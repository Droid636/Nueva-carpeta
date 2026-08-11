import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:verts/app/models/design_model.dart';

class DesignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Obtener diseños

  Future<List<DesignModel>> getDesigns() async {
    final snapshot = await _firestore
        .collection('disenos')
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return DesignModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  //eliminar diseño

  Future<void> deleteDesign(String id) async {
    try {
      await _firestore.collection('disenos').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar diseño: $e');
    }
  }

  // Guardar diseño

  Future<void> saveDesign({
    required String nombre,

    required bool disponible,

    required File imagen,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imagen.path.split('/').last}';

      final storageRef = _storage.ref().child('disenos/$fileName');

      // Subir imagen

      final uploadTask = await storageRef.putFile(imagen);

      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Guardar datos

      await _firestore.collection('disenos').add({
        'nombre': nombre,

        'imagen': imageUrl,

        'disponible': disponible,

        'fecha': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al guardar diseño: $e');
    }
  }
}
