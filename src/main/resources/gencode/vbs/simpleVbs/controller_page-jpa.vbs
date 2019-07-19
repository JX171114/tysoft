' ��ģ��������ʵ��bean

Option explicit
Do 
'rootPath -- �������Ŀ¼�Ĵ��·��
'rootPage -- ������·��
'tempPath -- �������ɵ���ʱĿ¼
Dim rootPath,rootPage,tempPath,entityPage,servicePage,webPage
'��ʵ���µİ���
Dim classPage,controllerPackage
Dim templateNo
Dim modelPage
modelPage = "pageModels\model.html" 'ģ��ҳ��·��
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
If author="" Then
	author = wshNetwork.UserName
End If

templateNo = "page"'InputBox("1.һ��ҳ�棬2.��ҳ��,3.�����б�ҳ��","�������ɵ�ģ����","1")

'If (templateNo<>"1" And templateNo<>"2" And templateNo<>"3") Then
'	MsgBox("ҳ��ģ�����ѡ��1��2��������ִ�У���")
'	Exit Do  
'End If


  
'��ʱĿ¼������
tempPath = "_temp1"
If fso.FolderExists(tempPath) then
	fso.DeleteFolder(tempPath)
End If
fso.CreateFolder(tempPath)
Output "��ʱ�ļ�Ŀ¼:"+tempPath


If init() Then
  'Ŀ¼�Ĵ���
   entityPath = CreateEntityPageFolder(fso, rootPath, classPage)
   'CreateFolder fso, webPage
   CreateSelectEntityToJava()

End If
fso.DeleteFolder (tempPath)
Exit Do  
Loop 

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
		rootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)
		controllerPackage = defaultRootPackage+FirstCharToL(ActiveModel.code)+".controller"
		CreateEntityPageFolder fso,rootPath,controllerPackage
	    Output "controller��·��:" + controllerPackage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		output "classPage:" + classPage
		entityPage = defaultRootPackage+FirstCharToL(ActiveModel.code) +".entity." +  FirstCharToL(ActivePackage.Code)
		servicePage = defaultRootPackage+FirstCharToL(ActiveModel.code) +".service." + FirstCharToL(ActivePackage.Code)
		webPage = defaultWebPage+"\" + FirstCharToL(ActivePackage.Code)
		output "��ҳ·��= " + webPage
		CreateRootPahtFolder fso, webPage
   Else
		rootPath = iniArray(0)
		Output "Դ�����·��=" + rootPath
		rootPage = Mid(iniArray(1),2)
		Output "ҳ������·��=" + rootPage
		CreateRootPahtFolder fso,rootPath
		controllerPackage = Mid(iniArray(2),2)+".controller"
		CreateEntityPageFolder fso,rootPath,controllerPackage
		classPage = getClassPage(ActiveDiagram.GetPackage())
		output "classPage= " + classPage
		entityPage = Mid(iniArray(2),2) +".entity." + FirstCharToL(ActivePackage.Code)
		servicePage = Mid(iniArray(2),2) +".service." + FirstCharToL(ActivePackage.Code)
		webPage = Mid(iniArray(1),2)+"\" + FirstCharToL(ActivePackage.Code)
		output "��ҳ·��= " + webPage
		CreateRootPahtFolder fso, webPage
   End If
   init = True
End Function


Function getClassPage(pPage)
	Dim currentPage
   getClassPage = ""
   Set currentPage = pPage
  ' Do While currentPage.ClassName <> "Conceptual Data Model"'ȥ��ѭ����ֻȡ�ϼ��İ���Ϣ
	  getClassPage = LCase(currentPage.code) + "." + getClassPage 
      
	  Set currentPage = currentPage.GetPackage()
  ' Loop
   If getClassPage <> "" Then
	 getClassPage =  controllerPackage + "." + Left(getClassPage,Len(getClassPage)-1)
   Else
     getClassPage = controllerPackage
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
	  Output "controllerĿ¼��" + CreateEntityPageFolder
    Next
    
