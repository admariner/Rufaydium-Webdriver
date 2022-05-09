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
	GetChromeDriver(Version="")
	{
		exe := "chromedriver.exe"
		zip := "chromedriver_win32.zip"
		if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",bver)
			Version := "_" bver2
		else
			bver1 := "unkown"
		uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"  Version
		DriverVersion := Request(uri,"GET")
		if InStr(DriverVersion, "NoSuchKey"){
			MsgBox,16,Testing,Error`nDriverVersion
			return false
		}
		
		if !FileExist(A_ScriptDir "\Backup")
			FileCreateDir, % A_ScriptDir "\Backup"
		
		while FileExist(A_ScriptDir "\" exe)
		{
			Process, Close, % GetPIDbyName(exe)
			FileMove, % A_ScriptDir "\" exe, % A_ScriptDir "\Backup\Chromedriver Version " bver1 ".exe", 1
		}
		
		DriverUrl := "https://chromedriver.storage.googleapis.com/" DriverVersion "/" zip
		return DownloadnExtract(DriverUrl,zip,exe)
	}
	
	/* not working
	GetEdgeDrive(Version="edgewebdriver/LATEST_STABLE",bit="32")
	{
		exe := "msedgedriver.exe"
		if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",bver)
			Version := "_" bver2
		else if(Version != "STABLE")
			Version := "RELEASE_" Version
		else
			bver1 := "unkown"
		uri := "https://msedgewebdriverstorage.blob.core.windows.net/" Version
		msgbox, % Clipboard := uri
		DriverVersion := Request(uri,"GET")
		
		if InStr(DriverVersion, "BlobNotFound"){
			MsgBox,16,Testing,Error`nDriverVersion
			return false
		}
		; Http header stream octact issue 
		msgbox, % DriverVersion
		
		if instr(bit,"64")
			zip := "edgedriver_win64.zip"
		else 
			zip := "edgedriver_win32.zip"
		
		if !FileExist(A_ScriptDir "\Backup")
			FileCreateDir, % A_ScriptDir "\Backup"
		
		while FileExist(A_ScriptDir "\" exe)
		{
			Process, Close, % GetPIDbyName(exe)
			FileMove, % A_ScriptDir "\" exe, % A_ScriptDir "\Backup\Chromedriver Version " bver1 ".exe", 1
		}
		DriverUrl := "https://msedgedriver.azureedge.net/" DriverVersion "/" zip
		return DownloadnExtract(DriverUrl,zip,exe)
	}
	*/
}

DownloadnExtract(url,zip,exe)
{
	msgbox, % url
	URLDownloadToFile, % url ,  % A_ScriptDir "/" zip
	fso := ComObjCreate("Scripting.FileSystemObject")
	AppObj := ComObjCreate("Shell.Application")
	FolderObj := AppObj.Namespace(A_ScriptDir "\" zip)	
	FileObj := FolderObj.ParseName(exe)
	AppObj.Namespace(A_ScriptDir "\").CopyHere(FileObj, 4|16)
	FileDelete, % A_ScriptDir "\" zip
	return A_ScriptDir "\" exe
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
