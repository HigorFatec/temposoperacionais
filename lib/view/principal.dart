import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/drawner_controller.dart';
import '../controller/login_controller.dart';
import 'util.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  @override
  void initState() {
    super.initState();
  }

  final List<Map<String, dynamic>> etapas = [
    {
      'label': '1 - Início de Viagem',
      'icon': Icons.directions_car,
      'route': '/inicio_de_viagem',
    },
    {
      'label': '2 - Ponto de Apoio',
      'icon': Icons.store_mall_directory,
      'route': '/ponto_de_apoio',
    },
    {
      'label': '3 - Triagem',
      'icon': Icons.assignment_turned_in,
      'route': '/triagem',
    },
    {
      'label': '4 - Local de Coleta',
      'icon': Icons.location_on,
      'route': '/local_de_coleta',
    },
    {
      'label': '5 - Ponto de Apoio',
      'icon': Icons.store,
      'route': '/ponto_de_apoio_2',
    },
    {
      'label': '6 - Destino',
      'icon': Icons.flag,
      'route': '/destino',
    },
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        erro(context, 'Usuário não está autenticado!');
      }
    });

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Início'),
                    subtitle: const Text('Tela Inicial'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/principal');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logoff'),
                    subtitle: const Text('Finaliza a sessão'),
                    onTap: () {
                      LoginController().logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Alterar Status da Carga'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/principal_2');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/fundoinicial.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione uma etapa para alterar o status da carga:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: etapas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final etapa = etapas[index];
                  return Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 6,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed(etapa['route']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              etapa['icon'],
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              etapa['label'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
