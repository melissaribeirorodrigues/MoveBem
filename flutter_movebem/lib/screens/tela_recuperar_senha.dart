import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final _emailController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;

  final Color pink1 = const Color(0xFFFF4D8A);
  final String baseUrl = 'http://200.19.1.19/usuario03/MoveBem';

  @override
  void dispose() {
    _emailController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _recuperarSenha() async {
    String email = _emailController.text.trim();
    String novaSenha = _novaSenhaController.text;
    String confirmarSenha = _confirmarSenhaController.text;

    if (email.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem('Por favor, preencha todos os campos', erro: true);
      return;
    }

    if (novaSenha != confirmarSenha) {
      _mostrarMensagem('As senhas não coincidem', erro: true);
      return;
    }

    if (novaSenha.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres', erro: true);
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Controller/CrudUsuario.php'),
        body: {
          'oper': 'RecuperarSenha',
          'email': email,
          'senha': novaSenha,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout ao conectar com o servidor');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['NumMens'] == 1) {
          _mostrarMensagem('Senha alterada com sucesso!');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          _mostrarMensagem(
            data['Mensagem'] ?? 'Erro ao alterar senha',
            erro: true,
          );
        }
      } else {
        _mostrarMensagem('Erro na comunicação com o servidor', erro: true);
      }
    } catch (e) {
      _mostrarMensagem('Erro: ${e.toString()}', erro: true);
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Digite seu e-mail e escolha uma nova senha',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // Campo E-mail
              const Text(
                'E-mail',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'seu@email.com',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo Nova Senha
              const Text(
                'Nova Senha',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _novaSenhaController,
                  obscureText: !_novaSenhaVisivel,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _novaSenhaVisivel
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: pink1,
                      ),
                      onPressed: () {
                        setState(() {
                          _novaSenhaVisivel = !_novaSenhaVisivel;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo Confirmar Senha
              const Text(
                'Confirmar Nova Senha',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _confirmarSenhaController,
                  obscureText: !_confirmarSenhaVisivel,
                  decoration: InputDecoration(
                    hintText: 'Digite a senha novamente',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmarSenhaVisivel
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: pink1,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botão Recuperar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _recuperarSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Alterar Senha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
