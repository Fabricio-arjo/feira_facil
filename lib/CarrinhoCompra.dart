import 'dart:developer';
import 'package:feira_facil/model/Item.dart';
import 'package:flutter/material.dart';
//import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ListaCompras.dart';
import 'package:feira_facil/helper/DatabaseHelper.dart';

import 'model/Compra.dart';

class CarrinhoCompra extends StatefulWidget {
  CarrinhoCompra({this.valor, this.id_compra});
  final double valor;
  final int id_compra;

  @override
  _CarrinhoCompraState createState() => _CarrinhoCompraState(this.valor, this.id_compra);
}

class _CarrinhoCompraState extends State<CarrinhoCompra> {
  _CarrinhoCompraState(this.valor,this.id_compra);
 
  double valor;
  int id_compra;

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _precoController = TextEditingController();
  TextEditingController _qtdeController = TextEditingController();
  TextEditingController _localController = TextEditingController();

  var _db = DatabaseHelper();

  double _saldo;

  //Lista para recuperar itens
  List<Item> _itens = List<Item>();

 
// Parâmetro opcional se existir item é uma edição
  _exibirTelaCadastro({Item item}) {
    String textoSalvarAtualizar = "";
    if (item == null) {
      //Salvando

      _nomeController.text = "";
      _precoController.text = "";
      _qtdeController.text = "";
      _localController.text="";

      textoSalvarAtualizar = "Adicionar";
    } else {
      //Atualizando

      _nomeController.text = item.nome;
      _precoController.text = item.preco.toString();
      _qtdeController.text = item.qtde.toString();
      _localController.text = item.local.toString();

      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(textoSalvarAtualizar +" Item",
              style: TextStyle(color:Colors.purple,
             )
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
                          
              children: <Widget>[
                         
                Container(
                  padding: EdgeInsets.all(5),
                  height: 55,
                  child: TextField(
                    controller: _nomeController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nome",
                        hintText: "Ex: Arroz"),
                  ),
                ),

               //Divider(),

               Row(
                   
                   children: <Widget>[

                     Container(
                          padding: EdgeInsets.all(5),
                          width: 120,
                          height: 55,
                          child: TextField(
                            controller: _precoController,
                            //autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Preço",
                                hintText: "Ex: 8.50"),
                          ),
                      ),

                            //Divider(),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: 110,
                        height: 55,
                        child: TextField(
                          controller: _qtdeController,
                          keyboardType: TextInputType.number,
                          //autofocus: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Qtde",
                              hintText: "Ex: 1"),
                        ),
                      ),
                     
                   ],

               ),

