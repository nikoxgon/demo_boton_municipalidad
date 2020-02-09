import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EncuestaPage extends StatefulWidget {
  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  int _radioValue = 0;

  void changeValue(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(228, 1, 51, 1),
          title: Text("ENCUESTA MUNICIPAL"),
          centerTitle: true,
        ),
        body: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "QUE NOTA LE PONE A LA MUNICIPALIDAD CON RESPECTO A LA SEÑALITICA",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Muy Buena", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      new Radio(
                          value: 5,
                          groupValue: _radioValue,
                          onChanged: changeValue),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Buena", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      new Radio(
                          value: 4,
                          groupValue: _radioValue,
                          onChanged: changeValue),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Regular", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      new Radio(
                          value: 3,
                          groupValue: _radioValue,
                          onChanged: changeValue),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Mala", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      new Radio(
                          value: 2,
                          groupValue: _radioValue,
                          onChanged: changeValue),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Pesima", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      new Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: changeValue),
                    ],
                  ),
                ],
              ),
            ),
            new Text(
              "INGRESE ALGUN COMENTARIO O SUGERENCIA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            new TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 1,
            ),
            new FlatButton(
              color: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              onPressed: (() {
                if (_radioValue == 0) {
                  Fluttertoast.showToast(
                      msg: "Debe completar la encuesta.",
                      timeInSecForIos: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      gravity: ToastGravity.TOP,
                      toastLength: Toast.LENGTH_LONG,
                      fontSize: 18.0);
                      return;
                } else {
                  Navigator.pop(context);
                }
              }),
              child: Text(
                "ENVIAR",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        )));
  }
}
