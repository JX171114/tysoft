' ��ģ��������ʵ��bean 

Option explicit

'rootPath -- �������Ŀ¼�Ĵ��·��
'rootPage -- ������·��
'tempPath -- �������ɵ���ʱĿ¼
Dim rootPath,rootPage,tempPath
'��ʵ���µİ���
Dim classPage
'fso -- FileSystemObject
'wshNetwork -- WScript.Network
'entityPath -- ����ʵ���·��
'author -- ע���ϵ���������
Dim fso,wshNetwork,entityPath
Dim table_top
table_top = ActivePackage.Comment + "_"
Set fso = CreateObject("Scripting.FileSystemObject")
'�������ƵĻ�ȡ
Set wshNetwork = CreateObject("WScript.Network")
'author = InputBox("��������","ע���ϵ���������",wshNetwork.UserName)
''On   Error   Resume   Next
If author="" Then
	author = wshNetwork.UserName
End If
''If   Err   <>   0   Then
''Dim author
''author = InputBox("��������","ע���ϵ���������",wshNetwork.UserName)
''End IF

'��ʱĿ¼������
Dim nowDate
nowDate = Date
'tempPath = CStr(nowDate) + "-temp"
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
		Output "����Ŀû�ж�������·��������Ĭ�ϵ����·�����ɡ�"
		Output "�Զ�������·����ο��������ã����û����Ĭ�����ɵ���vbs�ļ���ͬ���ļ����:"
		Output "����ConceptualDataModel��Comment������ע��:"
		Output "Դ�����·��"
		Output "���ɵ�ҳ��·��"
		Output "��������"
		Output "����:"
		Output "D:\projectPath\src\main\java"
		Output "D:\projectPath\src\main\resources\templates\project"
		Output "com.xmrbi.project"
		Output ""
		Output "<ע����1��Ϊ���ɵ�Դ����·������2��Ϊ���ɵ�ҳ��·������3��Ϊ��������>"
		'init = false
		'Exit Function
		rootPath = defaultRootPath
		Output "Դ�����·��:" + rootPath
		CreateRootPahtFolder fso,rootPath
		rootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)+".entity"
		Output "ʵ���·��:" + rootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		output "ʵ���Ӱ�·��:" + classPage
   Else
		rootPath = iniArray(0)
		Output "Դ�����·��:" + rootPath
		CreateRootPahtFolder fso,rootPath
		rootPage = Mid(iniArray(2),2)+".entity"
		Output "ʵ���·��:" + rootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		output "ʵ���Ӱ�·��:" + classPage
		'init = True
   End If
   init = True
End Function


Function getClassPage(pPage)
	Dim currentPage
   getClassPage = ""
   Set currentPage = pPage
  ' Do While currentPage.ClassName <> "Conceptual Data Model" 'ȥ��ѭ����ֻȡ�ϼ��İ���Ϣ 2013.7.22
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
Function CreateSelectEntityToJava()
   dim entity
   For Each entity In ActiveSelection 'ActiveModel.Entities
	If entity.ClassName = "Entity" Then
		EntityToJava entity
    End If
  Next
End Function

