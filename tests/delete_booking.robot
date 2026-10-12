Language: pt

*** Settings ***
Documentation       Cenários da operação DeleteBooking com autenticação por cookie.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT20 - API deve excluir uma reserva com autenticação válida
    [Documentation]    Valida status 201 e confirma a exclusão com GET retornando 404.
    [Tags]    smoke    booking    delete_booking

    Dado que possuo uma reserva própria cadastrada
    Quando eu excluir a reserva com autenticação válida
    Então a API deve retornar o status    201
    E a reserva excluída não deve estar disponível para consulta

CT21 - API deve rejeitar a exclusão de uma reserva sem autenticação
    [Documentation]    Valida status 403 e confirma que a reserva permanece existente e intacta.
    [Tags]    booking    delete_booking    negative

    Dado que possuo uma reserva própria cadastrada
    Quando eu excluir a reserva sem autenticação
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT22 - API deve rejeitar a exclusão de uma reserva com token inválido
    [Documentation]    Valida status 403 e confirma que a reserva permanece existente e intacta.
    [Tags]    booking    delete_booking    negative

    Dado que possuo uma reserva própria cadastrada
    Quando eu excluir a reserva com um token inválido
    Então a API deve retornar o status    403
    E a reserva deve manter os dados originais

CT23 - API deve rejeitar uma nova exclusão de uma reserva já excluída
    [Documentation]    Valida status 405 para DELETE autenticado em ID próprio já excluído.
    [Tags]    booking    delete_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E a reserva cadastrada foi excluída
    Quando eu excluir a reserva com autenticação válida
    Então a API deve retornar o status    405
    E a reserva excluída não deve estar disponível para consulta
