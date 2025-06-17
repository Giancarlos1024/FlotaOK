import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetalleNaveScreen extends StatefulWidget {
  final String docId;

  const DetalleNaveScreen({super.key, required this.docId});

  @override
  State<DetalleNaveScreen> createState() => _DetalleNaveScreenState();
}

class _DetalleNaveScreenState extends State<DetalleNaveScreen> {
  final List<String> etapas = [
    'Arribo de la Nave',
    'ETAPA 1',
    'ETAPA 2',
    'ETAPA 3',
    'ETAPA 4',
    'ETAPA 5',
    'ETAPA 6',
    'ETAPA 7',
    'Termino de Desconexion',
  ];

  late List<bool> checks;
  late List<TextEditingController> desdeControllers;
  Map<String, dynamic>? datosNave;

  @override
  void initState() {
    super.initState();
    checks = List.generate(etapas.length, (_) => false);
    desdeControllers = List.generate(etapas.length, (_) => TextEditingController());
    _cargarDatosNave();
  }

 Future<void> _cargarDatosNave() async {
  final doc = await FirebaseFirestore.instance
      .collection('naves')
      .doc(widget.docId)
      .get();

  if (doc.exists) {
    final data = doc.data();
    final List etapasGuardadas = data?['etapas'] ?? [];

    setState(() {
      datosNave = data;

      for (int i = 0; i < etapas.length; i++) {
        final etapa = etapas[i];
        final encontrada = etapasGuardadas.firstWhere(
          (et) => et['nombre'] == etapa,
          orElse: () => null,
        );

        if (encontrada != null) {
          desdeControllers[i].text = encontrada['valor'] ?? '';
          checks[i] = encontrada['completado'] ?? false;
        }
      }

      // 👉 Verifica si existe arribo/desconexion en Firestore y rellena si no están en etapas[]
      if (data!['arribo'] != null) {
        final formatted = DateFormat('yyyy-MM-dd HH:mm').format(data['arribo'].toDate());
        desdeControllers[0].text = formatted;
        checks[0] = true;
      }

      if (data['desconexion'] != null) {
        final formatted = DateFormat('yyyy-MM-dd HH:mm').format(data['desconexion'].toDate());
        desdeControllers[etapas.length - 1].text = formatted;
        checks[etapas.length - 1] = true;
      }
    });
  }
}



  String _formatearFecha(Timestamp ts) {
    final dt = ts.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  void _guardarTrabajo() async {
    List<Map<String, dynamic>> etapasList = [];

    for (int i = 0; i < etapas.length; i++) {
      etapasList.add({
        'nombre': etapas[i],
        'valor': desdeControllers[i].text.trim(),
        'completado': checks[i],
      });
    }

    DateTime? arribo;
    DateTime? desconexion;
    try {
      if (desdeControllers[0].text.isNotEmpty) {
        arribo = DateFormat('yyyy-MM-dd HH:mm').parse(desdeControllers[0].text.trim());
      }
      if (desdeControllers[etapas.length - 1].text.isNotEmpty) {
        desconexion = DateFormat('yyyy-MM-dd HH:mm').parse(desdeControllers[etapas.length - 1].text.trim());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Error al convertir fechas')),
      );
      return;
    }

    final estado = (checks[0] && checks[etapas.length - 1]) ? 'Concluido' : 'En curso';

    await FirebaseFirestore.instance.collection('naves').doc(widget.docId).update({
      'arribo': arribo != null ? Timestamp.fromDate(arribo) : null,
      'desconexion': desconexion != null ? Timestamp.fromDate(desconexion) : null,
      'estado': estado,
      'etapas': etapasList,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Trabajo guardado correctamente')),
    );

    Navigator.pop(context); // << vuelve al menú principal
  }



  Future<void> _mostrarDialogoFechaHora(int index) async {
  DateTime? fechaHora = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  ).then((fecha) async {
    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null) {
        return DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          hora.hour,
          hora.minute,
        );
      }
    }
    return null;
  });

  if (fechaHora != null) {
    final format = DateFormat('yyyy-MM-dd HH:mm');
    setState(() {
      desdeControllers[index].text = format.format(fechaHora);
      checks[index] = true;
    });

    // Guardar automáticamente en Firestore
    String campo = '';
    if (index == 0) campo = 'arribo';
    else if (index == etapas.length - 1) campo = 'desconexion';

    if (campo.isNotEmpty) {
      await FirebaseFirestore.instance.collection('naves').doc(widget.docId).update({
        campo: Timestamp.fromDate(fechaHora),
        'estado': 'En curso',
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('📋 Detalle Naves',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 240, 241, 242),
            )),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 Cambia este color a lo que quieras
        ),
      ),
      body: datosNave == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        datosNave!['nombre'] ?? 'Nombre desconocido',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'FSA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔹 Número de Viaje: ${datosNave!['viaje'] ?? '-'}'),
                        Text('🔹 Rate: ${(datosNave!['rate'] ?? '-').toStringAsFixed(2)}'),
                        Text('🔹 Toneladas: ${(datosNave!['toneladas'] ?? '-').toStringAsFixed(2)}'),
                        Text('🔹 Costo de sobregasto: USD ${(datosNave!['sobregasto'] ?? 0).toStringAsFixed(2)}'),
                        if (datosNave!['timestamp'] != null)
                          Text('🔹 Fecha de registro: ${_formatearFecha(datosNave!['timestamp'])}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(etapas.length, (index) {
                    final etapa = etapas[index];
                    final esInicioODesconexion = etapa.toUpperCase().contains('ARRIBO') || etapa.toUpperCase().contains('DESCONEXION');

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(etapa, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                if (esInicioODesconexion)
                                  ElevatedButton(
                                    onPressed: () => _mostrarDialogoFechaHora(index),
                                    child: const Text('Fecha/Hora'),
                                  )
                                else
                                  const Icon(Icons.build, color: Colors.grey),
                                const SizedBox(width: 10),
                                Checkbox(
                                  value: checks[index],
                                  onChanged: null,
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                            if (esInicioODesconexion && desdeControllers[index].text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '🕒 ${desdeControllers[index].text}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final arriboLleno = desdeControllers[0].text.isNotEmpty;
                        final desconexionLleno = desdeControllers[etapas.length - 1].text.isNotEmpty;

                        if (arriboLleno && desconexionLleno) {
                          _guardarTrabajo();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Debes registrar fecha/hora en ARRIBO y TERMINO DE DESCONEXIÓN.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'GUARDAR Y REGISTRAR TRABAJO',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
