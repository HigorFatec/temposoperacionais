import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/login_controller.dart';
import 'dados_motorista.dart';

class Cargas {
  final String ordem;
  final String moinho;
  final String cavalo;
  final String silo;
  final String programacao;
  final String janela;
  final String cte;

  Cargas({
    required this.ordem,
    required this.moinho,
    required this.cavalo,
    required this.silo,
    required this.programacao,
    required this.janela,
    required this.cte,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cargas && other.ordem == ordem;
  }

  @override
  int get hashCode => ordem.hashCode;
}

Future<bool> _verificarDtNoFirebase(String ordem) async {
  final query = await FirebaseFirestore.instance
      .collection('selecionado')
      .where('ordem', isEqualTo: ordem)
      .where('uid', isEqualTo: await IdentificacaoController.idUsuario())
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

final IdentificacaoController = LoginController();

Future<List<Cargas>?> fetchMotoristasFromFirestore() async {
  // Obtenha uma referência para a coleção 'teste_json' no Firestore
  final collection = FirebaseFirestore.instance.collection('janela');

  // Obtenha os documentos da coleção 'teste_json'
  final snapshot = await collection
      //.where('FILIAL', isEqualTo: await IdentificacaoController.filial())
      .get();

  // Converta as linhas da planilha em objetos Motorista
  final motoristas2 = snapshot.docs.map((doc) {
    final data = doc.data();
    final moinho = data['ORIGEM']?.toString() ?? '';
    final cavalo = data['CAVALO']?.toString() ?? '';
    final silo = data['SILO']?.toString() ?? '';
    final programacao = data['DAT.PROG.']?.toString() ?? '';
    final janela = data['JANELA']?.toString() ?? '';
    final String cte = data['CTE']?.toString() ?? '';
    final ordem = (data['Ordem de Coleta'] is int)
        ? data['Ordem de Coleta'].toString()
        : int.tryParse(data['Ordem de Coleta']?.toString() ?? '0')
                ?.toString() ??
            '0';

    return Cargas(
      ordem: ordem,
      moinho: moinho,
      cavalo: cavalo,
      silo: silo,
      programacao: programacao,
      janela: janela,
      cte: cte,
    );
  }).toList();
  return motoristas2.toSet().toList();
}

class MotoristasScreen2 extends StatefulWidget {
  const MotoristasScreen2({Key? key}) : super(key: key);

  @override
  _MotoristasScreenState2 createState() => _MotoristasScreenState2();
}

class _MotoristasScreenState2 extends State<MotoristasScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a Janela'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/cargas');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/fundoinicial.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por Placa',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Cargas>?>(
                future: fetchMotoristasFromFirestore().catchError((error) {
                  print('Erro ao carregar CTES: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Cargas>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Erro ao carregar CTES'));
                  } else {
                    final motoristas2 = snapshot.data!;

                    motoristas2.sort((a, b) =>
                        int.parse(b.ordem).compareTo(int.parse(a.ordem)));

                    return ListView.builder(
                      itemCount: motoristas2.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas2[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.silo
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: _verificarDtNoFirebase(motorista.ordem),
                          builder: (context, snapshot) {
                            Color cardColor = Colors.white; // cor padrão

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == true) {
                                cardColor = Colors
                                    .green; // cor se dt estiver no Firebase
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => DadosMotoristaScreen(
                                      motoristaSelecionado: motorista,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                          'Ordem: ${motorista.ordem}, Silo: ${motorista.silo}, Moinho:${motorista.moinho}'),
                                      subtitle: Text(
                                          'Janela: ${motorista.janela} \nCavalo: ${motorista.cavalo} \nCTE ${motorista.cte} \nData: ${motorista.programacao}'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}
