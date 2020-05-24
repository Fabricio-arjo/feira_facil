import 'dart:ffi';

class Carrinho {
  int id;
  int id_compra;
  int id_item;
  

 Carrinho(this.id_compra, this.id_item);

  Carrinho.fromMap(Map map) {
    this.id = map["id"];
    this.id_compra = map["id_compra"];
    this.id_item = map["id_item"];
    
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "id_compra": this.id_compra,
      "id_item": this.id_item,
     
    };

    if (this.id != null) {
      map["idCompra"] = this.id;
    }

    return map;
  }
}
