import 'package:feira_facil/model/Item.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'helper/CompraHelper.dart';
import 'CarrinhoCompra.dart';
import 'model/Compra.dart';
import 'package:intl/intl.dart';
import 'package:feira_facil/helper/DatabaseHelper.dart';

class ListaCompras extends StatefulWidget {
  @override
  _ListaComprasState createState() => _ListaComprasState();
}

class _ListaComprasState extends State<ListaCompras> {
  List<Compra> _itens = List<Compra>();

  TextEditingController _valorController = TextEditingController();
  double novoValor,saldoCompra;

  var _db = DatabaseHelper();

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    //Year -> y month-> M Day -> d
    //Hour -> H minute -> m second -> s
    //var formatador = DateFormat("d / MMMM / y H:m:s");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _exibirTelaEdicao(Compra compra) {
    _valorController.text = compra.valorLimite.toStringAsFixed(2);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Atualizar Valor",
                style: TextStyle(
                  color: Colors.purple,
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  height: 100,
                  child: TextField(
                    controller: _valorController,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Limite",
                      //hintText: compra.valorLimite.toString()
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    _atualizaValorCompra(
                        double.parse(_valorController.text), compra.idDcompra);
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.check)),
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Icon(Icons.close)),
            ],
          );
        });
  }

  _atualizaValorCompra(double novoValor, int id) async {
    List itensCompra = await _db.recuperarItens(id);

    for (var i in itensCompra) {
      Item item = Item.fromMap(i);
      if (item.status == 1) {
        setState(() {
          novoValor -= item.total;
          saldoCompra += item.total;
        });
      }
    }
    await _db.atualizaValorCompra(novoValor, saldoCompra , id);
  }

  _recuperaCompras() async {
    List comprasRealizadas = await _db.recuperaCompra();

    //Guardar dentro do for na lista temporaria
    List<Compra> listaTemporaria = List<Compra>();

    for (var comp in comprasRealizadas) {
      Compra compra = Compra.fromMap(comp);

      listaTemporaria.add(compra);
    }
    setState(() {
      _itens = listaTemporaria;
    });

    listaTemporaria = null;

    //print("Lista compras: " + comprasRealizadas.toString());
  }

  _removerCompra(int id) async {
    await _db.removerCompra(id);
  }

  _snackBar() {
    final snackbar = SnackBar(
      //backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
      content: Text(
        "Item removido",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );

    Scaffold.of(context).showSnackBar(snackbar);
    return snackbar;
  }

  @override
  Widget build(BuildContext context) {
   
    _recuperaCompras();

    return Scaffold(
      /*appBar: AppBar(
        title: Text("Purchases"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),*/

      body: Column(
        children: <Widget>[
          Expanded(
              child: _itens.length != 0
                  ? ListView.builder(
                      itemCount: _itens.length,
                      itemBuilder: (context, index) {
                        final compra = _itens[index];

                        return Dismissible(
                            background: Container(
                              color: Colors.green,
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),

                            //direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Excluir"),
                                        content: Text("Confirmar exclusão ?"),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              _removerCompra(compra.idDcompra);
                                              Navigator.pop(context);
                                              _snackBar();
                                            },
                                            child: Icon(Icons.check),
                                          ),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Icon(Icons.close))
                                        ],
                                      );
                                    });
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                _exibirTelaEdicao(compra);
                              }
                            },
                            key: Key(compra.idDcompra.toString()),
                            child: GestureDetector(
                                child: Card(
                              color: Colors.grey[100],
                              elevation: 3.0,
                              child: ListTile(
                                title: Text("Valor: " +
                                    compra.valorLimite.toStringAsFixed(2)),
                                subtitle: Text(" Data: " +
                                    _formatarData(compra.dataCompra)),
                                trailing: Icon(
                                  Icons.shopping_basket,
                                  size: 30,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CarrinhoCompra(
                                              valor: compra.valorLimite,
                                              id_compra: compra.idDcompra)));
                                },
                              ),
                            )));
                      })
                  : Center(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Nenhum registro encontrado.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    )))
        ],
      ),
    );
  }
}
