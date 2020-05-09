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

    //print("Lista itens: " + comprasRealizadas.toString());
  }

  @override
  Widget build(BuildContext context) {
    _recuperaCompras();

    return Scaffold(
      appBar: AppBar(
        title: Text("Purchases"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
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
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        print("direcao: endToStart ");
                      } else if (direction == DismissDirection.startToEnd) {
                        print("direcao: startToEnd ");
                      }

                      setState(() {
                        // _itens.removeAt(index);
                      });
                    },

                    key: Key(compra.idDcompra.toString()),

                    child: GestureDetector(

                      child:Card(

                         color: Colors.grey[100],
                         elevation: 3.0,

                          child: ListTile(

                            title: Text(
                                "Valor: " + compra.valorLimite.toStringAsFixed(2)),
                            subtitle:
                                Text(" Data: " + _formatarData(compra.dataCompra)),
                            trailing: Icon(Icons.add_shopping_cart),
                            
                            onTap: (){  
                                Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CarrinhoCompra(
                                              valor: compra.valorLimite,
                                              id_compra: compra.idDcompra)));
                            },
                      ),
                    )
                  )
                );
                }
              ),
          )
        ],
      ),
    );
  }
}
