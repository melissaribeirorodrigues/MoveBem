import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({Key? key}) : super(key: key);

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  DateTime _selectedDay = DateTime.now();
  bool _loading = false;
  Map<String, dynamic>? _dados;

  static const String backendUrl =
      "http://200.19.1.19/usuario03/MoveBem/Controller/CrudHistoricoDiario.php";

  int? _idUsuario;

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
        _idUsuario = dados['id_usuario'];
      });
      _carregarDados(_selectedDay);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _carregarDados(DateTime data) async {
    if (_idUsuario == null) return;
    
    setState(() => _loading = true);

    try {
      final resp = await http.post(
        Uri.parse(backendUrl),
        body: {
          "oper": "ResumoPorData",
          "id_usuario": _idUsuario.toString(),
          "data": "${data.toIso8601String().substring(0, 10)}"
        },
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          _dados = data;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const pink1 = Color(0xFFFF4D8A);

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
          "Histórico",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              focusedDay: _selectedDay,
              firstDay: DateTime(2023),
              lastDay: DateTime(2030),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (day, _) {
                setState(() => _selectedDay = day);
                _carregarDados(day);
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: pink1,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _dados == null
                    ? const Center(child: Text("Nenhum dado encontrado"))
                    : _buildResultado(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado() {
    final totalMin = _dados?['total_minutos_exercicio'] ?? 0;
    final totalAgua = _dados?['total_agua_ml'] ?? 0;
    final detalhesAgua = _dados?['detalhes_agua'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Total de Minutos de Alongamento",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Você realizou ${totalMin} segundos",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            "Consumo de Água",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Você consumiu ${totalAgua}ml de água",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          for (var item in detalhesAgua)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "+ ${item['qt_agua_ml']}ml  •  ${item['dh_ingestao_agua']}",
                style: const TextStyle(color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}
