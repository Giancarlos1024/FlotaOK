import 'package:flutter/material.dart';
import 'registro_trabajo_screen.dart';
import 'demurrage_screen.dart';
import 'contratista_screen.dart';
import 'ajustes_screen.dart';
import 'vista_principal_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final String correo;

  const MainScreen({super.key, required this.correo});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1;

  final List<String> _titles = [
    'Historial de Naves',
    'Ingreso de Datos Contratista',
    'Ajustes',
  ];

  final List<Widget> _contents = [
    const HistorialNavesView(),
    const Center(child: Text('Formulario de datos del contratista')),
    const Center(child: Text('Configuración de la aplicación')),
  ];

  void _onSelectMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == -1 ? 'MENÚ PRINCIPAL' : _titles[_selectedIndex],
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 240, 241, 242),
            ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 Cambia este color a lo que quieras
        ),
        
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: const Text('Usuario'),
                accountEmail: Text(widget.correo),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/logo.jpg'),
                  backgroundColor: Colors.white,
                ),
              ),
              _buildListTile(
                icon: Icons.home,
                label: 'Menú Principal',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = -1);
                },
              ),
              _buildListTile(
                icon: Icons.assignment_turned_in,
                label: 'Registro de Trabajos',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistroTrabajoScreen(),
                    ),
                  );
                },
              ),
              // _buildListTile(
              //   icon: Icons.history,
              //   label: 'Historial de Naves',
              //   onTap: () => _onSelectMenu(0),
              // ),
              _buildListTile(
                icon: Icons.person_add_alt_1,
                label: 'Ingreso de CPC',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContratistaScreen(),
                    ),
                  );
                },
              ),
              // _buildListTile(
              //   icon: Icons.directions_boat,
              //   label: 'Demurrage',
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const DemurrageScreen(),
              //       ),
              //     );
              //   },
              // ),
              _buildListTile(
                icon: Icons.settings,
                label: 'Ajustes',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AjustesScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildListTile(
                icon: Icons.exit_to_app,
                label: 'Cerrar Sesión',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _selectedIndex == -1
          ? const HistorialNavesView()
          : _contents[_selectedIndex],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
