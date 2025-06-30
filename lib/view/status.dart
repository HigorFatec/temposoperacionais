import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../controller/drawner_controller.dart';
import '../controller/firestore_controller.dart';
import '../controller/login_controller.dart';

class StatusMotoristaScreen extends StatefulWidget {
  @override
  _StatusMotoristaScreenState createState() => _StatusMotoristaScreenState();
}

class _StatusMotoristaScreenState extends State<StatusMotoristaScreen> {
  // Estrutura hierárquica das etapas
  final List<Map<String, dynamic>> etapas = [
    {
      "categoria": "1 - INICIO DE VIAGEM",
      "subetapas": [
        "1.00 Inicio de Viagem",
        "PARADA EXTRA",
        "1.01 Manutenção",
        "1.02 Posto Fiscal",
        "1.03 Alimentação",
        "1.04 Abastecimento",
        "1.05 Outros",
      ],
    },
    {
      "categoria": "2 - PONTO DE APOIO",
      "subetapas": [
        "2.00 Chegada Ponto de Apoio",
        "PARADA EXTRA",
        "2.01 Troca de Turno",
        "2.02 Aguardando Programação",
        "2.03 Manutenção",
        "2.04 Alimentação",
        "2.05 Abastecimento",
        "2.06 Posto Fiscal",
        "2.07 Outros",
        "2.08 Saida Ponto de Apoio",
        "PARADA EXTRA",
        "2.09 Manutenção",
        "2.10 Alimentação",
        "2.11 Abastecimento",
        "2.12 Posto Fiscal",
        "2.13 Outros",
      ],
    },
    {
      "categoria": "3 - TRIAGEM",
      "subetapas": [
        "3.00 Chegada Carregamento",
        "3.01 Patio de Triagem",
        "PARADA EXTRA",
        "3.02 Manutenção",
        "3.03 Alimentação",
        "3.04 Abastecimento",
        "3.05 Posto Fiscal",
        "3.06 Outros",
        "3.07 Estacionamento",
        "3.08 Saida do Patio",
        "3.09 Saida do Carregamento",
      ],
    },
    {
      "categoria": "4 - LOCAL DE COLETA",
      "subetapas": [
        "4.00 Chegada no Cliente",
        "PARADA EXTRA",
        "4.01 Manutenção",
        "4.02 Alimentação",
        "4.03 Outros",
        "4.04 Inicio Carregamento",
        "4.05 Fim do Carregamento",
        "4.06 Recebimento Nota Fiscal",
        "4.07 Recebimento CTE/MDFE",
        "4.08 Inicio de Viagem",
        "4.09 Saida do Cliente",
        "PARADA EXTRA",
        "4.10 Manutenção",
        "4.11 Posto Fiscal",
        "4.12 Alimentação",
        "4.13 Abastecimento",
        "4.14 Outros",
      ],
    },
    {
      "categoria": "5 - PONTO DE APOIO",
      "subetapas": [
        "5.00 Chegada no Ponto de Apoio",
        "PARADA EXTRA",
        "5.01 Motivo",
        "5.02 Troca de Turno",
        "5.03 Aguardando Definição Cliente",
        "5.04 Manutenção",
        "5.05 Alimentação",
        "5.06 Abastecimento",
        "5.07 Outros",
        "5.08 Saida do Ponto de Apoio",
        "PARADA EXTRA",
        "5.09 Manutenção",
        "5.10 Posto Fiscal",
        "5.11 Alimentação",
        "5.12 Abastecimento",
        "5.13 Outros",
      ],
    },
    {
      "categoria": "6 - DESTINO",
      "subetapas": [
        "6.00 Chegada Descarga",
        "PARADA EXTRA",
        "6.01 Manutenção",
        "6.02 Alimentação",
        "6.03 Outros",
        "6.04 Inicio Descarga",
        "6.05 Fim Descarga",
        "6.06 Saida do Cliente",
      ]
    }
  ];