'����ʵ�������
Function EntityToJava(pEntity)
   Dim filepath,filepathUTF8
   filepath = tempPath + "\" + FirstCharToU(pEntity.Code) + ".java.gbk"
   filepathUTF8 = entityPath + "\" + FirstCharToU(pEntity.Code) + ".java"
   
   'If BackUpFile(filepathUTF8)=false then
   '   Exit Function
   'End If
   Dim file
   Set file = fso.OpenTextFile(filepath, 2, true)


   'importStr imports��
   'baseAttStr ��������
   'baseMethodStr��������
   'rsAttStr��������
   'rsMethodStr��������
   Dim importStr
   Dim baseAttStr,baseMethodStr
   Dim rsAttStr,rsMethodStr
   Dim parentEntity
   Dim entityAnnotateStr
   importStr = ""

   
   'д�������Ϣ
   WriteJavaTop(file)
   file.Write  vbCrLf
   file.Write  "package " + getClassPage(pEntity.GetPackage()) + ";"+vbCrLf
   file.Write vbCrLf
   
   parentEntity = getExtendEntity(pEntity,importStr)
   getBaseStr pEntity,importStr,baseAttStr,baseMethodStr 
   getRelationshipStr pEntity,importStr,rsAttStr,rsMethodStr
   
    'дimports
   
   
   'дʵ��ע��
   entityAnnotateStr = getEntityAnnotate(pEntity,importStr)
   file.Write importStr + vbCrLf+ vbCrLf

   file.Write entityAnnotateStr
   file.Write "public class " + FirstCharToU(pEntity.code) + " implements "+parentEntity+"{" + vbCrLf
   file.Write  vbCrLf
   'дʵ�幹�캯��
   WriteEntityConstruct file,pEntity 
   file.Write  vbCrLf
   'д����
   file.Write  baseAttStr
   file.Write  rsAttStr
   'д����
   file.Write  baseMethodStr
   file.Write  rsMethodStr

   'дvopo
   WritePoToVo file,pEntity
   'дjson
   WritePoToJson file,pEntity
   'дjsonMap
   WritePoToMap file,pEntity

   file.Write "}"
   'UTF-8ת��
   ConvertToUTF8 filepath,filepathUTF8
End Function


'д�ļ�ͷע��
Function WriteJavaTop(file)
	file.Write "/**" + vbCrLf
 	file.Write "* <p>Description: "+ActiveModel.name+" "+ ActiveModel.code +"</p>" + vbCrLf
 	file.Write "*" + vbCrLf
 	file.Write "* <p>Copyright: Copyright (c) "+ CStr(DatePart("yyyy",Date)) +"</p>" + vbCrLf
 	file.Write "*" + vbCrLf
 	file.Write "* <p>Company: ����·����Ϣ�ɷ����޹�˾</p>" + vbCrLf
 	file.Write "*" + vbCrLf
 	file.Write "* @author :" + author + vbCrLf
 	file.Write "* @version 1.0" + vbCrLf
 	file.Write "*/" + vbCrLf
End Function


