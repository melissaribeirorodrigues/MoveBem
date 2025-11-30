# TELA DESCRIÇÃO DO EXERCÍCIO

**Arquivo:** `lib/screens/tela_descricao_exercicio.dart`  
**Rota:** `/descricao_exercicio`

---

## O QUE FAZ

Mostra os detalhes de um exercício específico: imagem, nome, duração e instruções de como fazer. Tela simples, sem botões, só leitura.

---

## COMPONENTES USADOS

**StatelessWidget**
- Não tem estado
- Só exibe informações

**ModalRoute.of(context)**
- Pega arguments da navegação
- Exercício completo vem como Map

**SingleChildScrollView**
- Permite scroll se a descrição for longa

**Image.asset**
- Mostra imagem do exercício (220px de altura)
- Mapeamento por id_exercicio

**Text**
- Nome do exercício (rosa, bold, 22px)
- Duração (cinza, 14px)
- Descrição (preto, 16px, height 1.4)

---

## LÓGICA DA TELA

```
1. build() → pega arguments
2. Extrai exercicio do Map
3. Pega: nm_exercicio, ds_exercicio, vl_duracao, id_exercicio
4. _getImagemExercicio(id) → retorna path da imagem
5. Mostra imagem centralizada
6. Mostra nome (rosa)
7. Mostra duração em segundos
8. Mostra "Como fazer"
9. Mostra descrição completa
```

---

## RECEBENDO DADOS

**De /exercicio_rotina:**
```dart
arguments: {
  "exercicio": {
    "id_exercicio": 10,
    "nm_exercicio": "Inclinação lateral",
    "ds_exercicio": "Incline a cabeça...",
    "vl_duracao": 30
  }
}
```

**De /treino_acontecendo:**
```dart
arguments: {
  "exercicio": {...}  // exercício atual do treino
}
```

---

## MAPEAMENTO DE IMAGENS

Mesma lógica das outras telas:
```dart
final imagens = {
  10: 'assets/AM_1.png',
  11: 'assets/AM_2.png',
  12: 'assets/AM_3.png',
  // ... até 27
};
```

Imagens se repetem (6 imagens pra 18 exercícios).

**Fallback:** se id não existe → `assets/logo.png`

---

## ESTRUTURA DA TELA

```
AppBar ("Descrição do exercício")

SingleChildScrollView [
  Imagem (220px)
  
  Nome do exercício (rosa, bold)
  Duração: X segundos (cinza)
  
  "Como fazer" (bold)
  Descrição completa
]
```

---

## NAVEGAÇÃO

**AppBar voltar:**
- Navigator.pop() → volta pra tela anterior

Pode vir de:
- Tela de exercícios da rotina
- Tela de treino acontecendo (ícone info)

---

## VALIDAÇÕES

**id_exercicio:**
- null → usa logo.png

**nm_exercicio:**
- null → "Exercício"

**ds_exercicio:**
- null → "Descrição não encontrada."

**vl_duracao:**
- int.tryParse() → se falhar, usa 0

---

## CORES

- Fundo: branco
- AppBar: branco
- Nome: `#FF4D8A` (rosa)
- Duração: Colors.black54 (cinza)
- Descrição: preto
- "Como fazer": preto bold

---

## ASSETS

```
assets/AM_1.png até AM_6.png
assets/logo.png
```

---

## APRENDIZADOS

- StatelessWidget pra telas sem estado
- ModalRoute.of(context)!.settings.arguments
- Cast seguro: `as Map<String, dynamic>`
- int.tryParse pra conversão segura
- Operador ?? pra valores padrão
- height: 1.4 pra espaçamento entre linhas
- SizedBox.height pra altura fixa da imagem
