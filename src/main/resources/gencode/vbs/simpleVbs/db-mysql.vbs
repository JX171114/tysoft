' ��ģ��������ʵ��bean 

Option explicit

'rootPath -- �������Ŀ¼�Ĵ��·��
'rootPage -- ������·��
'tempPath -- �������ɵ���ʱĿ¼
Dim rootPath,rootPage,tempPath,defaultDbRootPath
defaultDbRootPath = "..\db"
'��ʵ���µİ���
Dim classPage
'fso -- FileSystemObject
'wshNetwork -- WScript.Network
'entityPath -- ����ʵ���·��
'author -- ע���ϵ���������
Dim fso,wshNetwork,entityPath
Dim table_top,ref_table_top
table_top = ActivePackage.Comment + "_"
ref_table_top = table_top
Set fso = CreateObject("Scripting.FileSystemObject")
'�������ƵĻ�ȡ
Set wshNetwork = CreateObject("WScript.Network")
'author = InputBox("��������","ע���ϵ���������",wshNetwork.UserName)
If author="" Then
	author = wshNetwork.UserName
End If


'��ʱĿ¼������
'Dim nowDate
'nowDate = Date
'tempPath = CStr(nowDate) + "-temp"
tempPath = "_temp"
If fso.FolderExists(tempPath) then
	fso.DeleteFolder (tempPath)
End If
fso.CreateFolder(tempPath)

If init() Then
  'Ŀ¼�Ĵ���
  'entityPath = CreateEntityPageFolder(fso, rootPath, classPage)
   entityPath = defaultRootPath
   Output "����Mysql��������ļ�..."
   CreateSelectEntityToSql()
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
		'Output "Դ�����·��:" + rootPath
		CreateRootPahtFolder fso,rootPath
		CreateRootPahtFolder fso,defaultDbRootPath
		rootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)+".entity"
		'Output "ʵ���·��:" + rootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		'output "classPage:" + classPage
   Else
		rootPath = iniArray(0)
		'Output "Դ�����·��:" + rootPath
		CreateRootPahtFolder fso,rootPath
		rootPage = Mid(iniArray(2),2)+".entity"
		'Output "ʵ���·��:" + rootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		'output "classPage:" + classPage

   End If
   init = True
End Function


Function getClassPage(pPage)
	Dim currentPage
   getClassPage = ""
   Set currentPage = pPage
  ' Do While currentPage.ClassName <> "Conceptual Data Model" 'ȥ��ѭ����ֻȡ�ϼ��İ���Ϣ
  	  getClassPage = LCase(currentPage.code) + "." + getClassPage 
      
  	  Set currentPage = currentPage.GetPackage()
  ' Loop
   If getClassPage <> "" Then
	 getClassPage =  rootPage + "." + Left(getClassPage,Len(getClassPage)-1)
   Else
     getClassPage = rootPage
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
	  Output "ʵ��Ŀ¼��" + CreateEntityPageFolder
    Next
    
End Function

