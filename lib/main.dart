import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tempos_operacionais/firebase_options.dart';
import 'package:get/get.dart';
import 'package:tempos_operacionais/view/acoes_motorista/4_local_de_coleta.dart';
import 'package:tempos_operacionais/view/acoes_motorista/5_ponto_de_apoio.dart';
import 'package:tempos_operacionais/view/login.dart';
import 'package:tempos_operacionais/view/principal.dart';

import 'view/acoes_motorista/6_destino.dart';
import 'view/acoes_motorista/2_ponto_de_apoio.dart';
import 'view/cargas.dart';
import 'view/dados_motorista.dart';
import 'view/acoes_motorista/3_triagem.dart';
import 'view/acoes_motorista/1_inicio_de_viagem.dart';
import 'view/sobre.dart';
import 'view/status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tempos Operacionais',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(
            name: '/dados_motorista', page: () => const DadosMotoristaScreen()),
        GetPage(name: '/principal_2', page: () => const PrincipalPage()),
        GetPage(name: '/principal', page: () => StatusMotoristaScreen()),
        GetPage(name: '/cargas', page: () => const MotoristasScreen2()),

        GetPage(name: '/inicio_de_viagem', page: () => InicioViagemScreen()),
        GetPage(name: '/ponto_de_apoio', page: () => PontoDeApoioScreen()),
        GetPage(name: '/triagem', page: () => TriagemScreen()),
        GetPage(name: '/local_de_coleta', page: () => LocalDeColetaScreen()),
        GetPage(name: '/ponto_de_apoio_2', page: () => PontoDeApoio2Screen()),
        GetPage(name: '/destino', page: () => DestinoScreen()),

        //GetPage(name: '/destino', page: () => DestinoScreen()),

        GetPage(name: '/sobre', page: () => SobreTela()),

        //GetPage(name: '/cadastrar', page: () => const CadastrarPage()),
      ],
    );
  }
}
