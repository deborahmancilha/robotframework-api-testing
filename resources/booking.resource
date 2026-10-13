*** Settings ***
Documentation    Keywords BDD e coordenação do estado, preparação e limpeza das reservas.
Resource         auth.resource
Resource         booking_data.resource
Resource         booking_api.resource
Resource         booking_validations.resource

*** Variables ***
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
${DATE_FILTER_FIELD}    ${None}
${DATE_FILTER_VALUE}    2026-11-10

*** Keywords ***
Preparar consulta de reservas
    que possuo acesso à API Restful Booker
    VAR    @{CREATED_BOOKING_IDS}    scope=TEST
    VAR    @{EXPECTED_BOOKING_IDS}    scope=TEST
    VAR    ${CLEANUP_TOKEN}    ${None}    scope=TEST

que possuo reservas próprias para consultar
    ${suffix}=    Gerar identificador de dados
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
    ${response}=    Enviar requisição de token    ${credentials}
    Validar status da resposta    ${response}    200
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    token
    Should Not Be Empty    ${body}[token]
    VAR    ${CLEANUP_TOKEN}    ${body}[token]    scope=TEST

Criar reserva para consulta
    [Arguments]    ${lastname}    ${firstname}=${BOOKING_FIRSTNAME}
    ${payload}=    Montar dados de reserva    ${firstname}    ${lastname}
    ${response}=    Enviar criação de reserva    ${payload}
    Validar status da resposta    ${response}    200
    ${body}=    Set Variable    ${response.json()}
    ${booking_id}=    Extrair ID da criação    ${body}
    Append To List    ${CREATED_BOOKING_IDS}    ${booking_id}

eu consultar os IDs de reservas sem filtros
    Consultar IDs de reservas

eu consultar os IDs de reservas pelo primeiro nome
    ${filters}=    Montar filtros de reservas    firstname=${BOOKING_FIRSTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    ${CREATED_BOOKING_IDS}[1]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas pelo sobrenome
    ${filters}=    Montar filtros de reservas    lastname=${BOOKING_LASTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    ${CREATED_BOOKING_IDS}[2]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas pelo nome e sobrenome
    ${filters}=    Montar filtros de reservas    firstname=${BOOKING_FIRSTNAME}    lastname=${BOOKING_LASTNAME}
    VAR    @{EXPECTED_BOOKING_IDS}    ${CREATED_BOOKING_IDS}[0]    scope=TEST
    Consultar IDs de reservas    ${filters}

eu consultar os IDs de reservas por um nome sem correspondência
    ${filters}=    Montar filtros de reservas    firstname=${BOOKING_MISSING_NAME}
    Consultar IDs de reservas    ${filters}

Consultar IDs de reservas
    [Arguments]    ${filters}=${None}
    ${response}=    Enviar consulta de IDs    ${filters}
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter uma lista de IDs de reservas em JSON
    Extrair IDs da resposta    ${RESPONSE}

a resposta deve conter somente os IDs esperados para o filtro
    Validar IDs esperados    ${RESPONSE}    ${EXPECTED_BOOKING_IDS}

a resposta deve conter uma lista vazia
    Validar listagem vazia    ${RESPONSE}

Preparar criação de reserva
    Preparar consulta de reservas
    VAR    ${BOOKING_PAYLOAD}    ${None}    scope=TEST
    VAR    ${CREATED_BOOKING_ID}    ${None}    scope=TEST
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${None}    scope=TEST
    VAR    ${PARTIAL_BOOKING_PAYLOAD}    ${None}    scope=TEST
    Obter token para limpeza de reservas

que possuo dados válidos para criar uma reserva
    ${suffix}=    Gerar identificador de dados
    ${payload}=    Montar dados de reserva    QA${suffix}    Titular${suffix}    additional_needs=Breakfast
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

o depósito da reserva não foi pago
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    depositpaid=${False}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

os nomes da reserva contêm acentos e apóstrofo
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}
    ...    firstname=Débora${BOOKING_PAYLOAD}[firstname]    lastname=D'Ávila
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

eu enviar uma requisição para o endpoint de criação de reserva
    Should Not Be Equal    ${BOOKING_PAYLOAD}    ${None}    Prepare os dados antes de criar a reserva.
    ${response}=    Enviar criação de reserva    ${BOOKING_PAYLOAD}
    VAR    ${RESPONSE}    ${response}    scope=TEST
    Registrar reserva para limpeza    ${response}    ${BOOKING_PAYLOAD}

a resposta deve conter o ID e os dados da reserva criada
    Validar resposta de criação    ${RESPONSE}    ${BOOKING_PAYLOAD}

a reserva deve estar disponível para consulta com os dados enviados
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    A criação deve retornar um ID para consulta.
    ${response}=    Enviar consulta de reserva    ${CREATED_BOOKING_ID}
    Validar status da resposta    ${response}    200
    Validar resposta de reserva    ${response}    ${BOOKING_PAYLOAD}

que possuo uma reserva própria cadastrada
    que possuo dados válidos para criar uma reserva
    eu enviar uma requisição para o endpoint de criação de reserva
    a API deve retornar o status    200
    a resposta deve conter o ID e os dados da reserva criada

a reserva cadastrada foi excluída
    ${response}=    Enviar DELETE de reserva    ${CREATED_BOOKING_ID}    ${CLEANUP_TOKEN}
    Validar status da resposta    ${response}    201
    Remove Values From List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}

