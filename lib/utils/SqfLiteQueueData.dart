// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:sqflite/sqflite.dart';
final _version = 1;//数据库版本号
final _databaseName = "landy.db";//数据库名称
final _tableName = "inventory";//表名称
final _tableId = "id";//主键
final _tableTitle = "fid";//fid
final _tableMaterialName = "materialName";
final _tableMaterialNumber = "materialNumber";
final _tableSpecification = "specification";
final _tableUnitName = "unitName";
final _tableUnitNumber = "unitNumber";
final _tableRealQty = "realQty";
final _tableCountQty = "countQty";
final _tableStockName = "stockName";
final _tableStockNumber = "stockNumber";
final _tableOwnerid = "ownerid";
final _tableStockStatusId = "stockStatusId";
final _tableKeeperTypeId = "keeperTypeId";
final _tableKeeperId = "keeperId";
final _tableEntryID = "entryID";
class SqfLiteQueueData{
  SqfLiteQueueData.internal();
  //数据库句柄
  late Database _database;
  Future<Database> get database async {
    String path = await getDatabasesPath() + "/$_databaseName";
    _database = await openDatabase(path, version: _version,
      onConfigure: (Database db){
        print("数据库创建前、降级前、升级前调用");
      },
      onDowngrade: (Database db, int version, int x){
        print("降级时调用");
      },
      onUpgrade: (Database db, int version, int x){
        print("升级时调用");
      },
      onCreate: (Database db, int version) async {
        print("创建时调用");
      },
      onOpen: (Database db) async {
        print("重新打开时调用");
        await _createTable(db, '''create table if not exists $_tableName ($_tableId integer primary key,$_tableTitle text,$_tableMaterialName text,$_tableMaterialNumber text,$_tableSpecification text,$_tableUnitName text,$_tableUnitNumber text,$_tableRealQty INTEGER,$_tableCountQty text,$_tableStockName text,$_tableStockNumber text,$_tableOwnerid text,$_tableStockStatusId text,$_tableKeeperTypeId text,$_tableKeeperId text,$_tableEntryID text)''');
      },
    );
    return _database;
  }

  /// 创建表
  Future<void> _createTable(Database db, String sql) async{
    var batch = db.batch();
    batch.execute(sql);
    await batch.commit();
  }

  /// 添加数据
  static Future insertData(String title, int num) async{
    Database db = await SqfLiteQueueData.internal().open();
    //1、普通添加
    //await db.rawDelete("insert or replace into $_tableName ($_tableId,$_tableTitle,$_tableRealQty) values (null,?,?)",[title, num]);
    //2、事务添加
    db.transaction((txn) async{
      await txn.rawInsert("insert or replace into $_tableName ($_tableId,$_tableTitle,$_tableRealQty) values (null,?,?)",[title, num]);
    });
    await db.batch().commit();

    await SqfLiteQueueData.internal().close();
  }

  /// 根据id删除该条记录
  static Future deleteData(int id) async{
    Database db = await SqfLiteQueueData.internal().open();
    //1、普通删除
    //await db.rawDelete("delete from _tableName where _tableId = ?",[id]);
    //2、事务删除
    db.transaction((txn) async{
      txn.rawDelete("delete from $_tableName where $_tableId = ?",[id]);
    });
    await db.batch().commit();

    await SqfLiteQueueData.internal().close();
  }

  /// 根据id更新该条记录
  static Future updateData(int id,String title, int num) async{
    Database db = await SqfLiteQueueData.internal().open();
    //1、普通更新
    // await db.rawUpdate("update $_tableName set $_tableTitle =  ?,$_tableRealQty =  ? where $_tableId = ?",[title,num,id]);
    //2、事务更新
    db.transaction((txn) async{
      txn.rawUpdate("update $_tableName set $_tableTitle =  ?,$_tableRealQty =  ? where $_tableId = ?",[title,num,id]);
    });
    await db.batch().commit();

    await SqfLiteQueueData.internal().close();
  }

  /// 查询所有数据
  static Future<List<Map<String, dynamic>>> searchDates() async {
    Database db = await SqfLiteQueueData.internal().open();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $_tableName");
    print(maps);

    await SqfLiteQueueData.internal().close();
    return maps;
  }

  //打开
  Future<Database> open() async{
    return await database;
  }

  ///关闭
  Future<void> close() async {
    var db = await database;
    return db.close();
  }

  ///删除数据库表
  static Future<void> deleteDataTable() async {
    Database db = await SqfLiteQueueData.internal().open();
    //1、普通删除
    //await db.rawDelete("drop table $_tableName");
    //2、事务删除
    db.transaction((txn) async{
      txn.rawDelete("drop table $_tableName");
    });
    await db.batch().commit();

    await SqfLiteQueueData.internal().close();
  }

  ///删除数据库文件
  static Future<void> deleteDataBaseFile() async {
    await SqfLiteQueueData.internal().close();
    String path = await getDatabasesPath() + "/$_databaseName";
    File file = new File(path);
    if(await file.exists()){
      file.delete();
    }
  }
}
