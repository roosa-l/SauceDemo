*** Settings ***
Documentation    Simple data-driven test to verify login with
...              invalid credentials doesn't succeed.
...              Retrieves test data from separate Excel-file.
Library          DataDriver    file=invalid_credentials.xlsx
Resource         resource.robot
Suite Setup      Open Browser To Login Page
Suite Teardown   Close Browser
Test Template    Invalid Logins


*** Test Cases ***
Verify Login With Invalid Credentials Fails


*** Keywords ***
Invalid Logins
    [Arguments]    ${username}    ${password}
    Submit Login Credentials    ${username}    ${password}
    Login Should Fail
    [Teardown]    Reload Page