import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hichat/views/base.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../global.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MyView extends StatefulWidget{
  MyView({Key key, this.title}) : super(key: key);
  
  final String title;

   @override
  _MyViewState createState()=>_MyViewState();
}

class _MyViewState extends State<MyView> {


  @override
  void initState(){
    super.initState();
    //FileImage(File(Globals.myAvatar)).evict();
    _image = File(Globals.myAvatar);
  }
  File _image;

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
      String jsonEncoded = json.encode({"uid":Globals.myInfo.userid,"avatar":filestring});
      print(filestring);
      Globals.client.postUrl(Uri.parse("http://144.202.96.35:8080/avatar/push")).then((request){
        request.headers.add("contentType", ContentType.json);
        request.headers.add("contentLength", jsonEncoded.length);
        request.write(jsonEncoded);
      });
      // await HttpClient().post('144.202.96.35', 8080, 'avatar/push')
      //   ..headers.contentType = ContentType.json
      //   ..headers.contentLength = jsonEncoded.length
      //   ..write(jsonEncoded);
      //HttpClientResponse response = await request.close();  
      setState(() {
        _image=result;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    // context.PaintingBinding.instance.imageCache.maximumSize=0;
    // return Scaffold(
    //   appBar: AppBar(),
    //   body:ListView(
    //   children: <Widget>[
        
    //     ListTile(
    //       leading: _image.existsSync()?CircleAvatar(backgroundImage: FileImage(_image,scale: 0.2)):Text("aa"),
    //       title:Text(Globals.myInfo.name),
    //     ),
    //     ListTile(
    //       title:Text("我的二维码"),
    //       onTap: (){
    //         showDialog(
    //           context: context,
    //           builder: (BuildContext context){
    //             return Dialog(
    //               child: QrImage(
    //                 data: json.encode({'type':'contact', 'data':{'name':Globals.myInfo.name,'userid':Globals.myInfo.userid,'publickey':Globals.myInfo.publickey}}),
    //                 version: 8,
    //                 ),
    //             );
    //           });
    //       },
    //     ),
    //     ListTile(
    //       title: Text("设置头像"),
    //       onTap: getImage
    //     )
    //   ],
    // ),
    // bottomNavigationBar: BottomNavBar(),
    // );
    // return ListView(
    //   children: <Widget>[
        
    //     ListTile(
    //       leading: _image.existsSync()?CircleAvatar(backgroundImage: FileImage(_image,scale: 0.2)):Text("aa"),
    //       title:Text(Globals.myInfo.name),
    //     ),
    //     ListTile(
    //       title:Text("我的二维码"),
    //       onTap: (){
    //         showDialog(
    //           context: context,
    //           builder: (BuildContext context){
    //             return Dialog(
    //               child: QrImage(
    //                 data: json.encode({'type':'contact', 'data':{'name':Globals.myInfo.name,'userid':Globals.myInfo.userid,'publickey':Globals.myInfo.publickey}}),
    //                 version: 8,
    //                 ),
    //             );
    //           });
    //       },
    //     ),
    //     ListTile(
    //       title: Text("设置头像"),
    //       onTap: getImage
    //     )
    //   ],
    // );

    return Column(
        children: <Widget>[
          Container(
            color: Colors.red[50],
            height: 100,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: new BoxDecoration(
                  image: DecorationImage(image: FileImage(_image,scale: 0.2)),
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(8.0),
                    ), 
                  ),

                  margin: new EdgeInsets.all(4),
                ),
                Expanded(
                  child:Container(
                    margin: EdgeInsets.only(left: 4),
                    height: 60,
                    child:Column(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children:<Widget>[
                              Text(Globals.myInfo.name,style: TextStyle(fontSize: 24),)
                            ]
                          )
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: <Widget>[
                              Text("嗨聊号:zhangsan199"),
                              Expanded(
                                child:Container(
                                  child:Icon(Icons.ac_unit,size:20),
                                  alignment: AlignmentDirectional.centerEnd,
                                  )
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  )  
                ) 
              ],
            ),
          ),
          Divider(height: 10,thickness: 1),
          GestureDetector(
            child:Row(
              children: <Widget>[
                Container(
                  padding:EdgeInsets.only(left:10),
                  child: Text("设置"),
                )
              ],
            )
          ),
          Divider(height: 10,thickness: 1),
          GestureDetector(
            child:Row(
              children: <Widget>[
                Container(
                  padding:EdgeInsets.only(left:10),
                  child: Text("设置头像"),
                )
              ],
            ),
            onTap: getImage,
          ),
          Divider(height: 10,thickness: 1),
          GestureDetector(
            child:Row(
              children: <Widget>[
                Container(
                  padding:EdgeInsets.only(left:10),
                  child: Text("我的二维码"),
                )
              ],
            ),
            onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return Dialog(
                  child: QrImage(
                    data: json.encode({'type':'contact', 'data':{'name':Globals.myInfo.name,'userid':Globals.myInfo.userid,'publickey':Globals.myInfo.publickey}}),
                    version: 8,
                    ),
                );
              });
          },
          ),
        ],
      );
  }
}