import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaRotinas extends StatefulWidget {
  const TelaRotinas({super.key});

  @override
  State<TelaRotinas> createState() => _TelaRotinasState();
}

class _TelaRotinasState extends State<TelaRotinas> {
  final String baseUrl = 'http://200.19.1.19/usuario03/MoveBem';
  bool _loading = false;
  List<Map<String, dynamic>> _rotinas = [];
  int _currentIndex = 0;
  Map<String, dynamic>? dadosUsuario;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _loadRotinas();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    if (usuarioJson != null) {
      setState(() {
        dadosUsuario = json.decode(usuarioJson);
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadRotinas() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Controller/CrudRotina.php'),
        body: {'oper': 'Listar'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['NumMens'] == 1 && data['dados'] is List) {
          // cada item: {id_rotina, nm_rotina, ds_rotina}
          setState(() {
            _rotinas = List<Map<String, dynamic>>.from(data['dados']);
          });
        } else {
          // Se NumMens != 1 pode ter Mensagem de erro
          // limpar lista e mostrar snackbar
          setState(() {
            _rotinas = [];
          });
          final msg = (data is Map && data['Mensagem'] != null)
              ? data['Mensagem'].toString()
              : 'Falha ao carregar rotinas';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro HTTP: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildCard(Map<String, dynamic> rotina) {
    final title = rotina['nm_rotina'] ?? '';
    final desc = rotina['ds_rotina'] ?? '';
    final idRotina = rotina['id_rotina'];

    // Mapeia id_rotina para a imagem correspondente
    String imagePath = 'assets/rotina1.png'; // padrão
    
    // Converte para string para garantir comparação correta
    String idString = idRotina.toString();
    
    if (idString == '24') {
      imagePath = 'assets/rotina1.png';
    } else if (idString == '25') {
      imagePath = 'assets/rotina2.png';
    } else if (idString == '26') {
      imagePath = 'assets/rotina3.png';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Quadrado de fundo (mais claro e maior)
          Positioned(
            top: 8,
            left: 8,
            right: -8,
            bottom: -8,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFC4D6), // Rosa mais claro
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          // Quadrado principal (rosa)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFFF4D8A), // Rosa sólido
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 110, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFFFF4D8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // imagem à direita
          Positioned(
            right: -25,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 140,
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 72,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard() {
    return GestureDetector(
      onTap: () {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final idUsuario = args?['id_usuario']?.toString() ?? args?['idUsuario']?.toString() ?? '1';
        Navigator.pushNamed(context, '/agua', arguments: {'id_usuario': idUsuario});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
          // Quadrado de fundo (mais claro e maior)
          Positioned(
            top: 8,
            left: 8,
            right: -8,
            bottom: -8,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFE4F0), // Rosa bem claro
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          // Quadrado principal (branco/rosa claro)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 110, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE4F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Controlar Água',
                    style: TextStyle(
                      color: Color(0xFFFF4D8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Acompanhe sua hidratação diária e mantenha-se saudável bebendo a quantidade ideal de água.',
                  style: TextStyle(color: Color(0xFF666666)),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // imagem de água à direita
          Positioned(
            right: -6,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 140,
              child: Center(
                child: Image.asset(
                  'assets/agua.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_drink,
                      color: Color(0xFFFF4D8A),
                      size: 80,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = dadosUsuario?['nm_usuario'] ?? 'Usuário';

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadRotinas,
        child: Column(
          children: [
            // topo com saudação
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 8),
              color: Colors.white,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Olá, $nomeUsuario!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.only(top: 12, bottom: 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // Cards de rotinas do backend
                        if (_rotinas.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text('Nenhuma rotina encontrada'),
                            ),
                          )
                        else
                          ..._rotinas.map((rotina) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/exercicio_rotina',
                                  arguments: rotina,
                                );
                              },
                              child: _buildCard(rotina),
                            );
                          }).toList(),
                        // Card "Controlar Água"
                        _buildWaterCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
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
                  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                  final idUsuario = args?['id_usuario']?.toString() ?? args?['idUsuario']?.toString() ?? '1';
                  Navigator.pushReplacementNamed(context, '/agua', arguments: {'id_usuario': idUsuario});
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
    );
  }
}
