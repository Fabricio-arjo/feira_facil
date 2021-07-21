import 'package:feira_facil/ListaCompras.dart';
import 'package:flutter/material.dart';
import 'AdicionarCompra.dart';

class Home extends StatefulWidget {
  Home({this.voltar});

  final int voltar;

  @override
  _HomeState createState() => _HomeState(this.voltar);
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  _HomeState(this.voltar);

  int voltar;

  int _tabIndex = 0;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 2,
        vsync: this //SingleTickerProviderStateMixin  colocar no HomeState
        );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _toggleTab(int voltar) {
    if (voltar != null) {
      _tabController.animateTo(voltar);
    } else {
      _tabController.animateTo(0);
    }

    // print("Indice: ${voltar}");
  }

  @override
  Widget build(BuildContext context) {
    _toggleTab(voltar);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(
            "",
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: "Nova"),
              Tab(text: "Realizadas"),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AdicionarCompra(),
          ListaCompras(),
        ],
      ),
    );
  }
}

/*import 'dart:developer';
import 'package:feira_facil/helper/DatabaseHelper.dart';
import 'package:feira_facil/model/Compra.dart';
import 'package:flutter/material.dart';
import 'package:feira_facil/CarrinhoCompra.dart';
import 'package:feira_facil/model/Item.dart';
//import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:feira_facil/helper/CompraHelper.dart';
import 'ListaCompras.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController valorController = TextEditingController();
  double limite;
  String prefix = "R\$";
  var _db = DatabaseHelper();

  /*void limiteGasto() {

    _salvarCompra();
     
       setState(() {
      limite = double.parse(valorController.text);
      valorController.clear();
    });

  
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CarrinhoCompra(
                  valor: limite,
                )));
  }*/

  _salvarCompra() async {
    setState(() {
      limite = double.parse(valorController.text);
    });

    Compra compra = Compra(limite, DateTime.now().toString());
    int resultado = await _db.salvarCompra(compra);

    print("Compra: ${resultado}");

    valorController.clear();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ListaCompras()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ListaCompras()));
            }),
        backgroundColor: Colors.purple,
        title: Text(
          "shopping_cart",
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
                  /*child: Icon(
                    Icons.shopping_cart,
                    size: 100.0,
                    color: Colors.purple,
                  ),*/
                ),
                Center(
                  child: Text(
                    "Control you cash",
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
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Informe o limite a ser gasto.";
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Limite",
                        labelStyle: TextStyle(
                          color: Colors.green,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                        hintText: "Ex: 100.00",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixText: prefix,
                        prefixStyle: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: RaisedButton.icon(
                      color: Colors.lightGreen,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          //limiteGasto();
                          _salvarCompra();
                        }
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
        color: Colors.purple,
        elevation: 20.0,
        child: IconButton(
            icon: Icon(
              Icons.help,
              size: 25,
              color: Colors.white,
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
                        "Limite, é o valor máximo que deseja gastar. Após adicionar itens ao seu carrinho o valor de cada produto será deduzido do valor informado.Permitindo assim, que vc não ultrapasse o valor disponível para compra.",
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
 */
