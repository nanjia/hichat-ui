import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import "package:pointycastle/api.dart";
import "package:pointycastle/pointycastle.dart";
import "package:pointycastle/key_generators/ec_key_generator.dart";
import 'dart:convert';
import 'dart:async';
import 'global.dart';
import 'init.dart';
import 'models/account.dart';
import 'models/contact.dart';
import 'models/dialogue.dart';
import 'models/activity.dart';

class DialogueSink implements EventSink<String> {
  final EventSink<String> _outputSink;
  DialogueSink(this._outputSink);

  void add(String data) {
    var jsonData = json.decode(data);
    if(jsonData['type'] == 'dialogue'){
      _outputSink.add(data);
    }
  }

  void addError(e, [st]) { _outputSink.addError(e, st); }
  void close() { _outputSink.close(); }
}
Map createAccount(){
  var rnd = new SecureRandom("AES/CTR/AUTO-SEED-PRNG");
  final key = createMetaDataFromTime();
  final keyParam = new KeyParameter(key);
  final rndParams = new ParametersWithIV(keyParam, new Uint8List(16));
  rnd.seed(rndParams);

  var domainParams = new ECDomainParameters("prime192v1");
  var ecParams = new ECKeyGeneratorParameters(domainParams);
  var params = new ParametersWithRandom<ECKeyGeneratorParameters>(ecParams, rnd);
  var keyGenerator = ECKeyGenerator();
  keyGenerator.init(params);
  var rawKeyPair = keyGenerator.generateKeyPair();
  var keyPair = AsymmetricKeyPair<ECPublicKey, ECPrivateKey>(rawKeyPair.publicKey, rawKeyPair.privateKey);
  var publicKey = base64Encode(createUint8ListFromBigInt(keyPair.publicKey.Q.x.toBigInteger())+createUint8ListFromBigInt(keyPair.publicKey.Q.y.toBigInteger()));
  var privateKey = base64Encode(createUint8ListFromBigInt(keyPair.privateKey.d));
  return {"public":publicKey,'private':privateKey};
}

Uint8List createUint8ListFromBigInt(BigInt num){
  var list = List<int>();
  var str = num.toRadixString(16);
  str = str.padLeft(48, '0');
    for(int i = 0; i<str.length; i+=2){
    list.add(int.parse('0x'+str.substring(i,i+2)));
  }
  return Uint8List.fromList(list);
}

Uint8List createMetaDataFromTime(){
  var str = BigInt.from(DateTime.now().microsecondsSinceEpoch).toRadixString(16);
  var str1 = str.padLeft(32, '0');
    var list = List<int>();
    for(int i = 0; i<str1.length; i+=2){
    list.add(int.parse('0x'+str1.substring(i,i+2)));
  }
  return Uint8List.fromList(list);
}

BigInt createBigIntFromUint8List(Uint8List list){
  String result = '';
  for(int i = 0; i<list.length; i++){
    if(list[i]<16){
      result += '0'+list[i].toRadixString(16);
    }else{
      result += list[i].toRadixString(16);
    }
  }
  return BigInt.parse(result, radix:16);
}

