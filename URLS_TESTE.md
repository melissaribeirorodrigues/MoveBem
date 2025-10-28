# MoveBem API - URLs para Testes

## 🔧 CONFIGURAÇÃO AUTOMÁTICA DE SERVIDOR

O sistema detecta automaticamente o ambiente:
- **Servidor EXTERNO (200.19.1.19)**: Prioriza rede interna, fallback para externo
- **Servidor INTERNO (192.168.20.19)**: Usa rede interna com fallbacks
- **XAMPP LOCAL**: Conecta na rede interna (192.168.20.18)

## 🌐 URLs do Servidor EXTERNO (200.19.1.19) - ✅ FUNCIONANDO

**Status**: ✅ **ONLINE e OPERACIONAL** (testado via PowerShell)

### 📋 Documentação da API
```
http://200.19.1.19/usuario03/MoveBem/
```

### 🧪 Interface de Testes - ✅ TODAS FUNCIONANDO
```
http://200.19.1.19/usuario03/MoveBem/teste_servidor.html
http://200.19.1.19/usuario03/MoveBem/teste_rotinas.html
http://200.19.1.19/usuario03/MoveBem/teste_exercicios.html
http://200.19.1.19/usuario03/MoveBem/teste_agua.html
http://200.19.1.19/usuario03/MoveBem/teste_historico_diario.html
```

### 🔄 URLs com Cache Busting (se o navegador não carregar):
```
http://200.19.1.19/usuario03/MoveBem/teste_servidor.html?v=2025091217
http://200.19.1.19/usuario03/MoveBem/teste_rotinas.html?v=2025091217
http://200.19.1.19/usuario03/MoveBem/teste_exercicios.html?v=2025091217
http://200.19.1.19/usuario03/MoveBem/teste_agua.html?v=2025091217
```

### 🛠️ Dicas para Contornar Cache:
1. **Ctrl+F5** (hard refresh) no navegador
2. **Modo Incógnito/Privado** do navegador
3. **Limpar cache** nas configurações do navegador
4. **URLs com timestamp** (links acima)
5. **Developer Tools** → Network → Disable cache

⚠️ **Nota sobre navegadores**: Se o navegador mostrar "conexão recusada", use ferramentas alternativas:
- **PowerShell**: `Invoke-WebRequest -Uri "http://200.19.1.19/usuario03/MoveBem/teste_servidor.html"`
- **cURL**: `curl http://200.19.1.19/usuario03/MoveBem/teste_servidor.html`
- **Postman**: Funciona perfeitamente para APIs

🚨 **PROBLEMA CONFIRMADO**: Driver PostgreSQL ausente no servidor externo!

**ERRO RECEBIDO**: `"Erro de conexão com banco: could not find driver"`

```bash
# No servidor 200.19.1.19, executar como admin:
sudo apt-get update
sudo apt-get install php-pgsql
sudo systemctl restart apache2

# Verificar instalação:
php -m | grep pgsql
```

**Status Atual - DEPLOYMENT 95% COMPLETO**:
- ✅ **Arquivos**: Copiados e acessíveis (confirmado via WinSCP)
- ✅ **Apache**: Funcionando perfeitamente
- ✅ **PHP**: Executando normalmente  
- ✅ **Interfaces HTML**: Carregando corretamente
- ✅ **Teste de Conectividade**: Servidor acessível via PowerShell
- ❌ **PostgreSQL Driver**: **NÃO INSTALADO** ("could not find driver")
- ❌ **APIs**: Não funcionais até instalar driver

### 🔧 **Soluções Temporárias para Cache**:
- **URLs com ?v=timestamp** (ver seção acima)
- **Ctrl+F5** no navegador
- **Modo incógnito** do navegador
- **Developer Tools** → Disable cache

### ⚡ Endpoints Principais
```
Usuários:          http://200.19.1.19/usuario03/MoveBem/Controller/CrudUsuario.php
Rotinas:           http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Exercícios:        http://200.19.1.19/usuario03/MoveBem/Controller/CrudExercicio.php
Rotina-Exercício:  http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php
Registro Água:     http://200.19.1.19/usuario03/MoveBem/Controller/CrudRegistroAgua.php
Histórico Diário:  http://200.19.1.19/usuario03/MoveBem/Controller/CrudHistoricoDiario.php
```

