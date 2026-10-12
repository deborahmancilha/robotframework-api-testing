Language: pt

*** Settings ***
Documentation       Cenários da operação PartialUpdateBooking: PATCH com autenticação por cookie.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT16 - API deve atualizar somente o nome e sobrenome da reserva
    [Documentation]    Valida a alteração dos nomes, a preservação dos campos omitidos e a persistência no mesmo ID.
    [Tags]    smoke    booking    partial_update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT17 - API deve atualizar somente o depósito da reserva para não pago
    [Documentation]    Valida depositpaid false, a preservação dos campos omitidos e a persistência.
    [Tags]    booking    partial_update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o depósito para não pago
    Quando eu atualizar parcialmente a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve refletir a alteração parcial e preservar os demais campos
    E a reserva deve persistir os dados atualizados no mesmo ID

CT18 - API deve rejeitar a atualização parcial sem autenticação
    [Documentation]    Valida status 403 e dados originais preservados após PATCH sem credenciais.
    [Tags]    booking    partial_update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva sem autenticação
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT19 - API deve rejeitar a atualização parcial com token inválido
    [Documentation]    Valida status 403 e dados originais preservados após PATCH com token inválido.
    [Tags]    booking    partial_update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados para atualizar somente o nome e sobrenome da reserva
    Quando eu atualizar parcialmente a reserva com um token inválido
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais
