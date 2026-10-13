*** Settings ***
Documentation    Assertions das respostas e dados de reservas, com mensagens por campo.
Resource         common.resource

*** Keywords ***
Ler corpo JSON da resposta
    [Arguments]    ${response}
    Should Not Be Equal    ${response}    ${None}    Envie uma requisição antes de validar a resposta.
    Should Contain    ${response.headers}[Content-Type]    application/json
    ${body}=    Set Variable    ${response.json()}
    RETURN    ${body}

Validar objeto JSON
    [Arguments]    ${value}    ${label}=resposta
    ${is_dictionary}=    Evaluate    isinstance($value, dict)
    Should Be True    ${is_dictionary}    O campo ${label} deve ser um objeto JSON.

Validar tipo de campo
    [Arguments]    ${mapping}    ${key}    ${expected_type}    ${label}=${key}
    Dictionary Should Contain Key    ${mapping}    ${key}    O campo ${label} deve existir.
    ${actual_type}=    Evaluate    type($mapping[$key]).__name__
    IF    $expected_type == 'dict'
        ${matches}=    Evaluate    isinstance($mapping[$key], dict)
    ELSE IF    $expected_type == 'str'
        ${matches}=    Evaluate    isinstance($mapping[$key], str)
    ELSE
        ${matches}=    Evaluate    type($mapping[$key]).__name__ == $expected_type
    END
    Should Be True    ${matches}
    ...    O campo ${label} deve ser ${expected_type}; recebido ${actual_type}.

Validar dados completos da reserva
    [Arguments]    ${booking}    ${expected_payload}
    Validar objeto JSON    ${booking}    booking
    Validar tipo de campo    ${booking}    firstname    str
    Validar tipo de campo    ${booking}    lastname    str
    Validar tipo de campo    ${booking}    totalprice    int
    Validar tipo de campo    ${booking}    depositpaid    bool
    Validar tipo de campo    ${booking}    bookingdates    dict
    Validar tipo de campo    ${booking}[bookingdates]    checkin    str    bookingdates.checkin
    Validar tipo de campo    ${booking}[bookingdates]    checkout    str    bookingdates.checkout
    Validar tipo de campo    ${booking}    additionalneeds    str
    Dictionaries Should Be Equal    ${booking}    ${expected_payload}

Extrair ID da criação
    [Arguments]    ${body}
    Validar objeto JSON    ${body}
    Validar tipo de campo    ${body}    bookingid    int
    RETURN    ${body}[bookingid]

Validar resposta de criação
    [Arguments]    ${response}    ${expected_payload}
    ${body}=    Ler corpo JSON da resposta    ${response}
    Extrair ID da criação    ${body}
    Dictionary Should Contain Key    ${body}    booking
    Validar dados completos da reserva    ${body}[booking]    ${expected_payload}

Validar resposta de reserva
    [Arguments]    ${response}    ${expected_payload}
    ${body}=    Ler corpo JSON da resposta    ${response}
    Validar dados completos da reserva    ${body}    ${expected_payload}

Extrair IDs da resposta
    [Arguments]    ${response}
    ${body}=    Ler corpo JSON da resposta    ${response}
    ${is_list}=    Evaluate    isinstance($body, list)
    Should Be True    ${is_list}    A resposta deve ser uma lista JSON.
    ${ids}=    Create List
    FOR    ${item}    IN    @{body}
        Validar objeto JSON    ${item}    item da lista
        Validar tipo de campo    ${item}    bookingid    int
        Append To List    ${ids}    ${item}[bookingid]
    END
    List Should Not Contain Duplicates    ${ids}
    RETURN    ${ids}

Validar IDs esperados
    [Arguments]    ${response}    ${expected_ids}
    ${ids}=    Extrair IDs da resposta    ${response}
    Lists Should Be Equal    ${ids}    ${expected_ids}    ignore_order=${True}

Validar listagem vazia
    [Arguments]    ${response}
    ${ids}=    Extrair IDs da resposta    ${response}
    Should Be Empty    ${ids}    A busca sem correspondência deve retornar uma lista vazia.

Validar direção do filtro de data
    [Arguments]    ${response}    ${created_ids}
    ${ids}=    Extrair IDs da resposta    ${response}
    List Should Contain Value    ${ids}    ${created_ids}[2]
    List Should Not Contain Value    ${ids}    ${created_ids}[0]

Validar inclusão da data limite
    [Arguments]    ${response}    ${created_ids}
    ${ids}=    Extrair IDs da resposta    ${response}
    List Should Contain Value    ${ids}    ${created_ids}[1]

Validar rejeição controlada da criação
    [Arguments]    ${response}
    # Critério do projeto; não se aceita HTTP 500 como validação correta.
    ${rejected}=    Evaluate    $response.status_code in (400, 422)
    Run Keyword And Continue On Failure    Should Be True    ${rejected}
    ...    Esperado erro controlado de validação (400/422, critério do projeto), recebido HTTP ${response.status_code}. HTTP 500 não comprova validação correta.

Validar ausência de reserva criada
    [Arguments]    ${created_id}    ${created_ids}
    Should Be Equal    ${created_id}    ${None}    A requisição inválida criou uma reserva.
    Should Be Empty    ${created_ids}    A requisição inválida persistiu uma reserva.
