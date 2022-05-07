; WDM aka Web Driver management Class for Rufaydium.ahk 
; I am upto/will add support update auto download supporting Webdriver when browser gets update
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
	
	help(Location)
	{
		Run % comspec " /k " chr(34) Location chr(34) " --help > dir.txt",,Hide,PID
		while !FileExist(A_ScriptDir "\dir.txt")
			sleep, 200
		sleep, 200
		FileRead, Content, dir.txt
		while FileExist(A_ScriptDir "\dir.txt")
			FileDelete, % A_ScriptDir "\dir.txt"
		Process, Close, % PID
		return Content
	}
	
	visible
	{
		get
		{
			return this.visibility
		}
		
		set
		{
			if(value = 1) and !this.visibility
			{
				winshow, % "ahk_pid " this.pid
				this.visibility := 1
			}
			else
			{
				winhide, % "ahk_pid " this.pid
				this.visibility := 0
			}
		}
	}
	
	; supports for edge and other driver will soon be added 
	; thanks for AHK_user for driver auto-download suggestion and his code https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102616&start=60#p460812
	GetLatest_ChromeDriver(DriverLocation=0, Version="")
	{
		Process, Close, % GetPIDbyName("chromedriver.exe")
		if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",bver)
			Version := "_" bver2
		
		oHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		oHTTP.Open("GET", "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"  Version, true)
		oHTTP.Send()
		oHTTP.WaitForResponse()
		Version_Chromedriver := oHTTP.ResponseText
		
		if InStr(Version_Chromedriver, "NoSuchKey"){
			MsgBox,16,Testing,Error`nVersion_Chromedriver
			return false
		}
		
		Url_ChromeDriver := "https://chromedriver.storage.googleapis.com/" Version_Chromedriver "/chromedriver_win32.zip"
		URLDownloadToFile, %Url_ChromeDriver%,  %A_ScriptDir%/chromedriver_win32.zip
		fso := ComObjCreate("Scripting.FileSystemObject")
		AppObj := ComObjCreate("Shell.Application")
		FolderObj := AppObj.Namespace(A_ScriptDir "\chromedriver_win32.zip")
		if !FileExist(A_ScriptDir "\Backup")
			FileCreateDir, % A_ScriptDir "\Backup"
		
		while FileExist(DriverLocation)
			FileMove, % DriverLocation, % A_ScriptDir "\Backup\Chromedriver Version " bver1 ".exe", 1
		
		while FileExist(A_ScriptDir "\chromedriver.exe")
			FileMove, % A_ScriptDir "\chromedriver.exe", % A_ScriptDir "\Backup\Chromedriver Version unknown.exe", 1
		
		FileObj := FolderObj.ParseName("chromedriver.exe")
		AppObj.Namespace(A_ScriptDir "\").CopyHere(FileObj, 4|16)
		FileDelete, % A_ScriptDir "\chromedriver_win32.zip"
		return A_ScriptDir "\chromedriver.exe"
	}
}

/*
 Rufaydium totally depends on Rest API (HTTP) calls and 
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
