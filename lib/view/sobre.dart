import 'package:flutter/material.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';

class SobreTela extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('lib/images/1734746152811.jpeg'),
            ),
            SizedBox(width: 16.0), // Espaço entre as pessoas
            const Text(
              'Higor Machado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aplicativo criado por Higor Machado, utilizado a linguagem de programação Dart, HTML, CSS e JavaScript com o framework Flutter.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Melhorias ou sugestões, entrar em contato.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              color: Colors.deepPurple,
              textColor: Colors.white,
              onPressed: () async {
                await EasyLauncher.url(url: "https://github.com/HigorFatec");
              },
              child: const Text("Ver meu Portfólio no GitHub"),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              color: Colors.green[700],
              textColor: Colors.white,
              onPressed: () async {
                await EasyLauncher.sendToWhatsApp(
                    phone: "5513978090383",
                    message:
                        "Olá Higor, gostaria de conversar sobre seu projeto.");
              },
              child: const Text("Contato pelo WhatsApp"),
            ),
          ],
        ),
      ),
    );
  }
}