Uint8List createUint8ListFromString(String s) {
  var ret = new Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

String formatBytesAsHexString(Uint8List bytes) {
  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

Future<String> generateNegKey(String privatekey, String publickey)async{

  var uint8ListKey = base64Decode(publickey);
  var coordinateX = uint8ListKey.sublist(0, uint8ListKey.length~/2);
  var coordinateY = uint8ListKey.sublist(uint8ListKey.length~/2);
  var eccDomain = new ECDomainParameters("prime192v1");
  var Q = eccDomain.curve.createPoint(createBigIntFromUint8List(coordinateX), createBigIntFromUint8List(coordinateY));
  var negKeyTemp = Q*createBigIntFromUint8List(base64Decode(privatekey));
  print(negKeyTemp.x.toBigInteger());
  print(negKeyTemp.y.toBigInteger());
  var kss = createUint8ListFromBigInt(negKeyTemp.x.toBigInteger());
  kss = kss.sublist(0, 24);
  print(base64Encode(kss));
  return base64Encode(kss);
}

String encrypt(String data, String negKey){
  var uint8ListKey = base64Decode(negKey);
  final params = new KeyParameter(uint8ListKey);
  var cipher = new BlockCipher("AES");
  cipher..reset()..init(true, params);
  var plainText = utf8.encode(data);
  if(plainText.length%16>0){
    var padding = Uint8List(16-plainText.length%16);
    padding.setAll(0, [0x00]);
    plainText = Uint8List.fromList(plainText+padding);
  }
  var out = new Uint8List(plainText.length);
  for (var offset = 0; offset < plainText.length;) {
    var len = cipher.processBlock(plainText, offset, out, offset);
    offset += len;
  }
  var cipherText = out;
  var encodedCipherText = base64Encode(cipherText);
  return encodedCipherText;
}

String decrypt(String cipherText, String negKey){
  print(cipherText);
  var data = base64Decode(cipherText);
  print(data);
  if(data.length%16>0){
    var padding = Uint8List(16-data.length%16);
    padding.setAll(0, [0x00]);
    data = Uint8List.fromList(data+padding);
  }
  var uint8ListKey = base64Decode(negKey);
  final params = new KeyParameter(uint8ListKey);
  var cipher = new BlockCipher("AES");
  cipher..reset()..init(false, params);
  var cout = new Uint8List(data.length);
  for (var offset = 0; offset < data.length;) {
    var len = cipher.processBlock(data, offset, cout, offset);
    offset += len;
  }
  var plainTextAgain = Utf8Codec(allowMalformed: true).decode(cout);
  return plainTextAgain;
}

typedef void EventCallback(arg);

class EventBus {
  //私有构造函数
  EventBus._internal();

  //保存单例
  static EventBus _singleton = new EventBus._internal();

  //工厂构造函数
  factory EventBus()=> _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  var _emap = new Map<Object, List<EventCallback>>();

  //添加订阅者
  void on(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _emap[eventName] ??= new List<EventCallback>();
    _emap[eventName].add(f);
  }

  //移除订阅者
  void off(eventName, [EventCallback f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    //反向遍历，防止在订阅者在回调中移除自身带来的下标错位 
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}

Future handleCreateAccount(BuildContext context, username,img)async{
  // if(controller.text == ''){
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context)=>new SnackBar(
  //     content: new Text('请输入用户名'),
  //   ),
  //   );
  //   return;
  // }

  account = createAccount();
  // Map jsonData = {
  //   'username':base64Encode(Uint8List.fromList(utf8.encode(controller.text))),
  //   'pubkey':account['public'],
  //   'created':DateTime.now().toLocal().millisecondsSinceEpoch~/1000
  // };
  Map jsonData = {
    'username':base64Encode(Uint8List.fromList(utf8.encode(username))),
    'pubkey':account['public'],
    'created':DateTime.now().toLocal().millisecondsSinceEpoch~/1000
  };
  String encoded = json.encode(jsonData);
  print('jsondata');
  print(jsonData);
  var request = await HttpClient().post('144.202.96.35', 8080, 'signup')
    ..headers.contentType = ContentType.json 
    ..headers.contentLength = encoded.length
    ..write(encoded);
  HttpClientResponse response = await request.close();  
  var data = await response.transform(utf8.decoder).join();
  print(data);
  var userId = int.tryParse(data);
  String  jsonEncoded = json.encode({"uid":userId,"avatar":img});

  // await HttpClient().post('144.202.96.35', 8080, 'avatar/push')
  // ..headers.contentType = ContentType.json
  // ..headers.contentLength = jsonEncoded.length
  // ..write(jsonEncoded);
  Globals.client.postUrl(Uri.parse("http://144.202.96.35:8080/avatar/push")).then((request){
    request.headers.add("contentType", ContentType.json);
    request.headers.add("contentLength", jsonEncoded.length);
    request.write(jsonEncoded);
  });
  await File(Globals.myAvatar).copy(Globals.avatarPath+'$userId.jpg');
  //var teamKey = '0HRZzWQdg8TYiST0Jz4yDJ+14tnfNm2Qc3M3WmjlG1O5Nj7Xs2CUcxnrxsucFgB4';
  var newAccount = Account.fromMap({'userid':userId,'publickey':account['public'], 'privatekey':account['private'], 'name':username});
  await Globals.accountProvider.insert(newAccount);
  //var teamNegKey = await generateNegKey(account['private'],teamKey);
  //print('negkey:'+teamNegKey);
  //await Globals.contactProvider.insert(Contact.fromMap({'id':1, 'userid':1, 'name':'team', 'publickey':teamKey,'negkey':teamNegKey}));
  //await Globals.dialogueProvider.insert(Dialogue.fromMap({'id':1, 'contact':1, 'name':'team','io':0, 'content':'hello!', 'created':DateTime.now().toLocal().millisecondsSinceEpoch~/1000}));
  Globals.socket = await WebSocket.connect('ws://144.202.96.35:8080/ws');
  Globals.myInfo = await Globals.accountProvider.myInfo(); 
  Globals.socket.add(json.encode({
    'type':'init',
    'userid':Globals.myInfo.userid
  }));
}

  void handleMsg(msg)async{
    var jsonData = json.decode(msg);
    if(jsonData['type'] == 'dialogue'){
      print(jsonData);
      Globals.bus.emit('dialogue', jsonData);
      Contact contact;
      var data =jsonData['data'];
      contact = await Globals.contactProvider.getContact(jsonData['data']['from']);
      if(contact == null){
        var myPrivate = await Globals.accountProvider.myPrivateKey();
        var myNeg = await generateNegKey(myPrivate,data['pubkey']);
        var map = {
          'userid': data['from'],
          'name': data['name'],
          'publickey': data['pubkey'],
          'created': DateTime.now().toLocal().millisecondsSinceEpoch~/1000,
          'negkey': myNeg
        };
        await Globals.contactProvider.insert(Contact.fromMap(map));
        Globals.contacts = await Globals.contactProvider.getContacts();
        //var encoded = json.encode({'type':'add','content':{'host':myInfo.userid, 'guest':map['userid']}});
        //await HttpClient().post('10.132.247.108', 8090, 'contact')
        // ..headers.contentType = ContentType.json 
        // ..headers.contentLength = encoded.length
        // ..write(encoded);
        Globals.bus.emit('contact', Contact.fromMap(map));
        //bodyContent[1] = new ContactsView(contacts: contacts);
        contact = Contact.fromMap(map);
      }
      var newDialogue = {
        'contact':jsonData['data']['from'],
        'io':0,
        'content': decrypt(jsonData['data']['content'], contact.negkey),
        'name':jsonData['data']['name'],
        'created':jsonData['data']['created']
      };
      await Globals.dialogueProvider.insert(Dialogue.fromMap(newDialogue));
      Globals.recentDialogues = await Globals.dialogueProvider.getRecentDialogues(); 
      
      Globals.bus.emit('d', 'd');//setState(() {
        //bodyContent[0] = new DialoguesView(dialogues: recentDialogues);
        // if(contact == null){
        //   bodyContent[1] = new ContactsView(contacts: contacts,);
        // }
      //});
    }else if(jsonData['type'] == 'activity'){
      Globals.bus.emit('activity', Activity.fromMap(jsonData));
      Globals.activityProvider.insert(Activity.fromMap(jsonData));
      Globals.recentActivities = await Globals.activityProvider.getRecentActivities();
    }
  }
