import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/design_service.dart';
import '../models/design_model.dart';

class GananciaVelocimetro extends StatelessWidget {
  final double gananciaActual;
  final double objetivo;

  const GananciaVelocimetro({
    super.key,
    required this.gananciaActual,
    required this.objetivo,
  });

  @override
  Widget build(BuildContext context) {
    const valorMaximo = 1000.0;
    final progreso = (gananciaActual.clamp(0.0, valorMaximo) / valorMaximo)
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            'Ganancia actual',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _VelocimetroPainter(progreso: progreso),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${gananciaActual.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meta: \$${valorMaximo.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                '${(progreso * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${valorMaximo.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VelocimetroPainter extends CustomPainter {
  final double progreso;

  const _VelocimetroPainter({required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.74);
    final radius = size.width * 0.38;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, backgroundPaint);

    final progressPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi * progreso, false, progressPaint);

    final angle = math.pi + (math.pi * progreso);
    final pointerEnd = Offset(
      center.dx + math.cos(angle) * (radius - 12),
      center.dy + math.sin(angle) * (radius - 12),
    );

    final pointerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, pointerEnd, pointerPaint);

    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF2575FC));
  }

  @override
  bool shouldRepaint(covariant _VelocimetroPainter oldDelegate) {
    return oldDelegate.progreso != progreso;
  }
}

class DisenosPage extends StatelessWidget {
  const DisenosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DesignService designService = DesignService();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MIS DISEÑOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),

      body: StreamBuilder<List<DesignModel>>(
        stream: designService.getDesigns(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final designs = snapshot.data!;
          final totalVentas = designs
              .where((design) => design.publicado && design.precio > 0)
              .fold<double>(0, (sum, design) => sum + design.precio);
          final gananciaActual = totalVentas;
          final objetivo = 100.0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GananciaVelocimetro(
                  gananciaActual: gananciaActual,
                  objetivo: objetivo,
                ),
              ),
              if (designs.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No hay diseños todavía',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: designs.length,
                    itemBuilder: (context, index) {
                      final design = designs[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              design.imagen,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),

                          title: Text(
                            design.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                '\$${design.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF00D9FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                design.publicado
                                    ? (design.disponible
                                          ? '🟢 Disponible'
                                          : '🔴 No disponible')
                                    : '📝 Borrador',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF00D9FF),
                                ),
                                onPressed: () {
                                  _showEditDesignDialog(context, design);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  await designService.deleteDesign(design.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2575FC),

        onPressed: () {
          _showAddDesignDialog(context);
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          'Agregar diseño',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showEditDesignDialog(BuildContext context, DesignModel design) {
    final nombreController = TextEditingController(text: design.nombre);
    final precioController = TextEditingController(
      text: design.precio.toStringAsFixed(2),
    );

    File? imagen;
    bool disponible = design.disponible;
    bool publicado = design.publicado;
    String imagenUrl = design.imagen;

    final picker = ImagePicker();
    final designService = DesignService();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF121212),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Text(
                'Editar diseño',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            imagen = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: imagen != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(imagen!, fit: BoxFit.cover),
                              )
                            : Image.network(
                                imagenUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white70,
                                      size: 45,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nombre del diseño',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2575FC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: precioController,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2575FC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Ganancia estimada: \$${(double.tryParse(precioController.text) ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF00D9FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Otros gastos (70%): \$${(((double.tryParse(precioController.text) ?? 0) * 0.7)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: disponible,
                      activeThumbColor: const Color(0xFF00D9FF),
                      title: Text(
                        disponible ? 'Disponible' : 'No disponible',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setState(() {
                          disponible = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: publicado,
                      activeThumbColor: const Color(0xFF00D9FF),
                      title: Text(
                        publicado ? 'Publicado' : 'Borrador',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setState(() {
                          publicado = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                  ),
                  onPressed: () async {
                    final nombre = nombreController.text.trim();
                    final precio = double.tryParse(precioController.text) ?? 0;

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa el nombre del diseño'),
                        ),
                      );
                      return;
                    }

                    final publicadoFinal = publicado || precio > 0;

                    try {
                      await designService.updateDesign(
                        id: design.id,
                        nombre: nombre,
                        precio: precio,
                        disponible: disponible,
                        publicado: publicadoFinal,
                        imagenUrl: imagenUrl,
                        imagen: imagen,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diseño actualizado correctamente'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDesignDialog(BuildContext context) {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();

    File? imagen;
    bool disponible = true;

    final picker = ImagePicker();
    final designService = DesignService();

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF121212),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),

              title: const Text(
                'Nuevo Diseño',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    /// IMAGEN
                    InkWell(
                      onTap: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (image != null) {
                          setState(() {
                            imagen = File(image.path);
                          });
                        }
                      },

                      child: Container(
                        height: 150,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.white10,

                          borderRadius: BorderRadius.circular(15),

                          border: Border.all(color: Colors.white24),
                        ),

                        child: imagen != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),

                                child: Image.file(imagen!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: Colors.white70,
                                    size: 45,
                                  ),

                                  SizedBox(height: 10),

                                  Text(
                                    'Seleccionar imagen',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// NOMBRE
                    TextField(
                      controller: nombreController,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'Nombre del diseño',

                        labelStyle: const TextStyle(color: Colors.white70),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: const BorderSide(color: Colors.white24),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: const BorderSide(
                            color: Color(0xFF2575FC),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// PRECIO
                    TextField(
                      controller: precioController,
                      onChanged: (_) => setState(() {}),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'Precio',

                        prefixText: '\$ ',

                        labelStyle: const TextStyle(color: Colors.white70),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: const BorderSide(color: Colors.white24),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: const BorderSide(
                            color: Color(0xFF2575FC),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Ganancia estimada del diseño completo
                    Text(
                      'Ganancia estimada: \$${(double.tryParse(precioController.text) ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF00D9FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Otros gastos (70%): \$${(((double.tryParse(precioController.text) ?? 0) * 0.7)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    /// DISPONIBILIDAD
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,

                      value: disponible,

                      activeThumbColor: const Color(0xFF00D9FF),

                      title: Text(
                        disponible ? 'Disponible' : 'No disponible',

                        style: const TextStyle(color: Colors.white),
                      ),

                      onChanged: (value) {
                        setState(() {
                          disponible = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Cancelar'),
                ),

                TextButton(
                  onPressed: () async {
                    if (imagen == null || nombreController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona imagen y nombre del diseño',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await designService.saveDesign(
                        nombre: nombreController.text.trim(),
                        precio: double.tryParse(precioController.text) ?? 0,
                        disponible: false,
                        publicado: false,
                        imagen: imagen!,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Borrador guardado correctamente'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Guardar borrador'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                  ),

                  onPressed: () async {
                    if (imagen == null ||
                        nombreController.text.isEmpty ||
                        precioController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa nombre, imagen y precio'),
                        ),
                      );

                      return;
                    }

                    final publicadoFinal = true;

                    try {
                      await designService.saveDesign(
                        nombre: nombreController.text.trim(),
                        precio: double.parse(precioController.text),
                        disponible: disponible,
                        publicado: publicadoFinal,
                        imagen: imagen!,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diseño guardado correctamente'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },

                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
