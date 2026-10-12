Language: pt

*** Settings ***
Documentation       Cenários positivos da operação CreateBooking em JSON.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT10 - API deve criar uma reserva com dados válidos
    [Documentation]    Valida status, ID, dados retornados e persistência de uma reserva completa.
    [Tags]    smoke    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT11 - API deve criar uma reserva com depósito não pago
    [Documentation]    Valida que depositpaid false é preservado na criação e na consulta.
    [Tags]    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    E o depósito da reserva não foi pago
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT12 - API deve preservar acentos e apóstrofo nos nomes da reserva
    [Documentation]    Valida a preservação dos nomes com acentos e apóstrofo no retorno e na persistência.
    [Tags]    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    E os nomes da reserva contêm acentos e apóstrofo
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados
