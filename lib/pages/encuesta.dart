import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:seam/models/model_post.dart';
import 'package:seam/services/authentication.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class EncuestaPage extends StatefulWidget {
  EncuestaPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;
  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  final consultaController = TextEditingController();
  int _radioValue = 0;
  String _uid;

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
        body: FutureBuilder(
            future: createPost(),
            builder: (context, snapshot) {
              if (snapshot == null || snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        snapshot.data.consulta,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    ),
                    RatingBar(
                        tapOnlyMode: true,
                        itemSize: 48,
                        initialRating: 0,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                        onRatingUpdate: (rating) {
                          _radioValue = rating.toInt();
                        }),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      height: 58,
                      child: TextField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          hintText: '¿Alguna sugerencia?',
                        ),
                        keyboardType: TextInputType.multiline,
                        controller: consultaController,
                        minLines: null,
                        maxLines: null,
                        expands: true,
                        autocorrect: false,
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
                            sendRespuesta(snapshot);
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
                              sendRespuestaSi(snapshot);
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

  Future sendRespuesta(snapshot) async {
    final url =
        'https://c219zjx0le.execute-api.us-east-1.amazonaws.com/PROD/encuestas';
    final Respuesta data = Respuesta(
        type: "respuestaEncuesta",
        respuesta: "no",
        valor: '',
        comentario: '',
        uid: _uid,
        id_encuesta: snapshot.data.id);
    final response = await http.post('$url',
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postToJson(data));
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('Error al response encuesta');
    }
  }

  Future sendRespuestaSi(snapshot) async {
    final url =
        'https://c219zjx0le.execute-api.us-east-1.amazonaws.com/PROD/encuestas';
    final Respuesta data = Respuesta(
        type: "respuestaEncuesta",
        respuesta: 'si',
        valor: _radioValue.toString(),
        comentario: consultaController.text,
        uid: _uid,
        id_encuesta: snapshot.data.id);
    final response = await http.post('$url',
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postToJson(data));
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('Error al response encuesta');
    }
  }

  Future createPost() async {
    return widget.auth.getCurrentUser().then((onValue) async {
      _uid = onValue.uid;
      final EncuestaPost post = EncuestaPost(type: "get", user: onValue.uid);
      final url =
          'https://c219zjx0le.execute-api.us-east-1.amazonaws.com/PROD/encuestas';
      final response = await http.post('$url',
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: postToJson(post));
      print(response.body);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        return Encuesta.fromJson(json.decode(response.body));
      } else {
        // If the server did not return a 200 OK response, then throw an exception.
        throw Exception('Failed to load Encuesta');
      }
    });
  }

  Widget _getFirebase() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collectionGroup('encuestas').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No hay encuestas disponibles.'),
            );
          } else {
            snapshot.data.documents.removeWhere((DocumentSnapshot element) =>
                !(element.data['antiguedad'] == 1));
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    snapshot.data.documents.first.data['consulta'],
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                RatingBar(
                    tapOnlyMode: true,
                    itemSize: 58,
                    initialRating: 0,
                    itemCount: 5,
                    onRatingUpdate: (rating) {
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
                                .document(
                                    snapshot.data.documents.first.documentID)
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
                              Firestore.instance
                                  .collection('encuestas')
                                  .document(
                                      snapshot.data.documents.first.documentID)
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
        });
  }
}
