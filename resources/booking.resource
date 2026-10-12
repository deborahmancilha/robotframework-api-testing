*** Settings ***
Documentation    Requisições, validações e dados de teste das operações de reservas.
Resource         auth.resource

*** Variables ***
${BOOKING_ENDPOINT}    /booking
${BOOKING_FIRSTNAME}    ${None}
${BOOKING_LASTNAME}    ${None}
${BOOKING_OTHER_LASTNAME}    ${None}
${BOOKING_MISSING_NAME}    ${None}
@{CREATED_BOOKING_IDS}
@{EXPECTED_BOOKING_IDS}
${CLEANUP_TOKEN}    ${None}

*** Keywords ***
Preparar consulta de reservas
    que possuo acesso à API Restful Booker
    VAR    @{CREATED_BOOKING_IDS}    scope=TEST
    VAR    @{EXPECTED_BOOKING_IDS}    scope=TEST
    VAR    ${CLEANUP_TOKEN}    ${None}    scope=TEST

que possuo reservas próprias para consultar
    ${suffix}=    Evaluate    uuid.uuid4().hex    modules=uuid
    VAR    ${BOOKING_FIRSTNAME}    QA${suffix}    scope=TEST
    VAR    ${BOOKING_LASTNAME}    Titular${suffix}    scope=TEST
    VAR    ${BOOKING_OTHER_LASTNAME}    Outro${suffix}    scope=TEST
    VAR    ${BOOKING_MISSING_NAME}    Ausente${suffix}    scope=TEST
    ${credentials}=    Create Dictionary    username=${AUTH_USERNAME}    password=${AUTH_PASSWORD}
    ${auth_response}=    POST On Session    booker    /auth    json=${credentials}    expected_status=200
    ${auth_body}=    Set Variable    ${auth_response.json()}
    Dictionary Should Contain Key    ${auth_body}    token
    Should Not Be Empty    ${auth_body}[token]
    VAR    ${CLEANUP_TOKEN}    ${auth_body}[token]    scope=TEST
    Criar reserva para consulta    ${BOOKING_LASTNAME}
    Criar reserva para consulta    ${BOOKING_OTHER_LASTNAME}
    Criar reserva para consulta    ${BOOKING_LASTNAME}    Outro${suffix}

Criar reserva para consulta
    [Arguments]    ${lastname}    ${firstname}=${BOOKING_FIRSTNAME}
    ${dates}=    Create Dictionary    checkin=2026-11-10    checkout=2026-11-12
    ${payload}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${150}
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ${response}=    POST On Session    booker    ${BOOKING_ENDPOINT}    json=${payload}    expected_status=200
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    bookingid
    Append To List    ${CREATED_BOOKING_IDS}    ${body}[bookingid]

eu consultar os IDs de reservas sem filtros
    Consultar IDs de reservas

eu consultar os IDs de reservas pelo primeiro nome
    ${filters}=    Create Dictionary    firstname=${BOOKING_FIRSTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    ${CREATED_BOOKING_IDS}[1]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas pelo sobrenome
    ${filters}=    Create Dictionary    lastname=${BOOKING_LASTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    ${CREATED_BOOKING_IDS}[2]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas pelo nome e sobrenome
    ${filters}=    Create Dictionary    firstname=${BOOKING_FIRSTNAME}    lastname=${BOOKING_LASTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas por um nome sem correspondência
    ${filters}=    Create Dictionary    firstname=${BOOKING_MISSING_NAME}
    Consultar IDs de reservas    ${filters}

Consultar IDs de reservas
    [Arguments]    ${filters}=${None}
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}    params=${filters}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter uma lista de IDs de reservas em JSON
    Obter IDs da resposta

Obter IDs da resposta
    Should Not Be Equal    ${RESPONSE}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Contain    ${RESPONSE.headers}[Content-Type]    application/json
    ${body}=    Set Variable    ${RESPONSE.json()}
    ${is_list}=    Evaluate    isinstance($body, list)
    Should Be True    ${is_list}    A resposta deve ser uma lista JSON.
    ${ids}=    Create List
    FOR    ${item}    IN    @{body}
        ${is_dictionary}=    Evaluate    isinstance($item, dict)
        Should Be True    ${is_dictionary}    Cada item deve ser um objeto JSON.
        Dictionary Should Contain Key    ${item}    bookingid
        ${is_integer}=    Evaluate    type($item['bookingid']) is int
        Should Be True    ${is_integer}    bookingid deve ser um número inteiro.
        Append To List    ${ids}    ${item}[bookingid]
    END
    List Should Not Contain Duplicates    ${ids}
    RETURN    ${ids}

a resposta deve conter somente os IDs esperados para o filtro
    ${ids}=    Obter IDs da resposta
    Lists Should Be Equal    ${ids}    ${EXPECTED_BOOKING_IDS}    ignore_order=${True}

a resposta deve conter uma lista vazia
    ${ids}=    Obter IDs da resposta
    Should Be Empty    ${ids}    A busca sem correspondência deve retornar uma lista vazia.

Limpar reservas da consulta
    TRY
        ${cookies}=    Create Dictionary    token=${CLEANUP_TOKEN}
        FOR    ${booking_id}    IN    @{CREATED_BOOKING_IDS}
            Run Keyword And Continue On Failure
            ...    DELETE On Session    booker    ${BOOKING_ENDPOINT}/${booking_id}
            ...    cookies=${cookies}    expected_status=201
        END
    FINALLY
        Delete All Sessions
    END
