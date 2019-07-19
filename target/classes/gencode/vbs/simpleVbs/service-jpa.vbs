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
	  Output "������Ŀ¼��" + CreateEntityPageFolder
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
   fileInter.Write "public interface "+FirstCharToU(pEntity.Code)+"Service {" + vbCrLf 
   fileInter.Write interStr + vbCrLf
   fileInter.Write "}" + vbCrLf
   
   fileImpl.Write "/**" + vbCrLf 
   fileImpl.Write " * "+FirstCharToU(pEntity.Name)+"�������ʵ����" + vbCrLf 
   fileImpl.Write " */" + vbCrLf 
   fileImpl.Write "@Service"+ vbCrLf
   fileImpl.Write "@Transactional"+ vbCrLf
   fileImpl.Write "public class " + implName + " implements "+FirstCharToU(pEntity.Code)+"Service {" + vbCrLf 
   fileImpl.Write "    @Autowired" + vbCrLf
   fileImpl.Write "    private "+FirstCharToU(pEntity.Code)+"Repository "+FirstCharToL(pEntity.Code)+"Repository;" + vbCrLf + vbCrLf
   fileImpl.Write  implStr + vbCrLf
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
	file.Write   "import java.util.List;"+vbCrLf
	file.Write   "import java.util.Map;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Pageable;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort;"+vbCrLf
    file.Write   "import "+entityPage+"."+FirstCharToU(entity.Code)+";"+vbCrLf
    file.Write vbCrLf
End Function

'ʵ����������
Function insertImpImportPage(file,entity)
	file.Write   vbCrLf
	file.Write   "import java.util.ArrayList;"+vbCrLf
	file.Write   "import java.util.HashMap;"+vbCrLf
	file.Write   "import java.util.List;"+vbCrLf
	file.Write   "import java.util.Map;"+vbCrLf
	file.Write   "import javax.transaction.Transactional;"+vbCrLf
	file.Write   "import javax.persistence.criteria.CriteriaBuilder;"+vbCrLf
	file.Write   "import javax.persistence.criteria.CriteriaQuery;"+vbCrLf
	file.Write   "import javax.persistence.criteria.Predicate;"+vbCrLf
	file.Write   "import javax.persistence.criteria.Root;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Page;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Sort;"+vbCrLf
	file.Write   "import org.springframework.data.domain.Pageable;"+vbCrLf
'	file.Write   "import org.springframework.data.domain.PageRequest;"+vbCrLf
	file.Write   "import org.springframework.data.jpa.domain.Specification;"+vbCrLf
	file.Write   "import org.apache.commons.lang.StringUtils;"+vbCrLf
	file.Write   "import org.springframework.beans.factory.annotation.Autowired;"+vbCrLf
	file.Write   "import org.springframework.stereotype.Service;"+vbCrLf
	file.Write   vbCrLf
    file.Write   "import "+Replace(classPage,".service.",".repository.")+"."+FirstCharToU(entity.Code)+"Repository;"+vbCrLf
    file.Write   "import "+entityPage+"."+FirstCharToU(entity.Code)+";"+vbCrLf
	file.Write   "import "+classPage+"."+FirstCharToU(entity.Code)+"Service;"+vbCrLf
    file.Write vbCrLf
End Function


'���ɽӿڷ���
Function AddInterfaceMethod(entity)
    
	 AddInterfaceMethod =                      "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ��ѯ����" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return List" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public List<"+FirstCharToU(entity.Code)+"> queryAll"+FirstCharToU(entity.Code)+"();" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf
	 
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param "+FirstCharToL(entity.Code) + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return "+FirstCharToU(entity.Code) + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public "+FirstCharToU(entity.Code)+" save"+FirstCharToU(entity.Code)+"("+FirstCharToU(entity.Code)+" "+FirstCharToL(entity.Code)+");" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf
	 
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����ID��ȡ" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param id" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return "+FirstCharToU(entity.Code) + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public "+FirstCharToU(entity.Code)+" find"+FirstCharToU(entity.Code)+"ById(String id);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf

	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����idsɾ��" +entity.name  + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param  ids" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public void delete" + FirstCharToU(entity.Code)+"ByIds(String ids);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf	 
	 
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����������ѯ" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param queryMap" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param searchText" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param sort" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return List" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public List<"+FirstCharToU(entity.Code)+"> query"+FirstCharToU(entity.Code)+"List(Map<String,String> queryMap,String searchText,Sort sort);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf
	 
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����������ҳ��ѯ" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param queryMap" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param searchText" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageable" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return Page" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public Map<String,Object> queryPagesByMap(Map<String,String> queryMap,String searchText,Pageable pageable);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf
	 
	 AddInterfaceMethod = AddInterfaceMethod + "	/**" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * ����������ҳ��ѯ" +entity.name + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param searchText" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @param pageable" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 * @return Map<String,Object>" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "	 */" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + "    public Map<String,Object> queryPages(String searchText,Pageable pageable);" + vbCrLf
	 AddInterfaceMethod = AddInterfaceMethod + vbCrLf

