import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_controller.dart';

final IdentificacaoController = LoginController();

class FirestoreController {
  Future<void> exibirDadosColecao() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Primeiro documento da coleção
        DocumentSnapshot firstDocument = querySnapshot.docs[0];

        // Acessar os campos e armazenar em variáveis
        String dt = firstDocument.get('dt');
        String km = firstDocument.get('km');
        String motorista = firstDocument.get('motorista');
        String placa = firstDocument.get('placa');

        // Fazer algo com as variáveis
        print('Dt: $dt');
        print('Kilometragem: $km');
        print('Motorista: $motorista');
        print('Placa: $placa');
      } else {
        print('A coleção está vazia.');
      }
    } catch (error) {
      print('Erro ao obter os documentos da coleção: $error');
    }
  }

  Future<void> salvarDadosMotorista(String ordem, String moinho, String cavalo,
      String silo, String programacao, String janela, String cte) async {
    try {
      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('inicio_viagem');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'ordem': ordem,
        'moinho': moinho,
        'cavalo': cavalo,
        'silo': silo,
        'programacao': programacao,
        'janela': janela,
        'cte': cte,
        'motorista': await IdentificacaoController.nome(),
        'cpf': await IdentificacaoController.cpf(),
        'operacao': await IdentificacaoController.operacao(),
        'data': DateTime.now(),
        'uid': await IdentificacaoController.idUsuario(),
      });

      CollectionReference motoristasCollection2 =
          FirebaseFirestore.instance.collection('selecionado');
      await motoristasCollection2.add({
        'ordem': ordem,
        'silo': silo,
        'data': DateTime.now(),
        'uid': await IdentificacaoController.idUsuario(),
      });

      salvarDadosSaida(
          ordem, '1.0 Aguardando Ação do Motorista', silo, 'inicio');

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosSaida(
      String ordem, String status, String silo, String tipo) async {
    try {
      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('acoes_motorista');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'ordem': ordem,
        'status': status,
        'silo': silo,
        'tipo': tipo,
        'data': DateTime.now(),
        'motorista': await IdentificacaoController.nome(),
        'uid': await IdentificacaoController.idUsuario(),
        'operacao': await IdentificacaoController.operacao(),
      });

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosMotorista_ultragaz(
    String cavalo,
    String carreta,
    String motorista,
    String carga,
    String data_carga,
    String origem,
    String destino,
    String data_coleta,
  ) async {
    try {
      // Referência ao Firestore
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('inicio_viagem');

      motoristasCollection.add({
        'cavalo': cavalo,
        'carreta': carreta,
        'carga': carga,
        'data_carga': data_carga,
        'origem': origem,
        'destino': destino,
        'data_coleta': data_coleta,
        'motorista': await IdentificacaoController.nome(),
        'cpf': await IdentificacaoController.cpf(),
        'operacao': await IdentificacaoController.operacao(),
        'data': Timestamp.now(),
        'uid': await IdentificacaoController.idUsuario(),
      });

      CollectionReference motoristasCollection2 =
          FirebaseFirestore.instance.collection('selecionado');
      await motoristasCollection2.add({
        'carga': carga,
        'carreta': carreta,
        'data': DateTime.now(),
        'uid': await IdentificacaoController.idUsuario(),
      });

      salvarDadosSaida_ultragaz(carga, 'Aguardando Ação do Motorista', carreta,
          Timestamp.now().toDate().toString());

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosSaida_ultragaz(String carga, String status,
      String carreta, String data_informada) async {
    try {
      // Converter a string "data_informada" para um objeto DateTime
      DateTime dataConvertida = DateTime.parse(data_informada).toUtc();
      // Ajustar para o fuso horário UTC-3
      DateTime dataAjustada = dataConvertida.subtract(Duration(hours: 0));

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('acoes_motorista');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'carga': carga,
        'status': status,
        'carreta': carreta,
        'data_informada': dataAjustada, // Salva como DateTime diretamente
        'data': DateTime.now(), // Salva a data atual como DateTime
        'motorista': await IdentificacaoController.nome(),
        'operacao': await IdentificacaoController.operacao(),
        'uid': await IdentificacaoController.idUsuario(),
      });

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }
}
