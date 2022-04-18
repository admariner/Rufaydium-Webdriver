; WDM aka Web Driver managment Class for Rufaydium.ahk 
; I am upto/will add support update auto download supporting Webdriver when broswer gets update
; By Xeo786

Class RunDriver
{
	__New(Location,Port=9515,Parameters="")
	{
		SplitPath, Location,Name,,,DriverName
		Parameters := "--port=" Port . " " Parameters
		This.Target := Location " " chr(34) Parameters chr(34)
		this.DriverName := DriverName
		This.Port := Port
		PID := GetPIDbyName(Name)
		if PID
		{
			this.PID := PID
		}
		else			
			this.Launch()
	}
	
	__Delete()
	{
		;this.exit()
	}
	
	exit()
	{
		Process, Close, % This.PID
	}
	
	Launch()
	{
		Run % this.Target,,Hide,PID
		Process, Wait, % PID
		this.PID := PID
	}
}

/*
 Rufaydium is totally depands on Rest Api (HTTP) calls and 
 I would have created so many Winhttp com objects
 therefore I came up with this trick
 Single function per single process
 */
 
global WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
Request(url,Method,Payload:= 0,WaitForResponse=0) {
	WebRequest.Open(Method, url, false)
	WebRequest.SetRequestHeader("Content-Type","application/json")
	if Payload
		WebRequest.Send(Payloadfix(Payload))
	else
		WebRequest.Send()
	if WaitForResponse
		WebRequest.WaitForResponse()
	return WebRequest.responseText
	
}

Payloadfix(p)
{
	p := StrReplace(json.dump(p),"[[]]","[{}]") ; why using StrReplace() >> https://www.autohotkey.com/boards/viewtopic.php?f=6&p=450824#p450824
	p := RegExReplace(p,"\\\\uE(\d+)","\uE$1")  ; fixing Keys turn '\\uE000' into '\uE000'
	return p
}

GetPIDbyName(name) {
	static wmi := ComObjGet("winmgmts:\\.\root\cimv2")
	for Process in wmi.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" name "'")
		return Process.processId
}