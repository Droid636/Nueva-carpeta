import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verts/services/design_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:verts/app/models/design_model.dart';

class DisenosPage extends StatefulWidget {
  const DisenosPage({super.key});

  @override
  State<DisenosPage> createState() => _DisenosPageState();
}

class _DisenosPageState extends State<DisenosPage> {
  List<DesignModel> _designs = [];
  final DesignService _designService = DesignService();

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    try {
      final designs = await _designService.getDesigns();
      setState(() {
        _designs = designs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar diseños: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2575FC), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  'DISEÑOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 300,
                  child: _designs.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay diseños disponibles',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : CarouselSlider.builder(
                          itemCount: _designs.length,
                          itemBuilder: (context, index, realIndex) {
                            final design = _designs[index];
                            return Card(
                              color: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        design.imagen,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      design.nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      design.disponible
                                          ? 'Disponible'
                                          : 'No disponible',
                                      style: TextStyle(
                                        color: design.disponible
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await _designService.deleteDesign(
                                          design.id,
                                        );
                                        await _loadDesigns();

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Diseño eliminado correctamente',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Eliminar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 300,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                          ),
                        ),
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Agregar Diseño',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final nombreController = TextEditingController();

                      bool disponible = true;
                      File? imagenSeleccionada;

                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF121212),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  'Nuevo Diseño',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final picker = ImagePicker();

                                          final XFile? image = await picker
                                              .pickImage(
                                                source: ImageSource.gallery,
                                              );

                                          if (image != null) {
                                            setState(() {
                                              imagenSeleccionada = File(
                                                image.path,
                                              );
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 140,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color: Colors.white24,
                                            ),
                                          ),
                                          child: imagenSeleccionada != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Image.file(
                                                    imagenSeleccionada!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.image_outlined,
                                                      color: Colors.white70,
                                                      size: 40,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Seleccionar imagen',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      TextField(
                                        controller: nombreController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Nombre del diseño',
                                          labelStyle: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      SwitchListTile(
                                        value: disponible,
                                        activeColor: const Color(0xFF2575FC),
                                        title: const Text(
                                          'Disponible',
                                          style: TextStyle(color: Colors.white),
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
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (nombreController.text
                                          .trim()
                                          .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Ingresa un nombre'),
                                          ),
                                        );
                                        return;
                                      }

                                      if (imagenSeleccionada == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Selecciona una imagen',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        await DesignService().saveDesign(
                                          nombre: nombreController.text.trim(),
                                          disponible: disponible,
                                          imagen: imagenSeleccionada!,
                                        );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Diseño guardado correctamente',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
