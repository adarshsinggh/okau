/*
This is splash screen page
Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lurnify/ui/constant/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Timer _timer;
  int _second = 5; // set timer for 3 second and then direct to next page
  SharedPreferences sp;
  void _startTimer() {
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      setState(() {
        _second--;
      });
      if (_second == 0) {
        _cancelFlashsaleTimer();
        if (sp.getBool("onboarding") != null) {
          if (sp.getString("studentSno") == null) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Log_in, (route) => false);
          } else {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(home_page, (route) => false);
          }
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(on_boarding, (route) => false);
        }
      }
    });
  }

  void _cancelFlashsaleTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  void initState() {
    // set status bar color to transparent and navigation bottom color to black21
    _initializeSP();
    if (_second != 0) {
      _startTimer();
    }
    super.initState();
  }

  _initializeSP() async {
    sp = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _cancelFlashsaleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent),
      child: WillPopScope(
        onWillPop: () {
          return null;
        },
        child: Container(
          child: Center(
            child: Lottie.asset('assets/lottie/58305-guestlist.json'),
          ),
        ),
      ),
    ));
  }
}
