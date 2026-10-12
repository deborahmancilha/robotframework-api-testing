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
${BOOKING_PAYLOAD}    ${None}
${CREATED_BOOKING_ID}    ${None}
${UPDATED_BOOKING_PAYLOAD}    ${None}
${PARTIAL_BOOKING_PAYLOAD}    ${None}

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
    Obter token para limpeza de reservas
    Criar reserva para consulta    ${BOOKING_LASTNAME}
    Criar reserva para consulta    ${BOOKING_OTHER_LASTNAME}
    Criar reserva para consulta    ${BOOKING_LASTNAME}    Outro${suffix}

Obter token para limpeza de reservas
    ${credentials}=    Create Dictionary    username=${AUTH_USERNAME}    password=${AUTH_PASSWORD}
    ${auth_response}=    POST On Session    booker    /auth    json=${credentials}    expected_status=200
    ${auth_body}=    Set Variable    ${auth_response.json()}
    Dictionary Should Contain Key    ${auth_body}    token
    Should Not Be Empty    ${auth_body}[token]
    VAR    ${CLEANUP_TOKEN}    ${auth_body}[token]    scope=TEST

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

Preparar criação de reserva
    Preparar consulta de reservas
    VAR    ${BOOKING_PAYLOAD}    ${None}    scope=TEST
    VAR    ${CREATED_BOOKING_ID}    ${None}    scope=TEST
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${None}    scope=TEST
    VAR    ${PARTIAL_BOOKING_PAYLOAD}    ${None}    scope=TEST
    Obter token para limpeza de reservas

que possuo dados válidos para criar uma reserva
    ${suffix}=    Evaluate    uuid.uuid4().hex    modules=uuid
    ${dates}=    Create Dictionary    checkin=2026-11-10    checkout=2026-11-12
    ${payload}=    Create Dictionary
    ...    firstname=QA${suffix}
    ...    lastname=Titular${suffix}
    ...    totalprice=${150}
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=Breakfast
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

o depósito da reserva não foi pago
    Set To Dictionary    ${BOOKING_PAYLOAD}    depositpaid=${False}

os nomes da reserva contêm acentos e apóstrofo
    Set To Dictionary    ${BOOKING_PAYLOAD}    firstname=Débora${BOOKING_PAYLOAD}[firstname]    lastname=D'Ávila

eu enviar uma requisição para o endpoint de criação de reserva
    Should Not Be Equal    ${BOOKING_PAYLOAD}    ${None}    Prepare os dados antes de criar a reserva.
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    POST On Session    booker    ${BOOKING_ENDPOINT}
    ...    json=${BOOKING_PAYLOAD}    headers=${headers}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST
    # Registra o ID antes das assertions para permitir a limpeza se uma validação falhar.
    ${body}=    Set Variable    ${response.json()}
    ${has_id}=    Evaluate    isinstance($body, dict) and type($body.get('bookingid')) is int
    IF    ${has_id}
        VAR    ${CREATED_BOOKING_ID}    ${body}[bookingid]    scope=TEST
        Append To List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}
    END

a resposta deve conter o ID e os dados da reserva criada
    Should Contain    ${RESPONSE.headers}[Content-Type]    application/json
    ${body}=    Set Variable    ${RESPONSE.json()}
    ${is_dictionary}=    Evaluate    isinstance($body, dict)
    Should Be True    ${is_dictionary}    A resposta deve ser um objeto JSON.
    Dictionary Should Contain Key    ${body}    bookingid
    ${is_integer}=    Evaluate    type($body['bookingid']) is int
    Should Be True    ${is_integer}    bookingid deve ser inteiro.
    Dictionary Should Contain Key    ${body}    booking
    Validar dados da reserva    ${body}[booking]

a reserva deve estar disponível para consulta com os dados enviados
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    A criação deve retornar um ID para consulta.
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    headers=${headers}    expected_status=200
    Should Contain    ${response.headers}[Content-Type]    application/json
    Validar dados da reserva    ${response.json()}

que possuo uma reserva própria cadastrada
    que possuo dados válidos para criar uma reserva
    eu enviar uma requisição para o endpoint de criação de reserva
    a API deve retornar o status    200
    a resposta deve conter o ID e os dados da reserva criada

a reserva cadastrada foi excluída
    ${cookies}=    Create Dictionary    token=${CLEANUP_TOKEN}
    DELETE On Session    booker    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    cookies=${cookies}    expected_status=201
    Remove Values From List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}

eu consultar a reserva pelo ID
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    Prepare uma reserva antes de consultar seu ID.
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    headers=${headers}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter os dados da reserva cadastrada
    Should Contain    ${RESPONSE.headers}[Content-Type]    application/json
    Validar dados da reserva    ${RESPONSE.json()}

dados válidos para atualizar todos os campos da reserva
    ${suffix}=    Evaluate    uuid.uuid4().hex    modules=uuid
    ${dates}=    Create Dictionary    checkin=2026-12-15    checkout=2026-12-18
    ${payload}=    Create Dictionary
    ...    firstname=Atualizada${suffix}
    ...    lastname=Novo${suffix}
    ...    totalprice=${275}
    ...    depositpaid=${False}
    ...    bookingdates=${dates}
    ...    additionalneeds=Dinner
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${payload}    scope=TEST

