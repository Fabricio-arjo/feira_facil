import 'dart:developer';
import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Sugestao.dart';
import 'package:flutter/material.dart';
//import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ListaCompras.dart';
import 'package:feira_facil/helper/DatabaseHelper.dart';
import 'model/Compra.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_masked_text/flutter_masked_text.Dart';

class CarrinhoCompra extends StatefulWidget {
  CarrinhoCompra({this.valor, this.id_compra});
  final double valor;
  final int id_compra;

  @override
  _CarrinhoCompraState createState() =>
      _CarrinhoCompraState(this.valor, this.id_compra);
}

class _CarrinhoCompraState extends State<CarrinhoCompra> {
     _CarrinhoCompraState(this.valor, this.id_compra);

  double valor;
  int id_compra;
  int add = 0;
  var _db = DatabaseHelper();
  double _saldo;
  List<Item> _itens = List<Item>();
  
  
  

  TextEditingController _nomeController = TextEditingController(text: "");
  MoneyMaskedTextController _precoController = MoneyMaskedTextController(decimalSeparator: ',',thousandSeparator: '.');
  TextEditingController _qtdeController = TextEditingController();
  TextEditingController _localController = TextEditingController(text: "");

  String currentText = "";
  List<String> suggestions = [];

// Parâmetro opcional se existir item é uma edição
  _exibirTelaCadastro({Item item}) {
     _sugestoes();
      
    String textoSalvarAtualizar = "";
    if (item == null) {
      //Salvando

      _nomeController.text = "";
      _precoController.text = "";
      _qtdeController.text = "";
      _localController.text = "";

      textoSalvarAtualizar = "Adicionar";

    } else {
      //Atualizando
       
      _nomeController.text = item.nome.toString();
      _precoController.text =  item.preco.toStringAsFixed(2);
      _qtdeController.text = item.qtde.toString();
      _localController.text = item.local.toString();

      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(

        context: context,
        builder: (context) {
          return AlertDialog(

           title: Text(textoSalvarAtualizar + " Item",
                style: TextStyle(
                  color: Colors.purple,
                )),
            
            content: Container(

            height:200,
            width: 330,
            alignment: Alignment.topCenter,
            
            child: Column(
              
              mainAxisSize: MainAxisSize.min,

             children: <Widget>[

                Container(

                  padding: EdgeInsets.only(bottom: 5),
                                               
                  child: SimpleAutoCompleteTextField(
                    key: null,
                    controller: _nomeController,
                    suggestions: suggestions,
                    keyboardType: TextInputType.text,
                    textChanged: (text) => currentText = text,
                      
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nome",
                        //hintText: "Ex: Arroz"
                        ),
                                         
                  ),
                ),

             

                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      width: 120,
                      
                      child: TextField(
                        controller: _precoController,
                        //autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Preço",
                            //hintText: "Ex: 8.50"
                          ),
                      ),
                    ),

                    //Divider(),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: 110,
                     
                      child: TextField(
                        controller: _qtdeController,
                        keyboardType: TextInputType.number,
                        //autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Qtde",
                            //hintText: "Ex: 1"
                          ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(5,5,5,0),
                 
                  child: SimpleAutoCompleteTextField(
                    key: null,
                    controller: _localController,
                    keyboardType: TextInputType.text,
                    suggestions: suggestions,
                    textChanged: (text) => currentText = text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Local",
                        //hintText: "Ex: Estabelecimento"
                      ),
                      
                  ),
                  
                  /*TextField(
                    controller: _localController,
                    maxLength: 20,
                    keyboardType: TextInputType.text,
                    //autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Local",
                        //hintText: "Ex: Estabelecimento"
                      ),
                  ),*/

                )
              ],
            ),

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

    print("Lista itens: " +itensRecuperados.toString());
    
  }


  _salvarAtualizarItem({Item itemSelecionado}) async {

    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text.replaceAll(',', '.'));
    double qtde = double.parse(_qtdeController.text.replaceAll(',','.'));
    double total = preco * qtde;
    String local = _localController.text;
    int status;
    int compra_id = id_compra;

    if (itemSelecionado == null) {
      //Salvando

      //Objeto da classe item
      Item item = Item(nome, preco, qtde, total, local,DateTime.now().toString(), status, compra_id);
     
      int resultado = await _db.salvarItem(item);
      int sugestao = await _db.salvarSugestao(item.nome, item.local);
    
    
   
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

  //Atualiza a coluna Status
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
  _disponivel(double totalItem, bool operacao) {
    if ((totalItem != null) && (operacao == true)) {
      setState(() {
        valor -= totalItem;
      });

      _db.atualizaValorCompra(valor, id_compra);

      //print("Subtração ->  Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
    } else if ((totalItem != null) && (operacao == false)) {
      setState(() {
        valor += totalItem;
      });

      _db.atualizaValorCompra(valor, id_compra);

      //print("Adição -> Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
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

  _finalizarCompra(int codCompra, int adicionado) {



    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text("Finalizar compra"),
            content: Text("Deseja finalizar a compra ?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
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
 
  }

  _sugestoes()async{

     List dados = await _db.sugestoes();
     for (var d in dados) {
        Sugestao s = Sugestao.fromMap(d);
      if ((suggestions.contains(s.nome) == false)||(suggestions.contains(s.local) == false)) {
        setState(() {
           suggestions.add(s.nome);
           suggestions.add(s.local);            
        });
      }
     }
    
     print("Dados: "+ suggestions.toString());

  }
  
 
  @override
  void initState() {
    super.initState();
   
  
      
  }

  @override
  Widget build(BuildContext context) {

  _recuperarItens(id_compra);
  
  
      
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          "Items",
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        /*actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                _exibirTelaCadastro();
              })
        ],*/
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
        

          Expanded(
              child: _itens.length != 0
                  ? ListView.builder(
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
                                            setState(() {
                                              add-=1;
                                            });
                                            _removerItem(item.id, item.total,item.selected);
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
                              _exibirTelaCadastro(item: item);
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (item.selected == false) {
                                  item.selected = true;
                                  add += 1;
                                } else {
                                  item.selected = false;
                                  add -= 1;
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

                              print("Adicionados: ${add}");

                              if (add == _itens.length) {
                                _finalizarCompra(item.compra_id, add);
                              }

                            },
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 3.0,
                              key: Key(item.toString()),
                              child: ListTile(
                                title: item.status == 1
                                    ? Text(
                                        item.nome +
                                            " - Total: " +
                                            item.total.toStringAsFixed(2),
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(item.nome +
                                        " - Total: " +
                                        item.total.toStringAsFixed(2)),

                                //Exibir ações dentro do item de lista.

                                trailing: item.status != 1
                                    ? Icon(
                                        Icons.remove_shopping_cart,
                                        //color: Colors.grey,
                                        size: 30,
                                      )
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
                  : Center(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Clique no botão ",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87),
                        ),
                        Icon(Icons.add_shopping_cart, color: Colors.black87),
                        Text(
                          "para adicionar itens.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    )))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: Icon(Icons.add_shopping_cart),
          onPressed: () {
            _exibirTelaCadastro();
          }),
    );
  }
}
