
![alt text](https://i.ibb.co/HBPZ9Nd/Rufaydium.jpg)
## Rufaydium
Rufaydium is Webdriver Library for Autohotket, can support any chromium based browser and only requires Latest WebDriver,

i.e. for Chrome 100 you need to download ChromeDriver 100.0.4896.60
from https://chromedriver.chromium.org/downloads

It utilizes Rest Api of W3C from https://www.w3.org/TR/webdriver2/
Rufadium also supports Chrome Devtools Protocols same as chrome.ahk

## Note: 
No need to install / setup selenium, Rufaydium is AHK's Selenium,
even Selenium 4 have not been implement with latest W3C Webdriver methods for many languages,
I am not user of Selenium therefore, I am not sure if Rufaydium has more functionality compare to selenium
but I am sure Rufaydium is more flexible than selenium


## How to use
```AutoHotkey
# Include Rufaydium.ahk
; Just need Webdriver Executable llocation 
ChromeDriver := A_ScriptDir "\chromedriver.exe"
; choose different driver in order to automate different Browser
Driver := new RunDriver(ChromeDriver) ; running driver
Chrome := new Rufaydium(Driver) ; this will return control over Browser

; choosing Browser Capabilities, by using Capabilities Class you can make custom profile for specific need
; Chrome.capabilities := Capabilities.ChromeDefault 

; this is how we create session 
Page := Chrome.NewSession()
Page.Navigate("https://www.google.com/")
Page := ""
return
```

# Capabilities Class
Following class can be used to make required capabilities Custom profile for specific need that support concerned Webdriver. 
capabilities.ChromeDefault is just Custom profile that will help run chrome with no inforbar alert which says "chrome is being controlled by blah blah blah",
capabilities.Headless made for PDFprinting Session.print 
capabilities.ChromeProfile explains how to use chrome cmd switches aka "args"
capabilities.Simple should work with any chromium webdriver
```AutoHotkey
class capabilities
{
	static ChromeDefault =
	( LTrim Join
	{
	"capabilities": {
		"alwaysMatch": {
			"browserName": "chrome",
			"platformName": "windows",
			"goog:chromeOptions": {
				"w3c": json.true,
				"excludeSwitches": ["enable-automation"]
			}
		},
		"firstMatch": [{}]
		},
	"desiredCapabilities": {
		"browserName": "chrome"
		}
	}
	)
	; --user-data-dir example &  args links https://peter.sh/experiments/chromium-command-line-switches/
	static headless =
	( LTrim Join
	{
	"capabilities": {
		"alwaysMatch": {
			"browserName": "chrome",
			"platformName": "windows",
			"goog:chromeOptions": {
				"w3c": json.true,
				"args": ["--headless"],
				"excludeSwitches": ["enable-automation"]
			}
		},
		"firstMatch": [{}]
		},
	"desiredCapabilities": {
		"browserName": "chrome"
		}
	}
	)
	static ChromeProfile =
	( LTrim Join
	{
	"capabilities": {
		"alwaysMatch": {
			"browserName": "chrome",
			"goog:chromeOptions": {
				"w3c": json.true,
				"args": ["--user-data-dir=C:/ChromeProfile"],
				"excludeSwitches": ["enable-automation"]
			}
		},
		"firstMatch": [{}]
		},
	"desiredCapabilities": {
		"browserName": "chrome"
		}
	}
	)
	static Simple := {"capabilities":{"":""}}
	static ChromeSimple := {"capabilities":{"alwaysMatch":{"browserName":"chrome"}}}
}
```
# Script reloading
we can reload script as many time as we want but driver will be active in process so we can have control over all the session created through Webdriver so far and we can also Close Driver process this will cause issue that we can no longer access any session created through WebDriver which have been recently closed
```AutoHotkey
ChromeDriver := A_ScriptDir "\chromedriver.exe"
Driver := new RunDriver(ChromeDriver)
Driver.Exit() ; use this when you finished using Rufaydium class
```
# Session.Close() and Session.Exit()
different between Session.Close() and Session.Exit()
```AutoHotkey
ChromeDriver := A_ScriptDir "\chromedriver.exe"
Driver := new RunDriver(ChromeDriver)
Chrome := new Rufaydium(Driver)
Page1 := Chrome.NewSession()
Page1.Navigate("https://www.google.com/")
Page1.NewTab() 	; create new window / tab but Page1 session pointer will remain same 
Page1.Navigate("https://www.autohotkey.com/boards/viewtopic.php?t=94276") ; now 2nd tab is out active tab
; Page1.close() ; will close the active window / tab
Page1.exit() ; will close all windows / tabs will end up closing whole session 
```
# Switching Between Window Tabs & Frame
We Switch Tabs using `Session.SwitchbyTitle(Title)` or `Seesion.SwitchbyURL(url="")`
but Session remain the same If you check out examples I posted you would easly understand how switching Tab works
Just like Switch Tabs one can Switch Frames as well and pointer session will remain same.

![alt text](https://i.ibb.co/PW2P9ZG/Rufaydium-Frames-Example.png)

According to above image we have 1 session having three tabs
Example for TAB 1
```AutoHotkey
Session.SwitchbyURL(tab1url) ; to switch to TAB 1
; tab 1 has total 3 Frame
msgbox, % Session.FramesLength() ; this will return Frame quantity 2 from Main frame 
Session.Frame(0) ; switching to frame A
Session.getelementbyid(someid) ; this will get element from frame A
; now we cannot switch to frame B directly we need to go to main frame / main page
Session.ParentFrame() ; switch back to parent frame
Session.Frame(1) ; switching to frame B
Session.getelementbyid(someid) ; this will get element from frame B
; frame B also has a nasted frame we can switch to frame BA because its inside frame B
Session.Frame(0) ; switching to frame BA
Session.getelementbyid(someid) ; this will get element from frame BA
Session.ParentFrame() ; switch back to Frame B
Session.ParentFrame() ; switch back to Main Page / Main frame
```
Example for TAB 2
```AutoHotkey
Session.SwitchbyURL(tab2url) ; to switch to TAB 2
; tab 1 also has total 3 frames
msgbox, % Session.FramesLength() ; this will return Frame quantity 3
Session.Frame(0) ; switching to frame X
Session.ParentFrame() ; switch back to Main Page / Main frame
Session.Frame(1) ; switching to frame Y
Session.ParentFrame() ; switch back to Main Page / Main frame
Session.Frame(2) ; switching to frame Z
Session.ParentFrame() ; switch back to Main Page / Main frame
```
Example for TAB 3
```AutoHotkey
Session.SwitchbyURL(tab3url) ; to switch to TAB 3
msgbox, % Session.FramesLength() ; this will return Frame quantity which is Zero because TAB 3 has no frame
```
Switching frame would also Switch CDP of that Frame

# Error Handling
```AutoHotkey
; error Handling works with all methods, except methods that return Element pointer 
response :=  Session.method()
if response.error
	msgbox, % "error:" response.error "`nDetail:`n" json.dump(response)
response :=  Element.method()
if response.error
	msgbox, % "error:" response.error "`nDetail:`n" json.dump(response)	
```
# Few common functionality
```AutoHotkey
; this is will tell you is page loading I suspect it will be usefull while working with Session.CDP...()
; I and not sure if this supports other than chrome browser
Session.IsLoading()
; Accessing Element / Elements
; Following method return with element pointer if fail return empty and do not support error handling till now
Session.getelementbyid(id)
Session.QuerySelector(Path)
Session.QuerySelectorAll(Path)
Session.getElementsbyClassName(Class)
Session.getElementsbyName(Name) ; same as getElementsbyTagName
Session.getElementsbyXpath(xPath)

above function are simply based on 
Session.findelement(by.selector,"selectorparameter") 
Session.findelements(by.selector,"selectorparameter") 
; you can see by class
```
# by Class
```AutoHotkey
Class by
{
	static selector := "css selector"
	static Linktext := "link text"
	static Plinktext := "partial link text"
	static TagName := "tag name"
	static XPath	:= "xpath"
}
```
# Accessing Tables
There are many ways to acess table you can use Java Script function to extract Session.ExecuteSync(JS) or Session.CDP.Evaluate(JS)
but easy and simple ways is to utiliz AHK for loops
```AutoHotkey
Table := Session.QuerySelectorAll("table")[1]
for i, row in Table.QuerySelectorAll("tr")
{
  msgbox, % "Row number " i "has text: " row.innerText
  for c, td in row
  {
    msgbox, % "Row " i " Column: " c " has text: " td.innerText
  }
}
```
# Session window position and location
```AutoHotkey
; Getting window position and location
sessionrect := Session.Getrect()
msgbox, % json.dump(sessionrect)
; set session window position and locatoion
Srect := Session.SetRect(20,30,500,400) ; x, y, w, h 
; error handling
if Srect.error
	msgbox, % Srect.error
; setting rect will retun rect array
rect := Session.SetRect(1,1) ; this maximize to cover full screen and while taking care of taskbar
msgbox, % json.Dump(rect)
; sometime we only want to playwith x or y 
Session.x := 30
msgbox, % session.y
; this also return whole rect as well ; not just hight and also 
k := Session.hight := A_ScreenHeight - (A_ScreenHeight * 5 / 100)
if !k.error
	msgbox, json.dump(k)

Session.Maximize() ; this will Maximize session window
windowrect := Session.Minimize() ; this will minimize session window
if !windowrect.error ; error handling 
	msgbox, % json.dump(windowrect) ; if not error return with window rect

; following will turn full screen mode on
msgbox, % Json.Dump(Session.FullScreen()) ; return with rect, you can see x and y are zero h w are full screen sizes
; this simply turn fullscreen mode of
Session.Maximize()
```
# Handlling Session alerts popup messages
```AutoHotkey
Session.Alert("GET") ; getting text from pop up msg
Session.Alert("accept") ; pressing OK / accept pop up msg
Session.Alert("dismiss") ; pressing cancel / dismiss pop up msg
Session.Alert("Send","some text")  ; sending a Alert / pop up msg 
```
# Tacking Screen Shots accept only png file format
```AutoHotkey
Session.Screenshot("picture loaction") ; will save PNG to loaction
Element.Screenshot("picture loaction") ; will save PNG to loaction
```
# PDF printing 
its supported only for headless mode according to web driver 
```AutoHotkey
Session.print(PDFlocation,PrintOptions.A4_Default) ; see Class PrintOptions
Session.print(PDFlocation,{"":""}) ; for default print options
```
Class PrintOptions
PrintOptions to make custom PrintOptions
```AutoHotkey
Class PrintOptions ; https://www.w3.org/TR/webdriver2/#print
{
	static A4_Default =
	( LTrim Join
	{
 	"page":{
 		"width": 50,
 		"height": 60
	},
 	"margin":{
 		"top": 2,
 		"bottom": 2,
 		"left": 2,
 		"right": 2
	},
 	"scale": 1,
 	"orientation":"portrait",
	"shrinkToFit": json.true,
 	"background": json.true
	}
	)
}
```
# Session inputs events
```AutoHotkey
Session.move(x,y) move mouse pointer to location
Session.click(1) ; sending click on moved loaction ; [button: 1(left) | 2(middle) | 3(right)]
Session.DoubleClick(1) ; sending double click on moved loaction ; [button: 1(left) | 2(middle) | 3(right)]
Session.MBDown(1) ; sending mouse click down on moved loaction ; [button: 1(left) | 2(middle) | 3(right)]
Session.MBup(1) ; sending mouse click up on moved loaction ; [button: 1(left) | 2(middle) | 3(right)]
; now you can understand how to drag and drop stuff  read about element location rect and size further down below 
```
# Session Cookies
```AutoHotkey
Session.GetCookies() ; return with object array of cookies you need to parse then and understand 
Session.GetCookieName(Name) ; return with cookie with Name haven't tested it 
Session.AddCookie(CookieObj) ; will add cookie idk request parameters for adding cookies
```
# WDElement
Getting Elements their Information 
```AutoHotkey
Element.Name() ; will return tagname
Element.Rect() ; will return position and size
Element.Size() ; will return Size
Element.Location() ; will return position
Element.LocationInView() ; will return position in view
Element.enabled() ; will return boolean true for enabled or false disabled 
Element.Selected() ; will return boolean true for Selected or false not selected this will come handy for dropdown lists or combo list selecting options
Element.Displayed() ; will return boolean true for visible element / false for invisible element

; inputs and event triggers 
Element.Submut() ; this will trigger existing event(s)
Element.SendKey("text string " . key.class ) ; this convert text and will send key event to element and see Key.class for special keys 
Element.SendKey(key.ctrl "a" key.delete) ; this will clear text content in editbox by simply doing Ctrl + A and  delete
Element.Click() ; sent simple click
Element.Move() ; move mouse pointer to that element it will help drag drop stuff see session.click and session.move 
Element.clear() ; will cleat selected item / uploaded file or content text 
;getting value  element should be input box or editable other wise you need to use Session.CDP approach 
; to modify element selenium user will understand what I am talking about
msgbox, % Element.value
;setting value 
Element.value := "somevalue"

Element.InnerText ; return with innerTExt 
; you cannot set innerText using this approach you will need Session.CDP approach , CDP can modify whole DOM 
; if element is innerText based editbox we can simply use Element.sendkey()

; Attribs properties & CSS
Element.GetAttribute(Name) ; return with required attribute
Element.GetProperty(Name) ; return with required prorty
Element.GetCSS(Name) ; return with CSS

; element SHadow
Element.Shadow() ; return with shadow element detail actually I going to add functionality to access shadow elements in future
; first I need to learn about them

Element.Uploadfile(filelocation) ; this not working right I am working on it issue need to find out Payload/request parameters 
```
# Key.Class
```AutoHotkey
Class Key
{
	static Unidentified := "\uE000"
	static Cancel:= "\uE001"
	static Help:= "\uE002"
	static Backspace:= "\uE003"
	static Tab:= "\uE004"
	static Clear:= "\uE005"
	static Return:= "\uE006"
	static Enter:= "\uE007"
	static Shift:= "\uE008"
	static Control:= "\uE009"
	static Ctrl:= "\uE009"
	static Alt:= "\uE00A"
	static Pause:= "\uE00B"
	static Escape:= "\uE00C"
	static Space:= "\uE00D"
	static PageUp:= "\uE00E"
	static PageDown:= "\uE00F"
	static End:= "\uE010"
	static Home:= "\uE011"
	static ArrowLeft:= "\uE012"
	static ArrowUp:= "\uE013"
	static ArrowRight:= "\uE014"
	static ArrowDown:= "\uE015"
	static Insert:= "\uE016"
	static Delete:= "\uE017"
	static F1:= "\uE031"
	static F2:= "\uE032"
	static F3:= "\uE033"
	static F4:= "\uE034"
	static F5:= "\uE035"
	static F6:= "\uE036"
	static F7:= "\uE037"
	static F8:= "\uE038"
	static F9:= "\uE039"
	static F10:= "\uE03A"
	static F11:= "\uE03B"
	static F12:= "\uE03C"
	static Meta:= "\uE03D"
	static ZenkakuHankaku:= "\uE040"	
}
```

