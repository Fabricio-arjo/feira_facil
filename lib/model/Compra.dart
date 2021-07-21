class Compra {
  int idDcompra;
  double valorLimite;
  double saldo;
  int finalizada;
  String dataCompra;

  Compra(this.valorLimite, this.saldo, this.finalizada, this.dataCompra);

  Compra.fromMap(Map map) {
    this.idDcompra = map["idCompra"];
    this.valorLimite = map["valorLimite"];
    this.saldo = map["saldo"];
    this.finalizada = map["finalizada"];
    this.dataCompra = map["dataCompra"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "valorLimite": this.valorLimite,
      "saldo": this.saldo,
      "finalizada": this.finalizada,
      "dataCompra": this.dataCompra,
    };

    if (this.idDcompra != null) {
      map["idCompra"] = this.idDcompra;
    }

    return map;
  }
}
