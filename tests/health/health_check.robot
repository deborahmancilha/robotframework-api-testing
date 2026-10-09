Language: pt

*** Settings ***
Documentation       Verificações iniciais de disponibilidade.
Resource            ../../resources/health.resource
Suite Teardown      Delete All Sessions

*** Test Cases ***
CT01 API deve estar disponível
    [Documentation]    Valida a disponibilidade da API Restful Booker.
    [Tags]    smoke    health

    Dado que possuo acesso à API Restful Booker
    Quando eu enviar uma requisição para o endpoint de health check
    Então a API deve retornar o status    201
