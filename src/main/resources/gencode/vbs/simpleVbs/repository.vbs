' ��ģ��������ʵ��bean

Option explicit

'rootPath -- �������Ŀ¼�Ĵ��·��
'respRootPage -- ������·��
'tempPath -- �������ɵ���ʱĿ¼
Dim rootPath,rootPage,respRootPage,tempPath,entityPage
'��ʵ���µİ���
Dim classPage,respPack
'fso -- FileSystemObject
'wshNetwork -- WScript.Network
'entityPath -- ����ʵ���·��
'author -- ע���ϵ���������
respPack = "repository"
Dim fso,wshNetwork,entityPath


Set fso = CreateObject("Scripting.FileSystemObject")
''�������ƵĻ�ȡ
Set wshNetwork = CreateObject("WScript.Network")
'author = InputBox("��������","ע���ϵ���������",wshNetwork.UserName)
If author="" Then
	author = wshNetwork.UserName
End If


'��ʱĿ¼������
tempPath = "_temp"
If fso.FolderExists(tempPath) then
	fso.DeleteFolder (tempPath)
End If
fso.CreateFolder(tempPath)



If init() Then
  'Ŀ¼�Ĵ���
   entityPath = CreateEntityPageFolder(fso, rootPath, classPage)
   CreateSelectEntityToJava()
End If
fso.DeleteFolder (tempPath)

'��ʼ����������
Function init()

   Dim iniArray,signLen
   iniArray = Split(ActiveModel.Comment,vbCr)
   signLen = UBound(iniArray)
   If signLen < 1 Then
		'Output "�Զ�������·����ο��������ã����û����Ĭ�����ɵ���vbs�ļ���ͬ���ļ����:"
		'Output "����ConceptualDataModel��Comment������ע��:"
		'Output "Դ�����·��"
		'Output "���ɵ�ҳ��·��"
		'Output "��������"
		'Output "����:"
		'Output "D:\projectPath\src\main\java"
		'Output "D:\projectPath\src\main\resources\templates\project"
		'Output "com.xmrbi.project"
		'Output ""
		'Output "<ע����1��Ϊ���ɵ�Դ����·������2��Ϊ���ɵ�ҳ��·������3��Ϊ��������>"

		rootPath = defaultRootPath
		Output "Դ�����·��:" + rootPath
		CreateRootPahtFolder fso,rootPath
		rootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)+"."+respPack
		respRootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)+"."+respPack
	    Output "repository��·��:" + respRootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		output "classPage:" + classPage
		entityPage = defaultRootPackage+FirstCharToL(ActiveModel.code) +".entity." +  FirstCharToL(ActivePackage.Code)
   Else
	   rootPath = iniArray(0)
	   Output "Դ�����·��:" + rootPath
	   CreateRootPahtFolder fso,rootPath
	   rootPage = Mid(iniArray(1),2)
	   respRootPage = Mid(iniArray(2),2)+"."+respPack
	   Output "repository��·��:" + respRootPage
	   classPage =  getClassPage(ActiveDiagram.GetPackage())
	   output "classPage:" + classPage
	   entityPage = Mid(iniArray(2),2) +".entity." +  FirstCharToL(ActivePackage.Code)
   End If
   init = True
End Function


Function getClassPage(pPage)
	Dim currentPage
   getClassPage = ""
   Set currentPage = pPage
  ' Do While currentPage.ClassName <> "Conceptual Data Model"'ȥ��ѭ����ֻȡ�ϼ��İ���Ϣ
      If currentPage.code <>"" Then 
	  getClassPage = LCase(currentPage.code) + "." + getClassPage 
      End If
	  Set currentPage = currentPage.GetPackage()
	  
   'Loop
   If getClassPage <> "" Then
	 getClassPage =  respRootPage + "." + Left(getClassPage,Len(getClassPage)-1)
   Else
     getClassPage = respRootPage
   End If
   
End Function 

