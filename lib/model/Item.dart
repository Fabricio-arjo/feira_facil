import 'dart:ffi';

class Item{
 
  int id;
  String nome;
  double preco;
  double qtde;
  double total;
  String local;
  String data;
  bool selected = false;
  int status;
  int carrinho;
  int compra_id;

    
  
    //Objeto item
  
    Item(this.nome, this.preco, this.qtde, this.total, this.local,this.data,this.status,this.carrinho, this.compra_id);
  
    //Receber map e converter para objeto
    Item.fromMap(Map map){
  
      this.id = map["id"];
      this.nome = map["nome"];
      this.preco = map["preco"];
      this.qtde = map["qtde"];
      this.total = map["total"];
      this.local = map["local"];
      this.data = map["data"];
      this.status = map["status"];
      this.carrinho = map["carrinho"];
      this.compra_id = map["compra_id"];
          
  
    }
  
    //Conversão Map to Map
    Map toMap(){
  
        Map<String, dynamic> map = {
        "nome":this.nome,
        "preco":this.preco,
        "qtde":this.qtde,
        "total":this.total,
        "local":this.local,
        "data":this.data,
        "status":this.status,
        "carrinho":this.carrinho,
        "compra_id":this.compra_id,
       
        
        
     };
  
     if(this.id != null){
        map["id"] = this.id;
     }
  
     return map;
  
    }
  
  
  
  }
  
