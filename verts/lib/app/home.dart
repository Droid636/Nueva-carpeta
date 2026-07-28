import 'package:flutter/material.dart';
import 'package:verts/services/register.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.home, size: 80),

            const SizedBox(height: 20),

            const Text(
              'Bienvenido a Verts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (user != null)
              Text(user.email ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