'дʵ��ע��
Function getEntityAnnotate(pEntity,importStr)
   insertImportPage importStr,"java.util.HashMap" 
   insertImportPage importStr,"java.util.Map" 
   insertImportPage importStr,"java.text.SimpleDateFormat" 
   insertImportPage importStr,"javax.persistence.Entity" 
   insertImportPage importStr,"org.hibernate.annotations.Cache" 
   insertImportPage importStr,"org.hibernate.annotations.CacheConcurrencyStrategy"
   insertImportPage importStr,"org.hibernate.annotations.GenericGenerator"
   insertImportPage importStr,"org.springframework.format.annotation.DateTimeFormat"

   getEntityAnnotate =    "/**" + vbCrLf
   getEntityAnnotate = getEntityAnnotate +" * "+ pEntity.Name + " " + pEntity.Comment + vbCrLf
   getEntityAnnotate = getEntityAnnotate + " * �������� " + CStr(Date) + " "  + CStr(Time) + vbCrLf
   getEntityAnnotate = getEntityAnnotate + " */" + vbCrLf
   getEntityAnnotate = getEntityAnnotate + "@Entity" + vbCrLf
   getEntityAnnotate = getEntityAnnotate + "@Table(name="""+table_top + GetColumnStr(FirstCharToL(pEntity.Code))+""")"  + vbCrLf
   'getEntityAnnotate = getEntityAnnotate + "@Table(appliesTo="""+table_top + GetColumnStr(FirstCharToL(pEntity.Code))+""",comment="""+pEntity.name+""")"  + vbCrLf
   getEntityAnnotate = getEntityAnnotate + "@Inheritance(strategy = InheritanceType.JOINED)"  + vbCrLf
   getEntityAnnotate = getEntityAnnotate + "@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)"  + vbCrLf
End Function
'дʵ�幹�캯��
Function WriteEntityConstruct(file,pEntity)
   file.Write "    private static final long serialVersionUID = "+CStr(Int(Rnd*1000000*Rnd*1000000))+"L;" + vbCrLf+ vbCrLf
   file.Write "    public  " + FirstCharToU(pEntity.code) + "(){" + vbCrLf + "    }" + vbCrLf
   file.Write "    public  " + FirstCharToU(pEntity.code) + "(String id){" + vbCrLf 
   file.Write "      this.id = id;" + vbCrLf
   file.Write "    }" + vbCrLf
End Function

'дʵ�常��
Function getExtendEntity(pEntity,importStr)
   Dim parentObjs,p
   Set parentObjs = pEntity.InheritsFrom
   For Each p In parentObjs
		Dim parent,parentImport
		Set parent = p.ParentEntity
		getExtendEntity = FirstCharToU(parent.Code)
		Output FirstCharToU(parent.Code) + "'s IsShortcut = "+CStr(parent. IsShortcut())
		If parent. IsShortcut()=True Then 
			parentImport = getClassPage(parent.TargetPackage) + "." + FirstCharToU(parent.Code)
		    insertImportPage importStr,parentImport 
		End If
		Exit Function
   Next
   importStr = importStr + "import java.io.Serializable;"
   getExtendEntity = "Serializable"
End Function

Function insertImportPage(importStr,parentImport)
	
	Dim currentImport
    currentImport = "import "+parentImport  + ";"

	If InStr(importStr,currentImport)=0 Then 
		importStr = importStr + vbCrLf + currentImport 
		
	End If
End Function



'����ʵ�������
Function getBaseStr(pEntity,importStr,baseAttStr,baseMethodStr)
	Dim attr
    baseAttStr = ""
    baseMethodStr = ""
	For Each attr In pEntity.Attributes
			 If Not attr.IsShortcut Then 
				   baseAttStr = baseAttStr + AddBaseAttrib(attr)
				   baseMethodStr = baseMethodStr + AddBaseMethod(pEntity.Code,attr,importStr)
			 End If
			 
	Next
   
	
End Function


'�������Է���
Function AddBaseAttrib(attr)
	Dim tempComment 
	tempComment = attr.Name
	If Trim(attr.comment) <> "" then
		tempComment = tempComment + ":" + attr.Comment
	End If
	AddBaseAttrib = "    /**" + vbCrLf 
	AddBaseAttrib = AddBaseAttrib + "     * "+ tempComment + vbCrLf  
	AddBaseAttrib = AddBaseAttrib + "     */" + vbCrLf 
'	If attr.PrimaryIdentifier Then
'		AddBaseAttrib = AddBaseAttrib + "    private String " + FirstCharToL(attr.Code) + ";" + vbCrLf 
'	Else
	Dim td
	td = attr.DataType
'	Output attr.name + ":"+td +"--"+ cstr(attr.length) +"--"+ cstr(attr.Precision)
		AddBaseAttrib = AddBaseAttrib + "    private " + GetType(attr.DataType,attr.Length,attr.Precision) + " " + FirstCharToL(attr.Code) + ";" + vbCrLf 
'	End If 
	AddBaseAttrib = AddBaseAttrib + vbCrLf
End Function



'���ɷ���
Function AddBaseMethod(entityCode,attr,importStr)
     Dim hiberComment
	 hiberComment = ""
	 If attr.PrimaryIdentifier Then
		insertImportPage importStr,"javax.persistence.Id" 
		insertImportPage importStr,"javax.persistence.GeneratedValue" 
		insertImportPage importStr,"org.hibernate.annotations.GenericGenerator" 
		'insertImportPage importStr,"org.hibernate.annotations.Table" 
		insertImportPage importStr,"org.springframework.format.annotation.DateTimeFormat" 
	    insertImportPage importStr,"javax.persistence.Table" 
	    insertImportPage importStr,"javax.persistence.Inheritance" 
	    insertImportPage importStr,"javax.persistence.InheritanceType" 
	    insertImportPage importStr,"javax.persistence.Column" 

		 hiberComment = vbCrLf+"    @Id" + vbCrLf
		 hiberComment = hiberComment + "    @GenericGenerator(name=""idGenerator"", strategy=""uuid"")"+ vbCrLf
		 hiberComment = hiberComment + "    @GeneratedValue(generator=""idGenerator"")"+ vbCrLf
		 AddBaseMethod = hiberComment
		 AddBaseMethod = AddBaseMethod  + "    /**" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     *@return:"+ GetType(attr.DataType,attr.Length,attr.Precision) +" " + attr.Name + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     */" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "    @Column(length="+CStr(attr.Length)+")" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "    public "+ GetType(attr.DataType,attr.Length,attr.Precision) +" get" + FirstCharToU(attr.Code) + "(){"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "      return this." + FirstCharToL(attr.Code)+";"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "    }"

		 AddBaseMethod = AddBaseMethod + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "    /**" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     *@param:"+ GetType(attr.DataType,attr.Length,attr.Precision) +" " + attr.Name + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     */" + vbCrLf         
		 AddBaseMethod = AddBaseMethod  + "    public void set" + FirstCharToU(attr.Code) + "("+ GetType(attr.DataType,attr.Length,attr.Precision) +" " + FirstCharToL(attr.Code) + "){ "
		 AddBaseMethod = AddBaseMethod + vbCrLf + "      this." + FirstCharToL(attr.Code) + "=" + FirstCharToL(attr.Code) +";"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "    }"
		 AddBaseMethod = AddBaseMethod + vbCrLf
		 AddBaseMethod = AddBaseMethod + vbCrLf
	 Else 
		 AddBaseMethod = hiberComment
		 AddBaseMethod = AddBaseMethod  + "    /**" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     *@return:"+ GetType(attr.DataType,attr.Length,attr.Precision) +" " + attr.Name + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     */" + vbCrLf
	     If GetType(attr.DataType,attr.Length,attr.Precision) = "java.util.Date" Then
		 AddBaseMethod = AddBaseMethod  + "    @DateTimeFormat(pattern = ""yyyy-MM-dd HH:mm:ss"")" + vbCrLf
		 ElseIf GetType(attr.DataType,attr.Length,attr.Precision) = "java.lang.String" Then
		 AddBaseMethod = AddBaseMethod  + "    @Column(length="+CStr(attr.Length)+")" + vbCrLf
	     End If
		 AddBaseMethod = AddBaseMethod  + "    public "+ GetType(attr.DataType,attr.Length,attr.Precision) +" get" + FirstCharToU(attr.Code) + "(){"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "      return this." + FirstCharToL(attr.Code)+";"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "    }"

		 AddBaseMethod = AddBaseMethod + vbCrLf
         AddBaseMethod = AddBaseMethod  + "    /**" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     *@param:"+ GetType(attr.DataType,attr.Length,attr.Precision) +" " + attr.Name + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "     */" + vbCrLf
		 AddBaseMethod = AddBaseMethod  + "    public void set" + FirstCharToU(attr.Code) + "(" + GetType(attr.DataType,attr.Length,attr.Precision) + " " + FirstCharToL(attr.Code) + "){ "
		 AddBaseMethod = AddBaseMethod + vbCrLf + "      this." + FirstCharToL(attr.Code) + "=" + FirstCharToL(attr.Code) +";"
		 AddBaseMethod = AddBaseMethod + vbCrLf + "    }"
		 AddBaseMethod = AddBaseMethod + vbCrLf
		 AddBaseMethod = AddBaseMethod + vbCrLf
	 End If
End Function




Function getRelationshipStr(pEntity,importStr,rsAttStr,rsMethodStr)
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
					getManyToMany rs,roleName,pEntity,otherEntity,importStr,rsAttStr,rsMethodStr
				End If 
			'�Ƕ�Զ�
			Else 
				Dim objectNum,otherObjectNum
				objectNum = GetVaule(toCardinality,",",1)
				otherObjectNum = GetVaule(toCardinality,",",0)
				
				'���õ���һ�Զ�Ķ�Ӧ��ϵ roleNameΪ�ղ�����
				If objectNum = "n" And roleName <> "" Then
					'����һ�Զ�����Ժͷ���
					getOneToMany rs,roleName,otherEntity,importStr,rsAttStr,rsMethodStr
				End If 
				'���õ��Ƕ��һ�Ķ�Ӧ��ϵ
				If objectNum = "1"   Then
					'���ɶ��һ�����Ժͷ���
					getManyToOne rs,roleName,otherEntity,importStr,rsAttStr,rsMethodStr 
				End If
			End If
			
			If Trim(roleName)<> ""  And pEntity.GetPackage() <> otherEntity.GetPackage() Then 
					Dim otherImport
					otherImport = getClassPage(otherEntity.GetPackage()) + "." + FirstCharToU(otherEntity.Code)
					insertImportPage importStr,otherImport 
			End If
			doneRsCodes = doneRsCodes + rs.code+";"
		End If 
	Next
End Function

'��Զ��ϵ
Function getManyToMany(rs,roleName,pEntity,otherEntity,importStr,rsAttStr,rsMethodStr)
		rsAttStr = rsAttStr + "    /**"+ vbCrLf
		rsAttStr = rsAttStr + "     * "  + rs.Comment +" "+ otherEntity.name + vbCrLf
		rsAttStr = rsAttStr + "     */"+ vbCrLf
		insertImportPage importStr,"java.util.List" 
		insertImportPage importStr,"java.util.ArrayList" 
		insertImportPage importStr,getClassPage(otherEntity.GetPackage())+"."+FirstCharToU(otherEntity.code)

		rsAttStr = rsAttStr + "    private List<"+FirstCharToU(otherEntity.Code)+"> "+FirstCharToL(roleName) +" = new ArrayList<"+FirstCharToU(otherEntity.Code)+">();"+ vbCrLf
	    insertImportPage importStr,"javax.persistence.FetchType"
		insertImportPage importStr,"javax.persistence.CascadeType" 
		insertImportPage importStr,"javax.persistence.ManyToMany" 
		insertImportPage importStr,"javax.persistence.JoinTable" 
		insertImportPage importStr,"javax.persistence.JoinColumn" 
		'insertImportPage importStr,"javax.persistence.Table" 
	    insertImportPage importStr,"javax.persistence.Inheritance" 
	    insertImportPage importStr,"javax.persistence.InheritanceType" 
		insertImportPage importStr,"org.hibernate.annotations.Fetch"
		insertImportPage importStr,"org.hibernate.annotations.FetchMode"
		insertImportPage importStr,"org.hibernate.annotations.Cache"
		insertImportPage importStr,"org.hibernate.annotations.CacheConcurrencyStrategy"
		rsMethodStr = rsMethodStr + "    @ManyToMany "+ vbCrLf
		rsMethodStr = rsMethodStr + "    @JoinTable(name = """+GetColumnStr(rs.code)+""", "
		rsMethodStr = rsMethodStr + " joinColumns = { @JoinColumn(name = """+GetColumnStr(FirstCharToL(pEntity.code)) + "_id"") }, "
		rsMethodStr = rsMethodStr + " inverseJoinColumns = { @JoinColumn(name = """+GetColumnStr(FirstCharToL(otherEntity.code))+"_id"") })"+ vbCrLf
		rsMethodStr = rsMethodStr + "    @Fetch(FetchMode.SUBSELECT)"+ vbCrLf
		'rsMethodStr = rsMethodStr + "@OrderBy("""+id+""")"+ vbCrLf
		rsMethodStr = rsMethodStr + "    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE)"+ vbCrLf
		rsMethodStr = rsMethodStr + "    public List<"+FirstCharToU(otherEntity.code)+"> get"+FirstCharToU(roleName)+"() {"+ vbCrLf
		rsMethodStr = rsMethodStr + "       return "+FirstCharToL(roleName)+";"+ vbCrLf
		rsMethodStr = rsMethodStr + "    }"+ vbCrLf

		rsMethodStr = rsMethodStr + "    public void set"+FirstCharToU(roleName)+"(List<"+FirstCharToU(otherEntity.code)+"> "+FirstCharToL(roleName)+") {"+ vbCrLf
		rsMethodStr = rsMethodStr + "       this."+FirstCharToL(roleName)+" = "+FirstCharToL(roleName)+";"+ vbCrLf
		rsMethodStr = rsMethodStr + "    }"+ vbCrLf
