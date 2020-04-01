import 'package:flutter/material.dart';
import '../global.dart';
import '../utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import '../models/contact.dart';
import '../models/account.dart';
import 'dart:io';
import 'dart:convert';

import 'contacts.dart';
import 'dialogues.dart';
import 'my.dart';

PopupMenuButton popupMenu(BuildContext context){
  return PopupMenuButton(
      itemBuilder: (BuildContext context)=><PopupMenuEntry>[
        PopupMenuItem(
          child: Text('扫一扫'),
          value: 1,
        ),
        
      ],
      onSelected: (dynamic value)async{
        var path;
        ContactProvider contactProvider =ContactProvider();
        await getDatabasesPath().then((v)async{
        try {
          await Directory(v).create(recursive: true);
        } catch (_) {}
          path = join(v,'lianai.db');
        });
        await contactProvider.open(path);
        AccountProvider accountProvider = AccountProvider();
        await accountProvider.open(path);
        var privateKey = await accountProvider.myPrivateKey();
        var myInfo = await accountProvider.myInfo();
        switch(value){
          case 1:
          var strInfo = await new QRCodeReader()
                .setAutoFocusIntervalInMs(200)
                .setForceAutoFocus(true)
                .setTorchEnabled(true)
                .setHandlePermissions(true)
                .setExecuteAfterPermissionGranted(true)
              .scan();
              if(strInfo != null){
          
                Map info = json.decode(strInfo);
                switch (info['type']) {
                case 'contact': 
                  print(info);
                  var contact;
                  var data =info['data'];
                  await contactProvider.getContact(info['data']['userid']).then((value){contact =value;});
                  if(contact == null){
                    print(data);
                    var negkey = await generateNegKey(privateKey ,info['data']['publickey']);
                    print(negkey);
                    data['negkey'] =negkey;
                    await contactProvider.insert(Contact.fromMap(data));
                    var encoded = json.encode({'type':'add','content':{'host':myInfo.userid, 'guest':data['userid']}});
                    await HttpClient().post('10.132.247.108', 8090, 'contact')
                    ..headers.contentType = ContentType.json 
                    ..headers.contentLength = encoded.length
                    ..write(encoded);

                    Globals.bus.emit('contact', Contact.fromMap(data));
                    Globals.client.getUrl(Uri.parse("http://144.202.96.35:8080/avatar/get?id="+data['userid'])).then((HttpClientRequest request){
                      return request.close();
                    }).then((HttpClientResponse response)async{
                      var string = await response.transform(utf8.decoder).join();
                      File img = File(Globals.avatarPath+data["userid"]+"jpg");
                      await img.create();
                      List<int> intlist=new List<int>();
                      List<String> list = string.substring(1,string.length-1).split(",");
                      list.forEach((s)=>{
                        intlist.add(int.parse(s))
                      });
                      img.writeAsBytesSync(intlist);
                    });
                  }              
                  break;
                default:
              }
            }
          break;
          default:
        }
      },
      icon: Icon(Icons.person_add),
    );
}

class BottomNavBar extends StatefulWidget{
  @override
  _BottomNavBarState createState()=>_BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>{

  int _selectedIndex = Globals.navBarSelectedIndex;

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('信息')),
        BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/contacts.png")), title: Text('联系人')),
        BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/discovery.png")), title: Text('发现')),
        BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我')),
      ],
      // fixedColor: Colors.green,
      type:BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (int index) {
        Globals.navBarSelectedIndex=index;
        // switch(index){
        //   case 0:
        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
        //       builder: (BuildContext context) {
        //         return DialoguesView();
        //       },
        //     ),(Route<dynamic> route) => false);
        //     break;
        //   case 1:
        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(

        //       builder: (BuildContext context) {
        //         return ContactsView();
        //       },
        //     ),(Route<dynamic> route) => false);
        //     break;
        //   case 2:
        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
        //       builder: (BuildContext context) {
        //         // return ActivitiesView();
        //         return null;
        //       },
        //     ),(Route<dynamic> route) => false);
        //     break;
        //   case 3:
        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
        //       builder: (BuildContext context) {
        //         return MyView();
        //       },
        //     ),(Route<dynamic> route) => false);
        //     break;
        //   default:
        //     break;
        // }
      },
    );
  }
  
}
