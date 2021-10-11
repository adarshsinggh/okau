import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lurnify/helper/db_helper.dart';
import 'package:lurnify/ui/home_page.dart';
import 'package:lurnify/ui/screen/test/solution.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

class TestResult extends StatefulWidget {
  final int _correctQuestion, _wrongAnswer, _resultNumber;
  final List _testData;
  final Map _answerMap, _bookmarkMap;
  final _FORMATTED_TEST_DURATION;
  TestResult(this._correctQuestion, this._wrongAnswer, this._resultNumber, this._testData, this._answerMap, this._bookmarkMap,this._FORMATTED_TEST_DURATION);
  @override
  _TestResultState createState() => _TestResultState(_correctQuestion, _wrongAnswer, _resultNumber, _testData, _answerMap, _bookmarkMap);
}

class _TestResultState extends State<TestResult> with SingleTickerProviderStateMixin {
  final _correctQuestion, _wrongAnswer, _resultNumber;
  final List _testData;
  final Map _answerMap, _bookmarkMap;
  _TestResultState(this._correctQuestion, this._wrongAnswer, this._resultNumber, this._testData, this._answerMap, this._bookmarkMap);
  TabController _tabController;
  Timer _timer;

  @override
  void initState() {
    _tabController =  TabController(length: 2, vsync: this);
    super.initState();
    _timer = Timer(Duration(seconds: 1), () {
      _showDailyAppOpening();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Result"),
          leading: const Icon(null),
          actions: [
            IconButton(
                icon:const Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>const HomePage(),
                  ));
                })
          ],
          bottom: TabBar(
            tabs: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Tab(
                    child: Text("Score"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Tab(
                    child: Text("Analysis"),
                  ),
                ],
              )
            ],
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    resultCard(),
                    messageCard(),
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>const HomePage(),
                      ));
                    }, child:const Text('Go to home',style: TextStyle(color: Colors.white),))
                  ],
                ),
              ),
            ),
            Solution(_answerMap, _bookmarkMap, _testData,widget._FORMATTED_TEST_DURATION),
          ],
          controller: _tabController,
        ),
      ),
    );
  }

  Widget resultCard() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 1, spreadRadius: 1, offset: Offset(0, 1))]),
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 150.0,
                      lineWidth: 8.0,
                      percent: (_resultNumber / (_testData.length * 4)) < 0 ? 0 : _resultNumber / (_testData.length * 4),
                      animateFromLastPercent: true,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$_resultNumber",
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            height: 1.5,
                            width: 40,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text((_testData.length * 4).toString(), style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20))
                        ],
                      ),
                      progressColor: Colors.green,
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("$_correctQuestion Correct"),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("$_wrongAnswer Incorrect"),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text((_testData.length - (_wrongAnswer + _correctQuestion)).toString() + " Unattempted"),
                      ],
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: () {
                Share.share(
                  'Hey Check My Score in Lurnify Test ' + "$_resultNumber" + ' out of ' + (_testData.length * 4).toString(),
                );
              },
              child: Text("SHARE YOUR SCORE"),
            )
          ],
        ),
      ),
    );
  }

  Widget messageCard() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.style,
                  color: Colors.deepPurpleAccent,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "SSS Suggest : ",
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.deepPurpleAccent,
                ),
                Expanded(
                  child: Text(
                    "Dear Student, Attempt more question to improve your score, the more you attempt the more you get! ",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      letterSpacing: 0.6,
                      wordSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showDailyAppOpening() async {
    String testAttempt="0";
    String testScore="0";
    DBHelper dbHelper= DBHelper();
    Database db=await dbHelper.database;
    List<Map<String,dynamic>> list =await db.rawQuery('select testAttempt,testScore from reward order by sno desc limit 1');
    for(var a in list){
      testAttempt=a['testAttempt'] ?? '0';
      testScore=a['testScore'] ?? '0';
    }
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Congratulations',
      desc: "You earn $testAttempt dimes for attempting "
              "test and \n $testScore for scoring in test.\n Total dimes "
              "earn in this test is ${(int.parse(testScore) + int.parse(testAttempt)).toString()}.",
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      btnOkColor: Colors.black87,
      btnOkText: "Great",
      btnOkOnPress: () {},
    )..show();
  }
}
