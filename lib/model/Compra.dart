import 'dart:ffi';

class Compra {
  int idDcompra;
  double valorLimite;
  int finalizada;
  String dataCompra;

  Compra(this.valorLimite, this.finalizada, this.dataCompra);

  Compra.fromMap(Map map) {
    this.idDcompra = map["idCompra"];
    this.valorLimite = map["valorLimite"];
    this.finalizada = map["finalizada"];
    this.dataCompra = map["dataCompra"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "valorLimite": this.valorLimite,
      "finalizada": this.finalizada,
      "dataCompra": this.dataCompra,
    };

    if (this.idDcompra != null) {
      map["idCompra"] = this.idDcompra;
    }

    return map;
  }
}
