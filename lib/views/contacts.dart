import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hichat/views/base.dart';
import '../models/contact.dart';
import 'chat.dart';
import '../global.dart';

class ContactsView extends StatefulWidget{
  ContactsView({Key key, this.title, this.contacts}) : super(key: key);
  final String title;

  final List<Contact> contacts;
   @override
  _ContactsViewState createState()=>_ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {

  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  void initState(){
    super.initState();
    Globals.bus.on('contact', (contact){
      if (!mounted) {
        return;
      }
      setState(() {
       widget.contacts.add(contact); 
      });
    });
  }

  Widget _buildRow(BuildContext context, Contact contact) {
    File img = File(Globals.avatarPath+contact.userid.toString()+".jpg");
    File myavatar = File(Globals.myAvatar);
    // return new ListTile(
    //   leading: CircleAvatar(backgroundImage: FileImage(img.existsSync()?img:myavatar,scale: 0.2)),
    //   title: new Text(
    //     contact.name,
    //     style: _biggerFont,
    //   ),
    //   onTap: ()async{
    //     print(contact.userid);
    //     var dialogues = await Globals.dialogueProvider.getDialogues(contact.userid);
    //     Navigator.push(context, MaterialPageRoute<void>(
    //         builder: (BuildContext context) {
    //           return ChatView(contact:contact, dialogues:dialogues);
    //         },
    //       ));}
    // );
    return Column(children: <Widget>[
      GestureDetector(
         onTap: ()async{
        print(contact.userid);
        var dialogues = await Globals.dialogueProvider.getDialogues(contact.userid);
        Navigator.push(context, MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return ChatView(contact:contact, dialogues:dialogues);
            },
          ));},
            child:Container(
              height: 60,
              color: Colors.red[50],
              child: Row(children: <Widget>[
                Container(
            height: 44,
            width: 44,
        decoration: new BoxDecoration(
        image: DecorationImage(image: AssetImage('images/Jason-R-Deschler.jpg')),
        borderRadius: new BorderRadius.all(
          const Radius.circular(8.0),
        ), 
      ),

      margin: new EdgeInsets.all(8),),
        Expanded(child:Container(child:Column(
        children: <Widget>[
          Expanded(child: Container(child:Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Expanded(child:Text(contact.name,textAlign:TextAlign.left,style:TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.w900,
)))
,
    
            ],
          ),
          // decoration: new BoxDecoration(border: Border.all()),
          )),
        ],
      ),
      // decoration: new BoxDecoration(border: Border.all()),
      margin: EdgeInsets.all(4),))
              ],),
            ),),
                  Divider(height: 1,thickness: 1,indent: 60,),

    ],);
  }

  @override
  Widget build(BuildContext context) {

    // return Scaffold(
    //   appBar: AppBar(title: Text('联系人'), actions: <Widget>[popupMenu(context)]),
    //   body:ListView.builder(
    //   itemCount: Globals.contacts.length,
    //   itemBuilder: (context, i){

    //     return _buildRow(context, Globals.contacts[i]);
    //   },),
    //   bottomNavigationBar: BottomNavBar(),
    // );

    return ListView.builder(
      itemCount: Globals.contacts.length,
      itemBuilder: (context, i){

        return _buildRow(context, Globals.contacts[i]);
      },);

  }
}