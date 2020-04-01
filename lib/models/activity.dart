import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

final String tableActivities = 'activities';
final String columnId = 'id';
final String userId = 'userid';
final String userName = 'username';
final String columnContent = 'content';
final String columnCreated = 'created';


class Activity {
  int id;
  int userid;
  String username;
  String content;
  int created;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      userId: userid,
      userName: username,
      columnContent: content,
      columnCreated: created
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Activity();

  Activity.fromMap(Map<String, dynamic> map) {
    if (map[columnId] != null) {
      id = map[columnId];
    }
    userid = map[userId];
    username = map[userName];
    content = map[columnContent];
    created = map[columnCreated];
  }
}

class ActivityProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
            singleInstance: false,
        onOpen: (Database db) async {
      await db.execute('''
create table if not exists $tableActivities ( 
  $columnId integer primary key autoincrement, 
  $userId integer not null,
  $userName text not null,
  $columnContent text not null,
  $columnCreated integer not null)
''');
    });
  }

  Future<Activity> insert(Activity dialogue) async {
    dialogue.id = await db.insert(tableActivities, dialogue.toMap());
    return dialogue;
  }

  Future<Activity> getActivity(int id) async {
    List<Map> maps = await db.query(tableActivities,
        columns: [columnId, userId, userName, columnContent, columnCreated],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Activity>> getActivities(int userid) async {
    List<Map> maps = await db.query(tableActivities,
        columns: [columnId, userId, userName, columnContent, columnCreated],
        where: '$userId = ?',
        whereArgs: [userid]);
    List<Activity> list = List<Activity>();   
    if (maps.length > 0) {
      maps.forEach((v){list.add(Activity.fromMap(v));});
      return list;
    }
    return null;
  }

  Future<List<Activity>> getRecentActivities() async {
    List<Map> maps = await db.rawQuery('select * from activities order by created desc');
    List<Activity> list = List<Activity>();   
    if (maps.length > 0) {
      maps.forEach((v){list.add(Activity.fromMap(v));});
      return list;
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableActivities, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Activity dialogue) async {
    return await db.update(tableActivities, dialogue.toMap(),
        where: '$columnId = ?', whereArgs: [dialogue.id]);
  }

  Future close() async => db.close();
}