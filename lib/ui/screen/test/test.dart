import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:lurnify/ui/constant/constant.dart';
import 'package:lurnify/ui/screen/test/test_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Test extends StatefulWidget {
  final Map<String, dynamic> testData;
  final String testType;
  final sno, course, subject, unit, chapter;
  Test(this.testData, this.testType, this.sno, this.course, this.subject, this.unit, this.chapter);
  @override
  _TestState createState() => _TestState(testData, testType, sno, course, subject, unit, chapter);
}

class _TestState extends State<Test> with TickerProviderStateMixin {
  final Map<String, dynamic> testData;
  final String testType, sno, course, subject, unit, chapter;
  _TestState(this.testData, this.testType, this.sno, this.course, this.subject, this.unit, this.chapter);
  int _index = 0, _currentPageIndex = 0;
  bool reviewLater = false;
  int selectedOptionIndex;
  Timer _timer;
  int _TEST_TIMER_INSECONDS = 600;
  // int _questionTime = 0;
  String _FORMATTED_TEST_DURATION = "";
  int _noOFQuestions;
  bool _isFirstQuestion = true;
  bool _isLastQuestion = false;
  PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  PageController _controllerList = PageController(viewportFraction: 0.083, keepPage: true);
  AnimationController _controllerFloat;
  Map _answerMap = Map();
  Map _bookmarkMap = Map();
  String _toolBarName = "";
  String _testName = "";
  List _testQuestions = [];
  int _totalSecond = 0;
  Map<String, int> _questionTiming = Map();
  static const List<IconData> icons =  [
    Icons.check_circle_outline,
    Icons.info_outline,
    Icons.format_align_left_rounded,
  ];
  static const List<String> iconsText =  ["Submit", "Current Section Instruction", "Test Instruction"];
  DateTime _currentBackPressTime;
  Future<bool> _onWillPop() {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null || now.difference(_currentBackPressTime) > Duration(seconds: 2)) {
      _currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press BACK again to exit Test', toastLength: Toast.LENGTH_SHORT);
      return Future.value(false);
    }
    return Future.value(true);
  }
  // Future _getTestData() async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   var url = baseUrl + "getTestByTopic?topicSno="+sno+"&registerSno="+sp.getString("studentSno");
  //   print(url);
  //   http.Response response = await http.get(
  //     Uri.encodeFull(url),
  //   );
  //   var responseData = jsonDecode(response.body);
  //   _testData=responseData;
  //   print(_testData);
  //   _testQuestions=_testData['test'];
  //   setState(() {
  //     _noOFQuestions = _testQuestions.length;
  //     _toolBarName = _testData['testName'];
  //     _testName = _testData['testName'];
  //   });
  //
  // }

  // Future _getRankBoosterTestData()async{
  //   _testQuestions=list[0]['test'];
  //   setState(() {
  //     _noOFQuestions = _testQuestions.length;
  //     _toolBarName = "Rank Booster Test";
  //     _testName = "Rank Booster Test";
  //   });
  // }

  void startTimer() {
    const oneSec =  Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_TEST_TIMER_INSECONDS < 1) {
            timer.cancel();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TestSummary(_testQuestions, _answerMap, _bookmarkMap, _FORMATTED_TEST_DURATION, sno, testType, course, subject, unit, chapter, _totalSecond, _questionTiming,false,timer),
              ),
            );
          } else {
            _totalSecond = _totalSecond + 1;
            _TEST_TIMER_INSECONDS = _TEST_TIMER_INSECONDS - 1;
            _FORMATTED_TEST_DURATION = _formatDuration(Duration(seconds: _TEST_TIMER_INSECONDS));
            // _questionTime = _questionTime + 1;

            _questionTiming.update(_testQuestions[_currentPageIndex]['sno'].toString(), (value) => value + 1, ifAbsent: () => 1);
          }
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String oneDigits(int n) {
      if (n <= 9) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${oneDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    print("---------------------------------------------");
    print(testData['topicTestTime']);
    if (testData['test'] != null) {
      _testQuestions = testData['test'] ?? [];
      _toolBarName = testData['testName'] ?? "";
      _testName = testData['testName'] ?? '';
      _TEST_TIMER_INSECONDS = int.tryParse(testData['topicTestTime']) ?? 600;
      if (_TEST_TIMER_INSECONDS == 0) {
        _TEST_TIMER_INSECONDS = 600;
      }
    }
    print(_testQuestions);
    if (_testQuestions != null) {
      _noOFQuestions = _testQuestions.length;
    }
    startTimer();
    _controllerFloat =  AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: whiteColor),
        title: Text(
          _toolBarName ?? "no tool bar",
          style: TextStyle(color: whiteColor),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        backgroundColor: firstColor,
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: _testQuestions.isEmpty
            ? Container(
                alignment: Alignment.center,
                child:const Text(
                  "No Question",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    headingRow(),
                    questionRow(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: buttonRow(),
      floatingActionButton:  Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:  List.generate(icons.length, (int index) {
          Widget child =  Container(
            height: 70.0,
//            width: 110.0,
            alignment: FractionalOffset.topCenter,
            child:  ScaleTransition(
                scale:  CurvedAnimation(
                  parent: _controllerFloat,
                  curve:  Interval(0.0, 1.0 - index / icons.length / 2.0, curve: Curves.fastOutSlowIn),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding:const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        iconsText[index],
                        style:const TextStyle(color: Colors.white),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: firstColor,
                      mini: true,
                      heroTag: null,
                      child:  Icon(icons[index], color: Colors.white),
                      onPressed: () {
                        _floatingButtonClick(index);
                      },
                    ),
                  ],
                )),
          );
          return child;
        }).toList()
          ..add(
             FloatingActionButton(
              heroTag: null,
              backgroundColor: firstColor,
              child:  AnimatedBuilder(
                animation: _controllerFloat,
                builder: (BuildContext context, Widget child) {
                  return  Transform(
                    transform:  Matrix4.rotationZ(_controllerFloat.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child:  Icon(_controllerFloat.isDismissed ? Icons.add : Icons.close),
                  );
                },
              ),
              foregroundColor: whiteColor,
              onPressed: () {
                if (_controllerFloat.isDismissed) {
                  _controllerFloat.forward();
                } else {
                  _controllerFloat.reverse();
                }
              },
            ),
          ),
      ),
    );
  }

  Widget headingRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 5 / 10,
                  padding:const EdgeInsets.all(5),
                  decoration: BoxDecoration(border: Border.all(color: firstColor), borderRadius: BorderRadius.circular(5)),
                  margin:const EdgeInsets.only(left: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _testName,
                      iconEnabledColor: firstColor,
                      isDense: true,
                      style: TextStyle(
                        color: firstColor,
                        fontWeight: FontWeight.w600,
                      ),
                      items: <String>[_testName].map((String value) {
                        return  DropdownMenuItem<String>(
                          value: value,
                          child:  Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _testName = value;
                        });
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: firstColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                      ),
                      const  SizedBox(
                        width: 3,
                      ),
                      Text(
                        _FORMATTED_TEST_DURATION,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          questionsNoList(),
        ],
      ),
    );
  }

  Widget questionRow() {
    return Container(
      height: MediaQuery.of(context).size.height * 6.8 / 10,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(1),
      child: PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: _noOFQuestions,
        onPageChanged: (i) {
          _currentPageIndex = i;
          HapticFeedback.selectionClick();
          if (i > 10) {
            _controllerList.animateToPage(i, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
          }
          setState(() {
            _index = i;
            if (i == 0) {
              _isFirstQuestion = true;
            } else if (i == _noOFQuestions - 1) {
              _isLastQuestion = true;
            } else {
              _isFirstQuestion = false;
              _isLastQuestion = false;
            }
            //-------------------//
          });
        },
        itemBuilder: (context, i) {
          return Transform.scale(
            scale: i == _index ? 1 : 0.9999,
            transformHitTests: true,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                color: whiteColor,
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(color: firstColor, border: Border.all(color: firstColor)),
                            child: Center(
                                child: Text(
                              (i + 1).toString(),
                              style: TextStyle(color: whiteColor, fontSize: 14, fontWeight: FontWeight.w500),
                            )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "4",
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text(
                              'X',
                              style: TextStyle(color: whiteColor, fontSize: 14, fontWeight: FontWeight.w500),
                            )),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "1",
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            "Review Later",
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: Checkbox(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              activeColor: firstColor,
                              checkColor: whiteColor,
                              onChanged: (value) {
                                setState(() {
                                  if (_bookmarkMap[_testQuestions[i]['sno']] == "true") {
                                    reviewLater = false;
//                                  _bookmarkMap.update(_testData[i]['sno'], (value) => "false",ifAbsent: () => "false",);
                                    _bookmarkMap.remove(_testQuestions[i]['sno']);
                                  } else {
                                    reviewLater = true;
                                    _bookmarkMap.update(
                                      _testQuestions[i]['sno'],
                                      (value) => "true",
                                      ifAbsent: () => "true",
                                    );
                                  }
                                  //
                                });
                              },
                              value: _bookmarkMap[_testQuestions[i]['sno']] == "true" ? true : false,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 4.5 / 10,
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              Expanded(
                                child: Image.memory(base64.decode(_testQuestions[i]['encodedImage'] == null ? "" : _testQuestions[i]['encodedImage']), gaplessPlayback: true),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ListView.builder(
                            itemCount: int.parse(_testQuestions[i]['noOfOptions']),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, j) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _answerMap.update(
                                      _testQuestions[i]['sno'],
                                      (value) => j + 1,
                                      ifAbsent: () => j + 1,
                                    );
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 2 / 10,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: _answerMap[_testQuestions[i]['sno']] != j + 1 ? Colors.transparent : Colors.green),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: _answerMap[_testQuestions[i]['sno']] != j + 1 ? Colors.white : Colors.green,
                                            child: Text(
                                              (j + 1).toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _answerMap[_testQuestions[i]['sno']] != j + 1 ? firstColor : whiteColor,
                                              ),
                                            ),
                                          ),
                                          decoration: new BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                offset: const Offset(
                                                  0.0,
                                                  5.0,
                                                ),
                                                blurRadius: 8.0,
                                              )
                                            ],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
//                                    Divider(height: 1,color: _answerMap[_testData[i]['sno']]!=j+1?Colors.grey:Colors.green,thickness: 3,)
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget questionNoRow() {
  //   return Container(
  //     padding: EdgeInsets.all(5),
  //     height: MediaQuery.of(context).size.height * 0.5 / 10,
  //     width: MediaQuery.of(context).size.width,
  //     child: PageView.builder(
  //       controller: _controllerList,
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _noOFQuestions,
  //       dragStartBehavior: DragStartBehavior.start,
  //       physics: BouncingScrollPhysics(),
  //       itemBuilder: (context, i) {
  //         return Padding(
  //           padding: EdgeInsets.only(left: 10, top: 5),
  //           child: GestureDetector(
  //             onTap: () {
  //               _controller.animateToPage(i,
  //                   curve: Curves.decelerate,
  //                   duration: Duration(milliseconds: 300));
  //             },
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: _answerMap[_testQuestions[i]['sno']] == null
  //                     ? _bookmarkMap.containsKey(_testQuestions[i]['sno'])
  //                         ? Colors.blue
  //                         : Colors.white
  //                     : _bookmarkMap.containsKey(_testQuestions[i]['sno'])
  //                         ? Colors.blue
  //                         : Colors.green,
  //                 border: Border.all(color: Colors.black54),
  //                 borderRadius: BorderRadius.circular(3),
  //               ),
  //               child: Center(child: Text((i + 1).toString())),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget questionsNoList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 / 10,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _controllerList,
        padding: EdgeInsets.all(5),
        scrollDirection: Axis.horizontal,
        itemCount: _noOFQuestions,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          return Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: GestureDetector(
              onTap: () {
                _controller.animateToPage(i, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
              },
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: _answerMap[_testQuestions[i]['sno']] == null
                      ? _bookmarkMap.containsKey(_testQuestions[i]['sno'])
                          ? Colors.blue
                          : Colors.white
                      : _bookmarkMap.containsKey(_testQuestions[i]['sno'])
                          ? Colors.blue
                          : Colors.green,
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                    child: Text(
                  (i + 1).toString(),
                  style: TextStyle(color: Colors.black87),
                )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buttonRow() {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: RaisedButton(
            clipBehavior: Clip.antiAlias,
            autofocus: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 16,
                ),
                Text(
                  "Previous",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ],
            ),
            onPressed: () {
              if (_isFirstQuestion) {
              } else {
                _controller.animateToPage(_index - 1, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
                if (_index > 10) {
                  _controllerList.animateToPage(_index - 1, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
                }
              }
            },
            padding: EdgeInsets.symmetric(vertical: 15),
            color: firstColor,
          ),
        ),
        // child: GestureDetector(
        //   onTap: () {
        //     if (_isFirstQuestion) {
        //     } else {
        //       _controller.animateToPage(_index - 1,
        //           curve: Curves.decelerate,
        //           duration: Duration(milliseconds: 300));
        //       _controllerList.animateToPage(_index - 1,
        //           curve: Curves.decelerate,
        //           duration: Duration(milliseconds: 300));
        //     }
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: _isFirstQuestion
        //             ? firstColor.withOpacity(0.6)
        //             : firstColor),
        //     child: Center(
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(
        //             Icons.arrow_back,
        //             color: Colors.white,
        //           ),
        //           Text(
        //             "Previous",
        //             style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.bold,
        //                 letterSpacing: 0.8),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        Flexible(
          flex: 1,
          child: RaisedButton(
            clipBehavior: Clip.antiAlias,
            autofocus: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
            onPressed: () {
              if (_isLastQuestion) {
              } else {
                _controller.animateToPage(_index + 1, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
                if (_index > 10) {
                  _controllerList.animateToPage(_index - 1, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
                }
              }
            },
            padding: EdgeInsets.symmetric(vertical: 15),
            color: firstColor,
          ),
          // child: GestureDetector(
          //   onTap: () {
          //     if (_isLastQuestion) {
          //     } else {
          //       _controller.animateToPage(_index + 1,
          //           curve: Curves.decelerate,
          //           duration: Duration(milliseconds: 300));
          //       _controllerList.animateToPage(_index + 1,
          //           curve: Curves.decelerate,
          //           duration: Duration(milliseconds: 300));
          //     }
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //         color: _isLastQuestion
          //             ? firstColor.withOpacity(0.6)
          //             : firstColor),
          //     child: Center(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text("Next",
          //               style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.bold,
          //                   letterSpacing: 0.8)),
          //           Icon(
          //             Icons.arrow_forward,
          //             color: Colors.white,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }

  _floatingButtonClick(int index) async {
    _controllerFloat.reverse();
    if (index == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TestSummary(_testQuestions, _answerMap, _bookmarkMap, _FORMATTED_TEST_DURATION, sno, testType, course, subject, unit, chapter, _totalSecond, _questionTiming,true,_timer),
        ),
      );
    }
  }

  void toastMethod(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 12.0);
  }
}
