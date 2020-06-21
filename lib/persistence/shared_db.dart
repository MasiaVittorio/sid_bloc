import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

const String _TABLE = "shared_db";
const String _COLUMN_VALUE = 'value';
final String _createTable = '''
    CREATE TABLE $_TABLE ( 
      id integer primary key autoincrement, 
      key text UNIQUE not null,
      $_COLUMN_VALUE text);
    CREATE UNIQUE INDEX idx_${_TABLE}_id ON $_TABLE (id);
    CREATE UNIQUE INDEX idx_${_TABLE}_key ON $_TABLE (key);
    ''';

const String _NAME = "shared.db";


///A class that can be used just like shared preferences, but it 
///uses a sqlite database under the hood.
///You call [final instance = await SharedDb.getInstance()]
///and the you can go like [instance.getString(key)] or even
///[instance.setString(key,value)] but just with strings. 
class SharedDb {
  //Singleton pattern
  static SharedDb _instance;
  SharedDb._(this.db);
  final sqflite.Database db;

  static Future<sqflite.Database> _db;

  static Future<SharedDb> getInstance() async{

    //make sure they all await the same future
    if(_db == null && _instance == null){
      _db = _getDb();
    }

    //if the future is there, await for it
    //and then delete it
    if(_db != null){

      final sqflite.Database _d = await _db;
      _db = null;

      //with the database obtained (the same for every call of getInstance)
      //create the SharedDb instance but only one time
      if(_instance == null){
        _instance = SharedDb._(_d);
      }
    }

    return _instance;

  }

  static Future<String> _getPath() async {
    final databasesPath = await sqflite.getDatabasesPath();
    return path.join(databasesPath, _NAME);
  }

  static Future<sqflite.Database> _getDb() async {
    try {

      final String path = await _getPath();

      sqflite.Database result = await sqflite.openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // When creating the db, create the table
          await db.execute(_createTable);
          await db.execute('PRAGMA case_sensitive_like = true');
        }
      );

      //non so perché, copiato da frideos
      await result.execute('PRAGMA case_sensitive_like = true');

      return result;

    } catch (e) {

      print(e);
      return null;

    }
  }

  Future<String> getString(String key) async {
    assert(key != null);

    String valueString;
    final query = 'SELECT * FROM $_TABLE WHERE key = ?';

    try {
      final queryResult = await this.db.rawQuery(query, [key]);

      if (queryResult.isNotEmpty) {
        valueString = queryResult.first['$_COLUMN_VALUE'];
      }
    } catch (e) {
      print(e);
    }

    return valueString;
  }

  Future<bool> setString(String key, String value) async {
    assert(key != null);

    try {
      
      int changes = await this.db.rawUpdate(
        'UPDATE $_TABLE SET value = ? WHERE key = ?',
        [value,key]
      );
      if(changes == 0)
        await this.db.execute(
          '''
          INSERT INTO $_TABLE (key, $_COLUMN_VALUE) 
          VALUES  (?, ?); 
          ''', 
          [key, value]
        );

      return true;
    } catch (e) {
      // print(e);
    }

    return false;
  }

  Future<int> deleteByKey(String key) async {
    assert(key != null);

    try {
      return await this.db.delete(_TABLE, where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      print(e);
      return -1;
    }
  }
}