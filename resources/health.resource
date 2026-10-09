*** Settings ***
Documentation    Verificação de disponibilidade básica da API.
Resource         common.resource

*** Variables ***
${RESPONSE}    ${None}

*** Keywords ***
que possuo acesso à API Restful Booker
    VAR    ${RESPONSE}    ${None}    scope=TEST
    Conectar à API

eu enviar uma requisição para o endpoint de health check
    ${response}=    GET On Session    booker    /ping    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a API deve retornar o status
    [Arguments]    ${expected_status}
    Should Not Be Equal    ${RESPONSE}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Be Equal As Integers    ${RESPONSE.status_code}    ${expected_status}