               Container(
                  padding: EdgeInsets.all(5),
                  height: 55,
                  child: TextField(
                    controller: _localController,
                    keyboardType: TextInputType.text,
                    //autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Local",
                        hintText: "Ex: Estabelecimento"),
                  ),
                )
                          
              ],
                
            ),

            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    _salvarAtualizarItem(itemSelecionado: item);
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


  _recuperarItens(int id_compra) async {
          
   
    List itensRecuperados = await _db.recuperarItens(id_compra);

    //Guardar dentro do for na lista temporaria
    List<Item> listaTemporaria = List<Item>();

    for (var itm in itensRecuperados) {
      Item item = Item.fromMap(itm);

      listaTemporaria.add(item);
    }
    setState(() {
      _itens = listaTemporaria;
    });

    listaTemporaria = null;

    print("Lista itens: " + itensRecuperados.toString());
    print("Compra ID: " +id_compra.toString());
    
  }

  _salvarAtualizarItem({Item itemSelecionado}) async {

    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text);
    int qtde = int.parse(_qtdeController.text);
    double total = preco * qtde;
    String local = _localController.text;
    int status;
    int compra_id = id_compra; 

    if (itemSelecionado == null) {
      //Salvando

      //Objeto da classe item
      Item item = Item(nome, preco, qtde, total,local,DateTime.now().toString(), status, compra_id);
      int resultado = await _db.salvarItem(item);

        

    } else {
      //Atualizar

      itemSelecionado.nome = nome;
      itemSelecionado.preco = preco;
      itemSelecionado.qtde = qtde;
      itemSelecionado.total = total;
      itemSelecionado.local = local;
      itemSelecionado.data = DateTime.now().toString();

      //Método do Item Helper
      int resultado = await _db.atualizarItem(itemSelecionado);
    }

    _nomeController.clear();
    _precoController.clear();
    _qtdeController.clear();
    _localController.clear();


    _recuperarItens(id_compra);
  }
  

  _atualizaStatus(Item itemEscolhido, bool selecionado) async {

    if (selecionado == true && itemEscolhido.status != 1) {
      itemEscolhido.status = 1;

      print(itemEscolhido.nome + " -> " + itemEscolhido.status.toString());
    } else if (selecionado == false) {
      itemEscolhido.status = 0;

      print(itemEscolhido.nome + " -> " + itemEscolhido.status.toString());
    }

    int resultado = await _db.atualizarItem(itemEscolhido);
  }

  
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

  

  _removerItem(int id, double compra, bool operacao) async {
    if (operacao == true) {
      setState(() {
        valor += compra;
      });
    }
    await _db.removerItem(id);

    _recuperarItens(id_compra);
  }

  //Atualiza o saldo após a adição de itens no carrinho
  _disponivel(double compra, bool operacao) {

    if ((compra != null) && (operacao == true)) {

      setState(() {
        valor -= compra;
      });
      
     _db.atualizaValorCompra(valor,id_compra);

      print(
          "Subtração ->  Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
    } else if ((compra != null) && (operacao == false)) {

      setState(() {
        valor += compra;
      });
     
     _db.atualizaValorCompra(valor,id_compra);

      print(
          "Adição -> Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
    } else {
      valor = valor;
    }
  }

  _controleSaldo(double totalItem) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Saldo Insuficiente",
              style: TextStyle(
                  color: null, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Valor R\$ ${totalItem.toStringAsFixed(1)}0 ultrapassa o saldo disponível para compra.",
              style: TextStyle(
                color: null,
                fontSize: 15,
                //fontWeight: FontWeight.bold
              ),
            ),
            actions: <Widget>[
              FlatButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.check_circle, color: null),
                  label: Text(""))
            ],
          );
        });
  }

  
  _checkLenght() async {

   List itens = await _db.recuperarItens(id_compra);

   //print("Length ${itens.length}");
       return itens.length;    
  }

 
 @override
  void initState() {
    super.initState();

    _recuperarItens(id_compra);
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        
       /*leading: IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () async {
                  //await _db.atualizaStatus();
                  Navigator.push(context, 
                                  MaterialPageRoute(builder:
                                      (context) => ListaCompras()));
                      }),*/
        title: Text(
          "Items",
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              "R\$ ${valor.toStringAsFixed(2)}",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 35,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
          ),
          //Text("${widget.valor}",

         Expanded(
                                    
            child: _itens.length != 0 ?
             ListView.builder(
         
            itemCount: _itens.length,
            itemBuilder: (context, index) {

   
              //Recuperar item dentro do método recuperarItens
              final item = _itens[index];

              //item.selected !=item.selected;

              if (item.status == 1) {
                item.selected = true;
              } else if (item.status == 0) {
                item.selected = false;
              }
                
              return Dismissible(

                key: Key(item.id.toString()),

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
                                              _removerItem(item.id, item.total,
                                                  item.selected);
                                              Navigator.pop(context);
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
                                    }
                            );
                                      
                         } else if (direction == DismissDirection.startToEnd) {
                          
                             _exibirTelaCadastro(item: item);
                       }                    
                    },
              
              child: GestureDetector(

                onTap: (){

                                  
                  setState(() {

                          if (item.selected == false) {
                             item.selected=true;                            
                          } else {
                              item.selected=false; 
                          }                         
                    
                          _atualizaStatus(item, item.selected);
                        });

                        if (valor < item.total) {
                          item.status = 0;
                          _disponivel(0, item.selected);
                          _controleSaldo(item.total);
                        } else {
                          _disponivel(item.total, item.selected);
                        }

                },

                child:Card(
                

                color: Colors.grey[100],
                elevation: 3.0,
                key: Key(item.toString()),
                child: ListTile(

                  /*leading: Checkbox(

                      activeColor: Colors.green,
                      value: item.selected,
                      onChanged: (bool novoValor) {
                        
                        setState(() {
                          item.selected = novoValor;
                          _atualizaStatus(item, item.selected);
                        });

                        if (valor < item.total) {
                          item.status = 0;
                          _disponivel(0, item.selected);
                          _controleSaldo(item.total);
                        } else {
                          _disponivel(item.total, item.selected);
                        }
                      }
                      
                    ),*/

                 

                  title: item.status == 1
                      ? Text(
                          item.nome + " - Total: " + item.total.toStringAsFixed(2),
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(item.nome + " - Total: " + item.total.toStringAsFixed(2)),

                  //Exibir ações dentro do item de lista.

                  trailing: item.status != 1 ?

                   Icon(

                          Icons.add_shopping_cart,
                          //color: Colors.grey,
                          size: 30,
                        ) 
                      
                      /*Row(

                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[


                           GestureDetector(

                              onTap: () {
                                _exibirTelaCadastro(item: item);
                              },

                              child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                            ),

                            GestureDetector(

                              onTap: () {

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Excluir"),
                                        content: Text("Confirmar exclusão ?"),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              _removerItem(item.id, item.total,
                                                  item.selected);
                                              Navigator.pop(context);
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
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        )*/


                      : Icon(

                          Icons.shopping_cart,
                          color: Colors.green,
                          size: 30,
                        ),

                ),


              ),

              ),

              



              );
            
            },
          )

          :  
          
          Center(
                
                child:Row(
                  
                  mainAxisAlignment: MainAxisAlignment.center,                  
                  children: <Widget>[
                     Text(
                        "Clique no botão ",
                        textAlign: TextAlign.center,
                        style:TextStyle(color:Colors.black87),
                        
                      ),
                      Icon(Icons.add_shopping_cart, color:Colors.black87),
                      Text(
                        "para adicionar itens.",
                        textAlign: TextAlign.center,
                        style:TextStyle(color:Colors.black87),
                      ),
                  ],
                )
                
          )

         )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: Icon(Icons.add_shopping_cart),
          onPressed: () {
            _exibirTelaCadastro();
          }),

    /*bottomNavigationBar: BottomAppBar(
        //color: Colors.purple,
        elevation: 20.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(100,0,100,5),
             child:RaisedButton(
                      child: Text("Finalizar",
                      style: TextStyle(color:Colors.white,
                      fontWeight: FontWeight.bold),
                      ),
                      color: Colors.red,
                      onPressed: () {print("Finalizar !");},
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                     
                    )
        )
            
      ),*/
     
    );
  }
}


