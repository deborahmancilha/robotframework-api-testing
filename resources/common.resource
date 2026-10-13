*** Settings ***
Documentation    Configuração compartilhada da conexão HTTP.
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    https://restful-booker.herokuapp.com
${TIMEOUT}     30
${RESPONSE}    ${None}

*** Keywords ***
Conectar à API
    Create Session    booker    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}

que possuo acesso à API Restful Booker
    VAR    ${RESPONSE}    ${None}    scope=TEST
    Conectar à API

a API deve retornar o status
    [Arguments]    ${expected_status}
    Validar status da resposta    ${RESPONSE}    ${expected_status}

Validar status da resposta
    [Arguments]    ${response}    ${expected_status}
    Should Not Be Equal    ${response}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}
