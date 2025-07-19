class Tire {
  final String id;
  final String size;
  final String brand;
  final String? condition;
  final String? dot;
  final double depth;
  final double price;
  final String? location;
  final String? type;
  final String? entryDate;
  final String? notes;
  final String? photoUrl;

  Tire({
    required this.id,
    required this.size,
    required this.brand,
    this.condition,
    this.dot,
    required this.depth,
    required this.price,
    this.location,
    this.type,
    this.entryDate,
    this.notes,
    this.photoUrl,
  });

  factory Tire.fromJson(Map<String, dynamic> json) {
    return Tire(
      id: json['id_llanta'] ?? '',
      size: json['medida'] ?? '',
      brand: json['marcas'] != null ? json['marcas']['nombre'] : 'Sin marca',
      condition: json['condicion'],
      dot: json['dot'],
      depth: (json['profundidad'] ?? 0.0).toDouble(),
      price: (json['precio'] ?? 0.0).toDouble(),
      location: json['ubicacion'],
      type: json['tipo'],
      entryDate: json['fecha_ingreso'],
      notes: json['notas'],
      photoUrl: json['foto_url'],
    );
  }

  // Método para crear una copia del objeto con algunos campos modificados
  Tire copyWith({
    String? id,
    String? size,
    String? brand,
    String? condition,
    String? dot,
    double? depth,
    double? price,
    String? location,
    String? type,
    String? entryDate,
    String? notes,
    String? photoUrl,
  }) {
    return Tire(
      id: id ?? this.id,
      size: size ?? this.size,
      brand: brand ?? this.brand,
      condition: condition ?? this.condition,
      dot: dot ?? this.dot,
      depth: depth ?? this.depth,
      price: price ?? this.price,
      location: location ?? this.location,
      type: type ?? this.type,
      entryDate: entryDate ?? this.entryDate,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Método para convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_llanta': id,
      'medida': size,
      'id_marca': null, // Se necesitaría el ID de la marca, no solo el nombre
      'condicion': condition,
      'dot': dot,
      'profundidad': depth,
      'precio': price,
      'ubicacion': location,
      'tipo': type,
      'fecha_ingreso': entryDate,
      'notas': notes,
      'foto_url': photoUrl,
    };
  }
}