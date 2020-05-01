import 'dart:developer';

import 'package:feira_facil/model/Item.dart';
import 'package:flutter/material.dart';
import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CarrinhoCompra extends StatefulWidget {
  CarrinhoCompra({this.valor});
  final double valor;

  @override
  _CarrinhoCompraState createState() => _CarrinhoCompraState(this.valor);
}

class _CarrinhoCompraState extends State<CarrinhoCompra> {
 
  _CarrinhoCompraState(this.valor);
  double valor;

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _precoController = TextEditingController();
  TextEditingController _qtdeController = TextEditingController();
  var _db = ItemHelper();
  
  double _saldo;
 
 

  //Lista para recuperar itens
  List<Item> _itens = List<Item>();

  /*_exibirTelaCadastro(){


     showDialog(
       context: context,
       builder: (context){
            return AlertDialog(
               //title: Text("Adicionar Item"),
               content: 
                 
                  Column(
                                                                         
                   mainAxisSize: MainAxisSize.min,
                   children: <Widget>[

                      Padding(padding:EdgeInsets.all(3),
                        child:TextField(
                          controller: _nomeController,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nome",
                          hintText: "Ex: Arroz"
                         ),
                        ),
                      ),
                      
                      //Divider(),
                      Padding(padding: EdgeInsets.all(3),
                        child: TextField(
                           controller: _precoController,
                        //autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                           border: OutlineInputBorder(),
                          labelText: "Preço",
                          hintText: "Ex: 8.50"
                          ),
                        ),
                      ),
                      
                      //Divider(),
                      Padding(
                        padding: EdgeInsets.all(3),
                        child: TextField(
                        controller: _qtdeController,
                        keyboardType: TextInputType.number,
                        //autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Quantidade",
                          hintText: "Ex: 1"
                        ),
                      ),
                      )
                       
                       
                        
                     ],
                 
               ),

          
               actions: <Widget>[
                  FlatButton(
                   onPressed:()=>Navigator.pop(context), 
                   child: Icon(Icons.close)
                  ),
                  FlatButton(
                   onPressed:(){
                        
                      _salvarItem();
                       Navigator.pop(context);
                  }, 
                   child: Icon(Icons.check)
                  )
               ],
            );
       }
    );

 }*/





// Parâmetro opcional se existir item é uma edição
  _exibirTelaCadastro({Item item}) {
    String textoSalvarAtualizar = "";
    if (item == null) {
      //Salvando

      _nomeController.text = "";
      _precoController.text = "";
      _qtdeController.text = "";
     

      textoSalvarAtualizar = "Salvar";
    } else {
      //Atualizando

      _nomeController.text = item.nome;
      _precoController.text = item.preco.toString();
      _qtdeController.text = item.qtde.toString();
     

      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //title: Text("Adicionar Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(3),
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
                Padding(
                  padding: EdgeInsets.all(3),
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
                Padding(
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _qtdeController,
                    keyboardType: TextInputType.number,
                    //autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Quantidade",
                        hintText: "Ex: 1"),
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

  _recuperarItens() async {
    
       
    List itensRecuperados = await _db.recuperarItens();

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




  _salvarAtualizarItem( {Item itemSelecionado}) async {

    
    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text);
    int qtde = int.parse(_qtdeController.text);
    double total = preco * qtde;
    int status;
    
        
        
    if (itemSelecionado == null) {
      //Salvando
       
                    
      //Objeto da classe item
      Item item = Item(nome, preco, qtde, total, DateTime.now().toString(),status);
      int resultado = await _db.salvarItem(item);
   
    } else {
      //Atualizar

      itemSelecionado.nome = nome;
      itemSelecionado.preco = preco;
      itemSelecionado.qtde = qtde;
      itemSelecionado.total = total;
      itemSelecionado.data = DateTime.now().toString();
      
      //Método do Item Helper
      int resultado = await _db.atualizarItem(itemSelecionado);
    }

    _nomeController.clear();
    _precoController.clear();
    _qtdeController.clear();

    _recuperarItens();
  }


  _atualizaStatus(Item itemEscolhido, bool selecionado) async{
          
     if(selecionado==true && itemEscolhido.status!=1){
        itemEscolhido.status = 1;
               
        print(itemEscolhido.nome +" -> "+ itemEscolhido.status.toString());
    
     }else if(selecionado==false){
        itemEscolhido.status=0;
    
        print(itemEscolhido.nome +" -> "+ itemEscolhido.status.toString());
     }

    int resultado = await _db.atualizarItem(itemEscolhido);
    
  }

  /*_salvarItem() async {

    String nome = _nomeController.text;
    double preco = double.parse(_precoController.text);
    int  qtde =  int.parse(_qtdeController.text);
    String compra_id = _compraidController.text;

    //print("Data Atual " + DateTime.now().toString()); 

    //Objeto da classe item
    Item item = Item(nome, preco, qtde, null , DateTime.now().toString());
    int resultado = await _db.salvarItem(item);
    
     print("Salvar anotação: " + resultado.toString());


     _nomeController.clear();
     _precoController.clear();
     _qtdeController.clear();


     _recuperarItens();
    
 }*/

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

  @override
  void initState() {

    super.initState();

    _recuperarItens();

  }

  _removerItem(int id, double compra, bool operacao) async {
      
      if(operacao == true){
        setState(() {
            valor +=compra;
            
        });
      }
    await _db.removerItem(id);
    
     _recuperarItens();
  }

   //Atualiza o saldo após a adição de itens no carrinho
   
    _disponivel(double compra, bool operacao) {

        if ((compra != null) && (operacao == true)) {
          setState(() {
            valor -= compra;
          });
          print("Subtração ->  Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
        }else if((compra != null) && (operacao == false)){
            setState(() {
            valor += compra;
          });
          print("Adição -> Disponível: ${valor} - Compra: ${compra.toStringAsFixed(2)}");
        }else {
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
              "Valor R\$${totalItem}0 ultrapassa o saldo disponível para compra.",
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

  _resetLimit() async{
      await _db.atualizaLimit();
  }


 
  @override
  Widget build(BuildContext context) {
   
 
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,), 
      
               onPressed:(){
                   _resetLimit();
                    Navigator.pushReplacementNamed(context, "/");
                            
              }              
               
      ),

        title: Text(
          "Lista de Compras",
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
                  color: Colors.green,
                  fontSize: 35,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
          ),
          //Text("${widget.valor}",

          Expanded(
            
            child: ListView.builder(
            itemCount: _itens.length,
            itemBuilder: (context, index) {
              
              //Recuperar item dentro do método recuperarItens
              final item = _itens[index];

              //item.selected !=item.selected;
              
              if (item.status==1) {
                   item.selected=true;
                  
              } else if(item.status == 0) {
                    item.selected=false;
              }

              return Card(

                color: Colors.grey[50],
                elevation: 2.0,

                key: Key(item.toString()),
                
                child: ListTile(                        

                leading: Checkbox(
                      
                    activeColor: Colors.green,
                                         
                     value: item.selected, 

                      onChanged:(bool novoValor){
                        setState(() {
                            item.selected = novoValor;
                            _atualizaStatus(item,item.selected);
                        });

                       
                        if (valor < item.total) {
                           _disponivel(0 , item.selected);
                           _controleSaldo(item.total);
                      } else {
                         _disponivel(item.total , item.selected);
                     }

                      }
                 ),
                                              
                //leading: item.selected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),   

                 title: item.status == 1 ?  Text(item.nome + " - "+ item.total.toStringAsFixed(2), style: TextStyle(color: Colors.green),): Text(item.nome + " - "+ item.total.toStringAsFixed(2)),

                 
                 //Exibir ações dentro do item de lista.
                              
                  trailing: Row(
                    
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
                                        _removerItem(item.id , item.total, item.selected);
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
                  ),
                ),


              );

            },
          ))
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





