import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null; // Login correcto
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo.';

        case 'wrong-password':
          return 'Contraseña incorrecta.';

        case 'invalid-email':
          return 'El correo no es válido.';

        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';

        default:
          return e.message;
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
