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

CT03 - API deve negar token para usuário incorreto
    [Documentation]    Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token.
    [Tags]    auth    create_token    negative

    Dado que possuo credenciais válidas para a API Restful Booker
    E as credenciais possuem um usuário incorreto
    Quando eu enviar uma requisição para o endpoint de criação de token
    Então a API deve retornar o status    200
    E a resposta deve informar credenciais inválidas sem criar token

CT04 - API deve negar token para senha incorreta
    [Documentation]    Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token.
    [Tags]    auth    create_token    negative

    Dado que possuo credenciais válidas para a API Restful Booker
    E as credenciais possuem uma senha incorreta
    Quando eu enviar uma requisição para o endpoint de criação de token
    Então a API deve retornar o status    200
    E a resposta deve informar credenciais inválidas sem criar token

CT05 - API deve negar token sem o campo username
    [Documentation]    Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token.
    [Tags]    auth    create_token    negative

    Dado que possuo credenciais válidas para a API Restful Booker
    E o campo de credencial foi omitido    username
    Quando eu enviar uma requisição para o endpoint de criação de token
    Então a API deve retornar o status    200
    E a resposta deve informar credenciais inválidas sem criar token

CT06 - API deve negar token sem o campo password
    [Documentation]    Valida o comportamento da API: HTTP 200, reason Bad credentials e ausência de token.
    [Tags]    auth    create_token    negative

    Dado que possuo credenciais válidas para a API Restful Booker
    E o campo de credencial foi omitido    password
    Quando eu enviar uma requisição para o endpoint de criação de token
    Então a API deve retornar o status    200
    E a resposta deve informar credenciais inválidas sem criar token
