import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hichat/views/base.dart';
import '../models/dialogue.dart';
import '../models/contact.dart';
import '../views/chat.dart';
import '../global.dart';

class DialoguesView extends StatefulWidget{
  DialoguesView({Key key, this.title}) : super(key: key);
  final String title;



   @override
  _DialoguesViewState createState()=>_DialoguesViewState();
}

class _DialoguesViewState extends State<DialoguesView> {


  String path;
  final _biggerFont = const TextStyle(fontSize: 24.0);

  @override
  void initState(){
    super.initState();
    Globals.bus.on("d",(d){
      if (!mounted) {
        return;
      }
      setState(() {
      });
    });
  }

  Widget _buildRow(Dialogue dialogue, String contactName, BuildContext context) {
    File img = File(Globals.avatarPath+dialogue.contact.toString()+".jpg");
    File myavatar = File(Globals.myAvatar);

    return  Column(
      children:<Widget>[
    GestureDetector(
      child: Container(
        height: 60,
        color: Colors.red[50],
        child: Row(children: <Widget>[
          Container(
          height: 52,
          width: 52,
          decoration: new BoxDecoration(
          image: DecorationImage(image: FileImage(img.existsSync()?img:myavatar)),
          borderRadius: new BorderRadius.all(
            const Radius.circular(8.0),
          ), 
        ),

      margin: new EdgeInsets.all(4),),
        Expanded(child:Container(child:Column(
        children: <Widget>[
          Expanded(flex: 3,child: Container(child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[Expanded(child:Text(contactName,textAlign:TextAlign.left,style:TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
          )))
          ,
        Expanded(child:Container(child:Text(DateTime.fromMillisecondsSinceEpoch(dialogue.created*1000).toString().substring(11,16),textAlign:TextAlign.right,style:TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
          
        )),
        margin: EdgeInsets.only(right: 10),),),
            ],
          ),
          // decoration: new BoxDecoration(border: Border.all()),
          )),
          Expanded(flex: 3,child: Row(children: <Widget>[Expanded(child: Text(dialogue.content,style: TextStyle(color: Colors.red[200]), maxLines: 1,),)],),)
        ],
      ),
      // decoration: new BoxDecoration(border: Border.all()),
      margin: EdgeInsets.all(4),))
              ],),
            ),
            onTap: ()async{

        Contact contact = await Globals.contactProvider.getContact(dialogue.contact);
        List<Dialogue> dialogues = await Globals.dialogueProvider.getDialogues(dialogue.contact);
        Navigator.push(context, MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return ChatView(contact:contact, dialogues: dialogues,);
          },
        ));
      },
    ),
                Divider(height: 1,thickness: 1,indent: 60,),

      ]
    );

    

    // return new ListTile(
    //   leading: CircleAvatar(radius:20,backgroundImage: FileImage(img.existsSync()?img:myavatar,scale: 0.2)),
    //   title: new Text(
    //     contactName,
    //     style: _biggerFont,
    //   ),
    //   subtitle: new Text(
    //     dialogue.content,
    //   ),
    //   trailing: Text(DateTime.fromMillisecondsSinceEpoch(dialogue.created*1000).toString().substring(11,16)),
    //   onTap: ()async{

    //     Contact contact = await Globals.contactProvider.getContact(dialogue.contact);
    //     List<Dialogue> dialogues = await Globals.dialogueProvider.getDialogues(dialogue.contact);
    //     Navigator.push(context, MaterialPageRoute<void>(
    //       builder: (BuildContext context) {
    //         return ChatView(contact:contact, dialogues: dialogues,);
    //       },
    //     ));
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {

    // return Scaffold(
    //   appBar: AppBar(title: Text("")),
    //   body:ListView.builder(
    //   itemCount: Globals.recentDialogues.length,
    //   itemBuilder: (context, i){
    //     return _buildRow(Globals.recentDialogues[i], Globals.recentDialogues[i].name, context);
    //   },),
    //   bottomNavigationBar: BottomNavBar(),
    // );
    // return Text('hello');
    return ListView.builder(
      itemCount: Globals.recentDialogues.length,
      itemBuilder: (context, i){
        return _buildRow(Globals.recentDialogues[i], Globals.recentDialogues[i].name, context);
      },);
  }
}