*** Settings ***
Resource         resource.robot
Suite Setup      Open Browser To Login Page
Suite Teardown   Close Browser

*** Test Cases ***
Verify Valid Login And Logout
    Submit Login Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Webstore Frontpage Should Be Open
    Logout
