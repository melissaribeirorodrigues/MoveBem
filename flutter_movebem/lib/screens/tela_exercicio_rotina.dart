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
  int? _idRotina;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _nomeRotina = args['nm_rotina'] ?? '';
      _idRotina = args['id_rotina'];

      if (_idRotina != null) {
        _loadExercicios(_idRotina!);
      }
    }
  }

  Future<void> _loadExercicios(int idRotina) async {
    setState(() => _loading = true);

    try {
      final url = Uri.parse(
          'http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php');

      final response = await http.post(
        url,
        body: {
          'oper': 'Listar',
          'id_rotina': idRotina.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['NumMens'] == 1) {
          setState(() {
            _exercicios = data['dados'] ?? [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _exercicios = [];
        _loading = false;
      });
    }
  }

  // -----------------------
  //     TELA
  // -----------------------

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
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _exercicios.isEmpty
                    ? const Center(child: Text("Nenhum exercício encontrado"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _exercicios.length,
                        itemBuilder: (context, index) {
                          return _buildExercicioCard(_exercicios[index]);
                        },
                      ),
          ),

          // --------------------
          //  BOTÃO INICIAR
          // --------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_idRotina == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro: Rotina sem ID!")),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    '/treino_acontecendo',
                    arguments: {
                      "id_rotina": _idRotina,
                      "lista_exercicios": _exercicios,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "INICIAR ROTINA MATINAL",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------
  //    CARD DO EXERCÍCIO
  // -----------------------

  String _getImagemExercicio(int? idExercicio) {
    if (idExercicio == null) return 'assets/logo.png';
    
    final imagens = {
      10: 'assets/AM_1.png',  // Inclinação lateral do pescoço
      11: 'assets/AM_2.png',  // Rotação cervical
      12: 'assets/AM_3.png',  // Tríceps + lateral do tronco
      13: 'assets/AM_4.png',  // Peitoral na parede
      14: 'assets/AM_5.png',  // Alongamento em pé tocando os pés
      15: 'assets/AM_6.png',  // Extensão de coluna
      16: 'assets/AM_1.png',  // Abraço de ombros
      17: 'assets/AM_2.png',  // Alongamento de punho (palma para cima)
      18: 'assets/AM_3.png',  // Alongamento de punho (palma para baixo)
      19: 'assets/AM_4.png',  // Alongamento lateral em pé
      20: 'assets/AM_5.png',  // Círculos com tornozelos
      21: 'assets/AM_6.png',  // Flexão lombar sentado
      22: 'assets/AM_1.png',  // Posterior da coxa sentado
      23: 'assets/AM_2.png',  // Alongamento de pescoço para frente
      24: 'assets/AM_3.png',  // Alongamento de peitoral deitado
      25: 'assets/AM_4.png',  // Alongamento lateral suave deitado
      26: 'assets/AM_5.png',  // Deitar e abraçar os joelhos
      27: 'assets/AM_6.png',  // Respiração profunda com relaxamento
    };
    
    return imagens[idExercicio] ?? 'assets/logo.png';
  }

  Widget _buildExercicioCard(Map<String, dynamic> exercicio) {
    final nome = exercicio['nm_exercicio'];
    final duracao = exercicio['vl_duracao'];
    final id = exercicio['id_exercicio'];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/descricao_exercicio',
          arguments: {
            'id_exercicio': id,
            'id_rotina': _idRotina,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getImagemExercicio(id),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.fitness_center,
                        color: Color(0xFFFF4D8A), size: 32);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    "${duracao}s",
                    style: const TextStyle(color: Color(0xFFFF4D8A)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
