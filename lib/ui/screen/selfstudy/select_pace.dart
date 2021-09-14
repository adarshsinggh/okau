import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../helper/db_helper.dart';
import '../../../helper/pace_repo.dart';
import '../../../widgets/componants/custom-button.dart';
import '../../../model/pace.dart';
import '../../constant/constant.dart';
import '../../home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SelectThePace extends StatefulWidget {
  final bool backButtonWillWork;
  const SelectThePace(this.backButtonWillWork, {Key key}) : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  _SelectThePaceState createState() => _SelectThePaceState(backButtonWillWork);
}

class _SelectThePaceState extends State<SelectThePace> {
  _SelectThePaceState(this.backButtonWillWork);
  final bool backButtonWillWork;
  String _radioValue; //Initial definition of radio button value
  String choice;
  bool customProgram = false;
  String completionDate = "";
  double totalDuration = 0;
  String customValue;
  String expectedRank = "100";
  String completionYear = "2022";
  String completionMonth = "JAN";
  String completionDay = "02";
  double totalTiming = 0.0;
  var formatter = DateFormat('dd MMM yyyy');
  var _data;
  DateTime selectedDate = DateTime.now();
  double totalPerDayHours = 0;

  Future getTotalTopicDuration() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      DBHelper dbHelper = DBHelper();
      List<Map<String, dynamic>> map = await dbHelper.getTotalTopicDurationByCourse(sp.get("courseSno"));
      int tDuration = 0;
      for (var a in map) {
        tDuration = a['totalDuration'] ?? 0;
      }
      String getTotalDuration = tDuration.toString() ?? "0";
      totalDuration = double.parse(getTotalDuration);

