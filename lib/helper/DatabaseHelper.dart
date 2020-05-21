import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Compra.dart';
import 'package:feira_facil/model/Sugestao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {

  static final String tabela1 = "compra";
  static final String tabela2 = "item";
  static final String tabela3 = "sugestao";


  static final DatabaseHelper _databaseHelper = DatabaseHelper._iternal();
  Database _db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._iternal() {}

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarBD();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql1 = "CREATE TABLE $tabela1 ("
        "idCompra INTEGER PRIMARY KEY AUTOINCREMENT,"
        "valorLimite DOUBLE,"
        "finalizada INTEGER,"
        "dataCompra DATETIME)";

    await db.execute(sql1);

    String sql2 = "CREATE TABLE $tabela2 ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "nome VARCHAR,"
        "preco DOUBLE,"
        "qtde  DOUBLE,"
        "total DOUBLE,"
        "local VARCHAR,"
        "data DATETIME,"
        "status INTEGER,"
        "compra_id INTEGER)";

    await db.execute(sql2);

    String sql3 = "CREATE TABLE $tabela3 ("
        
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "nome VARCHAR,"
        "local VARCHAR)";
       

    await db.execute(sql3);
  }

  inicializarBD() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco_compras.db");

    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  // ------------------------- Compra ---------------------------------------------

  Future<int> salvarCompra(Compra compra) async {
    var bancoDados = await db;

    int resultado = await bancoDados.insert(tabela1, compra.toMap());
    return resultado;
  }

  recuperaCompra() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $tabela1 ORDER BY dataCompra DESC";
    List compra = await bancoDados.rawQuery(sql);
    return compra;
  }

  atualizaValorCompra(double novoValor, int idCompra) async {
    var bancoDados = await db;
    await bancoDados.rawUpdate(
        'UPDATE $tabela1 SET valorLimite = ? WHERE idCompra = ?',
        [novoValor, idCompra]);
  }

  Future<int> removerCompra(int id) async {
    var bancoDados = await db;
    return await bancoDados
        .delete(tabela1, where: "idCompra =?", whereArgs: [id]);
  }

 
  idCompra() async {

    var bancoDados = await db;
    String sql = "SELECT last_insert_rowid()$tabela1";
    var res = await bancoDados.rawQuery(sql);
    return res;
    
  }  

  
  //-------------------------------Itens ------------------------------------

  Future<int> salvarItem(Item item) async {
    var bancoDados = await db;

    //Map da classe item.toMap(). Pois será usado várias vezes
    int resultado = await bancoDados.insert(tabela2, item.toMap());
    return resultado;
  }

  recuperarItens(int id) async {
    var bancoDados = await db;

    //String sql = "SELECT * FROM $tabela2 ORDER BY data DESC";
    //List itens = await bancoDados.rawQuery(sql);

    List itens = await bancoDados.rawQuery(
        'SELECT * FROM $tabela1 c INNER JOIN $tabela2 i ON c.idCompra = i.compra_id WHERE idCompra = ?',
        [id]);

    return itens;
  }

  Future<int> atualizarItem(Item item) async {
    var bancoDados = await db;
    return await bancoDados.update(tabela2, item.toMap(),
        where: "id = ?", whereArgs: [item.id]);
  }

//Recebe um int, quantidade de itens removidos
  Future<int> removerItem(int id) async {
    var bancoDados = await db;
    return await bancoDados
        .delete(tabela2, where: "id =?", whereArgs: [id]);
  }

  atualizaStatus() async {
    var bancoDados = await db;
    String sql = "UPDATE $tabela2 SET status='0'";
    await bancoDados.rawQuery(sql);
  }

/*-------------------- Sugestão ----------------------------------------------- */


salvarSugestao(String nome, String local) async {
   
    var bancoDados = await db;
    int resultado = await bancoDados.rawInsert(
      'INSERT INTO $tabela3(nome,local) VALUES(?,?)',[nome,local]);
    return resultado;
 
  }


  sugestoes() async {
    var bancoDados = await db;
    List itens = await bancoDados.rawQuery('SELECT * FROM $tabela3');
    return itens;
  }


  


}




