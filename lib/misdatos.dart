import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MisDatosTab extends StatefulWidget {
  @override
  MisDatosTabState createState() => MisDatosTabState();
}

class MisDatosTabState extends State<MisDatosTab> {
// DATOS

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final rutController = TextEditingController();
  final phoneController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.perm_identity),
              focusedBorder: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          TextFormField(
            controller: surnameController,
            decoration: InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.perm_identity),
              focusedBorder: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          TextFormField(
            controller: rutController,
            decoration: InputDecoration(
                labelText: 'R.U.T',
                prefixIcon: Icon(Icons.perm_contact_calendar),
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
                hintText: '11.111.111-1'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
                labelText: 'Telefono',
                prefixIcon: Icon(Icons.phone),
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
                prefixText: '+56 '),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          OutlineButton(
            child: Text('Actualizar Datos'),
            textColor: Colors.green.shade500,
            borderSide: BorderSide(color: Colors.green.shade500),
            onPressed: () {
              Firestore fb = Firestore.instance;
              FirebaseAuth fa = FirebaseAuth.instance;
              fa.currentUser().then((onValue) {
                fb.collection('users').document(onValue.uid).setData({
                  'nombre': nameController.text,
                  'apellido': surnameController.text,
                  'rut': rutController.text,
                  'telefono': phoneController.text
                }).then((onValue) {
                  final snack = SnackBar(
                      content: Text('Datos Actualizados correctamente.'));
                  Scaffold.of(context).showSnackBar(snack);
                }).catchError((onError) {
                  print('------------------');
                  print('------------------');
                  print('------------------');
                  print(onError);
                  final snack = SnackBar(content: Text(onError));
                  Scaffold.of(context).showSnackBar(snack);
                });
              });
            },
          )
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    surnameController.dispose();
    rutController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
