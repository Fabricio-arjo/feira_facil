import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Compra.dart';
import 'package:feira_facil/model/Sugestao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final String tabela1 = "compra";
  static final String tabela2 = "item";
  static final String tabela3 = "local_item";
  static final String tabela4 = "carrinho";

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
        "saldo DOUBLE,"
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
        "unidade INTEGER,"
        "sigla VARCHAR,"
        "data DATETIME,"
        "status INTEGER,"
        "carrinho INTEGER,"
        "compra_id INTEGER)";

    await db.execute(sql2);

    String sql3 = "CREATE TABLE $tabela3 ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "nome VARCHAR,"
        "local VARCHAR,"
        "id_compra INTEGER)";

    await db.execute(sql3);

    String sql4 = "CREATE TABLE $tabela4 ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "id_item INTEGER,"
        "id_compra INTEGER)";

    await db.execute(sql4);
  }

  inicializarBD() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco_compras.db");

    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  // ------------------------- Compra ---------------------------------------------
  //Popula banco
  Future<int> compra1(Compra compra) async {
    var bancoDados = await db;
    int resultado = await bancoDados.insert(tabela1, compra.toMap());
    return resultado;
  }

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

  atualizaValorCompra(double novoValor, double somaItem, int idCompra) async {
    var bancoDados = await db;
    await bancoDados.rawUpdate(
        'UPDATE $tabela1 SET valorLimite = ?, saldo= ? WHERE idCompra = ?',
        [novoValor, somaItem, idCompra]);
  }

  Future<int> removerCompra(int id) async {
    var bancoDados = await db;
    return await bancoDados
        .delete(tabela1, where: "idCompra =?", whereArgs: [id]);
  }

  infoCompra(int idCompra) async {
    var bancoDados = await db;
    return await bancoDados.rawQuery(
        'SELECT valorLimite,saldo,finalizada FROM $tabela1 WHERE idCompra = ?',
        [idCompra]);
  }

  finalizaCompra(int compra_id) async {
    var bancoDados = await db;
    await bancoDados.rawUpdate(
        'UPDATE $tabela1 SET finalizada = ? WHERE idCompra = ?',
        [1, compra_id]);
  }

  reabreCompra(int compra_id) async {
    var bancoDados = await db;
    await bancoDados.rawUpdate(
        'UPDATE $tabela1 SET finalizada = ? WHERE idCompra = ?',
        [0, compra_id]);
  }

  //-------------------------------Itens ------------------------------------

  //Popula itens
  Future<int> populaItem(Item item) async {
    var bancoDados = await db;

    //Map da classe item.toMap(). Pois será usado várias vezes
    int resultado = await bancoDados.insert(tabela2, item.toMap());
    return resultado;
  }

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
    return await bancoDados
        .update(tabela2, item.toMap(), where: "id = ?", whereArgs: [item.id]);
  }

//Recebe um int, quantidade de itens removidos
  Future<int> removerItem(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(tabela2, where: "id =?", whereArgs: [id]);
  }

  atualizaStatus() async {
    var bancoDados = await db;
    String sql = "UPDATE $tabela2 SET status='0'";
    await bancoDados.rawQuery(sql);
  }

/*-------------------- Sugestão ----------------------------------------------- */

  salvarSugestao(String nome, String local, int id_compra) async {
    var bancoDados = await db;
    int resultado = await bancoDados.rawInsert(
        'INSERT INTO $tabela3(nome,local,id_compra) VALUES(?,?,?)',
        [nome, local, id_compra]);
    return resultado;
  }

  sugestoes() async {
    var bancoDados = await db;
    List itens = await bancoDados.rawQuery('SELECT * FROM $tabela3');
    return itens;
  }

  /* ------------------------- Carrinho -------------------------------- */

  /* inserirCarrinho(int id_compra, id_item) async {
   
    var bancoDados = await db;
    int resultado = await bancoDados.rawInsert(
      'INSERT INTO $tabela4(id_compra, id_item) VALUES(?,?)', [id_compra, id_item]);
    return resultado;
 
  }

   removerCarrinho(int id_item) async {
    var bancoDados = await db;
    return await bancoDados.delete(tabela4, where: "id_item =?", whereArgs: [id_item]);
  }
  

   Future itensCarrinho()async {
    var bancoDados = await db;
    var qtde =  await bancoDados.rawQuery('SELECT COUNT(*) as total FROM $tabela4');
    return qtde;
   }*/

}
