import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lurnify/helper/db_helper.dart';
import 'package:lurnify/model/register.dart';
import 'package:lurnify/ui/constant/ApiConstant.dart';
import 'package:lurnify/ui/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class UserProfileEdit extends StatefulWidget {
  @override
  _UserProfileEditState createState() => _UserProfileEditState();
}

class _UserProfileEditState extends State<UserProfileEdit> {
  final Color _color2 = const Color(0xff777777);

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _fatherName = TextEditingController();
  final TextEditingController _currentClass = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _schoolName = TextEditingController();
  final TextEditingController _marks10 = TextEditingController();
  final TextEditingController _marks12 = TextEditingController();
  final TextEditingController _address = TextEditingController();

  File _selectedImage;
  final picker = ImagePicker();
  DBHelper dbHelper = DBHelper();
  var data;
  String _profilePicturePath="";


  _getData()async{
    Database database=await dbHelper.database;
    String sql="select * from register order by sno desc limit 1";
    List<Map<String,dynamic>> register=await database.rawQuery(sql);
    for(var a in register){
      _name.text=a['name'];
      _phone.text=a['mobileno'];
      _email.text=a['email'];
      _dob.text=a['dob'];
      _fatherName.text=a['fatherName'];
      _currentClass.text=a['currentClass'];
      _target.text=a['target'];
      _schoolName.text=a['schoolName'];
      _marks10.text=a['marks10'];
      _marks12.text=a['marks12'];
      _address.text=a['address'];
      _profilePicturePath=a['profilePicturePath'];
    }
  }