End Function

'�����ļ���
Function CreateFolder (vfso, vpath)
   Set CreateFolder = nothing
   If vfso.FolderExists(vpath) then
     Set CreateFolder = vfso.GetFolder(vpath)
	 'Output "�Ѵ����ļ���: " + vpath
	 Exit Function
   Else
      Output "�����ļ���: " + vpath
     Set CreateFolder = vfso.CreateFolder(vpath)
	 
   End If 
End Function
'END-------------------Ŀ¼�Ĵ���



'��ѡ��Ķ�������java����
Function CreateSelectEntityToJava()
   dim entity
   For Each entity In ActiveSelection 'ActiveModel.Entities
	If entity.ClassName = "Entity" Then
		EntityToJava entity
		EntityToPage entity
    End If
  Next
End Function


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

'����ʵ�������
Function EntityToJava(pEntity)
   Dim filepath,filepathUTF8
   filepath = tempPath + "\" + FirstCharToU(pEntity.Code) + "Controller.java.gbk"
   filepathUTF8 = entityPath + "\" + FirstCharToU(pEntity.Code) + "Controller.java"
'   If BackUpFile(filepathUTF8)=false then
'	   Exit Function
'   End If
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
   'дimports
   insertImportPage file,pEntity

   file.Write "/**"	+vbCrLf
   file.Write " * " + pEntity.Name +"����" + vbCrLf
   file.Write " */"	+vbCrLf
   file.Write "@Controller"	+vbCrLf
   file.Write "@RequestMapping(""/"+FirstCharToL(ActivePackage.Code)+"/"+GetBarStr(FirstCharToL(pEntity.Code))+""")"	+vbCrLf
   file.Write "public class " + FirstCharToU(pEntity.code) + "Controller extends BaseController {" + vbCrLf
   
   'д����
   file.Write  getAttrib(pEntity)
  
   'д����
   file.Write  AddMethod(pEntity)
   'file.Write  rsMethodStr

   
   file.Write "}"
   'UTF-8ת��
   ConvertToUTF8 filepath,filepathUTF8
End Function


Function EntityToPage(pEntity)
    Dim listPath,listPathUTF8
	Dim listModelFile,listFile
	listPath = tempPath+"\" + GetPageName(pEntity.code) + ".html.gbk"
    listPathUTF8 = webPage + "\" + GetPageName(pEntity.Code) + ".html"
	Output "web·��="+listPathUTF8
'	If BackUpFile(listPathUTF8)=false Then
	   'If MsgBox(listPathUTF8+" �ļ��Ѿ�����,��ȷ��Ҫ������",vbYesNo)=vbNo Then
'	     Exit Function
	
	   'End If
	   'Dim oldFile
	   'Set oldFile = fso.GetFile(listPathUTF8)
	   'oldFile.Move (BackUpFile() + GetPageName(pEntity.Code) + ".jsp")
'  End If

	Set listModelFile = fso.opentextfile(modelPage)
	On   Error   Resume   Next
	Set listModelFile = fso.opentextfile(modelPage)
	If   Err   <>   0   Then 
		'MsgBox   "An   error   occurred:   "   &   Err.Description 
		Set listModelFile = fso.opentextfile("..\"+modelPage)
	Else 
		'MsgBox   "Success! " 
	End If
    Set listFile = fso.CreateTextFile(listPath,2)

	Dim strList,attr
    Dim queryCodeHtml,modRow,countNum,searchNames
    countNum = 0
	modRow = countNum Mod 2
	For Each attr In pEntity.Attributes
        If Not attr.IsShortcut Then  
			If Not attr.PrimaryIdentifier  Then
			   'Output "�ֶ����ͣ�" + attr.DataType
			   If GetType(attr.DataType) = "java.lang.String" Then
'				If modRow =0 Then 
'				    queryCodeHtml = queryCodeHtml + "						<div class=""form-group"" style=""margin-top:1px"">"+ vbCrLf
'				End If   
					queryCodeHtml = queryCodeHtml + "							<label class=""control-label col-sm-1"" for=""query_"+FirstCharToL(attr.Code)+""">"+attr.Name + "</label>"+ vbCrLf
					queryCodeHtml = queryCodeHtml + "							<div class=""col-sm-2""> <input type=""text"" class=""form-control"" id=""query_"+FirstCharToL(attr.Code)+""" name=""query_"+FirstCharToL(attr.Code)+""" /> </div>"+ vbCrLf
