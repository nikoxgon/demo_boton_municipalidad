import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam/pages/shared/appbar.dart';

import 'pendiente.dart';

class SelectionPage extends StatefulWidget {
  SelectionPage({Key key, this.data, this.onSignedOut}) : super(key: key);

  final VoidCallback onSignedOut;
  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  bool _seleccionado = false;

  @override
  void initState() {
    _seleccionado = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: Appbar(),
      body: _seleccionado
          ? new PendientePage(
              data: widget.data, onSignedOut: widget.onSignedOut)
          : Column(
              children: <Widget>[
                Container(
                  height: 20.0,
                ),
                _selectionButton(),
              ],
            ),
    );
  }

  Widget _selectionButton() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0))),
        child: Column(
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
                onPressed: () => _setData(2),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _setData(double tipo) {
    if (tipo == 1) {
      widget.data['tipo'] = 'Domicilio';
    } else {
      widget.data['tipo'] = 'Calle';
    }

    // SET TIMESTAMP AND REF USER
    widget.data['timestamp'] = FieldValue.serverTimestamp();

    Firestore.instance.collection('avisos').add(widget.data).then((onValue) {
      widget.data['documentID'] = onValue.documentID;
      setState(() {
        _seleccionado = true;
        print(_seleccionado);
      });
    }).catchError((onError) {});
  }
}