eu consultar a reserva pelo ID
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    Prepare uma reserva antes de consultar seu ID.
    ${response}=    Enviar consulta de reserva    ${CREATED_BOOKING_ID}
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter os dados da reserva cadastrada
    Validar resposta de reserva    ${RESPONSE}    ${BOOKING_PAYLOAD}

dados válidos para atualizar todos os campos da reserva
    ${suffix}=    Gerar identificador de dados
    ${payload}=    Montar dados de reserva    Atualizada${suffix}    Novo${suffix}
    ...    2026-12-15    2026-12-18    price=${275}    deposit_paid=${False}    additional_needs=Dinner
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${payload}    scope=TEST

eu atualizar a reserva com autenticação válida
    Enviar atualização completa da reserva    ${CLEANUP_TOKEN}

eu atualizar a reserva sem autenticação
    Enviar atualização completa da reserva

eu atualizar a reserva com um token inválido
    ${invalid_token}=    Gerar identificador de dados
    Enviar atualização completa da reserva    invalido${invalid_token}

Enviar atualização completa da reserva
    [Arguments]    ${token}=${None}    ${basic_auth}=${None}
    Should Not Be Equal    ${UPDATED_BOOKING_PAYLOAD}    ${None}    Prepare os dados da atualização.
    ${response}=    Enviar PUT de reserva    ${CREATED_BOOKING_ID}    ${UPDATED_BOOKING_PAYLOAD}    ${token}    ${basic_auth}
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve conter os dados atualizados da reserva
    Validar resposta de reserva    ${RESPONSE}    ${UPDATED_BOOKING_PAYLOAD}

a reserva deve persistir os dados atualizados no mesmo ID
    ${response}=    Enviar consulta de reserva    ${CREATED_BOOKING_ID}
    Validar status da resposta    ${response}    200
    Validar resposta de reserva    ${response}    ${UPDATED_BOOKING_PAYLOAD}

a reserva deve manter os dados originais
    a reserva deve estar disponível para consulta com os dados enviados

dados para atualizar somente o nome e sobrenome da reserva
    ${suffix}=    Gerar identificador de dados
    ${changes}=    Montar alterações de reserva    firstname=Parcial${suffix}    lastname=Novo${suffix}
    Preparar dados da atualização parcial    ${changes}

dados para atualizar somente o depósito para não pago
    ${changes}=    Montar alterações de reserva    depositpaid=${False}
    Preparar dados da atualização parcial    ${changes}

Preparar dados da atualização parcial
    [Arguments]    ${changes}
    ${expected}=    Montar resultado da alteração parcial    ${BOOKING_PAYLOAD}    ${changes}
    VAR    ${PARTIAL_BOOKING_PAYLOAD}    ${changes}    scope=TEST
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${expected}    scope=TEST

eu atualizar parcialmente a reserva com autenticação válida
    Enviar atualização parcial da reserva    ${CLEANUP_TOKEN}

eu atualizar parcialmente a reserva sem autenticação
    Enviar atualização parcial da reserva

eu atualizar parcialmente a reserva com um token inválido
    ${invalid_token}=    Gerar identificador de dados
    Enviar atualização parcial da reserva    invalido${invalid_token}

Enviar atualização parcial da reserva
    [Arguments]    ${token}=${None}    ${basic_auth}=${None}
    Should Not Be Equal    ${PARTIAL_BOOKING_PAYLOAD}    ${None}    Prepare os dados da atualização parcial.
    ${response}=    Enviar PATCH de reserva    ${CREATED_BOOKING_ID}    ${PARTIAL_BOOKING_PAYLOAD}    ${token}    ${basic_auth}
    VAR    ${RESPONSE}    ${response}    scope=TEST

