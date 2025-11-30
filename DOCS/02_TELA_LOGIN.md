# TELA LOGIN

**Arquivo:** `lib/screens/tela_login.dart`  
**Rota:** `/login`

---

## O QUE FAZ

Tela onde o usuário faz login no app. Tem campos de e-mail e senha, valida os dados e manda pro backend PHP. Se der certo, salva os dados do usuário localmente e vai pra tela de rotinas.

---

## COMPONENTES USADOS

**TextEditingController**
- Controla o que o usuário digita nos campos
- `_emailController` e `_senhaController`
- Conseguimos pegar o texto com `.text`

**TextField**
- Campo de entrada de texto
- `keyboardType: TextInputType.emailAddress` - mostra teclado de e-mail
- `obscureText: true` - esconde a senha com bolinhas
- `textInputAction: TextInputAction.next` - botão "próximo" no teclado

**IconButton (olhinho da senha)**
- Botão pra mostrar/esconder senha
- Muda o ícone entre `visibility` e `visibility_off`
- Alterna a variável `_senhaVisivel`

**http.post**
- Faz requisição POST pro backend PHP
- Envia e-mail e senha
- Recebe resposta em JSON

**SharedPreferences**
- Salva dados localmente no celular
- Usado pra guardar os dados do usuário logado
- Fica salvo mesmo se fechar o app

**ScaffoldMessenger.showSnackBar**
- Mostra mensagens na parte de baixo da tela
- Verde = sucesso, Vermelho = erro

**CircularProgressIndicator**
- Bolinha girando que aparece durante o login
- Fica no botão enquanto `_carregando = true`

**Container com BoxDecoration**
- Bordas arredondadas nos campos
- `BorderRadius.circular(30)` = bem redondinho
- `border: Border.all()` = borda rosa

**LinearGradient (topo)**
- Degradê rosa no topo da tela
- Efeito de luz indo do rosa escuro pro transparente

**SafeArea**
- Protege contra barra de notificação

**SingleChildScrollView**
- Permite rolar a tela se o teclado aparecer

---

## LÓGICA DO LOGIN

```dart
// 1. Usuário digita e-mail e senha
// 2. Clica no botão "Entrar"
// 3. Validação básica (campos vazios?)
// 4. Mostra loading no botão
// 5. Faz POST pro backend
// 6. Backend valida e retorna JSON
// 7. Se sucesso:
//    - Salva dados no SharedPreferences
//    - Navega pra /rotinas
// 8. Se erro:
//    - Mostra mensagem de erro vermelha
```

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudUsuario.php`

**Requisição:**
```
POST
oper: "Login"
email: "usuario@email.com"
senha: "123456"
```

**Resposta (sucesso):**
```json
{
  "NumMens": 1,
  "Mensagem": "Login realizado",
  "dados": {
    "id_usuario": 5,
    "nm_usuario": "João",
    "ds_email": "joao@email.com"
  }
}
```

**Resposta (erro):**
```json
{
  "NumMens": 0,
  "Mensagem": "E-mail ou senha incorretos"
}
```

**O que o backend faz:**
- Valida se o e-mail existe no banco
- Compara a senha usando `password_verify()` (senha é criptografada com hash)
- Retorna os dados do usuário se estiver correto

---

## VERIFICAÇÃO DE SESSÃO

```dart
// Quando abre a tela
initState() {
  _verificarSessao()
}

// Verifica se já tem usuário salvo
_verificarSessao() {
  se tem dados salvos no SharedPreferences:
    navega direto pra /rotinas (já tá logado)
  senão:
    fica na tela de login
}
```

**Por quê?** Se o usuário já fez login antes, não precisa logar de novo toda vez que abre o app.

---

## SALVAR SESSÃO

```dart
_salvarSessao(dadosUsuario) {
  SharedPreferences.setString('usuario', JSON do usuário)
  commit() // força salvar agora
}
```

Isso mantém o usuário logado mesmo fechando o app.

---

## ERROS E SOLUÇÕES

**❌ Senha aparecia em texto puro**
- Problema: dava pra ver a senha digitando
- Solução: `obscureText: true` no TextField da senha

**❌ Backend não recebia os dados**
- Problema: CORS bloqueava requisições do Flutter
- Solução: adicionar headers CORS no PHP:
```php
header('Access-Control-Allow-Origin: *');
```

**❌ Timeout em rede lenta**
- Problema: app travava se internet tava ruim
- Solução: adicionar timeout de 10 segundos:
```dart
.timeout(Duration(seconds: 10))
```

**❌ Múltiplas tentativas de login**
- Problema: usuário clicava várias vezes no botão
- Solução: desabilitar botão enquanto `_carregando = true`

**❌ Vazamento de memória**
- Problema: controllers não eram destruídos
- Solução: dispose dos controllers:
```dart
dispose() {
  _emailController.dispose();
  _senhaController.dispose();
}
```

**❌ Sessão não persistia**
- Problema: SharedPreferences não salvava
- Solução: adicionar `await prefs.commit()` depois do `setString`

**❌ Navegação com dados errados**
- Problema: navegava antes de salvar completamente
- Solução: usar `await` antes de navegar

---

## NAVEGAÇÃO

**Destinos:**
- `/rotinas` → quando login dá certo (passa dados do usuário)
- `/cadastro` → quando clica em "Cadastre-se"
- `/recuperar_senha` → quando clica em "Esqueceu sua senha?"

**Tipo:** `pushReplacementNamed('/rotinas')` - substitui o login, não dá pra voltar

**Dados passados:**
```dart
Navigator.pushReplacementNamed(
  context,
  '/rotinas',
  arguments: data['dados'], // dados do usuário
);
```

---

## CORES

- Rosa escuro: `#FF4D8A`
- Rosa claro: `#FFA7C4`
- Branco: campos e fundo
- Cinza placeholder: `Colors.grey[400]`
- Verde: mensagem de sucesso
- Vermelho: mensagem de erro

---

## VALIDAÇÕES

- Campos vazios → "Por favor, preencha todos os campos"
- E-mail/senha errados → mensagem do backend
- Sem internet → "Erro de conexão"
- Timeout → "Timeout ao conectar com o servidor"

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0  # requisições HTTP
  shared_preferences: ^2.2.2  # salvar dados localmente
```

---

## APRENDIZADOS

- http.post pra chamar APIs
- SharedPreferences pra persistência local
- TextField com validações
- obscureText pra senhas
- Timeout em requisições
- Verificar sessão no initState
- dispose() dos controllers
- async/await pra operações assíncronas
- setState() muda o estado visual (loading, visibilidade senha)