End Function 
'һ�Զ��ϵ
Function getOneToMany(rs,roleName,otherEntity,importStr,rsAttStr,rsMethodStr)
	rsAttStr = rsAttStr + "    /**"+ vbCrLf
	rsAttStr = rsAttStr + "     * "  + rs.Comment +" "+ otherEntity.name + vbCrLf
	rsAttStr = rsAttStr + "     */"+ vbCrLf

	
	insertImportPage importStr,"java.util.List" 
	insertImportPage importStr,"java.util.ArrayList" 
	insertImportPage importStr,"javax.persistence.FetchType"
	insertImportPage importStr,"javax.persistence.OneToMany" 
	insertImportPage importStr,"javax.persistence.JoinColumn" 
	'insertImportPage importStr,"javax.persistence.Table" 
	insertImportPage importStr,"javax.persistence.Inheritance" 
	insertImportPage importStr,"javax.persistence.InheritanceType" 
	insertImportPage importStr,"org.hibernate.annotations.Fetch"
	insertImportPage importStr,"org.hibernate.annotations.FetchMode"
	insertImportPage importStr,"org.hibernate.annotations.Cache"
	insertImportPage importStr,"org.hibernate.annotations.CacheConcurrencyStrategy"
	insertImportPage importStr,"javax.persistence.OrderBy"
	insertImportPage importStr,"javax.persistence.CascadeType" 
	insertImportPage importStr,getClassPage(otherEntity.GetPackage())+"."+FirstCharToU(otherEntity.code)


	rsAttStr = rsAttStr + "    private List<"+FirstCharToU(otherEntity.code)+"> "+FirstCharToL(roleName)+" = new ArrayList<"+FirstCharToU(otherEntity.code)+">();"+ vbCrLf
	rsMethodStr = rsMethodStr + "    @OneToMany(cascade={CascadeType.ALL},fetch=FetchType.LAZY) "+ vbCrLf
    rsMethodStr = rsMethodStr + "    @JoinColumn(name="""+GetColumnStr(rs.name)+""")"+ vbCrLf 'GetColumnStr(rs.name)
    rsMethodStr = rsMethodStr + "    @Fetch(FetchMode.SUBSELECT)"+ vbCrLf
    rsMethodStr = rsMethodStr + "    @OrderBy(""id"")"+ vbCrLf
    rsMethodStr = rsMethodStr + "    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE)"+ vbCrLf
	rsMethodStr = rsMethodStr + "    public List<"+FirstCharToU(otherEntity.code)+"> get"+FirstCharToU(roleName)+"() {"+ vbCrLf
    rsMethodStr = rsMethodStr + "      return "+FirstCharToL(roleName)+";"+ vbCrLf
    rsMethodStr = rsMethodStr + "    }"+ vbCrLf
	rsMethodStr = rsMethodStr + vbCrLf
	rsMethodStr = rsMethodStr + "    public void set"+FirstCharToU(roleName)+"(List<"+FirstCharToU(otherEntity.code)+"> "+FirstCharToL(roleName)+") {"+ vbCrLf
    rsMethodStr = rsMethodStr + "      this."+FirstCharToL(roleName)+" = "+FirstCharToL(roleName)+";"+ vbCrLf
    rsMethodStr = rsMethodStr + "    }"+ vbCrLf
End Function 
'���һ��ϵ
Function getManyToOne(rs,roleName,otherEntity,importStr,rsAttStr,rsMethodStr)
	rsAttStr = rsAttStr + "    /**"+ vbCrLf
	rsAttStr = rsAttStr + "     * " + rs.Comment +" "+ otherEntity.name + vbCrLf
	rsAttStr = rsAttStr + "     */"+ vbCrLf

	If Trim(roleName)="" Then 
		rsAttStr = rsAttStr + "    private Long " + FirstCharToL(rs.name) + ";" + vbCrLf 
		rsAttStr = rsAttStr + vbCrLf
		rsMethodStr = rsMethodStr  + "    public Long get" + FirstCharToU(rs.name) + "(){"+ vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf + "      return this." + FirstCharToL(rs.name)+";"+ vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf + "    }"+ vbCrLf

		rsMethodStr = rsMethodStr + vbCrLf + "    public void set" + FirstCharToU(rs.name) + "(Long " + FirstCharToL(rs.name) + "){ "+ vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf + "      this." + FirstCharToL(rs.name) + "=" + FirstCharToL(rs.name) +";"+ vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf + "    }"+ vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf
		rsMethodStr = rsMethodStr + vbCrLf
	Else 
	    insertImportPage importStr,"javax.persistence.FetchType"
		insertImportPage importStr,"javax.persistence.ManyToOne" 
		insertImportPage importStr,"javax.persistence.ForeignKey" 
		insertImportPage importStr,"javax.persistence.JoinColumn" 
		insertImportPage importStr,"javax.persistence.CascadeType" 
		insertImportPage importStr,getClassPage(otherEntity.GetPackage())+"."+FirstCharToU(otherEntity.code)

		rsAttStr = rsAttStr + "    private " + FirstCharToU(otherEntity.code) + " " + FirstCharToL(roleName) + ";" + vbCrLf 
		rsAttStr = rsAttStr + vbCrLf
		
		rsMethodStr = rsMethodStr + "    @ManyToOne( cascade = {CascadeType.PERSIST}, fetch = FetchType.LAZY )" + vbCrLf 
		rsMethodStr = rsMethodStr + "    @JoinColumn(name="""+GetColumnStr(rs.name)+""",nullable = true,foreignKey=@ForeignKey(name=""fk_"+ GetColumnStr(rs.code) +"""))" + vbCrLf  'GetColumnStr(rs.name)
		rsMethodStr = rsMethodStr + "    public " + FirstCharToU(otherEntity.code) + " get" + FirstCharToU(roleName) + "() {" + vbCrLf 
		rsMethodStr = rsMethodStr + "       return " + FirstCharToL(roleName) + ";"+ vbCrLf 
		rsMethodStr = rsMethodStr + "    }" + vbCrLf 

		rsMethodStr = rsMethodStr + "    public void set" + FirstCharToU(roleName) + "(" + FirstCharToU(otherEntity.code) + " " + FirstCharToL(roleName) + ") {" + vbCrLf 
		rsMethodStr = rsMethodStr + "       this." + FirstCharToL(roleName) + " = " + FirstCharToL(roleName) + ";" + vbCrLf 
		rsMethodStr = rsMethodStr + "    }" + vbCrLf 
	End If 
	
	

