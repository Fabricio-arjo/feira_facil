import 'package:flutter/material.dart' hide Colors;
import 'dart:developer';
import 'package:feira_facil/helper/DatabaseHelper.dart';
import 'package:feira_facil/model/Compra.dart';
import 'package:feira_facil/CarrinhoCompra.dart';
import 'package:feira_facil/model/Item.dart';
import 'package:flutter/material.dart';
//import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:feira_facil/helper/CompraHelper.dart';
import 'ListaCompras.dart';
import 'package:flutter_masked_text/flutter_masked_text.Dart';

class AdicionarCompra extends StatefulWidget {
  @override
  _AdicionarCompraState createState() => _AdicionarCompraState();
}

class _AdicionarCompraState extends State<AdicionarCompra> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MoneyMaskedTextController valorController =
      MoneyMaskedTextController(thousandSeparator: "", decimalSeparator: ",");

  double limite, saldo = 0;
  int finalizada = 0;
  var _db = DatabaseHelper();
  String prefix = "R\$";
  String _validate = "";

  _snackBar() {
    final snackbar = SnackBar(
      //backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text(
        "Informe um valor diferente de zero.",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );

    Scaffold.of(context).showSnackBar(snackbar);
    return snackbar;
  }

  _salvarCompra() async {
    setState(() {
      limite = double.parse(valorController.text.replaceAll(",", "."));
    });

    if (limite != 0) {
      Compra compra =
          Compra(limite, saldo, finalizada, DateTime.now().toString());
      int resultado = await _db.salvarCompra(compra);

      valorController.clear();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CarrinhoCompra(
                    id_compra: resultado,
                  )));
    } else {
      _snackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Image.asset(
                    "images/logo.png",
                    width: 142,
                    height: 142,
                  ),
                ),
                Center(
                  child: Text(
                    "Defina um valor",
                    style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(60, 50, 60, 30),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    controller: valorController,

                    /*validator: (value) {
                    if (value.isEmpty) {
                          return "Informe o limite a ser gasto.";
                      }
                    },*/

                    decoration: InputDecoration(
                      //labelText: "Limite",
                      labelStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                      ),
                      //hintText: "0.00",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      prefixIcon: Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                      /*prefixText: prefix,
                            prefixStyle: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)*/
                    ),
                  ),
                ),

                //Text(_validate, style: TextStyle(color: Colors.red), textAlign: TextAlign.center,),

                Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: RaisedButton.icon(
                      color: Colors.lightGreen,
                      onPressed: () {
                        /*if (_formKey.currentState.validate()) {*/
                        //limiteGasto();
                        _salvarCompra();
                        /*}*/
                      },
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(""),
                    )),
              ],
            )),
      ),
      bottomNavigationBar: BottomAppBar(
        //color: Colors.purple,
        elevation: 20.0,
        child: IconButton(
            icon: Icon(
              Icons.help,
              size: 25,
              color: Colors.purple,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Help",
                        style: TextStyle(color: Colors.purple),
                      ),
                      content: Text(
                        "Aqui você informa o valor máximo que deseja gastar. Após adicionar itens ao seu carrinho o valor de cada produto será deduzido do valor aqui informado. Permitindo assim, que você não ultrapasse o valor disponível para compra.",
                        textAlign: TextAlign.justify,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok"),
                        ),
                      ],
                    );
                  });
            }),
      ),
    );
  }
}
