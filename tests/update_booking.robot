Language: pt

*** Settings ***
Documentation       Cenários da operação UpdateBooking: PUT completo com autenticação por cookie e Basic Auth.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT45 - API deve atualizar todos os campos de uma reserva com autenticação válida
    [Documentation]    Valida a substituição dos dados, incluindo depósito true para false, e persistência no mesmo ID.
    [Tags]    smoke    booking    update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve conter os dados atualizados da reserva
    E a reserva deve persistir os dados atualizados no mesmo ID

CT46 - API deve rejeitar a atualização de uma reserva sem autenticação
    [Documentation]    Valida status 403 e preservação dos dados originais após PUT sem credenciais.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva sem autenticação
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT47 - API deve rejeitar a atualização de uma reserva com token inválido
    [Documentation]    Valida status 403 e preservação dos dados originais após PUT com token inválido.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com um token inválido
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT48 - API deve rejeitar atualização com JSON malformado
    [Documentation]    Valida HTTP 400 e reserva intacta após erro de sintaxe JSON.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    Quando eu atualizar a reserva com JSON malformado e autenticação válida
    Então a API deve retornar o status    400
    E a reserva deve manter os dados originais

CT49 - API deve rejeitar atualização sem um campo obrigatório
    [Documentation]    Valida HTTP 400 e reserva intacta após omissão de firstname.
    [Tags]    booking    update_booking    negative    required

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    E o corpo da atualização omite um campo obrigatório    firstname
    Quando eu atualizar a reserva com autenticação válida
    Então a API deve retornar o status    400
    E a reserva deve manter os dados originais

CT50 - API deve rejeitar atualização de uma reserva inexistente
    [Documentation]    Caracteriza HTTP 405 no PUT de uma reserva própria previamente excluída.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E a reserva cadastrada foi excluída
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com autenticação válida
    Então a API deve retornar o status    405
    E a reserva excluída não deve estar disponível para consulta

CT51 - API deve atualizar uma reserva com Basic Auth válida
    [Documentation]    Valida Basic Auth sem cookie de token.
    [Tags]    booking    update_booking    basic_auth

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com Basic Auth válida
    Então a API deve retornar o status    200
    E a resposta deve conter os dados atualizados da reserva
    E a reserva deve persistir os dados atualizados no mesmo ID

CT52 - API deve rejeitar a atualização de uma reserva com Basic Auth inválida
    [Documentation]    Valida HTTP 403 e dados preservados sem cookie de token.
    [Tags]    booking    update_booking    basic_auth    negative

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com Basic Auth inválida
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais
