import 'dart:async';
import 'package:flutter/material.dart';
import 'Home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 2),(){
       Navigator.pushReplacement(
         context, 
         MaterialPageRoute(builder: (_)=> Home())
         );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Container(

         decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('images/splash.png'),
              fit: BoxFit.cover,
          ),
        ),
          
          /* color: Colors.purple,
          padding: EdgeInsets.all(60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Image.asset("images/logo.png"),
                 Text("Gasto", style: TextStyle(
                     color: Colors.yellow
                 ),
                 textAlign: TextAlign.right,
                )
              ],
            ),
            //child: Image.asset("images/logo.png"),
            
          ),*/ 
       ),   
    );
  }
}