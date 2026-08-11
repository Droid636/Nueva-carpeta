class DesignModel {
  final String id;
  final String nombre;
  final String imagen;
  final bool disponible;

  DesignModel({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.disponible,
  });

  factory DesignModel.fromMap(Map<String, dynamic> data, String id) {
    return DesignModel(
      id: id,
      nombre: data['nombre'] ?? '',
      imagen: data['imagen'] ?? '',
      disponible: data['disponible'] ?? false,
    );
  }
}
