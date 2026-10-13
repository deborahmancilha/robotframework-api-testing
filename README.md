# RESTful Booker · Automação de testes de API

![Python 3.12](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Robot Framework](https://img.shields.io/badge/Robot_Framework-7.5-00C0B5?logo=robotframework&logoColor=white)
![RequestsLibrary](https://img.shields.io/badge/RequestsLibrary-0.9.7-005571)
[![API tests](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml/badge.svg?branch=main)](https://github.com/deborahmancilha/robotframework-api-testing/actions/workflows/api-tests.yml)

Projeto pessoal de automação de testes da API RESTful Booker, desenvolvido com Robot Framework, RequestsLibrary e Python. Implementa cenários BDD para as oito operações da API, com execução automatizada no GitHub Actions e relatórios de teste.

- **Site base:** [RESTful Booker](https://restful-booker.herokuapp.com/)
- **API Docs:** [Documentação dos endpoints](https://restful-booker.herokuapp.com/apidoc/index.html)

> **Etapa atual:** oito operações implementadas, 68 casos de teste e CI validada com jobs independentes de Smoke e Suíte completa.

## Habilidades demonstradas

- Testes funcionais de API: CRUD, status HTTP, estrutura JSON e persistência.
- Autenticação por cookie de token e Basic Auth, com cenários positivos e negativos.
- BDD em português e recursos separados para dados, requisições e validações.
- Dados próprios, nomes únicos e limpeza automatizada das reservas.
- Testes de caracterização, análise de divergências e relatórios preservados na CI.

## Cobertura implementada

**68 casos de teste**, incluindo oito smoke, um por operação. As suítes ficam diretamente em `tests/` e os casos preparam seus próprios dados.

| Operação | Casos |
| --- | ---: |
| HealthCheck | 1 |
| CreateToken | 5 |
| GetBookingIds | 9 |
| GetBooking | 2 |
| CreateBooking | 27 |
| UpdateBooking | 8 |
| PartialUpdateBooking | 10 |
| DeleteBooking | 6 |

O [catálogo de cobertura](docs/cobertura.md) reúne os títulos dos CTs, critérios, tags, testes de caracterização e divergências conhecidas.

## Como executar

Pré-requisitos: **Python 3.12**, Git e acesso à internet. VS Code e RobotCode são recomendados para edição. As versões das dependências estão fixadas em [requirements.txt](requirements.txt).

Na raiz do projeto, pelo PowerShell:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Execute o health check, selecione a tag `smoke` ou rode a suíte completa:

```powershell
# Apenas health check
.\.venv\Scripts\python.exe -m robot --include health --outputdir results/health tests

# Apenas pela tag smoke
.\.venv\Scripts\python.exe -m robot --include smoke --outputdir results/smoke tests

# Todos os testes
.\.venv\Scripts\python.exe -m robot --outputdir results/full tests
```

Os comandos usam o Python do venv diretamente, sem precisar ativá-lo. Em Linux/macOS, crie o ambiente com `python3.12 -m venv .venv` e use `.venv/bin/python`.

Abra `report.html` na pasta da execução para o resumo e `log.html` para investigar os detalhes. O `output.xml` permite processar os resultados automaticamente.

## CI e resultados

O [workflow API tests](.github/workflows/api-tests.yml) executa em pushes, pull requests e acionamento manual. Os dois jobs são independentes e publicam seus relatórios com retenção de 14 dias, inclusive após falhas.

**Última execução validada — 13/10/2026, commit `ffce3bf`:**

| Job | Resultado | Artefato |
| --- | --- | --- |
| Smoke | Oito casos aprovados | `robot-smoke-reports` |
| Suíte completa | 52 aprovados e 16 falhas conhecidas | `robot-full-reports` |

[Consultar a execução e baixar os relatórios](https://github.com/deborahmancilha/robotframework-api-testing/actions/runs/38461637240).

As falhas conhecidas permanecem ativas e reprovam a suíte completa e o workflow. Smoke aprovado confirma os caminhos básicos; não garante que toda a API esteja correta. O badge mostra o resultado agregado do workflow na `main`.

Os [critérios e as divergências observadas](docs/cobertura.md#divergências-observadas-na-ampliação) distinguem o comportamento documentado, as expectativas adotadas pelo projeto e as caracterizações do serviço.

## Organização

```text
Projeto_outubro/
├── .github/workflows/   # Integração contínua
├── .vscode/            # Configuração do editor
├── docs/               # Documentação detalhada
├── resources/          # Keywords BDD, dados, HTTP e validações
├── tests/              # Suítes por operação da API
├── results/            # Relatórios locais, ignorados pelo Git
├── README.md
└── requirements.txt
```

O ambiente `.venv/` também existe localmente e é ignorado pelo Git. A arquitetura e as responsabilidades dos recursos estão no [guia técnico](docs/guia-tecnico.md#camadas-dos-recursos-de-reservas).

## Documentação

- [Cobertura e critérios de teste](docs/cobertura.md): catálogo dos 68 CTs, classificação das tags e divergências.
- [Guia técnico](docs/guia-tecnico.md): ambiente, arquitetura, exemplo BDD, comandos adicionais, CI e decisões de teste.

## Referências

- [Robot Framework — guia oficial](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [RequestsLibrary — repositório oficial](https://github.com/MarketSquare/robotframework-requests)
- [GitHub Actions — projetos Python](https://docs.github.com/en/actions/tutorials/build-and-test-code/python)
- [ISTQB — CTFL Syllabus v4.0.1, seção 2.2.2: tipos de teste](https://istqb.org/wp-content/uploads/2024/11/ISTQB_CTFL_Syllabus_v4.0.1.pdf)
