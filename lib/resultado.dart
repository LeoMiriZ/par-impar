import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Resultado extends StatefulWidget {
  final Function callback;
  final String jogadorAtual;
  final String jogadorDesafiado;

  Resultado(this.callback, this.jogadorAtual, this.jogadorDesafiado);

  @override
  _ResultadoState createState() => _ResultadoState();
}

class _ResultadoState extends State<Resultado> {
  late Future<Map<String, dynamic>> futureResultado;

  @override
  void initState() {
    super.initState();
    futureResultado = buscarResultado(widget.jogadorAtual, widget.jogadorDesafiado);
  }

  Future<Map<String, dynamic>> buscarResultado(String jogador1, String jogador2) async {
    try {
      var url = Uri.parse('https://par-impar.glitch.me/jogar/$jogador1/$jogador2');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao buscar resultado');
      }
    } catch (e) {
      print('Erro ao buscar resultado: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: futureResultado,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Resultado (Clique na ação desejada e depois em voltar)'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Resultado (Clique na ação desejada e depois em voltar)'),
            ),
            body: Center(child: Text('Erro ao buscar resultado')),
          );
        } else if (snapshot.hasData) {
          var resultado = snapshot.data!;
          if (resultado.containsKey('msg')) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Resultado (Clique na ação desejada e depois em voltar)'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(resultado['msg']),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        widget.callback(0);
                      },
                      child: Text('Início 🏠'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.callback(1);
                      },
                      child: Text('Nova Aposta 🎲'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Resultado (Clique na ação desejada e depois em voltar)'),
              ),
              body: ResultadoWidget(resultado: resultado, callback: widget.callback),
            );
          }
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Resultado (Clique na ação desejada e depois em voltar)'),
            ),
            body: Center(child: Text('Nenhum resultado encontrado')),
          );
        }
      },
    );
  }
}

class ResultadoWidget extends StatelessWidget {
  final Map<String, dynamic> resultado;
  final Function callback;

  ResultadoWidget({required this.resultado, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vencedor: ${resultado['vencedor']['username']}'),
          Text('Valor: ${resultado['vencedor']['valor']}'),
          Text('Par ou ímpar: ${resultado['vencedor']['parimpar']}'),
          Text('Número: ${resultado['vencedor']['numero']}'),
          SizedBox(height: 16),
          Text('Perdedor: ${resultado['perdedor']['username']}'),
          Text('Valor: ${resultado['perdedor']['valor']}'),
          Text('Par ou ímpar: ${resultado['perdedor']['parimpar']}'),
          Text('Número: ${resultado['perdedor']['numero']}'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              callback(0);
            },
            child: Text('Início 🏠'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              callback(1);
            },
            child: Text('Nova Aposta 🎲'),
          ),
        ],
      ),
    );
  }
}
