import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hichat/models/activity.dart';
import 'post.dart';
import '../models/dialogue.dart';
import '../models/contact.dart';
import '../utils.dart';
import 'dart:convert';
import '../global.dart';

class ActivitiesView extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_ActivitiesViewState();
}
enum AppBarBehavior { normal, pinned, floating, snapping }
String something = "据称，近期有两位滴滴的原始股东拟出售股份，其中一位来自中国，一位来自美国，它们分别按400亿和430亿的估值叫价，这与9月底的估值相比，已经砍掉了1/3。但仍然找不到买家。";

class _ActivitiesViewState extends State<ActivitiesView>{
AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;
    final double _appBarHeight = 256.0;
    List activitiesView = [];
    List<Activity> activities = [];

  Widget title = Text(Globals.myInfo.name);
  ScrollController scrollController = ScrollController();
  @override
  void initState(){
    super.initState();
    activities = Globals.recentActivities;
    Globals.bus.on("activity",(activity){
      if (!mounted) {
        return;
      }
      setState(() {
       activities.insert(0,activity); 
      });
    });
    scrollController.addListener((){
      var offset = scrollController.offset;
      if(_appBarHeight-offset<kToolbarHeight){
        setState(() {
          title = Text("动态");
        });
      }else{
        setState(() {
          title = Text("Ali Connors");
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
        for (var activity in activities) {
          File img = File(Globals.avatarPath+activity.userid.toString()+".jpg");

      activitiesView.add(
        Container(
                decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.red[100])),

                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: new BoxDecoration(
                      image: DecorationImage(image: FileImage(img),fit: BoxFit.fitWidth),
                      borderRadius: new BorderRadius.all(
                        const Radius.circular(8.0),
                        ), 
                      ),
                      margin: new EdgeInsets.all(8),),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(6),
                          margin: EdgeInsets.only(top: 8,left: 2,right: 10),
                          child:Column(
                            children: <Widget>[
                              Container(
                                alignment: AlignmentDirectional.topStart,
                                height: 25,
                                child: Text(activity.username),
                              ),
                              Text(activity.content,style: TextStyle(),),
                            ],
                          ),
                            
                          decoration: BoxDecoration(
                            // color: Colors.red[100],
                            // border: Border.all(color: Colors.red[400]),
                            borderRadius: BorderRadius.all(const Radius.circular(8))
                          ),
                        )
                      )
                  ],
                ),
              )
      );
    }
    // TODO: implement build
    return Scaffold(
      // appBar: AppBar(),
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating || _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
            expandedHeight: _appBarHeight,
            flexibleSpace: FlexibleSpaceBar(

                title: title,
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(
                      'images/scape.jpg',
                      fit: BoxFit.cover,
                      height: _appBarHeight,
                    ),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions:<Widget>[   PopupMenuButton<AppBarBehavior>(
                  onSelected: (AppBarBehavior value) {
                    setState(() {
                      _appBarBehavior = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuItem<AppBarBehavior>>[
                    const PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.normal,
                      child: Text('App bar scrolls away'),
                    ),
                    const PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.pinned,
                      child: Text('App bar stays put'),
                    ),
                    const PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.floating,
                      child: Text('App bar floats'),
                    ),
                    const PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.snapping,
                      child: Text('App bar snaps'),
                    ),
                  ],
                ),]
          ),
          SliverList(delegate: SliverChildListDelegate(
           activitiesView
          ),)
        ],
      ),
      backgroundColor: Colors.red[50],
      // body: ListView.builder(
      //      physics: new NeverScrollableScrollPhysics(),
      //     shrinkWrap: true,
      //     itemCount: 2,
      //     itemBuilder: (context, i){
      //       return _buildRow();
      //     },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{
          Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return PostView();
              },
            ))
        },
        tooltip: 'Increment',
        child: Icon(Icons.photo_camera),
      ), 
      // bottomNavigationBar: BottomNavBar(),
    );
  }
}