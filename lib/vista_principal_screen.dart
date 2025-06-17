import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'detalle_nave_screen.dart';

class HistorialNavesView extends StatelessWidget {
  const HistorialNavesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('naves')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text(
              'NO HAY REGISTROS POR MOSTRAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          }

          final naves = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: naves.length,
            itemBuilder: (context, index) {
              final doc = naves[index];
              final data = doc.data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Sin nombre';
              final estado = data['estado'] ?? 'En curso';

             return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleNaveScreen(docId: doc.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nombre.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: estado == 'Concluido' ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              estado,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (estado == 'Concluido')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _mostrarModalDemurrage(context, data);
                              },
                              child: const Text('Demurrage'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Liquidación FSA')),
                                );
                              },
                              child: const Text('Liquidación FSA'),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            );

            },
          );
        },
      ),
    );
  }
}

// ✅ Función integrada al final:
void _mostrarModalDemurrage(BuildContext context, Map<String, dynamic> nave) {
  final double rate = nave['rate']?.toDouble() ?? 0;
  final double sobrecosto = nave['sobregasto']?.toDouble() ?? 0;
  final double toneladas = nave['toneladas']?.toDouble() ?? 0;
  final String nombre = nave['nombre'] ?? 'Sin nombre';
  final String viaje = nave['viaje'] ?? '-';

  final Timestamp? tsArribo = nave['arribo'];
  final Timestamp? tsDesconexion = nave['desconexion'];

  double demurrageCalculado = 0;
  double diasPlancha = 0;
  double diasOperacion = 0;
  double diasTotales = 0;
  double proporcion = 0;

  if (tsArribo != null && tsDesconexion != null && rate > 0 && sobrecosto > 0 && toneladas > 0) {
    final DateTime arribo = tsArribo.toDate();
    final DateTime desconexion = tsDesconexion.toDate();

    final double horasPlancha = toneladas / 350;
    diasPlancha = horasPlancha / 24;

    final Duration diferencia = desconexion.difference(arribo);
    diasTotales = diferencia.inMinutes / 60 / 24;
    diasOperacion = diasTotales - (6 / 24);

    proporcion = diasOperacion - diasPlancha;
    demurrageCalculado = proporcion * sobrecosto;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Demurrage - $nombre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔹 Viaje: $viaje'),
            Text('🔹 Toneladas: $toneladas'),
            Text('🔹 Rate: $rate'),
            Text('🔹 Sobrecosto (USD): $sobrecosto'),
            Text('🔹 Demurrage calculado (USD): ${demurrageCalculado.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            Text('🔹 Días de plancha: ${diasPlancha.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('🔹 Días reales transcurridos: ${diasTotales.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('🔹 Días de operación: ${diasOperacion.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('🔹 Proporción: ${proporcion.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pdf = pw.Document();

                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Reporte de Demurrage - $nombre',
                              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 12),
                          pw.Text('📌 Viaje: $viaje'),
                          pw.Text('📌 Toneladas: $toneladas'),
                          pw.Text('📌 Rate: $rate'),
                          pw.Text('📌 Sobrecosto (USD): $sobrecosto'),
                          pw.Text('📌 Demurrage calculado: ${demurrageCalculado.toStringAsFixed(2)}'),
                          pw.SizedBox(height: 12),
                          pw.Text('🔹 Días de plancha: ${diasPlancha.toStringAsFixed(2)}'),
                          pw.Text('🔹 Días reales transcurridos: ${diasTotales.toStringAsFixed(2)}'),
                          pw.Text('🔹 Días de operación: ${diasOperacion.toStringAsFixed(2)}'),
                          pw.Text('🔹 Proporción: ${proporcion.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );

                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdf.save(),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
