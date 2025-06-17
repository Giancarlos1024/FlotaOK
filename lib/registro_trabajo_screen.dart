import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroTrabajoScreen extends StatefulWidget {
  const RegistroTrabajoScreen({super.key});

  @override
  State<RegistroTrabajoScreen> createState() => _RegistroTrabajoScreenState();
}

class _RegistroTrabajoScreenState extends State<RegistroTrabajoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _viajeController = TextEditingController();
  final _toneladasController = TextEditingController();
  final _rateController = TextEditingController();
  final _sobregastoController = TextEditingController();

  void _guardarFormulario() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('naves').add({
          'nombre': _nombreController.text.trim(),
          'viaje': _viajeController.text.trim(),
          'toneladas': double.parse(_toneladasController.text.trim()),
          'rate': double.parse(_rateController.text.trim()),
          'sobregasto': double.parse(_sobregastoController.text.trim()),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos guardados correctamente en Firebase'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        _nombreController.clear();
        _viajeController.clear();
        _toneladasController.clear();
        _rateController.clear();
        _sobregastoController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Registro de Nave',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 240, 241, 242),
            )),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 Cambia este color a lo que quieras
        ),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Complete los datos del registro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputCard(
                controller: _nombreController,
                label: 'Nombre del NAVE',
                icon: Icons.directions_boat_filled,
              ),
              _buildInputCard(
                controller: _viajeController,
                label: 'Número de VIAJE',
                icon: Icons.confirmation_number,
              ),
              _buildInputCard(
                controller: _toneladasController,
                label: 'Toneladas',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
              _buildInputCard(
                controller: _rateController,
                label: 'Rate',
                icon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
              ),
              _buildInputCard(
                controller: _sobregastoController,
                label: 'Costo de sobregasto (S/./Hrs)',
                icon: Icons.money_off_csred_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.save_alt, color: Colors.white),
                  label: const Text(
                    'GUARDAR Y REGISTRAR GASTO',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color.fromARGB(255, 248, 250, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueGrey),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Este campo es requerido' : null,
      ),
    );
  }
}
