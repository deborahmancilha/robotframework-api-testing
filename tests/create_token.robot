Language: pt

*** Settings ***
Documentation       Cenários da operação CreateToken da API Restful Booker.
Resource            ../resources/auth.resource
Suite Teardown      Delete All Sessions

*** Test Cases ***
CT02 - API deve criar um token com credenciais válidas
    [Documentation]    Valida a criação de token com as credenciais públicas documentadas da API.
    [Tags]    smoke    auth

    Dado que possuo credenciais válidas para a API Restful Booker
    Quando eu enviar uma requisição para o endpoint de criação de token
    Então a API deve retornar o status    200
    E a resposta deve conter um token de autenticação
