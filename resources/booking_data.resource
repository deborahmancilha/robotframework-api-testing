*** Settings ***
Documentation    Montagem de dados de reservas e filtros; recebe argumentos e retorna dicionários.
Resource         common.resource

*** Keywords ***
Gerar identificador de dados
    ${identifier}=    Evaluate    uuid.uuid4().hex    modules=uuid
    RETURN    ${identifier}

Montar dados de reserva
    [Arguments]    ${firstname}    ${lastname}    ${checkin}=2026-11-10    ${checkout}=2026-11-12
    ...    ${price}=${150}    ${deposit_paid}=${True}    ${additional_needs}=${None}
    ${dates}=    Montar datas da reserva    ${checkin}    ${checkout}
    ${payload}=    Create Dictionary    firstname=${firstname}    lastname=${lastname}
    ...    totalprice=${price}    depositpaid=${deposit_paid}    bookingdates=${dates}
    IF    $additional_needs is not None
        Set To Dictionary    ${payload}    additionalneeds=${additional_needs}
    END
    RETURN    ${payload}

Montar datas da reserva
    [Arguments]    ${checkin}    ${checkout}
    ${dates}=    Create Dictionary    checkin=${checkin}    checkout=${checkout}
    RETURN    ${dates}

Montar filtros de reservas
    [Arguments]    &{fields}
    RETURN    ${fields}

Montar alterações de reserva
    [Arguments]    &{fields}
    RETURN    ${fields}

Copiar reserva com alterações
    [Arguments]    ${original}    &{changes}
    ${payload}=    Copy Dictionary    ${original}    deepcopy=${True}
    Set To Dictionary    ${payload}    &{changes}
    RETURN    ${payload}

Copiar reserva sem campo
    [Arguments]    ${original}    ${field}
    ${payload}=    Copy Dictionary    ${original}    deepcopy=${True}
    IF    '.' in $field
        ${key}=    Evaluate    $field.split('.')[1]
        Remove From Dictionary    ${payload}[bookingdates]    ${key}
    ELSE
        Remove From Dictionary    ${payload}    ${field}
    END
    RETURN    ${payload}

Montar resultado da alteração parcial
    [Arguments]    ${original}    ${changes}
    ${expected}=    Copiar reserva com alterações    ${original}    &{changes}
    IF    'bookingdates' in $changes
        ${dates}=    Copy Dictionary    ${original}[bookingdates]
        Set To Dictionary    ${dates}    &{changes}[bookingdates]
        Set To Dictionary    ${expected}    bookingdates=${dates}
    END
    RETURN    ${expected}

Montar dados para filtro de data
    [Arguments]    ${firstname}    ${field}    ${day}
    IF    $field == 'checkout'
        ${payload}=    Montar dados de reserva    ${firstname}    Filtro    2026-11-01    ${day}
    ELSE
        ${payload}=    Montar dados de reserva    ${firstname}    Filtro    ${day}    2026-11-15
    END
    RETURN    ${payload}
