# RESTful Booker · Automação de testes de API

![Python 3.12](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Robot Framework](https://img.shields.io/badge/Robot_Framework-7.5-00C0B5?logo=robotframework&logoColor=white)
![RequestsLibrary](https://img.shields.io/badge/RequestsLibrary-0.9.7-005571)
[![API tests](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml/badge.svg?branch=main)](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml)

Projeto pessoal de qualidade de software para automatizar verificações da API REST de reservas **RESTful Booker**. O objetivo é construir uma suíte legível, reproduzível e integrada ao GitHub Actions, com evidências que permitam investigar cada execução.

- **Site base:** [https://restful-booker.herokuapp.com/](https://restful-booker.herokuapp.com/)
- **API Docs:** [https://restful-booker.herokuapp.com/apidoc/index.html](https://restful-booker.herokuapp.com/apidoc/index.html)
- **Repositório:** [robotframework-api-testing](https://github.com/deborahmancilha/robotframework-api-testing)

> **Etapa atual:** automação das oito operações documentadas, com testes positivos, negativos, limites e Basic Auth. A etapa mais recente separa explicitamente os **testes de contrato**, que verificam as expectativas de validação, dos **testes de caracterização**, que registram comportamentos observados, incluindo erros internos HTTP 500. O projeto está publicado no GitHub e utiliza GitHub Actions para executar a suíte e disponibilizar os relatórios como artefatos.

## O que este projeto demonstra

- Validação do status HTTP do endpoint de health check.
- Validação da criação de token de autenticação e do formato da resposta JSON.
- Organização de testes e recursos reutilizáveis com Robot Framework.
- Isolamento de dependências em ambiente virtual e versões fixadas.
- Configuração de integração contínua com preservação dos relatórios, inclusive em falhas.
- Documentação das decisões, da cobertura real e dos próximos passos.

## Tecnologias

| Ferramenta | Papel no projeto |
| --- | --- |
| Python 3.12 | Runtime e ambiente virtual |
| Robot Framework 7.5 | Execução, assertions e relatórios |
| RequestsLibrary 0.9.7 | Requisições HTTP |
| VS Code + RobotCode | Edição e suporte a arquivos Robot |
| Git e GitHub | Versionamento e hospedagem do código |
| GitHub Actions | Execução automatizada e armazenamento de evidências |

As dependências diretas e transitivas estão fixadas em `requirements.txt`.

## Cobertura implementada

As oito suítes possuem **68 casos de teste**, organizados por operação. A numeração segue a ordem lógica abaixo; os testes mantêm dados próprios e não dependem dessa ordem de execução. Oito casos novos registram explicitamente erros internos observados na criação, separados das expectativas de validação de contrato.

| Suíte | CTs | Quantidade |
| --- | --- | --- |
| `health_check.robot` | CT01 | 1 |
| `create_token.robot` | CT02–CT06 | 5 |
| `get_booking_ids.robot` | CT07–CT15 | 9 |
| `get_booking.robot` | CT16–CT17 | 2 |
| `create_booking.robot` | CT18–CT44 | 27 |
| `update_booking.robot` | CT45–CT52 | 8 |
| `partial_update_booking.robot` | CT53–CT62 | 10 |
| `delete_booking.robot` | CT63–CT68 | 6 |

| Cenário | Endpoint | Verificações |
| --- | --- | --- |
| **CT01 - API deve estar disponível** | `GET /ping` | Valida a disponibilidade da API Restful Booker. |
| **CT02 - API deve criar um token com credenciais válidas** | `POST /auth` | Valida a criação de token com as credenciais públicas documentadas da API. |
| **CT03 - API deve negar token para usuário incorreto** | `POST /auth` | Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token. |
| **CT04 - API deve negar token para senha incorreta** | `POST /auth` | Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token. |
| **CT05 - API deve negar token sem o campo username** | `POST /auth` | Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token. |
| **CT06 - API deve negar token sem o campo password** | `POST /auth` | Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token. |
| **CT07 - API deve listar os IDs das reservas** | `GET /booking` | Valida status, formato JSON, tipo dos IDs e ausência de duplicatas. |
| **CT08 - API deve filtrar os IDs das reservas pelo primeiro nome** | `GET /booking` | Valida que o filtro firstname retorna as duas reservas próprias com o mesmo primeiro nome. |
| **CT09 - API deve filtrar os IDs das reservas pelo sobrenome** | `GET /booking` | Valida que o filtro lastname retorna as duas reservas próprias com o mesmo sobrenome. |
| **CT10 - API deve filtrar os IDs das reservas pelo nome e sobrenome** | `GET /booking` | Valida que ambos os filtros são aplicados, excluindo reservas que combinam apenas um dos campos. |
| **CT11 - API deve retornar uma lista vazia para um nome sem correspondência** | `GET /booking` | Valida uma busca válida sem resultados usando um nome único diferente das reservas criadas. |
| **CT12 - API deve filtrar reservas posteriores ao limite de checkin** | `GET /booking` | Verifica o contrato da API Docs: data maior ou igual ao filtro, isolando reservas com nome UUID. |
| **CT13 - API deve incluir reservas no limite do filtro checkin** | `GET /booking` | Verifica o contrato da API Docs: data maior ou igual ao filtro, isolando reservas com nome UUID. |
| **CT14 - API deve filtrar reservas posteriores ao limite de checkout** | `GET /booking` | Verifica o contrato da API Docs: data maior ou igual ao filtro, isolando reservas com nome UUID. |
| **CT15 - API deve incluir reservas no limite do filtro checkout** | `GET /booking` | Verifica o contrato da API Docs: data maior ou igual ao filtro, isolando reservas com nome UUID. |
| **CT16 - API deve consultar uma reserva existente pelo ID** | `GET /booking/{id}` | Valida status 200 e os dados completos de uma reserva própria consultada por ID. |
| **CT17 - API deve retornar não encontrado para uma reserva excluída** | `GET /booking/{id}` | Valida status 404 ao consultar o ID de uma reserva própria previamente excluída. |
| **CT18 - API deve criar uma reserva com dados válidos** | `POST /booking` | Valida status, ID, dados retornados e persistência de uma reserva completa. |
| **CT19 - API deve criar uma reserva com depósito não pago** | `POST /booking` | Valida que depositpaid false é preservado na criação e na consulta. |
| **CT20 - API deve preservar acentos e apóstrofo nos nomes da reserva** | `POST /booking` | Valida a preservação dos nomes com acentos e apóstrofo no retorno e na persistência. |
| **CT21 - API deve rejeitar criação sem o campo obrigatório firstname** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT22 - API deve rejeitar criação sem o campo obrigatório lastname** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT23 - API deve rejeitar criação sem o campo obrigatório totalprice** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT24 - API deve rejeitar criação sem o campo obrigatório depositpaid** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT25 - API deve rejeitar criação sem o campo obrigatório bookingdates.checkin** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT26 - API deve rejeitar criação sem o campo obrigatório bookingdates.checkout** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT27 - API deve rejeitar criação com primeiro nome numérico** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT28 - API deve rejeitar criação com preço não numérico** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT29 - API deve rejeitar criação com depósito como texto** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT30 - API deve rejeitar criação com datas como texto** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT31 - API deve rejeitar criação com nomes vazios** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT32 - API deve rejeitar criação com nomes com somente espaços** | `POST /booking` | Critério do projeto: erro controlado 400/422 sem criar reserva; a API Docs não especifica o código de validação. |
| **CT33 - API deve rejeitar criação com datas invertidas** | `POST /booking` | Hipótese de domínio: datas invertidas devem produzir erro controlado 400/422 sem criar reserva; a regra exige alinhamento de requisitos. |
| **CT34 - API deve criar uma reserva com preço zero** | `POST /booking` | Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado. |
| **CT35 - API deve preservar um preço inteiro elevado** | `POST /booking` | Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado. |
| **CT36 - API deve criar uma reserva com entrada e saída no mesmo dia** | `POST /booking` | Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado. |
| **CT37 - Caracterização - Criação sem firstname retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT38 - Caracterização - Criação sem lastname retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT39 - Caracterização - Criação sem totalprice retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT40 - Caracterização - Criação sem depositpaid retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT41 - Caracterização - Criação sem bookingdates.checkin retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT42 - Caracterização - Criação sem bookingdates.checkout retorna HTTP 500** | `POST /booking` | Registra o erro interno observado, sem criação de reserva; não comprova tratamento correto de validação. |
| **CT43 - Caracterização - Criação com firstname numérico retorna HTTP 500** | `POST /booking` | Registra o erro interno observado para firstname numérico, sem criação de reserva; não comprova validação correta. |
| **CT44 - Caracterização - Criação com bookingdates como texto retorna HTTP 500** | `POST /booking` | Registra o erro interno observado para bookingdates como texto, sem criação de reserva; não comprova validação correta. |
| **CT45 - API deve atualizar todos os campos de uma reserva com autenticação válida** | `PUT /booking/{id}` | Valida a substituição dos dados, incluindo depósito true para false, e persistência no mesmo ID. |
| **CT46 - API deve rejeitar a atualização de uma reserva sem autenticação** | `PUT /booking/{id}` | Valida status 403 e preservação dos dados originais após PUT sem credenciais. |
| **CT47 - API deve rejeitar a atualização de uma reserva com token inválido** | `PUT /booking/{id}` | Valida status 403 e preservação dos dados originais após PUT com token inválido. |
| **CT48 - API deve rejeitar atualização com JSON malformado** | `PUT /booking/{id}` | Valida HTTP 400 e reserva intacta após erro de sintaxe JSON. |
| **CT49 - API deve rejeitar atualização sem um campo obrigatório** | `PUT /booking/{id}` | Valida HTTP 400 e reserva intacta após omissão de firstname. |
| **CT50 - API deve rejeitar atualização de uma reserva inexistente** | `PUT /booking/{id}` | Caracteriza HTTP 405 no PUT de uma reserva própria previamente excluída. |
| **CT51 - API deve atualizar uma reserva com Basic Auth válida** | `PUT /booking/{id}` | Valida Basic Auth sem cookie de token. |
| **CT52 - API deve rejeitar a atualização de uma reserva com Basic Auth inválida** | `PUT /booking/{id}` | Valida HTTP 403 e dados preservados sem cookie de token. |
| **CT53 - API deve atualizar somente o nome e sobrenome da reserva** | `PATCH /booking/{id}` | Valida a alteração dos nomes, a preservação dos campos omitidos e a persistência no mesmo ID. |
| **CT54 - API deve atualizar somente o depósito da reserva para não pago** | `PATCH /booking/{id}` | Valida depositpaid false, a preservação dos campos omitidos e a persistência. |
| **CT55 - API deve rejeitar a atualização parcial sem autenticação** | `PATCH /booking/{id}` | Valida status 403 e dados originais preservados após PATCH sem credenciais. |
| **CT56 - API deve rejeitar a atualização parcial com token inválido** | `PATCH /booking/{id}` | Valida status 403 e dados originais preservados após PATCH com token inválido. |
| **CT57 - API deve atualizar somente o preço da reserva** | `PATCH /booking/{id}` | Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados. |
| **CT58 - API deve atualizar somente as necessidades adicionais da reserva** | `PATCH /booking/{id}` | Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados. |
| **CT59 - API deve atualizar somente as datas da reserva** | `PATCH /booking/{id}` | Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados. |
| **CT60 - API deve atualizar somente a data de entrada da reserva** | `PATCH /booking/{id}` | Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados. |
| **CT61 - API deve atualizar parcialmente uma reserva com Basic Auth válida** | `PATCH /booking/{id}` | Valida Basic Auth sem cookie de token. |
| **CT62 - API deve rejeitar a atualização parcial de uma reserva com Basic Auth inválida** | `PATCH /booking/{id}` | Valida HTTP 403 e dados preservados sem cookie de token. |
| **CT63 - API deve excluir uma reserva com autenticação válida** | `DELETE /booking/{id}` | Valida status 201 e confirma a exclusão com GET retornando 404. |
| **CT64 - API deve rejeitar a exclusão de uma reserva sem autenticação** | `DELETE /booking/{id}` | Valida status 403 e confirma que a reserva permanece existente e intacta. |
| **CT65 - API deve rejeitar a exclusão de uma reserva com token inválido** | `DELETE /booking/{id}` | Valida status 403 e confirma que a reserva permanece existente e intacta. |
| **CT66 - API deve rejeitar uma nova exclusão de uma reserva já excluída** | `DELETE /booking/{id}` | Valida status 405 para DELETE autenticado em ID próprio já excluído. |
| **CT67 - API deve excluir uma reserva com Basic Auth válida** | `DELETE /booking/{id}` | Valida Basic Auth sem cookie de token. |
| **CT68 - API deve rejeitar a exclusão de uma reserva com Basic Auth inválida** | `DELETE /booking/{id}` | Valida HTTP 403 e dados preservados sem cookie de token. |

### Critérios e dados de teste

- **CreateToken:** usa as credenciais públicas `admin` e `password123`. Credenciais incorretas ou incompletas retornam HTTP 200 com `reason: Bad credentials`, conforme a implementação; os cenários negativos também verificam ausência de `token`.
- **GetBookingIds:** filtros por nome, sobrenome, `checkin` e `checkout`. Os testes de data criam três reservas com datas antes, exatamente no limite e depois do filtro, isoladas por nome UUID. Os critérios de direção e igualdade seguem a API Docs, que descreve data maior ou igual ao filtro. Divergências entre documentação e serviço são falhas de contrato, não alterações das expectativas para aprovar a suíte.
- **GetBooking:** consulta uma reserva própria e verifica HTTP 404 após sua exclusão.
- **CreateBooking:** campos obrigatórios ausentes, tipos incompatíveis, nomes vazios/espaços e ordem das datas, além de cenários válidos com preço zero, preço inteiro elevado e estadia no mesmo dia. O valor `2147483647` é um ponto de referência de teste, não um máximo de negócio documentado. Rejeitar datas invertidas é uma expectativa de domínio adotada pelo projeto; os demais limites não documentados são descritos como caracterização do comportamento.
- **UpdateBooking:** atualização completa, JSON malformado, campo obrigatório ausente e reserva inexistente, com verificação de persistência ou preservação dos dados originais.
- **PartialUpdateBooking:** alterações de nomes, depósito, preço, necessidades adicionais e datas. Na alteração somente do check-in, o checkout deve ser preservado. O objeto esperado é uma cópia independente dos dados originais com somente as mudanças solicitadas.
- **Basic Auth:** cenários válidos e inválidos em PUT, PATCH e DELETE, usando sessões exclusivas sem cookie de token. A preparação e a limpeza continuam utilizando token próprio.

A documentação e a implementação de referência estão em [API Docs](https://restful-booker.herokuapp.com/apidoc/index.html) e [código-fonte oficial](https://github.com/mwinteringham/restful-booker). O serviço utiliza códigos específicos: 201 para DELETE bem-sucedido, 403 para autenticação rejeitada e 405 para PUT/DELETE em ID inexistente. O POST de criação responde 500 em cenários de campos obrigatórios ausentes e alguns tipos inválidos. Os CT37–CT44 verificam exatamente esse comportamento, mas **não representam um tratamento adequado de entrada inválida**. Os testes de contrato exigem 400 ou 422 como critério adotado pelo projeto, pois a API Docs não especifica o retorno desses erros; HTTP 500 não é mais aceito nessa validação. Os testes de contrato não presumem que tipos inválidos ou datas invertidas sejam válidos porque o serviço os aceitou.

### Caracterização e contrato

| Categoria | Pergunta respondida | Critério para entradas inválidas na criação |
| --- | --- | --- |
| `characterization` | A API mantém o comportamento observado? | HTTP 500 exato e nenhuma reserva criada |
| `contract` | A API atende à expectativa de validação do projeto? | HTTP 400 ou 422 e nenhuma reserva criada; HTTP 500 reprova |

A expectativa de 400/422 é uma decisão explícita deste projeto, não uma garantia da API Docs. Não se fixa arbitrariamente um único código não documentado. O mesmo dado de entrada pode aparecer em ambas as categorias porque as verificações têm objetivos diferentes. Aprovar uma caracterização confirma o comportamento atual, inclusive inadequado; não comprova que o serviço trata o erro corretamente. Se o servidor passar a responder 400/422, a caracterização falhará sinalizando uma mudança que deve ser investigada, enquanto o contrato poderá passar. As requisições e a limpeza permanecem nas keywords reutilizáveis de `booking.resource`.

| Entrada | CT de contrato | CT de caracterização |
| --- | --- | --- |
| Sem `firstname` | CT21 | CT37 |
| Sem `lastname` | CT22 | CT38 |
| Sem `totalprice` | CT23 | CT39 |
| Sem `depositpaid` | CT24 | CT40 |
| Sem `bookingdates.checkin` | CT25 | CT41 |
| Sem `bookingdates.checkout` | CT26 | CT42 |
| `firstname` numérico | CT27 | CT43 |
| `bookingdates` como texto | CT30 | CT44 |

Para executar somente as oito caracterizações de erro interno:

```powershell
.\.venv\Scripts\python.exe -m robot --include characterization --outputdir results/characterization tests/create_booking.robot
```

Para executar somente as expectativas de contrato da criação:

```powershell
.\.venv\Scripts\python.exe -m robot --include contract --outputdir results/contract tests/create_booking.robot
```

Nenhuma categoria é excluída automaticamente: a execução completa e o workflow continuam incluindo todos os casos. Para futuros cenários, a tag `characterization` deve registrar expectativas observadas específicas e a tag `contract` deve ter uma origem de requisito ou um critério de projeto documentado.

### Preparação e limpeza

Cada caso cria suas próprias reservas com nomes únicos, registra os IDs e exclui somente esses registros no teardown, mesmo após falhas de validação. Na criação, registramos o ID antes das assertions. Se a resposta não trouxer um ID utilizável, a limpeza tenta localizar exclusivamente o nome UUID do payload, inclusive após respostas de erro. Não são excluídas reservas públicas genéricas. Uma exclusão concluída remove o ID da lista de limpeza; falhas de limpeza reprovam o caso e as sessões são encerradas em `FINALLY`.

A API é pública e compartilhada; reinicializações ou alterações de terceiros durante o caso podem causar falhas. XML, formulários, desempenho, expiração de tokens e combinações exaustivas de campos continuam fora da cobertura atual.

### Divergências observadas na ampliação

A última execução local, registrada em `results/output.xml`, executou **68 casos: 52 aprovados, 16 reprovados e nenhum ignorado**, sem falhas de teardown. As **oito caracterizações CT37–CT44 passaram**. Os oito contratos correspondentes agora falham diante de HTTP 500, além das oito divergências já identificadas. A separação evidencia erros internos que antes eram aceitos pela assertion genérica; a aprovação da caracterização não elimina a falha de contrato.

Os casos abaixo possuem a tag `known_bug` para facilitar sua investigação. Essa tag **não ignora os testes nem transforma falhas em sucesso**. A suíte completa e o workflow continuam executando esses cenários; enquanto as divergências persistirem, o resultado será reprovado. O badge representa o commit publicado no GitHub, não as alterações ainda locais.

| CTs | Expectativa | Comportamento observado |
| --- | --- | --- |
| CT13 | `checkin` igual ao filtro deve ser incluído, conforme a API Docs | A reserva exatamente no limite é omitida |
| CT14 | `checkout` posterior ao filtro deve ser incluído, conforme a API Docs | A consulta retorna reservas anteriores/no limite e omite a posterior |
| CT21–CT27 e CT30 | Erro de validação controlado (400/422, critério do projeto) | O serviço responde HTTP 500; as caracterizações correspondentes registram esse retorno |
| CT28–CT29 | Tipos incompatíveis de preço e depósito devem ser rejeitados | POST aceita preço não numérico e depósito como texto com HTTP 200 |
| CT31–CT32 | Nomes vazios ou com somente espaços devem ser rejeitados | POST aceita as entradas com HTTP 200 |
| CT33 | Entrada posterior à saída deve ser rejeitada segundo a expectativa de domínio do projeto | POST aceita as datas invertidas; essa regra não é explicitada na API Docs e requer alinhamento de requisitos |
| CT60 | PATCH apenas do check-in deve preservar o checkout | O checkout retorna como `0NaN-aN-aN` |

Para investigar somente esses cenários:

```powershell
.\.venv\Scripts\python.exe -m robot --include known_bug --outputdir results/known-bugs tests
```

## Executar no Windows

Pré-requisitos: Python 3.12, Git e acesso à internet. VS Code e RobotCode são recomendados para edição.

Na raiz do projeto, pelo PowerShell:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m robot --outputdir results tests
```

Se o comando `py` não for encontrado, abra um novo terminal após instalar Python. Como alternativa, use o caminho do interpretador instalado:

```powershell
& "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe" -m venv .venv
```

Os comandos usam diretamente o Python do ambiente virtual; não é necessário ativá-lo nem alterar a política de execução do PowerShell.

### VS Code

```powershell
code .
```

Instale as extensões recomendadas em `.vscode/extensions.json`. Em **Python: Select Interpreter**, selecione `.venv\Scripts\python.exe`. O projeto também inclui esse caminho como interpretador padrão nas configurações locais do workspace.

### Executar apenas smoke ou alterar a URL

```powershell
.\.venv\Scripts\python.exe -m robot --include smoke --outputdir results tests
.\.venv\Scripts\python.exe -m robot --variable BASE_URL:https://restful-booker.herokuapp.com --outputdir results tests
```

Em Linux/macOS, crie o ambiente com `python3.12 -m venv .venv` e use `.venv/bin/python` nos comandos seguintes.

## Evidências da execução

Após executar a suíte, a pasta `results/` contém:

| Arquivo | Como utilizar |
| --- | --- |
| `report.html` | Consultar o resumo e o resultado dos testes |
| `log.html` | Investigar requisições, assertions e falhas |
| `output.xml` | Processar resultados com ferramentas de automação |

Abra `results/report.html` no navegador. Relatórios e ambiente virtual são ignorados pelo Git.

## Integração contínua

O workflow `.github/workflows/api-tests.yml` executa a suíte em pushes, pull requests e acionamento manual. Ele configura Python 3.12, instala as dependências e publica `robot-reports` com retenção de 14 dias, mesmo quando os testes falham. Uma falha da suíte reprova o job.

A integração contínua foi validada com sucesso no runner do GitHub, incluindo instalação das dependências, execução dos testes e publicação dos relatórios. Veja a [execução do commit que adicionou DeleteBooking](https://github.com/deborahmancilha/robotframework-api-testing/actions/runs/38282528654).

Para consultar os resultados, abra [Actions → API tests](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml), selecione uma execução e baixe o artefato `robot-reports`. Extraia o arquivo e abra `report.html` para o resumo ou `log.html` para os detalhes. O badge no início deste README mostra o resultado do workflow na branch `main` e leva ao histórico de execuções.

## Estrutura

```text
Projeto_outubro/
├── .github/
│   └── workflows/
│       └── api-tests.yml
├── .vscode/
│   ├── extensions.json
│   └── settings.json
├── resources/
│   ├── auth.resource
│   ├── booking.resource
│   ├── common.resource
│   └── health.resource
├── tests/
│   ├── create_booking.robot
│   ├── create_token.robot
│   ├── delete_booking.robot
│   ├── get_booking.robot
│   ├── get_booking_ids.robot
│   ├── health_check.robot
│   ├── partial_update_booking.robot
│   └── update_booking.robot
├── results/
├── .gitignore
├── README.md
└── requirements.txt
```

`common.resource` centraliza a conexão HTTP, a preparação da resposta e a validação de status. `health.resource` reúne a requisição de health check; `auth.resource` reúne a preparação das credenciais, a requisição de autenticação e a validação do token. A pasta `.venv/` também existe localmente. Ela e `results/` ficam no `.gitignore` e não são versionadas; os resultados são gerados durante a execução.

## Convenção de nomes das suítes

Os arquivos de teste seguem o nome das operações documentadas na API Docs, convertido para `snake_case`. Os cenários de cada operação ficam na mesma suíte, diretamente na pasta `tests/`.

| Operação na API Docs | Arquivo de teste | Situação |
| --- | --- | --- |
| HealthCheck | `tests/health_check.robot` | Implementado |
| CreateToken | `tests/create_token.robot` | Implementado |
| GetBookingIds | `tests/get_booking_ids.robot` | Implementado |
| GetBooking | `tests/get_booking.robot` | Implementado |
| CreateBooking | `tests/create_booking.robot` | Implementado |
| UpdateBooking | `tests/update_booking.robot` | Implementado |
| PartialUpdateBooking | `tests/partial_update_booking.robot` | Implementado |
| DeleteBooking | `tests/delete_booking.robot` | Implementado |

As oito operações possuem suítes implementadas. Os recursos agrupam keywords por funcionalidade, com configuração compartilhada em `common.resource`; a cobertura de cenários pode ser ampliada dentro de cada suíte.

A separação segue a ideia de encapsular ações e detalhes técnicos usada no Page Object Model (POM). Para esta API, a camada de recursos representa operações de serviço: `tests/get_booking_ids.robot` descreve os cenários BDD, `booking.resource` implementa requisições, validações e dados de teste, e `common.resource` centraliza conexão e status. Não existem páginas ou seletores de interface nesta automação.

Para executar somente a operação GetBookingIds:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/get_booking_ids.robot
```

Para executar somente a operação CreateBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/create_booking.robot
```

Para executar somente a operação GetBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/get_booking.robot
```

Para executar somente a operação UpdateBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/update_booking.robot
```

UpdateBooking envia o corpo completo por PUT, com cenários positivos, entradas inválidas, ID inexistente e autenticação por token ou Basic Auth. Os detalhes de cobertura estão na tabela de cenários.

PartialUpdateBooking envia apenas as mudanças por PATCH. Os cenários verificam também os campos omitidos e a persistência, com autenticação por token e Basic Auth. A API Docs mostra PUT em alguns exemplos, mas a operação utiliza PATCH.

Para executar somente a operação PartialUpdateBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/partial_update_booking.robot
```

DeleteBooking confirma a exclusão com uma consulta posterior e verifica a preservação das reservas em tentativas não autorizadas, por token ou Basic Auth. O status 405 na segunda exclusão é específico desta API.

Para executar somente a operação DeleteBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/delete_booking.robot
```

Os CTs seguem a ordem lógica HealthCheck → CreateToken → GetBookingIds → GetBooking → CreateBooking → UpdateBooking → PartialUpdateBooking → DeleteBooking. A descoberta padrão do Robot Framework segue os nomes dos arquivos; a numeração não impõe ordem de execução. Cada caso prepara seus próprios dados e pode ser executado independentemente.

## Escrita dos cenários em BDD

Os casos usam o padrão Given/When/Then em português dentro de arquivos `.robot`. A declaração `Language: pt` habilita os prefixos `Dado`, `Quando`, `Então` e `E` no Robot Framework.

```robotframework
CT01 - API deve estar disponível
    [Documentation]    Valida a disponibilidade da API Restful Booker.
    [Tags]    smoke    health

    Dado que possuo acesso à API Restful Booker
    Quando eu enviar uma requisição para o endpoint de health check
    Então a API deve retornar o status    201
```

Para executar apenas o health check:

```powershell
.\.venv\Scripts\python.exe -m robot --include health --outputdir results tests
```

Para executar apenas os testes com a tag `smoke`:

```powershell
.\.venv\Scripts\python.exe -m robot --include smoke --outputdir results tests
```

Para executar todos os testes:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests
```

## Decisões de teste

- **Sessão reutilizável:** configuração centralizada da URL e do timeout de 30 segundos.
- **TLS verificado:** as requisições mantêm a validação de certificados habilitada.
- **Status explícitos:** o passo `Então` declara e valida o código esperado; `/ping` utiliza 201 conforme a API.
- **Dados compartilhados:** os filtros de reservas usam dados próprios com nomes únicos e limpeza no teardown, evitando depender dos registros públicos existentes.
- **Falhas visíveis:** não há repetição automática para transformar falhas em sucesso. Indisponibilidade da API pública deve ser investigada pelos relatórios.

## Referências

- [API RESTful Booker](https://restful-booker.herokuapp.com/)
- [Documentação dos endpoints](https://restful-booker.herokuapp.com/apidoc/index.html)
- [Robot Framework — guia oficial](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [RequestsLibrary — repositório oficial](https://github.com/MarketSquare/robotframework-requests)
- [GitHub Actions — projetos Python](https://docs.github.com/en/actions/tutorials/build-and-test-code/python)
- [Python 3.12.10 — instalador utilizado no Windows](https://www.python.org/downloads/release/python-31210/)

---

Este portfólio evolui com a implementação: a cobertura e as evidências descritas aqui acompanham o que foi efetivamente executado.
