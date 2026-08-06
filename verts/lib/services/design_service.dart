import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DesignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveDesign({
    required String nombre,
    required bool disponible,
    required File imagen,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imagen.path.split('/').last}';

      final storageRef = _storage.ref().child('disenos/$fileName');

      final uploadTask = await storageRef.putFile(imagen);

      final imageUrl = await uploadTask.ref.getDownloadURL();

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