a resposta deve refletir a alteração parcial e preservar os demais campos
    a resposta deve conter os dados atualizados da reserva

eu excluir a reserva com autenticação válida
    Enviar exclusão da reserva    ${CLEANUP_TOKEN}

eu excluir a reserva sem autenticação
    Enviar exclusão da reserva

eu excluir a reserva com um token inválido
    ${invalid_token}=    Gerar identificador de dados
    Enviar exclusão da reserva    invalido${invalid_token}

Enviar exclusão da reserva
    [Arguments]    ${token}=${None}    ${basic_auth}=${None}
    Should Not Be Equal    ${CREATED_BOOKING_ID}    ${None}    Prepare uma reserva antes de excluí-la.
    ${response}=    Enviar DELETE de reserva    ${CREATED_BOOKING_ID}    ${token}    ${basic_auth}
    VAR    ${RESPONSE}    ${response}    scope=TEST
    IF    ${response.status_code} == 201
        Remove Values From List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}
    END

a reserva excluída não deve estar disponível para consulta
    ${response}=    Enviar consulta de reserva    ${CREATED_BOOKING_ID}
    Validar status da resposta    ${response}    404

que possuo reservas próprias antes, no limite e depois da data de filtro
    [Arguments]    ${field}
    ${suffix}=    Gerar identificador de dados
    VAR    ${BOOKING_FIRSTNAME}    Datas${suffix}    scope=TEST
    VAR    ${DATE_FILTER_FIELD}    ${field}    scope=TEST
    Obter token para limpeza de reservas
    FOR    ${day}    IN    2026-11-09    2026-11-10    2026-11-11
        ${payload}=    Montar dados para filtro de data    ${BOOKING_FIRSTNAME}    ${field}    ${day}
        ${response}=    Enviar criação de reserva    ${payload}
        Validar status da resposta    ${response}    200
        ${body}=    Set Variable    ${response.json()}
        ${booking_id}=    Extrair ID da criação    ${body}
        Append To List    ${CREATED_BOOKING_IDS}    ${booking_id}
    END

eu consultar os IDs por data posterior ao limite
    ${filters}=    Montar filtros de reservas    firstname=${BOOKING_FIRSTNAME}
    ...    ${DATE_FILTER_FIELD}=${DATE_FILTER_VALUE}
    Consultar IDs de reservas    ${filters}

a resposta deve incluir as reservas posteriores e excluir as anteriores ao limite
    Validar direção do filtro de data    ${RESPONSE}    ${CREATED_BOOKING_IDS}

a resposta deve incluir a reserva exatamente na data limite
    Validar inclusão da data limite    ${RESPONSE}    ${CREATED_BOOKING_IDS}

o campo obrigatório da reserva foi omitido
    [Arguments]    ${field}
    ${payload}=    Copiar reserva sem campo    ${BOOKING_PAYLOAD}    ${field}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

o campo da reserva possui valor inválido
    [Arguments]    ${field}    ${value}
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    ${field}=${value}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

o preço da reserva foi definido como
    [Arguments]    ${price}
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    totalprice=${price}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

os nomes da reserva estão vazios
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    firstname=${EMPTY}    lastname=${EMPTY}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

os nomes da reserva contêm somente espaços
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    firstname=${SPACE}${SPACE}    lastname=${SPACE}${SPACE}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

as datas da reserva estão em ordem invertida
    ${dates}=    Montar datas da reserva    2026-11-12    2026-11-10
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    bookingdates=${dates}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

as datas da reserva representam o mesmo dia
    ${dates}=    Montar datas da reserva    2026-11-10    2026-11-10
    ${payload}=    Copiar reserva com alterações    ${BOOKING_PAYLOAD}    bookingdates=${dates}
    VAR    ${BOOKING_PAYLOAD}    ${payload}    scope=TEST

a API deve rejeitar os dados inválidos da reserva
    Validar rejeição controlada da criação    ${RESPONSE}

a API deve apresentar o erro interno observado na criação
    a API deve retornar o status    500

a criação rejeitada não deve retornar um ID de reserva
    Validar ausência de reserva criada    ${CREATED_BOOKING_ID}    ${CREATED_BOOKING_IDS}