'				If modRow =1 Then 
'				    queryCodeHtml = queryCodeHtml + "						</div>"+ vbCrLf
'				End If
'				countNum = countNum + 1
'				modRow = countNum Mod 2
				   If searchNames <> "" Then
					   searchNames = searchNames+"��"
				   End If
                   searchNames = searchNames+attr.Name
               End If
			End If
		End If
	Next
'	If modRow =1 Then 
'			queryCodeHtml = queryCodeHtml + "                     </div>"+ vbCrLf
'	End If

	Dim attrHtmlHidden,attrHtml,attrColumn,attrColumnVal,attrColumnEmp,entityCode
	entityCode = FirstCharToL(pEntity.Code)
    For Each attr In pEntity.Attributes
        If Not attr.IsShortcut Then  
			If Not attr.PrimaryIdentifier And attr.Code <> "parentId"  Then
			    If GetType(attr.DataType) = "java.util.Date" Then
				attrHtmlHidden = attrHtmlHidden + "		            		<input type=""hidden"" id="""+ attr.code + """ name="""+ attr.code + """ value=""""/>" + vbCrLf
				Else 				
				attrHtml = attrHtml + "							<div class=""form-group"">"+ vbCrLf	
				attrHtml = attrHtml + "								<label class=""col-sm-3 control-label"">"+ attr.name + "��</label>"+ vbCrLf	
				attrHtml = attrHtml + "								<div class=""col-sm-9"">"+ vbCrLf	
				attrHtml = attrHtml + "									<input type=""text"" class=""form-control"" name="""+FirstCharToL(attr.Code)+""" id="""+FirstCharToL(attr.Code)+""" placeholder=""������"+ attr.name + """/>"+ vbCrLf	
				attrHtml = attrHtml + "								</div>"+ vbCrLf	
				attrHtml = attrHtml + "							</div>"+ vbCrLf	
				End If
				attrColumn = attrColumn + ",{"+ vbCrLf
				attrColumn = attrColumn + "				    field: '"+FirstCharToL(attr.Code)+"',"+ vbCrLf
				attrColumn = attrColumn + "				    title:'"+ attr.name + "',"+ vbCrLf
				attrColumn = attrColumn + "				    sortable:true"+ vbCrLf
				attrColumn = attrColumn + "				}"
			End If
				attrColumnVal = attrColumnVal + "					$('#inputForm').find(""input[name='"+FirstCharToL(attr.Code)+"']"").val("+entityCode+"."+FirstCharToL(attr.Code)+");"+ vbCrLf
				attrColumnEmp = attrColumnEmp + "       $('#inputForm').find(""input[name='"+FirstCharToL(attr.Code)+"']"").val('');"+ vbCrLf
		End If
	Next
	
	strList = listModelFile.readall()
	strList=Replace(strList,"%pageCopyrightTop%",getPageCopyrightTop(pEntity.Name))
	strList=Replace(strList,"%packageCode%",GetBarStr(FirstCharToL(ActivePackage.Code)))
	strList=Replace(strList,"%controlllerCode%",GetBarStr(FirstCharToL(pEntity.Code)))
	strList=Replace(strList,"%entityCode%",FirstCharToL(pEntity.Code))
	strList=Replace(strList,"%entityName%",pEntity.Name)
	strList=Replace(strList,"%queryCode%",queryCodeHtml)
	strList=Replace(strList,"%searchNames%",searchNames)
    strList=Replace(strList,"%attrHtmlHidden%",attrHtmlHidden)
    strList=Replace(strList,"%attrHtml%",attrHtml)
    strList=Replace(strList,"%attrColumn%",attrColumn)
    strList=Replace(strList,"%attrColumnVal%",attrColumnVal)
    strList=Replace(strList,"%attrColumnEmp%",attrColumnEmp)

	listFile.write  strList
    ConvertToUTF8 listPath,listPathUTF8
