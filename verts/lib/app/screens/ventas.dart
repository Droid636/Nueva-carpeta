import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verts/app/models/design_model.dart';
import 'package:verts/app/models/ventas_model.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionCostoExtraController =
      TextEditingController();
  final TextEditingController _costoExtraController = TextEditingController();

  List<DesignModel> _designs = [];
  List<VentaModel> _ventas = [];
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _selectedDesignId;
  DateTime _fechaVenta = DateTime.now();
  bool _tieneCostoExtra = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final designsSnapshot = await FirebaseFirestore.instance
          .collection('disenos')
          .where('uid', isEqualTo: currentUser.uid)
          .get();

      final designs = designsSnapshot.docs
          .map((doc) => DesignModel.fromFirestore(doc))
          .toList();

      final ventasSnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .where('uid', isEqualTo: currentUser.uid)
          .orderBy('fecha', descending: true)
          .get();

      final ventas = ventasSnapshot.docs
          .map((doc) => VentaModel.fromFirestore(doc))
          .toList();

      if (!mounted) return;

      setState(() {
        _designs = designs;
        _ventas = ventas;
        _loading = false;
        _hasError = false;
        _errorMessage = '';

        if (_designs.isNotEmpty &&
            (_selectedDesignId == null ||
                !_designs.any((design) => design.id == _selectedDesignId))) {
          _selectedDesignId = _designs.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = 'No se pudieron cargar los datos: $e';
      });
    }
  }

  double get _gananciaMesActual {
    final now = DateTime.now();
    return _ventas
        .where(
          (venta) =>
              venta.fecha.year == now.year && venta.fecha.month == now.month,
        )
        .fold<double>(0, (sum, venta) => sum + venta.gananciaNeta);
  }

  Future<void> _eliminarVenta(VentaModel venta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text(
          'Eliminar venta',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la venta de ${venta.cliente}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('ventas').doc(venta.id).delete();
      await _cargarDatos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta eliminada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _guardarVenta() async {
    final cliente = _clienteController.text.trim();
    final precio = double.tryParse(_precioController.text.trim()) ?? 0;
    final descripcionCostoExtra = _descripcionCostoExtraController.text.trim();
    final costoExtra = _tieneCostoExtra
        ? double.tryParse(_costoExtraController.text.trim()) ?? 0
        : 0.0;

    if (_selectedDesignId == null || cliente.isEmpty || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa cliente, diseño y precio válido'),
        ),
      );
      return;
    }

    if (_tieneCostoExtra &&
        (descripcionCostoExtra.isEmpty || costoExtra <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indica el concepto del costo extra y un monto válido'),
        ),
      );
      return;
    }

    if (_designs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero registra un diseño')),
      );
      return;
    }

    final designSeleccionado = _designs.firstWhere(
      (design) => design.id == _selectedDesignId,
    );

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    final venta = VentaModel(
      id: '',
      designId: designSeleccionado.id,
      nombreDiseno: designSeleccionado.nombre,
      cliente: cliente,
      precioVenta: precio,
      tieneCostoExtra: _tieneCostoExtra,
      descripcionCostoExtra: _tieneCostoExtra ? descripcionCostoExtra : '',
      costoExtra: costoExtra,
      fecha: _fechaVenta,
      uid: currentUser.uid,
    );

    await _firestore.collection('ventas').add(venta.toMap());

    _clienteController.clear();
    _precioController.clear();
    _descripcionCostoExtraController.clear();
    _costoExtraController.clear();
    _tieneCostoExtra = false;
    _fechaVenta = DateTime.now();

    await _cargarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta registrada correctamente')),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _precioController.dispose();
    _descripcionCostoExtraController.dispose();
    _costoExtraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ventas',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
            )
          : _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D9FF), Color(0xFF2575FC)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ganancias del mes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_gananciaMesActual.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Registrar venta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDesignId,
                    dropdownColor: const Color(0xFF111827),
                    decoration: InputDecoration(
                      labelText: 'Diseño vendido',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: _designs.map((design) {
                      return DropdownMenuItem<String>(
                        value: design.id,
                        child: Text(design.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDesignId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clienteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Cliente',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _precioController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Precio de venta',
                      prefixText: '\$ ',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _tieneCostoExtra,
                    onChanged: (value) {
                      setState(() {
                        _tieneCostoExtra = value;
                      });
                    },
                    title: const Text(
                      '¿Hubo un costo extra en esta venta?',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Actívalo solo si aplica para esta venta',
                      style: TextStyle(color: Colors.white70),
                    ),
                    activeThumbColor: const Color(0xFF00D9FF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (_tieneCostoExtra) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descripcionCostoExtraController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Concepto del costo extra',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _costoExtraController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Monto del costo extra',
                        prefixText: '\$ ',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Fecha de venta',
                      style: TextStyle(color: Colors.white70),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_fechaVenta),
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaVenta,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          _fechaVenta = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardarVenta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2575FC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.sell_rounded, color: Colors.white),
                      label: const Text(
                        'Guardar venta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Ventas recientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_ventas.isEmpty)
                    const Center(
                      child: Text(
                        'Aún no hay ventas registradas',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ventas.length,
                      itemBuilder: (context, index) {
                        final venta = _ventas[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venta.nombreDiseno,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cliente: ${venta.cliente}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (venta.tieneCostoExtra) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Costo extra: ${venta.descripcionCostoExtra}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        'Monto: \$${venta.costoExtra.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(venta.fecha),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Venta: \$${venta.precioVenta.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF00D9FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Neto: \$${venta.gananciaNeta.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _eliminarVenta(venta),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