End Function 

'дʵ��PoToVo
Function WritePoToVo(file,pEntity)
    file.Write "" + vbCrLf
    file.Write "    /**PoToVo*/" + vbCrLf
	file.Write "    public "++FirstCharToU(pEntity.Code)+" poToVo() {" + vbCrLf
	file.Write "        "+FirstCharToU(pEntity.Code)+ " vo = new "+FirstCharToU(pEntity.Code)+ "();"+ vbCrLf
	Dim attr
	For Each attr In pEntity.Attributes
			 If Not attr.IsShortcut Then 
					If attr.PrimaryIdentifier Then
						file.Write "        vo.setId(this.id);"+ vbCrLf
				   Else
						file.Write "        vo.set"+FirstCharToU(attr.Code)+"(this."+FirstCharToL(attr.code)+");"+ vbCrLf
				   End If
			 End If		 
	Next
	file.Write "       return vo;"+ vbCrLf
	file.Write "    }"+ vbCrLf
	
	
End Function

'дʵ��PoToJson
Function WritePoToJson(file,pEntity)
    file.Write "" + vbCrLf
    file.Write "    /**PoToJson*/" + vbCrLf
	file.Write "    public String poToJson() {" + vbCrLf
	file.Write "    	SimpleDateFormat sdf = new SimpleDateFormat(""yyyy-MM-dd HH:mm:ss"");"+ vbCrLf
	file.Write "    	StringBuilder sb = new StringBuilder(""{"");"+ vbCrLf
	Dim attr,num
	num = 0
	For Each attr In pEntity.Attributes
		 If Not attr.IsShortcut Then 
		       If num > 0 Then
			      file.Write "        sb.append("","");"+ vbCrLf
			   End If
			   If GetType(attr.DataType,attr.Length,attr.Precision)<> "java.util.Date" Then
			      file.Write "        sb.append(""\"""+FirstCharToL(attr.Code)+"\"":\"""").append(this.get"+FirstCharToU(attr.code)+"()).append(""\"""");"+ vbCrLf
			   Else
			      file.Write "        sb.append(""\"""+FirstCharToL(attr.Code)+"\"":\"""").append(this.get"+FirstCharToU(attr.code)+"() == null ? null : sdf.format(this.get"+FirstCharToU(attr.code)+"())).append(""\"""");"+ vbCrLf
			   End If
			   num = num + 1
		 End If
	Next
	file.Write "        sb.append(""}"");"+ vbCrLf
	file.Write "        return sb.toString();"+ vbCrLf
	file.Write "    }"+ vbCrLf
