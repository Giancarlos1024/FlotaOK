import 'package:flutter/material.dart';

class ContratistaScreen extends StatelessWidget {
  const ContratistaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: const Text('Datos del Contratista',
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
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Aquí va el formulario de ingreso de datos del contratista.'),
        ),
      ),
    );
  }
}
