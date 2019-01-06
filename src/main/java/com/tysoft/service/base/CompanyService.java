/**
* <p>Description: 1.基础数据 bs</p>
* <p>Copyright: Copyright (c) 2019</p>
* <p>Company: 厦门路桥信息股份有限公司</p>
*
* @author :dell
* @version 1.0
*/

package com.tysoft.service.base;


import java.util.List;
import java.util.Map;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import com.tysoft.entity.base.Company;

/**
 * 公司表管理服务接口类
 */
public interface CompanyService {
	/**
	 * 查询所有公司表
	 * @return List
	 */
    public List<Company> queryAllCompany();

	/**
	 * 保存公司表
	 * @param company
	 * @return Company
	 */
    public Company saveCompany(Company company);

	/**
	 * 根据ID获取公司表
	 * @param id
	 * @return Company
	 */
    public Company findCompanyById(String id);

	/**
	 * 根据ids删除公司表
	 * @param  ids
	 */
    public void deleteCompanyByIds(String ids);

	/**
	 * 根据条件查询公司表
	 * @param queryMap
	 * @param searchText
	 * @param sort
	 * @return List
	 */
    public List<Company> queryCompanyList(Map<String,String> queryMap,String searchText,Sort sort);

	/**
	 * 根据条件分页查询公司表
	 * @param queryMap
	 * @param searchText
	 * @param pageable
	 * @return Page
	 */
    public Map<String,Object> queryPagesByMap(Map<String,String> queryMap,String searchText,Pageable pageable);

	/**
	 * 根据条件分页查询公司表
	 * @param searchText
	 * @param pageable
	 * @return Map<String,Object>
	 */
    public Map<String,Object> queryPages(String searchText,Pageable pageable);


}