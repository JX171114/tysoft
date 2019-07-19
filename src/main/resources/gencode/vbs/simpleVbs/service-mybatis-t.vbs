' ��ģ��������ʵ��bean

Option explicit

'rootPath -- �������Ŀ¼�Ĵ��·��
'serviceRootPage -- ������·��
'tempPath -- �������ɵ���ʱĿ¼
Dim rootPath,serviceRootPage,rootPage,tempPath,entityPage
'��ʵ���µİ���
Dim classPage,implPage
'fso -- FileSystemObject
'wshNetwork -- WScript.Network
'entityPath -- ����ʵ���·��
'author -- ע���ϵ���������
implPage = "impl"
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
   CreateFolder fso,entityPath+"\"+implPage
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
		rootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)
		serviceRootPage = defaultRootPackage+FirstCharToL(ActiveModel.code)+".service"
	    Output "�����·��:" + serviceRootPage
		classPage =  getClassPage(ActiveDiagram.GetPackage())
		output "classPage:" + classPage
		entityPage = defaultRootPackage+FirstCharToL(ActiveModel.code) +".entity." +  FirstCharToL(ActivePackage.Code)
   Else
		rootPath = iniArray(0)
		Output "Դ�����·��:" + rootPath
		rootPage = Mid(iniArray(2),2)
		serviceRootPage = Mid(iniArray(2),2)+".service"
		Output "�����·��:" + serviceRootPage
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
	 getClassPage =  serviceRootPage + "." + Left(getClassPage,Len(getClassPage)-1)
   Else
     getClassPage = serviceRootPage
   End If
   
End Function 

'BEGIN -------------------Ŀ¼�Ĵ���
'��������Ŀ¼
Function CreateEntityPageFolder(vfso, vpath, vpage)
	Dim tempArray,temp
	CreateEntityPageFolder = vpath
	tempArray = Split(vpage, ".")
	
	For Each temp in tempArray
      CreateEntityPageFolder = CreateEntityPageFolder +"\" + temp
	  CreateFolder vfso, CreateEntityPageFolder
	  Output "����serviceĿ¼��" + CreateEntityPageFolder
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
		EntityToService entity
    End If
  Next
End Function

'��ѡ��Ķ�������java Service����
Function EntityToService(pEntity)
   
   Dim entity,tempInterface,tempImpl
   Dim interfaceName,implName
   Dim UTF8Interface,UTF8Impl
   
   
   '�����ӿ��ļ������������ļ�������ʵ���ļ�
   interfaceName = FirstCharToU(pEntity.Code)+"Service"
   implName = FirstCharToU(pEntity.Code) + "ServiceImpl"
   tempInterface = tempPath + "\" + interfaceName + ".java.gbk"
   tempImpl =  tempPath + "\" + implName + ".java.gbk"
   UTF8Interface = entityPath + "\" + interfaceName + ".java"
   UTF8Impl = entityPath + "\impl\" + implName + ".java"

   Dim fileInter,fileImpl
   Set fileInter = fso.OpenTextFile(tempInterface, 2, true)
   Set fileImpl = fso.OpenTextFile(tempImpl, 2, true)

   WriteJavaTop(fileInter)
   WriteJavaTop(fileImpl)
    
   WritePageInfo fileInter,getClassPage(ActivePackage)
   WritePageInfo fileImpl,getClassPage(ActivePackage)+".impl"
 
   insertInterImportPage fileInter,pEntity
   insertImpImportPage fileImpl,pEntity

   Dim interStr,implStr
   interStr = interStr + AddInterfaceMethod(pEntity)
   implStr = implStr + AddImplMethod(pEntity)

   fileInter.Write "/**" + vbCrLf 
   fileInter.Write " * "+FirstCharToU(pEntity.Name)+"�������ӿ���" + vbCrLf 
   fileInter.Write " */" + vbCrLf 	
   fileInter.Write "public interface "+FirstCharToU(pEntity.Code)+"Service extends BaseService<"+FirstCharToU(pEntity.Code)+">"+" {" + vbCrLf 
   fileInter.Write interStr + vbCrLf
   fileInter.Write "}" + vbCrLf
   
   fileImpl.Write "/**" + vbCrLf 
   fileImpl.Write " * "+FirstCharToU(pEntity.Name)+"�������ʵ����" + vbCrLf 
   fileImpl.Write " */" + vbCrLf 
   fileImpl.Write "@Service("""+FirstCharToL(pEntity.Code)+"Service"")"+ vbCrLf
   fileImpl.Write "@Transactional"+ vbCrLf
   fileImpl.Write "public class " + implName + " extends BaseServiceImpl<"+FirstCharToU(pEntity.Code)+"> implements "+FirstCharToU(pEntity.Code)+"Service {" + vbCrLf 
   fileImpl.Write implStr+ vbCrLf
   fileImpl.Write "}" + vbCrLf

  ConvertToUTF8 tempInterface,UTF8Interface
  ConvertToUTF8 tempImpl,UTF8Impl
