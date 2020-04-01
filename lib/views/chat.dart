import 'dart:io';

import 'package:flutter/material.dart';
import '../models/dialogue.dart';
import '../models/contact.dart';
import '../utils.dart';
import 'dart:convert';
import '../global.dart';

class ChatView extends StatefulWidget{
  ChatView({Key key, this.contact, this.dialogues}) : super(key: key);

  final List<Dialogue> dialogues;
  final Contact contact;

  @override
  _ChatViewState createState()=>_ChatViewState();
}

class _ChatViewState extends State<ChatView>{

  String path;
  var _controller = new TextEditingController();
  var scrollcontroller = new ScrollController(initialScrollOffset: 0);
  List<Dialogue> dialogues;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  var offset;
  @override
  void initState(){
    super.initState();
    scrollcontroller.addListener((){print(scrollcontroller.position.maxScrollExtent);});
    dialogues = widget.dialogues==null?new List<Dialogue>():widget.dialogues;
    Globals.bus.on('dialogue',(jsonData)async{
     if(jsonData['type']=='dialogue'&&jsonData['data']['from'] == widget.contact.id){
        var map = {
          'contact':jsonData['data']['from'],
          'name':jsonData['data']['name'],
          'io':0,
          'content':decrypt(jsonData['data']['content'], widget.contact.negkey),
          'created':jsonData['data']['created']
        };
        // Dialogue _dialogue = await widget.dialogueProvider.insert(Dialogue.fromMap(map));
        if (!mounted) {
          return;
        }
        setState(() {
          dialogues.add(Dialogue.fromMap(map));
        });
      }
    });
  }

  Widget _buildRow(Dialogue dialogue) {
    File img = File(Globals.avatarPath+dialogue.contact.toString()+".jpg");
    File myavatar = File(Globals.myAvatar);
    String time = DateTime.fromMillisecondsSinceEpoch(dialogue.created*1000).toString().substring(11,16);
    
    
    // return ListTile(
    //   leading: dialogue.io==1?CircleAvatar(backgroundImage: FileImage(myavatar,scale: 0.2)):CircleAvatar(backgroundImage: FileImage(img.existsSync()?img:myavatar,scale: 0.2)),
    //   subtitle: new Text(
    //     dialogue.content,
    //     style: _biggerFont,
    //   ),
    //   title: dialogue.io==1?Text('我  '+time,style: TextStyle(fontSize: 14.0),):Text(dialogue.name+'  '+time,style: TextStyle(fontSize: 14.0),),
    // );

        return  Container(
            child: dialogue.io==1?Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: new BoxDecoration(
                        image: DecorationImage(image: FileImage(myavatar,scale: 0.2),fit: BoxFit.fitWidth),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(8.0),
                          ), 
                        ),
                        margin: new EdgeInsets.all(8),),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            margin: EdgeInsets.only(top: 8,left: 2),
                            child:Text(dialogue.content,style: TextStyle(),),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              // border: Border.all(color: Colors.red[400]),
                              borderRadius: BorderRadius.all(const Radius.circular(8))
                            ),
                          )
                        )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(),
                )
              ],
            ):
          Row(
              children: <Widget>[
                 Expanded(
                  flex: 1,
                  child: Row(),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
   
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            margin: EdgeInsets.only(top: 8,left: 2),
                            child:Text(dialogue.content,style: TextStyle(),),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              // border: Border.all(color: Colors.red[400]),
                              borderRadius: BorderRadius.all(const Radius.circular(8))
                            ),
                          )
                        ),
                                           Container(
                        width: 48,
                        height: 48,
                        decoration: new BoxDecoration(
                        image: DecorationImage(image: FileImage(img.existsSync()?img:myavatar,scale: 0.2),fit: BoxFit.fitWidth),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(8.0),
                          ), 
                        ),
                        margin: new EdgeInsets.all(8),),
                    ],
                  ),
                ),
               
              ],
            ),
          );
  }
  Widget build(BuildContext context){
    
    return new Scaffold(
      backgroundColor: Colors.red[50],
      // resizeToAvoidBottomPadding: false,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.contact.name),
        backgroundColor: Colors.red[200]
      ),

      
      body: Column(children: <Widget>[
      //   Expanded(child: new ListView.builder(
      //     itemCount: widget.dialogues.length,
      //     controller: scrollcontroller,
      //     itemBuilder: (context, i){
      //       return _buildRow(dialogues[i]);
      //     },
      //   ),
      // ),
      Expanded(child: SingleChildScrollView(
        reverse:true,
        child:
        new ListView.builder(
          physics: new NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.dialogues==null?0:widget.dialogues.length,
          itemBuilder: (context, i){
            return _buildRow(dialogues[i]);
          },
        ),
      ),),
      Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.red[100])),
          color: Colors.red[50],
        ),
        child:Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.red[50]
                ),
                borderRadius: BorderRadius.all(const Radius.circular(8))
              ),
              child:TextField(
                minLines: 1,
              decoration: InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
              cursorColor: Colors.red[200],
            controller: _controller,
          )),
          flex: 5,),
          Expanded(
            child:GestureDetector(
              child:Container(
            alignment: AlignmentDirectional.center,
            height: 35,
            margin: EdgeInsets.only(left: 0,right: 4,top: 6,bottom: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(const Radius.circular(8))
            ),
            child: Text("发送",textAlign: TextAlign.justify,style: TextStyle(color: Colors.white),),
          ),
          onTap: (){
              var text = _controller.text;
              var created = DateTime.now().toLocal().millisecondsSinceEpoch~/1000;
              var map = {
                'contact':widget.contact.userid,
                'name':widget.contact.name,
                'io':1,
                'content':text,
                'created':created
              };
              var dialogue = new Dialogue.fromMap(map);
              Globals.dialogueProvider.insert(dialogue);
              _controller.clear();
              var data = {'type':'dialogue', 'from':Globals.myInfo.userid, 'name':Globals.myInfo.name, 'pubkeyfrom':Globals.myInfo.publickey, 'to':widget.contact.userid, 'content':encrypt(text, widget.contact.negkey), 'created':created};
              Globals.socket.add(json.encode(data));
              setState(() {
                dialogues.add(dialogue);
              });
            },
            ),
            
            // IconButton(
            // icon: Icon(Icons.send),
            // color: Colors.blue,
            // onPressed: (){
            //   var text = _controller.text;
            //   var created = DateTime.now().toLocal().millisecondsSinceEpoch~/1000;
            //   var map = {
            //     'contact':widget.contact.userid,
            //     'name':widget.contact.name,
            //     'io':1,
            //     'content':text,
            //     'created':created
            //   };
            //   var dialogue = new Dialogue.fromMap(map);
            //   Globals.dialogueProvider.insert(dialogue);
            //   _controller.clear();
            //   var data = {'type':'dialogue', 'from':Globals.myInfo.userid, 'name':Globals.myInfo.name, 'pubkeyfrom':Globals.myInfo.publickey, 'to':widget.contact.userid, 'content':encrypt(text, widget.contact.negkey), 'created':created};
            //   Globals.socket.add(json.encode(data));
            //   setState(() {
            //     dialogues.add(dialogue);
            //   });
            // },),
            flex: 1,)
        ],
      ))
      ],
      )
      
    );
  }
}
