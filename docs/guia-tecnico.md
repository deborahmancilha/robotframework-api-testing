# Guia técnico

[README](../README.md) · [Cobertura e critérios](cobertura.md)

Detalhes de ambiente, arquitetura, escrita dos cenários, execução e CI. Todos os comandos abaixo devem ser executados a partir da raiz do projeto. Os resultados ficam em `results/`, ignorada pelo Git.

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

## Estrutura

```text
Projeto_outubro/
├── .github/
│   └── workflows/
│       └── api-tests.yml
├── .vscode/
│   ├── extensions.json
│   └── settings.json
├── docs/
│   ├── cobertura.md
│   └── guia-tecnico.md
├── resources/
│   ├── auth.resource
│   ├── booking.resource
│   ├── booking_api.resource
│   ├── booking_data.resource
│   ├── booking_validations.resource
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

`common.resource` centraliza as bibliotecas RequestsLibrary e Collections, a conexão HTTP, a preparação da resposta e a validação de status. `health.resource` reúne a requisição de health check; `auth.resource` reúne a preparação das credenciais, a requisição de autenticação e a validação do token. A pasta `.venv/` também existe localmente. Ela e `results/` ficam no `.gitignore` e não são versionadas; os resultados são gerados durante a execução.

### Camadas dos recursos de reservas

| Recurso | Responsabilidade |
| --- | --- |
| `booking.resource` | Keywords BDD, estado de cada teste, preparação e limpeza das reservas |
| `booking_data.resource` | Montagem e cópia de payloads, filtros, datas e resultados esperados |
| `booking_api.resource` | GET, POST, PUT, PATCH e DELETE; headers, cookies, Basic Auth e sessões das operações protegidas |
| `booking_validations.resource` | Assertions de status de rejeição, JSON, campos, tipos, valores e listas de IDs |

As suítes continuam importando `booking.resource`. Ele recebe os resultados dos auxiliares e guarda somente o estado necessário no escopo do caso. Os auxiliares recebem argumentos explícitos e retornam os dados ou respostas, sem alterar variáveis de teste. Eles importam `common.resource` e não importam a camada BDD de volta, evitando dependências circulares.

Por exemplo, o passo de criação chama `Enviar criação de reserva` com o payload, guarda a resposta e registra o ID para limpeza. O passo de validação chama `Validar resposta de criação` com essa resposta e os dados esperados. Na atualização parcial, os dados originais são copiados para montar o resultado esperado sem alterar a reserva original em memória.

As validações de tipos são individuais: uma falha informa o campo e os tipos esperado e recebido, como `depositpaid deve ser bool; recebido str`. Os campos aninhados também são identificados por nome, como `bookingdates.checkout`. A comparação dos valores continua verificando o objeto completo. Os 68 cenários BDD, sua numeração e os critérios funcionais e de caracterização foram preservados nesta reorganização.

## Preparação e limpeza

Cada caso cria suas próprias reservas com nomes únicos, registra os IDs e exclui somente esses registros no teardown, mesmo após falhas de validação. Na criação, registramos o ID antes das assertions. Se a resposta não trouxer um ID utilizável, a limpeza tenta localizar exclusivamente o nome UUID do payload, inclusive após respostas de erro. Não são excluídas reservas públicas genéricas. Uma exclusão concluída remove o ID da lista de limpeza; falhas de limpeza reprovam o caso e as sessões são encerradas em `FINALLY`.

A API é pública e compartilhada; reinicializações ou alterações de terceiros durante o caso podem causar falhas. XML, formulários, desempenho, expiração de tokens e combinações exaustivas de campos continuam fora da cobertura atual.

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

A separação segue a ideia de encapsular ações e detalhes técnicos usada no Page Object Model (POM). Para esta API, os recursos representam operações de serviço: as suítes em `tests/` descrevem os cenários BDD, `booking.resource` coordena suas ações e os três auxiliares concentram dados, requisições e validações. `common.resource` fornece conexão, bibliotecas e status compartilhados.

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

UpdateBooking envia o corpo completo por PUT, com cenários positivos, entradas inválidas, ID inexistente e autenticação por token ou Basic Auth. Os detalhes estão no [catálogo de cenários](cobertura.md).

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

## Decisões de teste

- **Sessão reutilizável:** configuração centralizada da URL e do timeout de 30 segundos.
- **TLS verificado:** as requisições mantêm a validação de certificados habilitada.
- **Status explícitos:** o passo `Então` declara e valida o código esperado; `/ping` utiliza 201 conforme a API.
- **Dados compartilhados:** os filtros de reservas usam dados próprios com nomes únicos e limpeza no teardown, evitando depender dos registros públicos existentes.
- **Falhas visíveis:** não há repetição automática para transformar falhas em sucesso. Indisponibilidade da API pública deve ser investigada pelos relatórios.

## Integração contínua

O workflow `.github/workflows/api-tests.yml` é acionado em pushes, pull requests e execução manual. Ele possui dois jobs independentes, que podem executar em paralelo conforme a disponibilidade dos runners. Cada job configura Python 3.12, instala as dependências e publica seus relatórios com retenção de 14 dias, mesmo quando os testes falham.

| Job | Seleção | Pasta de resultados | Artefato |
| --- | --- | --- | --- |
| Smoke | Oito cenários com a tag `smoke`, um por operação | `results/smoke/` | `robot-smoke-reports` |
| Suíte completa | Todos os 68 cenários, incluindo smoke, entradas inválidas, limites e caracterizações | `results/full/` | `robot-full-reports` |

Os smoke são CT01, CT02, CT07, CT16, CT18, CT45, CT53 e CT63: verificam os caminhos básicos de health check, autenticação, listagem, consulta, criação, PUT, PATCH e DELETE. Eles fornecem uma verificação menor das operações principais; smoke aprovado não garante que todos os comportamentos da API estejam corretos.

A suíte completa executa mesmo se o smoke falhar. Cada job preserva o código de saída do Robot Framework: uma falha de teste reprova o job correspondente. Os casos com `known_bug` continuam ativos na suíte completa e suas falhas permanecem visíveis. Os oito smoke são executados novamente na suíte completa; cada execução prepara e limpa seus próprios dados.

Para reproduzir as execuções localmente:

```powershell
# Smoke
.\.venv\Scripts\python.exe -m robot --include smoke --outputdir results/smoke tests