      Database database = await dbHelper.database;
      String sql = "select * from pace order by sno desc limit 1";
      List<Map<String, dynamic>> list = await database.rawQuery(sql);
      for (var a in list) {
        print(a);
        expectedRank = a['expectedRank'];
        //completionDate = DateFormat('dd MMM yyyy').parse(a['syllabusCompletionDate']).toString();
        completionDate = '$completionDay + $completionMonth + $completionYear';
        totalPerDayHours = a['perDayStudyHour'];
      }
      // totalDuration = 0;
      // toastMethod(totalDuration.toString());
    } catch (e) {
      print(e);
      toastMethod(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // completionDate = formatter.format(DateTime.now().add(Duration(days: 180)));
    _data = getTotalTopicDuration();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => backButtonWillWork,
      child: Scaffold(
        appBar: AppBar(
          title: 'Self Study Program Pace'.text.make(),
          centerTitle: true,
          elevation: 0,
          leading: backButtonWillWork
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                )
              : Container(),
        ),
        body: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Material(
                color: Colors.transparent,
                child: [
                  rankSelector(),
                  completionDateSet(),
                  const SizedBox(
                    height: 10,
                  ),
                  studyHoursPick(),
                  const SizedBox(
                    height: 10,
                  ),
                ].vStack().scrollVertical(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        bottomNavigationBar: CustomButton(
          brdRds: 0,
          buttonText: 'Start ',
          onPressed: () {
            submit();
          },
          verpad: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        ),
      ),
    );
  }

  Widget completionDateSet() {
    return Builder(builder: (context) {
      return VxCard(
        VStack(
          [
            ('Course Deadline Challange'.text.white.xl.medium.makeCentered().p8()).box.color(Colors.deepPurple).make(),
            10.heightBox,
            'You Challange yourself to Complete your syllabus at most by...'.text.sm.center.lineHeight(1.5).make().p8().centered(),
            10.heightBox,
            [
              (completionYear.text.bold.make().p8())
                  .onInkTap(() {
                    showCupertinoModalPopup(
                        barrierColor: Colors.black54,
                        context: context,
                        builder: (context) {
                          return [
                            VxCard(VStack(
                              [
                                ('Select Target Year'.text.xl.medium.makeCentered().p8()).box.color(Colors.deepPurple[200]).make(),
                                Wrap(
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    _yearSelect('2021'),
                                    _yearSelect('2022'),
                                    _yearSelect('2023'),
                                  ],
                                ).wFull(context).p4(),
                                CustomButton(
                                  buttonText: 'Select',
                                  brdRds: 5,
                                  verpad: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                  onPressed: () {
                                    context.pop();
                                  },
                                ).centered(),
                                10.heightBox,
                              ],
                              alignment: MainAxisAlignment.spaceBetween,
                            )).make().p12().h40(context),
                          ].vStack().centered().wFull(context).hFull(context);
                        });
                  })
                  .card
                  .color(Colors.deepPurple.shade200)
                  .elevation(5)
                  .roundedSM
                  .make()
                  .centered()
                  .p8(),
              (completionMonth.text.bold.make().p8())
                  .onInkTap(() {
                    showCupertinoModalPopup(
                        barrierColor: Colors.black54,
                        context: context,
                        builder: (context) {
                          return [
                            VxCard(VStack(
                              [
                                ('Select Target Month'.text.xl.medium.makeCentered().p8()).box.color(Colors.deepPurple[200]).make(),
                                Wrap(
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    _monthSelect('JAN'),
                                    _monthSelect('FEB'),
                                    _monthSelect('MAR'),
                                    _monthSelect('APR'),
                                    _monthSelect('MAY'),
                                    _monthSelect('JUN'),
                                    _monthSelect('JUL'),
                                    _monthSelect('AUG'),
                                    _monthSelect('SEP'),
                                    _monthSelect('OCT'),
                                    _monthSelect('NOV'),
                                    _monthSelect('DEC'),
                                  ],
                                ).wFull(context).p4(),
                                CustomButton(
                                  buttonText: 'Select',
                                  brdRds: 5,
                                  verpad: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                  onPressed: () {
                                    context.pop();
                                  },
                                ).centered(),
                                10.heightBox,
                              ],
                              alignment: MainAxisAlignment.spaceBetween,
                            )).make().p12().h56(context),
                          ].vStack().centered().wFull(context).hFull(context);
                        });
                  })
                  .card
                  .color(Colors.deepPurple.shade200)
                  .elevation(5)
                  .roundedSM
                  .make()
                  .centered()
                  .p8(),
              (completionDay.text.bold.make().p8())
                  .onInkTap(() {
                    showCupertinoModalPopup(
                        barrierColor: Colors.black54,
                        context: context,
                        builder: (context) {
                          return [
                            VxCard(VStack(
                              [
                                ('Select Target Date'.text.xl.medium.makeCentered().p8()).box.color(Colors.deepPurple[200]).make(),
                                Wrap(
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    _daySelect('02'),
                                    _daySelect('09'),
                                    _daySelect('16'),
                                    _daySelect('23'),
                                    _daySelect('30'),
                                  ],
                                ).wFull(context).p4(),
                                CustomButton(
                                  buttonText: 'Select',
                                  brdRds: 5,
                                  verpad: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                  onPressed: () {
                                    context.pop();
                                  },
                                ).centered(),
                                10.heightBox,
                              ],
                              alignment: MainAxisAlignment.spaceBetween,
                            )).make().p12().h40(context),
                          ].vStack().centered().wFull(context).hFull(context);
                        });
                  })
                  .card
                  .color(Colors.deepPurple.shade200)
                  .elevation(5)
                  .roundedSM
                  .make()
                  .centered()
                  .p8(),
            ].hStack().centered(),
            '(CourseName)'.text.sm.center.lineHeight(1.5).make().centered().py12(),
          ],
        ),
      ).elevation(10).roundedSM.p8.make().centered().px12();
    });
  }

  Widget studyHoursPick() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.deepPurple, width: 1), borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: firstColor),
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: double.maxFinite,
            alignment: Alignment.center,
            child: const Text(
              "Self Study Average Hours Per Day",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Row(
            children: [
              Radio(
                value: 'one',
                groupValue: _radioValue,
                onChanged: radioButtonChanges,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Standard Program:",
                  ),
                  Text(
                    "6 Hrs a Day",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'two',
                groupValue: _radioValue,
                onChanged: radioButtonChanges,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Comprehensive Program:",
                  ),
                  Text(
                    "8 Hrs a Day",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'three',
                groupValue: _radioValue,
                onChanged: radioButtonChanges,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Exhaustive Program:",
                  ),
                  Text(
                    "10 Hrs a Day",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'four',
                groupValue: _radioValue,
                onChanged: radioButtonChanges,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Custom Program:",
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: const InputDecoration(hintText: "4.5"),
                          enabled: customProgram,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              totalTiming = double.parse(value);
                            });
                          },
                        ),
                      ),
                      const Text(
                        "Hrs",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ).px12();
  }

  Widget rankSelector() {
    return Builder(builder: (context) {
      return VxCard(
        VStack(
          [
            ('Rank Challange'.text.white.xl.semiBold.makeCentered().p8()).box.color(Colors.deepPurple).make(),
            'You Challange yourself not to exceed your rank beyond'.text.sm.center.lineHeight(1.5).make().centered(),
            (' $expectedRank'.text.bold.make().p8())
                .onInkTap(() {
                  showCupertinoModalPopup(
                      barrierColor: Colors.black54,
                      context: context,
                      builder: (context) {
                        return [
                          VxCard(VStack(
                            [
                              ('Rank Challange'.text.xl.medium.makeCentered().p8()).box.color(Colors.deepPurple[200]).make(),
                              'You Challange yourself not to exceed your rank beyond'.text.sm.center.lineHeight(1.5).make().p8(),
                              (expectedRank.text.bold.make().p8()).px12().card.elevation(10).roundedSM.make().centered().p4(),
                              // todo place the student selected coursename in below bracket
                              'in your (CourseName)'.text.sm.center.lineHeight(1.5).make().centered(),
                              20.heightBox,
                              Wrap(
                                alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  _rankSelect('10'),
                                  _rankSelect('100'),
                                  _rankSelect('500'),
                                  _rankSelect('1000'),
                                  _rankSelect('2000'),
                                  _rankSelect('5000'),
                                  _rankSelect('10000'),
                                ],
                              ).wFull(context),
                              20.heightBox,
                            ],
                            alignment: MainAxisAlignment.spaceBetween,
                          )).make().p12().h60(context),
                        ].vStack().centered().wFull(context).hFull(context);
                      });
                })
                .card
                .color(Colors.deepPurple.shade200)
                .elevation(5)
                .roundedSM
                .make()
                .centered()
                .p8(),
            'in your (CourseName)'.text.sm.center.lineHeight(1.5).make().centered().py12(),
          ],
        ),
      ).elevation(10).roundedSM.p8.make().centered().px12();
    });
  }

  Widget _rankSelect(String rank) {
    return (rank.text.bold.make().p16())
        .onInkTap(() {
          setState(() {
            expectedRank = rank;
            context.pop();
          });
        })
        .card
        .elevation(5)
        .roundedSM
        .make();
  }

  Widget _daySelect(String day) {
    return (day.text.bold.make().p16())
        .onInkTap(() {
          setState(() {
            completionDay = day;
          });
        })
        .card
        .elevation(5)
        .roundedSM
        .make();
  }

  Widget _monthSelect(String month) {
    return (month.text.bold.make().p16())
        .onInkTap(() {
          setState(() {
            completionMonth = month;
          });
        })
        .card
        .elevation(5)
        .roundedSM
        .make();
  }

  Widget _yearSelect(String year) {
    return (year.text.bold.make().p16())
        .onInkTap(() {
          setState(() {
            completionYear = year;
          });
        })
        .card
        .elevation(5)
        .roundedSM
        .make();
  }

  void radioButtonChanges(String value) {
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'one':
          customProgram = false;
          customValue = null;
          choice = value;
          totalTiming = 6;
          break;
        case 'two':
          customProgram = false;
          customValue = null;
          choice = value;
          totalTiming = 8;
          break;
        case 'three':
          customProgram = false;
          customValue = null;
          choice = value;
          totalTiming = 10;
          break;
        case 'four':
          customProgram = true;
          customValue = null;
          choice = value;
          break;
      }
      debugPrint(choice); //Debug the choice in console
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      confirmText: 'Confirm',
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2023),
    );

    if (picked != null) selectedDate = picked;
    if (DateFormat('EEEE').format(selectedDate) == "Sunday") {
      completionDate = formatter.format(selectedDate);
      print(completionDate);
      SharedPreferences sp = await SharedPreferences.getInstance();
      print(sp.getString('firstMonday'));
      Duration inDays = selectedDate.difference(DateTime.parse(sp.getString('firstMonday')));
      int convertedInDays = inDays.inDays;
      print(convertedInDays);
      print(totalDuration);
      setState(() {
        if (customValue == null) {
          totalPerDayHours = (totalDuration / 60).round() / convertedInDays;
        } else {
          totalPerDayHours = double.parse(customValue);
        }
        print(totalPerDayHours);
      });
    } else {
      Fluttertoast.showToast(msg: 'Selected Date should be sunday');
    }
  }

  void submit() async {
    try {
      if (selectedDate.toString().split(" ")[0] == DateTime.now().toString().split(" ")[0]) {
        toastMethod("Please Select Syllabus Completion Date");
      } else {
        print(totalPerDayHours);
        if (totalPerDayHours > 15) {
          toastMethod("Too Less");
        } else {
          SharedPreferences sp = await SharedPreferences.getInstance();
          String studentSno = sp.getString("studentSno");
          String syllabusCompletionDate = selectedDate.toString();

          totalTiming ??= totalPerDayHours;

          String perDayStudyHour = totalTiming.toString();
          double userStudyHourDifference = totalTiming - totalPerDayHours; //user selected-standard time
          double percentDifference = (userStudyHourDifference * 100) / totalPerDayHours;
          String courseSno = sp.get("courseSno");
          Pace pace = Pace();
          pace.courseSno = courseSno;
          pace.enteredDate = DateTime.now().toString();
          pace.studentSno = studentSno;
          pace.expectedRank = expectedRank;
          pace.perDayStudyHour = perDayStudyHour;
          pace.syllabusCompletionDate = syllabusCompletionDate;
          pace.percentDifference = percentDifference.toStringAsFixed(2);
          pace.register = sp.getString('studentSno');

          PaceRepo paceRepo = PaceRepo();
          paceRepo.insertIntoPace(pace);

          FirebaseFirestore.instance.collection('pace').add(pace.toJson());

          toastMethod("Data Saved Successfully");

          sp.setString("courseCompletionDate", completionDate);
          sp.setString("courseCompletionDateFormatted", selectedDate.toString().split(" ")[0]);
          //
          sp.setString("courseStartingDate", sp.getString('firstMonday'));
          sp.setInt("totalWeeks", (selectedDate.difference(DateTime.now()).inDays / 7).round());
          sp.setDouble("totalStudyHour", totalTiming);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()), ModalRoute.withName('/'));
        }
      }
    } catch (e) {
      toastMethod("123 " + e.toString());
    }
  }

  void toastMethod(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black54, textColor: Colors.white, fontSize: 18.0);
  }
}
