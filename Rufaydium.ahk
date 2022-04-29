; Rufaydium V1.41
; Rufaydium is Webdriver Library can support any chromium based browser 
; It only requires Latest WebDriver, 
; i.e. for Chrome 100 you need to download ChromeDriver 100.0.4896.60
; from https://chromedriver.chromium.org/downloads
;
; It utilizes Rest API of W3C from https://www.w3.org/TR/webdriver2/
; Rufaydium also supports Chrome Devtools Protocols same as chrome.ahk
; 
; Note: no need to install /setup selenium, Rufaydium is AHK's Selenium
; Link : https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102616&p=456008#p456008
; By Xeo786

#Include WDM.ahk
#Include CDP.ahk
#Include JSON.ahk
#include WDElements.ahk

Class Rufaydium
{
	__new(Driver)
	{
		This.Driver := Driver
		This.DriverUrl := "http://127.0.0.1:" Driver.Port
	}
	
	__Delete()
	{
		;This.Driver.Exit()
	}
	
	send(url,Method,Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		r := Json.load(Request(url,Method,Payload,WaitForResponse)).value ; Thanks to GeekDude for his awesome cJson.ahk
		if r 
			return r
	}
	
	SessionParameters(Parameters)
	{
		if !IsObject(Parameters)
			return
		else
			this.capabilities := Parameters
	}
	
	NewSession()
	{
		window := []
		if !this.capabilities
			this.capabilities := capabilities.Simple
		
		k := this.Send( this.DriverUrl "/session","POST",this.capabilities,1)
		if k.error
		{
			msgbox, 48,Rufaydium WebDriver Support Error,% "WebDriver Version does not supports Browser Version `n`n" Json.dump(k)
			return
		}
		window.debuggerAddress := StrReplace(k.capabilities["goog:chromeOptions"].debuggerAddress,"localhost","http://127.0.0.1")
		window.address := this.DriverUrl "/session/" k.SessionId
		return new Session(window)
	}
	
	getSessions() ; get all windows
	{
		Sessions := this.send(this.DriverUrl "/sessions","GET")
		windows := []
		for k, se in Sessions
		{
			chromeOptions := Se["capabilities","goog:chromeOptions"]
			s := []
			s.id := Se.id
			s.debuggerAddress := StrReplace(chromeOptions.debuggerAddress,"localhost","http://127.0.0.1")
			s.address := this.DriverUrl "/session/" s.id
			windows[k] := new Session(s)
		}
		return windows
	}
	
	getSession(i=0,t=0)
	{
		if i
		{
			S := this.getSessions()[i])
			if t
			{
				S.SwitchTab(t)
			}
			return S
		}
	}
	
	getSessionByUrl(URL)
	{
		for k, w in this.getSessions()
		{
			w.SwitchbyURL(URL)
			if instr(w.URL(),URL)
				return w
		}
	}
	
	getSessionByTitle(Title)
	{
		for k, s in this.getSessions()
		{
			s.SwitchbyTitle(Title)
			if instr(s.title(),Title)
				return s
		}
	}
	
	QuitAllSessions()
	{
		for k, s in this.getSessions()
			s.Quit()
	}
	
}


