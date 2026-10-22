import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/models/Clientes.dart';

class ClientesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// GUARDAR CLIENTE
  Future<void> saveCliente({
    required String nombre,
    required String apellidos,
    required String telefono,
    required bool actividad,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final cliente = Clientes(
      id: '',
      nombre: nombre,
      apellidos: apellidos,
      telefono: telefono,
      actividad: actividad,
      uid: currentUser.uid,
    );

    await _firestore.collection('clientes').add(cliente.toMap());
  }

  /// OBTENER CLIENTES
  Stream<List<Clientes>> getClientes() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('clientes')
        .where('uid', isEqualTo: currentUser.uid)
        .orderBy('nombre', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Clientes.fromFirestore(doc)).toList(),
        );
  }

  /// Actualizar cliente
  Future<void> updateCliente({
    required String id,
    required String nombre,
    required String apellidos,
    required String telefono,
    required bool actividad,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final clienteRef = _firestore.collection('clientes').doc(id);

    await clienteRef.update({
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'actividad': actividad,
      'uid': currentUser.uid,
    });
  }

  /// Eliminar cliente
  Future<void> deleteCliente(String id) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final clienteRef = _firestore.collection('clientes').doc(id);

    await clienteRef.delete();
  }
}
