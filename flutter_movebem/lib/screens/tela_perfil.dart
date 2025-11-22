import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  Map<String, dynamic>? dadosUsuario;
  String nomeUsuario = "";
  String email = "";
  String senha = "********";
  final String baseUrl = 'http://200.19.1.19/usuario03/MoveBem';

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
        nomeUsuario = dados['nm_usuario'] ?? "";
        email = dados['ds_email'] ?? "";
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/rotinas',
              arguments: dadosUsuario,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF69B4),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 70,
                  color: Color(0xFFFF69B4),
                ),
              ),

              const SizedBox(height: 20),

              // Nome com editar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nomeUsuario,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _mostrarDialogoEditarNome,
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFFFF69B4),
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Email
              _buildCampoInfo('E-mail', email),

              // Senha
              _buildCampoSenha(),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _mostrarDialogoAlterarSenha,
                  child: const Text(
                    'Alterar senha',
                    style: TextStyle(
                      color: Color(0xFF00B0FF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ HISTÓRICO FUNCIONANDO
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/historico',
                    arguments: {
                      'id_usuario': dadosUsuario?['id_usuario'],
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Histórico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Sair e Excluir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarDialogoSair,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC1E3),
                        foregroundColor: const Color(0xFFFF69B4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarDialogoExcluirConta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF69B4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Excluir Conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Menu inferior
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4D8A), Color(0xFFF1AEC2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white70, size: 28),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/rotinas',
                    arguments: dadosUsuario,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.water_drop,
                    color: Colors.white70, size: 28),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/agua',
                    arguments: dadosUsuario,
                  );
                },
              ),
              const Icon(Icons.person, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampoInfo(String label, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoSenha() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Senha',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            senha,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 Diálogos (mesmos que antes)
  void _mostrarDialogoEditarNome() {}
  void _mostrarDialogoAlterarSenha() {}
  void _mostrarDialogoSair() {}
  void _mostrarDialogoExcluirConta() {}
}
