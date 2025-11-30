# TELA PERFIL

**Arquivo:** `lib/screens/tela_perfil.dart`  
**Rota:** `/perfil`

---

## O QUE FAZ

Mostra os dados do usuário logado (nome, email, senha oculta). Permite editar nome, alterar senha, ver histórico, sair da conta e excluir conta. Tudo com diálogos de confirmação.

---

## COMPONENTES USADOS

**SharedPreferences**
- Carrega dados do usuário no initState
- Se não tiver, manda pro login
- Atualiza quando nome é alterado

**AlertDialog**
- Diálogos pra editar nome, alterar senha, sair e excluir
- Validações antes de executar ações

**GestureDetector**
- Ícone de editar no nome
- Link pro histórico

**Container circular**
- Avatar do usuário (ícone person_outline)
- Borda rosa

**_buildCampoInfo**
- Widget reutilizável pra mostrar email
- Row com label e valor
- Borda inferior cinza

**Bottom Navigation Bar**
- Mesmo das outras telas
- Perfil fica ativo (branco)

**http.post**
- Alterar nome: oper=Alterar
- Alterar senha: oper=AlterarSenha (validação com Login antes)
- Excluir conta: oper=Excluir

**SingleChildScrollView**
- No diálogo de senha pra evitar overflow
- Na tela principal também

---

## LÓGICA DA TELA

```
1. initState → _carregarDadosUsuario()
2. SharedPreferences.getString('usuario')
3. Se null → vai pro login
4. Se ok → extrai nm_usuario e ds_email
5. Mostra avatar + nome + email + senha (********)
6. Clique editar nome → abre diálogo → POST Alterar → atualiza SharedPreferences
7. Clique alterar senha → abre diálogo → valida atual com Login → POST AlterarSenha
8. Clique histórico → Navigator.pushNamed('/historico')
9. Clique sair → remove SharedPreferences → vai pro login
10. Clique excluir → POST Excluir → remove SharedPreferences → vai pro login
```

---

## BACKEND

### Operação: Alterar (nome)

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudUsuario.php`

**Requisição:**
```
POST
oper: "Alterar"
id_usuario: "33"
nm_usuario: "Melissa"
ds_email: "melissa@gmail.com"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "Mensagem": "Dados do usuario Alterados"
}
```

**O que faz:**
- UPDATE TB_Usuario SET nm_usuario, ds_email WHERE id_usuario
- NÃO mexe na senha (separado)

---

### Operação: AlterarSenha

**Requisição:**
```
POST
oper: "AlterarSenha"
id_usuario: "33"
ds_senha: "novaSenha123"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "Mensagem": "Senha alterada com sucesso"
}
```

**O que faz:**
- Criptografa senha com password_hash
- UPDATE TB_Usuario SET ds_senha WHERE id_usuario

**Validação antes:**
- Faz Login com email + senha atual
- Se NumMens != 1, mostra "Senha atual incorreta"
- Se passar, aí chama AlterarSenha

---

### Operação: Excluir

**Requisição:**
```
POST
oper: "Excluir"
id_usuario: "33"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "Mensagem": "Usuario Excluido com Sucesso"
}
```

**O que faz:**
- DELETE FROM tb_historico_diario WHERE id_usuario
- DELETE FROM tb_registro_agua WHERE id_usuario
- DELETE FROM TB_Usuario WHERE id_usuario
- Tudo em transação (rollback se falhar)

---

## DIÁLOGOS

### Editar Nome

- TextField com valor atual
- Validação: não pode vazio
- POST Alterar → atualiza SharedPreferences → setState(nomeUsuario)

### Alterar Senha

- 3 TextFields: atual, nova, confirmar
- Validações:
  - Todos preenchidos
  - Nova == Confirmar
  - Nova >= 6 caracteres
  - Atual validada com Login
- POST AlterarSenha

### Sair

- Diálogo de confirmação
- Remove SharedPreferences
- Navigator.pushReplacementNamed('/login')

### Excluir Conta

- Diálogo de confirmação
- POST Excluir
- Remove SharedPreferences
- Navigator.pushReplacementNamed('/login')

---

## NAVEGAÇÃO

**Bottom Nav:**
- Home → pushReplacementNamed('/rotinas')
- Água → pushReplacementNamed('/agua')
- Perfil → já tá aqui (ícone branco)

**AppBar voltar:**
- pushReplacementNamed('/rotinas')

**Link Histórico:**
- pushNamed('/historico')

---

## ERROS E SOLUÇÕES

**❌ Perda de dados do usuário ao navegar**
- Problema: quando navegava entre telas, perdia dados
- Solução: SharedPreferences no initState de todas as telas

**❌ Senha sendo criptografada ao editar nome**
- Problema: AlterarDadosUsuario criptografava senha de novo
- Solução: separar em Alterar (nome/email) e AlterarSenha (só senha)

**❌ Validação de senha atual não funcionava**
- Problema: tentava comparar com senha criptografada no SharedPreferences
- Solução: fazer Login com email + senha atual pra validar no backend

**❌ Dialog de senha com overflow**
- Problema: 3 campos não cabiam na tela pequena
- Solução: SingleChildScrollView no content do AlertDialog

**❌ Excluir conta dava erro de foreign key**
- Problema: usuário tinha registros em outras tabelas
- Solução: deletar em cascata (histórico, água, depois usuário)

**❌ Senha resetada mas login não funcionava**
- Problema: senha no banco não tava criptografada corretamente
- Solução: criar script resetar_senha.php com password_hash

---

## CORES

- Fundo: branco
- Avatar borda: `#FF69B4` (rosa)
- Ícone editar: `#FF69B4`
- Link alterar senha: `#00B0FF` (azul)
- Botão sair: `#FFC1E3` (rosa claro) com texto `#FF69B4`
- Botão excluir: `#FF69B4` com texto branco
- Bottom nav: gradient `#FF4D8A` → `#F1AEC2`

---

## VALIDAÇÕES

**Nome:**
- Não pode vazio (trim)

**Senha:**
- Todos campos preenchidos
- Nova == Confirmar
- Nova >= 6 caracteres
- Atual validada com backend

**Excluir conta:**
- Diálogo de confirmação dupla

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

---

## APRENDIZADOS

- Separar operações de alteração (nome vs senha)
- Validar senha atual pelo backend (não localmente)
- SingleChildScrollView em diálogos grandes
- Sempre validar mounted antes de setState após async
- Atualizar SharedPreferences quando altera dados
- Transações no backend pra exclusão em cascata
- Diálogos de confirmação pra ações destrutivas
- TextEditingController pre-populado com valor atual
- GestureDetector pra ícones clicáveis
