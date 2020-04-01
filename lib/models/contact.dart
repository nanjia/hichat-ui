import 'package:sqflite/sqflite.dart';

final String tableContacts = 'contacts';
final String columnId = 'id';
final String userId = 'userid';
final String columnName = 'name';
final String publicKey = 'publickey';
final String negKey = 'negkey';
final String memo = 'memo';

class Contact {
  int id;
  int userid;
  String name;
  String publickey;
  String negkey;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      publicKey: publickey,
      userId:userid,
      columnName:name,
      negKey:negkey
    };
    if (id != null) {
      map[columnId] = id;
    }
    print('map:');
    print(map);
    return map;
  }

  Contact();

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    publickey = map[publicKey];
    userid = map[userId];
    name = map[columnName];
    negkey = map[negKey];
  }
}

class ContactProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
            singleInstance: false,
        onOpen: (Database db) async {
      await db.execute('''
create table if not exists $tableContacts ( 
  $columnId integer primary key autoincrement, 
  $publicKey text not null,
  $negKey text not null,
  $userId integer not null,
  $columnName text not null)
''');

      // var num = await db.rawQuery('select count(*) from contacts');
      // if(num[0][0] == 0){
      //   await db.execute("insert into contacts(publickey, negkey, userid,name) values()");
      // }
    });
  }

  Future<Contact> insert(Contact contact) async {
    contact.id = await db.insert(tableContacts, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    List<Map> maps = await db.query(tableContacts,
        columns: [columnId, publicKey, negKey, userId, columnName],
        where: '$userId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }
  // Future<String> getNegKey(int contact) async {
  //   List<Map> maps = await db.query(tableContacts,
  //       columns: [negKey],
  //       where: '$userId = ?',
  //       whereArgs: [contact]);
  //   if (maps.length > 0) {
  //     return maps.first['negkey'];
  //   }
  //   return null;
  // }

  Future<List<Contact>> getContacts() async {
    List<Map> maps = await db.query(tableContacts,
        columns: [columnId, columnName, userId, publicKey, negKey],
        );
    List<Contact> list = List<Contact>();   
    if (maps.length > 0) {
      maps.forEach((v){list.add(Contact.fromMap(v));});
      return list;
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableContacts, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Contact contact) async {
    return await db.update(tableContacts, contact.toMap(),
        where: '$columnId = ?', whereArgs: [contact.id]);
  }

  Future close() async => db.close();
}