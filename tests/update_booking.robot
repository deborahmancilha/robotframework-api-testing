Language: pt

*** Settings ***
Documentation       Cenários da operação UpdateBooking: PUT completo com autenticação por cookie.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT13 - API deve atualizar todos os campos de uma reserva com autenticação válida
    [Documentation]    Valida a substituição dos dados, incluindo depósito true para false, e persistência no mesmo ID.
    [Tags]    smoke    booking    update_booking

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com autenticação válida
    Então a API deve retornar o status    200
    E a resposta deve conter os dados atualizados da reserva
    E a reserva deve persistir os dados atualizados no mesmo ID

CT14 - API deve rejeitar a atualização de uma reserva sem autenticação
    [Documentation]    Valida status 403 e preservação dos dados originais após PUT sem credenciais.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva sem autenticação
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT15 - API deve rejeitar a atualização de uma reserva com token inválido
    [Documentation]    Valida status 403 e preservação dos dados originais após PUT com token inválido.
    [Tags]    booking    update_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E dados válidos para atualizar todos os campos da reserva
    Quando eu atualizar a reserva com um token inválido
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais
