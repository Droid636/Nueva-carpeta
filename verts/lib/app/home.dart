import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:shimmer/shimmer.dart';
import 'package:verts/app/models/design_model.dart';
import 'package:verts/services/design_service.dart';
import 'package:verts/services/register.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DesignService _designService;
  late Stream<List<DesignModel>> _designStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _designService = DesignService();
    _designStream = _designService.getDesigns();
  }

  void _refreshDesigns() {
    setState(() {
      _designStream = _designService.getDesigns();
    });
  }

  Future<double> _getMonthlySalesTotal() async {
    final now = DateTime.now();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 0;
    }

    final snapshot = await _firestore
        .collection('ventas')
        .where('uid', isEqualTo: currentUser.uid)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final fecha = (data['fecha'] as Timestamp?)?.toDate();
      final precio = (data['precioVenta'] ?? 0).toDouble();

      if (fecha != null && fecha.year == now.year && fecha.month == now.month) {
        total += precio;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    final logout = () async {
      await auth.logout();

      if (!context.mounted) return;

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
    };

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logoNuevo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.paintBrush,
                    color: Colors.blueAccent,
                  ),
                  title: const Text(
                    'Diseños',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/disenos');
                  },
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.moneyBillTrendUp,
                    color: Colors.greenAccent,
                  ),
                  title: const Text(
                    'Ventas',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ventas');
                  },
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.users,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text(
                    'Clientes',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/clientes');
                  },
                ),

                const Spacer(),
                const Divider(color: Colors.white24),

                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.blueGrey,
                  ),
                  title: const Text(
                    'Acerca de',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF121212),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // LOGO
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/logoInfo.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // NOMBRE
                              const Text(
                                'Vert´s Design',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // VERSIÓN
                              const Text(
                                'Versión 1.0.5',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: logout,
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(86),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logoNuevo.png'),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                toolbarHeight: 72,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00D9FF),
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        onRefresh: () async {
          _refreshDesigns();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: StreamBuilder<List<DesignModel>>(
          stream: _designStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final designs = (snapshot.data ?? [])
                .where((design) => design.imagen.isNotEmpty)
                .toList();

            return Container(
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diseños',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/disenos');
                            },
                            child: const Text(
                              'Ver más',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF00D9FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (designs.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No hay diseños para mostrar',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            viewportFraction: 0.65,
                          ),
                          items: designs.map((design) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: design.imagen.isNotEmpty
                                    ? Image.network(
                                        design.imagen,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Shimmer.fromColors(
                                                baseColor: const Color(
                                                  0xFFD3D3D3,
                                                ),
                                                highlightColor: const Color(
                                                  0xFFEEEEEE,
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFD3D3D3,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white.withValues(
                                                  alpha: 0.08,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: Colors.white70,
                                                    size: 42,
                                                  ),
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.white70,
                                            size: 42,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Venta de diseños',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/ventas');
                            },
                            child: const Text(
                              'Ver más',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF00D9FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<double>(
                        future: _getMonthlySalesTotal(),
                        builder: (context, snapshot) {
                          final total = snapshot.data ?? 0.0;
                          final goal = 1500.0;
                          final progress = (total / goal).clamp(0.0, 1.0);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF101826), Color(0xFF0B1020)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CustomPaint(
                                    painter: _SalesGaugePainter(
                                      progress: progress,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                          const Text(
                                            'meta',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ventas del mes',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.trending_up_rounded,
                                            color: Color(0xFF3AE374),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Meta: \$${goal.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            width: 220 * progress,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              gradient: LinearGradient(
                                                colors: progress >= 0.6
                                                    ? const [
                                                        Color(0xFF3AE374),
                                                        Color(0xFF00C853),
                                                      ]
                                                    : const [
                                                        Color(0xFFFF8A65),
                                                        Color(0xFFF44336),
                                                      ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SalesGaugePainter extends CustomPainter {
  final double progress;

  _SalesGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: progress >= 0.6
            ? const [Color(0xFF3AE374), Color(0xFF00C853)]
            : const [Color(0xFFFF8A65), Color(0xFFF44336)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
