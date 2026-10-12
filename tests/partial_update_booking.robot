Language: pt

*** Settings ***
Documentation       Cenários da operação PartialUpdateBooking: PATCH com autenticação por cookie e Basic Auth.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT45 - API deve atualizar somente o nome e sobrenome da reserva
    [Documentation]    Valida a alteração dos nomes, a preservação dos campos omitidos e a persistência no mesmo ID.
    [Tags]    smoke    booking    partial_update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT46 - API deve atualizar somente o depósito da reserva para não pago
    [Documentation]    Valida depositpaid false, a preservação dos campos omitidos e a persistência.
    [Tags]    booking    partial_update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o depósito para não pago
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT47 - API deve rejeitar a atualização parcial sem autenticação
    [Documentation]    Valida status 403 e dados originais preservados após PATCH sem credenciais.
    [Tags]    booking    partial_update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva sem autenticação
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT48 - API deve rejeitar a atualização parcial com token inválido
    [Documentation]    Valida status 403 e dados originais preservados após PATCH com token inválido.
    [Tags]    booking    partial_update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com um token inválido
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT49 - API deve atualizar somente o preço da reserva
    [Documentation]    Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados.
    [Tags]    booking    partial_update_booking    contract

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o preço da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT50 - API deve atualizar somente as necessidades adicionais da reserva
    [Documentation]    Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados.
    [Tags]    booking    partial_update_booking    contract

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente as necessidades adicionais da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT51 - API deve atualizar somente as datas da reserva
    [Documentation]    Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados.
    [Tags]    booking    partial_update_booking    contract

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente as datas da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT52 - API deve atualizar somente a data de entrada da reserva
    [Documentation]    Valida alteração parcial, persistência e preservação dos demais campos, incluindo campos aninhados.
    [Tags]    booking    partial_update_booking    contract    known_bug

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente a data de entrada da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT53 - API deve atualizar parcialmente uma reserva com Basic Auth válida
    [Documentation]    Valida Basic Auth sem cookie de token.
    [Tags]    booking    partial_update_booking    basic_auth

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com Basic Auth válida
    Então a API deve retornar o status    200
    E a resposta deve conter os dados atualizados da reserva
    E a reserva deve persistir os dados atualizados no mesmo ID

CT54 - API deve rejeitar a atualização parcial de uma reserva com Basic Auth inválida
    [Documentation]    Valida HTTP 403 e dados preservados sem cookie de token.
    [Tags]    booking    partial_update_booking    basic_auth    negative

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com Basic Auth inválida
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais
