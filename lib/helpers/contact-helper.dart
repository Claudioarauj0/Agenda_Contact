import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String phoneColumn = "phoneColumn";
const String emailColumn = "emailColumn";
const String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper._internal();

  factory ContactHelper() => _instance;

  ContactHelper._internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    var databaseFactory = databaseFactoryFfi;

    final databasesPath = await databaseFactory.getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
                "CREATE TABLE IF NOT EXISTS $contactTable($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
          },
        ));
  }

  Future<Contact> saveContact(Contact contact) async {
    //salvar o contato
    Database? dbContact = await db;
    contact.id = await dbContact?.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    //obter dados do contato atraves do id
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    //deletar o contato
    Database? dbContact = await db;
    return await dbContact!
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    //atualizar os contatos
    Database? dbContact = await db;
    return await dbContact!.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database? dbContact = await db;
    List<Map<String, dynamic>> listMap =
        await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map<String, dynamic> m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //fecha o banco de dados
  Future close() async {
    Database? dbContact = await db;
    dbContact!.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, phone: $phone, email: $email, img: $img)";
  }
}
