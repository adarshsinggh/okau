import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:lurnify/helper/topic_test_result_repo.dart';
import 'package:lurnify/helper/due_topic_test_repo.dart';
import 'package:lurnify/model/topic_test_result.dart';
import 'package:lurnify/ui/constant/ApiConstant.dart';
import 'package:lurnify/ui/screen/test/test_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestSummary extends StatefulWidget {
  final Map _answerMap, _bookmarkMap;
  final List _testData;
  final String _FORMATTED_TEST_DURATION, testType;
  final sno, course, subject, unit, chapter;
  final int totalSecond;
  final Map<String, dynamic> questionTiming;
  final bool canBack;
  final Timer timer;

  TestSummary(this._testData, this._answerMap, this._bookmarkMap, this._FORMATTED_TEST_DURATION, this.sno, this.testType, this.course, this.subject, this.unit, this.chapter, this.totalSecond,
      this.questionTiming,this.canBack,this.timer);

  @override
  _TestSummaryState createState() => _TestSummaryState(_testData, _answerMap, _bookmarkMap, _FORMATTED_TEST_DURATION, sno, testType, course, subject, unit, chapter, totalSecond);
}

class _TestSummaryState extends State<TestSummary> {
  final Map _answerMap, _bookmarkMap;
  final List _testData;
  final sno, course, subject, unit, chapter;
  String _FORMATTED_TEST_DURATION, testType;
  final int totalSecond;

  _TestSummaryState(this._testData, this._answerMap, this._bookmarkMap, this._FORMATTED_TEST_DURATION, this.sno, this.testType, this.course, this.subject, this.unit, this.chapter, this.totalSecond);

  String totalNoOFQuestions = "0";
  String totalNoOFAnsweredQuestions = "0";
  String totalUnanswered = "0";
  String totalReviewLater = "0";
  int _correctQuestion = 0;
  int _wrongAnswer = 0;
  int _resultNumber = 0;

