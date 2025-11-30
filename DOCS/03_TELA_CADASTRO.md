# TELA CADASTRO

**Arquivo:** `lib/screens/tela_cadastro.dart`  
**Rota:** `/cadastro`

---

## O QUE FAZ

Tela pra criar uma conta nova no app. Usuário preenche nome, e-mail e senha (2x pra confirmar). Valida os dados e envia pro backend que cria o usuário no banco. Se der certo, volta pra tela de login.

---

## COMPONENTES USADOS

**TextEditingController** (4 campos)
- `_nomeController` - nome do usuário
- `_emailController` - e-mail
- `_senhaController` - senha
- `_confirmarSenhaController` - confirmação da senha

**TextField**
- 4 campos de entrada
- Cada um com tipo de teclado específico
- Nome: `TextInputType.name`
- E-mail: `TextInputType.emailAddress`
- Senhas: `obscureText: true`

**IconButton (olhinhos)**
- 2 botões pra mostrar/esconder cada senha
- `_senhaVisivel` e `_confirmarSenhaVisivel`

**http.post**
- Envia dados pro backend PHP
- Operação: "Inserir"

**Container com BoxDecoration**
- Campos com borda rosa arredondada
- `BorderRadius.circular(30)`

**LinearGradient (topo)**
- Mesmo efeito da tela de login
- Rosa degradê no topo

**SafeArea e SingleChildScrollView**
- Protege áreas do sistema
- Permite scroll quando teclado aparece

---

## LÓGICA DO CADASTRO

```dart
// 1. Usuário preenche os 4 campos
// 2. Clica em "Cadastrar"
// 3. Validações:
//    - Todos os campos preenchidos?
//    - Senhas coincidem?
//    - Senha tem pelo menos 6 caracteres?
// 4. Se validou: mostra loading
// 5. Envia POST pro backend
// 6. Backend faz hash da senha e insere no banco
// 7. Se sucesso:
//    - Mostra mensagem verde
//    - Aguarda 1 segundo
//    - Volta pra tela de login
// 8. Se erro:
//    - Mostra mensagem vermelha do backend
```

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudUsuario.php`

**Requisição:**
```
POST
oper: "Inserir"
nome: "João Silva"
email: "joao@email.com"
senha: "123456"  (texto puro - backend faz o hash)
```

**Resposta (sucesso):**
```json
{
  "NumMens": 1,
  "Mensagem": "Cadastro realizado com sucesso"
}
```

**Resposta (erro):**
```json
{
  "NumMens": 0,
  "Mensagem": "E-mail já cadastrado"
}
```

**O que o backend faz:**
- Verifica se o e-mail já existe
- Criptografa a senha com `password_hash()`
- Insere no banco: `tb_usuario (nm_usuario, ds_email, ds_senha)`
- Retorna sucesso ou erro

**IMPORTANTE:** A senha é enviada em texto puro pro backend, que faz o hash com `password_hash()` do PHP. Assim fica compatível com o `password_verify()` do login.

---

## VALIDAÇÕES

**Campos vazios:**
```dart
if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
  return "Por favor, preencha todos os campos";
}
```

**Senhas não coincidem:**
```dart
if (senha != confirmarSenha) {
  return "As senhas não coincidem";
}
```

**Senha muito curta:**
```dart
if (senha.length < 6) {
  return "A senha deve ter no mínimo 6 caracteres";
}
```

---

## ERROS E SOLUÇÕES

**❌ E-mail duplicado**
- Problema: tentava cadastrar e-mail que já existia
- Solução: backend valida e retorna erro, app mostra mensagem

**❌ Senhas não conferiam**
- Problema: usuário digitava senhas diferentes
- Solução: validação antes de enviar pro backend

**❌ Hash de senha incompatível**
- Problema: primeiro tentamos fazer hash no Flutter, mas não batia com o PHP
- Solução: enviar senha em texto puro, deixar backend fazer o hash

**❌ Navegação antes de salvar**
- Problema: voltava pro login antes do backend confirmar
- Solução: usar `await` e só navegar depois do `Future.delayed`

**❌ Controllers não eram limpos**
- Problema: memory leak
- Solução: dispose de todos os 4 controllers

**❌ Botão cadastrar múltiplas vezes**
- Problema: clique duplo criava usuários duplicados
- Solução: desabilitar botão com `_carregando ? null : _cadastrar`

---

## NAVEGAÇÃO

**Origem:** Vem da tela de login (quando clica "Cadastre-se")

**Destino:** Volta pra `/login` após cadastro bem-sucedido

**Tipo:** `Navigator.pop(context)` - só volta, não cria nova rota

**Por quê?** Depois de cadastrar, o usuário precisa fazer login com a conta nova.

---

## DIFERENÇA PRA TELA DE LOGIN

| Login | Cadastro |
|-------|----------|
| 2 campos (e-mail, senha) | 4 campos (nome, e-mail, senha, confirmar) |
| Salva sessão | NÃO salva sessão |
| Vai pra /rotinas | Volta pra /login |
| Operação "Login" | Operação "Inserir" |
| Valida senha com hash | Backend cria hash |

---

## CORES

- Rosa escuro: `#FF4D8A`
- Rosa claro: `#FFA7C4`
- Branco: fundo e campos
- Cinza: placeholders
- Verde: sucesso
- Vermelho: erro

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
```

---

## APRENDIZADOS

- Validação de confirmação de senha
- Trim nos campos (remove espaços extras)
- Future.delayed pra dar tempo do usuário ver a mensagem
- Navigator.pop() pra voltar
- Não fazer hash de senha no frontend (deixar pro backend)
- Validar tamanho mínimo de senha
- 4 controllers = 4 dispose()
