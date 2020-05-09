import 'dart:ffi';

class Compra {
  int idDcompra;
  double valorLimite;
  String dataCompra;

  Compra(this.valorLimite, this.dataCompra);

  Compra.fromMap(Map map) {
    this.idDcompra = map["idCompra"];
    this.valorLimite = map["valorLimite"];
    this.dataCompra = map["dataCompra"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "valorLimite": this.valorLimite,
      "dataCompra": this.dataCompra,
    };

    if (this.idDcompra != null) {
      map["idCompra"] = this.idDcompra;
    }

    return map;
  }
}
