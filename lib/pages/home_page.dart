import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_boton/models/todo.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:url_launcher/url_launcher.dart';

import 'package:vibration/vibration.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer _timer;
  bool sendAlert = false;
  bool acceptAlert = false;

  Firestore fs;

  List<Todo> _todoList;

  final Firestore _database = Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<QuerySnapshot> _onTodoAddedSubscription;
  StreamSubscription<QuerySnapshot> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  Text text;
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioCache audioCache;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .collection('demo')
        .orderBy('userId')
        .where('id', isEqualTo: widget.userId);
    _onTodoAddedSubscription = _todoQuery.snapshots().listen(_onEntryAdded);
    _onTodoChangedSubscription = _todoQuery.snapshots().listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifica tu cuenta"),
          // backgroundColor: Color.fromRGBO(21, 19, 18, 1),
          titleTextStyle: TextStyle(color: Colors.black54),
          content: new Text(
              "Porfavor verifica tu cuenta con el link enviado a tu correo."),
          contentTextStyle: TextStyle(color: Colors.black54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Reenviar"),
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Omitir"),
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(QuerySnapshot event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.documentChanges.single.oldIndex;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] = Todo.fromSnapshot(event);
    });
  }

  _onEntryAdded(QuerySnapshot event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event));
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.collection('todo').add(todo.toJson());
    }
  }

  _updateTodo(Todo todo) {
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.collection('todo').document(todo.key).updateData(todo.toJson());
    }
  }

  _deleteTodo(String todoId, int index) {
    _database.collection('todo').document(todoId).delete().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  _showDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget _showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(todoId, index);
              },
              child: ListTile(
                title: Text(
                  subject,
                  style: TextStyle(fontSize: 20.0),
                ),
                trailing: IconButton(
                    icon: (completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
                    onPressed: () {
                      _updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  Widget _showButton() {
    if (!sendAlert) {
      return RawMaterialButton(
        fillColor: Colors.red.shade500,
        highlightColor: Colors.red.shade800,
        elevation: 2,
        constraints: BoxConstraints(
            minWidth: 250, minHeight: 250, maxWidth: 250, maxHeight: 250),
        child:
            Icon(FontAwesomeIcons.exclamation, color: Colors.white, size: 130),
        highlightElevation: 10,
        shape: CircleBorder(
            side: BorderSide(
          color: Colors.grey.shade400,
          width: 5,
        )),
        onHighlightChanged: (estado) {
          if (estado) {
            Vibration.vibrate();
            _timer = Timer.periodic(Duration(seconds: 1), (callback) async {
              print('-------- SEGUNDO:  -----------');
              print('TICK: ' + _timer.tick.toString());

              if (_timer.tick > 2) {
                print(_timer.tick);

                AudioCache audioCache =
                    new AudioCache(fixedPlayer: audioPlayer);
                audioCache.load('audio/beep.mp3').then((onValue) {
                  audioCache.loop('audio/beep.mp3',
                      mode: PlayerMode.LOW_LATENCY);
                });
                await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                    .then((onValue) {
                  final fb = Firestore.instance;
                  fb.collection('latlng').add({
                    'lat': onValue.latitude,
                    'lng': onValue.longitude
                  }).then((val) {
                    Vibration.cancel();
                    setState(() {
                      sendAlert = true;
                      audioPlayer.stop();
                    });
                    SnackBar(content: Text('Ingresado con exito.'));
                  }).catchError((onError) {
                    SnackBar(content: Text('Error.'));
                    print(onError);
                  });
                });
                print('-------- CANCELADO 1 -----------');
                _timer.cancel();
              }
            });
          } else if (!estado && _timer.isActive) {
            print('-------- CANCELADO 2 -----------');
            _timer.cancel();
          }
        },
        onPressed: () {},
      );
    } else {
      return null;
    }
  }

  Widget _showButtonTextAlarm() {
    if (!sendAlert) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        child: Text(
          'PARA EMERGENCIAS PRESIONE EL BOTON POR AL MENOS 3 SEGUNDOS',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return null;
    }
  }

  Widget _showAlarmSendMessage() {
    if (sendAlert && !acceptAlert) {
      return Card(
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'ALARMA Y UBICACION ENVIADA',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'ESPERANDO CONFIRMACION....',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: IconButton(
              icon: Icon(FontAwesomeIcons.map),
              onPressed: () {
                setState(() {
                  acceptAlert = true;
                });
              },
            ),
          )
        ]),
      );
    } else {
      return null;
    }
  }

  Widget _showMapNavegation() {
    if (acceptAlert) {
      Completer<GoogleMapController> _controller = Completer();
      final CameraPosition _kGooglePlex = CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962),
        zoom: 14.4746,
      );
      return Expanded(
          flex: 7,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ));
    } else {
      return null;
    }
  }


  void call(String number) => launch("tel:$number");

  Widget _showMapCall() {
    if (acceptAlert) {
      return Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                child: Text(
                  'Si necesita llamar al movil, \n solo apriete el boton',
                  style: TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: FloatingActionButton(
                  onPressed: () {
                    call('+56964953030');
                  },
                  child: Icon(Icons.call),
                  backgroundColor: Colors.green,
                  tooltip: 'Llamar Patrulla',
                ),
              )
            ],
          ));
    } else {
      return null;
    }
  }

  Widget _showAlarma() {
    return Container(
        height: double.maxFinite,
        child: Column(
          // alignment: AlignmentDirectional.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showButton(),
            _showButtonTextAlarm(),
            _showAlarmSendMessage(),
            _showMapNavegation(),
            _showMapCall()
          ].where((children) => children != null).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/logo_independencia.png',
          height: 40,
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          new FlatButton(
              child:
                  new Icon(FontAwesomeIcons.signOutAlt, color: Colors.indigo),
              onPressed: _signOut)
        ],
      ),
      body: _showAlarma(),
    );
  }
}