'BEGIN -------------------Ŀ¼�Ĵ���
'������Ŀ¼
Function CreateRootPahtFolder(vfso, vpath)
	Dim tempArray,temp,rootPath
	tempArray = Split(vpath, "\")

	For Each temp in tempArray
	  If rootPath <> "" Then
		 rootPath = rootPath +"\"
	  End If
      rootPath = rootPath  + temp
	  CreateFolder vfso, rootPath
    Next    
End Function

'��������Ŀ¼
Function CreateEntityPageFolder(vfso, vpath, vpage)
	Dim tempArray,temp
	CreateEntityPageFolder = vpath
	tempArray = Split(vpage, ".")
	
	For Each temp in tempArray
      CreateEntityPageFolder = CreateEntityPageFolder +"\" + temp
	  CreateFolder vfso, CreateEntityPageFolder
	  Output "repositoryĿ¼��" + CreateEntityPageFolder
    Next
    
End Function

'�����ļ���
Function CreateFolder (vfso, vpath)
   Set CreateFolder = nothing
   If vfso.FolderExists(vpath) then
     Set CreateFolder = vfso.GetFolder(vpath)
'	 output "�Ѵ����ļ���: " + vpath
	 Exit Function
   Else
     Set CreateFolder = vfso.CreateFolder(vpath)
	 output "�����ļ���: " + vpath
	 Output ""
   End If 
End Function
'END-------------------Ŀ¼�Ĵ���
Function BackUpFile(pOldFileName)
	If fso.FileExists(pOldFileName) then
	   If MsgBox(pOldFileName + " �ļ��Ѿ�����,��ȷ��Ҫ������",vbYesNo)=vbNo Then
	     BackUpFile = false
	     Exit Function
	   End If
	   Dim oldFile
		Dim backupDir,fileName
		fileName = Mid(pOldFileName,InStrRev(pOldFileName,"\"))
		backupDir = "backup-"+Replace(CStr(Now()),":","-")
		CreateFolder fso, backupDir
		output pOldFileName
		Set oldFile = fso.GetFile(pOldFileName)
		oldFile.Move (backupDir + "\" + fileName)
		BackUpFile = true
    End If
	BackUpFile = true
End Function


'��ѡ��Ķ�������java����
Function CreateSelectEntityToJava()
   dim entity
   For Each entity In ActiveSelection 'ActiveModel.Entities
	If entity.ClassName = "Entity" Then
		EntityToJava entity
    End If
  Next
End Function

'��ѡ��Ķ�������java Service����
Function EntityToJava(pEntity)
   
   Dim entity,tempResp
   Dim respName
   Dim UTF8resp
   
   
   '�����ӿ��ļ������������ļ�������ʵ���ļ�
   respName = FirstCharToU(pEntity.Code)+"Repository"
   tempResp = tempPath + "\" + respName + ".java.gbk"
   UTF8resp = entityPath + "\" + respName + ".java"

   Dim fileResp
   Set fileResp = fso.OpenTextFile(tempResp, 2, true)

   WriteJavaTop fileResp,pEntity
    
   WritePageInfo fileResp,getClassPage(ActivePackage)
 
   insertRespImportPage fileResp,pEntity

   Dim respStr
   respStr = respStr + AddRespMethod(pEntity)
   fileResp.Write "/**" + vbCrLf
   fileResp.Write " * " +pEntity.Name+ vbCrLf
   fileResp.Write " */" + vbCrLf
   fileResp.Write "@Repository" + vbCrLf
   fileResp.Write "public interface "+FirstCharToU(pEntity.Code)+"Repository extends JpaRepository<"+FirstCharToU(pEntity.Code)+",String>, JpaSpecificationExecutor<"+FirstCharToU(pEntity.Code)+">{" + vbCrLf
   fileResp.Write respStr + vbCrLf
   fileResp.Write "}" + vbCrLf
   
   ConvertToUTF8 tempResp,UTF8resp
End Function


'д�ļ�ͷע��
Function WriteJavaTop(file,pEntity)
	file.Write "/**" + vbCrLf
 	file.Write "* <p>Description: "+pEntity.name+"����</p>" + vbCrLf
 	file.Write "* <p>Copyright: Copyright (c) "+ CStr(DatePart("yyyy",Date)) +"</p>" + vbCrLf
 	file.Write "* <p>Company: ����·����Ϣ�ɷ����޹�˾</p>" + vbCrLf
 	file.Write "* @author :" + author + vbCrLf
 	file.Write "* �������� " + CStr(Date) + " "  + CStr(Time) + vbCrLf
 	file.Write "* @version V1.0" + vbCrLf
 	file.Write "*/" + vbCrLf
End Function



'д�ļ�ͷע��
Function WritePageInfo(file,pageinfo)
   file.Write  vbCrLf
   file.Write  "package " + pageinfo + ";"+vbCrLf
   file.Write vbCrLf
End Function



'�ӿ���������
Function insertRespImportPage(file,entity)
	file.Write   vbCrLf
	file.Write   "import org.springframework.data.domain.Page;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Pageable;"+vbCrLf
	file.Write   "import org.springframework.data.jpa.repository.Query;"+vbCrLf
	file.Write   "import org.springframework.data.jpa.repository.JpaRepository;"+vbCrLf
	file.Write   "import org.springframework.data.jpa.repository.JpaSpecificationExecutor;"+vbCrLf
	file.Write   "import org.springframework.stereotype.Repository;"+vbCrLf
    file.Write vbCrLf
	file.Write   "import "+entityPage + "."+FirstCharToU(entity.Code)+";"+vbCrLf
    file.Write vbCrLf
End Function


'���ɽӿڷ���
Function AddRespMethod(entity)
     Dim attr,countNum
	 countNum = 0
	 AddRespMethod =                      "	/**" + vbCrLf
	 AddRespMethod = AddRespMethod + "	 * ��ҳ��ѯ" + vbCrLf
	 AddRespMethod = AddRespMethod + "	 * @param searchText" + vbCrLf
	 AddRespMethod = AddRespMethod + "	 * @param pageable" + vbCrLf
	 AddRespMethod = AddRespMethod + "	 * @return Page" + vbCrLf
	 AddRespMethod = AddRespMethod + "	 */" + vbCrLf
	 AddRespMethod = AddRespMethod + "	@Query(""select t from "+FirstCharToU(entity.Code)+" t "
	 For Each attr In entity.Attributes
		If Not attr.IsShortcut Then
			If Not attr.PrimaryIdentifier  Then
				If GetType(attr.DataType) = "java.lang.String" Then
					If countNum =0 Then
						AddRespMethod = AddRespMethod + "where t."+attr.Code +" like ?1 "
                    Else
                        AddRespMethod = AddRespMethod + "or t."+attr.Code +" like ?1 "
					End If
					countNum = countNum + 1
				End If
			End If
		End If
     Next
	 AddRespMethod = AddRespMethod + """)" + vbCrLf
	 AddRespMethod = AddRespMethod + "    public Page<"+FirstCharToU(entity.Code)+"> queryPage(String searchText,Pageable pageable);" + vbCrLf
	 AddRespMethod = AddRespMethod + vbCrLf

End Function



'�������
Function GetType(vtype)
  Dim regEx, patrn, typeStr,Match, Matches
  patrn = "\D*"
  Set regEx = New RegExp
  regEx.Pattern = patrn
  regEx.IgnoreCase = True
  Set Matches = regEx.Execute(vtype)
  
  For Each Match in Matches   ' ѭ������Matches���ϡ�
      typeStr = Match.Value
  Next
  
	Select Case typeStr
           Case "I"   GetType = "java.lang.Integer"
           Case "LI"  GetType = "java.lang.Long"
           Case "SI"  GetType = "java.lang.Short"

		   Case "BT"  GetType = "java.lang.Byte"

		   Case "N"  GetType = "java.lang.Double"
		   Case "DC"  GetType = "java.math.BigDecimal"

		   Case "F"   GetType = "java.lang.Float"
		   Case "SF"  GetType = "java.lang.Float"
		   Case "LF"  GetType = "java.lang.Float"


		   Case "MN"  GetType = "java.math.BigDecimal"
		   Case "NO"  GetType = "java.lang.Long"

		   Case "BL"  GetType = "java.lang.Boolean"

		   Case "A"   GetType = "java.lang.String"
		   Case "VA"  GetType = "java.lang.String"
		   Case "LA"  GetType = "java.lang.String"
		   Case "LVA" GetType = "java.lang.String"
		   Case "TXT" GetType = "java.lang.String"

		   Case "MBT"  GetType = "byte[]"
		   Case "VMBT" GetType = "byte[]"

		   Case "D"   GetType = "java.util.Date"
		   Case "T"   GetType = "java.util.Date"
		   Case "DT"  GetType = "java.util.Date"
		   Case "TS"  GetType = "java.util.Calendar"

		   Case "BIN"  GetType = "byte[]"
		   Case "LBIN" GetType = "byte[]"

		   Case "BMP"  GetType = "java.sql.Blob"
		   Case "PIC"  GetType = "java.sql.Blob"
		   Case "OLE"  GetType = "java.sql.Clob"

           Case Else GetType = vtype
    End Select
End Function

'����ĸ���д
Function FirstCharToU(vstr)
	Dim vLeftChar,vBackStr
	vLeftChar = Left(vstr, 1)
	vLeftChar = UCase(vLeftChar)
	vBackStr = Mid(vstr,2)
    FirstCharToU = vLeftChar + vBackStr
End Function


'����ĸ��Сд
Function FirstCharToL(vstr)
	Dim vLeftChar,vBackStr
	vLeftChar = Left(vstr, 1)
	vLeftChar = LCase(vLeftChar)
	vBackStr = Mid(vstr,2)
    FirstCharToL = vLeftChar + vBackStr
End Function