eu atualizar a reserva com JSON malformado e autenticação válida
    ${response}=    Enviar PUT com JSON malformado    ${CREATED_BOOKING_ID}    ${CLEANUP_TOKEN}
    VAR    ${RESPONSE}    ${response}    scope=TEST

o corpo da atualização omite um campo obrigatório
    [Arguments]    ${field}
    ${payload}=    Copiar reserva sem campo    ${UPDATED_BOOKING_PAYLOAD}    ${field}
    VAR    ${UPDATED_BOOKING_PAYLOAD}    ${payload}    scope=TEST

dados para atualizar somente o preço da reserva
    ${changes}=    Montar alterações de reserva    totalprice=${275}
    Preparar dados da atualização parcial    ${changes}

dados para atualizar somente as necessidades adicionais da reserva
    ${changes}=    Montar alterações de reserva    additionalneeds=Dinner
    Preparar dados da atualização parcial    ${changes}

dados para atualizar somente as datas da reserva
    ${dates}=    Montar datas da reserva    2026-12-15    2026-12-18
    ${changes}=    Montar alterações de reserva    bookingdates=${dates}
    Preparar dados da atualização parcial    ${changes}

dados para atualizar somente a data de entrada da reserva
    ${dates}=    Montar alterações de reserva    checkin=2026-11-11
    ${changes}=    Montar alterações de reserva    bookingdates=${dates}
    Preparar dados da atualização parcial    ${changes}

eu atualizar a reserva com Basic Auth válida
    ${credentials}=    Create List    ${AUTH_USERNAME}    ${AUTH_PASSWORD}
    Enviar atualização completa da reserva    basic_auth=${credentials}

eu atualizar a reserva com Basic Auth inválida
    ${credentials}=    Create List    ${AUTH_USERNAME}    senha_incorreta
    Enviar atualização completa da reserva    basic_auth=${credentials}

eu atualizar parcialmente a reserva com Basic Auth válida
    ${credentials}=    Create List    ${AUTH_USERNAME}    ${AUTH_PASSWORD}
    Enviar atualização parcial da reserva    basic_auth=${credentials}

eu atualizar parcialmente a reserva com Basic Auth inválida
    ${credentials}=    Create List    ${AUTH_USERNAME}    senha_incorreta
    Enviar atualização parcial da reserva    basic_auth=${credentials}

eu excluir a reserva com Basic Auth válida
    ${credentials}=    Create List    ${AUTH_USERNAME}    ${AUTH_PASSWORD}
    Enviar exclusão da reserva    basic_auth=${credentials}

eu excluir a reserva com Basic Auth inválida
    ${credentials}=    Create List    ${AUTH_USERNAME}    senha_incorreta
    Enviar exclusão da reserva    basic_auth=${credentials}

Limpar reservas da consulta
    Limpar reservas do teste

Limpar reservas do teste
    TRY
        FOR    ${booking_id}    IN    @{CREATED_BOOKING_IDS}
            Run Keyword And Continue On Failure    Excluir reserva da limpeza    ${booking_id}
        END
    FINALLY
        Delete All Sessions
    END

Excluir reserva da limpeza
    [Arguments]    ${booking_id}
    ${response}=    Enviar DELETE de reserva    ${booking_id}    ${CLEANUP_TOKEN}
    Validar status da resposta    ${response}    201

Registrar reserva para limpeza
    [Arguments]    ${response}    ${payload}
    TRY
        ${body}=    Set Variable    ${response.json()}
    EXCEPT
        VAR    ${body}    ${None}
    END
    ${has_id}=    Evaluate    isinstance($body, dict) and type($body.get('bookingid')) is int
    IF    ${has_id}
        VAR    ${CREATED_BOOKING_ID}    ${body}[bookingid]    scope=TEST
        Append To List    ${CREATED_BOOKING_IDS}    ${CREATED_BOOKING_ID}
    ELSE
        # Uma resposta de criação inválida pode não trazer o ID; o nome UUID permite limpeza segura.
        ${can_search}=    Evaluate    isinstance($payload.get('firstname'), str) and $payload['firstname'].startswith('QA') and len($payload['firstname']) >= 34
        IF    ${can_search}
            ${filters}=    Montar filtros de reservas    firstname=${payload}[firstname]
            ${lookup}=    Enviar consulta de IDs    ${filters}
            Validar status da resposta    ${lookup}    200
            FOR    ${item}    IN    @{lookup.json()}
                Append To List    ${CREATED_BOOKING_IDS}    ${item}[bookingid]
            END
        END
    END
