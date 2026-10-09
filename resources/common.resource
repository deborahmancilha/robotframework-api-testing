*** Settings ***
Documentation    Configuração compartilhada da conexão HTTP.
Library    RequestsLibrary

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
    Should Not Be Equal    ${RESPONSE}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Be Equal As Integers    ${RESPONSE.status_code}    ${expected_status}
