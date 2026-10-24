import 'package:flutter/material.dart';
import 'package:verts/app/models/Clientes.dart';
import 'package:verts/app/models/ventas_model.dart';
import 'package:verts/services/Clientes.dart';

class ClientesPage extends StatefulWidget {
  ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  static const _background = Color(0xFF0B1020);
  static const _surface = Color(0xFF111827);
  static const _muted = Color(0xFF94A3B8);
  static const _cyan = Color(0xFF00D9FF);
  static const _blue = Color(0xFF2575FC);

  final ClientesService _clientesService = ClientesService();
  final Set<String> _clientesConComprasAbiertas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clientes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: StreamBuilder<List<Clientes>>(
        stream: _clientesService.getClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _cyan));
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final clientes = snapshot.data ?? const <Clientes>[];
          final activos = clientes.where((cliente) => cliente.actividad).length;

          return StreamBuilder<List<VentaModel>>(
            stream: _clientesService.getVentas(),
            builder: (context, ventasSnapshot) {
              if (ventasSnapshot.hasError) {
                return _buildErrorState(ventasSnapshot.error);
              }

              if (!ventasSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: _cyan),
                );
              }

              final ventas = ventasSnapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryCard(clientes.length, activos),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Directorio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _CountBadge(count: clientes.length),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (clientes.isEmpty)
                    _buildEmptyState(context)
                  else
                    for (final cliente in clientes) ...[
                      _buildClienteCard(
                        context,
                        cliente,
                        _ventasDelCliente(cliente, ventas),
                        _clientesConComprasAbiertas.contains(cliente.id),
                        () {
                          setState(() {
                            if (!_clientesConComprasAbiertas.remove(
                              cliente.id,
                            )) {
                              _clientesConComprasAbiertas.add(cliente.id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClienteDialog(context),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Agregar cliente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int total, int activos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142A48), Color(0xFF172554)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.groups_2_rounded, color: _cyan, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clientes registrados',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 42,
            width: 1,
            color: Colors.white.withOpacity(0.12),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activos',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3AE374),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$activos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<VentaModel> _ventasDelCliente(
    Clientes cliente,
    List<VentaModel> ventas,
  ) {
    final nombreCompleto = '${cliente.nombre} ${cliente.apellidos}'
        .trim()
        .toLowerCase();

    return ventas
        .where(
          (venta) =>
              venta.clienteId == cliente.id ||
              (nombreCompleto.isNotEmpty &&
                  venta.clienteId.isEmpty &&
                  venta.cliente.trim().toLowerCase() == nombreCompleto),
        )
        .toList();
  }

  Widget _buildClienteCard(
    BuildContext context,
    Clientes cliente,
    List<VentaModel> compras,
    bool comprasAbiertas,
    VoidCallback onToggleCompras,
  ) {
    final nombreCompleto = '${cliente.nombre} ${cliente.apellidos}'.trim();
    final nombreParaAvatar = cliente.nombre.trim();
    final inicial = nombreParaAvatar.isEmpty
        ? '?'
        : nombreParaAvatar.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_cyan.withOpacity(0.22), _blue.withOpacity(0.30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                alignment: Alignment.center,
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCompleto.isEmpty ? 'Sin nombre' : nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: _muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cliente.telefono.isEmpty
                                ? 'Sin teléfono'
                                : cliente.telefono,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _StatusBadge(isActive: cliente.actividad),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Eliminar cliente',
                onPressed: () => _confirmarEliminacion(context, cliente),
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFFF7A7A),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5A5F).withOpacity(0.10),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onToggleCompras,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Diseños comprados (${compras.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    comprasAbiertas ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: comprasAbiertas
                ? Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: compras.isEmpty
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Sin compras registradas',
                              style: TextStyle(color: _muted, fontSize: 12),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final compra in compras)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.checkroom_rounded,
                                        color: _cyan,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          compra.nombreDiseno,
                                          style: const TextStyle(
                                            color: _muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: _cyan,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes clientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Agrega tu primer contacto para empezar a crear relaciones.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, height: 1.45, fontSize: 13),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _showAddClienteDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar cliente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _cyan,
              side: BorderSide(color: _cyan.withOpacity(0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFFF7A7A),
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los clientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminacion(
    BuildContext context,
    Clientes cliente,
  ) async {
    final nombre = '${cliente.nombre} ${cliente.apellidos}'.trim();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF151E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFF7A7A),
          size: 30,
        ),
        title: const Text(
          'Eliminar cliente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Deseas eliminar a ${nombre.isEmpty ? 'este cliente' : nombre}?',
          style: const TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: _muted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB93845),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await _clientesService.deleteCliente(cliente.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente eliminado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el cliente: $error'),
          backgroundColor: const Color(0xFFB93845),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddClienteDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddClienteDialog(),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF172554),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count en total',
        style: const TextStyle(
          color: Color(0xFF8BE9FD),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF3AE374) : const Color(0xFFFF8A8A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

  static const _dialogBackground = Color(0xFF151E30);
  static const _accent = Color(0xFF00D9FF);

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScaffoldMessenger.of(context);

    return AlertDialog(
      backgroundColor: _dialogBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuevo cliente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre',
              icon: Icons.person_outline_rounded,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _apellidosController,
              label: 'Apellidos',
              icon: Icons.badge_outlined,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _telefonoController,
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _actividad ? 'Cliente activo' : 'Cliente inactivo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              value: _actividad,
              activeThumbColor: _accent,
              onChanged: _guardando
                  ? null
                  : (value) => setState(() => _actividad = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        FilledButton.icon(
          onPressed: _guardando ? null : _guardarCliente,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2575FC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          icon: _guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(_guardando ? 'Guardando' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: _accent, size: 20),
        filled: true,
        fillColor: const Color(0xFF0B1020),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    );
  }

  Future<void> _guardarCliente() async {
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final telefono = _telefonoController.text.trim();
    final telefonoValido =
        RegExp(r'^[0-9+() -]+$').hasMatch(telefono) &&
        RegExp(r'\d').hasMatch(telefono);

    if (nombre.isEmpty || apellidos.isEmpty || !telefonoValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre y un teléfono válido.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await ClientesService().saveCliente(
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
        actividad: _actividad,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente registrado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el cliente: $error'),
          backgroundColor: const Color(0xFFB93845),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _guardando = false);
    }
  }
}
