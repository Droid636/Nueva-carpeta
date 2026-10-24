import 'package:cloud_firestore/cloud_firestore.dart';

class VentaModel {
  final String id;
  final String designId;
  final String nombreDiseno;
  final String clienteId;
  final String cliente;
  final double precioVenta;
  final bool tieneCostoExtra;
  final String descripcionCostoExtra;
  final double costoExtra;
  final DateTime fecha;
  final String uid;

  VentaModel({
    required this.id,
    required this.designId,
    required this.nombreDiseno,
    this.clienteId = '',
    required this.cliente,
    required this.precioVenta,
    this.tieneCostoExtra = false,
    this.descripcionCostoExtra = '',
    this.costoExtra = 0,
    required this.fecha,
    required this.uid,
  });

  double get gananciaNeta => precioVenta - costoExtra;

  factory VentaModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return VentaModel(
      id: doc.id,
      designId: data['designId'] ?? '',
      nombreDiseno: data['nombreDiseno'] ?? '',
      clienteId: data['clienteId'] ?? '',
      cliente: data['cliente'] ?? '',
      precioVenta: (data['precioVenta'] ?? 0).toDouble(),
      tieneCostoExtra: data['tieneCostoExtra'] ?? false,
      descripcionCostoExtra: data['descripcionCostoExtra'] ?? '',
      costoExtra: (data['costoExtra'] ?? 0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'designId': designId,
      'nombreDiseno': nombreDiseno,
      'clienteId': clienteId,
      'cliente': cliente,
      'precioVenta': precioVenta,
      'tieneCostoExtra': tieneCostoExtra,
      'descripcionCostoExtra': descripcionCostoExtra,
      'costoExtra': costoExtra,
      'fecha': Timestamp.fromDate(fecha),
      'uid': uid,
    };
  }
}
