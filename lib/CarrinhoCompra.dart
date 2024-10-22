import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/model/Sugestao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ConfirmaCompra.dart';
import 'Home.dart';
import 'ListaCompras.dart';
import 'package:feira_facil/helper/DatabaseHelper.dart';
import 'controller.dart';
import 'model/Compra.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_masked_text/flutter_masked_text.Dart';
import 'package:animations/animations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CarrinhoCompra extends StatefulWidget {
  CarrinhoCompra({this.valor, this.id_compra});

  final double valor;
  final int id_compra;

  @override
  _CarrinhoCompraState createState() =>
      _CarrinhoCompraState(this.valor, this.id_compra);
}

class _CarrinhoCompraState extends State<CarrinhoCompra>
    with TickerProviderStateMixin {
  _CarrinhoCompraState(this.valor, this.id_compra);

  final controller = Controller();

  FocusNode _focus = new FocusNode();

  //Dropdown
  int _value;

  AnimationController _controller;
  Animation<double> _animation;

  double valor;
  int id_compra;
  var _db = DatabaseHelper();
  double _saldo;
  List<Item> _itens = List<Item>();

  TextEditingController _nomeController = TextEditingController(text: '');
  MoneyMaskedTextController _precoController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  TextEditingController _qtdeController = TextEditingController(text: '');
  TextEditingController _localController = TextEditingController(text: '');

  String currentText = "";
  List<String> suggestions = [];
  int noCarrinho;
  int finalizada;
  String situacao = "";
  double valorCompra, saldoCompra;
  double compra, saldo;
  int voltar, indice = 1;

// Parâmetro opcional se existir item é uma edição
  _exibirTelaCadastro({Item item}) async {
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
      _qtdeController.text = item.qtde.toString();
      _localController.text = item.local.toString();
      _value = item.unidade;

      textoSalvarAtualizar = "Atualizar";
    }

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: AlertDialog(
            title: Text(textoSalvarAtualizar + " Item",
                style: TextStyle(
                  color: Colors.purple,
                )),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Observer(builder: (_) {
                      return Container(
                          padding: EdgeInsets.all(5),
                          child: Text(controller.mensagemErro,
                              style: TextStyle(color: Colors.red)));
                    }),
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: SimpleAutoCompleteTextField(
                        key: null,
                        focusNode: _focus,
                        controller: _nomeController,
                        suggestions: suggestions,
                        keyboardType: TextInputType.text,
                        textChanged: (text) => currentText = text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Descrição",

                          /*hintText: "Ex: Arroz"*/
                        ),
                      ),
                    ),
                    //Inicio da linha
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(4),
                          width: 110,
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
                        Container(
                          padding: EdgeInsets.all(4),
                          width: 120,
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
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          width: 100,
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
                        Container(
                          padding: EdgeInsets.all(8),
                          width: 100,
                          child: DropdownButton(
                            hint: Text("Tipo"),
                            value: _value,
                            items: [
                              DropdownMenuItem(
                                child: Text("g"),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text("Kg"),
                                value: 2,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "Unidade",
                                ),
                                value: 3,
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _value = value);

                              //print(_value);
                            },
                          ),
                        )
                      ],
                    ),

                    //Fim da Linha
                  ],
                ),
              );
            }),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    controller.validaCampo(_nomeController.text);
                    _salvarAtualizarItem(itemSelecionado: item);

                    //Navigator.pop(context);
                  },
                  child: Icon(Icons.check)),
              FlatButton(
                  onPressed: () {
                    controller.resetCampo();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close)),
            ],
          ));
        });
  }

  //Popular itens
  _populaItem() async {
    Item item = Item("Item", 100.00, 1, 100.00, "Extra", 2, "Kg",
        DateTime.now().toString(), 0, 0, 1);

    int resultado = await _db.salvarItem(item);
  }

  _salvarAtualizarItem({Item itemSelecionado}) async {
    if (_nomeController.text.isNotEmpty) {
      if (_precoController.text.isEmpty == true) {
        setState(() {
          _precoController.text = '0';
        });

        if (_qtdeController.text.isEmpty == true) {
          setState(() {
            _qtdeController.text = '0';
          });
        }

        if (_localController.text.isEmpty == true) {
          setState(() {
            _localController.text = 'Local';
          });
        }
      }
    }
    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text.replaceAll(',', '.'));
    double qtde = double.parse(_qtdeController.text.replaceAll(',', '.'));
    double conversao;
    if (_value == 1) {
      setState(() => conversao = (qtde / 1000));
    } else {
      setState(() => conversao = (qtde / 1));
    }
    double total = preco * conversao;
    double valorTotal = double.parse(total.toStringAsFixed(2));
    String local = _localController.text;
    String sigla;
    int status;
    int carrinho = 0;
    int compra_id = id_compra;

    switch (_value) {
      case 1:
        setState(() => sigla = "g");
        break;
      case 2:
        setState(() => sigla = "Kg");
        break;
      case 3:
        setState(() => sigla = "un");
        break;
      default:
        setState(() => sigla = "");
    }

    if (itemSelecionado == null) {
      Item item = Item(nome, preco, qtde, valorTotal, local, _value, sigla,
          DateTime.now().toString(), status, carrinho, compra_id);

      if (_nomeController.text.isNotEmpty) {
        int resultado = await _db.salvarItem(item);
        Navigator.pop(context);
      }

      setState(() => _value = null);
      int sugestao =
          await _db.salvarSugestao(item.nome, item.local, item.compra_id);
    } else {
      itemSelecionado.nome = nome;
      itemSelecionado.preco = preco;
      itemSelecionado.qtde = qtde;
      itemSelecionado.total = preco * conversao;
      itemSelecionado.local = local;
      itemSelecionado.unidade = _value;
      itemSelecionado.sigla = sigla;

      itemSelecionado.data = DateTime.now().toString();

      int resultado = await _db.atualizarItem(itemSelecionado);
      Navigator.pop(context);

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
    setState(() => _value = null);
    _recuperarItens(id_compra);
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

  //Atualizar os saldos nesse método, apos remover item do carrinho...
  _removerItem(int id, double itemTotal, bool selected) async {
    double valorComprado;

    //print("Id ${id}  item ${itemTotal} operação ${selected}");

    setState(() {
      valorComprado = itemTotal;
    });

    await _db.removerItem(id);
    if ((itemTotal != null) && (selected == true)) {
      setState(() {
        valorCompra += valorComprado;
        saldoCompra -= valorComprado;
      });
    } else if ((itemTotal != null) && (selected == false)) {
      valorCompra = valorCompra;
      saldoCompra = saldoCompra;
    }

    await _db.atualizaValorCompra(valorCompra, saldoCompra, id_compra);
    await _recuperarItens(id_compra);
  }

  //Atualiza o saldo após a adição de itens ao CARRINHO
  _disponivel(double totalItem, bool selected) async {
    //Item adicionado ao carrinho
    if ((totalItem != null) && (selected == true)) {
      setState(() {
        valorCompra -= totalItem;
        saldoCompra += totalItem;
      });

      print(
          "Limite disponível: ${valorCompra.toStringAsFixed(2)} Valor comprado ${saldoCompra.toStringAsFixed(2)} selected ${selected}");
      await _db.atualizaValorCompra(valorCompra, saldoCompra, id_compra);

      //Item removido do carrinho
    } else if ((totalItem != null) && (selected == false)) {
      setState(() {
        valorCompra += totalItem;
        saldoCompra -= totalItem;
      });
      print(
          "Limite disponível: ${valorCompra.toStringAsFixed(2)} valor devolvido ${totalItem.toStringAsFixed(2)} Valor comprado ${saldoCompra.toStringAsFixed(2)} selected ${selected}");
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

    /*print(
        " Limite disponível ${valorCompra} - valor comprado ${saldoCompra} - finalizada ${finalizada}");*/
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
    //Popula item
    //_populaItem();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            actions: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ]),
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
                          color: Colors.deepPurple,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${valorCompra.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Usado",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${saldoCompra.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: TextStyle(
                          color: Colors.red,
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
                                  // ignore: missing_return
                                  confirmDismiss: (direction) {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
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
                                                    print(_removerItem(
                                                        item.id,
                                                        item.total,
                                                        item.selected));
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

                                      // Atualiza limite de compra e valor compra caso valor do item seja editado.
                                      if (item.selected == true) {
                                        setState(() {
                                          compra = valorCompra;
                                          saldo = saldoCompra;
                                        });

                                        setState(() {
                                          compra += item.total;
                                          saldo -= item.total;
                                        });
                                      }
                                    }
                                  },

                                  // GESTURE DETECTOR
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
                                            //Testa se valor do item é menor que o saldo disponível.
                                            if (item.total < valorCompra) {
                                              setState(() {
                                                _disponivel(
                                                    item.total, item.selected);
                                              });
                                            } else {
                                              setState(() {
                                                item.status = 0;

                                                // _disponivel(0, item.selected);
                                                //Mensagem informando que o saldo é menor
                                                _controleSaldo(item.total);
                                              });
                                            }
                                          }
                                        : () {},
                                    child: Card(
                                      color: Colors.grey[100],
                                      elevation: 3.0,
                                      key: Key(item.toString()),
                                      child: ListTile(
                                        leading: item.status != 1
                                            ? Icon(
                                                Icons.check_box_outline_blank,
                                                color: Colors.purple,
                                                size: 17,
                                              )
                                            : Icon(
                                                Icons.check_box,
                                                color: Colors.blueGrey,
                                                size: 17,
                                              ),
                                        title: item.status == 1
                                            ? Text(
                                                item.nome +
                                                    "  R\$:" +
                                                    item.preco
                                                        .toStringAsFixed(2)
                                                        .replaceAll(".", ",") +
                                                    "   Qtde: " +
                                                    item.qtde
                                                        .toStringAsFixed(2)
                                                        .replaceAll(".", ",") +
                                                    "" +
                                                    item.sigla,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: 13.5,
                                                    color: Colors.blueGrey,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1),
                                              )
                                            : Text(
                                                item.nome +
                                                    "     R\$:" +
                                                    item.preco
                                                        .toStringAsFixed(2)
                                                        .replaceAll(".", ",") +
                                                    "   Qtde: " +
                                                    item.qtde
                                                        .toStringAsFixed(2)
                                                        .replaceAll(".", ",") +
                                                    "" +
                                                    item.sigla,
                                                style: TextStyle(
                                                    fontSize: 13.5,
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1),
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
                                    leading: item.status != 1
                                        ? Icon(
                                            Icons.check_box_outline_blank,
                                            color: Colors.purple,
                                            size: 17,
                                          )
                                        : Icon(
                                            Icons.check_box,
                                            color: Colors.blueGrey,
                                            size: 17,
                                          ),
                                    title: item.status == 1
                                        ? Text(
                                            item.nome +
                                                "     R\$:" +
                                                item.preco
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".", ",") +
                                                "   Qtde: " +
                                                item.qtde
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".", ",") +
                                                item.sigla,
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 13,
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
                                          )
                                        : Text(
                                            item.nome +
                                                "  R\$:" +
                                                item.preco
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".", ",") +
                                                "   Qtde: " +
                                                item.qtde
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".", ","),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
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
