import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../controller/drawner_controller.dart';
import '../../controller/firestore_controller.dart';
import '../../controller/login_controller.dart';
import '../util.dart';

class PontoDeApoio2Screen extends StatefulWidget {
  @override
  State<PontoDeApoio2Screen> createState() => PontoDeApoioScreen2State();
}

class PontoDeApoioScreen2State extends State<PontoDeApoio2Screen> {
  final firestoreController = FirestoreController();
  final IdentificacaoController = LoginController();

  final ordemController = TextEditingController();
  final placaCarretaController = TextEditingController();

  List<String> status_carga = [];

  String placaCarreta = '';
  String transportadora = '5.00 Chegada no Ponto de Apoio';
  String tipo = 'inicio';
  // Status atual
  String? statusAtual;
  String? ordemAtual;
  String? siloAtual;
  String? codigoAtual;
  Timestamp? dataAtual;

  // Novo estado para Parada Extra
  bool isParadaExtra = false;

  @override
  void initState() {
    super.initState();
    fetchStatusAtual();
    inicio_da_viagem();
  }

  Future<void> fetchStatusAtual() async {
    try {
      // Obtenha o último documento da coleção
      // "acoes_motorista"
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('acoes_motorista')
          .where('uid', isEqualTo: await IdentificacaoController.idUsuario())
          .orderBy('data',
              descending: true) // Ordena por data (mais recente primeiro)
          .limit(1) // Apenas o último documento
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          statusAtual = snapshot.docs.first['status']; // Pega o campo "status"
          ordemAtual = snapshot.docs.first['ordem']; // Pega o campo "ordem"
          siloAtual = snapshot.docs.first['silo']; // Pega o campo "silo"
          dataAtual = snapshot.docs.first['data']; // Pega o campo "data"
          //codigoAtual = snapshot.docs.first['codigo']; // Pega o campo "codigo"

          // Atualize os controladores
          ordemController.text = ordemAtual ?? '';
          placaCarretaController.text = siloAtual ?? '';
        });
      }
    } catch (e) {
      print("Erro ao buscar status atual: $e");
    }
  }

  Future<void> inicio_da_viagem() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(isParadaExtra ? 'parada_extra_5' : 'ponto_de_apoio_2')
          .orderBy('codigo')
          .get();
      final data = snapshot.docs.map((doc) => doc['nome'] as String).toList();

      setState(() {
        status_carga = data;
        // Garante que transportadora sempre exista na lista
        if (!status_carga.contains(transportadora)) {
          transportadora = status_carga.isNotEmpty ? status_carga.first : '';
        }
      });
    } catch (e) {
      print('Erro ao enviar planilha!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Inicio'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/principal');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Ponto de Apoio'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/ponto_de_apoio');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Define a altura do contêiner igual à altura da tela
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/fundoinicial.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16.0),

                      // Título
                      const Text(
                        'Informações da Carga',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10.0),
                      // Campo de texto para o número da ordem
                      Card(
                        color: Colors.grey[400],
                        child: TextFormField(
                          onChanged: (text) {
                            ordemController.text = text;
                          },
                          controller: ordemController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Nº da Ordem',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.directions_car),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      Card(
                        color: Colors.grey[400],
                        child: TextFormField(
                          onChanged: (text) {
                            placaCarretaController.text = text;
                          },
                          controller: placaCarretaController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Placa Silo',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.directions_car),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      Card(
                        color: Colors.grey[400],
                        child: TextFormField(
                          initialValue: DateTime.now().toString(),
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Data da alteração',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      const Text(
                        'Alterar Status da Carga',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15.0),

                      // Botão Parada Extra
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                          backgroundColor:
                              isParadaExtra ? Colors.red : Colors.blue,
                        ),
                        onPressed: () async {
                          setState(() {
                            isParadaExtra = !isParadaExtra;
                            transportadora = isParadaExtra
                                ? '5.01 Motivo'
                                : '5.00 Chegada no Ponto de Apoio';
                          });
                          await inicio_da_viagem();
                        },
                        child: const Text('Adicionar Parada Extra'),
                      ),

                      const SizedBox(height: 15.0),

                      Container(
                        color: Colors.white,
                        child: status_carga.isEmpty ||
                                !status_carga.contains(transportadora)
                            ? const Center(child: CircularProgressIndicator())
                            :
                            // Dropdownbutton para selecionar o status da carga
                            DropdownButtonFormField<String>(
                                value: transportadora, // Valor selecionado
                                onChanged: (newValue) {
                                  setState(() {
                                    transportadora = newValue!;
                                  });
                                },
                                items: status_carga.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  labelText: 'Alterar status da carga',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 10.0),
                      //Dropdownbutton para selecionar inicio ou fim da viagem
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: tipo, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              tipo = newValue!;
                            });
                          },
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'inicio',
                              child: Text('Inicio da Ação'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'fim',
                              child: Text('Fim da Ação'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Ação',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Botão para salvar os dados
                      ElevatedButton(
                        onPressed: () {
                          if (_validateFields()) {
                            // SALVAR DADOS NO FIREBASE
                            firestoreController.salvarDadosSaida(
                              ordemController.text,
                              transportadora,
                              placaCarretaController.text,
                              tipo,
                            );
                          }
                        },
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (ordemController.text.isEmpty) {
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      Navigator.of(context).pushNamed('/principal');
      return true;
    }
  }
}
