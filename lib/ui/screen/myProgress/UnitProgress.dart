import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lurnify/config/data.dart';
import 'package:lurnify/ui/constant/constant.dart';
import 'package:lurnify/ui/screen/myProgress/ChapterProgress.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lurnify/ui/constant/ApiConstant.dart';

class UnitProgress extends StatefulWidget {
  final sno;
  final String sname;
  UnitProgress(this.sno, this.sname);
  @override
  _UnitProgressState createState() => _UnitProgressState(sno, sname);
}

class _UnitProgressState extends State<UnitProgress> {
  final sno;
  final String sname;
  _UnitProgressState(this.sno, this.sname);
  List _myUnitProgress;

  Future _getMyUnitProgress() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String registrationSno = sp.getString("studentSno");
    var url = baseUrl +
        "getUnitProgressBySubject?registrationSno=" +
        registrationSno +
        "&subjectSno=" +
        sno.toString();
    print(url);
    http.Response response = await http.get(
      Uri.encodeFull(url),
    );
    var resbody = jsonDecode(response.body);
    print(resbody);
    _myUnitProgress = resbody;
    print(_myUnitProgress);
  }

  @override
  void initState() {
    _myUnitProgress = List();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMyUnitProgress(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: Container(
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(sname + ' Progress'),
                  centerTitle: true,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.yellow],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: ListView.builder(
                itemCount: _myUnitProgress.length,
                shrinkWrap: true,
                primary: false,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, i) {
                  double percent = _myUnitProgress[i]['userCompletedTopics'] /
                      _myUnitProgress[i]['totalTopics'];
                  double completedUnit = (_myUnitProgress[i]
                          ['userCompletedTopics'] /
                      _myUnitProgress[i]['totalTopics'] *
                      100);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
                    child: AspectRatio(
                      aspectRatio: 4 / 1,
                      child: InkWell(
                        onTap: () {
                          _getChapters(_myUnitProgress[i]['unitSno'],
                              _myUnitProgress[i]['unitName']);
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Image.asset(
                                    AppSlider.cardimage[0],
                                    fit: BoxFit.contain,
                                    height: 50,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _myUnitProgress[i]['unitName'],
                                    style: TextStyle(color: whiteColor),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CircularPercentIndicator(
                                    radius: 50,
                                    lineWidth: 5.0,
                                    animation: true,
                                    percent: percent > 1 ? 1 : percent,
                                    animateFromLastPercent: true,
                                    center: Text(
                                      completedUnit > 100
                                          ? 100.toString()
                                          : completedUnit.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: whiteColor,
                                      ),
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(30, 255, 255, 255),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              gradient: _randomGradient(i),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Gradient _randomGradient(int i) {
    if (i % 3 == 0) {
      return AppSlider.sliderGradient[0];
    } else if (i % 3 == 1) {
      return AppSlider.sliderGradient[2];
    } else if (i % 3 == 2) {
      return AppSlider.sliderGradient[1];
    }
    return AppSlider.sliderGradient[1];
  }

  _getChapters(sno, uname) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChapterProgress(sno, uname),
    ));
  }
}
