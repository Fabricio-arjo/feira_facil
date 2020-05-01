import 'package:flutter/material.dart';
import 'package:feira_facil/CarrinhoCompra.dart';
import 'package:feira_facil/model/Item.dart';
import 'package:feira_facil/helper/ItemHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main(){ runApp(
  
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Home(),

          //NomearRotas
          initialRoute: "/",
          routes: {
            "/carrinho":(context)=> CarrinhoCompra()
          },

      )); 
} 

    class Home extends StatefulWidget {
      @override
      _HomeState createState() => _HomeState();
    }
    
    class _HomeState extends State<Home> {

     GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
     TextEditingController valorController = TextEditingController();
     double limite;
     String prefix="R\$";
     
     
     void limiteGasto(){

       setState(() {
         limite = double.parse(valorController.text);
         valorController.clear();
       });

              
        /*Navigator.push(
              context,
              MaterialPageRoute(
               builder:(context) => CarrinhoCompra(valor: limite,)
             )
        );*/

        Navigator.pushReplacement(context,MaterialPageRoute(
               builder:(context) => CarrinhoCompra(valor: limite,)
        ));

               
     

     }

  

      @override
      Widget build(BuildContext context) {

         return Scaffold(
            
            appBar: AppBar(
              backgroundColor: Colors.purple,
              title: Text("shopping_cart",
              
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold ,
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

                           Padding(padding: EdgeInsets.only(top:60),

                               child:Icon(
                                 Icons.shopping_cart,
                                 size:100.0,
                                 color: Colors.purple,
                               ) ,
                              
                            ),
                            
                           Center(
                                  child: Text("Controle seu gasto",
                                    style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                        
                                     ),
                                     textAlign: TextAlign.center ,
                                    ),
                             ),

                             Padding(padding: EdgeInsets.fromLTRB(60,50,60,30),


                              child:TextFormField(
                                  
                                  
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: valorController,

                                  validator: (value){
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
                                  border: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.green),
                                      
                                  ),
                                  prefixText: prefix,
                                  prefixStyle: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  )
                                  
                                  
                                                           
                               ),
                            ),
                                                       
                          ),

                          Padding(padding: EdgeInsets.fromLTRB(60, 0, 60, 0),  

                            child:RaisedButton.icon(
                              color: Colors.lightGreen,

                              onPressed: (){
                                
                                if (_formKey.currentState.validate()) {
                                   limiteGasto(); 
                                 
                                }
                                                           
                              }, 

                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                               ),
                              icon: Icon(Icons.check, color: Colors.white,size:25,),
                              label:Text(""),
                                          
                            )
                          ),
                                                                     
                        
                       ],
                        
                     )
    
                 ), 
                 
                 
                        
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
                   onPressed: (){

                       showDialog(
                          
                          context: context,
                          builder: (BuildContext context){
                          return AlertDialog(
                              title: Text("Help",
                               style: TextStyle(
                                 color: Colors.purple
                               ),
                              ),
                                content: Text("Helpe-me"),
                                 actions: <Widget>[
                                      FlatButton(
                                          onPressed: (){
                                             Navigator.pop(context);
                                               }, 
                                                child: Text("Ok"),
                                                ),
                                            ],  
                                );
                               }
                              );  
                            }
                      ),
                   ),

          );
            
        }
    }

   
  

