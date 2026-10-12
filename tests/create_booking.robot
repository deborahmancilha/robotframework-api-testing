Language: pt

*** Settings ***
Documentation       Cenários positivos, negativos e limites da operação CreateBooking em JSON.
Resource            ../resources/booking.resource
Test Setup          Preparar criação de reserva
Test Teardown       Limpar reservas do teste

*** Test Cases ***
CT18 - API deve criar uma reserva com dados válidos
    [Documentation]    Valida status, ID, dados retornados e persistência de uma reserva completa.
    [Tags]    smoke    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT19 - API deve criar uma reserva com depósito não pago
    [Documentation]    Valida que depositpaid false é preservado na criação e na consulta.
    [Tags]    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    E o depósito da reserva não foi pago
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT20 - API deve preservar acentos e apóstrofo nos nomes da reserva
    [Documentation]    Valida a preservação dos nomes com acentos e apóstrofo no retorno e na persistência.
    [Tags]    booking    create_booking

    Dado que possuo dados válidos para criar uma reserva
    E os nomes da reserva contêm acentos e apóstrofo
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT21 - API deve rejeitar criação sem o campo obrigatório firstname
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    firstname
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT22 - API deve rejeitar criação sem o campo obrigatório lastname
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    lastname
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT23 - API deve rejeitar criação sem o campo obrigatório totalprice
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    totalprice
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT24 - API deve rejeitar criação sem o campo obrigatório depositpaid
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    depositpaid
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT25 - API deve rejeitar criação sem o campo obrigatório bookingdates.checkin
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    bookingdates.checkin
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT26 - API deve rejeitar criação sem o campo obrigatório bookingdates.checkout
    [Documentation]    Verifica a rejeição sem ID; um status 5xx não representa tratamento adequado de entrada inválida.
    [Tags]    booking    create_booking    negative    required

    Dado que possuo dados válidos para criar uma reserva
    E o campo obrigatório da reserva foi omitido    bookingdates.checkout
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT27 - API deve rejeitar criação com primeiro nome numérico
    [Documentation]    Verifica rejeição de tipo incompatível com o contrato da API.
    [Tags]    booking    create_booking    negative    contract

    Dado que possuo dados válidos para criar uma reserva
    E o campo da reserva possui valor inválido    firstname    ${123}
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT28 - API deve rejeitar criação com preço não numérico
    [Documentation]    Verifica rejeição de tipo incompatível com o contrato da API.
    [Tags]    booking    create_booking    negative    contract    known_bug

    Dado que possuo dados válidos para criar uma reserva
    E o campo da reserva possui valor inválido    totalprice    caro
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT29 - API deve rejeitar criação com depósito como texto
    [Documentation]    Verifica rejeição de tipo incompatível com o contrato da API.
    [Tags]    booking    create_booking    negative    contract    known_bug

    Dado que possuo dados válidos para criar uma reserva
    E o campo da reserva possui valor inválido    depositpaid    false
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT30 - API deve rejeitar criação com datas como texto
    [Documentation]    Verifica rejeição de tipo incompatível com o contrato da API.
    [Tags]    booking    create_booking    negative    contract

    Dado que possuo dados válidos para criar uma reserva
    E o campo da reserva possui valor inválido    bookingdates    datas_invalidas
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT31 - API deve rejeitar criação com nomes vazios
    [Documentation]    Verifica entrada inválida; datas invertidas representam uma expectativa de domínio adotada pelo projeto.
    [Tags]    booking    create_booking    negative    boundary    contract    known_bug

    Dado que possuo dados válidos para criar uma reserva
    E os nomes da reserva estão vazios
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT32 - API deve rejeitar criação com nomes com somente espaços
    [Documentation]    Verifica entrada inválida; datas invertidas representam uma expectativa de domínio adotada pelo projeto.
    [Tags]    booking    create_booking    negative    boundary    contract    known_bug

    Dado que possuo dados válidos para criar uma reserva
    E os nomes da reserva contêm somente espaços
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT33 - API deve rejeitar criação com datas invertidas
    [Documentation]    Verifica entrada inválida; datas invertidas representam uma expectativa de domínio adotada pelo projeto.
    [Tags]    booking    create_booking    negative    boundary    contract    known_bug

    Dado que possuo dados válidos para criar uma reserva
    E as datas da reserva estão em ordem invertida
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve rejeitar os dados inválidos da reserva
    E a criação rejeitada não deve retornar um ID de reserva

CT34 - API deve criar uma reserva com preço zero
    [Documentation]    Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado.
    [Tags]    booking    create_booking    boundary

    Dado que possuo dados válidos para criar uma reserva
    E o preço da reserva foi definido como    ${0}
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT35 - API deve preservar um preço inteiro elevado
    [Documentation]    Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado.
    [Tags]    booking    create_booking    boundary

    Dado que possuo dados válidos para criar uma reserva
    E o preço da reserva foi definido como    ${2147483647}
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados

CT36 - API deve criar uma reserva com entrada e saída no mesmo dia
    [Documentation]    Caracteriza um limite de dados aceito pelo serviço, sem presumir um máximo documentado.
    [Tags]    booking    create_booking    boundary

    Dado que possuo dados válidos para criar uma reserva
    E as datas da reserva representam o mesmo dia
    Quando eu enviar uma requisição para o endpoint de criação de reserva
    Então a API deve retornar o status    200
    E a resposta deve conter o ID e os dados da reserva criada
    E a reserva deve estar disponível para consulta com os dados enviados
