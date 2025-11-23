import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jugador.dart';
import '../models/game_theme.dart'; // Importamos los temas

class DataManager extends ChangeNotifier {
  // --- TEMA ACTUAL ---
  GameTheme temaActual = GameTheme.cyberpunk; // Por defecto

  // --- VARIABLES DE ESTADO ---
  List<Jugador> plantilla = [];
  List<Jugador> convocados = [];
  List<Jugador> titulares = [];
  List<Jugador> suplentes = [];

  int puntosBUC = 0;
  int puntosRival = 0;
  int segundosPartido = 0;
  bool relojCorriendo = false;
  Timer? _timerPartido;

  // --- INICIALIZACIÓN ---
  DataManager() {
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // CARGAR TEMA
    String temaId = prefs.getString('temaId') ?? 'cyberpunk';
    temaActual = GameTheme.getById(temaId);

    // Cargar Listas
    final plantillaString = prefs.getStringList('plantilla') ?? [];
    plantilla = plantillaString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();

    final titularesString = prefs.getStringList('titulares') ?? [];
    titulares = titularesString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();
    
    final suplentesString = prefs.getStringList('suplentes') ?? [];
    suplentes = suplentesString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();

    puntosBUC = prefs.getInt('puntosBUC') ?? 0;
    puntosRival = prefs.getInt('puntosRival') ?? 0;
    segundosPartido = prefs.getInt('segundosPartido') ?? 0;

    notifyListeners();
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // GUARDAR TEMA
    prefs.setString('temaId', temaActual.id);

    prefs.setStringList('plantilla', plantilla.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setStringList('titulares', titulares.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setStringList('suplentes', suplentes.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setInt('puntosBUC', puntosBUC);
    prefs.setInt('puntosRival', puntosRival);
    prefs.setInt('segundosPartido', segundosPartido);
  }

  // --- CAMBIAR TEMA ---
  void cambiarTema(GameTheme nuevoTema) {
    temaActual = nuevoTema;
    _guardarDatos();
    notifyListeners();
  }

  // ... RESTO DE TU CÓDIGO IGUAL QUE ANTES ...
  
  void agregarJugadorPlantilla(String nombre) {
    if (nombre.trim().isEmpty) return;
    plantilla.add(Jugador(nombre: nombre));
    _guardarDatos();
    notifyListeners();
  }

  void eliminarJugadorPlantilla(Jugador jugador) {
    plantilla.remove(jugador);
    _guardarDatos();
    notifyListeners();
  }

  void toggleConvocado(Jugador jugador) {
    if (convocados.contains(jugador)) {
      convocados.remove(jugador);
    } else {
      convocados.add(jugador);
    }
    notifyListeners();
  }

  void limpiarConvocados() {
    convocados.clear();
    notifyListeners();
  }

  void toggleTitular(Jugador jugador) {
    if (titulares.contains(jugador)) {
      titulares.remove(jugador);
    } else {
      titulares.add(jugador);
    }
    notifyListeners();
  }

  void iniciarPartidoLogica() {
    suplentes = convocados.where((j) => !titulares.contains(j)).toList();
    _guardarDatos();
    notifyListeners();
  }

  void toggleReloj() {
    relojCorriendo = !relojCorriendo;
    if (relojCorriendo) {
      _timerPartido = Timer.periodic(const Duration(seconds: 1), (timer) {
        segundosPartido++;
        for (var jugador in titulares) {
          jugador.segundosJugados++;
        }
        if (segundosPartido % 5 == 0) _guardarDatos(); 
        notifyListeners();
      });
    } else {
      _timerPartido?.cancel();
      _guardarDatos(); 
    }
    notifyListeners();
  }

  void cambiarPuntos(bool esBUC, int cantidad) {
    if (esBUC) {
      puntosBUC += cantidad;
      if (puntosBUC < 0) puntosBUC = 0;
    } else {
      puntosRival += cantidad;
      if (puntosRival < 0) puntosRival = 0;
    }
    notifyListeners();
  }

  void reiniciarTiempoPartido() {
    segundosPartido = 0;
    _guardarDatos();
    notifyListeners();
  }

  void reiniciarTiemposJugadores() {
    for (var j in plantilla) {
      j.segundosJugados = 0;
    }
    _guardarDatos();
    notifyListeners();
  }

  void finalizarPartido() {
    _timerPartido?.cancel();
    relojCorriendo = false;
    titulares.clear();
    suplentes.clear();
    convocados.clear();
    segundosPartido = 0;
    puntosBUC = 0;
    puntosRival = 0;
    _guardarDatos();
    notifyListeners();
  }

  bool realizarCambio(Jugador entra, Jugador sale) {
    if (!suplentes.contains(entra) || !titulares.contains(sale)) return false;
    suplentes.remove(entra);
    titulares.remove(sale);
    titulares.add(entra);
    suplentes.add(sale);
    _guardarDatos();
    notifyListeners();
    return true;
  }
  
  String get tiempoPartidoFormateado {
    int minutos = (segundosPartido / 60).floor();
    int segundos = segundosPartido % 60;
    return "${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
  }
  // Verificar si hay un partido en curso o datos guardados
  bool hayPartidoGuardado() {
    // Consideramos que hay partido si el tiempo es > 0 o hay algún punto
    return segundosPartido > 0 || puntosBUC > 0 || puntosRival > 0;
  }
}