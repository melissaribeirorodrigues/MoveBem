import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelaExercicioRotina extends StatefulWidget {
  const TelaExercicioRotina({Key? key}) : super(key: key);

  @override
  State<TelaExercicioRotina> createState() => _TelaExercicioRotinaState();
}

class _TelaExercicioRotinaState extends State<TelaExercicioRotina> {
  bool _loading = true;
  List<dynamic> _exercicios = [];
  String _nomeRotina = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _nomeRotina = args['nm_rotina'] ?? '';
      final idRotina = args['id_rotina'];
      if (idRotina != null) {
        _loadExercicios(idRotina);
      }
    }
  }

  Future<void> _loadExercicios(int idRotina) async {
    setState(() {
      _loading = true;
    });

    try {
      final url = Uri.parse('http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php');
      print('Buscando exercícios para rotina ID: $idRotina');
      final response = await http.post(
        url,
        body: {
          'oper': 'Listar',
          'id_rotina': idRotina.toString(),
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data decoded: $data');
        if (data['NumMens'] == 1 && data['Mensagem'] == 'Sucesso na Pesquisa') {
          setState(() {
            _exercicios = data['dados'] ?? [];
            print('Exercícios carregados: ${_exercicios.length}');
            _loading = false;
          });
        } else {
          print('Erro na resposta: ${data['Mensagem']}');
          setState(() {
            _exercicios = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar exercícios: $e');
      setState(() {
        _exercicios = [];
        _loading = false;
      });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _nomeRotina,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _exercicios.isEmpty
                    ? const Center(child: Text('Nenhum exercício encontrado'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _exercicios.length,
                        itemBuilder: (context, index) {
                          final exercicio = _exercicios[index];
                          return _buildExercicioCard(exercicio);
                        },
                      ),
          ),
          // Botão "Iniciar Rotina"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Ação para iniciar a rotina
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                child: const Text(
                  'INICIAR ROTINA MATINAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            margin: const EdgeInsets.all(16.0),
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4D8A), Color(0xFFFF7BAC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: const Icon(Icons.water_drop, color: Colors.white70, size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white70, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercicioCard(Map<String, dynamic> exercicio) {
    final nomeExercicio = exercicio['nm_exercicio'] ?? 'Exercício';
    final duracao = exercicio['vl_duracao'] ?? 0;
    final idExercicio = exercicio['id_exercicio'];
    
    // Mapeia id_exercicio para a imagem correspondente
    String imagePath = 'assets/exercicio_default.png';
    String idString = idExercicio.toString();
    
    if (idString == '14') {
      imagePath = 'assets/AM_1.png';
    } else if (idString == '15') {
      imagePath = 'assets/AM_2.png';
    } else if (idString == '10') {
      imagePath = 'assets/AM_3.png';
    } else if (idString == '11') {
      imagePath = 'assets/AM_5.png';
    } else if (idString == '13') {
      imagePath = 'assets/AM_4.png';
    } else if (idString == '12') {
      imagePath = 'assets/AM_6.png';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem do exercício
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fitness_center,
                    color: Color(0xFFFF4D8A),
                    size: 28,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informações do exercício
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeExercicio,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (duracao > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${duracao}s',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF4D8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