End Function


'д�ļ�ͷע��
Function WriteJavaTop(file)
	file.Write "/**" + vbCrLf
 	file.Write "* <p>Description: "+ActivePackage.name+" "+ ActivePackage.Comment +"</p>" + vbCrLf
 	file.Write "* <p>Copyright: Copyright (c) "+ CStr(DatePart("yyyy",Date)) +"</p>" + vbCrLf
 	file.Write "* <p>Company: ����·����Ϣ�ɷ����޹�˾</p>" + vbCrLf
 	file.Write "*" + vbCrLf
 	file.Write "* @author :" + author + vbCrLf
 	file.Write "* @version 1.0" + vbCrLf
 	file.Write "*/" + vbCrLf
End Function


'д�ļ�ͷע��
Function WritePageInfo(file,pageinfo)
   file.Write  vbCrLf
   file.Write  "package " + pageinfo + ";"+vbCrLf
   file.Write vbCrLf
End Function


'�ӿ���������
Function insertInterImportPage(file,entity)
	file.Write   vbCrLf
	file.Write   "import java.util.Map;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort;"+vbCrLf
	file.Write   "import com.github.pagehelper.PageInfo;"+vbCrLf
    file.Write   "import "+serviceRootPage+".BaseService;"+vbCrLf
    file.Write   "import "+entityPage+"."+FirstCharToU(entity.Code)+";"+vbCrLf
    file.Write vbCrLf
End Function

'ʵ����������
Function insertImpImportPage(file,entity)
	file.Write   vbCrLf
	file.Write   "import java.util.Map;"+vbCrLf
	file.Write   "import javax.transaction.Transactional;"+vbCrLf
	file.Write   "import org.springframework.beans.factory.annotation.Autowired;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Pageable;"+vbCrLf
	file.Write   "import org.springframework.stereotype.Service;"+vbCrLf
	file.Write   "import com.github.pagehelper.Page;"+vbCrLf
	file.Write   "import com.github.pagehelper.PageHelper;"+vbCrLf
	file.Write   "import com.github.pagehelper.PageInfo;"+vbCrLf
	file.Write   vbCrLf
    file.Write   "import "+serviceRootPage+".BaseServiceImpl;"+vbCrLf
    file.Write   "import "+rootPage+".common.query.Query;"+vbCrLf
    file.Write   "import "+entityPage+"."+FirstCharToU(entity.Code)+";"+vbCrLf
    file.Write   "import "+classPage+"."+FirstCharToU(entity.Code)+"Service;"+vbCrLf
    file.Write   "import "+Replace(classPage,"service","mapper")+"."+FirstCharToU(entity.Code)+"Mapper;"+vbCrLf
    file.Write vbCrLf
End Function


'���ɽӿڷ���
Function AddInterfaceMethod(entity)
    
	 AddInterfaceMethod =                      "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ��ҳ��ѯ" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param " +FirstCharToL(entity.Code) + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param sort" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageNo ҳ��" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageSize ÿҳ����" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return PageInfo" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public PageInfo<"+FirstCharToU(entity.Code)+"> queryPages("+FirstCharToU(entity.Code)+" "+FirstCharToL(entity.Code)+", Sort sort, int pageNo, int pageSize);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf
    
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����queryMap��ҳ��ѯ" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param queryMap"  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param search"  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageNo ҳ��"  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageSize ÿҳ����"  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return PageInfo" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public PageInfo<"+FirstCharToU(entity.Code)+"> queryPagesByMap(Map<String, String> queryMap,String search,int pageNo, int pageSize);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf

	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ɾ��" +entity.name  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param ids" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public void  delete" + FirstCharToU(entity.Code)+"(String ids);"
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf

