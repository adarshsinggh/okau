import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import '../../../helper/db_helper.dart';
import '../../../model/chapters.dart';
import '../../../model/course.dart';
import '../../../model/register.dart';
import '../../../model/subject.dart';
import '../../../model/topics.dart';
import '../../../model/units.dart';
import '../../constant/ApiConstant.dart';
import '../../constant/constant.dart';
import '../../../widgets/componants/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'referal_code.dart';

class CourseSelection extends StatefulWidget {
  final mobile;
  final type, year, courseName;
  CourseSelection(this.mobile, this.year, this.type, this.courseName);

  @override
  _CourseSelectionState createState() => _CourseSelectionState(mobile, year, type, courseName);
}

class _CourseSelectionState extends State<CourseSelection> {
  String mobile, type, year, courseName;
  _CourseSelectionState(this.mobile, this.year, this.type, this.courseName);

  var data;
  List<Map<String, dynamic>> courseList = [];
  int selectedIndex;
  String selectedCourseSno = "0";
  Future getCourse() async {
    try {
      DBHelper dbHelper = DBHelper();
      courseList = await dbHelper.getCourse(type, year);
      print(courseList);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    data = getCourse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Available Programs",style: TextStyle(color: Colors.purpleAccent),),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: data,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  getCourse();
                },
                child: SingleChildScrollView(
                  physics:const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                     const SizedBox(
                        height: 30,
                      ),
                      ListView.builder(
                        itemCount: courseList.length,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = i;
                                selectedCourseSno = courseList[i]['courseSno'];
                              });
                            },
                            child: Padding(
                              padding:const EdgeInsets.all(10),
                              child: Container(
                                padding:const EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border: selectedIndex == i ? Border.all(color: firstColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                    color: firstColor.withOpacity(0.1)),
                                child: Center(
                                    child: Text(
                                  courseList[i]['courseName'],
                                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                                )),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Lottie.asset(
                  'assets/lottie/56446-walk.json',
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        child: CustomButton(
          verpad: EdgeInsets.symmetric(vertical: 5),
          buttonText: "Let's Get Started",
          brdRds: 0,
          onPressed: () {
            _start();
          },
        ),
      ),
    );
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
          DBHelper dbHelper = new DBHelper();
          Database db = await dbHelper.database;
          var batch = db.batch();

          batch.delete('course');
          batch.delete('subject');
          batch.delete('unit');
          batch.delete('chapter');
          batch.delete('topic');
          batch.delete('register');

          Map<String, dynamic> registerMap = jsonDecode(recentData['register']);
          Register register =  Register();
          register.sno = recentData['studentSno'];
          // register.block = registerMap['block'];
          register.mobileno = registerMap['mobileno'];
          register.accountType = "1";
          register.courseId = selectedCourseSno.toString();
          register.firstMonday = registerMap['firstMonday'];
          register.joiningDate = registerMap['joiningDate'];

          // print(register.toJson());

          batch.insert('register', register.toJson());

          CourseDto courseDto = new CourseDto();
          courseDto.sno = int.parse(selectedCourseSno);
          courseDto.courseName = courseName;

          batch.insert('course', courseDto.toJson());

          for (var a in recentData['courseContent']) {
            Subject subject = new Subject();
            subject.sno = a['sno'];
            subject.subjectName = a['subjectName'];
            subject.courseSno = selectedCourseSno;
            batch.insert('subject', subject.toJson());

            List b = a['unitDtos'] ?? [];
            for (var c in b) {
              UnitDtos unitDtos = new UnitDtos();
              unitDtos.sno = c['sno'];
              unitDtos.unitName = c['unitName'];
              unitDtos.subjectSno = a['sno'].toString();
              batch.insert('unit', unitDtos.toJson());

              List d = c['chapterDtos'] ?? [];
              for (var e in d) {
                ChapterDtos chapterDtos = new ChapterDtos();
                chapterDtos.sno = e['sno'];
                chapterDtos.chapterName = e['chapterName'];
                chapterDtos.unitSno = c['sno'].toString();

                batch.insert('chapter', chapterDtos.toJson());

                List f = e['topicDtos'] ?? [];
                for (var g in f) {
                  // print('small wallaaaa'+g['subtopic']);
                  TopicDtos topicDtos = new TopicDtos();
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReferalCode()));
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
      content: new Row(
        children: [
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(firstColor),
          ),
          SizedBox(
            width: 20,
          ),
          Text("Please Wait...")
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
                    style: TextStyle(color: whiteColor, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                content: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          selected: 0 == _selectedIndex,
                          title: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: _selectedIndex == 0 ? Icon(Icons.check) : Container(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Course Batch A',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
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
                          selected: 2 == _selectedIndex,
                          title: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: _selectedIndex == 2 ? Icon(Icons.check) : Container(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Course Batch B',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Starting from 28 Oct 2021',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                            print(_selectedIndex);
                          },
                        ),
                        Spacer(),
                        SizedBox(
                            width: double.maxFinite,
                            child: CustomButton(
                              verpad: EdgeInsets.symmetric(vertical: 0),
                              buttonText: 'Done',
                              brdRds: 10,
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
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        // ignore: missing_return
        pageBuilder: (context, animation1, animation2) {});
  }
}
