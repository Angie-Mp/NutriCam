import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountUserModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String edad;
  final String altura;
  final String genero;
  final String pesoActual;
  final String pesoIdeal;
  final String email;
  final bool emailVerified;
  final Timestamp? createdAt;

  CreateAccountUserModel({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.altura,
    required this.genero,
    required this.pesoActual,
    required this.pesoIdeal,
    required this.email,
    this.emailVerified = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'altura': altura,
      'genero': genero,
      'pesoActual': pesoActual,
      'pesoIdeal': pesoIdeal,
      'email': email,
      'emailVerified': emailVerified,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory CreateAccountUserModel.fromMap(Map<String, dynamic> map) {
    return CreateAccountUserModel(
      uid: map['uid'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      edad: map['edad'],
      altura: map['altura'],
      genero: map['genero'],
      pesoActual: map['pesoActual'],
      pesoIdeal: map['pesoIdeal'],
      email: map['email'],
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'],
    );
  }
}
