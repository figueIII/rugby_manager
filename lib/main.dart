import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_manager.dart';
import 'screens/inicio_screen.dart';
import 'screens/gestion_plantilla_screen.dart';
import 'screens/seleccionar_convocados_screen.dart';
import 'screens/elegir_titulares_screen.dart';
import 'screens/partido_screen.dart';
import 'screens/cambios_screen.dart';
 
void main() {
  runApp(
    // Inyectamos el DataManager en toda la app
    ChangeNotifierProvider(
      create: (context) => DataManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Equipo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioScreen(),
        '/gestion_plantilla': (context) => const GestionPlantillaScreen(),
        '/seleccionar_convocados': (context) => const SeleccionarConvocadosScreen(),
        '/elegir_titulares': (context) => const ElegirTitularesScreen(),
        '/partido': (context) => const PartidoScreen(),
        '/cambios': (context) => const CambiosScreen(),
      },
    );
  }
}