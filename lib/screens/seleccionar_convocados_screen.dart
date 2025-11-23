import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class SeleccionarConvocadosScreen extends StatefulWidget {
  const SeleccionarConvocadosScreen({super.key});

  @override
  State<SeleccionarConvocadosScreen> createState() => _SeleccionarConvocadosScreenState();
}

class _SeleccionarConvocadosScreenState extends State<SeleccionarConvocadosScreen> {
  String _filtroBusqueda = ""; // Texto del buscador

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    // 1. Filtrar lista por búsqueda
    List<Jugador> listaFiltrada = data.plantilla.where((j) {
      return j.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase());
    }).toList();

    // 2. Ordenar: Seleccionados PRIMERO, luego No Seleccionados
    listaFiltrada.sort((a, b) {
      bool aSelected = data.convocados.contains(a);
      bool bSelected = data.convocados.contains(b);
      
      if (aSelected && !bSelected) return -1; // a va antes
      if (!aSelected && bSelected) return 1;  // b va antes
      
      // Si ambos tienen el mismo estado, orden alfabético
      return a.nombre.compareTo(b.nombre);
    });

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('CONVOCATORIA', style: TextStyle(color: tema.colorPositivo, fontSize: 16)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BUSCADOR ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(color: tema.textoPrincipal),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: tema.colorPositivo),
                hintText: "Buscar jugador...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: tema.bgPanel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20)
              ),
              onChanged: (texto) {
                setState(() {
                  _filtroBusqueda = texto;
                });
              },
            ),
          ),

          // --- LISTA ---
          Expanded(
            child: ListView.builder(
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final jugador = listaFiltrada[index];
                final esConvocado = data.convocados.contains(jugador);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: esConvocado ? tema.colorPositivo.withOpacity(0.1) : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: esConvocado ? tema.colorPositivo : Colors.transparent, 
                        width: 4
                      ),
                      bottom: BorderSide(color: Colors.white10)
                    ),
                  ),
                  child: ListTile(
                    title: Text(jugador.nombre, 
                      style: TextStyle(
                        color: esConvocado ? Colors.white : tema.textoPrincipal.withOpacity(0.5),
                        fontWeight: esConvocado ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                    trailing: Icon(
                      esConvocado ? Icons.check_circle : Icons.circle_outlined,
                      color: esConvocado ? tema.colorPositivo : Colors.grey,
                    ),
                    onTap: () => data.toggleConvocado(jugador),
                  ),
                );
              },
            ),
          ),

          // --- ZONA INFERIOR ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo.withOpacity(0.5)))
            ),
            child: Column(
              children: [
                Text("SELECCIONADOS: ${data.convocados.length}", 
                   style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(color: tema.colorNegativo)),
                        onPressed: () => data.limpiarConvocados(),
                        child: Text('BORRAR TODO', style: TextStyle(color: tema.colorNegativo)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tema.colorPositivo.withOpacity(0.2),
                          side: BorderSide(color: tema.colorPositivo)
                        ),
                        onPressed: () {
                          if (data.convocados.isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Selecciona al menos un jugador')));
                             return;
                          }
                          Navigator.pushNamed(context, '/elegir_titulares');
                        },
                        child: Text('SIGUIENTE', style: TextStyle(color: tema.colorPositivo)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}