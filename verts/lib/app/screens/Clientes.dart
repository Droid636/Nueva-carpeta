import 'package:flutter/material.dart';
import 'package:verts/app/models/Clientes.dart';
import 'package:verts/services/Clientes.dart';

class ClientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clientes',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<List<Clientes>>(
        stream: ClientesService().getClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay clientes disponibles.'));
          }

          final clientes = snapshot.data!;

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];

              return Card(
                color: const Color(0xFF121212),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Imagen del cliente
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade800,
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Datos en dos filas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${cliente.nombre} ${cliente.apellidos}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.white54,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    cliente.telefono,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  cliente.actividad
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: cliente.actividad
                                      ? Colors.green
                                      : Colors.red,
                                  size: 17,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cliente.actividad ? 'Activo' : 'Inactivo',
                                  style: TextStyle(
                                    color: cliente.actividad
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddClienteDialog(context);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,

        label: const Text(
          'Agregar cliente',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showAddClienteDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddClienteDialog(),
    );
  }
}

class _AddClienteDialog extends StatefulWidget {
  const _AddClienteDialog();

  @override
  State<_AddClienteDialog> createState() => _AddClienteDialogState();
}

class _AddClienteDialogState extends State<_AddClienteDialog> {
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _actividad = true;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    return AlertDialog(
      title: const Text('Agregar Cliente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _apellidosController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Apellidos'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_actividad ? 'Activo' : 'Inactivo'),
                Switch(
                  value: _actividad,
                  onChanged: _guardando
                      ? null
                      : (value) {
                          setState(() {
                            _actividad = value;
                          });
                        },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardando
              ? null
              : () async {
                  final nombre = _nombreController.text.trim();
                  final apellidos = _apellidosController.text.trim();
                  final telefono = _telefonoController.text.trim();
                  final telefonoValido =
                      RegExp(r'^[0-9+() -]+$').hasMatch(telefono) &&
                      RegExp(r'\d').hasMatch(telefono);

                  if (nombre.isEmpty || apellidos.isEmpty || !telefonoValido) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingresa el nombre y un teléfono válido.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _guardando = true;
                  });

                  try {
                    await ClientesService().saveCliente(
                      nombre: nombre,
                      apellidos: apellidos,
                      telefono: telefono,
                      actividad: _actividad,
                    );

                    if (!mounted) return;
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Cliente registrado correctamente.'),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('No se pudo guardar: $e')),
                    );
                    setState(() {
                      _guardando = false;
                    });
                  }
                },
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
