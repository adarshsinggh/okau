import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lurnify/ui/screen/selfstudy/select_pace.dart';
import 'package:lurnify/ui/screen/userProfile/update_profile.dart';
import 'package:lurnify/ui/screen/userProfile/user_profile_edit.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../helper/db_helper.dart';
import '../../constant/constant.dart';
import '../../constant/routes.dart';
import '../../../widgets/componants/custom_button.dart';
import '../myProgress/subject_unit.dart';
import '../socialGroup/social_group.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserProfile extends StatefulWidget {
  const UserProfile({Key key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _completedTopics = "0";
  String _completedChapters = "0";
  String _completedUnits = "0";
  double _perDatStudyHour = 0;
  List<Map<String, dynamic>> _streaks = [];
  String _profilePicturePath="";
  var data;

  _getData() async {
    DBHelper dbHelper =  DBHelper();
    Database db = await dbHelper.database;
    db.transaction((txn) async {
      String sql = "select count(sno) as completedUnits from completed_units";
      List<Map<String, dynamic>> list = await txn.rawQuery(sql);

      String sql2 = "select count(sno) as completedChapters from completed_chapters";
      List<Map<String, dynamic>> list2 = await txn.rawQuery(sql2);

      String sql3 = "select count(sno) as completedTopics from study"
          " where topicCompletionStatus='Complete' "
          "and revision='0' "
          "group by topicSno";
      List<Map<String, dynamic>> list3 = await txn.rawQuery(sql3);

      String perDayStudyHour = "0";
      String sql4 = "select perDayStudyHour from pace";
      List<Map<String, dynamic>> list4 = await txn.rawQuery(sql4);
      for (var a in list4) {
        perDayStudyHour = a['perDayStudyHour'];
      }
      _perDatStudyHour = double.tryParse(perDayStudyHour);

      String a ="select * from study";
      List<Map<String,dynamic>> map=await txn.rawQuery(a);


      // String sql5 = "SELECT sum(totalSecond)/3600 as totalSecond FROM study WHERE"
      //     " study.`date` > (SELECT DATETIME('now', '-7 day') group by study.`date`)";
      // _streaks = await txn.rawQuery(sql5);

      String sql6="select profilePicturePath from register order by sno desc limit 1";

      List<Map<String,dynamic>> registers=await txn.rawQuery(sql6);
      for(var a in registers){
        _profilePicturePath=a['profilePicturePath'];
      }
      print("----------------------------------------");
      print(_profilePicturePath);

      for (var a in list) {
        _completedUnits = a['completedUnits'].toString();
      }

      for (var a in list2) {
        _completedChapters = a['completedChapters'].toString();
      }

      for (var a in list3) {
        _completedTopics = a['completedTopics'].toString();
      }

      return null;
    });
  }

  @override
  void initState() {
    data=_getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'User Profile',
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const Text(
                          "Aman Sharma",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          'Joined June 2021',
                          style: TextStyle(color: firstColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AspectRatio(
                      aspectRatio: 4 / 2,
                      child: Stack(
                        children: [
                           Align(
                            alignment: Alignment.center,
                            child: _ProgressBar(
                              progressValue: 40,
                              task: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.15,
                                  decoration:const BoxDecoration(
                                      shape: BoxShape.circle,
                                  ),
                                  child:_profilePicturePath==null? Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    decoration:const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: AssetImage('assets/profile-pic.png'))
                                    ),
                                  ): Image.asset('/data/user/0/com.mahaadev.lurnify/app_flutter/scaled_59533d3a-ffb0-4299-a366-e68027cb58e17286218254647134705.jpg',errorBuilder: (context, error, stackTrace) {
                                    return  Container(
                                      height: MediaQuery.of(context).size.height*0.15,
                                        decoration:const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: AssetImage('assets/profile-pic.png'))
                                        ),
                                        );
                                  },),
                                  // foregroundImage: AssetImage(_profilePicturePath),
                                  // onForegroundImageError: (exception, stackTrace) {
                                  //   Image.asset('assets/profile-pic.png');
                                  // },
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(height: 50, width: 50, child: Image.asset('assets/award.png')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SocialGroup(),
                        ));
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        padding:const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        width: MediaQuery.of(context).size.width * 4 / 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 0.0),
                              child: Container(
                                child:const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/images/anshul.png')),
                                decoration:  BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:  Border.all(
                                    color: Colors.deepPurple,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 0.15),
                                child: Container(
                                  child:const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/images/anshul.png')),
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:  Border.all(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 0.3),
                                child: Container(
                                  child:const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/images/anshul.png')),
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:  Border.all(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 0.45),
                                child: Container(
                                  child:const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/images/anshul.png')),
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:  Border.all(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 0.60),
                                child: Container(
                                  child: CircleAvatar(
                                    foregroundColor: whiteColor,
                                    backgroundColor: firstColor,
                                    radius: 15,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children:const [
                                        Text(
                                          '20',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Icon(
                                          Icons.add,
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:  Border.all(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                )),
                            Align(
                              alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, 1.0),
                              child:const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            )
                          ],
                        ),
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:  Border.all(width: 0.5, color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Divider(
                          height: 10,
                          thickness: 0.5,
                        ),
                        const Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Progress Summary',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>const MyProgress(),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _completedUnits,
                                        style:const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600, fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const  Text(
                                        'Unit Completed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _completedChapters,
                                        style:const TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.w600, fontSize: 18),
                                      ),
                                      const  SizedBox(
                                        height: 10,
                                      ),
                                      const  Text(
                                        'Chapter Completed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _completedTopics,
                                        style: TextStyle(color: Colors.deepPurple[300], fontWeight: FontWeight.w600, fontSize: 18),
                                      ),
                                      const  SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Topic Completed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          height: 20,
                          thickness: 0.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:const [
                                    Text(
                                      '2 Days',
                                      style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.w600, fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Streak',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: _customCircularIndicator(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                        ),
                        InkWell(
                          onTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (builder) {
                                  return UserProfileEdit();
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const[
                                Text('Edit Profile'),
                                Icon(Icons.edit),
                              ],
                            ),
                          ),
                        ),
                        const  Divider(
                          height: 1,
                          thickness: 0.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: CustomButton(
        buttonText: 'Update Study Pace',
        brdRds: 0,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectThePace(true),));
        },
      ),
    );
  }

  Widget _customCircularIndicator() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, i) {
          double percent = 0;
          if (_streaks.asMap().containsKey(i)) {
            percent = _streaks[i]['totalSecond'] / _perDatStudyHour;
          }
          return Padding(
            padding: const EdgeInsets.only(left: 5),
            child: CircularPercentIndicator(
              radius: 30,
              lineWidth: 3.0,
              animation: true,
              percent: percent,
              backgroundColor: Color.fromARGB(30, 128, 112, 254),
              circularStrokeCap: CircularStrokeCap.round,
              linearGradient: LinearGradient(
                colors: <Color>[Colors.deepPurpleAccent, Colors.deepPurple],
                stops: <double>[0.25, 0.75],
              ),
            ),
          );
        },
      ),
    );
  }
}



class _ProgressBar extends StatelessWidget {
  const _ProgressBar({Key key, @required this.progressValue, @required this.task}) : super(key: key);

  final double progressValue;
  final Widget task;

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              positionFactor: 0.1,
              angle: 90,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  task,
                ],
              ))
        ],
        minimum: 0,
        maximum: 100,
        showLabels: false,
        showTicks: false,
        axisLineStyle: AxisLineStyle(
          thickness: 0.1,
          cornerStyle: CornerStyle.bothCurve,
          color: Color.fromARGB(30, 128, 112, 254),
          thicknessUnit: GaugeSizeUnit.factor,
        ),
        pointers: <GaugePointer>[
          RangePointer(
              value: progressValue.isNaN ? 0 : progressValue,
              width: 0.1,
              sizeUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.startCurve,
              gradient: const SweepGradient(colors: <Color>[Colors.lightGreen, Colors.green], stops: <double>[0.25, 0.75])),
          MarkerPointer(
            markerHeight: 9,
            markerWidth: 9,
            value: progressValue.isNaN ? 0 : progressValue,
            markerType: MarkerType.circle,
            color: Colors.green,
          )
        ],
      )
    ]);
  }
}
