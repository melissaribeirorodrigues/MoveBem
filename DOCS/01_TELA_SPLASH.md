# TELA SPLASH

**Arquivo:** `lib/main.dart`  
**Rota:** `/`

---

## O QUE FAZ

Primeira tela que aparece quando abre o app. Mostra o logo do MoveBem e uma barra de carregamento. Depois de 4 segundos vai automaticamente pra tela de login.

---

## COMPONENTES USADOS

**Timer.periodic**
- Executa uma função a cada 80ms
- Aumenta o progresso da barra de 0% até 100%
- Quando chega em 100%, navega pro login

**FractionallySizedBox**
- Faz a barra de progresso crescer
- widthFactor vai de 0.0 (vazio) até 1.0 (cheio)

**LinearGradient**
- Degradê rosa na barra de progresso
- Vai de rosa escuro (#FF4D8A) pra rosa claro (#FFA7C4)

**Image.asset**
- Carrega o logo de `assets/logo.png`

**MediaQuery** (responsividade)
- Pega o tamanho da tela do celular
- `MediaQuery.of(context).size.width` = largura da tela
- Usamos pra calcular o tamanho do logo: `logoSize = largura * 0.80` (80% da tela)

**SafeArea**
- Evita que os elementos fiquem embaixo da barra de notificação ou botões do celular
- Coloca padding automático nas áreas do sistema

**Navigator.pushReplacementNamed**
- Navega pra próxima tela MAS substitui a tela atual
- Usamos `pushReplacementNamed('/login')` em vez de `pushNamed`
- Diferença: com replacement, o usuário NÃO consegue voltar pra splash apertando o botão voltar
- Faz sentido porque ninguém precisa voltar pra tela de carregamento

---

## LÓGICA

```dart
// Variáveis
double _progress = 0.0;     // progresso: 0.0 até 1.0
Timer? _timer;              // controla a animação
bool _navegou = false;      // evita navegar 2x

// Quando abre a tela
initState() → _startProgress()

// Cria timer que roda a cada 80ms
Timer.periodic(80ms) {
  _progress += 0.02        // soma 2%
  setState()               // redesenha a tela
  
  if (_progress >= 1.0) {
    timer.cancel()
    navega pro login
  }
}

// Tempo total: 50x 0.02 = 1.0 em 50 iterações × 80ms = 4 segundos
```

---

## BACKEND

Nenhum. Só frontend.

---

## ERROS E SOLUÇÕES

**❌ Timer navegava múltiplas vezes**
- Problema: chegava em 100% e tentava navegar várias vezes
- Solução: flag `_navegou` pra garantir que só navega uma vez

**❌ Memory leak**
- Problema: timer continuava rodando depois de sair da tela
- Solução: cancelar o timer no `dispose()`

**❌ Logo não aparecia**
- Problema: esquecemos de declarar no pubspec.yaml
- Solução: adicionar `assets/logo.png` no pubspec e dar `flutter pub get`

**❌ Erro de contexto ao navegar**
- Problema: navegava antes da tela estar pronta
- Solução: usar `WidgetsBinding.instance.addPostFrameCallback()`

---

## CORES

- Rosa escuro: `#FF4D8A`
- Rosa claro: `#FFA7C4`
- Fundo barra: `#F3EAF0`
- Texto: `Colors.grey[700]`

---

## ASSETS

```
assets/logo.png
```

---

## APRENDIZADOS

- Timer.periodic pra animações simples
- Sempre cancelar timers no dispose()
- pushReplacementNamed substitui a tela (não dá pra voltar)
- Usar flags pra evitar ações duplicadas
- addPostFrameCallback garante que o contexto tá pronto
