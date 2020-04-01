import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'utils.dart';
import 'models/account.dart';
import 'models/contact.dart';
import 'models/dialogue.dart';
import 'models/activity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'global.dart';
import 'package:path_provider/path_provider.dart';

String path;
Map account;
bool accountCreated;

Future<String> myAvatarPath() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return '$dir/myAvatar.jpg';
}
Future<String> avatarPath() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return dir+"/avatars/";
}
Future init()async{
  
  Globals.bus=new EventBus();
  Globals.myAvatar=await myAvatarPath();
  Globals.avatarPath = await avatarPath();
  Globals.accountProvider = AccountProvider();
  Globals.contactProvider = ContactProvider();
  Globals.dialogueProvider = DialogueProvider();
  Globals.activityProvider = ActivityProvider();
  await getDatabasesPath().then((v)async{
  try {
    await Directory(v).create(recursive: true);
  } catch (_) {}
  path = join(v,'lianai.db');
  });
  
  await Globals.accountProvider.open(path);
  await Globals.contactProvider.open(path);
  await Globals.dialogueProvider.open(path);
  await Globals.activityProvider.open(path);
  //     var ss = await accountProvider.db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
  await Globals.accountProvider.db.query('contacts').then(print);
  await Globals.accountProvider.db.query('dialogues').then(print);
  await Globals.accountProvider.db.query('account').then(print);
  accountCreated = await isAccountCreated();
  print(accountCreated);
  if(accountCreated){
    Globals.myInfo = await Globals.accountProvider.myInfo();
    //    var teamKey = '0HRZzWQdg8TYiST0Jz4yDJ+14tnfNm2Qc3M3WmjlG1O5Nj7Xs2CUcxnrxsucFgB4';
    //    var mypri = await accountProvider.myPrivateKey();
    // var teamNegKey = await generateNegKey(mypri,teamKey);
    try{
      
      Globals.socket = await WebSocket.connect('ws://144.202.96.35:8080/ws').timeout(Duration(seconds: 10));
      if(Globals.socket.readyState==WebSocket.open){
      Globals.socket.add(json.encode({
          'type':'init',
          'userid':Globals.myInfo.userid
        }));
      }
    }catch(e){
      //print(e);
    }
    
    // socket.then((s)=>{s.add(json.encode({
    //       'type':'init',
    //       'userid':myInfo.userid
    //     }))}).catchError((e)=>{
    //       print(e)
    //     }).timeout(Duration(seconds: 10),onTimeout: ()=>{});

    // await socket;
    


    Globals.recentDialogues = await Globals.dialogueProvider.getRecentDialogues(); 
    Globals.recentActivities = await Globals.activityProvider.getRecentActivities();
    Globals.contacts = await Globals.contactProvider.getContacts();
  }else{
  }
}

Future<bool> isAccountCreated()async{
  Account _account;
  _account = await Globals.accountProvider.getAccount(1);
  if(_account != null){
    return true;
  }else{
    return false;
  }
}

