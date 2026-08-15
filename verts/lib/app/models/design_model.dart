import 'package:cloud_firestore/cloud_firestore.dart';

class DesignModel {
  final String id;
  final String nombre;
  final String imagen;
  final double precio;
  final bool disponible;
  final bool publicado;
  final DateTime? fecha;

  DesignModel({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.disponible,
    required this.publicado,
    this.fecha,
  });

  factory DesignModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return DesignModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      imagen: data['imagen'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      disponible: data['disponible'] ?? true,
      publicado: data['publicado'] ?? true,
      fecha: (data['fecha'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'imagen': imagen,
      'precio': precio,
      'disponible': disponible,
      'publicado': publicado,
      'fecha': FieldValue.serverTimestamp(),
    };
  }
}