End Function


'����ʵ���෽��
Function AddImplMethod(entity)
     AddImplMethod =                 "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ��ҳ��ѯ" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param " +FirstCharToL(entity.Code) + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param sort" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageNo ҳ��" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageSize ÿҳ����" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return PageInfo" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public PageInfo<"+FirstCharToU(entity.Code)+"> queryPages("+FirstCharToU(entity.Code)+" "+FirstCharToL(entity.Code)+", Sort sort, int pageNo, int pageSize) {" + vbCrLf	 
	 AddImplMethod = AddImplMethod + "        Condition condition=new Condition("+FirstCharToU(entity.Code)+".class);" + vbCrLf
	 AddImplMethod = AddImplMethod + "        Criteria criteria = condition.createCriteria();" + vbCrLf
	 AddImplMethod = AddImplMethod + "        if(StringUtils.isNotBlank("+FirstCharToL(entity.Code)+".getName())){" + vbCrLf
	 AddImplMethod = AddImplMethod + "        	  criteria.andLike(""name"", ""%""+"+FirstCharToL(entity.Code)+".getName()+""%"");" + vbCrLf
	 AddImplMethod = AddImplMethod + "        }" + vbCrLf
	 AddImplMethod = AddImplMethod + "        condition.setOrderByClause(""create_time desc"");" + vbCrLf
	 AddImplMethod = AddImplMethod + "        PageInfo<"+FirstCharToU(entity.Code)+"> pages = this.queryPageByCondition(pageNo,pageSize,condition);" + vbCrLf
	 AddImplMethod = AddImplMethod + "        return pages;" + vbCrLf
	 AddImplMethod = AddImplMethod + "    }" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
    
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����queryMap��ҳ��ѯ" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param queryMap"  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param search"  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageNo ҳ��"  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageSize ÿҳ����"  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return PageInfo" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public PageInfo<"+FirstCharToU(entity.Code)+"> queryPagesByMap(Map<String, String> queryMap,String search,int pageNo, int pageSize) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "        Condition condition = Query.createCondition("+FirstCharToU(entity.Code)+".class);" + vbCrLf
	 AddImplMethod = AddImplMethod + "        Query.initCondition(queryMap);" + vbCrLf
	 AddImplMethod = AddImplMethod + "        //ҳ�����ϵ�������Ļ������" + vbCrLf
	 AddImplMethod = AddImplMethod + "        if(StringUtils.isNotBlank(search)) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "            Query.AND().andLike(""name"", ""%""+search+""%"").orLike(""content"", ""%""+search+""%"");" + vbCrLf
	 AddImplMethod = AddImplMethod + "        }" + vbCrLf
	 AddImplMethod = AddImplMethod + "" + vbCrLf
	 AddImplMethod = AddImplMethod + "        PageInfo<"+FirstCharToU(entity.Code)+"> pages = this.queryPageByCondition(pageNo,pageSize,condition);" + vbCrLf
	 AddImplMethod = AddImplMethod + "        return pages;" + vbCrLf
	 AddImplMethod = AddImplMethod + "    }" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf

	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ɾ��" +entity.name  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param ids" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public void delete" + FirstCharToU(entity.Code)+"ByIds(String ids){" + vbCrLf
	 AddImplMethod = AddImplMethod + "       String[] idsArr = ids.split("","");" + vbCrLf
	 AddImplMethod = AddImplMethod + "       List<Object> li = new ArrayList<Object>();" + vbCrLf
	 AddImplMethod = AddImplMethod + "       for(int i = 0; i < idsArr.length; i++) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "           li.add(idsArr[i]);" + vbCrLf
	 AddImplMethod = AddImplMethod + "           //this.deleteById(idsArr[i]);" + vbCrLf
	 AddImplMethod = AddImplMethod + "       }" + vbCrLf
	 AddImplMethod = AddImplMethod + "       this.deleteByIds("+FirstCharToU(entity.Code)+".class, ""id"", li);" + vbCrLf
	 AddImplMethod = AddImplMethod + "   }" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
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