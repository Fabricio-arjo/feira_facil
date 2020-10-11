import 'package:flutter/material.dart';

class CadastroItem extends StatefulWidget {
  @override
  _CadastroItemState createState() => _CadastroItemState();
}

class _CadastroItemState extends State<CadastroItem> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: AlertDialog(
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
                  labelText: "Descrição",

                  //hintText: "Ex: Arroz"
                ),
              ),
            ),
            //Inicio da linha
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(4),
                  width: 100,
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
                  width: 135,
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
                    padding: EdgeInsets.all(8), width: 100, child: Text("Aqui")
                    /*DropdownButton(
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
                            print(_value);
                          },
                        ),*/
                    ),
              ],
            )

            //Fim da Linha
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
            onPressed: () => Navigator.pop(context), child: Icon(Icons.close)),
      ],
    ));
  }
}