  // Status atual
  String? statusAtual;
  String? ordemAtual;
  String? siloAtual;
  Timestamp? dataAtual;

  @override
  void initState() {
    super.initState();
    fetchStatusAtual();
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
        });
      }
    } catch (e) {
      print("Erro ao buscar status atual: $e");
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
                    // Usando FutureBuilder para verificar o status do administrador
                    FutureBuilder<String>(
                      future:
                          verificarAdministrador(), // Chama a função assíncrona
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasData &&
                            snapshot.data == 'Administrador') {
                          return Card(
                            color: Colors.red, // Cor de fundo vermelha
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin:
                                const EdgeInsets.only(top: 3.0, bottom: 3.0),
                            child: InkWell(
                              onTap: () {
                                print('Painel Administrador clicado');
                                // Exemplo: navegar para outra página ou abrir um painel de administração
                                // Navigator.of(context).pushNamed('/adminPanel');
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Painel Administrador', // Título do painel
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Texto branco para contraste
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(); // Caso não seja administrador, não exibe o card
                        }
                      },
                    ),
                    // ListTiles

                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Início'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/principal');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Sobre'),
                      subtitle: const Text('Informações App'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sobre');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logoff'),
                      subtitle: const Text('finaliza a sessão'),
                      onTap: () {
                        LoginController().logout();
                        Navigator.of(context).pushReplacementNamed('/login');
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
        title: const Text('Status do Motorista'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/principal');
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
        child: statusAtual == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card com informações do motorista
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: Colors.green[50],
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person,
                                size: 40, color: Colors.green),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informações do Motorista',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  infoLinha('Nº da Ordem Atual:', ordemAtual),
                                  infoLinha('Silo Atual:', siloAtual),
                                  infoLinha('Status da Ordem:', statusAtual),
                                  infoLinha(
                                    'Última Atualização:',
                                    dataAtual != null
                                        ? DateFormat('dd/MM/yyyy HH:mm:ss')
                                            .format(dataAtual!.toDate())
                                        : 'N/A',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Lista de Etapas com Cards
                    Expanded(
                      child: ListView.builder(
                        itemCount: etapas.length,
                        itemBuilder: (context, index) {
                          final categoria = etapas[index];
                          final bool algumaSelecionada =
                              (categoria["subetapas"] as List<String>)
                                  .contains(statusAtual);

                          return Card(
                            elevation: algumaSelecionada ? 8 : 2,
                            color: algumaSelecionada
                                ? Colors.green[100]
                                : Colors.white,
                            margin: const EdgeInsets.only(bottom: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: algumaSelecionada
                                    ? Colors.green
                                    : Colors.grey[400],
                              ),
                              title: Text(
                                categoria["categoria"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                  color: algumaSelecionada
                                      ? Colors.green[900]
                                      : Colors.black87,
                                ),
                              ),
                              children: (categoria["subetapas"] as List<String>)
                                  .map((subetapa) {
                                final bool isAtual = subetapa == statusAtual;
                                return ListTile(
                                  leading: Icon(
                                    Icons.circle,
                                    color: isAtual
                                        ? Colors.green
                                        : Colors.grey[400],
                                    size: 16,
                                  ),
                                  title: Text(
                                    subetapa,
                                    style: TextStyle(
                                      fontWeight: isAtual
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isAtual
                                          ? Colors.green[900]
                                          : Colors.black54,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Alterar Status da Carga',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/principal_2');
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget infoLinha(String titulo, String? valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2.0),
    child: Row(
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 15.0, color: Colors.black87),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            valor ?? "Não disponível",
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

// Função que retorna se o usuário é administrador
Future<String> verificarAdministrador() async {
  String adminStatus = await IdentificacaoController.admin();
  if (adminStatus == 'true') {
    return 'Administrador';
  } else {
    return 'Não Administrador';
  }
}