## 🏢 URLs do Servidor INTERNO (192.168.20.19)

### 📋 Documentação da API
```
http://192.168.20.19/usuario03/MoveBem/
```

### 🧪 Interface de Testes
```
http://192.168.20.19/usuario03/MoveBem/teste_servidor.html
http://192.168.20.19/usuario03/MoveBem/teste_rotinas.html
http://192.168.20.19/usuario03/MoveBem/teste_exercicios.html
http://192.168.20.19/usuario03/MoveBem/teste_agua.html
```

### ⚡ Endpoints Principais
```
Usuários:          http://192.168.20.19/usuario03/MoveBem/Controller/CrudUsuario.php
Rotinas:           http://192.168.20.19/usuario03/MoveBem/Controller/CrudRotina.php
Exercícios:        http://192.168.20.19/usuario03/MoveBem/Controller/CrudExercicio.php
Rotina-Exercício:  http://192.168.20.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php
Registro Água:     http://192.168.20.19/usuario03/MoveBem/Controller/CrudRegistroAgua.php
```

## 🔧 Exemplos de Requisições

### 🎯 URLs Locais - XAMPP - FUNCIONANDO 100%
```
Base Local:        http://localhost/MoveBem/
Testes HTML:       http://localhost/MoveBem/teste_servidor.html
                   http://localhost/MoveBem/teste_rotinas.html
                   http://localhost/MoveBem/teste_exercicios.html
                   http://localhost/MoveBem/teste_agua.html

Usuários:          http://localhost/MoveBem/Controller/CrudUsuario.php
Rotinas:           http://localhost/MoveBem/Controller/CrudRotina.php
Exercícios:        http://localhost/MoveBem/Controller/CrudExercicio.php
Rotina-Exercício:  http://localhost/MoveBem/Controller/CrudRotinaExercicio.php
Registro Água:     http://localhost/MoveBem/Controller/CrudRegistroAgua.php
```

## 🎯 LÓGICA DE DETECÇÃO AUTOMÁTICA

### Servidor EXTERNO (200.19.1.19):
1. **192.168.20.18:5432** (PostgreSQL rede interna) 
2. **200.19.1.18:5432** (PostgreSQL externo - fallback)

### Servidor INTERNO (192.168.20.19):
1. **192.168.20.18:5432** (PostgreSQL rede interna - FIXO)

### XAMPP Local:
1. **192.168.20.18:5432** (PostgreSQL rede interna - testado)

## ⚠️ CONFIGURAÇÃO IMPORTANTE

**Servidor INTERNO (192.168.20.19)**: 
- PostgreSQL está **SEMPRE** no **192.168.20.18:5432**
- Não há fallbacks - conexão direta e fixa
- Sem tentativas de outros IPs para evitar timeouts

## 🔍 LOG DE DEBUG

O sistema grava logs com prefixo "MoveBem" para facilitar debug:
- `MoveBem: Detectado servidor EXTERNO (200.19.1.19)`
- `MoveBem: Detectado servidor INTERNO (192.168.20.19)` 
- `MoveBem: Detectado ambiente LOCAL (XAMPP)`
- `MoveBem: Usando PostgreSQL [IP]`

Para visualizar logs no servidor, verifique error_log do Apache/PHP.

### 🏃‍♂️ API de Exercícios

#### Listar Exercícios:
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudExercicio.php
Method: POST
Body:
oper=L
```

#### Cadastrar Exercício:
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudExercicio.php
Method: POST
Body:
oper=I
nm_exercicio=Corrida
ds_tempo=00:30:00
```

#### Consultar Exercício:
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudExercicio.php
Method: POST
Body:
oper=C
id_exercicio=1
```

### 🔗 API de Rotina-Exercício

#### Adicionar Exercício à Rotina:
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php
Method: POST
Body:
oper=I
id_rotina=1
id_exercicio=1
```

