import 'dart:ffi';

class Item{
 

  int id;
  String nome;
  double preco;
  int qtde;
  double total;
  String data;
  bool selected = false;
  int status;
  

  //Objeto item

  Item(this.nome, this.preco, this.qtde, this.total,this.data,this.status);

  //Receber map e converter para objeto
  Item.fromMap(Map map){

    this.id = map["id"];
    this.nome = map["nome"];
    this.preco = map["preco"];
    this.qtde = map["qtde"];
    this.total = map["total"];
    this.status = map["status"];
    
        

  }

  //Conversão Map to Map
  Map toMap(){

      Map<String, dynamic> map = {
      "nome":this.nome,
      "preco":this.preco,
      "qtde":this.qtde,
      "total":this.total,
      "data":this.data,
      "status":this.status,
     
      
      
   };

   if(this.id != null){
      map["id"] = this.id;
   }

   return map;

  }



}