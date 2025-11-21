class Jugador {
  String nombre;
  int segundosJugados;
  // Podemos agregar más stats aquí en el futuro

  Jugador({
    required this.nombre,
    this.segundosJugados = 0,
  });

  // Convertir a formato JSON para guardar en "TinyDB" (SharedPreferences)
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'segundosJugados': segundosJugados,
      };

  // Crear Jugador desde los datos guardados
  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      nombre: json['nombre'],
      segundosJugados: json['segundosJugados'] ?? 0,
    );
  }

  // Helper para mostrar tiempo formateado 00:00
  String get tiempoFormateado {
    int minutos = (segundosJugados / 60).floor();
    int segundos = segundosJugados % 60;
    String minStr = minutos.toString().padLeft(2, '0');
    String secStr = segundos.toString().padLeft(2, '0');
    return "$minStr:$secStr";
  }
}