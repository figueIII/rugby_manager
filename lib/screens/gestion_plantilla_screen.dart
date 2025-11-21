import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';

class GestionPlantillaScreen extends StatefulWidget {
  const GestionPlantillaScreen({super.key});

  @override
  State<GestionPlantillaScreen> createState() => _GestionPlantillaScreenState();
}

class _GestionPlantillaScreenState extends State<GestionPlantillaScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('GESTION DE UNIDADES', style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontSize: 16)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo), // Color de la flecha atrás
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: tema.colorPositivo.withOpacity(0.3), height: 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- INPUT ZONA ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: tema.textoPrincipal),
                    decoration: InputDecoration(
                      labelText: 'Identificador de la unidad',
                      labelStyle: TextStyle(color: tema.textoPrincipal.withOpacity(0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: tema.colorPositivo.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: tema.colorPositivo),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tema.colorPositivo.withOpacity(0.2),
                    foregroundColor: tema.colorPositivo,
                    side: BorderSide(color: tema.colorPositivo),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  onPressed: () {
                    data.agregarJugadorPlantilla(_nameController.text);
                    _nameController.clear();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: tema.bgPanel,
              child: Text("BASE DE DATOS DE JUGADORES", 
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: tema.textoPrincipal, letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            // --- LISTA JUGADORES ---
            Expanded(
              child: ListView.builder(
                itemCount: data.plantilla.length,
                itemBuilder: (context, index) {
                  final jugador = data.plantilla[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: tema.bgPanel.withOpacity(0.5),
                      border: Border(left: BorderSide(color: tema.colorPositivo, width: 3)),
                    ),
                    child: ListTile(
                      leading: Text("${index + 1}", style: TextStyle(color: tema.colorPositivo, fontSize: 18, fontFamily: 'Courier')),
                      title: Text(jugador.nombre, style: TextStyle(color: tema.textoPrincipal)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: tema.colorNegativo),
                        onPressed: () => data.eliminarJugadorPlantilla(jugador),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}