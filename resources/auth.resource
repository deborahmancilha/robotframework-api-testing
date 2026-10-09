*** Settings ***
Documentation    Criação de token de autenticação na API Restful Booker.
Resource         common.resource
Library          Collections

*** Variables ***
${AUTH_USERNAME}    admin
${AUTH_PASSWORD}    password123
${AUTH_PAYLOAD}     ${None}

*** Keywords ***
que possuo credenciais válidas para a API Restful Booker
    que possuo acesso à API Restful Booker
    ${payload}=    Create Dictionary    username=${AUTH_USERNAME}    password=${AUTH_PASSWORD}
    VAR    ${AUTH_PAYLOAD}    ${payload}    scope=TEST

eu enviar uma requisição para o endpoint de criação de token
    Should Not Be Equal    ${AUTH_PAYLOAD}    ${None}    Prepare as credenciais antes de enviar a requisição.
    ${response}=    POST On Session    booker    /auth    json=${AUTH_PAYLOAD}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter um token de autenticação
    Should Not Be Equal    ${RESPONSE}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Contain    ${RESPONSE.headers}[Content-Type]    application/json
    ${body}=    Set Variable    ${RESPONSE.json()}
    ${is_dictionary}=    Evaluate    isinstance($body, dict)
    Should Be True    ${is_dictionary}    A resposta deve ser um objeto JSON.
    Dictionary Should Contain Key    ${body}    token
    ${is_string}=    Evaluate    isinstance($body['token'], str)
    Should Be True    ${is_string}    O token deve ser uma string.
    Should Not Be Empty    ${body}[token]    O token não deve estar vazio.
