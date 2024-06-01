import 'package:flutter/material.dart';
import 'aposta.dart';
import 'cadastro.dart';
import 'lista.dart';
import 'resultado.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  runApp(ParImpar());
}

class ParImpar extends StatefulWidget {
  @override
  State<ParImpar> createState() => ParImparState();
}

class Jogador {
  var jogador;
  var pontos;

  Jogador(this.jogador, this.pontos);

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      json['username'] as String,
      json['pontos'] as int,
    );
  }
}

class ParImparState extends State<ParImpar> {
  // controla qual a tela deve ser exibida:
  // 0 - cadastro
  // 1 - aposta
  // 2 - lista
  // 3 - resultado
  var telaAtual = 0;
  var jogador = "";
  var url = "";
  var jogador1 = "";
  var jogador2 = "";
  
  // funcao passada como parametro para a troca de tela
  void trocaTela(int idNovaTela) {
    setState(() {
      telaAtual = idNovaTela;
    });
  }

  // funcao para o cadastro do jogador
  Future<void> cadastro(String name) async {
    var url = Uri.https('par-impar.glitch.me', 'novo');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': name}),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        jogador = name;
      });
      trocaTela(1);
    } else {
      throw const HttpException('Falha ao cadastrar jogador');
    }
  }

  Future<void> enviarAposta(int valorAposta, int parimpar, int dedos) async {
    var url = Uri.https('par-impar.glitch.me', 'aposta');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': jogador,
        'valor': valorAposta,
        'parimpar': parimpar, // 2 -> par, 1 -> ímpar
        'numero': dedos,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      trocaTela(2);
    } else {
      throw const HttpException('Falha ao enviar aposta');
    }
  }

  // retorna a tela correspondente
  Widget exibirTela() {
    if (telaAtual == 0) {
      return Cadastro(cadastro);
    } else if (telaAtual == 1) {
      return Aposta(enviarAposta, jogador);
    } else if (telaAtual == 2) {
      return Lista(trocaTela, jogador);
    } else {
      return Resultado(trocaTela, jogador1, jogador2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Par ou Ímpar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: exibirTela(),
    );
  }
}
