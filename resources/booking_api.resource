*** Settings ***
Documentation    Chamadas HTTP das reservas; retorna respostas sem modificar o estado do teste.
Resource         common.resource

*** Variables ***
${BOOKING_ENDPOINT}    /booking

*** Keywords ***
Enviar criação de reserva
    [Arguments]    ${payload}
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    POST On Session    booker    ${BOOKING_ENDPOINT}
    ...    json=${payload}    headers=${headers}    expected_status=any
    RETURN    ${response}

Enviar consulta de IDs
    [Arguments]    ${filters}=${None}
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}    params=${filters}    expected_status=any
    RETURN    ${response}

Enviar consulta de reserva
    [Arguments]    ${booking_id}
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    GET On Session    booker    ${BOOKING_ENDPOINT}/${booking_id}
    ...    headers=${headers}    expected_status=any
    RETURN    ${response}

Preparar sessão de operação protegida
    [Arguments]    ${alias}    ${token}=${None}    ${basic_auth}=${None}
    Create Session    ${alias}    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}    auth=${basic_auth}
    ${cookies}=    Create Dictionary
    IF    $token is not None
        Set To Dictionary    ${cookies}    token=${token}
    END
    RETURN    ${cookies}

Enviar PUT de reserva
    [Arguments]    ${booking_id}    ${payload}    ${token}=${None}    ${basic_auth}=${None}
    ${cookies}=    Preparar sessão de operação protegida    booker_update    ${token}    ${basic_auth}
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    PUT On Session    booker_update    ${BOOKING_ENDPOINT}/${booking_id}
    ...    json=${payload}    headers=${headers}    cookies=${cookies}    expected_status=any
    RETURN    ${response}

Enviar PATCH de reserva
    [Arguments]    ${booking_id}    ${changes}    ${token}=${None}    ${basic_auth}=${None}
    ${cookies}=    Preparar sessão de operação protegida    booker_partial    ${token}    ${basic_auth}
    ${headers}=    Create Dictionary    Accept=application/json
    ${response}=    PATCH On Session    booker_partial    ${BOOKING_ENDPOINT}/${booking_id}
    ...    json=${changes}    headers=${headers}    cookies=${cookies}    expected_status=any
    RETURN    ${response}

Enviar DELETE de reserva
    [Arguments]    ${booking_id}    ${token}=${None}    ${basic_auth}=${None}
    ${cookies}=    Preparar sessão de operação protegida    booker_delete    ${token}    ${basic_auth}
    ${response}=    DELETE On Session    booker_delete    ${BOOKING_ENDPOINT}/${booking_id}
    ...    cookies=${cookies}    expected_status=any
    RETURN    ${response}

Enviar PUT com JSON malformado
    [Arguments]    ${booking_id}    ${token}
    ${cookies}=    Preparar sessão de operação protegida    booker_update    ${token}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${response}=    PUT On Session    booker_update    ${BOOKING_ENDPOINT}/${booking_id}
    ...    data={"firstname":    headers=${headers}    cookies=${cookies}    expected_status=any
    RETURN    ${response}
