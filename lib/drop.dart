import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text("Pressione"),
                onPressed: () {
                  openDialog(context); // chama o alert
                })
          ],
        ),
      ),
    );
  }

  void openDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(4),
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
                    print(_value);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
