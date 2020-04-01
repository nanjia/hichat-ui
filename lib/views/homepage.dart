import 'package:flutter/material.dart';
import 'package:hichat/views/contacts.dart';
import 'activities.dart';
import 'base.dart';
import 'dialogues.dart';
import 'my.dart';


class HomePageView extends StatefulWidget{
  HomePageView({Key key, this.title}) : super(key: key);
  
  final String title;

   @override
  _HomePageViewState createState()=>_HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>{

  static int _selectedIndex = 0;


  final bodyContents = [
    new DialoguesView(),
    new ContactsView(),
    new ActivitiesView(),
    new MyView()
  ];


  void _onItemTapped(int index){
        setState((){
          _selectedIndex = index;
        });
  }
  @override
  Widget build(BuildContext context) {
      final appBars = [
    AppBar(title:Text("信息"),backgroundColor: Colors.red[500],),
    AppBar(title:Text("联系人"),backgroundColor: Colors.red[500],actions: <Widget>[popupMenu(context)]),
    null,
    AppBar(title:Text("档案"),backgroundColor: Colors.red[500],)
  ];
       BottomNavigationBar botNavBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('信息')),
        BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/contacts.png")), title: Text('联系人')),
        BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/discovery.png")), title: Text('发现')),
        BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我')),
      ],
      // fixedColor: Colors.green,
      type:BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap:_onItemTapped,
       );
    switch (_selectedIndex) {
      case 0:
        bodyContents[0] = new DialoguesView();
        break;
      case 1:
        bodyContents[1] = new ContactsView();
        break;
      case 2:
        bodyContents[2] = new ActivitiesView();
        break;
      case 3:
        bodyContents[3] = new MyView();
        break;
      default:
    }

    return Scaffold(
      backgroundColor: Colors.red[200],
      appBar:appBars.elementAt(_selectedIndex),
      body:bodyContents.elementAt(_selectedIndex),
      bottomNavigationBar: botNavBar,
    );

    }

    
  }
