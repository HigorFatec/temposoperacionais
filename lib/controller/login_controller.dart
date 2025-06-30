import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view/util.dart';

class LoginController {
  //
  // CRIAR CONTA
  // Adiciona a conta de um novo usuário no serviço
  // Firebase Authentication
  //
  criarConta(context, nome, email, senha, cargo, matricula, admin, txtfilial) {
    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        cargo.isEmpty ||
        matricula.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((resultado) {
      //Armazenar o NOME do usuário no Firestore
      FirebaseFirestore.instance.collection('usuarios').add(
        {
          'uid': resultado.user!.uid,
          'nome': nome,
          'email': email,
          'senha': senha,
          'cargo': cargo,
          'matricula': matricula,
          'filial': txtfilial,
          'admin': admin,
          'status': false,
        },
      );

      sucesso(context, 'Usuário criado com sucesso.');
      Navigator.pop(context);
      sucesso(context, 'Usuário criado com sucesso.');
    }).catchError((e) {
      switch (e.code) {
        case 'email-already-in-use':
          erro(context, 'O email já foi cadastrado.');
          break;
        case 'invalid-email':
          erro(context, 'O email informado é inválido.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // LOGIN
  //
  login(context, email, senha) async {
    if (email.isEmpty || senha.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((value) async {
      bool usuarioStatus = await status();

      print(usuarioStatus);

      print(await versao());

      if (await versao() == '1.1') {
        if (usuarioStatus == true) {
          sucesso(context, 'Usuário autenticado com sucesso.');

          String operacaoUsuario = await operacao();

          print(operacaoUsuario);

          if (operacaoUsuario == 'MDIAS')
            Navigator.pushNamed(context, '/cargas');
          else if (operacaoUsuario == 'ULTRAGAZ') {
            Navigator.pushNamed(context, '/cargas_ultragaz');
          } else
            Navigator.pushNamed(context, '/cargas');
        } else if (usuarioStatus != true) {
          logout();
          erro(context, 'Conta inativa! Procure o Administrador');
        }
      } else {
        erro(context, 'Versão do aplicativo desatualizada, por favor atualize');
        logout();
        return;
      }
    }).catchError((e) {
      switch (e.code) {
        case 'user-not-found':
          erro(context, 'Usuário não encontrado.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // ESQUECEU A SENHA
  //
  esqueceuSenha(context, String email) {
    if (email.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      sucesso(context, 'E-mail enviado com sucesso.');
    } else {
      erro(context, 'Não foi possível enviar o e-mail');
    }
    Navigator.pop(context);
  }

  //
  // LOGOUT
  //
  logout() async {
    try {
      var statusDados = await fetchStatusAtual();

      CollectionReference logout =
          FirebaseFirestore.instance.collection('logout');
      await logout.add({
        'uid': idUsuario(),
        'motorista': await nome(),
        'operacao': await operacao(),
        'cpf': await cpf(),
        'status': 'logout',
        'ordem': statusDados['ordem'] ?? '',
        'silo': statusDados['silo'] ?? '',
        'data': DateTime.now(),
      });
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Erro ao registrar logout: $e');
    }
  }

  //
  // ID do Usuário Logado
  //
  idUsuario() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  //
  // NOME do Usuário Logado
  //
// Atualizar o tipo de retorno para Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> usuarioLogado() async {
    Map<String, dynamic> usuario = {};

    await FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: idUsuario())
        .get()
        .then((resultado) {
      final data = resultado.docs[0].data();
      usuario = {
        'operacao': data['operacao'] ?? '',
        'centro': data['centro'] ?? '',
        'versao': data['versao'] ?? '',
        'cnh': data['CNH'] ?? '',
        'nome': data['nome'] ?? '',
        'cpf': data['cpf'] ?? '',
        'cargo': data['cargo'] ?? '',
        'matricula': data['MATRICULA'] ?? '',
        'filial': data['filial'] ?? '',
        'status': data['status'] ?? '',
        'email': data['email'] ?? '',
        'admin': data['admin'] ?? false, //caso não exista é nullo
      };
    });

    return usuario;
  }

  //
  // ATUALIZAR INFORMAÇÕES DO USUÁRIO
  //
  atualizarInformacoesUsuario(context, nome, matricula, cargo) {
    if (nome.isEmpty || matricula.isEmpty || cargo.isEmpty) {
      erro(context, 'Por favor, preencha todos os campos.');
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: uid)
        .get()
        .then((resultado) {
      final docId = resultado.docs[0].id;

      FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
        'nome': nome,
        'matricula': matricula,
        'cargo': cargo,
      }).then((_) {
        sucesso(context, 'Informações atualizadas com sucesso.');
        Navigator.pop(context);
      }).catchError((e) {
        erro(context, 'Erro ao atualizar informações: ${e.toString()}');
      });
    }).catchError((e) {
      erro(context, 'Erro ao buscar informações do usuário: ${e.toString()}');
    });
  }

//checkando status

  Future<bool> status() async {
    // Obtendo o usuário logado
    Map<String, dynamic> usuario = await usuarioLogado();

    // Verificando se o usuário está logado e se o atributo 'status' existe
    if (usuario.isNotEmpty && usuario.containsKey('status')) {
      // Obtendo o valor do atributo 'status' e convertendo para booleano
      return usuario['status'] as bool;
    } else {
      // Se o usuário não estiver logado ou o atributo 'status' estiver ausente, retorna false
      return false;
    }
  }

  //verificar o atributo "versao" string do usuário logado
  versao() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['versao'];
  }

  nome() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['nome'];
  }

  cpf() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['cpf'];
  }

  operacao() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['operacao'];
  }

  filial() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['filial'];
  }

  admin() async {
    Map<String, dynamic> usuario = await usuarioLogado();
    return usuario['admin'];
  }

  Future<Map<String, dynamic>> fetchStatusAtual() async {
    try {
      // Obtenha o último documento da coleção "acoes_motorista"
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('acoes_motorista')
          .where('uid', isEqualTo: await idUsuario())
          .orderBy('data',
              descending: true) // Ordena por data (mais recente primeiro)
          .limit(1) // Apenas o último documento
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Retorne os dados do primeiro documento
        var doc = snapshot.docs.first;
        String operacaoUsuario = await operacao();

        if (operacaoUsuario == 'MDIAS') {
          return {
            'status': doc['status'],
            'ordem': doc['ordem'],
            'silo': doc['silo'],
            'data': doc['data'],
          };
        } else if (operacaoUsuario == 'ULTRAGAZ') {
          return {
            'status': doc['status'],
            'ordem': doc['carga'],
            'silo': doc['cavalo'],
            'data': doc['data'],
          };
        } else {
          // Se não houver documentos, retorne um mapa vazio
          return {
            'status': doc['status'],
            'ordem': doc['ordem'],
            'silo': doc['silo'],
            'data': doc['data'],
          };
        }
      }
    } catch (e) {
      print("Erro ao buscar status atual: $e");
      return {};
    }

    return {};
  }
}
