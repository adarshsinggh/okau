import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:lurnify/config/data.dart';
import 'package:lurnify/helper/db_helper.dart';
import 'package:lurnify/widgets/componants/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SpinnerClass extends StatefulWidget {
  final _spinData;
  SpinnerClass(this._spinData);
  @override
  _SpinnerClassState createState() => _SpinnerClassState(_spinData);
}

class _SpinnerClassState extends State<SpinnerClass> {
  final _spinData;
  _SpinnerClassState(this._spinData);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.4,
                child: FortuneWheel(
                  indicators: [
                    FortuneIndicator(
                        child: Image.asset(
                          'assets/icons/spineer.png',
                          fit: BoxFit.contain,
                          height: 60,
                        ),
                        alignment: Alignment.center)
                  ],
                  physics: CircularPanPhysics(
                    duration:const Duration(seconds: 1),
                    curve: Curves.decelerate,
                  ),
                  duration:const Duration(seconds: 10),
                  animateFirst: false,
                  selected: _selected,
                  onAnimationEnd: () {
                    _updateDailyTask();
                  },
                  items: List.generate(
                    _spinData.length,
                        (index) {
                      return FortuneItem(
                          style: FortuneItemStyle(
                              color: AppColors.tileIconColors[index],
                              textStyle:const TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center),
                          child: Text(_spinData[index]['taskName']));
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding:const EdgeInsets.fromLTRB(20, 20, 20, 5),
                height: MediaQuery.of(context).size.height * 0.15,
                child: Center(
                  child: CustomButton(
                    verpad:const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 40,
                    ),
                    brdRds: 30,
                    btnClr: Colors.green,
                    buttonText: 'SPIN',
                    onPressed: () {
                      try {
                        var _random =  Random();
                        setState(() {
                          _selected = _random.nextInt(6);
                          if(_selected==0){
                            _selected = _random.nextInt(6);
                            if(_selected==0){
                              _selected = _random.nextInt(6);
                              if(_selected==0){
                                _selected = _random.nextInt(6);
                              }
                            }
                          }
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
// FortuneWheel(
//   indicators: [
//     FortuneIndicator(
//         child: Image.asset(
//           'assets/icons/spineer.png',
//           fit: BoxFit.contain,
//           height: 60,
//         ),
//         alignment: Alignment.center)
//   ],
//   physics: CircularPanPhysics(
//     duration: Duration(seconds: 1),
//     curve: Curves.decelerate,
//   ),
//   duration: Duration(seconds: 10),
//   animateFirst: false,
//   selected: _selected,
//   onAnimationEnd: () {
//     _updateDailyTask();
//   },
//   items: List.generate(
//     _spinData.length,
//     (index) {
//       return FortuneItem(
//           style: FortuneItemStyle(
//               color: AppColors.tileIconColors[index],
//               textStyle: TextStyle(
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center),
//           child: Text(_spinData[index]['taskName']));
//     },
//   ),
// ),

  _updateDailyTask() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      // var url = baseUrl +
      //     "storeSpinData?registerSno=" +
      //     sp.getString("studentSno") +
      //     "&dailyTaskSno=" +
      //     _spinData[_selected - 1]['sno'].toString();
      // print(url);
      // http.Response response = await http.post(
      //   Uri.encodeFull(url),
      // );
      DBHelper dbHelper =  DBHelper();
      Database database = await dbHelper.database;
      String sql = "select sno from daily_task_completion "
          "where registerSno='${sp.getString("studentSno")}' and spinDate='${DateTime.now().toString().split(" ")[0]}' ";
      print(sql);
      List<Map<String, dynamic>> list = await database.rawQuery(sql);
      print("-----------------------------------$list");
      if (list.isEmpty) {
        String sql2 = "insert into daily_task_completion (registerSno,dailyTaskSno,spinDate,status,enteredDate,onlineStatus) "
            "values('${sp.getString("studentSno")}','${_spinData[_selected - 1]['sno'].toString()}',"
            "'${DateTime.now().toString().split(" ")[0]}',"
            "'spined','${DateTime.now().toString()}','new')";
        print(sql2);
        int x = await database.rawInsert(sql2);
        print(x);
      } else {
        String sql2 =
            "update daily_task_completion set dailyTaskSno='${_spinData[_selected - 1]['sno'].toString()}', status='spined', onlineStatus='new' where registerSno='${sp.getString("studentSno")}' "
            "and spinDate='${DateTime.now().toString().split(" ")[0]}'";
        print(sql2);
        await database.rawUpdate(sql2);
      }

      // String s="select * from daily_task_completion";
      // var a = await database.rawQuery(s);
      // print(a);

      _showSpinTask();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showSpinTask() async {
    String result = "";
    List<Map<String, dynamic>> data = _spinData[_selected - 1]['dailyTaskDatas'];
    for (int i = 0; i < data.length; i++) {
      result = result +
          "Your task type is" +
          data[i]['taskType'] +
          " and you have to complete " +
          data[i]['taskUnit'].toString() +
          "test or study minute\nAnd you will be rewarded with " +
          data[i]['coins'].toString() +
          " Coins or " +
          data[i]['cash'].toString() +
          " cash or " +
          data[i]['certificate'].toString() +
          " certificates or " +
          data[i]['noOfReferralCoupons'].toString() +
          " refferals coupons\n";
    }
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Congratulations',
      desc: result,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      btnOkColor: Colors.black87,
      btnOkText: "Great",
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },
    )..show();
  }
}
