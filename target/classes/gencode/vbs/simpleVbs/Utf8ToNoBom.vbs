' ��ģ��������ʵ��bean

Option explicit
Do 
Dim fso,rootPath,webPage,tempPath,batFilePath,defaultDbRootPath
defaultDbRootPath = "..\db"
 
Set fso = CreateObject("Scripting.FileSystemObject")  

If init() Then
   Output "����utf8ת���������ʱ�ļ�..."
   createBat()
   Output "���ļ�ת��Ϊ��Bom��UTF8��ʽ... ..."
   executeBat()
   Output "ת����ɡ�"
   Output "�������ɳɹ���"
   delBat()
End If

Exit Do  
Loop 

'��ʼ����������
Function init()
   Dim iniArray,signLen
   iniArray = Split(ActiveModel.Comment,vbCr)
   signLen = UBound(iniArray)
   If signLen < 1 Then
		rootPath = defaultRootPath
		Output "Դ�����·��:" + rootPath
		webPage = defaultWebPage
		output "��ҳ·��= " + webPage		
   Else
		rootPath = iniArray(0)
		Output "Դ�����·��=" + rootPath
		webPage = Mid(iniArray(1),2)
		output "��ҳ·��= " + webPage
   End If
   init = True
End Function

'����bat�ļ�
Function createBat()
   Dim file
   batFilePath = rootPath + "\Utf8ToNoBom.bat"
   Set file = fso.OpenTextFile(batFilePath, 2, true)
   file.Write  "@echo off"+vbCrLf
   file.Write  "powershell ^"+vbCrLf
   file.Write  "    Get-ChildItem "+rootPath+"\ -recurse *.java^|%%{^"+vbCrLf
   file.Write  "        $txt = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8);^"+vbCrLf
   file.Write  "        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False;^"+vbCrLf
   file.Write  "        [System.IO.File]::WriteAllText($_.FullName, $txt, $Utf8NoBomEncoding);^"+vbCrLf
   file.Write  "    }"+vbCrLf
   'file.Write  "pause"+vbCrLf

   file.Write  "@echo off"+vbCrLf
   file.Write  "powershell ^"+vbCrLf
   file.Write  "    Get-ChildItem "+webPage+"\ -recurse *.html^|%%{^"+vbCrLf
   file.Write  "        $txt = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8);^"+vbCrLf
   file.Write  "        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False;^"+vbCrLf
   file.Write  "        [System.IO.File]::WriteAllText($_.FullName, $txt, $Utf8NoBomEncoding);^"+vbCrLf
   file.Write  "    }"+vbCrLf

   file.Write  "@echo off"+vbCrLf
   file.Write  "powershell ^"+vbCrLf
   file.Write  "    Get-ChildItem "+defaultDbRootPath+"\ -recurse *.sql^|%%{^"+vbCrLf
   file.Write  "        $txt = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8);^"+vbCrLf
   file.Write  "        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False;^"+vbCrLf
   file.Write  "        [System.IO.File]::WriteAllText($_.FullName, $txt, $Utf8NoBomEncoding);^"+vbCrLf
   file.Write  "    }"+vbCrLf
End Function

'ִ��bat�ļ�
Function executeBat()
Dim wshshell
set wshshell=CreateObject("wscript.shell")
wshshell.run batFilePath,0,true
End Function

'ɾ��bat�ļ�
Function delBat()
    ''WScript.Sleep 2000 '���ַ�ʽ����ʱ�����ﲻ����
	'Dim ws  '���������ַ�ʽ��ʱ
	'set ws=CreateObject("wscript.shell")
    'ws.run "cmd.exe /c choice /t 5 /d y /n >nul" ,0,true
    'MsgBox "�������ɳɹ�"
fso.deleteFile  batFilePath
End Function
'-----------------------------------------------------------------------------------------
