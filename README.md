# RESTful Booker · Automação de testes de API

![Python 3.12](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Robot Framework](https://img.shields.io/badge/Robot_Framework-7.5-00C0B5?logo=robotframework&logoColor=white)
![RequestsLibrary](https://img.shields.io/badge/RequestsLibrary-0.9.7-005571)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)

Projeto pessoal de qualidade de software para automatizar verificações da API REST de reservas **RESTful Booker**. O objetivo é construir uma suíte legível, reproduzível e integrada ao GitHub Actions, com evidências que permitam investigar cada execução.

- **Site base:** [https://restful-booker.herokuapp.com/](https://restful-booker.herokuapp.com/)
- **API Docs:** [https://restful-booker.herokuapp.com/apidoc/index.html](https://restful-booker.herokuapp.com/apidoc/index.html)

> **Etapa atual:** base publicada no GitHub, com cenários de health check, criação de token, consulta, criação, atualização completa e parcial e exclusão de reservas implementados. O workflow está configurado para executar a suíte e preservar os relatórios.

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

| Cenário | Endpoint | Verificações |
| --- | --- | --- |
| **CT01 - API deve estar disponível** | `GET /ping` | HTTP 201 |
| **CT02 - API deve criar um token com credenciais válidas** | `POST /auth` | HTTP 200, conteúdo JSON e campo `token` como string não vazia |
| **CT03 - API deve listar os IDs das reservas** | `GET /booking` | HTTP 200, lista JSON, IDs inteiros e sem duplicatas |
| **CT04 - API deve filtrar os IDs das reservas pelo primeiro nome** | `GET /booking?firstname=...` | HTTP 200 e somente os dois IDs esperados |
| **CT05 - API deve filtrar os IDs das reservas pelo sobrenome** | `GET /booking?lastname=...` | HTTP 200 e somente os dois IDs esperados |
| **CT06 - API deve filtrar os IDs das reservas pelo nome e sobrenome** | `GET /booking?firstname=...&lastname=...` | HTTP 200 e somente o ID que combina ambos os campos |
| **CT07 - API deve retornar uma lista vazia para um nome sem correspondência** | `GET /booking?firstname=...` | HTTP 200 e lista JSON vazia |
| **CT08 - API deve consultar uma reserva existente pelo ID** | `GET /booking/{id}` | HTTP 200, JSON e dados iguais aos cadastrados |
| **CT09 - API deve retornar não encontrado para uma reserva excluída** | `GET /booking/{id}` | HTTP 404 após excluir a reserva própria |
| **CT10 - API deve criar uma reserva com dados válidos** | `POST /booking` | HTTP 200, ID inteiro, dados retornados e persistidos iguais aos enviados |
| **CT11 - API deve criar uma reserva com depósito não pago** | `POST /booking` | Preservação de `depositpaid=false` na criação e consulta |
| **CT12 - API deve preservar acentos e apóstrofo nos nomes da reserva** | `POST /booking` | Preservação dos nomes na criação e consulta |
| **CT13 - API deve atualizar todos os campos de uma reserva com autenticação válida** | `PUT /booking/{id}` | HTTP 200, dados atualizados e persistência no mesmo ID |
| **CT14 - API deve rejeitar a atualização de uma reserva sem autenticação** | `PUT /booking/{id}` | HTTP 403 e dados originais preservados |
| **CT15 - API deve rejeitar a atualização de uma reserva com token inválido** | `PUT /booking/{id}` | HTTP 403 e dados originais preservados |
| **CT16 - API deve atualizar somente o nome e sobrenome da reserva** | `PATCH /booking/{id}` | HTTP 200, nomes alterados, demais campos preservados e persistência |
| **CT17 - API deve atualizar somente o depósito da reserva para não pago** | `PATCH /booking/{id}` | HTTP 200, depósito false, demais campos preservados e persistência |
| **CT18 - API deve rejeitar a atualização parcial sem autenticação** | `PATCH /booking/{id}` | HTTP 403 e dados originais preservados |
| **CT19 - API deve rejeitar a atualização parcial com token inválido** | `PATCH /booking/{id}` | HTTP 403 e dados originais preservados |
| **CT20 - API deve excluir uma reserva com autenticação válida** | `DELETE /booking/{id}` | HTTP 201 e GET posterior com HTTP 404 |
| **CT21 - API deve rejeitar a exclusão de uma reserva sem autenticação** | `DELETE /booking/{id}` | HTTP 403 e reserva intacta |
| **CT22 - API deve rejeitar a exclusão de uma reserva com token inválido** | `DELETE /booking/{id}` | HTTP 403 e reserva intacta |
| **CT23 - API deve rejeitar uma nova exclusão de uma reserva já excluída** | `DELETE /booking/{id}` | HTTP 405 e GET posterior com HTTP 404 |

O cenário CreateToken usa as credenciais públicas de demonstração presentes na API Docs: `admin` e `password123`. O corpo é enviado em JSON com `username` e `password`; a RequestsLibrary define o `Content-Type` ao utilizar o argumento `json`. O teste verifica a criação do token; seu uso em operações protegidas será validado nos cenários dessas operações.

GetBookingIds utiliza o contrato da [API Docs — GetBookingIds](https://restful-booker.herokuapp.com/apidoc/index.html#api-Booking-GetBookings): status 200 e lista de objetos com IDs únicos. A validação de inteiro segue o formato dos identificadores da API, sendo mais restrita que o tipo `number` documentado. A listagem sem filtros aceita uma lista vazia e não exige quantidade nem ordem fixas.

Os cenários com filtros criam três reservas com nomes únicos gerados por UUID: duas compartilham o primeiro nome e duas compartilham o sobrenome. A combinação de nome e sobrenome identifica somente uma delas, permitindo detectar filtros ignorados. Cada caso mantém seus próprios IDs e token de limpeza; no teardown, exclui apenas suas reservas, tenta limpar as demais mesmo se uma exclusão falhar e encerra as sessões. Falhas na limpeza reprovam o caso. A criação e a exclusão são preparação e limpeza dos testes de consulta, não suítes completas dessas operações.

A API é pública e compartilhada; reinicializações ou alterações por terceiros durante um caso podem causar falhas. Filtros por `checkin` e `checkout`, também documentados, permanecem pendentes. Busca sem correspondência é um cenário válido com resultado vazio; não se presume erro HTTP para esse caso.

GetBooking consulta uma reserva própria pelo ID e compara o objeto JSON com os dados cadastrados. O cenário negativo exclui sua própria reserva antes da consulta, evitando presumir que um ID fixo não existe. O status 404 é comportamento da [implementação da API](https://github.com/mwinteringham/restful-booker/blob/master/routes/index.js), verificado na execução; a API Docs de GetBooking descreve o retorno de sucesso. A reserva excluída é removida da lista de limpeza para não tentar excluí-la novamente.

CreateBooking segue o [contrato documentado](https://restful-booker.herokuapp.com/apidoc/index.html#api-Booking-CreateBooking): envia `firstname`, `lastname`, `totalprice`, `depositpaid`, `bookingdates` e `additionalneeds` em JSON, solicitando retorno JSON pelo header `Accept`. O sucesso esperado é HTTP 200, com `bookingid` e `booking`. Os CT10–CT12 são cenários positivos; as variações de booleano e caracteres são escolhas de cobertura do projeto. Cada caso utiliza um nome único, compara os campos retornados com o payload e consulta `GET /booking/{id}` para verificar persistência. O POST não recebe token; a autenticação serve à limpeza por DELETE.

O ID é registrado antes das assertions de conteúdo para permitir exclusão mesmo quando uma validação posterior falha. Se a API criar a reserva sem retornar um ID utilizável, a limpeza por ID não poderá identificá-la. Campos ausentes, tipos inválidos, regras de datas e outros formatos de requisição ainda não estão cobertos; os códigos de erro não são presumidos, pois a API Docs de CreateBooking descreve somente a resposta de sucesso.

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

Depois de publicar o projeto no GitHub, consulte **Actions → API tests** e baixe o artefato da execução. A validação do workflow no runner do GitHub ainda está pendente. O badge de resultado será adicionado quando houver uma URL real do repositório.

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

Os arquivos planejados serão criados quando a automação da operação começar. Os recursos agrupam keywords por funcionalidade, com configuração compartilhada em `common.resource`.

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

UpdateBooking envia o corpo completo por `PUT /booking/{id}`, conforme a [API Docs](https://restful-booker.herokuapp.com/apidoc/index.html#api-Booking-UpdateBooking). O CT13 altera todos os campos, incluindo `depositpaid` de true para false, valida a resposta e consulta o mesmo ID para conferir persistência. Os CT14 e CT15 verificam rejeição sem autenticação ou com token inválido e consultam a reserva para garantir que seus dados originais foram preservados. O status 403 segue a [implementação da API](https://github.com/mwinteringham/restful-booker/blob/master/routes/index.js) e é conferido na execução. Uma sessão exclusiva para PUT evita herdar cookies; a autenticação de preparação permanece disponível para a limpeza. Basic Auth, corpos inválidos e IDs inexistentes ainda não estão cobertos nesta suíte.

PartialUpdateBooking envia somente os campos a alterar por `PATCH /booking/{id}`, conforme a [API Docs](https://restful-booker.herokuapp.com/apidoc/index.html#api-Booking-PartialUpdateBooking). O resultado esperado é uma cópia independente dos dados originais com as alterações aplicadas. Comparar o objeto completo na resposta e na consulta posterior verifica também a preservação dos campos omitidos. Os casos de autenticação usam uma sessão exclusiva, verificam status 403 e confirmam que a reserva permaneceu intacta. Nesta etapa, estão cobertos nomes e depósito; alterações em datas, outros campos, Basic Auth, corpo inválido e ID inexistente permanecem pendentes. Os exemplos da API Docs mostram PUT em alguns trechos de PartialUpdateBooking, mas a operação e a rota na implementação utilizam PATCH.

Para executar somente a operação PartialUpdateBooking:

```powershell
.\.venv\Scripts\python.exe -m robot --outputdir results tests/partial_update_booking.robot
```

DeleteBooking utiliza reservas próprias e uma sessão exclusiva para excluir por `DELETE /booking/{id}`. O sucesso é HTTP 201, conforme a [API Docs](https://restful-booker.herokuapp.com/apidoc/index.html#api-Booking-DeleteBooking), e a consulta posterior deve retornar 404. Sem autenticação ou com token inválido, verificamos status 403 e a preservação dos dados. Uma segunda exclusão autenticada do mesmo ID retorna 405 na [implementação desta API](https://github.com/mwinteringham/restful-booker/blob/master/routes/index.js); esse status é específico do serviço, não uma regra geral para APIs REST. Quando o DELETE retorna 201, o ID sai da lista de limpeza para evitar outra exclusão no teardown. Basic Auth ainda não está coberto.

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
