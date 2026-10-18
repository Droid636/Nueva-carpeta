import 'package:cloud_firestore/cloud_firestore.dart';

class VentaModel {
  final String id;
  final String designId;
  final String nombreDiseno;
  final String cliente;
  final double precioVenta;
  final DateTime fecha;
  final String uid;

  VentaModel({
    required this.id,
    required this.designId,
    required this.nombreDiseno,
    required this.cliente,
    required this.precioVenta,
    required this.fecha,
    required this.uid,
  });

  factory VentaModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return VentaModel(
      id: doc.id,
      designId: data['designId'] ?? '',
      nombreDiseno: data['nombreDiseno'] ?? '',
      cliente: data['cliente'] ?? '',
      precioVenta: (data['precioVenta'] ?? 0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'designId': designId,
      'nombreDiseno': nombreDiseno,
      'cliente': cliente,
      'precioVenta': precioVenta,
      'fecha': Timestamp.fromDate(fecha),
      'uid': uid,
    };
  }
}
