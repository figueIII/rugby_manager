import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class CambiosScreen extends StatefulWidget {
  const CambiosScreen({super.key});

  @override
  State<CambiosScreen> createState() => _CambiosScreenState();
}

class _CambiosScreenState extends State<CambiosScreen> {
  Jugador? titularSeleccionado; // Sale
  Jugador? suplenteSeleccionado; // Entra

  @override
  Widget build(BuildContext context) {
    // Al usar Provider.of sin especificar listen: false, esta pantalla se reconstruye
    // cada vez que el DataManager cambia (es decir, cada segundo del reloj).
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('PROTOCOLO DE SUSTITUCION', style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontSize: 14)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: tema.colorPositivo.withOpacity(0.3), height: 1)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // COLUMNA IZQUIERDA: SALE (Usa colorNegativo)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, 
                        color: tema.colorNegativo.withOpacity(0.1), 
                        padding: const EdgeInsets.all(10),
                        child: Text("SALE (ACTIVO)", 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tema.colorNegativo, letterSpacing: 1, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.titulares.length,
                          itemBuilder: (context, index) {
                            final j = data.titulares[index];
                            final isSelected = titularSeleccionado == j;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? tema.colorNegativo.withOpacity(0.3) : null,
                                border: const Border(bottom: BorderSide(color: Colors.white10))
                              ),
                              child: ListTile(
                                // Usamos Row para poner Nombre a la izq y Tiempo a la der
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(j.nombre, 
                                        style: TextStyle(color: tema.textoPrincipal),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(j.tiempoFormateado, 
                                      style: TextStyle(
                                        color: tema.colorNegativo, // Color rojo/magenta para indicar fatiga/salida
                                        fontFamily: 'Courier', 
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() => titularSeleccionado = j),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: Colors.white10),
                // COLUMNA DERECHA: ENTRA (Usa colorPositivo)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, 
                        color: tema.colorPositivo.withOpacity(0.1), 
                        padding: const EdgeInsets.all(10),
                        child: Text("ENTRA (RESERVA)", 
                           textAlign: TextAlign.center,
                           style: TextStyle(color: tema.colorPositivo, letterSpacing: 1, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.suplentes.length,
                          itemBuilder: (context, index) {
                            final j = data.suplentes[index];
                            final isSelected = suplenteSeleccionado == j;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? tema.colorPositivo.withOpacity(0.3) : null,
                                border: const Border(bottom: BorderSide(color: Colors.white10))
                              ),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(j.nombre, 
                                        style: TextStyle(color: tema.textoPrincipal),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(j.tiempoFormateado, 
                                      style: TextStyle(
                                        color: tema.textoPrincipal.withOpacity(0.5), // Más apagado porque está en banquillo
                                        fontFamily: 'Courier'
                                      )
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() => suplenteSeleccionado = j),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ZONA VALIDACIÓN
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo.withOpacity(0.5))),
            ),
            child: Column(
              children: [
                Text(
                  (titularSeleccionado != null && suplenteSeleccionado != null)
                  ? "${titularSeleccionado!.nombre}  ➔  ${suplenteSeleccionado!.nombre}"
                  : "ESPERANDO SELECCION...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: (titularSeleccionado != null && suplenteSeleccionado != null) ? tema.colorPositivo : Colors.grey
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: tema.textoPrincipal),
                      padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    onPressed: () {
                      if (titularSeleccionado != null && suplenteSeleccionado != null) {
                        bool exito = data.realizarCambio(suplenteSeleccionado!, titularSeleccionado!);
                        if (exito) {
                          Navigator.pop(context);
                        }
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selección incompleta', style: TextStyle(color: tema.bgPrincipal)),
                              backgroundColor: tema.colorPositivo,
                            ));
                      }
                    },
                    child: Text("EJECUTAR INTERCAMBIO", style: TextStyle(color: tema.textoPrincipal, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}