*** Settings ***
Documentation    Verificação de disponibilidade básica da API.
Resource         common.resource

*** Keywords ***
eu enviar uma requisição para o endpoint de health check
    ${response}=    GET On Session    booker    /ping    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST
