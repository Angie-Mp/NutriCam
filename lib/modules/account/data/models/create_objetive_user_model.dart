import 'package:cloud_firestore/cloud_firestore.dart';

class ObjetiveUserModel {
  final String uid;
  final String objetivo;
  final String tipoMeta;
  final DateTime createdAt;

  ObjetiveUserModel({
    required this.uid,
    required this.objetivo,
    required this.createdAt,
    required this.tipoMeta,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'objetivo': objetivo,
      'createdAt': createdAt,
      'tipoMeta': tipoMeta,
    };
  }

  factory ObjetiveUserModel.fromMap(Map<String, dynamic> map) {
    return ObjetiveUserModel(
      uid: map['uid'],
      objetivo: map['objetivo'],
      tipoMeta: map['tipoMeta'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