  @override
  void initState() {
    // _registerRef = FirebaseFirestore.instance.collection('register');
    data=_getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:data,
      builder: (context, snapshot) {
        return Material(
          color: Colors.transparent,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            height: MediaQuery.of(context).size.height * 8 / 10,
            child: Card(
              margin: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PreferredSize(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(top: 5, right: 10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                                child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                              ),
                            ),
                          ],
                        ),
                        preferredSize: const Size.fromHeight(50)),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _createProfilePicture(),
                         if(_selectedImage!=null) Align(
                              alignment: Alignment.center,
                              child: CupertinoButton(child:const Text('Upload',style: TextStyle(color: Colors.purple),), onPressed: (){
                                _uploadProfileImage();
                              })),
                          const SizedBox(height: 40),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _profileFiledRow('Name', _name),
                                  _profileFiledRow('Phone Number', _phone),
                                  _profileFiledRow('Email', _email),
                                  _profileFiledRow('Date of Birth', _dob),
                                  _profileFiledRow('Father Name', _fatherName),
                                  _profileFiledRow('Current Class', _currentClass),
                                  _profileFiledRow('Target', _target),
                                  _profileFiledRow('School Name', _schoolName),
                                  _profileFiledRow('Marks in 10th', _marks10),
                                  _profileFiledRow('Marks in 12th', _marks12),
                                  _profileFiledRow('Address', _address),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        save();
                                      },
                                      child: const Text(
                                        "Save",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _profileFiledRow(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: _color2, fontWeight: FontWeight.normal),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
      ],
    );
  }

  save()async {
    if (_name.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter name');
    } else if (_phone.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter phone number');
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String studentSno=sp.getString("studentSno");
      Register register =  Register();
      register.sno=int.parse(studentSno);
      register.name=_name.text;
      register.mobileno=_phone.text;
      register.email=_email.text;
      register.dob=_dob.text;
      register.fatherName=_fatherName.text;
      register.currentClass=_currentClass.text;
      register.target=_target.text;
      register.schoolName=_schoolName.text;
      register.marks10=_marks10.text;
      register.marks12=_marks12.text;
      register.address=_address.text;
      register.accountType="1";
      register.firstMonday=sp.getString('firstMonday').split(' ')[0];
      register.joiningDate=sp.getString('joiningDate').split(' ')[0];
      String url=baseUrl+'updateRegistration';
      http.Response response = await http.post(
          Uri.parse(url),
          body: jsonEncode(register.toJson()),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          }
      );

      Map<String,dynamic> map = jsonDecode(response.body);
      if(map['result']==true){
        register.sno=null;
        Database database=await dbHelper.database;
        await database.insert('register',register.toJson());
        Fluttertoast.showToast(msg: 'Updated');
        Navigator.of(context).pop();
      }else{
        Fluttertoast.showToast(msg: 'Failed');
      }

    }
  }

  Widget _createProfilePicture() {
    final double profilePictureSize =
        MediaQuery.of(context).size.width * 4 / 10;
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        width: profilePictureSize,
        height: profilePictureSize,
        child: GestureDetector(
          onTap: () {
            _showPopupUpdatePicture();
          },
          child: Stack(
            children: [
              Container(
                child: GestureDetector(
                  onTap: () {
                    _showPopupUpdatePicture();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: (profilePictureSize),
                    child: Hero(
                      tag: 'profilePicture',
                      child: ClipOval(
                        child: SizedBox(
                          width: profilePictureSize,
                          height: profilePictureSize,
                          child:  _selectedImage==null
                                    ? _profilePicturePath=="" || _profilePicturePath ==null
                                      ? Image.asset('assets/profile-pic.png')
                                        : Image.asset(_profilePicturePath,fit: BoxFit.fill,)
                                          :Image.file(_selectedImage,fit: BoxFit.fill,),
                        ),
                      ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepPurple,
                    width: 3.0,
                  ),
                ),
              ),
              // create edit icon in the picture
              Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(
                    top: 0, left: MediaQuery.of(context).size.width / 4),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                  child: const Icon(
                    Icons.edit,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPopupUpdatePicture() {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No', style: TextStyle(color: firstColor)));
    Widget continueButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: 'Click edit profile picture',
              toastLength: Toast.LENGTH_SHORT);
        },
        child: Text('Yes', style: TextStyle(color: firstColor)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Edit Profile Picture',
        style: TextStyle(fontSize: 18),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(onPressed: (){
            _chooseImage(ImageSource.camera);
          }, icon: const Icon(Icons.camera_alt,size: 40,)),
          IconButton(onPressed: (){
            _chooseImage(ImageSource.gallery);
          }, icon: const Icon(Icons.photo,size: 40,))
        ],
      ),

    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _chooseImage(source) async {
    Navigator.of(context).pop();
    var pickedFile = await picker.getImage(
      source: source,
      imageQuality: 50
    );
    setState(() {
      _selectedImage=File(pickedFile.path);
    });

    if (pickedFile.path == null) _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {});
    } else {
      print(response.file);
    }
  }

  _uploadProfileImage()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    var postUri = Uri.parse(baseUrl+'uploadProfilePicture');

    http.MultipartRequest request =  http.MultipartRequest("POST", postUri);

    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'file', _selectedImage.path);

    request.files.add(multipartFile);
    request.fields['register']=sp.getString('studentSno');

    http.StreamedResponse response = await request.send();

    if(response.statusCode>=200 || response.statusCode>300){
      Map<String,dynamic> map = jsonDecode(await response.stream.bytesToString());
      if(map['result']==true){
        // Navigator.of(context).pop();
        _saveFile();
        Fluttertoast.showToast(msg: "Picture Uploaded");
      }else{
        Fluttertoast.showToast(msg: "Picture Upload Failed");
      }
    }

  }

  void _saveFile() async {
    File file = File(await _getFilePath()); // 1
    file.writeAsBytes(_selectedImage.readAsBytesSync());
  }


  Future<String> _getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    var fileName = (_selectedImage.path.split('/').last);
    String filePath = '$appDocumentsPath/$fileName'; // 3
    DBHelper dbHelper = DBHelper();
    Database database = await dbHelper.database;
    print(filePath);
    String sql="update register set profilePicturePath='$filePath'";
    await database.rawQuery(sql);
    return filePath;
  }

// Future _uploadFile() async {
//   if (_savePressed) {
//   } else if (_selectedImage == null) {
//     Fluttertoast.showToast(msg: "Please select Image");
//   } else {
//     setState(() {
//       _savePressed = true;
//     });
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String register = sp.getString('studentSno');
//     ref = firebase_storage.FirebaseStorage.instance.ref().child('images/${Path.basename(_selectedImage.path)}');
//     await ref.putFile(_selectedImage).whenComplete(() async {
//       await ref.getDownloadURL().then((value) {
//         _registerRef.add({'url': value, 'register': register}).whenComplete(() {
//           Fluttertoast.showToast(msg: "Saved");
//           setState(() {
//             _savePressed = false;
//           });
//         });
//       });
//     });
//   }
// }
}
