import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cadastro extends StatelessWidget {
  final Function callback;

  Cadastro(this.callback);

  Future<Map<String, dynamic>> buscarPontos(String username) async {
    try {
      var url = Uri.parse('https://par-impar.glitch.me/pontos/$username');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao buscar pontos');
      }
    } catch (e) {
      print('Erro ao buscar pontos: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final jogador = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro e Busca de Jogadores'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                controller: jogador,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nome do Jogador",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  buscarPontos(jogador.text).then((pontos) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pontos do jogador ${pontos['username']}: ${pontos['pontos']}',
                          style: TextStyle(fontSize: 18), // Aumentando ainda mais o tamanho da fonte
                        ),
                      ),
                    );
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao buscar pontos. Por favor, tente novamente.'),
                      ),
                    );
                  });
                }
              },
              child: const Text('Buscar Pontos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  callback(jogador.text);
                }
              },
              child: const Text('Apostar'),
            ),
          ],
        ),
      ),
    );
  }
}
