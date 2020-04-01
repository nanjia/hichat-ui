import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../init.dart';
import '../global.dart';
import '../utils.dart';
import 'homepage.dart';

class SignUpView extends StatefulWidget{

  @override
  _SignUpState createState()=>_SignUpState();
}

class _SignUpState extends State<SignUpView>{

  var _controller = new TextEditingController();
  File _image;
  String filestring;
    Future getImage() async {

    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    if(image!=null){
      var result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path, Globals.myAvatar,
          quality: 88,
          rotate: 0,
          minHeight: 100,
          minWidth: 100
        );
      String filestring = result.readAsBytesSync().toString();
      print(filestring);

      //HttpClientResponse response = await request.close();  
      setState(() {
        _image=result;
      });
    }
    
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
          return Scaffold(
      appBar: AppBar(
        title: Text("创建账号"),
        backgroundColor: Colors.red[500]
      ),
      body: Center(
        child:
          
        Container(
          child:Column(children: <Widget>[
            GestureDetector(child:Container(
          height: 52,
          width: 52,
          decoration: new BoxDecoration(
          image: DecorationImage(image: _image.existsSync()?FileImage(_image):AssetImage("images/avatar.jpg")),
          borderRadius: new BorderRadius.all(
            const Radius.circular(8.0),
            ), 
          ),
          margin: new EdgeInsets.all(4),),
          onTap: getImage,
            ),
          Row(children: <Widget>[Expanded(child:Container(),flex: 1,),Expanded(child:TextField(controller: _controller,decoration: InputDecoration(hintText:"用户名"),),flex: 2,),Expanded(child:Container(),flex: 1,)]),
          RaisedButton(
            color: Colors.red,
            disabledColor: Colors.red,
            textColor: Colors.white,
            disabledTextColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))
            ),
          child: Text("创建账号"),
          onPressed: ()async{
            print(_controller.text);
            if(_image==null){
              showDialog(
                context: context,
                builder: (BuildContext context)=>new SnackBar(
                content: new Text('请设置头像'),
                ),
              );
              return;
            }
            if(_controller.text == ''){
              showDialog(
                context: context,
                builder: (BuildContext context)=>new SnackBar(
                content: new Text('请输入用户名'),
                ),
              );
              return;
            }
            await handleCreateAccount(context, _controller.text,filestring);
            Globals.recentDialogues = await Globals.dialogueProvider.getRecentDialogues(); 
            Globals.contacts = await Globals.contactProvider.getContacts();
            Globals.socket.listen(handleMsg);
            accountCreated=true;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return HomePageView();
            },
            ),(Route<dynamic> route) => false);
            // setState((){
            //  _accountCreated = true; 
            // });
        },),
        ],))
        ),
      );
  }
}