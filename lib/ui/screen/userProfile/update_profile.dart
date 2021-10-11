// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:lurnify/ui/constant/constant.dart';
//
// class UserProfileEdit extends StatefulWidget {
//   @override
//   _UserProfileEditState createState() => _UserProfileEditState();
// }
//
// class _UserProfileEditState extends State<UserProfileEdit> {
//   // Color _color1 = firstColor;
//   final Color _color2 = const Color(0xff777777);
//   // Color _color3 = Color(0xFF515151);
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         clipBehavior: Clip.hardEdge,
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//         ),
//         height: MediaQuery.of(context).size.height * 8 / 10,
//         child: Card(
//           margin: const  EdgeInsets.all(0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 PreferredSize(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           margin:  const EdgeInsets.only(top: 5, right: 10),
//                           child: Card(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             elevation: 2,
//                             child: IconButton(
//                                 icon: const  Icon(
//                                   Icons.close,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 }),
//                           ),
//                         ),
//                       ],
//                     ),
//                     preferredSize: const  Size.fromHeight(50)),
//                 Container(
//                   margin: const  EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _createProfilePicture(),
//                       const  SizedBox(height: 40),
//                       Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _ProfileInfo(
//                                 color2: _color2,
//                                 label: 'Name',
//                                 info: 'Anil Kumar Jangid',
//                                 onTap: () {
//                                   Fluttertoast.showToast(
//                                       msg: 'Click edit name',
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 },
//                               ),
//                               const  SizedBox(
//                                 height: 24,
//                               ),
//                               _ProfileInfo(
//                                 color2: _color2,
//                                 label: 'Email',
//                                 info: 'aeny.dev@gmail.com',
//                                 onTap: () {
//                                   Fluttertoast.showToast(
//                                       msg: 'Click edit email',
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 },
//                               ),
//                               const  SizedBox(
//                                 height: 24,
//                               ),
//                               _ProfileInfo(
//                                 color2: _color2,
//                                 label: 'Date of Birth',
//                                 info: '22/08/1996',
//                                 onTap: () {
//                                   Fluttertoast.showToast(
//                                       msg: 'Click edit DOB',
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 },
//                               ),
//                               const  SizedBox(
//                                 height: 24,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _createProfilePicture() {
//     final double profilePictureSize =
//         MediaQuery.of(context).size.width * 4 / 10;
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         margin: const  EdgeInsets.only(top: 40),
//         width: profilePictureSize,
//         height: profilePictureSize,
//         child: GestureDetector(
//           onTap: () {
//             _showPopupUpdatePicture();
//           },
//           child: Stack(
//             children: [
//               Container(
//                 child: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   radius: (profilePictureSize),
//                   child: Hero(
//                     tag: 'profilePicture',
//                     child: ClipOval(
//                       child: SizedBox(
//                         width: profilePictureSize,
//                         height: profilePictureSize,
//                         child: Image.asset('assets/images/anshul.png'),
//                       ),
//                     ),
//                   ),
//                 ),
//                 decoration:   BoxDecoration(
//                   shape: BoxShape.circle,
//                   border:  Border.all(
//                     color: Colors.deepPurple,
//                     width: 3.0,
//                   ),
//                 ),
//               ),
//               // create edit icon in the picture
//               Container(
//                 width: 30,
//                 height: 30,
//                 margin: EdgeInsets.only(
//                     top: 0, left: MediaQuery.of(context).size.width / 4),
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 2,
//                   child: const  Icon(
//                     Icons.edit,
//                     size: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showPopupUpdatePicture() {
//     // set up the buttons
//     Widget cancelButton = TextButton(
//         onPressed: () {
//           Navigator.pop(context);
//         },
//         child: Text('No', style: TextStyle(color: firstColor)));
//     Widget continueButton = TextButton(
//         onPressed: () {
//           Navigator.pop(context);
//           Fluttertoast.showToast(
//               msg: 'Click edit profile picture',
//               toastLength: Toast.LENGTH_SHORT);
//         },
//         child: Text('Yes', style: TextStyle(color: firstColor)));
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       title: const  Text(
//         'Edit Profile Picture',
//         style: TextStyle(fontSize: 18),
//       ),
//       content: Text('Do you want to edit profile picture ?',
//           style: TextStyle(fontSize: 13, color: _color2)),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }
//
// class _ProfileInfo extends StatelessWidget {
//   const _ProfileInfo(
//       {Key key, @required Color color2, this.info, this.label, this.onTap})
//       : _color2 = color2,
//         super(key: key);
//
//   final Color _color2;
//   final String label;
//   final String info;
//   final Function onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//               fontSize: 12, color: _color2, fontWeight: FontWeight.normal),
//         ),
//         const  SizedBox(
//           height: 8,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 info,
//                 style: const  TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             GestureDetector(
//                 onTap: onTap,
//                 child: const  Icon(
//                   Icons.edit,
//                   size: 15,
//                 ))
//           ],
//         ),
//       ],
//     );
//   }
// }
