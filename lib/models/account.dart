import 'package:sqflite/sqflite.dart';


final String tableAccount = 'account';
final String columnId = 'id';
final String userId = 'userid';
final String columnName = 'name';
final String publicKey = 'publickey';
final String privateKey = 'privatekey';

class Account {
  int id;
  String publickey;
  String privatekey;
  int userid;
  String name;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      publicKey: publickey,
      privateKey: privatekey,
      userId:userid,
      columnName:name
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Account();

  Account.fromMap(Map<String, dynamic> map) {
    id = map[columnId] as int;
    publickey = map[publicKey];
    privatekey = map[privateKey];
    userid = map[userId] as int;
    name = map[columnName];
  }
}
class AccountProvider {
  Database db;
  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        singleInstance: false,
        onOpen: (Database db) async {
      await db.execute('''
create table if not exists $tableAccount ( 
  $columnId integer primary key autoincrement, 
  $publicKey text not null,
  $privateKey text not null,
  $userId integer not null,
  $columnName text)
''');
    });
  }

  Future<Account> insert(Account account) async {
    account.id = await db.insert(tableAccount, account.toMap());
    return account;
  }

  Future<Account> getAccount(int id) async {
    List<Map> maps = await db.query(tableAccount,
        columns: [columnId, publicKey, privateKey, userId, columnName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableAccount, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Account account) async {
    return await db.update(tableAccount, account.toMap(),
        where: '$columnId = ?', whereArgs: [account.id]);
  }

  Future<String> myPrivateKey() async{
    var maps = await db.rawQuery('select privatekey from account limit 1');
    return maps[0]['privatekey'];
  }

  Future<Account> myInfo() async{
    var maps = await db.rawQuery('select id, userid, name, publickey from account limit 1');
    if(maps.length>0){
      return Account.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future close() async => db.close();
}