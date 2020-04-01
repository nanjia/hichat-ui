import 'package:flutter/material.dart';
import 'package:hichat/views/signup.dart';
import 'utils.dart';

import 'views/dialogues.dart';

import 'global.dart';
import 'init.dart';

void main()async{
  await init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '***',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: '***'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState()=>_MyHomePageState();
  
}

class _MyHomePageState extends State<MyHomePage> {

  bool _accountCreated;


  @override
  void initState(){
    super.initState();
    _accountCreated = accountCreated;
    if(_accountCreated){
      if(Globals.socket!=null){
        Globals.socket.listen(handleMsg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if(_accountCreated){
      return DialoguesView();
    }else{
      return SignUpView();
    }

  }
}
