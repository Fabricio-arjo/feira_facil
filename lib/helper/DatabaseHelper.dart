import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Compra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final String nomeTabela1 = "compra";
  static final String nomeTabela2 = "item";

  static final DatabaseHelper _databaseHelper = DatabaseHelper._iternal();
  Database _db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._iternal(){}

  get db async{
      if (_db != null) {
          return _db;         
       } else {
          _db = await inicializarBD();
          return _db;
       }
  }

   _onCreate(Database db, int version) async {

      String sql1 = "CREATE TABLE $nomeTabela1 ("
      "idCompra INTEGER PRIMARY KEY AUTOINCREMENT,"
      "valorLimite DOUBLE,"
      "dataCompra DATETIME)";
       
       await db.execute(sql1);
       
       String sql2 = "CREATE TABLE $nomeTabela2 ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "nome VARCHAR,"
        "preco DOUBLE,"
        "qtde INT,"
        "total DOUBLE,"
        "local,"
        "data DATETIME,"
        "status INTEGER,"
        "compra_id INTEGER)";

        await db.execute(sql2);
     }
     


  inicializarBD() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco_compras.db");

    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  // ------------------------- Compra ---------------------------------------------

   Future <int> salvarCompra(Compra compra) async {
       var bancoDados = await db;

       int resultado = await bancoDados.insert(nomeTabela1, compra.toMap());
       return resultado;   
   }


      recuperaCompra() async {
      
      var bancoDados = await db;
      String sql = "SELECT * FROM $nomeTabela1 ORDER BY dataCompra DESC";
      List compra = await bancoDados.rawQuery(sql);
      return compra;

   }

       atualizaValorCompra(double novoValor, int idCompra) async{
       var bancoDados = await db;
       await bancoDados.rawUpdate('UPDATE $nomeTabela1 SET valorLimite = ? WHERE idCompra = ?',[novoValor, idCompra]);
   
   }

    Future<int> removerCompra(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(nomeTabela1, where: "idCompra =?", whereArgs: [id]);
  }



   //-------------------------------Itens ------------------------------------

   Future<int> salvarItem(Item item) async {
    var bancoDados = await db;

    //Map da classe item.toMap(). Pois será usado várias vezes
    int resultado = await bancoDados.insert(nomeTabela2, item.toMap());
    return resultado;
  }

  recuperarItens(int id) async {
    
    var bancoDados = await db;

    //String sql = "SELECT * FROM $nomeTabela2 ORDER BY data DESC";
    //List itens = await bancoDados.rawQuery(sql);

    List itens = await bancoDados.rawQuery('SELECT * FROM $nomeTabela1 c INNER JOIN $nomeTabela2 i ON c.idCompra = i.compra_id WHERE idCompra = ?', [id]);
    
    return itens;

  }



  Future<int> atualizarItem(Item item) async {
    var bancoDados = await db;
    return await bancoDados.update(nomeTabela2, item.toMap(), where: "id = ?", whereArgs: [item.id]);
  }

//Recebe um int, quantidade de itens removidos
  Future<int> removerItem(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(nomeTabela2, where: "id =?", whereArgs: [id]);
  }


   atualizaStatus() async {
    var bancoDados = await db;
    
    String sql = "UPDATE $nomeTabela2 SET status='0'";
    await bancoDados.rawQuery(sql);
    
  }



}