  // ignore: missing_return
  Future getTestSummary() {
    totalNoOFQuestions = _testData.length.toString();
    totalNoOFAnsweredQuestions = _answerMap.length.toString();
    totalUnanswered = (_testData.length - _answerMap.length).toString();
    totalReviewLater = _bookmarkMap.length.toString();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.canBack,
      child: Scaffold(
          appBar: AppBar(
            title:const Text("Summary"),
          ),
          body: FutureBuilder(
            future: getTestSummary(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Lottie.asset(
                      'assets/lottie/56446-walk.json',
                    ),
                  ),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.amberAccent),
                          child: Center(
                            child: Text(
                              "Remaining Time ($_FORMATTED_TEST_DURATION)",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.black38),
                          child: Center(
                            child: Text(
                              "All Questions ($totalNoOFQuestions)",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.green),
                          child: Center(
                            child: Text(
                              "Answered ($totalNoOFAnsweredQuestions)",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.red),
                          child: Center(
                            child: Text(
                              "Unanswered ($totalUnanswered)",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.blue),
                          child: Center(
                            child: Text(
                              "Review Later ($totalReviewLater)",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // ignore: deprecated_member_use
                        RaisedButton(
                          color: Colors.deepPurpleAccent,
                          splashColor: Colors.black87,
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            _testSubmit();
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          )),
    );
  }

  Future _testSubmit() async {
    _correctQuestion = 0;
    _resultNumber = 0;
    _wrongAnswer = 0;
    SharedPreferences sp = await SharedPreferences.getInstance();
    for (int i = 0; i < _testData.length; i++) {
      if (_answerMap.containsKey(_testData[i]['sno'])) {
        if (_answerMap[_testData[i]['sno']].toString() == _testData[i]['answer']) {
          _correctQuestion = _correctQuestion + 1;
          _resultNumber = _resultNumber + 4;
        } else {
          _wrongAnswer = _wrongAnswer + 1;
          _resultNumber = _resultNumber - 1;
        }
      }
    }
    int _wrongQuestion = _testData.length - _correctQuestion;
    double _testPercent = (_correctQuestion / _testData.length) * 100;
    var url = "";
    int result = 0;
    if (testType == "topicTest") {
      TopicTestResult topicTestResult =  TopicTestResult();
      topicTestResult.regSno = sp.getString("studentSno");
      topicTestResult.totalQuestion = _testData.length.toString();
      topicTestResult.correctQuestion = _correctQuestion.toString();
      topicTestResult.wrongQuestion = _wrongQuestion.toString();
      topicTestResult.resultNumber = _resultNumber.toString();
      topicTestResult.testPercent = _testPercent.toStringAsFixed(2);
      topicTestResult.answerMap = _answerMap.toString();
      topicTestResult.totalTestTime = totalSecond.toString();

      topicTestResult.enteredDate = DateTime.now().toString();
      topicTestResult.topicSno = sno.toString();
      topicTestResult.course = course.toString();
      topicTestResult.subject = subject.toString();
      topicTestResult.unit = unit.toString();
      topicTestResult.chapter = chapter.toString();
      topicTestResult.status = 'new';

      topicTestResult.questionTiming = jsonEncode(widget.questionTiming);

      TopicTestResultRepo topicTestResultRepo =  TopicTestResultRepo();
      result = await topicTestResultRepo.insertIntoTopicTestResult(topicTestResult);

      // FirebaseFirestore.instance.collection('topicTestResult').add(topicTestResult.toJson());
      if (_testPercent >= 50) {
        DueTopicTestRepo dueTopicTestRepo =  DueTopicTestRepo();
        List<Map<String, dynamic>> list2 = await dueTopicTestRepo.getDueTopicTestByStatusAndTopicAndRegister('INCOMPLETE', sno, sp.getString("studentSno"));
        if (list2.isNotEmpty) {
          dueTopicTestRepo.updateDueTopicTest(sno);
          FirebaseFirestore.instance
              .collection('dueTopicTest')
              .where('status', isEqualTo: 'INCOMPLETE')
              .where('topicSno', isEqualTo: sno)
              .where('registerSno', isEqualTo: sp.getString("studentSno"))
              .get()
              .then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((element) {
              element.reference.update({'status': 'Complete'});
            });
          });
        }
      }
      // url = baseUrl +
      //     "saveTopicTest?regSno=" +
      //     sp.getString("studentSno") +
      //     "&totalQuestion=" +
      //     _testData.length.toString() +
      //     "&correctQuestion=" +
      //     _correctQuestion.toString() +
      //     "&wrongQuestion=" +
      //     _wrongQuestion.toString() +
      //     "&resultNumber=" +
      //     _resultNumber.toString() +
      //     "&testPercent=" +
      //     _testPercent.toStringAsFixed(2) +
      //     "&topicSno=" +
      //     sno.toString();
    } else if (testType == "rankBoosterTest") {
      url = baseUrl +
          "saveRankBoosterTest?regSno=" +
          sp.getString("studentSno") +
          "&totalQuestion=" +
          _testData.length.toString() +
          "&correctQuestion=" +
          _correctQuestion.toString() +
          "&wrongQuestion=" +
          _wrongQuestion.toString() +
          "&resultNumber=" +
          _resultNumber.toString() +
          "&testPercent=" +
          _testPercent.toStringAsFixed(2);
    }

    // print(url);
    // print(_answerMap.toString());
    // http.Response response = await http.post(Uri.encodeFull(url),
    //     body: jsonEncode(_answerMap.toString()));
    // var responseData = jsonDecode(response.body);
    // print(responseData);
    if (result > 0) {
      toastMethod("Test Submitted Successful");
      if(widget.timer.isActive){
        widget.timer.cancel();
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => TestResult(_correctQuestion, _wrongAnswer, _resultNumber, _testData, _answerMap, _bookmarkMap, _FORMATTED_TEST_DURATION), //yha pr response ko hataye hai
      ));
    } else {
      toastMethod("Failed.");
    }
  }

  void toastMethod(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black54, textColor: Colors.white, fontSize: 18.0);
  }
}
