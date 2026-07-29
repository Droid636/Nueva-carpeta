import 'package:flutter/material.dart';
import 'package:verts/services/register.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    final String email = user?.email ?? '';
    final String inicial = email.isNotEmpty
        ? email.substring(0, 1).toUpperCase()
        : "V";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.65),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// Barra superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "VERT'S STORE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await auth.logout();

                          if (!context.mounted) return;

                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// Avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF2575FC),
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 42,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "¡Bienvenido!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Has iniciado sesión correctamente",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 35),

                  /// Tarjeta
                  SizedBox(
                    height: 170,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildMenuCard(
                            context,
                            icon: Icons.inventory_2_outlined,
                            titulo: "Inventario",
                            route: "/inventario",
                            color: const Color(0xFF00D9FF),
                          ),

                          const SizedBox(width: 15),
                          _buildMenuCard(
                            context,
                            icon: Icons.shopping_cart_outlined,
                            titulo: "Ventas",
                            route: "/ventas",
                            color: const Color(0xFF2575FC),
                          ),

                          const SizedBox(width: 15),

                          _buildMenuCard(
                            context,
                            icon: Icons.attach_money_rounded,
                            titulo: "Ganancias",
                            route: "/ganancias",
                            color: const Color(0xFF7B2CFF),
                          ),

                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00D9FF),
                            Color(0xFF2575FC),
                            Color(0xFF7B2CFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await auth.logout();

                          if (!context.mounted) return;

                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          shadowColor: Colors.white.withValues(alpha: 0.12),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),

                        label: const Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMenuCard(
  BuildContext context, {
  required IconData icon,
  required String titulo,
  required Color color,
  required String route,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () {
      Navigator.pushNamed(context, route);
    },
    child: Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 30),
          ),

          const SizedBox(height: 12),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
