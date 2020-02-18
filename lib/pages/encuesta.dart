import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('encuestas').orderBy('antiguedad').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('No hay encuestas disponibles.'),
                );
              } else {
                // snapshot.data.documents.removeWhere((element) => element.data['antiguedad'] == 1);
                // print(snapshot.data.documents.first.data['antiguedad']);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                Text(
                  snapshot
                      .data.documents.first.data['consulta'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                RatingBar(
                    initialRating: 3,
                    itemCount: 5,
                    itemBuilder: (BuildContext context, index) {
                      switch (index) {
                        case 0:
                          return Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                        case 1:
                          return Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.redAccent,
                          );
                        case 2:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: Colors.amber,
                          );
                        case 3:
                          return Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.lightGreen,
                          );
                        case 4:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                        default:
                          return Container();
                      }
                    },
                    onRatingUpdate: (rating) {
                      print(rating);
                      _radioValue = rating.toInt();
                    }),
                new Text(
                  "INGRESE ALGUN COMENTARIO O SUGERENCIA",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                new TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                ),
                new FlatButton(

                  color: Colors.green,
                  padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  onPressed: (() {
                    if (_radioValue == 0) {
                      Fluttertoast.showToast(
                          msg: "Debe completar la encuesta.",
                          timeInSecForIos: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_LONG,
                          fontSize: 18.0);
                      return;
                    } else {
                      Navigator.pop(context);
                    }
                  }),
                  child: Text(
                    "ENVIAR Y CERRAR",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                  ],
                );
              }
            }));
  }
}