# Suíte completa
.\.venv\Scripts\python.exe -m robot --outputdir results/full tests
```

Para consultar os resultados, abra [Actions → API tests](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml), selecione uma execução e confira o status de cada job. Baixe `robot-smoke-reports` ou `robot-full-reports`, extraia o arquivo e abra `report.html` para o resumo ou `log.html` para os detalhes. Cada artefato também inclui `output.xml`.

Uma execução pode ter Smoke aprovado e Suíte completa reprovada: as operações básicas passaram, mas outros cenários encontraram divergências. O badge no início deste README mostra o resultado agregado do workflow na branch `main`; se qualquer job falhar, ele indica falha.

A configuração com dois jobs foi validada no GitHub em 13/10/2026, na [execução do commit `ffce3bf`](https://github.com/deborahmancilha/robotframework-api-testing/actions/runs/38461637240). O job **Smoke foi aprovado**, com os oito cenários; o job **Suíte completa foi reprovado**, com 52 casos aprovados e as mesmas 16 falhas conhecidas. Ambos concluíram a publicação dos artefatos `robot-smoke-reports` e `robot-full-reports`. A validação confirma o funcionamento dos dois jobs e da publicação dos relatórios; as falhas da suíte completa permanecem registradas e reprovam o workflow.

Na validação local dessa configuração, os oito smoke passaram na API real, sem falhas de limpeza. O dry run da suíte completa validou a estrutura dos 68 cenários sem chamar a API; esse resultado não substitui uma execução real nem altera as divergências documentadas.

## Referências

- [API RESTful Booker](https://restful-booker.herokuapp.com/)
- [Documentação dos endpoints](https://restful-booker.herokuapp.com/apidoc/index.html)
- [ISTQB — CTFL Syllabus v4.0.1, seção 2.2.2: tipos de teste e testes funcionais](https://istqb.org/wp-content/uploads/2024/11/ISTQB_CTFL_Syllabus_v4.0.1.pdf)
- [Robot Framework — guia oficial](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [RequestsLibrary — repositório oficial](https://github.com/MarketSquare/robotframework-requests)
- [GitHub Actions — projetos Python](https://docs.github.com/en/actions/tutorials/build-and-test-code/python)
- [Python 3.12.10 — instalador utilizado no Windows](https://www.python.org/downloads/release/python-31210/)