End Function


'����ʵ���෽��
Function AddImplMethod(entity)
    
	 AddImplMethod =                      "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ��ѯ����" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return List" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public List<"+FirstCharToU(entity.Code)+"> queryAll"+FirstCharToU(entity.Code)+"(){" + vbCrLf
	 AddImplMethod = AddImplMethod + "        return this."+FirstCharToL(entity.Code)+"Repository.findAll();" + vbCrLf
	 AddImplMethod = AddImplMethod + "    }" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
	 
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param "+FirstCharToL(entity.Code) + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return "+FirstCharToU(entity.Code) + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public "+FirstCharToU(entity.Code)+" save"+FirstCharToU(entity.Code)+"("+FirstCharToU(entity.Code)+" "+FirstCharToL(entity.Code)+"){" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    return this."+FirstCharToL(entity.Code)+"Repository.saveAndFlush("+FirstCharToL(entity.Code)+");" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
	 
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����ID��ȡ" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param id" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return "+FirstCharToU(entity.Code) + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public "+FirstCharToU(entity.Code)+" find"+FirstCharToU(entity.Code)+"ById(String id){" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    return this."+FirstCharToL(entity.Code)+"Repository.findOne(id);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf

	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����idsɾ��" +entity.name  + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param  ids" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public void  delete" + FirstCharToU(entity.Code)+"ByIds(String ids){" + vbCrLf
	 AddImplMethod = AddImplMethod + "		String[] idsArr = ids.split("","");" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    for(int i = 0; i < idsArr.length; i++) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "	        this."+FirstCharToL(entity.Code)+"Repository.delete(idsArr[i]);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    }" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf	 
	 
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����������ѯ" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param queryMap" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param sort" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param sort" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return List" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public List<"+FirstCharToU(entity.Code)+"> query"+FirstCharToU(entity.Code)+"List(Map<String,String> queryMap,String searchText,Sort sort){" + vbCrLf
	 AddImplMethod = AddImplMethod + "		return this."+FirstCharToL(entity.Code)+"Repository.findAll(genSpecification(queryMap, searchText), sort);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
	 
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����������ҳ��ѯ" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param queryMap" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param searchText" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageable" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return Map<String,Object>" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public Map<String,Object> queryPagesByMap(Map<String,String> queryMap,String searchText,Pageable pageable){" + vbCrLf
	 AddImplMethod = AddImplMethod + "		Page<"+FirstCharToU(entity.Code)+"> page = this."+FirstCharToL(entity.Code)+"Repository.findAll(genSpecification(queryMap, searchText), pageable);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    return pageToMap(page);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf
	 
	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * ����������ҳ��ѯ" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param searchText" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageable" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return Map<String,Object>" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	@Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "    public Map<String,Object> queryPages(String searchText,Pageable pageable){" + vbCrLf
	 AddImplMethod = AddImplMethod + "		searchText = StringUtils.isNotBlank(searchText)? ""%""+searchText+""%"":""%%"";" + vbCrLf
	 AddImplMethod = AddImplMethod + "		Page<"+FirstCharToU(entity.Code)+"> page = this."+FirstCharToL(entity.Code)+"Repository.queryPage(searchText, pageable);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	    return pageToMap(page);" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf+ vbCrLf

     Dim attr,countNum,rs
	 countNum = 1

	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * �ӹ�������" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param queryMap" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param searchText" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return Specification" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 private Specification<"+FirstCharToU(entity.Code)+"> genSpecification(Map<String, String> queryMap, String searchText) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "	     return new Specification<"+FirstCharToU(entity.Code)+">() {" + vbCrLf
	 AddImplMethod = AddImplMethod + "	         @Override" + vbCrLf
	 AddImplMethod = AddImplMethod + "	         public Predicate toPredicate(Root<"+FirstCharToU(entity.Code)+"> root, CriteriaQuery<?> cq, CriteriaBuilder cb) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             List<Predicate> predicate = new ArrayList<>();" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             // TODO �ӹ�������" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             //���������ѯ�÷��磺root.join(""useunit"").get(""name"").as(String.class)" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             if(queryMap != null) {" + vbCrLf
	 For Each attr In entity.Attributes
		If Not attr.IsShortcut Then
			If Not attr.PrimaryIdentifier  Then
				If GetType(attr.DataType) = "java.lang.String" Then
	 AddImplMethod = AddImplMethod + "	                 if(StringUtils.isNotBlank(queryMap.get(""query_"+attr.code+"""))){" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                     predicate.add(cb.like(root.get("""+attr.code+"""), ""%"" + queryMap.get(""query_"+attr.code+""") + ""%""));" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                 }" + vbCrLf
				End If
			End If
		End If
     Next
	 For Each rs In entity.relationships
		If rs.Entity1 = rs.Entity2 Then
	 AddImplMethod = AddImplMethod + "	                 if(StringUtils.isNotBlank(queryMap.get(""parentId""))){" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                	 predicate.add(cb.equal(root.join(""parent"").get(""id""),queryMap.get(""parentId"")));" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                 }" + vbCrLf
		End If
	 Next
	 AddImplMethod = AddImplMethod + "	             }" + vbCrLf
	 AddImplMethod = AddImplMethod + "" + vbCrLf

	 AddImplMethod = AddImplMethod + "                //������-�������" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             if(StringUtils.isNotBlank(searchText)){" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                 List<Predicate> predicates = new ArrayList<>();" + vbCrLf
	 For Each attr In entity.Attributes
		If Not attr.IsShortcut Then
			If Not attr.PrimaryIdentifier  Then
				If GetType(attr.DataType) = "java.lang.String" Then
	 AddImplMethod = AddImplMethod + "	                 Predicate p"+CStr(countNum)+" = cb.like(root.get("""+attr.code+"""), ""%"" + searchText + ""%"");" + vbCrLf
	 AddImplMethod = AddImplMethod + "	                 predicates.add(p"+CStr(countNum)+");" + vbCrLf
	            countNum = countNum + 1
				End If
			End If
		End If
     Next
	 AddImplMethod = AddImplMethod + "	                 predicate.add(cb.or(predicates.toArray(new Predicate[predicates.size()])));" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             }" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             " + vbCrLf
	 AddImplMethod = AddImplMethod + "	             Predicate[] pre = new Predicate[predicate.size()];" + vbCrLf
	 AddImplMethod = AddImplMethod + "	             return cq.where(predicate.toArray(pre)).getRestriction();" + vbCrLf
	 AddImplMethod = AddImplMethod + "	         }" + vbCrLf
	 AddImplMethod = AddImplMethod + "	     };" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 }" + vbCrLf
	 AddImplMethod = AddImplMethod + vbCrLf


	 AddImplMethod = AddImplMethod + "	/**" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * PageתMap" +entity.name + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * " + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @param pageInfo" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 * @return Map<String,Object>" + vbCrLf
	 AddImplMethod = AddImplMethod + "	 */" + vbCrLf
	 AddImplMethod = AddImplMethod + "	private Map<String,Object> pageToMap(Page<"+FirstCharToU(entity.Code)+"> page) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "		Map<String,Object> resultMap = new HashMap<String,Object>();" + vbCrLf
	 AddImplMethod = AddImplMethod + "		List<Map<String,Object>> listMap = new ArrayList<Map<String,Object>>();" + vbCrLf
	 AddImplMethod = AddImplMethod + "		if (page.getSize() > 0) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "			for ("+FirstCharToU(entity.Code)+" "+FirstCharToL(entity.Code)+" : page) {" + vbCrLf
	 AddImplMethod = AddImplMethod + "				listMap.add("+FirstCharToL(entity.Code)+".poToMap());" + vbCrLf
	 AddImplMethod = AddImplMethod + "			}" + vbCrLf
	 AddImplMethod = AddImplMethod + "		}" + vbCrLf
	 AddImplMethod = AddImplMethod + "		resultMap.put(""page"", page.getTotalPages());" + vbCrLf
	 AddImplMethod = AddImplMethod + "		resultMap.put(""total"", page.getTotalElements());" + vbCrLf
	 AddImplMethod = AddImplMethod + "		resultMap.put(""rows"", listMap);" + vbCrLf
	 AddImplMethod = AddImplMethod + "		return resultMap;" + vbCrLf
	 AddImplMethod = AddImplMethod + "	}" + vbCrLf
	
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