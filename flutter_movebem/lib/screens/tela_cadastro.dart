import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;

  final Color pink1 = const Color(0xFFFF4D8A);
  final Color pink2 = const Color(0xFFFFA7C4);

  // URL do backend
  final String baseUrl = 'http://200.19.1.19/usuario03/MoveBem';

  // Libera recursos quando o widget é destruído
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // Função que faz cadastro chamando o backend PHP
  Future<void> _cadastrar() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;
    String confirmarSenha = _confirmarSenhaController.text;

    // Validações
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem('Por favor, preencha todos os campos', erro: true);
      return;
    }

    if (senha != confirmarSenha) {
      _mostrarMensagem('As senhas não coincidem', erro: true);
      return;
    }

    if (senha.length < 6) {
      _mostrarMensagem('A senha deve ter no mínimo 6 caracteres', erro: true);
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      // Envia senha em texto simples - o backend faz o hash com password_hash()
      print('Enviando senha em texto simples');
      final response = await http.post(
        Uri.parse('$baseUrl/Controller/CrudUsuario.php'),
        body: {
          'oper': 'Inserir',
          'nome': nome,
          'email': email,
          'senha': senha, // Senha em texto simples
        },
      );


  print('Resposta servidor (cadastro): ${response.statusCode} ${response.body}');

      setState(() {
        _carregando = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se o cadastro foi bem-sucedido
        if (data['NumMens'] == 1) {
          // Cadastro bem-sucedido
          _mostrarMensagem('Cadastro realizado com sucesso!');
          
          // Aguarda 1 segundo e volta para a tela de login
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context); // Volta para tela de login
        } else {
          // Cadastro falhou
          _mostrarMensagem(
            data['Mensagem'] ?? 'Erro ao realizar cadastro',
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

  // Constrói a interface da tela de cadastro
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
                'Faça Seu Cadastro Agora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: pink1,
                ),
              ),

              const SizedBox(height: 30),

              // Campo de Nome
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: pink1, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _nomeController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      hintText: 'Digite seu nome',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.person_outline, color: pink1),
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
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: true,
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

              const SizedBox(height: 20),

              // Campo de Confirmar Senha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: pink1, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _confirmarSenhaController,
                    obscureText: !_confirmarSenhaVisivel,
                    textInputAction: TextInputAction.done,
                    enableInteractiveSelection: true,
                    onSubmitted: (_) => _cadastrar(),
                    decoration: InputDecoration(
                      hintText: 'Confirme sua senha',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: pink1),
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
              ),

              const SizedBox(height: 30),

              // Botão Cadastrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _cadastrar,
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
                            'Cadastrar',
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

              // Já possui login? Entrar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já possui login? ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Volta para tela de login
                    },
                    child: Text(
                      'Entrar',
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
