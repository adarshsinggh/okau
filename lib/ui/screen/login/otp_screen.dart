import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lurnify/widgets/componants/custom_alert.dart';
import '../../../helper/db_helper.dart';
import '../../../model/chapters.dart';
import '../../../model/course.dart';
import '../../../model/register.dart';
import '../../../model/subject.dart';
import '../../../model/topics.dart';
import '../../../model/units.dart';
import '../../constant/ApiConstant.dart';
import '../../constant/constant.dart';
import '../../home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'course_group.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final String verificationId;

  const OtpScreen({Key key, this.mobile, this.verificationId}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState(verificationId, mobile);
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  String verificationId;
  String mobile;
  _OtpScreenState(this.verificationId, this.mobile);

  // Constants
  int time = 60;
  AnimationController _controller;
  DBHelper dbHelper = DBHelper();
  Database database;
  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  int _fifthDigit;
  int _sixthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  FirebaseAuth _auth = FirebaseAuth.instance;
  String phoneNo;
  String errorMessage = '';

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return Text(
      "Verification Code",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
    );
  }

  // Return "Email" label
  get _getEmailLabel {
    this.phoneNo = "+91" + mobile;
    return Text(
      "Please enter the OTP sent\non " + this.phoneNo,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
        _otpTextField(_fifthDigit),
        _otpTextField(_sixthDigit),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        _getVerificationCodeLabel,
        _getEmailLabel,
        _getInputField,
        _hideResendButton ? _getTimerText : _getResendButton,
        _getOtpKeyboard
      ],
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.access_time),
            SizedBox(
              width: 5.0,
            ),
            OtpTimer(_controller, 15.0)
          ],
        ),
      ),
    );
  }

  // Returns "Resend" button
  get _getResendButton {
    return InkWell(
      child: Container(
        height: 32,
        width: 120,
        decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(32)),
        alignment: Alignment.center,
        child: Text(
          "Resend OTP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        _startCountdown();
        _resendCode();
      },
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        height: _screenSize.width - 80,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                        setState(() {
                          time = 60;
                        });
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: Icon(
                        Icons.backspace,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixthDigit != null) {
                            _sixthDigit = null;
                          } else if (_fifthDigit != null) {
                            _fifthDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: time))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() {
            _hideResendButton = !_hideResendButton;
          });
        }
      });
    _controller.reverse(from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
    _initializeDb();
  }

  _initializeDb() async {
    database = await dbHelper.database;
    print('Database intitalized');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
          child: _getInputPart,
        ),
      ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    return Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: Text(
        digit != null ? digit.toString() : "",
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(bottom: BorderSide(width: 2.0, color: isDark ? Colors.white : Colors.black87))),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          height: 80.0,
          width: 80.0,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: firstColor)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fifthDigit == null) {
        _fifthDigit = _currentDigit;
      } else if (_sixthDigit == null) {
        _sixthDigit = _currentDigit;

        var otp = _firstDigit.toString() + _secondDigit.toString() + _thirdDigit.toString() + _fourthDigit.toString() + _fifthDigit.toString() + _sixthDigit.toString();
        _verifyOtp(otp);

        // Verify your otp by here. API call
      }
    });
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }

  Future<void> _resendCode() async {
    this.phoneNo = "+91" + mobile;
    // ignore: await_only_futures
    FirebaseAuth _auth = await FirebaseAuth.instance;
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      verificationId = verId;
      print('Code sent to ' + this.phoneNo);
    };
    try {
      _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (Exception exceptio) {
            print('${exceptio.toString()}');
          });
      print("1" + verificationId);
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });
        break;
    }
  }

  _verifyOtp(smsOTP) async {
    try {
      _submitAlertBox(context);
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential user = await _auth.signInWithCredential(credential);
      // ignore: await_only_futures
      final User currentUser = await _auth.currentUser;
      if (user.user.uid == currentUser.uid) {
        String url = baseUrl + "checkIfUserExist?mobile=$mobile";
        http.Response response = await http.post(Uri.encodeFull(url));
        var body = jsonDecode(response.body);
        if (body['result'] == true) {
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("mobile", mobile.toString());
          sp.setString("courseSno", body['courseSno']);
          sp.setString("studentSno", body['studentSno'].toString());
          sp.setString("firstMonday", body['firstMonday'].toString());
          sp.setString("joiningDate", body['joiningDate'].toString());

          //Saving data to local DB
          // DBHelper dbHelper = new DBHelper();
          // Database db = await dbHelper.database;

          // await database.rawQuery("select * from course");
          var batch = database.batch();

          batch.rawQuery('delete from course');
          batch.rawQuery('delete from subject');
          batch.rawQuery('delete from unit');
          batch.rawQuery('delete from chapter');
          batch.rawQuery('delete from topic');
          batch.rawQuery('delete from register');

          Map<String, dynamic> registerMap = jsonDecode(body['register']);
          Register register = Register();
          register.sno = body['studentSno'];
          // register.block = registerMap['block'];
          register.mobileno = registerMap['mobileno'];
          register.accountType = "1";
          register.courseId = body['courseSno'];
          register.firstMonday = registerMap['firstMonday'];
          register.joiningDate = registerMap['joiningDate'];

          // print(register.toJson());

          batch.insert('register', register.toJson());

          CourseDto courseDto = CourseDto();
          courseDto.sno = int.parse(body['courseSno']);
          courseDto.courseName = body['courseName'];

          batch.insert('course', courseDto.toJson());

          for (var a in body['courseContent']) {
            Subject subject = Subject();
            subject.sno = a['sno'];
            subject.subjectName = a['subjectName'];
            subject.courseSno = body['courseSno'];
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

          String registerSno = sp.getString("studentSno");

          await FirebaseFirestore.instance.collection("dimes").where('registerSno', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('dimes', f.data());
            }
          });
          print("dimes inserted");
          await FirebaseFirestore.instance.collection("dueTopicTests").where('registerSno', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('due_topic_tests', f.data());
            }
          });
          print("dueTopicTests inserted");
          await FirebaseFirestore.instance.collection("recentStudy").where('registrationSno', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('recent_study', f.data());
            }
          });
          print("recentStudy inserted");
          await FirebaseFirestore.instance.collection("study").where('register', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('study', f.data());
            }
          });
          print("study inserted");
          await FirebaseFirestore.instance.collection("topicTestResult").where('regSno', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('topic_test_result', f.data());
            }
          });
          print("topicTestResult inserted");

          await FirebaseFirestore.instance.collection("pace").where('register', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {

              batch.insert('pace', f.data());
            }
          });
          print("pace inserted");

          await FirebaseFirestore.instance.collection("dailyTaskCompletion").where('registerSno', isEqualTo: registerSno).get().then((QuerySnapshot snapshot) {
            for (var f in snapshot.docs) {
              batch.insert('daily_task_completion', f.data());
            }
          });
          print("dailyTaskCompletion inserted");

          await batch.commit(noResult: true);
          _signUpToast("Login Successful");

          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => const HomePage()), ModalRoute.withName('/'));
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => CourseGroup(mobile)), ModalRoute.withName('/'));
        }
      } else {
        _signUpToast("Invalid Otp");
      }
    } catch (e) {
      Navigator.of(context).pop();
      _signUpToast("Something went wrong. Please try after sometime");
      print(e);
    }
  }

  void _signUpToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black87, textColor: Colors.white, fontSize: 18.0);
  }

  _submitAlertBox(BuildContext context) {
    var alert = CustomAlert();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// ignore: must_be_immutable
class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  // Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, {Key key}) : super(key: key);

  String get timerString {
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return Text(
            timerString,
            style: TextStyle(
                fontSize: fontSize,
                // color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
