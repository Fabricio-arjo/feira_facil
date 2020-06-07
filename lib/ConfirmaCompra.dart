import 'package:flutter/material.dart';

class ConfirmaCompra extends StatefulWidget {
  @override
  _ConfirmaCompraState createState() => _ConfirmaCompraState();
}

class _ConfirmaCompraState extends State<ConfirmaCompra> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text("Confirmar dados da compra"),
          centerTitle: true,
          backgroundColor: Colors.purple,
        ),

        body: SingleChildScrollView(
          child: Expanded(
              child: DataTable(
                    columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Produto',
                            style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,fontSize:12,color:Colors.purple),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Valor',
                            style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,fontSize:12,color:Colors.purple),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: Text(
                            'Qtde.\ndesejada',
                            style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,fontSize:12, color:Colors.purple),
                          ),
                        ),
                        DataColumn(
                          numeric:true,
                          label: Text(            
                            'Qtde',
                            style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,fontSize:12,color:Colors.purple),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Editar',
                            style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,fontSize:12,color:Colors.purple),
                          ),
                        ),
                      ],
                      rows: const <DataRow>[
                        DataRow(
                        
                          cells: <DataCell>[
                            DataCell(Text('Item 1')),
                            DataCell(Text('10.00')),
                            DataCell(Text('5')),
                            DataCell(Text('3')),
                            DataCell(Icon(Icons.edit)),
                          ],
                        ),
                        DataRow(
                          
                          cells: <DataCell>[
                            DataCell(Text('Item 2')),
                            DataCell(Text('10.00')),
                            DataCell(Text('5')),
                            DataCell(Text('3')),
                            DataCell(Icon(Icons.edit)),
                          ],
                        ),
                      ],
            ), 
              
           )
         
        ),
        
      
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
        },
        label: Text('Confirmar'),
        icon: Icon(Icons.thumb_up),
        backgroundColor: Colors.green,
      ),
    );
   
  }
}