End Function

'дʵ��PoToMap
Function WritePoToMap(file,pEntity)
    file.Write "" + vbCrLf
    file.Write "    /**PoToMap*/" + vbCrLf
	file.Write "    public Map<String, Object> poToMap() {" + vbCrLf
	file.Write "    	SimpleDateFormat sdf = new SimpleDateFormat(""yyyy-MM-dd HH:mm:ss"");"+ vbCrLf
	file.Write "    	Map<String, Object> jsonMap = new HashMap<String, Object>();"+ vbCrLf
	Dim attr
	For Each attr In pEntity.Attributes
		 If Not attr.IsShortcut Then 
			   If GetType(attr.DataType,attr.Length,attr.Precision) = "java.util.Date" Then
			      file.Write "        jsonMap.put("""+FirstCharToL(attr.Code)+""",this."+FirstCharToL(attr.code)+" == null ? null : sdf.format(this."+FirstCharToL(attr.code)+"));"+ vbCrLf
			   Else
			      file.Write "        jsonMap.put("""+FirstCharToL(attr.Code)+""",this."+FirstCharToL(attr.code)+");"+ vbCrLf
			   End If
		 End If
	Next

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
			
			'�Ƕ�Զ�
			If rsType <> 3 Then
				Dim objectNum,otherObjectNum
				objectNum = GetVaule(toCardinality,",",1)
				otherObjectNum = GetVaule(toCardinality,",",0)
				
				'���õ��Ƕ��һ�Ķ�Ӧ��ϵ
				If objectNum = "1"   Then
					'���ɶ��һ�����Ժͷ���
					file.Write "        jsonMap.put("""+FirstCharToL(roleName)+""", this."+FirstCharToL(roleName)+"==null?null:this."+FirstCharToL(roleName)+".poToMap());"+ vbCrLf
				End If
			End If
			doneRsCodes = doneRsCodes + rs.code+";"
		End If 
	Next

	file.Write "        return jsonMap;"+ vbCrLf
	file.Write "    }"+ vbCrLf
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
           Case "I"   GetType = "java.lang.Integer"
           Case "LI"  GetType = "java.lang.Long"
           Case "SI"  GetType = "java.lang.Short"

		   Case "BT"  GetType = "java.lang.Byte"
           
		   Case "N"  
			If vPrecision = 0 Then
				GetType = "java.lang.Long"
			Else 
				GetType = "java.lang.Double"
			End If 
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

'��ȡ�ֶ�ע��
Function GetColumnComment(attr)
    Dim colComment
    If GetType(attr.DataType,attr.Length,attr.Precision) = "java.lang.String" Then
		 GetColumnComment = "@Column(name = """+GetColumnStr(FirstCharToL(attr.Code))+""",length="+CStr(attr.Length)+",columnDefinition=""COMMENT '"+attr.name+"'"")"
	Else
		 GetColumnComment = "@Column(name = """+GetColumnStr(FirstCharToL(attr.Code))+""",columnDefinition=""COMMENT '"+attr.name+"'"")"
	End If
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
