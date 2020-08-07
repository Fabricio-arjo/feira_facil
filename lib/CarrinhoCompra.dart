import 'dart:developer';
import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Sugestao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ConfirmaCompra.dart';
import 'Home.dart';
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
  var _db = DatabaseHelper();
  double _saldo;
  List<Item> _itens = List<Item>();

  TextEditingController _nomeController = TextEditingController(text: "");
  MoneyMaskedTextController _precoController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  TextEditingController _qtdeController =
      MaskedTextController(mask: '0000,000', text: '');
  TextEditingController _localController = TextEditingController(text: "");

  String currentText = "";
  List<String> suggestions = [];
  int noCarrinho;
  int finalizada;
  String situacao = "";
  double valorCompra, saldoCompra;
  double compra, saldo;
  int voltar, indice = 1;

// Parâmetro opcional se existir item é uma edição
  _exibirTelaCadastro({Item item}) {
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
      _precoController.text = item.preco.toStringAsFixed(2);
      _qtdeController.text = item.qtde.toStringAsFixed(3);
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
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
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

    //print("Lista itens: " +itensRecuperados.toString());
  }

  _salvarAtualizarItem({Item itemSelecionado}) async {
    if ((_precoController.text.isEmpty == true) ||
        (_qtdeController.text.isEmpty == true) ||
        (_localController.text.isEmpty == true)) {
      setState(() {
        _precoController.text = "0";
        _qtdeController.text = "0";
        _localController.text = "";
      });
    }

    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text.replaceAll(',', '.'));
    double qtde = double.parse(_qtdeController.text.replaceAll(',', '.'));
    double total = preco * qtde;

    String local = _localController.text;
    int status;
    int carrinho = 0;
    int compra_id = id_compra;

    if (itemSelecionado == null) {
      Item item = Item(nome, preco, qtde, total, local,
          DateTime.now().toString(), status, carrinho, compra_id);

      int resultado = await _db.salvarItem(item);
      int sugestao =
          await _db.salvarSugestao(item.nome, item.local, item.compra_id);
    } else {
      itemSelecionado.nome = nome;
      itemSelecionado.preco = preco;
      itemSelecionado.qtde = qtde;
      itemSelecionado.total = itemSelecionado.preco * itemSelecionado.qtde;
      itemSelecionado.local = local;
      itemSelecionado.data = DateTime.now().toString();

      int resultado = await _db.atualizarItem(itemSelecionado);
      int sugestao = await _db.salvarSugestao(itemSelecionado.nome,
          itemSelecionado.local, itemSelecionado.compra_id);

      if (itemSelecionado.selected == true) {
        setState(() {
          compra -= itemSelecionado.total;
          saldo += itemSelecionado.total;
        });

        await _db.atualizaValorCompra(compra, saldo, id_compra);
      }
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
    } else if (selecionado == false) {
      itemEscolhido.status = 0;
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
    double valor;

    setState(() {
      valor = compra;
    });

    await _db.removerItem(id);

    //print("Compra: ${valor}");

    _disponivel(valor, false);

    _snackBar();

    await _recuperarItens(id_compra);
  }

  //Atualiza o saldo após a adição de itens ao carrinho
  _disponivel(double totalItem, bool operacao) async {
    if ((totalItem != null) && (operacao == true)) {
      setState(() {
        valorCompra -= totalItem;
        saldoCompra += totalItem;
      });
      await _db.atualizaValorCompra(valorCompra, saldoCompra, id_compra);
    } else if ((totalItem != null) && (operacao == false)) {
      setState(() {
        valorCompra += totalItem;
        saldoCompra -= totalItem;
      });

      await _db.atualizaValorCompra(valorCompra, saldoCompra, id_compra);
    } else {
      valorCompra = valorCompra;
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

  _snackBar() {
    final snackbar = SnackBar(
      //backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text(
        "Item removido",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );

    Scaffold.of(context).showSnackBar(snackbar);
    return snackbar;
  }

  _snackBar2() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 36,
              child: Text(
                "\nCompra Finalizada !",
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.check, color: Colors.purple)),
            ],
          );
        });
  }

  _finalizarReabrirCompraAlert(int codCompra, int status) {
    if (status == 1) {
      setState(() => situacao = "reabrir");
    } else if (status == 0) {
      setState(() => situacao = "finalizar");
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text("Finalizar compra"),
            content: Text(
              "\nDeseja ${situacao} a compra ?",
              style:
                  TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  if (status == 1) {
                    _reabreCompra(codCompra);
                  } else if (status == 0) {
                    _finalizaCompra(codCompra);
                  }
                  Navigator.of(context).pop();
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

  _sugestoes() async {
    List dados = await _db.sugestoes();
    for (var d in dados) {
      Sugestao s = Sugestao.fromMap(d);
      if ((suggestions.contains(s.nome) == false)) {
        setState(() {
          suggestions.add(s.nome);
        });
      } else if ((suggestions.contains(s.local) == false)) {
        setState(() {
          suggestions.add(s.local);
        });
      }
    }
    //print("Dados: "+ suggestions.toString());
  }

  /* _insereCarrinho(int id_compra, int id_item) async {
    int  resultado = await _db.inserirCarrinho(id_compra, id_item);
    print(" Insert " + resultado.toString());
    
    _itensCarrinho();
  }*/

  /* _removeCarrinho(int id_item) async {
    int resultado = await _db.removerCarrinho(id_item);
    print(" Remove shopping cart " + resultado.toString());
    
    //_itensCarrinho();
  }*/

  /*_itensCarrinho() async {
     var valor = (await _db.itensCarrinho())[0]['total'];
    
     setState(()=>noCarrinho = valor);
     print("Count: ${noCarrinho}");

     /*if (noCarrinho == _itens.length) {
        _finalizarCompraAlert(id_compra);
     }*/
  }*/

  _finalizaCompra(int id_compra) async {
    if (id_compra != null) {
      return await _db.finalizaCompra(id_compra);
    }
    print("Compra ${id_compra} finalizada");
  }

  _reabreCompra(int id_compra) async {
    if (id_compra != null) {
      return await _db.reabreCompra(id_compra);
    }
    print("Compra ${id_compra} reaberta !");
  }

  _infoCompra(int id_compra) async {
    var dados = await _db.infoCompra(id_compra);

    setState(() {
      valorCompra = dados[0]['valorLimite'];
      finalizada = dados[0]['finalizada'];
      saldoCompra = dados[0]['saldo'];
    });

    //print(" Valor ${valorCompra} - saldo compra ${saldoCompra} - finalizada ${finalizada}");
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        _finalizarReabrirCompraAlert(id_compra, finalizada);
        break;
      case 1:
        if (finalizada == 1) {
          _snackBar2();
        } else {
          _exibirTelaCadastro();
        }

        break;
      default:
        print("");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _infoCompra(id_compra);
    _recuperarItens(id_compra);
    _sugestoes();

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 25),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(
                              voltar: indice,
                            )));
              }),
          backgroundColor: Colors.purple,
          title: Text(
            "Itens",
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Disponível",
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${valorCompra.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Usado",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${saldoCompra.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            Expanded(
                child: _itens.length != 0
                    ? ListView.builder(
                        itemCount: _itens.length,
                        itemBuilder: (context, index) {
                          //Recuperar item dentro do método recuperarItens
                          final item = _itens[index];

                          if (item.status == 1) {
                            item.selected = true;
                          } else if (item.status == 0) {
                            item.selected = false;
                          }

                          return finalizada != 1
                              ? Dismissible(
                                  key: Key(item.id.toString()),
                                  background: Container(
                                    color: Colors.green,
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              //title: Text("Excluir",style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                                              content: Text(
                                                "\Confirmar exclusão ?",
                                                style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    _removerItem(
                                                        item.id,
                                                        item.total,
                                                        item.selected);
                                                    Navigator.pop(context);
                                                    _snackBar();
                                                  },
                                                  child: Icon(Icons.check),
                                                ),
                                                FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Icon(Icons.close))
                                              ],
                                            );
                                          });
                                    } else if (direction ==
                                        DismissDirection.startToEnd) {
                                      _exibirTelaCadastro(item: item);

                                      if (item.selected == true) {
                                        compra = valorCompra;
                                        saldo = saldoCompra;

                                        setState(() {
                                          compra += item.total;
                                          saldo -= item.total;
                                        });

                                        print(compra.toString() +
                                            " ---- " +
                                            saldo.toString());
                                      }
                                    }
                                  },
                                  child: GestureDetector(
                                    onTap: finalizada != 1
                                        ? () {
                                            setState(() {
                                              if (item.selected == false) {
                                                item.selected = true;
                                              } else {
                                                item.selected = false;
                                              }
                                              _atualizaStatus(
                                                  item, item.selected);
                                            });

                                            if (valorCompra < item.total) {
                                              setState(() {
                                                item.status = 0;
                                              });
                                              _disponivel(0, item.selected);
                                              _controleSaldo(item.total);
                                            } else {
                                              _disponivel(
                                                  item.total, item.selected);
                                            }
                                          }
                                        : () {},
                                    child: Card(
                                      color: Colors.grey[100],
                                      elevation: 3.0,
                                      key: Key(item.toString()),
                                      child: ListTile(
                                        title: item.status == 1
                                            ? Text(
                                                item.nome +
                                                    "     R\$:" +
                                                    item.preco
                                                        .toStringAsFixed(2) +
                                                    "   Qtde: " +
                                                    item.qtde
                                                        .toStringAsFixed(3),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2),
                                              )
                                            : Text(
                                                item.nome +
                                                    "     R\$:" +
                                                    item.preco
                                                        .toStringAsFixed(2) +
                                                    "   Qtde: " +
                                                    item.qtde
                                                        .toStringAsFixed(3),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2),
                                              ),

                                        //Exibir ações dentro do item de lista.

                                        trailing: item.status != 1
                                            ? Icon(
                                                Icons.add_shopping_cart,
                                                color: Colors.purple,
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
                                )
                              : Card(
                                  color: Colors.grey[100],
                                  elevation: 3.0,
                                  key: Key(item.toString()),
                                  child: ListTile(
                                    title: item.status == 1
                                        ? Text(
                                            item.nome +
                                                "     R\$:" +
                                                item.preco.toStringAsFixed(2) +
                                                "   Qtde: " +
                                                item.qtde.toStringAsFixed(3),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
                                          )
                                        : Text(
                                            item.nome +
                                                "     R\$:" +
                                                item.preco.toStringAsFixed(2) +
                                                "   Qtde: " +
                                                item.qtde.toStringAsFixed(3),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
                                          ),

                                    //Exibir ações dentro do item de lista.

                                    trailing: item.status != 1
                                        ? Icon(
                                            Icons.add_shopping_cart,
                                            color: Colors.purple,
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.shopping_cart,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                  ),
                                );
                        },
                      )
                    : Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: finalizada != 1
                                ? <Widget>[
                                    Text(
                                      "Clique em  ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.purple),
                                    ),
                                    Icon(Icons.playlist_add,
                                        size: 30, color: Colors.purple),
                                    Text(
                                      "  para adicionar itens.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.purple),
                                    )
                                  ]
                                : <Widget>[])))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: finalizada == 0
                  ? Icon(Icons.lock, color: Colors.purple, size: 30)
                  : Icon(Icons.lock_open, color: Colors.purple, size: 30),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: finalizada == 0
                  ? Icon(Icons.playlist_add, color: Colors.purple, size: 30)
                  : Icon(Icons.playlist_add, color: Colors.grey[400], size: 30),
              title: Text(''),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        )

        /*floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
                       
          onPressed: () {
          _finalizarReabrirCompraAlert(id_compra, finalizada);
           },
           
          label: finalizada == 1 ? Text('Continuar',style: TextStyle(letterSpacing: 3)) : Text('Finalizar',style: TextStyle(letterSpacing: 3)),
          backgroundColor: finalizada == 1 ? Colors.green : Colors.pink,
        ),*/
        );
  }
}
