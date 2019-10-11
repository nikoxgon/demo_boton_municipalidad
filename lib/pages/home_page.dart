import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_boton/models/todo.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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

class _HomePageState extends State<HomePage> {
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
          title: new Text("Verifica tu cuenta."),
          backgroundColor: Color.fromRGBO(54, 58, 129, 1),
          titleTextStyle: TextStyle(color: Colors.white),
          content: new Text("Porfavor verifica tu cuenta con el link enviado a tu correo."),
          contentTextStyle: TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Reenviar"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Omitir"),
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

  Widget _showAlarma() {
    return Scaffold(
      body: Center(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            fillColor: Colors.red.shade500,
            elevation: 30,
            highlightColor: Colors.red.shade800,
            highlightElevation: 100,
            shape: CircleBorder(),
            onPressed: () async {
              AudioCache audioCache = new AudioCache(fixedPlayer: audioPlayer);
              audioCache.load('audio/beep.mp3').then((onValue) {
                audioCache.loop('audio/beep.mp3', mode: PlayerMode.LOW_LATENCY);
              });
              Vibration.vibrate(duration: 10000);
              await Geolocator()
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                  .then((onValue) {
                final fb = Firestore.instance;
                fb.collection('latlng').add({
                  'lat': onValue.latitude,
                  'lng': onValue.longitude
                }).then((val) {
                  SnackBar(content: Text('Ingresado con exito.'));
                }).catchError((onError) {
                  SnackBar(content: Text('Error.'));
                  print(onError);
                });
                setState(() {
                  text = Text(onValue.latitude.toString());
                  Vibration.cancel();
                  audioPlayer.stop();
                });
              });
            },
            constraints: BoxConstraints(
                minWidth: 300, minHeight: 300, maxWidth: 500, maxHeight: 500),
            child: Icon(Icons.phonelink_ring, color: Colors.white, size: 100),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter login demo'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _showAlarma(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showDialog(context);
      //   },
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // )
    );
  }
}
