import 'package:feira_facil/model/Item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class ItemHelper{

 static final String nomeTabela = "item"; 

//Padrão Singleton: Retorna uma única instância do BD

static final ItemHelper _itemHelper = ItemHelper._internal();
Database _db;

factory ItemHelper(){
  return _itemHelper;
}

ItemHelper._internal(){
}

//Acessar DB

get db async {

   if (_db != null) {
      return _db;     
   } else {
       _db = await inicializarBD();
       return _db;
   }

}

_onCreate(Database db, int version) async {

   String sql = "CREATE TABLE $nomeTabela ("
   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
   "nome VARCHAR,"
   "preco DOUBLE," 
   "qtde INT," 
   "total DOUBLE,"
   "data DATETIME,"
   "status INTEGER)";
   
   
   await db.execute(sql);

}


inicializarBD() async {

final caminhoBancoDados = await getDatabasesPath();
final localBancoDados = join (caminhoBancoDados,"banco_compras.db");

var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate );
return db;

}

//Recebe objeto Item classe Item
//Retorna ID do item inserido
Future<int> salvarItem(Item item) async{

  var bancoDados = await db;

 
   //Map da classe item.toMap(). Pois será usado várias vezes
   int resultado = await bancoDados.insert(nomeTabela,item.toMap());
   return resultado;
}



 recuperarItens() async {
    
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List itens = await bancoDados.rawQuery(sql);
    return itens;


 }

Future<int> atualizarItem(Item item) async {

    var bancoDados = await db;
    return await bancoDados.update(
      nomeTabela,
      item.toMap(),
      where: "id = ?",
      whereArgs: [item.id]
    );
 }

//Recebe um int, quantidade de itens removidos
Future<int> removerItem(int id) async{

var bancoDados = await db;
return await bancoDados.delete(
  nomeTabela,
  where: "id =?",
  whereArgs: [id]
);

}



 
} 