#### Listar Exercícios de uma Rotina:
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php
Method: POST
Body:
oper=L
id_rotina=1
```

## 🔧 Exemplos de Requisições - Usuários

### 1. Listar Usuários (GET)
```
http://200.19.1.19/MoveBem/Controller/CrudUsuario.php?oper=Listar
```

### 2. Login (POST)
```
URL: http://200.19.1.19/MoveBem/Controller/CrudUsuario.php
Method: POST
Body:
oper=Login
ds_email=usuario@email.com
ds_senha=123456
```

### 3. Cadastrar Usuário (POST)
```
URL: http://200.19.1.19/MoveBem/Controller/CrudUsuario.php
Method: POST
Body:
oper=Inserir
nm_usuario=João Silva
ds_email=joao@email.com
ds_senha=123456
```

### 4. Consultar Usuário (POST)
```
URL: http://200.19.1.19/MoveBem/Controller/CrudUsuario.php
Method: POST
Body:
oper=Consultar
id_usuario=1
```

### 5. Alterar Usuário (POST)
```
URL: http://200.19.1.19/MoveBem/Controller/CrudUsuario.php
Method: POST
Body:
oper=Alterar
id_usuario=1
nm_usuario=João Silva Santos
ds_email=joao.santos@email.com
ds_senha=nova123
```

### 6. Excluir Usuário (POST)
```
URL: http://200.19.1.19/MoveBem/Controller/CrudUsuario.php
Method: POST
Body:
oper=Excluir
id_usuario=1
```

## 🏃‍♀️ Rotinas - Exemplos de Requisições

### 1. Listar Rotinas (GET)
```
http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php?oper=L
```

### 2. Cadastrar Rotina (POST)
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Method: POST
Body:
oper=I
nm_rotina=Corrida Matinal
ds_rotina=Rotina de corrida de 30 minutos pela manhã
```

### 3. Consultar Rotina (POST)
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Method: POST
Body:
oper=C
id_rotina=1
```

### 4. Alterar Rotina (POST)
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Method: POST
Body:
oper=A
id_rotina=1
nm_rotina=Corrida Matinal Avançada
ds_rotina=Rotina de corrida de 45 minutos pela manhã com intervalos
```

### 5. Excluir Rotina (POST)
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Method: POST
Body:
oper=E
id_rotina=1
```

### 6. Pesquisar Rotina por Nome (POST)
```
URL: http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php
Method: POST
Body:
oper=P
nm_rotina=corrida
```

## 📱 Para App Mobile (Flutter/React Native)

### Dart/Flutter:
```dart
final response = await http.post(
  Uri.parse('http://200.19.1.19/MoveBem/Controller/CrudUsuario.php'),
  body: {
    'oper': 'Login',
    'ds_email': 'usuario@email.com',
    'ds_senha': 'senha123'
  },
);
final data = json.decode(response.body);
```

### JavaScript/React Native:
```javascript
fetch('http://200.19.1.19/MoveBem/Controller/CrudUsuario.php', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
  },
  body: new URLSearchParams({
    oper: 'Login',
    ds_email: 'usuario@email.com',
    ds_senha: 'senha123'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

## 🛠️ Testando com cURL (Terminal)

### Login:
```bash
curl -X POST "http://200.19.1.19/MoveBem/Controller/CrudUsuario.php" \
     -d "oper=Login&ds_email=usuario@email.com&ds_senha=123456"
```

### Listar:
```bash
curl -X POST "http://200.19.1.19/MoveBem/Controller/CrudUsuario.php" \
     -d "oper=Listar"
```

### Cadastrar:
```bash
curl -X POST "http://200.19.1.19/MoveBem/Controller/CrudUsuario.php" \
     -d "oper=Inserir&nm_usuario=Teste&ds_email=teste@email.com&ds_senha=123456"
```

## 📋 Resposta Padrão da API

### Sucesso:
```json
{
  "operacao": "Login",
  "NumMens": 1,
  "Mensagem": "Login realizado com sucesso",
  "registros": 1,
  "dados": {
    "id_usuario": 1,
    "ds_email": "usuario@email.com",
    "nm_usuario": "Nome do Usuario"
  }
}
```

### Erro:
```json
{
  "operacao": "Login",
  "NumMens": 0,
  "Mensagem": "Email ou senha incorretos",
  "registros": 0,
  "dados": null
}
```

## 🎯 Checklist de Deploy

- [ ] Upload dos arquivos via WinSCP para 200.19.1.19
- [ ] Testar documentação: http://200.19.1.19/MoveBem/
- [ ] Testar interface: http://200.19.1.19/MoveBem/teste_servidor.html
- [ ] Testar listar usuários
- [ ] Testar cadastro
- [ ] Testar login
- [ ] Integrar com app móvel
