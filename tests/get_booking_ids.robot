Language: pt

*** Settings ***
Documentation       Cenários da operação GetBookingIds: listagem e filtros por nome.
Resource            ../resources/booking.resource
Test Setup          Preparar consulta de reservas
Test Teardown       Limpar reservas da consulta

*** Test Cases ***
CT03 - API deve listar os IDs das reservas
    [Documentation]    Valida status, formato JSON, tipo dos IDs e ausência de duplicatas.
    [Tags]    smoke    booking    get_booking_ids

    Dado que possuo acesso à API Restful Booker
    Quando eu consultar os IDs de reservas sem filtros
    Então a API deve retornar o status    200
    E a resposta deve conter uma lista de IDs de reservas em JSON

CT04 - API deve filtrar os IDs das reservas pelo primeiro nome
    [Documentation]    Valida que o filtro firstname retorna as duas reservas próprias com o mesmo primeiro nome.
    [Tags]    booking    get_booking_ids    filter

    Dado que possuo reservas próprias para consultar
    Quando eu consultar os IDs de reservas pelo primeiro nome
    Então a API deve retornar o status    200
    E a resposta deve conter somente os IDs esperados para o filtro

CT05 - API deve filtrar os IDs das reservas pelo sobrenome
    [Documentation]    Valida que o filtro lastname retorna as duas reservas próprias com o mesmo sobrenome.
    [Tags]    booking    get_booking_ids    filter

    Dado que possuo reservas próprias para consultar
    Quando eu consultar os IDs de reservas pelo sobrenome
    Então a API deve retornar o status    200
    E a resposta deve conter somente os IDs esperados para o filtro

CT06 - API deve filtrar os IDs das reservas pelo nome e sobrenome
    [Documentation]    Valida que ambos os filtros são aplicados, excluindo reservas que combinam apenas um dos campos.
    [Tags]    booking    get_booking_ids    filter

    Dado que possuo reservas próprias para consultar
    Quando eu consultar os IDs de reservas pelo nome e sobrenome
    Então a API deve retornar o status    200
    E a resposta deve conter somente os IDs esperados para o filtro

CT07 - API deve retornar uma lista vazia para um nome sem correspondência
    [Documentation]    Valida uma busca válida sem resultados usando um nome único diferente das reservas criadas.
    [Tags]    booking    get_booking_ids    filter

    Dado que possuo reservas próprias para consultar
    Quando eu consultar os IDs de reservas por um nome sem correspondência
    Então a API deve retornar o status    200
    E a resposta deve conter uma lista vazia
