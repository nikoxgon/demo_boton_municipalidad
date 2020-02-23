import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:seam/services/authentication.dart';

class EncuestaPage extends StatefulWidget {
  EncuestaPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;
  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  final consultaController = TextEditingController();
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
            stream: Firestore.instance.collectionGroup('encuestas').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print(snapshot);
              if (!snapshot.hasData) {
                return Center(
                  child: Text('No hay encuestas disponibles.'),
                );
              } else {
                snapshot.data.documents.removeWhere(
                    (DocumentSnapshot element) =>
                        !(element.data['antiguedad'] == 1));
                print(snapshot.data.documents.first.data['antiguedad']);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data.documents.first.data['consulta'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    RatingBar(
                        tapOnlyMode: true,
                        itemSize: 58,
                        initialRating: 0,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 60,
                        child: new TextField(
                          decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            hintText: '¿Alguna sugerencia?',
                          ),
                          keyboardType: TextInputType.multiline,
                          controller: consultaController,
                          minLines: null,
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        MaterialButton(
                          padding: EdgeInsets.all(20.0),
                          color: Colors.red,
                          textColor: Colors.white,
                          onPressed: (() {
                            widget.auth.getCurrentUser().then((onValue) {
                              Firestore.instance
                                  .collection('users')
                                  .document(onValue.email)
                                  .snapshots()
                                  .first
                                  .then((val) {
                                Firestore.instance
                                    .collection('encuestas')
                                    .document(snapshot
                                        .data.documents.first.documentID)
                                    .collection('respuestas')
                                    .add({
                                  'userId': onValue.email,
                                  'userData': {
                                    'rut': val.data['rut'],
                                    'nombre': val.data['nombre'],
                                    'telefono': val.data['telefono'],
                                    'cuadrante': val.data['cuadrante'],
                                    'residencia': val.data['relacion'],
                                    'anos_comuna': val.data['anos_comuna'],
                                    'sexo': val.data['sexo'],
                                    'fec_nac': val.data['fecha_nac']
                                  },
                                  'respuesta': 'no',
                                  'valor': null,
                                  'comentario': null
                                }).then((val) {
                                  Navigator.pop(context);
                                });
                              });
                            });
                          }),
                          child: Text("NO RESPONDER"),
                        ),
                        MaterialButton(
                          padding: EdgeInsets.all(20.0),
                          textColor: Colors.white,
                          color: Colors.green,
                          onPressed: (() {
                            if (_radioValue == 0) {
                              Fluttertoast.showToast(
                                  msg: "Debe completar la encuesta.",
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.green,
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_LONG,
                                  fontSize: 18.0);
                              return;
                            } else {
                              widget.auth.getCurrentUser().then((onValue) {
                                Firestore.instance
                                    .collection('users')
                                    .document(onValue.email)
                                    .snapshots()
                                    .first
                                    .then((val) {
                                  print(val.data);
                                  Firestore.instance
                                      .collection('encuestas')
                                      .document(snapshot
                                          .data.documents.first.documentID)
                                      .collection('respuestas')
                                      .add({
                                    'userId': onValue.email,
                                    'userData': {
                                      'rut': val.data['rut'],
                                      'nombre': val.data['nombre'],
                                      'telefono': val.data['telefono'],
                                      'cuadrante': val.data['cuadrante'],
                                      'residencia': val.data['relacion'],
                                      'anos_comuna': val.data['anos_comuna'],
                                      'sexo': val.data['sexo'],
                                      'fec_nac': val.data['fecha_nac']
                                    },
                                    'respuesta': 'si',
                                    'valor': _radioValue,
                                    'comentario': consultaController.text
                                  }).then((val) {
                                    Navigator.pop(context);
                                  });
                                });
                              });
                            }
                          }),
                          child: Text("ENVIAR Y CERRAR"),
                        )
                      ],
                    ),
                  ],
                );
              }
            }));
  }
}
