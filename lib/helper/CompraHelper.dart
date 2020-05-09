
import 'package:feira_facil/model/Compra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class CompraHelper{
  
    static final String nomeTabela = "compra";

    static final CompraHelper _compraHelper = CompraHelper._internal();
    Database _db;

    factory CompraHelper(){
       return _compraHelper;
    }

    CompraHelper._internal(){}

    get db async{
       if (_db != null) {
          return _db;         
       } else {
          _db = await inicializarBD();
          return _db;
       }
    }

    _onCreate(Database db, int version) async {

      String sql = "CREATE TABLE $nomeTabela ("
      "idCompra INTEGER PRIMARY KEY AUTOINCREMENT,"
      "valorLimite DOUBLE,"
      "dataCompra DATETIME)";
      
      await db.execute(sql);
    }

    inicializarBD() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco_compras.db");

    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  
    
    Future <int> salvarCompra(Compra compra) async {
       var bancoDados = await db;

       int resultado = await bancoDados.insert(nomeTabela, compra.toMap());
       return resultado;   
   }

   recuperaCompra() async {
      
      var bancoDados = await db;
      String sql = "SELECT * FROM $nomeTabela ORDER BY dataCompra DESC";
      List compra = await bancoDados.rawQuery(sql);
      return compra;

   }


}

