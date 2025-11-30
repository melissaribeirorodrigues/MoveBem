# TELA CONSUMO DE ÁGUA

**Arquivo:** `lib/screens/tela_agua.dart`  
**Rota:** `/agua`

---

## O QUE FAZ

Registra a quantidade de água que o usuário bebeu durante o dia. Mostra o total acumulado do dia e exibe feedback visual quando adiciona água. Tem um campo pra digitar a quantidade em ml e salva no banco.

---

## COMPONENTES USADOS

**SharedPreferences**
- Pega o ID do usuário salvo no login
- Valida se o usuário está logado
- Se não tiver dados, manda pro login

**http.post - TotalDia**
- Busca o total de água já registrado no dia
- Endpoint: CrudRegistroAgua.php com oper=TotalDia

**http.post - Inserir**
- Salva a nova quantidade de água
- Soma no total do dia

**TextEditingController**
- Controla o campo de texto da quantidade
- Limpa após salvar
- Só aceita números (keyboardType: number)

**Container com feedback**
- Aparece quando salva água
- Mostra quantidade adicionada + total do dia
- Some sozinho depois de 3 segundos
- Gradient rosa

**Future.delayed**
- Esconde o feedback após 3 segundos
- Verifica se mounted antes de dar setState

**Bottom Navigation Bar**
- Mesmo das outras telas
- Água fica ativo (index 1)
- Home → /rotinas
- Água → já tá aqui
- Perfil → /perfil

---

## LÓGICA DA TELA

```
1. initState → _carregarDadosUsuario()
2. Busca usuario do SharedPreferences
3. Se não tiver → volta pro login
4. Se tiver → extrai id_usuario
5. Chama _carregarTotalDia() com esse ID
6. Backend retorna total do dia
7. Usuário digita quantidade (ex: 250ml)
8. Clica "Salvar Quantidade"
9. Valida se é número > 0
10. POST pro backend com id_usuario + qt_agua_ml
11. Backend insere e retorna sucesso
12. Atualiza _totalDia += quantidade
13. Mostra feedback visual por 3 segundos
14. Limpa o campo
```

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudRegistroAgua.php`

### Operação: TotalDia

**Requisição:**
```
POST
oper: "TotalDia"
id_usuario: "1"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "dados": {
    "total": 1500
  }
}
```

Soma todos os registros de água do dia atual daquele usuário.

### Operação: Inserir

**Requisição:**
```
POST
oper: "Inserir"
id_usuario: "1"
qt_agua_ml: "250"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "mensagem": "Registro inserido com sucesso"
}
```

Insere na `tb_registro_agua` com data/hora atual.

---

## CARREGAMENTO DE DADOS

```
initState:
  └─ _carregarDadosUsuario()
       ├─ SharedPreferences.getString('usuario')
       ├─ Se null → Navigator.pushReplacementNamed('/login')
       └─ Se ok → json.decode()
            ├─ Extrai id_usuario
            └─ _carregarTotalDia()
                 └─ POST TotalDia → atualiza _totalDia
```

Mesmo padrão das outras telas pra resolver o problema de perder dados.

---

## FEEDBACK VISUAL

Container que aparece no topo quando salva:
- Gradient rosa (#FF4D8A → #FF7BAC)
- Mostra "Você adicionou X ml"
- Mostra "Total dia: Y ml"
- Botão X pra fechar antes dos 3 segundos
- Aparece quando `_mostrarFeedback = true`
- Some automaticamente após 3 segundos

---

## VALIDAÇÕES

**Campo vazio ou zero:**
- `int.tryParse(_quantidadeController.text) ?? 0`
- Se for <= 0, não faz nada
- Não mostra erro, só não salva

**Usuário não logado:**
- Se SharedPreferences.getString('usuario') for null
- Redireciona pro /login

**Erro de rede:**
- Catch silencioso
- Não trava a tela
- Continua funcionando normalmente

---

## NAVEGAÇÃO

**Bottom Nav:**
- Home (index 0) → pushReplacementNamed('/rotinas')
- Água (index 1) → já está aqui
- Perfil (index 2) → pushNamed('/perfil', arguments: dadosUsuario)

**AppBar:**
- Botão voltar → Navigator.pop()

---

## ERROS E SOLUÇÕES

**❌ Perda de dados do usuário ao navegar**
- Problema: quando navegava entre telas, perdia os dados do usuário
- Solução: usar SharedPreferences pra salvar no login e ler de novo no initState

**❌ Total do dia não atualizava automaticamente**
- Problema: quando adicionava água, tinha que recarregar pra ver total atualizado
- Solução: somar localmente `_totalDia += quantidade` após salvar

**❌ Feedback ficava travado na tela**
- Problema: feedback não sumia sozinho
- Solução: `Future.delayed(3 segundos)` com verificação de `mounted`

**❌ TextField aceitava texto**
- Problema: usuário digitava letras
- Solução: `keyboardType: TextInputType.number` + `int.tryParse()`

**❌ Múltiplos cliques no botão**
- Problema: salvava várias vezes se clicar rápido
- Solução: limpar campo após salvar (`_quantidadeController.clear()`)

**❌ Erro ao buscar total do dia**
- Problema: se backend falhasse, quebrava a tela
- Solução: try-catch silencioso, deixa total em 0

---

## CORES

- Fundo: `#FFF0F5` (rosa bem claro)
- Gradient feedback: `#FF4D8A` → `#FF7BAC`
- Botão salvar: `#FF4D8A`
- Bottom nav: mesmo gradient
- Campo texto: branco com sombra

---

## ASSETS

```
assets/agua.png  (imagem do copo)
```

Imagem tem 200x280px, centralizada.

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

---

## APRENDIZADOS

- SharedPreferences pra manter sessão do usuário
- Future.delayed pra animações temporárias
- Validação com mounted antes de setState
- TextEditingController.dispose() pra evitar memory leak
- keyboardType.number pra teclado numérico
- try-catch silencioso quando erro não é crítico
- Feedback visual melhora UX (mostra confirmação)
- Atualizar total localmente ao invés de recarregar do backend
