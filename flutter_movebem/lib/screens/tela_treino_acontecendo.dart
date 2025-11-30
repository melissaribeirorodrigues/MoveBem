import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaTreinoAcontecendo extends StatefulWidget {
  const TelaTreinoAcontecendo({Key? key}) : super(key: key);

  @override
  State<TelaTreinoAcontecendo> createState() => _TelaTreinoAcontecendoState();
}

class _TelaTreinoAcontecendoState extends State<TelaTreinoAcontecendo> {
  bool _loading = true;
  bool _error = false;
  String _errorMsg = '';
  List<Map<String, dynamic>> _exercicios = [];

  int _index = 0;
  int _remaining = 0;
  bool _isRunning = false;
  Timer? _timer;

  final int _restSeconds = 20;
  int _restRemaining = 0;
  Timer? _restTimer;

  int? _idRotina;

  /// contador geral (segundos)
  int _totalSeconds = 0;
  bool _saved = false;

  static const String backendRotinaUrl =
      'http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php';

  static const String backendHistoricoUrl =
      'http://200.19.1.19/usuario03/MoveBem/Controller/CrudHistoricoDiario.php';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _idRotina = args?['id_rotina'] ?? args?['idRotina'];

    if (_idRotina == null) {
      setState(() {
        _loading = false;
        _error = true;
        _errorMsg = 'Erro: ID da rotina não informado';
      });
      return;
    }

    if (_exercicios.isEmpty) _fetchRotina(_idRotina!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _saveIfNotSaved();
    super.dispose();
  }

  Future<void> _fetchRotina(int idRotina) async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final uri = Uri.parse(backendRotinaUrl);
      final r = await http.post(
        uri,
        body: {
          'oper': 'Listar',
          'id_rotina': idRotina.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
      final jsonData = json.decode(r.body);

      if (jsonData is Map && jsonData['NumMens'] == 1) {
        final dados = jsonData['dados'] ?? [];
        _exercicios = dados
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();

        if (_exercicios.isEmpty) {
          setState(() {
            _loading = false;
            _error = true;
            _errorMsg = 'Rotina sem exercícios';
          });
          return;
        }

        _startExerciseAtIndex(0);

        setState(() {
          _loading = false;
        });
      } else {
        throw Exception(jsonData['Mensagem'] ?? 'Resposta inesperada');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
        _errorMsg = 'Erro ao carregar rotina: $e';
      });
    }
  }

  void _startExerciseAtIndex(int idx) {
    if (!mounted) return;
    if (idx < 0 || idx >= _exercicios.length) return;

    final ex = _exercicios[idx];
    // garante que sempre converte para int
    final duration = int.tryParse(ex['vl_duracao'].toString()) ?? 0;

    _timer?.cancel();
    setState(() {
      _index = idx;
      _remaining = duration;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isRunning || !mounted) return;
      if (_remaining <= 0) {
        t.cancel();
        _onExerciseFinished();
      } else {
        setState(() {
          _remaining--;
          _totalSeconds++;
        });
      }
    });
  }

  void _onExerciseFinished() {
    final isLast = _index >= _exercicios.length - 1;

    if (isLast) {
      _showRoutineFinished();
      return;
    }

    _restRemaining = _restSeconds;
    _restTimer?.cancel();
    _restTimer = null;

    _showRestDialog();
  }

  void _showRestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            // cria o timer apenas uma vez
            _restTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!mounted) return;

              if (_restRemaining <= 0) {
                t.cancel();
                _restTimer = null;
                Navigator.of(context).pop();
                _advanceToNextExercise();
              } else {
                setStateDialog(() {
                  _restRemaining--;
                });
              }
            });

            return AlertDialog(
              backgroundColor: Colors.pink.shade50,
              title:
                  const Text('DESCANSO', style: TextStyle(color: Colors.pink)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Próximo: ${_exercicios[_index + 1]['nm_exercicio']}'),
                  const SizedBox(height: 12),
                  Text(
                    _formatSeconds(_restRemaining),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _restTimer?.cancel();
                      _restTimer = null;
                      Navigator.pop(context);
                      _advanceToNextExercise();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("PULAR DESCANSO"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _advanceToNextExercise() {
    _timer?.cancel();
    _restTimer?.cancel();
    _restTimer = null;

    final next = _index + 1;
    if (next >= _exercicios.length) {
      _showRoutineFinished();
    } else {
      _startExerciseAtIndex(next);
    }
  }

  void _showRoutineFinished() async {
    await _saveToDatabase();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("ROTINA FINALIZADA!"),
          content: const Text("Parabéns, você concluiu sua rotina."),
          actions: [
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("VOLTAR"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveIfNotSaved() async {
    if (_totalSeconds > 0 && !_saved) {
      await _saveToDatabase();
    }
  }

  Future<void> _saveToDatabase() async {
    if (_saved) return;

    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    if (usuarioJson == null || _idRotina == null) return;

    final dados = json.decode(usuarioJson);
    final idUsuario = dados['id_usuario'];
    
    if (idUsuario == null) return;

    final uri = Uri.parse(backendHistoricoUrl);

    await http.post(uri, body: {
      'oper': 'InserirHistorico',
      'id_usuario': idUsuario.toString(),
      'id_rotina': _idRotina.toString(),
      'vl_total_minutos': _totalSeconds.toString(),
    });

    _saved = true;
  }

  String _formatSeconds(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

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
    const pink1 = Color(0xFFFF4D8A);
    const pink2 = Color(0xFFFFA7C4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Treino", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await _saveToDatabase();
            if (mounted) Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.pink),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/descricao_exercicio',
                arguments: {
                  'exercicio': _exercicios[_index],
                },
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? Center(child: Text(_errorMsg))
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Text(
                            'Exercício ${_index + 1}/${_exercicios.length}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const Spacer(),
                          Text(
                            _exercicios[_index]['nm_exercicio'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 220,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        _getImagemExercicio(
                            _exercicios[_index]['id_exercicio']),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Mantenha a respiração!",
                      style:
                          TextStyle(color: pink1, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatSeconds(_remaining),
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isRunning = !_isRunning;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pink1,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isRunning ? "PAUSAR" : "RETOMAR"),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _saveToDatabase();
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pink2,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("ENCERRAR TREINO"),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
