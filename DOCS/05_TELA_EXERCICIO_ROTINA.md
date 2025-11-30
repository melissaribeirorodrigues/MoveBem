# TELA EXERCÍCIOS DA ROTINA

**Arquivo:** `lib/screens/tela_exercicio_rotina.dart`  
**Rota:** `/exercicio_rotina`

---

## O QUE FAZ

Mostra a lista de exercícios de uma rotina específica. Recebe os dados da rotina da tela anterior, busca os exercícios no backend e lista eles. Tem um botão "INICIAR ROTINA" embaixo que começa o treino.

---

## COMPONENTES USADOS

**didChangeDependencies**
- Executa quando a tela recebe os arguments
- Pega os dados da rotina que veio da tela anterior
- Chama o backend pra buscar os exercícios

**http.post**
- Busca exercícios pelo id_rotina
- Endpoint: CrudRotinaExercicio.php

**ListView.builder**
- Cria a lista de exercícios dinamicamente
- Um card pra cada exercício

**InkWell**
- Efeito de clique nos cards
- Navega pra tela de descrição do exercício

**Container com border**
- Cards brancos com borda cinza
- `Border.all(color: Colors.grey.shade300)`

**ClipRRect**
- Imagem do exercício com bordas arredondadas
- Rosa de fundo se não carregar

**AppBar**
- Mostra o nome da rotina no topo
- Botão voltar

---

## LÓGICA DA TELA

```dart
// 1. Tela abre → didChangeDependencies()
// 2. Pega arguments da navegação
// 3. Extrai: nm_rotina (nome) e id_rotina (ID)
// 4. Chama _loadExercicios(id_rotina)
// 5. Backend retorna lista de exercícios daquela rotina
// 6. Guarda em _exercicios = []
// 7. Pra cada exercício, cria um card com:
//    - Imagem (mapeada pelo id_exercicio)
//    - Nome do exercício
//    - Duração em segundos
// 8. Clique no card → vai pra /descricao_exercicio
// 9. Clique em "INICIAR" → vai pra /treino_acontecendo
```

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php`

**Requisição:**
```
POST
oper: "Listar"
id_rotina: "24"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "dados": [
    {
      "id_exercicio": 10,
      "nm_exercicio": "Inclinação lateral do pescoço",
      "ds_exercicio": "Incline a cabeça...",
      "vl_duracao": 30
    },
    {
      "id_exercicio": 11,
      "nm_exercicio": "Rotação cervical",
      "ds_exercicio": "Gire lentamente...",
      "vl_duracao": 40
    }
    // ... mais exercícios
  ]
}
```

**O que o backend faz:**
- JOIN entre `tb_rotina_exercicio` e `tb_exercicio`
- Filtra pelo `id_rotina` recebido
- Retorna exercícios daquela rotina específica na ordem

---

## RECEBENDO OS DADOS

```dart
didChangeDependencies() {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  
  if (args != null) {
    _nomeRotina = args['nm_rotina'] ?? '';  // nome pra mostrar no AppBar
    _idRotina = args['id_rotina'];           // ID pra buscar exercícios
    
    _loadExercicios(_idRotina);
  }
}
```

**Por que didChangeDependencies?**
- Não dá pra pegar arguments no initState
- didChangeDependencies roda depois que o context tá pronto
- Só executa a busca uma vez (verifica se `_exercicios.isEmpty`)

---

## MAPEAMENTO DE IMAGENS

Cada exercício tem uma imagem específica:
```dart
final imagens = {
  10: 'assets/AM_1.png',  // Inclinação lateral
  11: 'assets/AM_2.png',  // Rotação cervical
  12: 'assets/AM_3.png',  // Tríceps
  13: 'assets/AM_4.png',  // Peitoral
  // ... até 27
};
```

Temos 6 imagens (AM_1 a AM_6) que se repetem pros 18 exercícios.

**Imagem padrão:** Se o id não existir no mapa, usa `assets/logo.png`

---

## ESTRUTURA DOS CARDS

```dart
Container com borda cinza
  Row [
    Container rosa (#FFE4F0)
      Imagem do exercício (55x55)
    
    Coluna [
      Nome do exercício (bold)
      Duração em segundos (rosa)
    ]
  ]
```

Bem simples, sem efeito de sombra (diferente dos cards da tela de rotinas).

---

## BOTÃO INICIAR ROTINA

```dart
ElevatedButton(
  "INICIAR ROTINA MATINAL"
  cor: branco
  borda: preta
  
  onPressed: navega pra /treino_acontecendo
)
```

**Dados enviados:**
```dart
arguments: {
  "id_rotina": _idRotina,
  "lista_exercicios": _exercicios  // lista completa!
}
```

Manda a lista inteira pra próxima tela não precisar buscar de novo.

---

## NAVEGAÇÃO

**Recebe de /rotinas:**
```dart
{
  "id_rotina": 24,
  "nm_rotina": "Rotina Matinal",
  "ds_rotina": "..."
}
```

**Envia pra /treino_acontecendo:**
```dart
{
  "id_rotina": 24,
  "lista_exercicios": [ex1, ex2, ex3, ...]
}
```

**Envia pra /descricao_exercicio:**
```dart
{
  "id_exercicio": 10,
  "id_rotina": 24
}
```

---

## ERROS E SOLUÇÕES

**❌ Perda de dados do usuário ao navegar**
- Problema: quando navegava entre telas, perdia os dados do usuário (nome, email, etc)
- Solução: usar SharedPreferences pra salvar no login e ler de novo em cada tela que precisa

**❌ Arguments null**
- Problema: navegava sem passar dados
- Solução: validar `if (args != null)` antes de usar

**❌ Busca infinita de exercícios**
- Problema: didChangeDependencies chamava várias vezes
- Solução: só buscar se `_exercicios.isEmpty`

**❌ Imagens não carregavam**
- Problema: faltavam assets no pubspec
- Solução: adicionar todas as AM_1 até AM_6

**❌ Conversão de duração**
- Problema: às vezes vinha string, às vezes int
- Solução: `int.tryParse(exercicio['vl_duracao'].toString())`

**❌ ID null no botão iniciar**
- Problema: _idRotina era null e dava erro
- Solução: validar antes de navegar e mostrar SnackBar se for null

**❌ Lista vazia quando backend falhava**
- Problema: não mostrava nada se desse erro
- Solução: setar `_exercicios = []` no catch e mostrar mensagem

---

## CORES

- Fundo da imagem: `#FFE4F0` (rosa claro)
- Borda do card: `Colors.grey.shade300`
- Nome exercício: preto
- Duração: `#FF4D8A` (rosa escuro)
- Botão: branco com borda preta

---

## ASSETS

```
assets/AM_1.png
assets/AM_2.png
assets/AM_3.png
assets/AM_4.png
assets/AM_5.png
assets/AM_6.png
assets/logo.png  (fallback)
```

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
```

---

## APRENDIZADOS

- didChangeDependencies pra pegar arguments
- ModalRoute.of(context)?.settings.arguments pra receber dados
- ListView.builder pra listas dinâmicas
- Mapear IDs pra assets específicos
- Passar lista completa pra próxima tela (evita nova busca)
- Validar null em arguments
- InkWell pra efeito de clique
- int.tryParse pra converter tipos seguros
