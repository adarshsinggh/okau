import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static DBHelper _dbHelper;
  static Database _database;

  DBHelper._createInstance();

  factory DBHelper() {
    _dbHelper ??= DBHelper._createInstance();
    return _dbHelper;
  }

  Future<Database> get database async {
    _database ??= await initializeDB();
    return _database;
  }

  Future<Database> initializeDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'lurnify.db';
    //print(directory.path);
    var chatsDB = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
    );

    return chatsDB;
  }

  void _createDB(Database db, int newVersion) async {
    // await db.execute("drop table course_group");
    await db.execute("create table course_group(sno integer primary key autoincrement,"
        " courseName text,groupName text,courseSno text, `type` text, year text,startDate text,endDate text)");

    await db.execute('create table course(sno integer primary key autoincrement,courseName text)');

    await db.execute('create table subject(sno integer primary key autoincrement,subjectName text,courseSno text)');

    await db.execute('create table unit(sno integer primary key autoincrement,unitName text, subjectSno text)');

    await db.execute('create table chapter(sno integer primary key autoincrement,chapterName text,unitSno text)');

    await db.execute('create table topic(sno integer primary key autoincrement,topicName text, subTopic text, duration text, topicLabel text, topicImp text,chapterSno text)');

    // await db.execute('create table recent_study(sno integer primary key autoincrement,duration text,'
    //     'enteredBy text, enteredDate text, registration_sno text, study_type text, updatedBy text,'
    //     ' updatedDate text, chapter text, course text, subject text, topic text, unit text)');

    await db.execute('create table study(sno integer primary key autoincrement,chapterSno text,courseSno text,'
        'date text,duration text, effectivenessOfStudy text, endDate text, enteredDate text, numericalPercent text,'
        'revision text, startDate text, subjectSno text, theoryPercent text, timePunchedFrom text,'
        'topicCompletionStatus text, topicSno text, totalSecond text, totalTime text, unitSno text, updatedDate text, register text, status text )');

    await db.execute("create table reward(sno integer primary key autoincrement,appOpening text, dailyTask text,"
        "enteredBy text, enteredDate text, feeDeposite text, monthlyChallenge text, rankboosterTestAttempt text,"
        "rankboosterTestScore text, rankboosterTestScore1 text, rankboosterTestScore2 text,rankboosterTestScore3 text,"
        "refer text, studyTime text, testAttempt text, testScore text, testScore1 text, testScore2 text, testScore3 text,"
        "updatedBy text, updatedDate text, weeklyChallengeAccept text)");

    await db.execute("create table dimes(sno integer primary key autoincrement,credit text, debit text,"
        "message text, enteredBy text, enteredDate text,updatedBy text, updatedDate text, registerSno text, status text)");

    await db.execute("create table recent_study(sno integer primary key autoincrement,duration text,"
        "enteredBy text, enteredDate text, registrationSno text, studyType text, updatedBy text, updatedDate text,"
        "chapter text, course text, subject text, topic text, unit text, status text)");

    await db.execute("create table due_topic_tests(sno integer primary key autoincrement,enteredDate text,"
        " status text, registerSno text, topicSno text,course text,subject text, unit text, chapter text, onlineStatus text)");

    await db.execute("create table remark(sno integer primary key autoincrement,"
        "enteredBy text, enteredDate text, message text, studentSno text,"
        " subject text, topicSno text, updatedBy text, updatedDate text)");

    await db.execute("create table pace(sno integer primary key autoincrement,"
        "courseSno text, enteredDate text, expectedRank text, perDayStudyHour text,"
        "syllabusCompletionDate text, updatedDate text, studentSno text,"
        " timePercent text,percentDifference text, register text)");

    await db.execute("create table topic_test_result(sno integer primary key autoincrement, answerMap text,"
        "correctQuestion text, enteredBy text, enteredDate text, resultNumber text, testPercent text,"
        "totalQuestion text, wrongQuestion   text, regSno text, topicSno text, totalTestTime text,course text, subject text,"
        " unit text, chapter text, status text, questionTiming text)");

    await db.execute("create table test_main(sno integer primary key autoincrement,"
        "enteredBy text,enteredDate text, testName text, topicSet integer, updatedBy text, updatedDate text,"
        "chapter text, course text, instruction text, subject text, topic text, unit text, topicType text,topicTestTime text)");

    await db.execute("create table test(sno integer primary key autoincrement,"
        "answer text, difficulty text, directory text, enteredBy text, enteredDate text, fileName text,"
        "filePath text, noOfOptions text, questionType text, solutionDirectory text, solutionFileName text, "
        "solutionFilePath text, updatedBy text, updatedDate text, uuid text, testMain text, encodedImage text,encodedSolution text)");

    await db.execute("create table instruction(sno integer primary key autoincrement,"
        "enteredBy text, enteredDate text, instructionPageName text, updatedBy text, updatedDate text)");

    await db.execute("create table instruction_data(sno integer primary key autoincrement,"
        "enteredBy text, enteredDate text, instructions text, updatedBy text, updatedDate text, instructionSno text)");

    await db.execute("create table register(sno integer primary key autoincrement, profilePicturePath text,"
        "block text, mobileno text, accountType text, courseId text, firstMonday text, joiningDate text, enteredDate text,name text,email text,"
        "dob text,fatherName text,currentClass text, target text, schoolName text, marks10 text, marks12 text, address text)");

    // await db.execute("create table challenge_accept(sno integer primary key autoincrement, enteredBy text, enteredDate text,"
    //     "status text, week integer, registerSno text)");

    await db.execute("create table weekly_task(sno integer primary key autoincrement, coins text, enteredBy text,"
        "enteredDate text, minimumStudyDays text, totalNumberOfTest text, totalStudyHour text, updatedBy text,"
        "updatedDate text, week text)");

    await db.execute("create table daily_task_completion(sno integer primary key autoincrement, enteredBy text, enteredDate text,"
        "spinDate text, status text, updatedBy text, updatedDate text, registerSno text, dailyTaskSno text, onlineStatus text)");

    await db.execute("create table daily_task(sno integer primary key autoincrement, enteredBy text, enteredDate text,"
        " taskName text, endDateTime text, startDateTime text, status text)");

    await db.execute("create table daily_task_data(sno integer primary key autoincrement, cash text, certificate text, coins text, enteredBy text,"
        "enteredDate text, noOfReferralCoupons text, taskType text, dailyTaskSno text, taskUnit text)");

    await db.execute("create table data_update(sno integer primary key autoincrement,reward text, weeklyTask text,"
        "dailyTaskCompletion text,dailyAppOpening text, dailyTask text, dailyTaskData text, beatDistraction text, timerPage text,challengeAccept text,dataSynced text)");

    await db.execute("create table beat_distraction(sno integer primary key autoincrement,message text)");

    await db.execute("create table daily_app_opening(sno integer primary key autoincrement,appOpeningDate text, enteredDate text, registerSno text)");

    await db.execute("create table timer_page_message(sno integer primary key autoincrement,message text)");

    await db.execute("create table challenge_accept(sno integer primary key autoincrement,enteredBy text, enteredDate text, status text,"
        "updatedBy text, updatedDate text, week text, registerSno text)");

    // new tables to be synced

    await db.execute('create table completed_chapters(sno integer primary key autoincrement,chapter text,unit text,subject text, register text, enteredDate text)');

    await db.execute('create table completed_units(sno integer primary key autoincrement,chapter text,unit text,subject text, register text, enteredDate text)');

    await db.execute('create table completed_subjects(sno integer primary key autoincrement,chapter text,unit text,subject text, register text, enteredDate text)');

    print("ALL TABLES CREATED");
  }

  void deleteDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'lurnify.db';
    //print('Datebase deleted');
    await deleteDatabase(path);
  }

  // Future<int> insertCourseGroup(CourseGroup model) async {
  //   Database db = await this.database;
  //
  //   var result = db.insert("chat", model.toJson());
  //   return result;
  // }

  Future<List<Map<String, dynamic>>> getChats() async {
    Database db = await database;
    var result = db.rawQuery("select * ,(select count(sno) from chat where roomId=c.roomId and status='delivered') as unreadChats"
        " from chat as c group by roomId order by messageTime desc");
    return result;
  }

  Future<int> updateChatRoomIdStatus(roomId) async {
    Database db = await database;

    var result = db.rawUpdate("update chat set status='read' where roomId=" + roomId + "");
    return result;
  }

  insertCourseGroupBatch(list) async {
    var res;
    try {
      Database db = await database;
      await db.execute('delete from course_group');
      var batch = db.batch();
      for (var i in list) {
        batch.insert("course_group", i);
      }
      res = batch.commit();
    } catch (e) {
      //print('insertCourseGroupBatch : ' + e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getCourseBatch() async {
    Database db = await database;
    var result = db.rawQuery('select * from course_group');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCourseType() async {
    Database db = await database;
    List<Map<String, dynamic>> allValue = [];
    var result = db.rawQuery('select distinct(type) as t from course_group group by type');
    var b = await result;
    for (var a in b) {
      //print(a['t']);
      var res2 = db.rawQuery("select * from course_group where type='${a['t']}' group by year");
      var c = await res2;
      Map<String, dynamic> value = {'type': a['t'], 'detail': c};
      allValue.add(value);
    }
    //print(allValue);
    return allValue;
  }

  Future<List<Map<String, dynamic>>> getCourse(String type, String year) async {
    Database db = await database;
    String sql = "select * from course_group where type='$type' and year='$year'";
    //print(sql);
    var result = db.rawQuery(sql);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTimerPageMessage(String topicSno) async {
    Database db = await database;
    String sql = "select sum(totalSecond) as totalSecond from study where topicSno='$topicSno'";
    //print(sql);
    var result = db.rawQuery(sql);
    return result;
  }

  Future<List<Map<String, dynamic>>> totalSecondByDate(String date) async {
    try {
      Database db = await database;
      String sql = "select sum(totalSecond) as totalSecond from study where date='$date'";
      //print(sql);
      var result = db.rawQuery(sql);
      return result;
    } catch (e) {
      //print("totalSecondByDate" + e.toString());
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNextTopic(String chapterSno, String topicSno) async {
    try {
      Database db = await database;
      String sql = "select * from topic where chapterSno=$chapterSno and sno>$topicSno";
      //print(sql);
      var result = db.rawQuery(sql);
      return result;
    } catch (e) {
      //print("totalSecondByDate" + e.toString());
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTotalTopicDurationByCourse(String courseSno) async {
    try {
      Database db = await database;
      String sql = "select sum(topic.duration) as totalDuration from topic  "
          "INNER JOIN chapter on chapter.sno=topic.chapterSno "
          "INNER JOIN unit on unit.sno=chapter.unitSno  "
          "INNER JOIN `subject` on `subject`.sno=unit.subjectSno "
          "INNER JOIN course on course.sno=subject.courseSno  "
          "where course.sno='$courseSno'";
      // print(sql);
      var result = db.rawQuery(sql);
      return result;
    } catch (e) {
      //print("totalSecondByDate" + e.toString());
      return [];
    }
  }
}
