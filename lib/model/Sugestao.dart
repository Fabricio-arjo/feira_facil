import 'dart:ffi';

class Sugestao{
 

  int id;
  String nome;
  String local;
  int id_compra;
  
      
    //Objeto item
  
    Sugestao(this.nome, this.local);
  
    //Receber map e converter para objeto
    Sugestao.fromMap(Map map){
  
      this.id = map["id"];
      this.nome = map["nome"];
      this.local = map["local"]; 
      this.id_compra = map["id_compra"];
      
          
  
    }
  
    //Conversão Map to Map
    Map toMap(){
  
        Map<String, dynamic> map = {
        "nome":this.nome,
        "preco":this.local,
        "id_compra":this.id_compra,
                
     };
  
     if(this.id != null){
        map["id"] = this.id;
     }
  
     return map;
  
    }
    
  
  }
  
