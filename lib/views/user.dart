import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../global.dart';
import 'chat.dart';

class UserView extends StatefulWidget{
  UserView({Key key, this.title, this.contact}) : super(key: key);
  final String title;

  final Contact contact;
   @override
  _UserViewState createState()=>_UserViewState();
}

class _UserViewState extends State<UserView> {

  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        leading: Text(widget.contact.name),
      ),
      body: Center(child: Column(children: <Widget>[
        Row(children: <Widget>[
          RaisedButton(
            child: Text('发消息'),
            onPressed: ()async{
              var dialogues = await Globals.dialogueProvider.getDialogues(widget.contact.userid);
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return ChatView(contact:widget.contact,dialogues: dialogues);
                },
              ));
            },
          )],)
      ],),),
    );
  }
}