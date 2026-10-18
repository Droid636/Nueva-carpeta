import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/design_service.dart';
import '../models/design_model.dart';

class DisenosPage extends StatelessWidget {
  const DisenosPage({super.key});

  static const List<String> _categorias = [
    'Higway 35',
    'Teku',
    'Metal Maniacs',
    'Silencers',
    'Drones',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    final DesignService designService = DesignService();
    designService.categoriaSeleccionada = null;

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

          if (designs.isEmpty) {
            return const Center(
              child: Text(
                'No hay diseños todavía',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final groupedDesigns = <String, List<DesignModel>>{};
          for (final design in designs) {
            final category = design.categoria.trim().isEmpty
                ? 'Sin categoría'
                : design.categoria.trim();
            groupedDesigns.putIfAbsent(category, () => []).add(design);
          }

          final categories = [
            ..._categorias.where(groupedDesigns.containsKey),
            ...groupedDesigns.keys.where(
              (category) =>
                  !_categorias.contains(category) &&
                  category != 'Sin categoría',
            ),
            if (groupedDesigns.containsKey('Sin categoría')) 'Sin categoría',
          ];

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              for (final category in categories)
                _buildCategoryCarousel(
                  context,
                  category,
                  groupedDesigns[category]!,
                  designService,
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

  Widget _buildCategoryCarousel(
    BuildContext context,
    String category,
    List<DesignModel> designs,
    DesignService designService,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${designs.length}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: designs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final design = designs[index];
                return _buildDesignCard(context, design, designService);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignCard(
    BuildContext context,
    DesignModel design,
    DesignService designService,
  ) {
    return SizedBox(
      width: 200,

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    design.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(
                        color: Colors.white10,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white70,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      children: [
                        _buildCardAction(
                          icon: Icons.edit_outlined,
                          color: const Color(0xFF00D9FF),
                          backgroundColor: Colors.black54,
                          onPressed: () =>
                              _showEditDesignDialog(context, design),
                        ),
                        _buildCardAction(
                          icon: Icons.delete_outline,
                          color: Colors.amber,
                          backgroundColor: Colors.black54,
                          onPressed: () async {
                            await designService.deleteDesign(design.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      design.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 15)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color, size: 19),
        onPressed: onPressed,
      ),
    );
  }

  void _showEditDesignDialog(BuildContext context, DesignModel design) {
    final nombreController = TextEditingController(text: design.nombre);
    File? imagen;
    String imagenUrl = design.imagen;

    final picker = ImagePicker();
    final designService = DesignService();
    designService.categoriaSeleccionada = design.categoria;

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
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: design.categoria.isNotEmpty
                          ? design.categoria
                          : null,
                      items: const [
                        DropdownMenuItem(
                          value: 'Higway 35',
                          child: Text('Higway 35'),
                        ),
                        DropdownMenuItem(value: 'Teku', child: Text('Teku')),
                        DropdownMenuItem(
                          value: 'Metal Maniacs',
                          child: Text('Metal Maniacs'),
                        ),
                        DropdownMenuItem(
                          value: 'Silencers',
                          child: Text('Silencers'),
                        ),
                        DropdownMenuItem(
                          value: 'Drones',
                          child: Text('Drones'),
                        ),

                        DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                      ],
                      onChanged: (String? value) {
                        designService.categoriaSeleccionada = value;
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

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa el nombre del diseño'),
                        ),
                      );
                      return;
                    }

                    try {
                      await designService.updateDesign(
                        id: design.id,
                        nombre: nombre,
                        precio: design.precio,
                        categoria:
                            designService.categoriaSeleccionada ??
                            design.categoria,
                        disponible: design.disponible,
                        publicado: design.publicado,
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
    File? imagen;

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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Higway 35',
                          child: Text('Higway 35'),
                        ),
                        DropdownMenuItem(value: 'Teku', child: Text('Teku')),
                        DropdownMenuItem(
                          value: 'Metal Maniacs',
                          child: Text('Metal Maniacs'),
                        ),
                        DropdownMenuItem(
                          value: 'Silencers',
                          child: Text('Silencers'),
                        ),
                        DropdownMenuItem(
                          value: 'Drones',
                          child: Text('Drones'),
                        ),
                        DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                      ],
                      onChanged: (value) {
                        designService.categoriaSeleccionada = value;
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                  ),
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
                        precio: 0,
                        disponible: true,
                        publicado: true,
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
