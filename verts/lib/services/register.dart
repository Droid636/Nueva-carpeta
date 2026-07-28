import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar usuario
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(name);

      await _db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'El correo ya está registrado.';

        case 'invalid-email':
          return 'El correo electrónico no es válido.';

        case 'weak-password':
          return 'La contraseña es demasiado débil.';

        case 'configuration-not-found':
          return 'Firebase Auth no está configurado correctamente para este flujo. En Firebase Console habilita Email/Password y revisa la configuración del proyecto.';

        default:
          return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Iniciar sesión
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No existe una cuenta con ese correo.';

        case 'wrong-password':
          return 'Contraseña incorrecta.';

        case 'invalid-email':
          return 'Correo inválido.';

        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';

        default:
          return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Usuario actual
  User? get currentUser => _auth.currentUser;
}
