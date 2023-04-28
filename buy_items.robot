*** Settings ***
Resource          resource.robot
Suite Setup       Open Browser And Login
Suite Teardown    Run Keywords
...               Logout
...               Close Browser

*** Test Cases ***
Verify Buying One Item Succeeds
    Set Local Variable    ${item}    backpack
    Add Item To Shopping Cart    ${item}
    Check Cart And Price Of Item    ${item}
    Fill Buyer Info
    Check Total Price
    Finish Purchase

Verify Buying Multiple Items Succeeds
    @{items}=    Create List    backpack  onesie  shirt
    Add Multiple Items To Shopping Cart   ${items}
    Check Cart And Price Of Multiple Items    ${items}
    Fill Buyer Info
    Check Total Price
    Finish Purchase
    