Class Session extends Rufaydium
{
	
	__new(i)
	{
		this.id := i.id
		this.Address := i.address
		this.debuggerAddress := i.debuggerAddress
		this.currentTab := this.Send("window","GET")
		this.CDP := new CDP(this.Address)
	}
	
	__Delete()
	{
		;this.Quit()
	}
	
	Quit()
	{
		this.Send(this.address ,"DELETE")
	}
	
	close()
	{
		This.currentTab := this.Send("window","DELETE")
	}
	
	NewTab()
	{
		This.currentTab := this.Send("window/new","POST",{"type":"tab"}).handle
		This.Switch(This.currentTab)
	}
	
	Detail()
	{
		return this.Send( this.debuggerAddress "/json","GET")
	}
	
	GetTabs()
	{
		return this.Send("window/handles","GET")
	}
	
	Switch(Tabid)
	{
		this.currentTab := Tabid
		this.Send("window","POST",{"handle":Tabid})
	}
	
	Title()
	{
		return this.Send("title","GET")
	}
	
	SwitchTab(i=0)	
	{
		if i
		{
			return this.Switch(This.currentTab := this.GetTabs()[i])
		}
	}
	
	SwitchbyTitle(Title="")
	{
		handles := this.GetTabs()
		for k , handle in handles
		{
			this.switch(handle)
			if instr(this.title(),Title)
			{
				This.currentTab := handle
				break
			}
		}
		this.Switch(This.currentTab )
	}
	
	SwitchbyURL(url="")
	{
		handles := this.GetTabs()
		for k , handle in handles
		{
			this.switch(handle)
			if instr(this.URL(),url)
			{
				This.currentTab := handle
				break
			}
		}
		this.Switch(This.currentTab )
	}
	
	url()
	{
		return this.Send("url","GET")
	}
	
	Refresh()
	{
		return this.Send("refresh","POST")
	}
	
	IsLoading()
	{
		return this.Send("is_loading","GET")
	}
	
	timeouts()
	{
		return this.Send("timeouts","GET")
	}
	
	Navigate(url)
	{
		return this.Send("url","POST",{"url":url})
	}
	
	Forward()
	{
		return this.Send("forward","POST") ; not tested
	}
	
	Back()
	{
		return this.Send("back","POST") ; not tested
	}
	
	GetRect()
	{
		return this.Send("window/rect","GET")
	}
	
	SetRect(x:=1,y:=1,w:=0,h:=0)
	{
		if !w
			w := A_ScreenWidth - 0
		if !h
			h := A_ScreenHeight - (A_ScreenHeight * 5 / 100)
		return this.Send("window/rect","POST",{"x":x,"y":y,"width":w,"height":h})
	}
	
	X
	{
		get
		{
			rect := this.GetRect()
			return rect.x
		}
		
		Set
		{
			msgbox, % value
			return this.Send("window/rect","POST",{"x":value})
		}
	}
	
	Y
	{
		get
		{
			rect := this.GetRect()
			return rect.y
		}
		
		Set
		{
			return this.Send("window/rect","POST",{"y":value})
		}
	}
	
	width
	{
		get
		{
			rect := this.GetRect()
			return rect.width
		}
		
		Set
		{
			return this.Send("window/rect","POST",{"width":value})
		}
	}
	
	height
	{
		get
		{
			rect := this.GetRect()
			return rect.height
		}
		
		Set
		{
			return this.Send("window/rect","POST",{"height":value})
		}
	}
	
	Maximize()
	{
		return this.Send("window/maximize","POST",json.null)
	}
	
	Minimize()
	{
		return this.Send("window/minimize","POST",json.null)
	}
	
	FullScreen()
	{
		return this.Send("window/fullscreen","POST",json.null)
	}
	
	FramesLength()
	{
		return this.ExecuteSync("return window.length")
	}
	
	Frame(i)
	{
		return this.Send("frame","POST",{"id":i})
	}
	
	ParentFrame()
	{
		return this.Send("frame/parent","POST",json.null)
	}
	
	HTML()
	{
		return this.Send("source","GET",0,1)
	}
	
	ActiveElement()
	{
		return New WDElement(this.Send("element/active","GET"))
	}
	
	findelement(u,v) 
	{
		for element, elementid in this.Send("element","POST",{"using":u,"value":v},1)
		{
			address := RegExReplace(this.address "/element/" elementid,"(\/element\/.*)\/element","/element")
			return New WDElement(address)
		}
	}
	
	findelements(u,v)
	{
		
		e := []
		for k, element in this.Send("elements","POST",{"using":u,"value":v},1)
		{
			for i, elementid in element
			{
				address := RegExReplace(this.address "/element/" elementid,"(\/element\/.*)\/element","/element")
				e[k] := New WDElement(address)
			}
		}
		return e
	}
	
	getElementByID(id)
	{
		return this.findelement(by.selector,"#" id)
	}
	
	QuerySelector(Path)
	{
		return this.findelement(by.selector,Path)
	}
	
	QuerySelectorAll(Path)
	{
		return this.findelements(by.selector,Path)
	}
	
	getElementsbyClassName(Class)
	{
		Class = [class='%Class%']
		return this.findelements(by.selector,Class)
	}
	
	getElementsbyName(Name)
	{
		return this.findelements(by.TagName,Name)
	}
	
	getElementsbyXpath(xPath)
	{
		return this.findelements(by.xPath,xPath)
	}
	
	ExecuteSync(Script,Args*)
	{
		return this.Send("execute/sync","POST", { "script":Script,"args":[Args*]},1)
	}
	
	ExecuteAsync(Script,Args*)
	{
		return this.Send("execute/async","POST", { "script":Script,"args":Args*},1)
	}
	
	GetCookies()
	{
		return this.Send("cookie","GET")
	}
	
	GetCookieName(Name)
	{
		return this.Send("cookie/" Name,"GET")
	}
	
	AddCookie(CookieObj)
	{
		return this.Send("cookie","POST",CookieObj)
	}
	
	Alert(Action,Text:=0)
	{
		switch Action
		{
			case "accept":		i := "/alert/accept",	m := "POST"
			case "dismiss":	i := "/alert/dismiss",	m := "POST"
			case "GET":    	i := "/alert/text",		m := "GET" 
			case "Send":    	i := "/alert/text",		m := "POST" 
		}
		
		if Text
			return this.Send(this.address i,m,{"text":Text})
		else
			return this.Send(this.address i,m)
	}
	
	Screenshot(location:=0)
	{
		Base64Canvas :=  this.Send("screenshot","GET")
		if Base64Canvas
		{
			nBytes := Base64Dec( Base64Canvas, Bin ) ; thank you Skan :)
			File := FileOpen(location, "w")
			File.RawWrite(Bin, nBytes)
			File.Close()
		}
	}
	
	Print(PDFLocation,Options)
	{
		Base64pdfData := this.Send("print","POST",Options) ; does not works
		if !Base64pdfData.error
		{
			nBytes := Base64Dec( Base64pdfData, Bin ) ; thank you Skan :)
			File := FileOpen(PDFLocation, "w")
			File.RawWrite(Bin, nBytes)
			File.Close()
		}
		else
			msgbox, ,Rufaydium, % "Fail to save PDF`nError : " json.Dump(Base64pdfData) "`n`nMake sure chrome is running headless mode`nPlease define Print Options or use print profiles from PrintOptions.class"
	}
	
	click(i:=0) ; [button: 0(left) | 1(middle) | 2(right)]
	{
		PointerClick =
		( LTrim Join
		{
			"actions": [
				{
				"type": "pointer",
				"id": "mouse",
				"parameters": {"pointerType": "mouse"},
				"actions": [
					{"type": "pointerDown", "button": %i%},
					{"type": "pause", "duration": 100},
					{"type": "pointerUp", "button": %i%}
					]
				}
			]
		}
		)
		return this.Actions(json.load(PointerClick))
	}
	
	DoubleClick(i=0) ; [button: 0(left) | 1(middle) | 2(right)]
	{
		PointerClicks =
		( LTrim Join
		{
			"actions": [
				{
				"type": "pointer",
				"id": "mouse",
				"parameters": {"pointerType": "mouse"},
				"actions": [
					{"type": "pointerDown", "button": %i%},
					{"type": "pause", "duration": 100},
					{"type": "pointerUp", "button": %i%},
					{"type": "pause", "duration": 500},
					{"type": "pointerDown", "button": %i%},
					{"type": "pause", "duration": 100},
					{"type": "pointerUp", "button": %i%}
					]
				}
			]
		}
		)
		return this.Actions(json.load(PointerClicks))
	}
	
	MBDown(i=0) ; [button: 0(left) | 1(middle) | 2(right)]
	{
		;return this.Send("buttondown","POST",{"button":i})		PointerClick =
		PointerDown =
		( LTrim Join
		{
			"actions": [
				{
				"type": "pointer",
				"id": "mouse",
				"parameters": {"pointerType": "mouse"},
				"actions": [
					{"type": "pointerDown", "button": %i%}
					]
				}
			]
		}
		)
		return this.Actions(json.load(PointerDown))
	}
	
	MBup(i=0) ; [button: 0(left) | 1(middle) | 2(right)]
	{
		;return this.Send("buttonup","POST",{"button":i})
		PointerUP =
		( LTrim Join
		{
			"actions": [
				{
				"type": "pointer",
				"id": "mouse",
				"parameters": {"pointerType": "mouse"},
				"actions": [
					{"type": "pointerUp", "button": %i%}
					]
				}
			]
		}
		)
		return this.Actions(json.load(PointerUP))
	}
	
	Move(x,y)
	{
		PointerMove =
		( LTrim Join
		{
			"actions": [
				{
				"type": "pointer",
				"id": "mouse",
				"parameters": {"pointerType": "mouse"},
				"actions": [{
							"type": "pointerMove",
							"duration": 0,
							"x": %x%, "y": %y%
							}]
				}
			]
		}
		)
		return this.Actions(json.load(PointerMove))
	}
	
	Actions(ActionObj)
	{
		return this.Send("actions","POST",ActionObj)
	}
	
	execute_sql()
	{
		return this.Send("execute_sql","POST",{"":""}) ; idk about sql 
	}
}

Class by
{
	static selector := "css selector"
	static Linktext := "link text"
	static Plinktext := "partial link text"
	static TagName := "tag name"
	static XPath	:= "xpath"
}

; here you one can make Capabilities profile as per requirement
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


; https://www.autohotkey.com/boards/viewtopic.php?t=35964
Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
	Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
	DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
	VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
	DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
	Return Rqd
}

Base64Enc( ByRef Bin, nBytes, LineLength := 64, LeadingSpaces := 0 ) { ; By SKAN / 18-Aug-2017
	Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",nBytes, "UInt",0x1, "Ptr",0,   "UIntP",Rqd )
	VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",nBytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
	If ( LineLength = 64 and ! LeadingSpaces )
		Return B64
	B64 := StrReplace( B64, "`r`n" )        
	Loop % Ceil( StrLen(B64) / LineLength )
		B .= Format("{1:" LeadingSpaces "s}","" ) . SubStr( B64, N += LineLength, LineLength ) . "`n" 
	Return RTrim( B,"`n" )    
}
