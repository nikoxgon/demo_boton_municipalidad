import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_boton/pages/shared/pendiente.dart';
import 'package:flutter/material.dart';

class SelectionPage extends StatefulWidget {
  SelectionPage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/logo_independencia.png',
          height: 40,
        ),
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
      ),
      body: _selectionButton(),
    );
  }

  Widget _selectionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '¿Donde se encuentra ubicado?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MaterialButton(
            child: Text('Domicilio'),
            color: Colors.indigo,
            textColor: Colors.white,
            minWidth: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            shape: StadiumBorder(),
            onPressed: () => _setData(1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MaterialButton(
            child: Text('Calle'),
            color: Colors.orange,
            textColor: Colors.white,
            minWidth: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            shape: StadiumBorder(),
            onPressed: () => _setData(2),
          ),
        )
      ],
    );
  }

  void _setData(double tipo) {
    widget.data['tipo'] = tipo;

    Firestore.instance.collection('avisos').add(widget.data).then((onValue) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => PendientePage(
                data: widget.data,
              )));
    }).catchError((onError) {
      print(onError);
    });
  }
}