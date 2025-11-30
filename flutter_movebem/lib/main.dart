import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/tela_treino_acontecendo.dart';
import 'screens/tela_login.dart';
import 'screens/tela_cadastro.dart';
import 'screens/tela_rotinas.dart';
import 'screens/tela_exercicio_rotina.dart';
import 'screens/tela_agua.dart';
import 'screens/tela_descricao_exercicio.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_historico.dart';
import 'screens/tela_recuperar_senha.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveBem - Splash',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),
        '/rotinas': (context) => const TelaRotinas(),
        '/exercicio_rotina': (context) => const TelaExercicioRotina(),
        '/agua': (context) => const TelaAgua(),
        '/perfil': (context) => const TelaPerfil(),
        '/treino_acontecendo': (context) => const TelaTreinoAcontecendo(),
        '/descricao_exercicio': (context) => const TelaDescricaoExercicio(),
        '/historico': (context) => const TelaHistorico(),
        '/recuperar_senha': (context) => const TelaRecuperarSenha(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;
  bool _navegou = false; // Flag para evitar múltiplas navegações

  final Color pink1 = const Color(0xFFFF4D8A);
  final Color pink2 = const Color(0xFFFFA7C4);

  // Inicia o progresso quando o widget é criado
  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  // Controla a animação da barra de progresso
  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();

          // Navega apenas uma vez
          if (!_navegou) {
            _navegou = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
          }
        }
      });
    });
  }

  // Libera o timer quando o widget é destruído
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Constrói a interface da tela de splash
  @override
  Widget build(BuildContext context) {
    final double logoSize = MediaQuery.of(context).size.width * 0.80;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo centralizado
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Barra de progresso e texto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Column(
                children: [
                  // Fundo arredondado da barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 12,
                      color: const Color(0xFFF3EAF0),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: _progress, // progresso de 0.0 a 1.0
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [pink1, pink2],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'CARREGANDO...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
