import 'package:flutter/material.dart';

class TelaDescricaoExercicio extends StatelessWidget {
  const TelaDescricaoExercicio({Key? key}) : super(key: key);

  String _getImagemExercicio(int? idExercicio) {
    if (idExercicio == null) return 'assets/logo.png';

    final imagens = {
      10: 'assets/AM_1.png',
      11: 'assets/AM_2.png',
      12: 'assets/AM_3.png',
      13: 'assets/AM_4.png',
      14: 'assets/AM_5.png',
      15: 'assets/AM_6.png',
      16: 'assets/AM_1.png',
      17: 'assets/AM_2.png',
      18: 'assets/AM_3.png',
      19: 'assets/AM_4.png',
      20: 'assets/AM_5.png',
      21: 'assets/AM_6.png',
      22: 'assets/AM_1.png',
      23: 'assets/AM_2.png',
      24: 'assets/AM_3.png',
      25: 'assets/AM_4.png',
      26: 'assets/AM_5.png',
      27: 'assets/AM_6.png',
    };

    return imagens[idExercicio] ?? 'assets/logo.png';
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final exercicio = args['exercicio'] as Map<String, dynamic>;

    final nome = exercicio['nm_exercicio'] ?? 'Exercício';
    final descricao = exercicio['ds_exercicio'] ?? 'Descrição não encontrada.';
    final duracaoSeg = int.tryParse(exercicio['vl_duracao'].toString()) ?? 0;
    final idExercicio = exercicio['id_exercicio'] as int?;

    const pink1 = Color(0xFFFF4D8A);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Descrição do exercício',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 220,
                child: Image.asset(
                  _getImagemExercicio(idExercicio),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: pink1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duração aproximada: $duracaoSeg segundos',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Como fazer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
