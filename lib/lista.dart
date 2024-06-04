import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'resultado.dart';

class Lista extends StatefulWidget {
  final Function callback;
  final String jogadorAtual;

  Lista(this.callback, this.jogadorAtual);

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  List<Jogador> jogadores = [];
  bool isLoading = true;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    listarJogadores();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => listarJogadores());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> listarJogadores() async {
    var url = Uri.https('par-impar.glitch.me', 'jogadores');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData['jogadores'] is List) {
          setState(() {
            jogadores = (jsonData['jogadores'] as List)
                .map((json) => Jogador.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          throw const FormatException('Formato de resposta inesperado');
        }
      } else {
        throw const HttpException('Falha ao carregar jogadores');
      }
    } catch (e) {
      print('Erro ao buscar jogadores: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> desafiarJogador(String jogadorDesafiado) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Resultado(widget.callback, widget.jogadorAtual, jogadorDesafiado),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Jogadores (Clique em algum adversário para jogar)'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: jogadores.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(jogadores[index].username),
                  subtitle: Text('Pontos: ${jogadores[index].pontos}'),
                  onTap: () => desafiarJogador(jogadores[index].username),
                );
              },
            ),
    );
  }
}

class Jogador {
  final String username;
  final int pontos;

  Jogador(this.username, this.pontos);

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      json['username'] ?? 'Unknown',
      json['pontos'] ?? 0,
    );
  }
}
