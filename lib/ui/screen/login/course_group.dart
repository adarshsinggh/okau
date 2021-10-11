// ignore_for_file: no_logic_in_create_state

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../../helper/db_helper.dart';
import '../../../model/chapters.dart';
import '../../../model/course.dart';
import '../../../model/register.dart';
import '../../../model/subject.dart';
import '../../../model/topics.dart';
import '../../../model/units.dart';
import '../../constant/ApiConstant.dart';
import '../../constant/routes.dart';
import '../../constant/constant.dart';
import '../../../widgets/componants/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:velocity_x/velocity_x.dart';

class CourseGroup extends StatefulWidget {
  final mobile;
  const CourseGroup(this.mobile, {Key key}) : super(key: key);
  @override
  _CourseGroupState createState() => _CourseGroupState(mobile);
}

class _CourseGroupState extends State<CourseGroup> {
  _CourseGroupState(this.mobile);
  // ignore: prefer_typing_uninitialized_variables
  final mobile;
  int selectedIndex = 0;
  String type, year, courseName;
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _allData = [];
  var data;
  String selectedCourseSno = "0";
  Future _getCourse() async {
    try {
      var url = baseUrl + "getCourseGroup";
      print(url);
      var response = await http.get(url);
      List list = jsonDecode(response.body);
      await _dbHelper.insertCourseGroupBatch(list);
      _allData = await _dbHelper.getCourseType();
      print(_allData);
    } catch (e) {
      //print('_getCourseGroup : ' + e.toString());
    }
  }