eu atualizar a reserva com autenticação válida
    Enviar atualização completa da reserva    ${CLEANUP_TOKEN}

eu atualizar a reserva sem autenticação
    Enviar atualização completa da reserva

eu atualizar a reserva com um token inválido
    ${invalid_token}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Enviar atualização completa da reserva    invalido${invalid_token}

Enviar atualização completa da reserva
    [Arguments]    ${token}=${None}
    Should Not Be Equal    ${UPDATED_BOOKING_PAYLOAD}    ${None}    Prepare os dados da atualização.
    # Sessão exclusiva para garantir que o caso sem autenticação não herde cookies.
    Create Session    booker_update    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}
    ${headers}=    Create Dictionary    Accept=application/json
    ${cookies}=    Create Dictionary
    IF    $token is not None
        Set To Dictionary    ${cookies}    token=${token}
    END
    ${response}=    PUT On Session    booker_update    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    json=${UPDATED_BOOKING_PAYLOAD}    headers=${headers}    cookies=${cookies}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter os dados atualizados da reserva
    Should Contain    ${RESPONSE.headers}[Content-Type]    application/json
    Validar dados da reserva    ${RESPONSE.json()}    ${UPDATED_BOOKING_PAYLOAD}

a reserva deve persistir os dados atualizados no mesmo ID
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    headers=${headers}    expected_status=200
    Should Contain    ${response.headers}[Content-Type]    application/json
    Validar dados da reserva    ${response.json()}    ${UPDATED_BOOKING_PAYLOAD}

a reserva deve manter os dados originais
    a reserva deve estar disponível para consulta com os dados enviados

dados para atualizar somente o nome e sobrenome da reserva
    ${suffix}=    Evaluate    uuid.uuid4().hex    modules=uuid
    ${changes}=    Create Dictionary    firstname=Parcial${suffix}    lastname=Novo${suffix}
    Preparar dados da atualização parcial    ${changes}

dados para atualizar somente o depósito para não pago
    ${changes}=    Create Dictionary    depositpaid=${False}
    Preparar dados da atualização parcial    ${changes}

Preparar dados da atualização parcial
    [Arguments]    ${changes}
    ${expected}=    Copy Dictionary    ${BOOKING_PAYLOAD}    deepcopy=${True}
    Set To Dictionary    ${expected}    &{changes}
    VAR    ${PARTIAL_BOOKING_PAYLOAD}    ${changes}    scope=TEST
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${expected}    scope=TEST

eu atualizar parcialmente a reserva com autenticação válida
    Enviar atualização parcial da reserva    ${CLEANUP_TOKEN}

eu atualizar parcialmente a reserva sem autenticação
    Enviar atualização parcial da reserva

eu atualizar parcialmente a reserva com um token inválido
    ${invalid_token}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Enviar atualização parcial da reserva    invalido${invalid_token}

Enviar atualização parcial da reserva
    [Arguments]    ${token}=${None}
    Should Not Be Equal    ${PARTIAL_BOOKING_PAYLOAD}    ${None}    Prepare os dados da atualização parcial.
    Create Session    booker_partial    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}
    ${headers}=    Create Dictionary    Accept=application/json
    ${cookies}=    Create Dictionary
    IF    $token is not None
        Set To Dictionary    ${cookies}    token=${token}
    END
    ${response}=    PATCH On Session    booker_partial    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    json=${PARTIAL_BOOKING_PAYLOAD}    headers=${headers}    cookies=${cookies}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve refletir a alteração parcial e preservar os demais campos
    a resposta deve conter os dados atualizados da reserva

eu excluir a reserva com autenticação válida
    Enviar exclusão da reserva    ${CLEANUP_TOKEN}

eu excluir a reserva sem autenticação
    Enviar exclusão da reserva

eu excluir a reserva com um token inválido
    ${invalid_token}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Enviar exclusão da reserva    invalido${invalid_token}

Enviar exclusão da reserva
    [Arguments]    ${token}=${None}
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    Prepare uma reserva antes de excluí-la.
    Create Session    booker_delete    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}
    ${cookies}=    Create Dictionary
    IF    $token is not None
        Set To Dictionary    ${cookies}    token=${token}
    END
    ${response}=    DELETE On Session    booker_delete    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}
    ...    cookies=${cookies}    expected_status=any
    VAR    ${RESPONSE}    ${response}    scope=TEST
    IF    ${response.status_code} == 201
        Remove Values From List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}
    END

a reserva excluída não deve estar disponível para consulta
    GET On Session    booker    ${BOOKING_ENDPOINT}/${CREATED_BOOKING_ID}    expected_status=404

Validar dados da reserva
    [Arguments]    ${booking}    ${expected_payload}=${BOOKING_PAYLOAD}
    ${valid_types}=    Evaluate
    ...    isinstance($booking, dict) and isinstance($booking.get('firstname'), str) and isinstance($booking.get('lastname'), str) and type($booking.get('totalprice')) is int and type($booking.get('depositpaid')) is bool and isinstance($booking.get('bookingdates'), dict) and isinstance($booking.get('additionalneeds'), str)
    Should Be True    ${valid_types}    Os campos da reserva devem possuir os tipos esperados.
    Dictionaries Should Be Equal    ${booking}    ${expected_payload}

Limpar reservas da consulta
    Limpar reservas do teste

Limpar reservas do teste
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
