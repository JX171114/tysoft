Sub Include(sInstFile) 
Dim oFSO, f, s 
Set oFSO = CreateObject("Scripting.FileSystemObject") 
Set f = oFSO.OpenTextFile(sInstFile) 
s = f.ReadAll 
f.Close 
ExecuteGlobal s 
End Sub

'defaultRootPath --Դ����Ĭ�ϸ�·��
'defaultWebPage --ҳ��Ĭ��·��
'defaultRootPackage --Ĭ�ϰ�ǰ׺
'author --����
Dim defaultRootPath,defaultWebPage,defaultRootPackage,author
defaultRootPath = "..\code\src\main\java"
defaultWebPage = "..\code\src\main\resources\templates"
defaultRootPackage = "com.xmrbi."

'�������ƵĻ�ȡ
Set wNetwork = CreateObject("WScript.Network")
author = InputBox("��������","ע���ϵ���������",wNetwork.UserName)

'ִ�и����ļ��ű�
Include "simpleVbs/entity.vbs"
Include "simpleVbs/repository.vbs"
Include "simpleVbs/db-mysql.vbs"
'Include "simpleVbs/db-oracle.vbs"
Include "simpleVbs/service-jpa-criteria.vbs"
Include "simpleVbs/controller_page-jpa.vbs"
Include "simpleVbs/Utf8ToNoBom.vbs"
MsgBox "�������ɳɹ�"