  @override
  void initState() {
    data = _getCourse();
    super.initState();
    print(_allData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: 'Your Target Course'.text.make(),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Builder(builder: (context) {
                  return VStack(
                    [
                      ListView.builder(
                        itemCount: _allData.length,
                        shrinkWrap: true,
                        primary: false,
                        itemBuilder: (context, i) {
                          return VxCard(
                            VStack(
                              [
                                [
                                  Text(_allData[i]['type'], style: const TextStyle(fontSize: Vx.dp16, fontWeight: FontWeight.w600)).p4(),
                                  Text(_allData[i]['type'] == 'Engineering' ? '( IIT JEE-Main/Advance )' : '( NEET UG )', style: const TextStyle(fontSize: Vx.dp12)).pOnly(bottom: 15),
                                ].vStack().centered().backgroundColor(Colors.deepPurple.withOpacity(0.2)),
                                ListView.builder(
                                  itemCount: _allData[i]['detail'].length,
                                  shrinkWrap: true,
                                  primary: false,
                                  itemBuilder: (context, j) {
                                    return ListTile(
                                      selected: i == selectedIndex,
                                      selectedTileColor: Colors.deepPurple,
                                      title: ZStack(
                                        [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: selectedIndex == i
                                                ? Icon(
                                                    Icons.check,
                                                    color: whiteColor,
                                                  )
                                                : Container(),
                                          ),
                                          Text(_allData[i]['detail'][j]['courseName']).text.make().p(8)
                                        ],
                                      ).centered(),
                                      subtitle: Text(
                                        _allData[i]['detail'][j]['year'] + ' Year Foundation Course ',
                                        textAlign: TextAlign.center,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = i;
                                          selectedCourseSno = _allData[i]['detail'][j]['courseSno'].toString();
                                          print(selectedCourseSno);
                                          showBatch(context);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                              alignment: MainAxisAlignment.spaceBetween,
                            ),
                          ).elevation(10).make().p12();
                        },
                      ),
                      const SizedBox().hOneThird(context),
                      [
                        VxBox(child: 'Note :'.richText.withTextSpanChildren([' for assistance contact Lurnify team on'.textSpan.normal.make()]).sm.bold.center.makeCentered()).make().h4(context),
                        VxBox(child: 'WhatsApp :'.richText.withTextSpanChildren([' Team Lurnify'.textSpan.normal.make()]).sm.bold.center.makeCentered()).make().h4(context).onInkTap(() {
                          toastMethod('WhatsApp : 8505066587');
                        }),
                      ].vStack(),
                    ],
                  ).centered().scrollVertical();
                });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: CustomButton(
            verpad: const EdgeInsets.symmetric(vertical: 5),
            buttonText: "Let's Get Started",
            brdRds: 0,
            onPressed: () {
              _start();
            },
          ),
        ));
  }

  Future _start() async {
    try {
      if (selectedCourseSno == "0") {
        toastMethod("Please Select Course");
      } else {
        _otpSentAlertBox(context);
        SharedPreferences sp = await SharedPreferences.getInstance();
        var url = baseUrl + "saveRegistration?accountType=1&course=" + selectedCourseSno + "&mobile=" + mobile.toString();
        print(url);
        http.Response response = await http.post(
          Uri.encodeFull(url),
        );
        print(url);
        var resbody = jsonDecode(response.body);
        Map<String, dynamic> recentData = resbody;
        Navigator.of(context).pop();
        if (response.statusCode == 200) {
          sp.setString("mobile", mobile.toString());
          sp.setString("courseSno", selectedCourseSno.toString());
          sp.setString("studentSno", recentData['studentSno'].toString());
          sp.setString("firstMonday", recentData['firstMonday'].toString());
          sp.setString("joiningDate", recentData['joiningDate'].toString());

          //Saving data to local DB
          DBHelper dbHelper = DBHelper();
          Database db = await dbHelper.database;
          var batch = db.batch();

          batch.delete('course');
          batch.delete('subject');
          batch.delete('unit');
          batch.delete('chapter');
          batch.delete('topic');
          batch.delete('register');

          String sql="insert into challenge_accept (enteredBy,enteredDate,status,week,registerSno) "
              "values('default','${DateTime.now().toString()}','accepted','0','${recentData['studentSno'].toString()}')";
          print(sql);
          batch.rawInsert(sql);

          Map<String, dynamic> registerMap = jsonDecode(recentData['register']);
          Register register = Register();
          register.sno = recentData['studentSno'];
          // register.block = registerMap['block'];
          register.mobileno = registerMap['mobileno'];
          register.accountType = "1";
          register.courseId = selectedCourseSno.toString();
          register.firstMonday = registerMap['firstMonday'];
          register.joiningDate = registerMap['joiningDate'];

          // print(register.toJson());

          batch.insert('register', register.toJson());

          CourseDto courseDto = CourseDto();
          courseDto.sno = int.parse(selectedCourseSno);
          courseDto.courseName = courseName;

          batch.insert('course', courseDto.toJson());

          for (var a in recentData['courseContent']) {
            Subject subject = Subject();
            subject.sno = a['sno'];
            subject.subjectName = a['subjectName'];
            subject.courseSno = selectedCourseSno;
            batch.insert('subject', subject.toJson());

            List b = a['unitDtos'] ?? [];
            for (var c in b) {
              UnitDtos unitDtos = UnitDtos();
              unitDtos.sno = c['sno'];
              unitDtos.unitName = c['unitName'];
              unitDtos.subjectSno = a['sno'].toString();
              batch.insert('unit', unitDtos.toJson());

              List d = c['chapterDtos'] ?? [];
              for (var e in d) {
                ChapterDtos chapterDtos = ChapterDtos();
                chapterDtos.sno = e['sno'];
                chapterDtos.chapterName = e['chapterName'];
                chapterDtos.unitSno = c['sno'].toString();

                batch.insert('chapter', chapterDtos.toJson());

                List f = e['topicDtos'] ?? [];
                for (var g in f) {
                  // print('small wallaaaa'+g['subtopic']);
                  TopicDtos topicDtos = TopicDtos();
                  topicDtos.sno = g['sno'];
                  topicDtos.topicName = g['topicName'];
                  topicDtos.subtopic = g['subTopic'];
                  topicDtos.duration = g['duration'];
                  topicDtos.chapterSno = e['sno'].toString();
                  topicDtos.topicImp = g['topicImp'].toString();
                  topicDtos.topicLabel = g['topicLabel'];
                  batch.insert('topic', topicDtos.toJson());
                }
              }
            }
          }
          batch.commit();
          toastMethod("Registration Successful");
          // MyReportRepo myReportRepo = new MyReportRepo();
          // myReportRepo.getData();
          Navigator.of(context).pushNamedAndRemoveUntil(referralCode, (route) => false);
        } else {
          toastMethod("Registration Failed");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void toastMethod(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black54, textColor: Colors.white, fontSize: 18.0);
  }

  _otpSentAlertBox(BuildContext context) {
    var alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(firstColor),
          ),
          const SizedBox(
            width: 20,
          ),
          const Text("Please Wait...")
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future showBatch(context) {
    int _selectedIndex = 0;
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                title: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: firstColor,
                  ),
                  child: Text(
                    'Course Batches',
                    style: TextStyle(color: whiteColor, fontSize: Vx.dp16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                content: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          selected: 0 == _selectedIndex,
                          selectedTileColor: Colors.deepPurple,
                          title: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: _selectedIndex == 0
                                    ? Icon(
                                        Icons.check,
                                        color: whiteColor,
                                      )
                                    : Container(),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Course Batch A',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Text(
                            'Starting from 22 Oct 2021',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                            print(_selectedIndex);
                          },
                        ),
                        ListTile(
                          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                          selected: 1 == _selectedIndex,
                          title: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: _selectedIndex == 1 ? const Icon(Icons.check) : Container(),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Course Batch B',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Text(
                            'Starting from 28 Oct 2021',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                            print(_selectedIndex);
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                            width: double.maxFinite,
                            child: CustomButton(
                              verpad: const EdgeInsets.symmetric(vertical: 0),
                              buttonText: 'Done',
                              brdRds: 5,
                              onPressed: () {
                                _start();
                              },
                            )),
                      ],
                    )),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        // ignore: missing_return
        pageBuilder: (context, animation1, animation2) {});
  }
}
