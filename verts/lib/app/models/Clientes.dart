import 'package:cloud_firestore/cloud_firestore.dart';

class Clientes {
  final String id;
  final String nombre;
  final String apellidos;
  final String telefono;
  final bool actividad;
  final String uid;

  Clientes({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.actividad,
    required this.uid,
  });

  factory Clientes.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Clientes(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellidos: data['apellidos'] ?? '',
      telefono: data['telefono']?.toString() ?? '',
      actividad: data['actividad'] ?? true,
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'actividad': actividad,
      'uid': uid,
    };
  }
}
