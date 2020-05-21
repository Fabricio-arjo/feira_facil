import 'package:flutter/material.dart';
import 'CarrinhoCompra.dart';
import 'Home.dart';
import 'ListaCompras.dart';


void main() {
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme:ThemeData(
     
    ) 
      
    ,

    //NomearRotas
    initialRoute: "/",
    routes: {
      "/carrinho": (context) => CarrinhoCompra(),
      "/historico": (context) => ListaCompras()
    },
  ));
}

