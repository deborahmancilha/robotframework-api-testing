# RESTful Booker · Automação de testes de API

![Python 3.12](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Robot Framework](https://img.shields.io/badge/Robot_Framework-7.5-00C0B5?logo=robotframework&logoColor=white)
![RequestsLibrary](https://img.shields.io/badge/RequestsLibrary-0.9.7-005571)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)

Projeto pessoal de qualidade de software para automatizar verificações da API REST de reservas **RESTful Booker**. O objetivo é construir uma suíte legível, reproduzível e integrada ao GitHub Actions, com evidências que permitam investigar cada execução.

- **Site base:** [https://restful-booker.herokuapp.com/](https://restful-booker.herokuapp.com/)
- **API Docs:** [https://restful-booker.herokuapp.com/apidoc/index.html](https://restful-booker.herokuapp.com/apidoc/index.html)

> **Etapa atual:** preparação da base do projeto, com um teste de health check implementado. O workflow está configurado; sua execução no GitHub depende da publicação do repositório. As próximas operações serão automatizadas depois da revisão da base e publicação no GitHub.

## O que este projeto demonstra

- Validação do status HTTP do endpoint de health check.
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
| **CT01 API deve estar disponível** | `GET /ping` | HTTP 201 |

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
│   ├── common.resource
│   └── health.resource
├── tests/
│   └── health/
│       └── health_check.robot
├── results/
├── .gitignore
├── README.md
└── requirements.txt
```

`common.resource` centraliza a conexão HTTP; `health.resource` reúne as keywords usadas pela suíte `health_check.robot`. A pasta `.venv/` também existe localmente. Ela e `results/` ficam no `.gitignore` e não são versionadas; os resultados são gerados durante a execução.

## Convenção de nomes das suítes

Os arquivos de teste seguem o nome das operações documentadas na API Docs, convertido para `snake_case`. Os cenários de cada operação ficam na mesma suíte, organizada por funcionalidade.

| Operação na API Docs | Arquivo de teste | Situação |
| --- | --- | --- |
| HealthCheck | `tests/health/health_check.robot` | Implementado |
| CreateToken | `tests/auth/create_token.robot` | Planejado |
| GetBookingIds | `tests/booking/get_booking_ids.robot` | Planejado |
| GetBooking | `tests/booking/get_booking.robot` | Planejado |
| CreateBooking | `tests/booking/create_booking.robot` | Planejado |
| UpdateBooking | `tests/booking/update_booking.robot` | Planejado |
| PartialUpdateBooking | `tests/booking/partial_update_booking.robot` | Planejado |
| DeleteBooking | `tests/booking/delete_booking.robot` | Planejado |

Os arquivos planejados serão criados quando a automação da operação começar. Os recursos agrupam keywords por funcionalidade, com configuração compartilhada em `common.resource`.

## Escrita dos cenários em BDD

Os casos usam o padrão Given/When/Then em português dentro de arquivos `.robot`. A declaração `Language: pt` habilita os prefixos `Dado`, `Quando`, `Então` e `E` no Robot Framework.

```robotframework
CT01 API deve estar disponível
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

## Decisões de teste

- **Sessão reutilizável:** configuração centralizada da URL e do timeout de 30 segundos.
- **TLS verificado:** as requisições mantêm a validação de certificados habilitada.
- **Status explícitos:** o passo `Então` declara e valida o código esperado; `/ping` utiliza 201 conforme a API.
- **Dados compartilhados:** os testes iniciais apenas leem a API pública. A futura suíte de escrita deverá criar suas próprias reservas e limpar os dados que criar.
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