'�����ļ���
Function CreateFolder (vfso, vpath)
   Set CreateFolder = nothing
   If vfso.FolderExists(vpath) then
     Set CreateFolder = vfso.GetFolder(vpath)
	 'output "�Ѵ����ļ���: " + vpath
	 Exit Function
   Else 
     output "�����ļ���: " + vpath
     Set CreateFolder = vfso.CreateFolder(vpath)
	 'Output "�����ļ��гɹ�"
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
		backupDir = "backup\"+Replace(CStr(Now()),":","-")
		CreateFolder fso, backupDir
		output pOldFileName
		Set oldFile = fso.GetFile(pOldFileName)
		oldFile.Move (backupDir + "\" + fileName)
		BackUpFile = true
    End If
	BackUpFile = true
End Function



'��ѡ��Ķ�������java����
Function CreateSelectEntityToSql()
   dim entity
   For Each entity In ActiveSelection 'ActiveModel.Entities
	If entity.ClassName = "Entity" Then
		EntityToSql entity
    End If
  Next
End Function

'����ʵ����SQL����
Function EntityToSql(pEntity)
   Dim filepath,filepathUTF8
   filepath = tempPath + "\mysql-" + table_top + GetColumnStr(FirstCharToL(pEntity.Code)) + ".sql.gbk"
   filepathUTF8 = defaultDbRootPath + "\mysql-" + table_top + GetColumnStr(FirstCharToL(pEntity.Code)) + ".sql"

   Dim file
   Set file = fso.OpenTextFile(filepath, 2, true)

   'priAttr ����
   'baseAttStr ��������
   'rsAttStr��������
   Dim priAttr,rsCol
   Dim baseAttStr
   Dim rsAttStr
   Dim parentEntity
   Dim entityAnnotateStr
   
   'д�������Ϣ
   'file.Write  "-- �����ΪUTF-8�����ʽ������mysql���ߵ������и��ļ���������EditPlus�����ΪUTF-8���룩"  + vbCrLf
   file.Write  "-- Date:" + CStr(Date) + " "  + CStr(Time) + vbCrLf
   file.Write  "-- author:" + author + vbCrLf + vbCrLf
   file.Write  "SET FOREIGN_KEY_CHECKS=0; " +vbCrLf
   file.Write vbCrLf
   
   getBaseStr pEntity,priAttr,baseAttStr 
   getRelationshipStr pEntity,rsCol,rsAttStr
  
   file.Write "-- DROP TABLE IF EXISTS `"+table_top + GetColumnStr(FirstCharToL(pEntity.Code))+"`;" + vbCrLf
   file.Write "CREATE TABLE `"+table_top + GetColumnStr(FirstCharToL(pEntity.Code))+"` ("+vbCrLf

   'д����
   file.Write  baseAttStr
   file.Write  rsAttStr

   file.Write priAttr
   file.Write ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='"+pEntity.Name+"';"
   'UTF-8ת��
   ConvertToUTF8 filepath,filepathUTF8
  ' WriteToFile filepathUTF8, ReadFile(filepath, "utf-8"), "utf-8"
End Function

'����ʵ�������
Function getBaseStr(pEntity,priAttr,baseAttStr)
	Dim attr,iden
    baseAttStr = ""
	For Each attr In pEntity.Attributes
		If Not attr.IsShortcut Then 
			If attr.PrimaryIdentifier Then
				priAttr = "  PRIMARY KEY (`" + FirstCharToL(attr.Code) + "`)" + vbCrLf 
				
			End If
			baseAttStr = baseAttStr + AddBaseAttrib(attr)
		End If	 
	Next  
End Function


'�������Է���
Function AddBaseAttrib(attr) 
    Dim isnull
	isnull = " DEFAULT NULL "
	If attr.Mandatory Then
		isnull = " NOT NULL "
	End If
	'Output attr.name + ":"+attr.DataType +"--"+ cstr(attr.length) +"--"+ cstr(attr.Precision)
	AddBaseAttrib = AddBaseAttrib + "  `"+GetColumnStr(FirstCharToL(attr.Code))+"` " + GetType(attr.DataType,attr.Length,attr.Precision) + isnull + " COMMENT '" + attr.Name + attr.Comment+ "'," + vbCrLf 
End Function


Function getRelationshipStr(pEntity,rsCol,rsAttStr)
	Dim rs,doneRsCodes
	doneRsCodes = ";"
    For Each rs In pEntity.relationships
		If InStr(doneRsCodes,";"+rs.code+";")=0 Then 
			Dim rsType,otherEntity,roleName,otheRroleName,toCardinality
			'rs.RelationshipType
			'(0) One-to-one <1..1> 
			'(1) One-to-many <1..n> 
			'(2) Many-to-one
			'(3) Many-to-many
			rsType = rs.RelationshipType
			If pEntity = rs.Entity1 Or (rs.Entity1.IsShortcut() And pEntity.code = rs.Entity1.code) Then
				Set otherEntity = rs.Entity2
				If rs.Entity2.IsShortcut() Then
					Set otherEntity = rs.Entity2.TargetObject
				End If 
				roleName = rs.Entity1ToEntity2Role
				otheRroleName = rs.Entity2ToEntity1Role
				toCardinality = rs.Entity1ToEntity2RoleCardinality	
			End If
			If pEntity = rs.Entity2 Or (rs.Entity2.IsShortcut() And pEntity.code = rs.Entity2.code) Then
				 Set otherEntity = rs.Entity1
				 If rs.Entity1.IsShortcut() Then
					Set otherEntity = rs.Entity1.TargetObject
				 End If 
				 roleName = rs.Entity2ToEntity1Role
				 otheRroleName = rs.Entity1ToEntity2Role
				 toCardinality = rs.Entity2ToEntity1RoleCardinality		
			End If
			
			'��Զ�������
			If rsType = 3 Then
				If Trim(roleName)<>"" Then 
					'���ɶ�Զ�����Ժͷ���
					getManyToMany rs,roleName,pEntity,otherEntity
				End If 
			'�Ƕ�Զ�
			Else 
				Dim objectNum,otherObjectNum
				objectNum = GetVaule(toCardinality,",",1)
				otherObjectNum = GetVaule(toCardinality,",",0)
				
				'���õ���һ�Զ�Ķ�Ӧ��ϵ roleNameΪ�ղ�����
				If objectNum = "n" And roleName <> "" Then
					'����һ�Զ�����Ժͷ���
					getOneToMany rs,roleName,otherEntity,rsCol,rsAttStr
				End If 
				'���õ��Ƕ��һ�Ķ�Ӧ��ϵ
				If objectNum = "1"   Then
					'���ɶ��һ�����Ժͷ���
					getManyToOne rs,roleName,otherEntity,rsCol,rsAttStr 
				End If
			End If
			
			If Trim(roleName)<> ""  And pEntity.GetPackage() <> otherEntity.GetPackage() Then 
					Dim otherImport
					otherImport = getClassPage(otherEntity.GetPackage()) + "." + FirstCharToU(otherEntity.Code)
			End If
			doneRsCodes = doneRsCodes + rs.code+";"
		End If 
	Next
End Function

'��Զ��ϵ
Function getManyToMany(rs,roleName,pEntity,otherEntity)
   Dim filepath,filepathUTF8,rsAttStr,attr
   filepath = tempPath + "\mysql-" + rs.code + ".sql.gbk"
   filepathUTF8 = defaultDbRootPath + "\mysql-" + rs.code + ".sql"

   Dim file
   Set file = fso.OpenTextFile(filepath, 2, true)
   
   'д�������Ϣ
   file.Write  "-- �����ΪUTF-8�����ʽ������mysql���ߵ������и��ļ���������EditPlus�����ΪUTF-8���룩"  + vbCrLf
   file.Write  "-- Date:" + CStr(Date) + " "  + CStr(Time) + vbCrLf
   file.Write  "-- author:" + author + vbCrLf + vbCrLf
   file.Write  "SET FOREIGN_KEY_CHECKS=0; " +vbCrLf
   file.Write vbCrLf
  
   file.Write "DROP TABLE IF EXISTS "+rs.code+";" + vbCrLf+ vbCrLf
   file.Write "CREATE TABLE "+rs.code+" ("+vbCrLf

   'д����
   For Each attr In pEntity.Attributes
		If Not attr.IsShortcut Then 
			If attr.PrimaryIdentifier Then
				rsAttStr = rsAttStr + "  `"+ GetColumnStr(FirstCharToL(pEntity.Code)) +"_id` "+ GetType(attr.DataType,attr.Length,attr.Precision) +" NOT NULL COMMENT '"+pEntity.Name+"',"+ vbCrLf
				rsAttStr = rsAttStr + "  KEY `idx_"+GetColumnStr(FirstCharToL(pEntity.Code))+"_"+ rs.code +"` (`"+ GetColumnStr(FirstCharToL(pEntity.Code))+"_id`) USING BTREE,"+ vbCrLf
				rsAttStr = rsAttStr + "  CONSTRAINT `fk_"+ GetColumnStr(FirstCharToL(pEntity.Code))+"_"+ rs.code +"` FOREIGN KEY (`"+ GetColumnStr(FirstCharToL(pEntity.Code)) +"_id`) REFERENCES `"+table_top + GetColumnStr(FirstCharToL(pEntity.Code))+"` (`"+attr.Code+"`),"+ vbCrLf
			End If
		End If	 
	Next

   For Each attr In otherEntity.Attributes
   ref_table_top = otherEntity.GetPackage().Comment + "_"
		If Not attr.IsShortcut Then 
			If attr.PrimaryIdentifier Then
				rsAttStr = rsAttStr + "  `"+ GetColumnStr(FirstCharToL(otherEntity.Code)) +"_id` "+ GetType(attr.DataType,attr.Length,attr.Precision) +" NOT NULL COMMENT '"+otherEntity.Name+"',"+ vbCrLf
				rsAttStr = rsAttStr + "  KEY `idx_"+GetColumnStr(FirstCharToL(otherEntity.Code))+"_"+ rs.code +"` (`"+ GetColumnStr(FirstCharToL(otherEntity.Code)) +"_id`) USING BTREE,"+ vbCrLf
				rsAttStr = rsAttStr + "  CONSTRAINT `fk_"+ GetColumnStr(FirstCharToL(otherEntity.Code))+"_"+ rs.code +"` FOREIGN KEY (`"+ GetColumnStr(FirstCharToL(otherEntity.Code)) +"_id`) REFERENCES `"+ref_table_top + GetColumnStr(FirstCharToL(otherEntity.Code))+"` (`"+attr.Code+"`),"+ vbCrLf
			End If
		End If	 
	Next
	rsAttStr = rsAttStr + "  PRIMARY KEY (`"+ GetColumnStr(FirstCharToL(pEntity.Code)) +"_id`,`"+ GetColumnStr(FirstCharToL(otherEntity.Code)) +"_id`)"
   file.Write rsAttStr+vbCrLf
   file.Write ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='"+rs.Comment+"';"
   'UTF-8ת��
   ConvertToUTF8 filepath,filepathUTF8
End Function 

'һ�Զ��ϵ
Function getOneToMany(rs,roleName,otherEntity,rsCol,rsAttStr)
   Dim attr
   ref_table_top = otherEntity.GetPackage().Comment + "_"
   For Each attr In otherEntity.Attributes
		If Not attr.IsShortcut Then 
			If attr.PrimaryIdentifier Then
				rsAttStr = rsAttStr + "  `"+ GetColumnStr(rs.name) +"` "+ GetType(attr.DataType,attr.Length,attr.Precision) +" DEFAULT NULL COMMENT '"+otherEntity.Name+"',"+ vbCrLf
				rsAttStr = rsAttStr + "  KEY `"+ GetColumnStr(rs.code) +"` (`"+ GetColumnStr(rs.name) +"`) USING BTREE,"+ vbCrLf
				rsAttStr = rsAttStr + "  CONSTRAINT `fk_"+ GetColumnStr(rs.code) +"` FOREIGN KEY (`"+ GetColumnStr(rs.name) +"`) REFERENCES `"+ref_table_top + GetColumnStr(FirstCharToL(otherEntity.Code))+"` (`"+attr.Code+"`),"+ vbCrLf
			End If
		End If	 
	Next 
End Function 

'���һ��ϵ
Function getManyToOne(rs,roleName,otherEntity,rsCol,rsAttStr)
   Dim attr
'  If otherEntity.IsShortcut() = true Then
	ref_table_top = otherEntity.GetPackage().Comment + "_"
'   End If
   For Each attr In otherEntity.Attributes
		If Not attr.IsShortcut Then 
			If attr.PrimaryIdentifier Then
				rsAttStr = rsAttStr + "  `"+ GetColumnStr(rs.name) +"` "+ GetType(attr.DataType,attr.Length,attr.Precision) +" DEFAULT NULL COMMENT '"+otherEntity.Name+"',"+ vbCrLf
				rsAttStr = rsAttStr + "  KEY `"+ GetColumnStr(rs.code) +"` (`"+ GetColumnStr(rs.name) +"`) USING BTREE,"+ vbCrLf
				rsAttStr = rsAttStr + "  CONSTRAINT `fk_"+ GetColumnStr(rs.code) +"` FOREIGN KEY (`"+ GetColumnStr(rs.name) +"`) REFERENCES `"+ref_table_top + GetColumnStr(FirstCharToL(otherEntity.Code))+"` (`"+attr.Code+"`),"+ vbCrLf
			End If
		End If	 
	Next 
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


'�������
Function GetType(vtype,vLength,vPrecision)

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
           Case "I"   GetType = "INT(20)"
           Case "LI"  GetType = "INT(20)"
           Case "SI"  GetType = "INT(20)"

		   Case "BT"  GetType = "VARCHAR("+vLength+")"
           
		   Case "N"  
			If vPrecision = 0 Then
				GetType = "BIGINT(20)"
			Else 
				GetType = "DOUBLE("+cstr(vLength)+","+vPrecision+")"
			End If 
		   Case "DC"  GetType = "DECIMAL("+cstr(vLength)+","+cstr(vPrecision)+")"

		   Case "F"   GetType = "FLOAT("+cstr(vLength)+","+cstr(vPrecision)+")"
		   Case "SF"  GetType = "FLOAT("+cstr(vLength)+","+cstr(vPrecision)+")"
		   Case "LF"  GetType = "FLOAT("+cstr(vLength)+","+cstr(vPrecision)+")"

		   Case "MN"  GetType = "DECIMAL("+cstr(vLength)+","+cstr(vPrecision)+")"
		   Case "NO"  GetType = "BIGINT(20)"

		   Case "BL"  GetType = "BOOLEAN"

		   Case "A"   GetType = "VARCHAR("+cstr(vLength)+")"
		   Case "VA"  GetType = "VARCHAR("+cstr(vLength)+")"
		   Case "LA"  GetType = "VARCHAR("+cstr(vLength)+")"
		   Case "LVA" GetType = "VARCHAR("+cstr(vLength)+")"
		   Case "TXT" GetType = "VARCHAR("+cstr(vLength)+")"

		   Case "MBT"  GetType = "BINARY"
		   Case "VMBT" GetType = "BINARY"

		   Case "D"   GetType = "DATE"
		   Case "T"   GetType = "TIME"
		   Case "DT"  GetType = "DATETIME"
		   Case "TS"  GetType = "TIMESTAMP"

		   Case "BIN"  GetType = "BINARY"
		   Case "LBIN" GetType = "BINARY"

		   Case "BMP"  GetType = "BLOB"
		   Case "PIC"  GetType = "BLOB"
		   Case "OLE"  GetType = "CLOB"

           Case Else GetType = vtype
    End Select
End Function


'ȡ�÷ָ���ֽ������ĵ�N��ֵ
Function GetVaule(vstr,vsign,vnum)
	Dim tempArray,length
    tempArray = Split(vstr, vsign)
	length = UBound(tempArray)
	if vnum > length Then 
	 GetVaule = null
	Else
	 GetVaule = tempArray(vnum)
	End If
End Function



'��ȡ�շ�����
Function GetColumnStr(vstr)
	Dim vLeftChar
	Dim strLen
	Dim k
	Dim newStr
	Dim bigLen
	strLen = Len(vstr)
	newStr = Left(vstr,1)
	bigLen = 0
	If newStr >=  "A"  and newStr <=  "Z"  Then
		bigLen = 1
	End If
	For k = 2 To strLen
       vLeftChar = Mid(vstr, k,1)
	   If vLeftChar >=  "A"  and vLeftChar <=  "Z"  Then
			bigLen = bigLen + 1
			If  Mid(vstr, k-1,1)<>"_"   Then
				newStr = newStr + "_" 
				
			End If
	   End If
	   newStr = newStr + LCase(vLeftChar)
    Next

	If bigLen = strLen Then
		GetColumnStr = vstr
	Else
		GetColumnStr = newStr
	End If
	
End Function

'-----------------------------------------------------------------------------------------
Function toUTF8(szInput)
    Dim wch, uch, szRet
    Dim x
    Dim nAsc, nAsc2, nAsc3
    '����������Ϊ�գ����˳�����
    If szInput = "" Then
        toUTF8 = szInput
        Exit Function
    End If
    '��ʼת��
     For x = 1 To Len(szInput)
        '����mid�����ֲ�GB��������
        wch = Mid(szInput, x, 1)
        '����ascW��������ÿһ��GB�������ֵ�Unicode�ַ�����
        'ע��asc�������ص���ANSI �ַ����룬ע������
        nAsc = AscW(wch)
        If nAsc < 0 Then nAsc = nAsc + 65536
    
        If (nAsc And &HFF80) = 0 Then
            szRet = szRet & wch
        Else
            If (nAsc And &HF000) = 0 Then
                uch = "%" & Hex(((nAsc / 2 ^ 6)) Or &HC0) & Hex(nAsc And &H3F Or &H80)
                szRet = szRet & uch
            Else
               'GB�������ֵ�Unicode�ַ�������0800 - FFFF֮��������ֽ�ģ��
                uch = "%" & Hex((nAsc / 2 ^ 12) Or &HE0) & "%" & _
                            Hex((nAsc / 2 ^ 6) And &H3F Or &H80) & "%" & _
                            Hex(nAsc And &H3F Or &H80)
                szRet = szRet & uch
            End If
        End If
    Next
        
    toUTF8 = szRet
End Function

Dim SrcCode,DestCode,stm
SrcCode="gb2312"
DestCode="utf-8"
'-------------------------------------------------
'��������:ConvertFile
'����:��һ���ļ����б���ת��
'-------------------------------------------------
Function ConvertFile(FileUrl)
    Call WriteToFile(FileUrl, ReadFile(FileUrl, SrcCode), DestCode)
End Function
'-------------------------------------------------
'��������:ReadFile
'����:����AdoDb.Stream��������ȡ���ָ�ʽ���ı��ļ�
'-------------------------------------------------
Function ReadFile(FileUrl, CharSet)
    Dim Str
    Set stm = CreateObject("Adodb.Stream")
    stm.Type = 2
    stm.mode = 3
    stm.charset = CharSet
    stm.Open
    stm.loadfromfile FileUrl
    Str = stm.readtext
    stm.Close
    Set stm = Nothing
    ReadFile = Str
End Function
'-------------------------------------------------
'��������:WriteToFile
'����:����AdoDb.Stream������д����ָ�ʽ���ı��ļ�
'-------------------------------------------------
Function WriteToFile (FileUrl, Str, CharSet)
    Set stm = CreateObject("Adodb.Stream")
	stm.Position = 0
    stm.Type = 2
    stm.mode = 3
    stm.charset = CharSet
    stm.Open
    stm.WriteText Str
    stm.SaveToFile FileUrl, 2
    stm.flush
    stm.Close
    Set stm = Nothing
End Function