End Function

'д�ļ�ͷע��
Function WriteJavaTop(file)
	file.Write "/**" + vbCrLf
 	file.Write "* <p>Description: "+ActiveModel.name+" "+ ActiveModel.code +" Controller</p>" + vbCrLf
 	file.Write "* <p>Copyright: Copyright (c) "+ CStr(DatePart("yyyy",Date)) +"</p>" + vbCrLf
 	file.Write "* <p>Company: ����·����Ϣ�ɷ����޹�˾</p>" + vbCrLf
 	file.Write "*" + vbCrLf
 	file.Write "* @author :" + author + vbCrLf
 	file.Write "* @version 1.0" + vbCrLf
 	file.Write "*/" + vbCrLf
End Function

'дhtml,jsp�ļ�ͷ�汾ע��
Function getPageCopyrightTop(eName)
 	getPageCopyrightTop  =  "* @Copyright(c): ����·����Ϣ�ɷ����޹�˾  ��Ȩ����" + vbCrLf
 	getPageCopyrightTop  = getPageCopyrightTop + "* @author :" + author + vbCrLf
 	getPageCopyrightTop  = getPageCopyrightTop + "* @Description:" + eName+ "���� " + vbCrLf
 	getPageCopyrightTop  = getPageCopyrightTop + "* @createDate:" +CStr(DatePart("yyyy",Date))+"-"+CStr(DatePart("m",Date))+"-"+CStr(DatePart("d",Date))
End Function

'дʵ��ע��
Function getAttrib(pEntity)
   getAttrib = getAttrib +"	@Autowired"  + vbCrLf
   getAttrib = getAttrib +"	private "+FirstCharToU(pEntity.Code)+"Service " + FirstCharToL(pEntity.Code)+"Service;"  + vbCrLf+ vbCrLf+ vbCrLf

End Function


Function insertImportPage(file,pEntity)
'	file.Write  vbCrLf
	file.Write   "import java.util.HashMap;"+vbCrLf
	file.Write   "import java.util.Date;"+vbCrLf
	file.Write   "import java.util.Map;"+vbCrLf
	file.Write   "import javax.servlet.http.HttpServletRequest;"+vbCrLf
	file.Write  vbCrLf
	file.Write   "import org.apache.commons.lang.StringUtils;"+vbCrLf
	file.Write   "import org.springframework.beans.factory.annotation.Autowired;"+vbCrLf
	file.Write   "import org.springframework.data.domain.PageRequest;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Pageable;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort.Direction;"+vbCrLf
'	file.Write   "import org.springframework.data.domain.Sort.Order;"+vbCrLf
	file.Write   "import org.springframework.stereotype.Controller;"+vbCrLf
	file.Write   "import org.springframework.ui.Model;"+vbCrLf
	file.Write   "import org.springframework.web.bind.annotation.RequestMapping;"+vbCrLf
	file.Write   "import org.springframework.web.bind.annotation.ResponseBody;"+vbCrLf
'	file.Write   "import net.sf.json.JSON;"+vbCrLf
	file.Write   "import net.sf.json.JSONObject;"+vbCrLf
	file.Write   "import com.xmrbi.iams.controller.BaseController;"+vbCrLf
    file.Write   "import "+entityPage + "."+FirstCharToU(pEntity.Code)+";"+vbCrLf
	file.Write   "import "+servicePage + "."+FirstCharToU(pEntity.Code)+"Service;"+vbCrLf
    file.Write vbCrLf+ vbCrLf
    
