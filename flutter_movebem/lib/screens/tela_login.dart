import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _carregando = false;

  final Color pink1 = const Color(0xFFFF4D8A);
  final Color pink2 = const Color(0xFFFFA7C4);

  // URL do backend
  final String baseUrl = 'http://200.19.1.19/usuario03/MoveBem';

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  // Verifica se já existe uma sessão salva
  Future<void> _verificarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    if (usuarioJson != null && usuarioJson.isNotEmpty) {
      try {
        final dadosUsuario = json.decode(usuarioJson);
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/rotinas',
            arguments: dadosUsuario,
          );
        }
      } catch (e) {
        await prefs.remove('usuario');
      }
    }
  }

  // Salva os dados do usuário localmente
  Future<void> _salvarSessao(Map<String, dynamic> dadosUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', json.encode(dadosUsuario));
    await prefs.commit();
  }

  // Libera recursos quando o widget é destruído
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Função que faz login chamando o backend PHP
  Future<void> _entrar() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mostrarMensagem('Por favor, preencha todos os campos', erro: true);
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Controller/CrudUsuario.php'),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
        body: {
          'oper': 'Login',
          'email': email,
          'senha': senha,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout ao conectar com o servidor');
        },
      );

      setState(() {
        _carregando = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['NumMens'] == 1) {
          await _salvarSessao(data['dados']);
          _mostrarMensagem('Login realizado com sucesso!');
            
          Navigator.pushReplacementNamed(
            context,
            '/rotinas',
            arguments: data['dados'],
          );
        } else {
          _mostrarMensagem(
            data['Mensagem'] ?? 'E-mail ou senha incorretos',
            erro: true,
          );
        }
      } else {
        _mostrarMensagem('Erro ao conectar com o servidor', erro: true);
      }
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      _mostrarMensagem(
        'Erro de conexão: ${e.toString()}',
        erro: true,
      );
    }
  }

  // Mostra mensagem de sucesso ou erro na tela
  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  // Constrói a interface da tela de login
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Topo arredondado rosa com gradiente e efeito de luz
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      pink1,                  
                      pink2,                  
                      pink2.withOpacity(0.7), 
                      Colors.white,           
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
              ),

              // Espaço para centralizar o conteúdo
              SizedBox(height: screenHeight * 0.15),

              // Título
              Text(
                'Faça Seu Login Agora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: pink1,
                ),
              ),

              const SizedBox(height: 30),

              // Campo de E-mail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: pink1, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: true,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Digite seu e-mail',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.email_outlined, color: pink1),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de Senha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: pink1, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    textInputAction: TextInputAction.done,
                    enableInteractiveSelection: true,
                    onSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      hintText: 'Digite sua senha',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: pink1),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: pink1,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaVisivel = !_senhaVisivel;
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
              ),

              const SizedBox(height: 10),

              // Esqueceu sua senha?
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/recuperar_senha');
                },
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botão Entrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Não possui login? Cadastre-se
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não possui login? ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: pink1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
