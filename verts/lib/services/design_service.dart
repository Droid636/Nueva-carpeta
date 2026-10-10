import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app/models/design_model.dart';

class DesignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// GUARDAR DISEÑO
  Future<void> saveDesign({
    required String nombre,
    required double precio,
    required bool disponible,
    required bool publicado,
    required File imagen,
  }) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final storageRef = _storage.ref().child('disenos/$fileName');

    await storageRef.putFile(imagen);

    final imageUrl = await storageRef.getDownloadURL();

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final design = DesignModel(
      id: '',
      nombre: nombre,
      imagen: imageUrl,
      precio: precio,
      disponible: disponible,
      publicado: publicado,
      uid: currentUser.uid,
    );

    await _firestore.collection('disenos').add(design.toMap());
  }

  /// OBTENER DISEÑOS
  Stream<List<DesignModel>> getDesigns() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('disenos')
        .where('uid', isEqualTo: currentUser.uid)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DesignModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// ACTUALIZAR DISEÑO
  Future<void> updateDesign({
    required String id,
    required String nombre,
    required double precio,
    required bool disponible,
    required bool publicado,
    required String imagenUrl,
    File? imagen,
  }) async {
    String finalImageUrl = imagenUrl;

    if (imagen != null) {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('disenos/$fileName');
      await storageRef.putFile(imagen);
      finalImageUrl = await storageRef.getDownloadURL();
    }

    await _firestore.collection('disenos').doc(id).update({
      'nombre': nombre,
      'imagen': finalImageUrl,
      'precio': precio,
      'disponible': disponible,
      'publicado': publicado,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  /// ELIMINAR DISEÑO
  Future<void> deleteDesign(String id) async {
    await _firestore.collection('disenos').doc(id).delete();
  }
}
