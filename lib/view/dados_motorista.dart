// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:tempos_operacionais/view/cargas.dart';
import '../controller/firestore_controller.dart';
import '../controller/login_controller.dart';

import '../view/util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DadosMotoristaScreen extends StatefulWidget {
  final Cargas? motoristaSelecionado;

  const DadosMotoristaScreen({Key? key, this.motoristaSelecionado})
      : super(key: key);

  @override
  State<DadosMotoristaScreen> createState() => _DadosMotoristaScreenState();
}

class _DadosMotoristaScreenState extends State<DadosMotoristaScreen> {
  final ordemController = TextEditingController();
  final moinhoController = TextEditingController();
  final cavaloController = TextEditingController();
  final siloController = TextEditingController();
  final programacaoController = TextEditingController();
  final janelaController = TextEditingController();
  final cteController = TextEditingController();

  final firestoreController = FirestoreController();
  final IdentificacaoController = LoginController();

  List<String> motoristas = [];

  @override
  void initState() {
    super.initState();
    if (widget.motoristaSelecionado != null) {
      ordemController.text = widget.motoristaSelecionado!.ordem;
      moinhoController.text = widget.motoristaSelecionado!.moinho;
      cavaloController.text = widget.motoristaSelecionado!.cavalo;
      siloController.text = widget.motoristaSelecionado!.silo;
      programacaoController.text = widget.motoristaSelecionado!.programacao;
      janelaController.text = widget.motoristaSelecionado!.janela;
      cteController.text = widget.motoristaSelecionado!.cte;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados Carga e Motorista'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: getMotoristas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  motoristas = snapshot.data!; // Atualiza a lista de motoristas
                  return FutureBuilder<List<String>>(
                    future: getPlacas(), // Obtém a lista de placas
                    builder: (context, placasSnapshot) {
                      if (placasSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (placasSnapshot.hasData) {
                        List<String> placas = placasSnapshot.data!;

                        return FutureBuilder<List<String>>(
                          future: getDts(), // Obtém a lista de DTs
                          builder: (context, dtsSnapshot) {
                            if (dtsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (dtsSnapshot.hasData) {
                              List<String> dts = dtsSnapshot.data!;

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: motoristas.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: Text(motoristas[index]),
                                      onTap: () {
                                        print('teste');
                                        //_removerMotorista(index);
                                      },
                                      trailing: FloatingActionButton(
                                        onPressed: () {
                                          print('ok');
                                          //_motoristaController.text =
                                          //   motoristas[index];
                                          //_placaController.text = placas[
                                          //    index]; // Defina a placa do motorista
                                          //_dtController.text = dts[
                                          //    index]; // Defina a DT do motorista
                                          // Ação adicional ao pressionar o botão "+" dentro do Card
                                        },
                                        mini: true,
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (dtsSnapshot.hasError) {
                              return const Text('Erro ao carregar DTs');
                            } else {
                              return const Text('Carregando DTs...');
                            }
                          },
                        );
                      } else if (placasSnapshot.hasError) {
                        return const Text('Erro ao carregar placas');
                      } else {
                        return const Text('Carregando placas...');
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar motoristas');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          setState(() {
                            moinhoController.text = text;
                          });
                        },
                        controller: moinhoController,
                        decoration: const InputDecoration(
                          labelText: 'Moinho',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.password),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          setState(() {
                            ordemController.text = text;
                          });
                        },
                        controller: ordemController,
                        decoration: const InputDecoration(
                          labelText: 'Nº da Ordem',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.numbers),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          janelaController.text = text;
                        },
                        controller: janelaController,
                        decoration: const InputDecoration(
                          labelText: 'Janela',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          programacaoController.text = text;
                        },
                        controller: programacaoController,
                        decoration: const InputDecoration(
                          labelText: 'Programação',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          siloController.text = text;
                        },
                        controller: siloController,
                        decoration: const InputDecoration(
                          labelText: 'Silo',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        enabled: false,
                        onChanged: (text) {
                          cavaloController.text = text;
                        },
                        controller: cavaloController,
                        decoration: const InputDecoration(
                          labelText: 'Cavalo',
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
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields()) {
                          // SALVAR DADOS NO FIREBASE
                          firestoreController.salvarDadosMotorista(
                              ordemController.text,
                              moinhoController.text,
                              cavaloController.text,
                              siloController.text,
                              programacaoController.text,
                              janelaController.text,
                              cteController.text);
                          //});
                          Navigator.pushNamed(context, '/principal');
                          Navigator.pushReplacementNamed(context, '/principal');
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> getMotoristas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('motoristas')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    final motoristas =
        snapshot.docs.map((doc) => doc['motorista'] as String).toList();
    return motoristas;
  }

  Future<List<String>> getDts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('motoristas')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
    return dts;
  }

  Future<List<String>> getPlacas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('motoristas')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    final placas = snapshot.docs.map((doc) => doc['placa'] as String).toList();
    return placas;
  }

  bool _validateFields() {
    if (moinhoController.text.isEmpty ||
//        data.isEmpty ||
        siloController.text.isEmpty) {
//        horario.isEmpty
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      return true;
    }
  }
}