End Function



'���ɷ���
Function AddMethod(pEntity)
	 Dim attr
     AddMethod =              "   /**" + vbCrLf
	 AddMethod = AddMethod  + "    * ����չʾ�б�" + vbCrLf
	 AddMethod = AddMethod  + "    */" + vbCrLf
	 AddMethod = AddMethod  + "   @RequestMapping(""list"")" + vbCrLf
	 AddMethod = AddMethod  + "   public String list(HttpServletRequest request,Model model) {"+ vbCrLf
	 AddMethod = AddMethod  + "       return """+GetBarStr(FirstCharToL(ActivePackage.Code))+"/"+GetBarStr(FirstCharToL(pEntity.Code))+""";"+ vbCrLf
	 AddMethod = AddMethod  + "   }"+ vbCrLf
	 AddMethod = AddMethod  + "   "+ vbCrLf

	 AddMethod = AddMethod  + "   /**" + vbCrLf
	 AddMethod = AddMethod  + "    * ��ѯ�б�" + vbCrLf
	 AddMethod = AddMethod  + "    */" + vbCrLf
'	 AddMethod = AddMethod  + "   @RequestMapping(""query-"+GetBarStr(FirstCharToL(pEntity.Code))+"-page"")" + vbCrLf
	 AddMethod = AddMethod  + "   @RequestMapping(""query-page"")" + vbCrLf
	 AddMethod = AddMethod  + "   @ResponseBody"+ vbCrLf
	 AddMethod = AddMethod  + "   public Map<String,Object> queryPage(HttpServletRequest request) {"+ vbCrLf
	 AddMethod = AddMethod  + "       String pageNum = request.getParameter(""pageNum"");"+ vbCrLf
	 AddMethod = AddMethod  + "       String size = request.getParameter(""size"");"+ vbCrLf
	 AddMethod = AddMethod  + "       String searchForm = request.getParameter(""searchForm"");"+ vbCrLf
	 AddMethod = AddMethod  + "       String searchText = request.getParameter(""searchText"");"+ vbCrLf
	 AddMethod = AddMethod  + "       String ordername = request.getParameter(""ordername"");"+ vbCrLf
	 AddMethod = AddMethod  + "       String order = request.getParameter(""order"");"+ vbCrLf

	 AddMethod = AddMethod  + "       "+ vbCrLf
	 AddMethod = AddMethod  + "       Sort sort = new Sort(Direction.DESC, ""id"");"+ vbCrLf
	 AddMethod = AddMethod  + "       if(this.isNotBlank(ordername)&&this.isNotBlank(order)) {"+ vbCrLf
	 AddMethod = AddMethod  + "           sort = new Sort(order.equals(""asc"")?Direction.ASC:Direction.DESC, ordername);"+ vbCrLf
	 AddMethod = AddMethod  + "       }"+ vbCrLf
	 AddMethod = AddMethod  + "       Pageable pageable = new PageRequest(new Integer(pageNum)-1, new Integer(size), sort);"+ vbCrLf
	 AddMethod = AddMethod  + "       "+ vbCrLf

	 AddMethod = AddMethod  + "       //ͨ��Map��ʽ��ѯ"+ vbCrLf
	 AddMethod = AddMethod  + "       Map<String,String> queryMap = new HashMap<String,String>();"+ vbCrLf
	 AddMethod = AddMethod  + "       if(StringUtils.isNotBlank(searchForm)) {"+ vbCrLf '//ͨ��ҳ��""query_""��ͷ���������Կ��Զ����˲�ѯ
	 AddMethod = AddMethod  + "           queryMap = (Map<String,String>)JSONObject.fromObject(searchForm);//����ȡ���Ľ��洫������json�ַ������map"+ vbCrLf
	 AddMethod = AddMethod  + "       }"+ vbCrLf
	 AddMethod = AddMethod  + "//       Map<String,Object> resultMap = this."+FirstCharToL(pEntity.Code)+"Service.queryPagesByMap(queryMap,searchText,pageable);"+ vbCrLf
	 AddMethod = AddMethod  + "       "+ vbCrLf

	 AddMethod = AddMethod  + "       Map<String,Object> resultMap = this."+FirstCharToL(pEntity.Code)+"Service.queryPages(searchText,pageable);"+ vbCrLf
	 AddMethod = AddMethod  + "       return resultMap;"+ vbCrLf
	 AddMethod = AddMethod  + "   }"+ vbCrLf
	 AddMethod = AddMethod  + "   "+ vbCrLf


     AddMethod = AddMethod  + "   /**" + vbCrLf
	 AddMethod = AddMethod  + "    * ����"+pEntity.Name + vbCrLf
	 AddMethod = AddMethod  + "    */" + vbCrLf
	 AddMethod = AddMethod  + "   @RequestMapping(""save"")" + vbCrLf
	 AddMethod = AddMethod  + "   @ResponseBody" + vbCrLf
	 AddMethod = AddMethod  + "   public String save("+FirstCharToU(pEntity.Code)+" "+FirstCharToL(pEntity.Code)+", HttpServletRequest request) {" + vbCrLf
     AddMethod = AddMethod  + "		  String id = request.getParameter(""id"");" + vbCrLf
     AddMethod = AddMethod  + "		  if(StringUtils.isBlank(id)) {" + vbCrLf
	 For Each attr In pEntity.Attributes
	     If Not attr.IsShortcut Then
		    If attr.code = "createTime" Then
	 AddMethod = AddMethod  + "		      "+FirstCharToL(pEntity.Code)+".setCreateTime(new Date());" + vbCrLf
		    End If
		    If attr.code = "isValid" Then
	 AddMethod = AddMethod  + "		      "+FirstCharToL(pEntity.Code)+".setIsValid(true);" + vbCrLf
		    End If
		    If attr.code = "isDeleted" Then
	 AddMethod = AddMethod  + "		      "+FirstCharToL(pEntity.Code)+".setIsDeleted(false);" + vbCrLf
		    End If
         End If
     Next
     AddMethod = AddMethod  + "		  }" + vbCrLf
	 AddMethod = AddMethod  + "		  "+FirstCharToU(pEntity.Code)+" new"+FirstCharToU(pEntity.Code)+" = "+FirstCharToL(pEntity.Code)+"Service.save"+FirstCharToU(pEntity.Code)+"("+FirstCharToL(pEntity.Code)+");" + vbCrLf
	 AddMethod = AddMethod  + "		  request.setAttribute("""+FirstCharToL(pEntity.Code)+""", "+FirstCharToL(pEntity.Code)+");" + vbCrLf
	 AddMethod = AddMethod  + "		  request.setAttribute(""id"", id);" + vbCrLf
	 AddMethod = AddMethod  + "		  if(new"+FirstCharToU(pEntity.Code)+" != null)" + vbCrLf
	 AddMethod = AddMethod  + "		       return ""{\""success\"":true,\""msg\"":\""����ɹ�!\""}"";" + vbCrLf
	 AddMethod = AddMethod  + "		  else" + vbCrLf
	 AddMethod = AddMethod  + "		       return ""{\""success\"":false,\""msg\"":\""����ʧ��!\""}"";" + vbCrLf
	 AddMethod = AddMethod  + "    }" + vbCrLf
	 AddMethod = AddMethod  + "     " + vbCrLf


     AddMethod = AddMethod  + "   /**" + vbCrLf
	 AddMethod = AddMethod  + "    * ��ȡ"+pEntity.Name + vbCrLf
	 AddMethod = AddMethod  + "    */" + vbCrLf
	 AddMethod = AddMethod  + "   @RequestMapping(""find"")" + vbCrLf
	 AddMethod = AddMethod  + "   @ResponseBody" + vbCrLf
	 AddMethod = AddMethod  + "   public Map<String, Object> find(HttpServletRequest request) {" + vbCrLf
	 AddMethod = AddMethod  + "       String id = request.getParameter(""id"");" + vbCrLf
	 AddMethod = AddMethod  + "       Map<String, Object> resultMap = new HashMap<String,Object>();" + vbCrLf
	 AddMethod = AddMethod  + "       if(StringUtils.isNotBlank(id)){" + vbCrLf
	 AddMethod = AddMethod  + "           "+FirstCharToU(pEntity.Code)+" "+FirstCharToL(pEntity.Code)+" = this."+FirstCharToL(pEntity.Code)+"Service.find"+FirstCharToU(pEntity.Code)+"ById(id);" + vbCrLf
	 AddMethod = AddMethod  + "           resultMap.put("""+FirstCharToL(pEntity.Code)+""","+FirstCharToL(pEntity.Code)+".poToMap());"+ vbCrLf
	 AddMethod = AddMethod  + "       }"+ vbCrLf
	 AddMethod = AddMethod  + "       return resultMap;" + vbCrLf
	 AddMethod = AddMethod  + "   }" + vbCrLf
	 AddMethod = AddMethod  + "   " + vbCrLf


	 AddMethod = AddMethod  + "   /**" + vbCrLf
	 AddMethod = AddMethod  + "     * ɾ��" +pEntity.Name + vbCrLf
	 AddMethod = AddMethod  + "    */" + vbCrLf
	 AddMethod = AddMethod  + "   @RequestMapping(""delete"")" + vbCrLf
	 AddMethod = AddMethod  + "   @ResponseBody" + vbCrLf
	 AddMethod = AddMethod  + "   public String delete(HttpServletRequest request) {" + vbCrLf
	 AddMethod = AddMethod  + "	    String ids = request.getParameter(""ids"");" + vbCrLf
	 AddMethod = AddMethod  + "	    try{" + vbCrLf
	 AddMethod = AddMethod  + "	        this."+FirstCharToL(pEntity.Code)+ "Service.delete"+FirstCharToU(pEntity.Code)+ "ByIds(ids);" + vbCrLf
	 AddMethod = AddMethod  + "	    }catch(Exception e){" + vbCrLf
	 AddMethod = AddMethod  + "		    return ""{\""success\"":false,\""msg\"":\""ɾ��ʧ��!\""}"";" + vbCrLf
	 AddMethod = AddMethod  + "	    }" + vbCrLf
	 AddMethod = AddMethod  + "	    return ""{\""success\"":true,\""msg\"":\""ɾ���ɹ�!\""}"";" + vbCrLf
	 AddMethod = AddMethod  + "	}" + vbCrLf

End Function


Function GetPageName(vstr)
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
		newStr = LCase(newStr)
	End If
	For k = 2 To strLen
       vLeftChar = Mid(vstr, k,1)
	   If vLeftChar >=  "A"  and vLeftChar <=  "Z"  Then
			bigLen = bigLen + 1
			If  Mid(vstr, k-1,1)<>"-"   Then
				newStr = newStr + "-" 
				
			End If
	   End If
	   newStr = newStr + LCase(vLeftChar)
    Next
	'Output "bigLen=" + CStr(bigLen)
	If bigLen = strLen Then
		GetPageName = vstr
	Else
		GetPageName = newStr
	End If
	
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

'------------------------------------------------------------------------------------

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

'��ȡ�շ������ı�Ϊ����������ַ���
Function GetBarStr(vstr)
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
			If  Mid(vstr, k-1,1)<>"-"   Then
				newStr = newStr + "-" 
				
			End If
	   End If
	   newStr = newStr + LCase(vLeftChar)
    Next
	'Output "bigLen=" + CStr(bigLen)
	If bigLen = strLen Then
		GetBarStr = vstr
	Else
		GetBarStr = newStr
	End If
	
End Function



'-----------------------------------------------------------------------------------------
