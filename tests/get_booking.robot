Language: pt

*** Settings ***
Documentation       Cenários da operação GetBooking: consulta de uma reserva por ID.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT08 - API deve consultar uma reserva existente pelo ID
    [Documentation]    Valida status 200 e os dados completos de uma reserva própria consultada por ID.
    [Tags]    smoke    booking    get_booking

    Dado que possuo uma reserva própria cadastrada
    Quando eu consultar a reserva pelo ID
    Então a API deve retornar o status    200
    E a resposta deve conter os dados da reserva cadastrada

CT09 - API deve retornar não encontrado para uma reserva excluída
    [Documentation]    Valida status 404 ao consultar o ID de uma reserva própria previamente excluída.
    [Tags]    booking    get_booking    negative

    Dado que possuo uma reserva própria cadastrada
    E a reserva cadastrada foi excluída
    Quando eu consultar a reserva pelo ID
    Então a API deve retornar o status    404
