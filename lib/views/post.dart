import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hichat/views/base.dart';
import '../models/activity.dart';
import 'chat.dart';
import '../global.dart';

class PostView extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_PostViewState();
}

class _PostViewState extends State<PostView>{

  var _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
                border: Border.all(
                  color: Colors.red[100]
                ),
                borderRadius: BorderRadius.all(const Radius.circular(8))
            ),
            child: TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
            ),
          ),
          RaisedButton(
            onPressed: ()async{
              Activity activity = Activity();
              activity.userid=Globals.myInfo.userid;
              activity.username=Globals.myInfo.name;
              activity.created=DateTime.now().toLocal().millisecondsSinceEpoch~/1000;
              activity.content=_controller.text;
              Globals.activityProvider.insert(activity);
              var data = {'type':'activity','userid':activity.userid,'username':activity.username,'created':activity.created,'content':activity.content};
              Globals.socket.add(data);
              Globals.bus.emit("activity",activity);
              Navigator.pop(context); 
            },
            color: Colors.red,
            disabledColor: Colors.red,
            textColor: Colors.white,
            disabledTextColor: Colors.white,
            child: Text("发布"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))
            ),
            )
        ],
      ),
    );
  }
}
