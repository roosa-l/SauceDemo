*** Settings ***
Library    SeleniumLibrary
Library    JSONLibrary
Library    Collections

*** Variables ***
${URL}              https://www.saucedemo.com
${BROWSER}          chrome
${VALID_USER}       standard_user
${VALID_PASSWORD}   secret_sauce
${TOTAL_PRICE}      ${0.0}

# Locators
${SHOPPING_CART}          //a[@class="shopping_cart_link"]
${ERROR_MESSAGE}          //h3[@data-test="error"]
${ADD_TO_CART}            add-to-cart-
${REMOVE}                 //button[text()="Remove"]
${INV_ITEM}               //div[@class="inventory_item_name"]
${INV_PRICE}              //div[@class="inventory_item_price"]
${TOTAL_PRICE_INFO}       //div[@class="summary_subtotal_label"]
${TOTAL_PRICE_WITH_TAX}   //div[@class="summary_info_label summary_total_label"]

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${URL}    ${BROWSER}

Submit Login Credentials
    [Arguments]    ${username}    ${password}
    Input Text    user-name    ${username}
    Input Password    password    ${password}
    Click Element    login-button

Webstore Frontpage Should Be Open
    Location Should Be    ${URL}/inventory.html
    Element should be visible   ${SHOPPING_CART}
    
Open Browser And Login
    Open Browser To Login Page
    Submit Login Credentials    ${VALID_USER}    ${VALID_PASSWORD}

Logout
    Click Element    react-burger-menu-btn
    Wait Until Element Is Enabled    logout_sidebar_link
    Click Element    logout_sidebar_link
    Element Should Be Visible    login-button    

Login Should Fail
    Page Should Contain Element    ${ERROR_MESSAGE}

Add Item To Shopping Cart    
    [Arguments]    ${item}
    ${item_info}=    Retrieve Item Data From JSON file    ${item}
    ${item_selector}=    Get From Dictionary    ${item_info}    selector
    Click Element    ${ADD_TO_CART}${item_selector}

Add Multiple Items To Shopping Cart
    [Arguments]    ${items}
    FOR    ${item}    IN    @{items}
        Add Item To Shopping Cart    ${item}
    END

Check Cart And Price Of Item
    [Documentation]    Checks added items are in cart and the prices match
    ...                the ones in the JSON file. Adds the item price to 
    ...                the ${TOTAL_PRICE} global variable. 
    [Arguments]    ${item}    ${index}=1
    ${item_info}=    Retrieve Item Data From JSON file    ${item}
    ${item_name}=    Get From Dictionary    ${item_info}    name
    ${item_price}=    Get From Dictionary    ${item_info}    price
    Click Element    ${SHOPPING_CART}
    Element Should Contain    (${INV_ITEM})[${index}]    ${item_name}
    Element Should Contain    (${INV_PRICE})[${index}]    ${item_price}
    ${sum}=    Evaluate    ${TOTAL_PRICE} + ${item_price}
    Set Global Variable    ${TOTAL_PRICE}    ${sum}

Check Cart And Price Of Multiple Items
    [Arguments]    ${items}
    ${index}=    Set Variable    1
    FOR    ${item}    IN    @{items}
        Check Cart And Price Of Item    ${item}    ${index}
        ${index}    Evaluate    ${index} + 1
    END
    
Remove Items From Cart
    ${count}=    Get Element Count    ${REMOVE}
    FOR    ${counter}    IN RANGE    0    ${count}
        Click Element    (${REMOVE})[1]
    END
    Page Should Not Contain Element    ${REMOVE}

Check Total Price   
    [Documentation]    Checks the total price of items to be purchased with and without
    ...                tax (8%). Converts the total sum with tax into a float with two decimals.
    ...                Finally resets the ${TOTAL_PRICE} global variable to 0.0.
    Element Should Contain    ${TOTAL_PRICE_INFO}    ${TOTAL_PRICE}
    ${with_tax}    Evaluate    ${TOTAL_PRICE} + ${TOTAL_PRICE} * 0.08
    ${with_tax_converted}    Convert To Number    ${with_tax}    precision=2
    Element Should Contain    ${TOTAL_PRICE_WITH_TAX}    ${with_tax_converted}
    Set Global Variable    ${TOTAL_PRICE}    ${0.0}
    
Fill Buyer Info
    Click Element    checkout
    Input Text       first-name     John
    Input Text       last-name      Doe
    Input Text       postal-code    100100
    Click Element    continue

Finish Purchase
    Click Element    finish
    Click Element    back-to-products

Retrieve Item Data From JSON file
    [Arguments]    ${item}
    ${json_obj}=    Load Json From File    items.json
    ${item_as_list}=    Get Value From Json    ${json_obj}    $.${item}
    ${item_as_dict}=    Set Variable    ${item_as_list}[0]
    RETURN    ${item_as_dict}