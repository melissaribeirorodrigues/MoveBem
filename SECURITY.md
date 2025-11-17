# Segurança de senhas — MoveBem

Aviso rápido
-----------
Este repositório atualmente tem o cliente (aplicativo Flutter) calculando um hash MD5 da senha antes de enviá-la ao backend. O backend aplica `password_hash` (PHP) ao valor recebido e usa `password_verify` no login.

Por que isto é um problema
-------------------------
- MD5 é considerado inseguro para armazenamento de senhas. É vulnerável a ataques de força bruta e tabelas rainbow.
- Se alguém interceptar o valor MD5 enviado (por exemplo, num canal HTTP não seguro), esse valor pode ser usado como credencial (replay), porque o servidor trata o MD5 como se fosse a "senha" enviada.
- Hashing no cliente (client-side hashing) não substitui o uso de TLS/HTTPS para proteger credenciais em trânsito.

Recomendações
-------------
1. Melhor solução (recomendada):
   - Remover o hash no cliente. Enviar a senha em texto apenas sobre HTTPS.
   - No servidor, usar `password_hash` com um algoritmo forte (PASSWORD_DEFAULT normalmente usa bcrypt; prefira `PASSWORD_ARGON2ID` se disponível) e `password_verify` para autenticação.
   - Isso resulta em: servidor armazena `password_hash(senha)` e o cliente não faz hashing.

2. Migração para Argon2 (servidor):
   - Atualize o código PHP para usar `PASSWORD_ARGON2ID` quando disponível.
   - Durante login, chame `password_needs_rehash` e re-hash a senha com o novo algoritmo quando necessário.

3. Se for necessário manter hashing no cliente por compatibilidade:
   - Prefira SHA‑256 (ou um HMAC com chave por sessão) sobre MD5.
   - Garanta que todo tráfego use HTTPS.
   - Adicione proteção contra replay (tokens, nonces, limites de tempo).
   - Documente claramente que o servidor está armazenando `password_hash(client_hash)`.

Passos práticos para migrar (exemplo)
-------------------------------------
- No cliente (Flutter): remova o uso de `md5`/`sha256` e envie a senha em texto para o endpoint de cadastro/login.
- No servidor (PHP):
  - Continue usando `password_hash($senha, PASSWORD_DEFAULT)` ao cadastrar.
  - No `LoginComEmailSenha`, use `password_verify($senha, $hash)`.
  - Para migrar hashes existentes que armazenam `password_hash(MD5(senha))`, você pode aceitar temporariamente ambos os formatos no login:
    - Tente `password_verify($senha, $hash)` (caso antigo em que o cliente enviou o MD5, envie MD5 do cliente no login). Em seguida, ao logar com sucesso, re-hasheie usando `password_hash($rawSenha, PASSWORD_ARGON2ID)` e atualize o banco.

Contato / Observações
---------------------
Se quiser, eu posso:
- Reverter o cliente para enviar a senha em texto (opção recomendada). Eu faço a mudança no Flutter e atualizo comentários.
- Atualizar o backend para usar Argon2 e adicionar re-hash automático durante o login.
- Fornecer um plano de migração detalhado para dados já armazenados.

Obrigado por cuidar da segurança — se quiser que eu execute a migração recomendada, diga qual opção prefere.