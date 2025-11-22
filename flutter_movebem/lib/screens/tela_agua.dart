import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaAgua extends StatefulWidget {
  const TelaAgua({Key? key}) : super(key: key);

  @override
  State<TelaAgua> createState() => _TelaAguaState();
}

class _TelaAguaState extends State<TelaAgua> {
  final TextEditingController _quantidadeController = TextEditingController();
  int _totalDia = 0;
  bool _mostrarFeedback = false;
  int _quantidadeAdicionada = 0;
  int _currentIndex = 1;
  String _idUsuario = '1';
  Map<String, dynamic>? dadosUsuario;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    if (usuarioJson != null) {
      final dados = json.decode(usuarioJson);
      setState(() {
        dadosUsuario = dados;
        _idUsuario = dados['id_usuario'].toString();
      });
      _carregarTotalDia();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _carregarTotalDia() async {
    try {
      final url = Uri.parse('http://200.19.1.19/usuario03/MoveBem/Controller/CrudRegistroAgua.php');
      final response = await http.post(
        url,
        body: {
          'oper': 'TotalDia',
          'id_usuario': _idUsuario,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response TotalDia: $data');
        if (data['NumMens'] == 1 && data['dados'] != null) {
          setState(() {
            _totalDia = data['dados']['total'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar total do dia: $e');
    }
  }

  Future<void> _salvarQuantidade() async {
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    
    if (quantidade <= 0) {
      return;
    }

    try {
      final url = Uri.parse('http://200.19.1.19/usuario03/MoveBem/Controller/CrudRegistroAgua.php');
      final response = await http.post(
        url,
        body: {
          'oper': 'Inserir',
          'id_usuario': _idUsuario,
          'qt_agua_ml': quantidade.toString(),
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['NumMens'] == 1) {
          setState(() {
            _quantidadeAdicionada = quantidade;
            _totalDia += quantidade;
            _mostrarFeedback = true;
            _quantidadeController.clear();
          });

          // Esconde o feedback após 3 segundos
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _mostrarFeedback = false;
              });
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao salvar quantidade: $e');
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Consumo de Água',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Feedback de adição
                  if (_mostrarFeedback)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4D8A), Color(0xFFFF7BAC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Você adicionou $_quantidadeAdicionada ml',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total dia: $_totalDia ml',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _mostrarFeedback = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  const Text(
                    'Informe a quantidade água ingerida:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Imagem do copo
                  Image.asset(
                    'assets/agua.png',
                    width: 200,
                    height: 280,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  // Campo de texto
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Digite aqui (ml)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botão Salvar
                  ElevatedButton(
                    onPressed: _salvarQuantidade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Salvar Quantidade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4D8A), Color.fromARGB(255, 241, 174, 194)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: _currentIndex == 0 ? Colors.white : Colors.white70,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                      Navigator.pushReplacementNamed(context, '/rotinas');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.water_drop,
                      color: _currentIndex == 1 ? Colors.white : Colors.white70,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color: _currentIndex == 2 ? Colors.white : Colors.white70,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                      Navigator.pushNamed(
                        context,
                        '/perfil',
                        arguments: dadosUsuario,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
