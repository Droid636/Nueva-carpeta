import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verts/services/design_service.dart';

class DisenosPage extends StatelessWidget {
  const DisenosPage({super.key});

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
