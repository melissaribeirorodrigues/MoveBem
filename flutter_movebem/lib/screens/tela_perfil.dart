import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;
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
                  Navigator.pushNamed(context, '/historico');
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

  void _mostrarDialogoEditarNome() {
    final TextEditingController nomeController = TextEditingController(text: nomeUsuario);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(
            labelText: 'Novo nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final novoNome = nomeController.text.trim();
              if (novoNome.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome não pode estar vazio')),
                );
                return;
              }

              try {
                final url = Uri.parse('$baseUrl/Controller/CrudUsuario.php');
                final response = await http.post(url, body: {
                  'oper': 'Alterar',
                  'id_usuario': dadosUsuario?['id_usuario'].toString() ?? '',
                  'nm_usuario': novoNome,
                  'ds_email': email,
                });

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  if (data['NumMens'] == 1) {
                    // Atualiza SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    dadosUsuario?['nm_usuario'] = novoNome;
                    await prefs.setString('usuario', json.encode(dadosUsuario));

                    setState(() {
                      nomeUsuario = novoNome;
                    });
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nome alterado com sucesso!')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['mensagem'] ?? 'Erro ao alterar nome')),
                      );
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao conectar com servidor')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAlterarSenha() {
    final TextEditingController senhaAtualController = TextEditingController();
    final TextEditingController novaSenhaController = TextEditingController();
    final TextEditingController confirmarSenhaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: senhaAtualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final senhaAtual = senhaAtualController.text;
              final novaSenha = novaSenhaController.text;
              final confirmarSenha = confirmarSenhaController.text;

              if (senhaAtual.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              if (novaSenha != confirmarSenha) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('As senhas não coincidem')),
                );
                return;
              }

              if (novaSenha.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha deve ter no mínimo 6 caracteres')),
                );
                return;
              }

              try {
                // Primeiro valida a senha atual fazendo login
                final urlLogin = Uri.parse('$baseUrl/Controller/CrudUsuario.php');
                final responseLogin = await http.post(urlLogin, body: {
                  'oper': 'Login',
                  'email': email,
                  'senha': senhaAtual,
                });

                if (responseLogin.statusCode == 200) {
                  final dataLogin = json.decode(responseLogin.body);
                  
                  if (dataLogin['NumMens'] != 1) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Senha atual incorreta')),
                      );
                    }
                    return;
                  }

                  // Se a senha atual tá correta, atualiza pra nova
                  final url = Uri.parse('$baseUrl/Controller/CrudUsuario.php');
                  final response = await http.post(url, body: {
                    'oper': 'AlterarSenha',
                    'id_usuario': dadosUsuario?['id_usuario'].toString() ?? '',
                    'ds_senha': novaSenha,
                  });

                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    if (data['NumMens'] == 1) {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha alterada com sucesso!')),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data['mensagem'] ?? 'Erro ao alterar senha')),
                        );
                      }
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao conectar com servidor')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('usuario');
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoExcluirConta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final url = Uri.parse('$baseUrl/Controller/CrudUsuario.php');
                final response = await http.post(url, body: {
                  'oper': 'Excluir',
                  'id_usuario': dadosUsuario?['id_usuario'].toString() ?? '',
                });

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  if (data['NumMens'] == 1) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('usuario');
                    
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conta excluída com sucesso')),
                      );
                    }
                  } else {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['mensagem'] ?? 'Erro ao excluir conta')),
                      );
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao conectar com servidor')),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
