// Created using https://app.quicktype.io/

// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<dynamic> postFromJson(String str) {
  final jsonData = json.decode(str);
  return jsonData;
}

class Encuesta {
  final String id;
  final String consulta;

  Encuesta({this.id, this.consulta});

  factory Encuesta.fromJson(List<dynamic> json) {
    return Encuesta(
      id: json.first["id"].toString(),
      consulta: json.first["consulta"],
    );
  }
}

class Respuesta {
  final String type;
  final String respuesta;
  final String valor;
  final String comentario;
  final String uid;
  final String id_encuesta;

  Respuesta(
      {this.type,
      this.respuesta,
      this.valor,
      this.comentario,
      this.uid,
      this.id_encuesta});

  factory Respuesta.fromJson(List<dynamic> json) {
    return Respuesta(
        type: json.first["type"].toString(),
        respuesta: json.first["respuesta"].toString(),
        valor: json.first["valor"].toString(),
        comentario: json.first["comentario"].toString(),
        uid: json.first["uid"].toString(),
        id_encuesta: json.first["id_encuesta"]);
  }


  Map<String, dynamic> toJson() => {
    "type": type,
    "respuesta": respuesta,
    "valor": valor,
    "comentario": comentario,
    "uid": uid,
    "id_encuesta": id_encuesta
  };

}

class EncuestaPost {
  final String type;
  final String user;

  EncuestaPost({this.type, this.user});

  factory EncuestaPost.fromJson(List<dynamic> json) {
    return EncuestaPost(
        type: json.first["type"].toString(),
        user: json.first["user"].toString());
  }

  Map<String, dynamic> toJson() => {"type": type, "user": user};
}

String postToJson(data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

// List<Any> allPostsFromJson(String str) {
//   final jsonData = json.decode(str);
//   return new List<Post>.from(jsonData.map((x) => Post.fromJson(x)));
// }

// String allPostsToJson(List<Post> data) {
//   final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
//   return json.encode(dyn);
// }
