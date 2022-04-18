
![alt text](https://i.ibb.co/HBPZ9Nd/Rufaydium.jpg)
# Rufaydium-Webdriver
Rufaydium is Webdriver Library for Autohotket, can support any chromium based browser and only requires Latest WebDriver,

i.e. for Chrome 100 you need to download ChromeDriver 100.0.4896.60
from https://chromedriver.chromium.org/downloads

It utilizes Rest Api of W3C from https://www.w3.org/TR/webdriver2/
Rufadium also supports Chrome Devtools Protocols same as chrome.ahk

# Note: 
No need to install / setup selenium, Rufaydium is AHK's Selenium,
even Selenium 4 have not been implement with latest W3C Webdriver methods for many languages,
I am not user of Selenium therefore, I am not sure if Rufaydium has more functionality compare to selenium
but I am sure Rufaydium is more flexible than selenium


```AutoHotkey
#Include Rufaydium.ahk
; Just need Webdriver Executable llocation 
ChromeDriver := A_ScriptDir "\chromedriver.exe"
; choose different driver in order to automate different Browser
Driver := new RunDriver(ChromeDriver) ; running driver
Chrome := new Rufaydium(Driver) ; this will return control over Browser

; choosing Browser Capabilities, by using Capabilities you can make custom profile for specific need
; Chrome.capabilities := Capabilities.ChromeDefault 

; this is how we create session 
Page := Chrome.NewSession()
Page.Navigate("https://www.google.com/")
Page := ""
return
```
