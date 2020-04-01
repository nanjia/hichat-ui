import 'package:sqflite/sqflite.dart';

final String tableDialogues = 'dialogues';
final String columnId = 'id';
final String contactId = 'contact';
final String contactName = 'name';
final String columnIo = 'io';
final String columnContent = 'content';
final String columnCreated = 'created';


class Dialogue {
  int id;
  int contact;
  int io; //0 to me; 1 from me
  String content;
  String name;
  int created;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      contactId: contact,
      columnIo: io,
      columnContent: content,
      columnCreated: created,
      contactName: name,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Dialogue();

  Dialogue.fromMap(Map<String, dynamic> map) {
    if (map[columnId] != null) {
      id = map[columnId];
    }
    contact = map[contactId];
    io = map[columnIo];
    content = map[columnContent];
    created = map[columnCreated];
    name = map[contactName];
  }
}

class DialogueProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
            singleInstance: false,
        onOpen: (Database db) async {
      await db.execute('''
create table if not exists $tableDialogues ( 
  $columnId integer primary key autoincrement, 
  $contactId integer not null,
  $contactName text not null,
  $columnIo integer not null,
  $columnContent text not null,
  $columnCreated integer not null)
''');
      // var num = await db.rawQuery('select count(*) from dialogues');
      // if(num[0][0] == 0){
      //   await db.execute("insert into dialogues(contact, io, userid,name,content) values()");
      // }
    });
  }

  Future<Dialogue> insert(Dialogue dialogue) async {
    dialogue.id = await db.insert(tableDialogues, dialogue.toMap());
    return dialogue;
  }

  Future<Dialogue> getDialogue(int id) async {
    List<Map> maps = await db.query(tableDialogues,
        columns: [columnId, contactId, columnIo, columnContent, columnCreated, contactName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Dialogue.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Dialogue>> getDialogues(int contact) async {
    print(contact);
    List<Map> maps = await db.query(tableDialogues,
        columns: [columnId, contactId, columnIo, columnContent, columnCreated, contactName],
        where: '$contactId = ?',
        whereArgs: [contact]);
    List<Dialogue> list = List<Dialogue>();   
    if (maps.length > 0) {
      maps.forEach((v){list.add(Dialogue.fromMap(v));});
      return list;
    }
    return null;
  }

  Future<List<Dialogue>> getRecentDialogues() async {
    List<Map> maps = await db.rawQuery('select * from (select * from dialogues order by created asc) a group by a.contact');
    print(maps);
    List<Dialogue> list = List<Dialogue>();   
    if (maps.length > 0) {
      print(maps);
      maps.forEach((v){print(v);list.add(Dialogue.fromMap(v));});
      return list;
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableDialogues, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Dialogue dialogue) async {
    return await db.update(tableDialogues, dialogue.toMap(),
        where: '$columnId = ?', whereArgs: [dialogue.id]);
  }

  Future close() async => db.close();
}