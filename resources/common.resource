*** Settings ***
Documentation    Configuração compartilhada da conexão HTTP.
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://restful-booker.herokuapp.com
${TIMEOUT}     30

*** Keywords ***
Conectar à API
    Create Session    booker    ${BASE_URL}    verify=${True}    timeout=${TIMEOUT}
