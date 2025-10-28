# MoveBem - Tela de Carregamento (Splash Screen)

Este pequeno projeto Flutter contém a tela de carregamento inicial que aparece quando o app é aberto.

## Arquivos criados
- `lib/main.dart` — Aplicação Flutter com a tela `SplashScreen` (tela de carregamento)
- `pubspec.yaml` — Manifest do projeto referenciando `assets/logo.png`
- `assets/` — Pasta para a imagem do logo. Coloque o logo do MoveBem como `assets/logo.png`

## O que o `main.dart` faz?
**Sim, o `main.dart` é a primeira tela que aparece quando você abre o app.** Ele contém:
- A tela de carregamento (`SplashScreen`) com o logo centralizado
- Uma barra de progresso animada embaixo (com gradiente rosa)
- O texto "CARREGANDO..."
- Um timer que simula o carregamento (quando chega a 100%, você pode navegar para a próxima tela)

## Como executar no Android Studio

### Opção 1: Abrir no Android Studio (Recomendado)
1. Abra o Android Studio
2. Clique em `File` → `Open...`
3. Navegue até a pasta: `c:\Users\user\Desktop\Faculdade\Dispositivos Moveis\MoveBem\flutter_movebem`
4. Clique em `OK`
5. Aguarde o Android Studio indexar o projeto e baixar as dependências automaticamente
6. **Importante**: Coloque a imagem do logo em `assets/logo.png` antes de rodar
7. No canto superior direito, selecione um dispositivo (emulador Android ou Chrome)
8. Clique no botão ▶️ (Run) ou pressione `Shift+F10`

### Opção 2: Via linha de comando (PowerShell)
1. Instale o Flutter SDK (https://flutter.dev/docs/get-started/install) se ainda não tiver
2. No PowerShell, vá até a pasta do projeto:

```powershell
cd "c:\Users\user\Desktop\Faculdade\Dispositivos Moveis\MoveBem\flutter_movebem"
```

3. Coloque a imagem do logo em `assets/logo.png`

4. Baixe as dependências e rode o app:

```powershell
flutter pub get
flutter run -d chrome   # para rodar no navegador
# ou
flutter run             # para rodar em dispositivo/emulador conectado
```

### Criar/iniciar um emulador Android

#### Via Android Studio (GUI)
Se você não tiver um emulador configurado:
1. No Android Studio, vá em `Tools` → `Device Manager`
2. Clique em `Create Device`
3. Escolha um dispositivo (ex: Pixel 6) → `Next`
4. Baixe uma system image (ex: Android 13/Tiramisu) → `Next` → `Finish`
5. Clique no botão ▶️ para iniciar o emulador
6. Rode o projeto Flutter normalmente

#### Via linha de comando (PowerShell/CMD)

**1. Listar emuladores disponíveis:**
```powershell
# Navegue até a pasta do Android SDK (normalmente em):
cd C:\Users\user\AppData\Local\Android\Sdk\emulator

# Liste os emuladores criados:
.\emulator.exe -list-avds
```

**2. Iniciar um emulador específico:**
```powershell
# Substitua "nome_do_emulador" pelo nome que apareceu no comando anterior
.\emulator.exe -avd nome_do_emulador
```

**Exemplo prático:**
```powershell
cd C:\Users\user\AppData\Local\Android\Sdk\emulator
.\emulator.exe -list-avds
# Resultado exemplo: Pixel_6_API_33
.\emulator.exe -avd Pixel_6_API_33
```

**3. Depois que o emulador abrir, rode o app Flutter:**
```powershell
# Em outra janela do PowerShell, na pasta do projeto:
cd "c:\Users\user\Desktop\Faculdade\Dispositivos Moveis\MoveBem\flutter_movebem"
flutter run
```

**Atalho rápido (adicione ao PATH):**
Se quiser rodar `emulator` de qualquer lugar, adicione ao PATH do Windows:
- `C:\Users\user\AppData\Local\Android\Sdk\emulator`
- `C:\Users\user\AppData\Local\Android\Sdk\platform-tools`

Depois pode usar direto:
```powershell
emulator -list-avds
emulator -avd Pixel_6_API_33
```

## Observações importantes
- **Adicione a imagem do logo** em `assets/logo.png`. Se não adicionar, o Flutter dará erro ao carregar os assets. Alternativamente, você pode substituir o `Image.asset` no `lib/main.dart` por um texto de placeholder enquanto desenvolve.
- A barra de progresso é simulada com um `Timer` (para demonstração). Substitua essa lógica pelas suas tarefas reais de inicialização/carregamento e navegue para a próxima tela quando terminar.

## Próximos passos (posso fazer para você)
- Adicionar navegação automática para a tela inicial (home) quando o carregamento terminar
- Conectar com o backend PHP (fazer login automático, buscar dados, etc.)
- Criar as outras telas do app (login, home, exercícios, etc.)
- Configurar o projeto completo para Android/iOS
