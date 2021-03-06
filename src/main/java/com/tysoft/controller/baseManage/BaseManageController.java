package com.tysoft.controller.baseManage;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.collections4.map.HashedMap;
import org.hibernate.criterion.Expression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.geo.Circle;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.JsonObject;
import com.tysoft.common.Criteria;
import com.tysoft.common.JsonUtils;
import com.tysoft.common.MD5Util;
import com.tysoft.common.Restrictions;
import com.tysoft.controller.BaseController;
import com.tysoft.entity.base.Menu;
import com.tysoft.entity.base.Power;
import com.tysoft.entity.base.Role;
import com.tysoft.entity.base.Unit;
import com.tysoft.entity.base.User;
import com.tysoft.repository.base.MenuRepository;
import com.tysoft.service.base.MenuService;
import com.tysoft.service.base.PowerService;
import com.tysoft.service.base.RoleService;
import com.tysoft.service.base.UnitService;
import com.tysoft.service.base.UserService;

import antlr.StringUtils;
import cn.hutool.core.date.DateUtil;
import jodd.util.StringUtil;
import net.sf.json.JSONObject;

@Controller
@RequestMapping("/baseManage")
public class BaseManageController extends BaseController {
	// 自动装载相关服务
	@Autowired
	protected PowerService powerService;
	@Autowired
	protected RoleService roleService;
	@Autowired
	protected UnitService unitService;
	@Autowired
	protected UserService userService;
	@Autowired
	protected MenuService menuService;
	@Autowired
	protected MenuRepository menuRepository;
	
	
	private String userView = "baseManage/user/userView";
	private String userAdd = "baseManage/user/user-add";
	private String powerView = "baseManage/power/powerView";
	private String powerAdd = "baseManage/power/power-add";
	private String powerEdit = "baseManage/power/power-edit";
	private String powerLookChild = "baseManage/power/power-look-child";
	private String unitView = "baseManage/unit/unitView";
	private String unitAdd = "baseManage/unit/unit-add";
	private String roleView = "baseManage/role/roleView";
	private String roleAddView = "baseManage/role/roleAddView";
	private String rolePowerSetView = "baseManage/role/rolePowerSet";
	private String userUnitSet = "baseManage/user/user-unit-set";
    private String revisePasswordView="baseManage/user/password";	
    //private String userPowerSet = "baseManage/user/user-power-set";
	// 菜单操作
	private String menuView = "baseManage/menu/menuSet";
	private String menuAddView = "baseManage/menu/menu-add";
	// 菜单-权限选择界面
	private String powerChoose = "baseManage/power/power-choose";
	private String menuPower = "baseManage/menu/menu-power";
	private String menuEdit = "baseManage/menu/menu-edit";
	//用户分配角色权限
	private String userSetRole = "baseManage/user/user-role-set";

	// 权限界面
	@RequestMapping("powerView")
	public String powerView(HttpServletRequest request) {
		String view = "";
		String powerViewType = request.getParameter("powerViewType");
		// 按顺序界面为权限模块界面-权限模块添加界面-子权限添加界面
		if (powerViewType.equals("powerView")) {
			view = powerView;
		} else if (powerViewType.equals("powerAddView")) {
			String pid = request.getParameter("pid");
			request.setAttribute("pid", pid);
			view = powerAdd;
		} else if (powerViewType.equals("powerLookChildView")) {
			String pid = request.getParameter("pid");
			request.setAttribute("pid", pid);
			view = powerLookChild;
		} else if (powerViewType.equals("powerEdit")) {
			String id = request.getParameter("id");
			Power power = this.powerService.findPowerById(id);
			request.setAttribute("power", power);
			view = powerEdit;
		} else if (powerViewType.equals("powerChoose")) {
			view = powerChoose;
		}

		return view;
	}

	// 权限模块界面
	@RequestMapping("powerPage")
	@ResponseBody
	public Object powerPage(HttpServletRequest request) {
		String page = request.getParameter("page");
		String limit = request.getParameter("limit");
		String pid = request.getParameter("pid");
		String queryPowerName = request.getParameter("powerName");
		String isChoosePower = request.getParameter("chooseFlag");
		String menuId = request.getParameter("menuId");
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		Criteria<Power> criteria = new Criteria<>();
		// 当不是菜单选择权限的时候
		if (!StringUtil.isNotBlank(isChoosePower)) {
			// 正常情况下的权限选择
			if (StringUtil.isNotBlank(pid)) {
				criteria.add(Restrictions.eq("pid", pid, false));
			} else {
				criteria.add(Restrictions.eq("pid", "menu", false));
			}
		} else {
			if (!StringUtil.isNotBlank(queryPowerName)) {
				Map<String, Object> firstMap = new HashMap<String, Object>();
				firstMap.put("id", "clearPower");
				firstMap.put("powerName", "清空权限");
				firstMap.put("url", "空");
				listMap.add(firstMap);
			}
			criteria.add(Restrictions.ne("pid", "menu", false));

		}
		if (StringUtil.isNotBlank(queryPowerName)) {
			criteria.add(Restrictions.like("powerName", queryPowerName, false));
		}
		Order order = new Order(Direction.DESC, "id");// 根据id排序
		Sort sort = new Sort(order);
		Page<Power> pages = this.powerService.queryPowerByPage(criteria, sort, Integer.valueOf(page) - 1,
				Integer.valueOf(limit));
		if (pages.getTotalPages() > 0) {
			Map<String, Object> map = null;
			Menu menu = null;
			if (StringUtil.isNotBlank(menuId)) {
				menu = this.menuService.findMenuById(menuId);
			}
			for (Power power : pages.getContent()) {
				map = new HashMap<String, Object>();
				String id = power.getId();
				String powerName = power.getPowerName();
				if (menu != null && menu.getPower() != null) {
					if (id.equals(menu.getPower().getId())) {
						map.put("LAY_CHECKED", true);
					}
					;
				}
				String icon = power.getIcon();
				map.put("id", id);
				map.put("powerName", powerName);
				map.put("url", power.getUrl());
				map.put("icon", icon);
				listMap.add(map);
			}
		}
		Map<String, Object> powerMap = new LinkedHashMap<String, Object>();
		powerMap.put("code", 0);
		powerMap.put("msg", "");
		powerMap.put("count", pages.getTotalElements());
		powerMap.put("data", listMap);
		return powerMap;
	}

	// 权限增加界面
	@RequestMapping("powerAddView")
	public String powerAddView(HttpServletRequest request) {
		return powerAdd;
	}

	// 权限增加
	@RequestMapping("powerAdd")
	@ResponseBody
	public Map<String, Object> powerAdd(HttpServletRequest request) {
		Map<String, Object> tipMsg = new HashedMap<>();
		// 权限json字符串
		String childPower = request.getParameter("childPower");
		String powerName = request.getParameter("powerName");
		if (StringUtil.isNotBlank(childPower)) {
			// 获得对象
			JSONObject obj = JSONObject.fromObject(childPower);
			Power power = new Power();
			power.setPid((String) obj.get("pid"));
			power.setPowerName((String) obj.get("powerName"));
			power.setUrl((String) obj.get("url"));
			Power savePower = this.powerService.savePower(power);
			if (savePower != null) {
				tipMsg.put("msg", 1);
			}
		} else {
			Power power = this.powerService.parentPower(powerName);
			if (power != null) {
				// 该权限模块已存在
				tipMsg.put("msg", 0);
			} else {
				Power addPower = new Power();
				addPower.setPowerName(powerName);
				addPower.setPid("menu");
				Power newPower = this.powerService.savePower(addPower);
				if (newPower != null) {
					tipMsg.put("msg", 1);
				}
			}
		}

		return tipMsg;
	}

	// 权限修改
	@RequestMapping("powerEdit")
	@ResponseBody
	public Map<String, Object> powerEdit(HttpServletRequest request) {
		Map<String, Object> tipMsg = new HashedMap<>();
		String editPower = request.getParameter("editPower");
		JSONObject obj = JSONObject.fromObject(editPower);
		Power power = (Power) JSONObject.toBean(obj, Power.class);
		this.powerService.savePower(power);
		return tipMsg;
	}

	// 权限删除
	@RequestMapping("powerDel")
	@ResponseBody
	public Map<String, Object> powerDel(HttpServletRequest request) {
		Map<String, Object> resultMap = new HashedMap<>();
		String id = request.getParameter("id");
		Power power = this.powerService.findPowerById(id);
		// 删除子权限
		if (!power.getPid().equals("menu")) {
			this.powerService.deletePowerByIds(id);
		} else {
			// 批量删除
			// 主权限id
			String pid = power.getId();
			Criteria<Power> criteria = new Criteria<>();
			criteria.add(Restrictions.eq("pid", pid, false));
			List<Power> powerList = this.powerService.queryPowerByCondition(criteria, null);
			powerList.add(power);
			this.powerService.batchDeletPower(powerList);
		}

		return resultMap;
	}

	// 验证删除密码
	@RequestMapping("validatePsw")
	@ResponseBody
	public Map<String, Object> validatePsw(HttpServletRequest request) throws Exception {
		Map<String, Object> resultMap = new HashedMap<>();
		String psw = request.getParameter("psw");
		User user = this.getCurrentSystemUser(request);
		if (MD5Util.encode(psw).equals(user.getLoginPsw())) {
			resultMap.put("msg", 0);
		} else {
			resultMap.put("msg", 1);
		}
		return resultMap;
	}
    //webSocket测试界面
	@RequestMapping("webSocketView")
	public String webSocketView(HttpServletRequest request) {
		return "baseManage/user/webSocketView";
	}
	
	// 单位界面
	@RequestMapping("unitView")
	public String unitView(HttpServletRequest request) {
		String view = "";
		String unitViewType = request.getParameter("unitViewType");
		if (unitViewType.equals("unitView")) {
			view = unitView;
		} else if (unitViewType.equals("unitAdd")) {
			view = unitAdd;
		} else if (unitViewType.equals("unitEdit")) {
			String id = request.getParameter("id");
			Unit unit = this.unitService.findUnitById(id);
			request.setAttribute("unit", unit);
			view = unitAdd;
		} else if (unitViewType.equals("unitAddPeople")) {
			String unitId = request.getParameter("unitId");
			request.setAttribute("unitId", unitId);
			view = userView;
		}
		return view;
	}

	// 添加单位
	@RequestMapping("unitAdd")
	@ResponseBody
	public Map<String, Object> unitAdd(HttpServletRequest request) throws Exception {
		Map<String, Object> resultMap = new HashedMap<>();
		String unitName = request.getParameter("unitName");
		Unit unit = this.unitService.findUnitByName(unitName);
		if (unit != null) {
			resultMap.put("msg", 0);
		} else {
			Unit newUnit = new Unit();
			newUnit.setUnitName(unitName);
			newUnit.setUnitNum(0);
			this.unitService.saveUnit(newUnit);
			resultMap.put("msg", 1);
		}
		return resultMap;
	}

	// 单位分页
	@RequestMapping("unitPage")
	@ResponseBody
	public Object unitPage(HttpServletRequest request) {
		String page = request.getParameter("page");
		String limit = request.getParameter("limit");
		String unitName = request.getParameter("unitName");
		String type = request.getParameter("type");
		Criteria<Unit> criteria = new Criteria<>();

		if (StringUtil.isNotBlank(unitName)) {
			criteria.add(Restrictions.like("unitName", unitName, false));
		}
		Order order = new Order(Direction.DESC, "id");// 根据id排序
		Sort sort = new Sort(order);
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		Page<Unit> pages = this.unitService.queryUnitByPage(criteria, sort, Integer.valueOf(page) - 1,
				Integer.valueOf(limit));
		if (pages.getTotalPages() > 0) {
			Map<String, Object> map = null;
			Unit firstUnit = null;
			for (Unit unit : pages.getContent()) {
				map = new HashMap<String, Object>();
				String id = unit.getId();
				String name = unit.getUnitName();
				Integer unitNum = unit.getUnitNum();
				map.put("id", id);
				map.put("unitName", name);
				map.put("unitNum", unitNum);
				if (name.equals(this.firstUnit)) {
					if (!StringUtil.isNotBlank(type)) {
						listMap.add(0, map);
					}

				} else {
					listMap.add(map);
				}
			}
		}
		Map<String, Object> unitMap = new LinkedHashMap<String, Object>();
		unitMap.put("code", 0);
		unitMap.put("msg", "");
		unitMap.put("count", pages.getTotalElements());
		unitMap.put("data", listMap);
		return unitMap;
	}

	// 编辑单位
	@RequestMapping("unitEdit")
	@ResponseBody
	public String unitEdit(HttpServletRequest request) throws IllegalAccessException {
		String editUnit = request.getParameter("editUnit");
		Unit unit = (Unit) this.StringtoBean(editUnit, Unit.class);
		this.unitService.saveUnit(unit);
		return this.Success;
	}

	// 解散单位
	@RequestMapping("unitRelease")
	@ResponseBody
	public String unitRelease(HttpServletRequest request) {
		String id = request.getParameter("id");
		Unit unit = this.unitService.findUnitById(id);
		int unitNum = unit.getUnitNum();
		if (unitNum == 0) {
			this.unitService.deleteUnitByIds(id);
		} else {
			System.out.println("当前单位存在人员");
		}
		return Success;
	}


	@RequestMapping("userPage")
	@ResponseBody
	public Object peoplePage(HttpServletRequest request) {
		Map<String, Object> resultMap = new LinkedHashMap<String, Object>();
		String unitId = request.getParameter("unitId");
		String page = request.getParameter("page");
		String limit = request.getParameter("limit");
		String name = request.getParameter("name");
		String state = request.getParameter("state");
		Criteria<User> criteria = new Criteria<>();
		int unitNameFlag = 0;
		if (StringUtil.isNotBlank(unitId)) {
			criteria.add(Restrictions.eq("unit", this.unitService.findUnitById(unitId), false));
			Unit unit = this.unitService.findUnitById(unitId);
			String unitName = unit.getUnitName();
			// 默认不是未分配人员
			if (unitName.equals(firstUnit)) {
				unitNameFlag = 1;
			}
		}

		if (StringUtil.isNotBlank(name)) {
			criteria.add(Restrictions.like("name", name, false));
		}

		if (StringUtil.isNotBlank(state)) {
			criteria.add(Restrictions.eq("state", Integer.valueOf(state), false));
		}
		Order order = new Order(Direction.DESC, "id");// 根据id排序
		Sort sort = new Sort(order);
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		Page<User> pages = this.userService.queryUserByPage(criteria, sort, Integer.valueOf(page) - 1,
				Integer.valueOf(limit));
		if (pages.getTotalPages() > 0) {
			Map<String, Object> map = null;
			for (User user : pages.getContent()) {
				map = new HashMap<String, Object>();
				String id = user.getId();
				String userName = user.getName();
				String phone = user.getPhone();
				map.put("id", id);
				map.put("state", user.getState());
				map.put("userName", userName);
				map.put("phone", phone);
				if (user.getUnit() != null) {
					map.put("unitName", user.getUnit().getUnitName());
				}
				if (StringUtil.isNotBlank(unitId)) {
					map.put("hide", true);
					map.put("unitNameFlag", unitNameFlag);
				}
				listMap.add(map);
			}
		}
		Map<String, Object> peopleMap = new LinkedHashMap<String, Object>();
		peopleMap.put("code", 0);
		peopleMap.put("msg", "");
		peopleMap.put("count", pages.getTotalElements());
		peopleMap.put("data", listMap);
		return peopleMap;
	}

	// 人员管理界面
	@RequestMapping("userView")
	public String userView(HttpServletRequest request) {
		return userView;
	}

	// 新增人员界面
	@RequestMapping("userAddView")
	public String userAddView(HttpServletRequest request) {
		String unitId = request.getParameter("unitId");
		String id = request.getParameter("id");
		User user = null;
		if (StringUtil.isNotBlank(id)) {
			user = this.userService.findUserById(id);
		} else {
			user = new User();
		}
		request.setAttribute("user", user);
		request.setAttribute("unitId", unitId);
		return userAdd;
	}

	// 人员增加
	@RequestMapping(value = "userAdd", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> userAdd(HttpServletRequest request, User user) {
		String unitId = request.getParameter("unitId");
		String editFlag = request.getParameter("editFlag");
		Map<String, Object> tipMsg = new HashedMap<>();
		// 编辑标记
		Unit unit = this.unitService.findUnitById(unitId);
		if (StringUtil.isNotBlank(editFlag)) {
			String beforeLoginName = request.getParameter("beforeLoginName");
			String nowLonginName = user.getLoginName();
			// 编辑
			if (beforeLoginName.equals(nowLonginName)) {
				user.setUnit(unit);
				tipMsg.put("msg", 1);
				this.userService.saveUser(user);
			} else {
				User isUser = this.userService.findIsUser(user);
				if (isUser != null) {
					tipMsg.put("msg", 0);
				} else {
					user.setUnit(unit);
					tipMsg.put("msg", 1);
					this.userService.saveUser(user);
				}
			}
		} else {
			user.setState(0);
			user.setLoginPsw(MD5Util.encode(this.initPsw));
			user.setUnit(unit);
			User isUser = this.userService.findIsUser(user);
			if (isUser != null) {
				tipMsg.put("msg", 0);
			} else {
				tipMsg.put("msg", 1);
				this.userService.saveUser(user);
			}
		}

		return tipMsg;
	}

	// 删除单位-人员
	@RequestMapping("userDelet")
	@ResponseBody
	public String peopleDelet(HttpServletRequest request) {
		String id = request.getParameter("id");
		this.userService.deleteUserByIds(id);
		return Success;
	}

	// 人员状态
	@RequestMapping("userStateOpen")
	@ResponseBody
	public String userStateOpen(HttpServletRequest request) {
		String id = request.getParameter("id");
		User user = this.userService.findUserById(id);
		int chang = 0;
		int state = user.getState();
		if (state == 0) {
			chang = 1;// 禁用
		} else {
			chang = 0;// 启用
		}
		user.setState(chang);
		this.userService.saveUser(user);
		return Success;
	}

	// 用户批量删除
	@RequestMapping("userBatchDelet")
	@ResponseBody
	public String userBatchDelet(HttpServletRequest request) {
		String ids = request.getParameter("ids");
		String idsArr[] = ids.split(",");
		User user = this.userService.findUserById(idsArr[0]);
		Unit unit = user.getUnit();
		unit.setUnitNum(unit.getUnitNum() - idsArr.length);
		this.unitService.saveUnit(unit);
		for (int i = 0; i < idsArr.length; i++) {
			this.userService.deleteUserByIds(idsArr[i]);
		}
		return Success;
	}

	// 用户分配部门界面
	@RequestMapping("userUnitSetView")
	public String userUnitPowerSet(HttpServletRequest request) {
		String userId = request.getParameter("id");
		request.setAttribute("userId", userId);
		return userUnitSet;
	}
	
		
		// 用户分配角色
		@RequestMapping("userRoleSetView")
		public String userRoleSetView(HttpServletRequest request) {
			String userId = request.getParameter("id");
			User user = this.userService.findUserById(userId);
			List<Role> roles=user.getRoles();
			if(roles.size()>0) {
				String roleIds="";
				for(int i=0;i<roles.size();i++) {
					String roleId =roles.get(i).getId();
					if(i==0) {
						roleIds=roleId;	
					}else {
						roleIds+=","+roleId;
					}
				}
		    request.setAttribute("roleIds", roleIds);
			}
			request.setAttribute("roles", roles);
			request.setAttribute("userId", userId);
			return userSetRole;
       }
		
		// 用户分配角色
		@RequestMapping("userRoleSet")
		@ResponseBody
		public String userRoleSet(HttpServletRequest request) {
			String userId = request.getParameter("userId");
			String roles=request.getParameter("roles");
			User user =this.userService.findUserById(userId);
			//当前选择的角色不为空
			List<Role> roleList=new ArrayList<>();
			if(StringUtil.isNotBlank(roles)) {
				String roleArr[]=roles.split(",");
				for(int i=0;i<roleArr.length;i++) {
					String roleId=roleArr[i].replaceAll(" ", "");
					Role role=this.roleService.findRoleById(roleId);
					roleList.add(role);
				}
			}
			user.setRoles(roleList);
            this.userService.saveUser(user);
			return Success;
       }
     

	// 分配功能
	@RequestMapping("userUnitSet")
	@ResponseBody
	public String userUnitSet(HttpServletRequest request) {
		String unitId = request.getParameter("unitId");
		String userId = request.getParameter("userId");
		User user = this.userService.findUserById(userId);
		Unit unit = this.unitService.findUnitById(unitId);
		Unit useUnit = this.unitService.saveUnit(unit);
		user.setUnit(useUnit);
		this.userService.saveUser(user);
		return Success;
	}

	// 分配角色界面
	@RequestMapping("roleView")
	public String roleView(HttpServletRequest request) {
		String view = "";
		String roleViewType = request.getParameter("roleViewType");
		if (roleViewType.equals("roleView")) {
			view = roleView;
		} else if (roleViewType.equals("roleAddView")) {
			view = roleAddView;
		} else if (roleViewType.equals("roleEditView")) {
			String id = request.getParameter("id");
			Role role = this.roleService.findRoleById(id);
			view = roleAddView;
			request.setAttribute("role", role);
		} else if (roleViewType.equals("rolePowerView")) {
			String id = request.getParameter("id");
			view = rolePowerSetView;
			request.setAttribute("roleId", id);
		}
		return view;
	}

	@RequestMapping("rolePage")
	@ResponseBody
	public Object rolePage(HttpServletRequest request) {
		String page = request.getParameter("page");
		String limit = request.getParameter("limit");
		String queryRoleName = request.getParameter("roleName");
		Criteria<Role> criteria = new Criteria<>();
		if (StringUtil.isNotBlank(queryRoleName)) {
			criteria.add(Restrictions.like("roleName", queryRoleName, false));
		}
		Order order = new Order(Direction.DESC, "id");// 根据id排序
		Sort sort = new Sort(order);
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		Page<Role> pages = this.roleService.queryRoleByPage(criteria, sort, Integer.valueOf(page) - 1,
				Integer.valueOf(limit));
		if (pages.getTotalPages() > 0) {
			Map<String, Object> map = null;
			for (Role role : pages.getContent()) {
				map = new HashMap<String, Object>();
				String id = role.getId();
				String roleName = role.getRoleName();
				map.put("id", id);
				map.put("roleName", roleName);
				listMap.add(map);
			}
		}
		Map<String, Object> roleMap = new LinkedHashMap<String, Object>();
		roleMap.put("code", 0);
		roleMap.put("msg", "");
		roleMap.put("count", pages.getTotalElements());
		roleMap.put("data", listMap);
		return roleMap;
	}

	// 创建角色
	@RequestMapping("creatRole")
	@ResponseBody
	public Map<String, Object> creatRole(HttpServletRequest request) {
		Map<String, Object> tipMsg = new HashedMap<>();
		String roleName = request.getParameter("roleName");
		Role role = this.roleService.isExistRole(roleName);
		// 当前没有此角色
		if (role == null) {
			// 创建角色
			Role newRole = new Role();
			newRole.setRoleName(roleName);
			tipMsg.put("msg", 0);
			this.roleService.saveRole(newRole);
		} else {
			tipMsg.put("msg", 1);
		}
		return tipMsg;
	}

	// 删除角色
	@RequestMapping("deletRole")
	@ResponseBody
	public String deletRole(HttpServletRequest request) {
		String id = request.getParameter("id");
		// 进行角色删除
		this.roleService.deleteRoleByIds(id);
		return Success;
	}

	// 编辑角色
	@RequestMapping("editRole")
	@ResponseBody
	public String editRole(HttpServletRequest request) {
		String editRole = request.getParameter("editRole");
		JSONObject obj = JSONObject.fromObject(editRole);
		Role role = (Role) JSONObject.toBean(obj, Role.class);
		// 进行保存
		this.roleService.saveRole(role);
		return Success;
	}

	// 角色-权限树
	@RequestMapping("rolePowerData")
	@ResponseBody
	public Object rolePower(HttpServletRequest request) {
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		String roleId = request.getParameter("roleId");
		Role role = this.roleService.findRoleById(roleId);
		List<Power> havePowers = role.getPowers();
		// 查出所有权限
		Criteria<Power> criteria = new Criteria<>();
		criteria.add(Restrictions.eq("pid", "menu", false));
		// 排序规则
		Order order = new Order(Direction.DESC, "id");// 根据id排序
		Sort sort = new Sort(order);
		List<Power> parent = this.powerService.queryPowerByCondition(criteria, sort);
		for (int i = 0; i < parent.size(); i++) {
			Power power = parent.get(i);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("name", power.getPowerName());
			map.put("value", power.getId());
			map.put("disabled", false);
			String childId = power.getId();
			Criteria<Power> childCriteria = new Criteria<>();
			childCriteria.add(Restrictions.eq("pid", childId, false));
			List<Power> childList = this.powerService.queryPowerByCondition(childCriteria, sort);
			List<Map<String, Object>> childDataMap = new ArrayList<Map<String, Object>>();
			for (int j = 0; j < childList.size(); j++) {
				Power child = childList.get(j);
				// 已选的权限
				Map<String, Object> childMap = new HashMap<String, Object>();
				childMap.put("name", child.getPowerName());
				childMap.put("value", child.getId());
				childMap.put("disabled", false);
				if (havePowers.indexOf(child) != -1) {
					childMap.put("checked", true);
					map.put("checked", true);
				}
				childDataMap.add(childMap);
			}
			map.put("list", childDataMap);
			listMap.add(map);
		}
		Map<String, Object> roleMap = new LinkedHashMap<String, Object>();
		roleMap.put("code", 0);
		roleMap.put("msg", "获取成功");
		roleMap.put("data", listMap);
		return roleMap;
	}

	// 角色权限设置
	@RequestMapping("rolePowerSet")
	@ResponseBody
	public String rolePowerSet(HttpServletRequest request) {
		String roleId = request.getParameter("roleId");
		String powerId = request.getParameter("powerId");
		Role role = this.roleService.findRoleById(roleId);
		List<Power> powerList = new ArrayList<>();
		if (StringUtil.isNotBlank(powerId)) {
			String powerIds[] = powerId.split(",");
			for (int i = 0; i < powerIds.length; i++) {
				String id = powerIds[i];
				Power power = this.powerService.findPowerById(id);
				powerList.add(power);
			}
		}
		role.setPowers(powerList);
		this.roleService.saveRole(role);
		return Success;
	}

	@RequestMapping("menuView")
	public String menuView(HttpServletRequest request) {
		String menuViewType = request.getParameter("menuViewType");
		String view = "";
		if (menuViewType.equals("menuAdd")) {
			view = menuAddView;
		} else if (menuViewType.equals("menuPower")) {
			String pid = request.getParameter("pid");
			request.setAttribute("pid", pid);
			view = menuPower;
		} else if (menuViewType.equals("menuEdit")) {
			String menuId = request.getParameter("id");
			Menu menu = this.menuService.findMenuById(menuId);
			request.setAttribute("menu", menu);
			//菜单和排序
			if(StringUtil.isNotBlank(menu.getSortFlag())){
				request.setAttribute("nameAndSort", menu.getMenuName()+"-"+menu.getSortFlag());
			}else{
				request.setAttribute("nameAndSort", menu.getMenuName());
			}
			//时间转字符串
			String createTime="";
			if(menu.getCreatTime()!=null){
				createTime=DateUtil.format(menu.getCreatTime(),"yyyy-MM-dd HH:mm:ss");
			}
			request.setAttribute("createTime", createTime);
			request.setAttribute("power", menu.getPower());
			view = menuEdit;
		} else if (menuViewType.equals("menuView")) {
			Criteria<Menu> first = new Criteria<>();
			first.add(Restrictions.eq("pid", "first", false));
			Menu firstMenu = this.menuService.uniqueMenuByCondtion(first);
			request.setAttribute("menu", firstMenu);
			view = menuView;
		} else if (menuViewType.equals("powerChoose")) {
			view = powerChoose;
		}
		return view;
	}

	// 查询菜单按钮
	@RequestMapping("query-menu-tree")
	@ResponseBody
	public Object queryMenuTree(HttpServletRequest request) throws Exception {
		String menuName = request.getParameter("menuName");
		String page = request.getParameter("page");
		String limit = request.getParameter("limit");
		//判断当前是否有进行修改
		String editMenuId=request.getParameter("editMenuId");
		Page<Menu> pages=null;
		List<Menu> menuList = new ArrayList<>();
		Criteria<Menu> criteria = new Criteria<>();
		if (StringUtil.isNotBlank(menuName)) {
			criteria.add(Restrictions.like("menuName", menuName, false));
			pages=this.menuService.queryMenuByPage(criteria, null,Integer.valueOf(page)-1, Integer.valueOf(limit));
		} else {
			criteria.add(Restrictions.eq("pid", "first", false));
			Menu fatherMenu=this.menuService.uniqueMenuByCondtion(criteria);
			Criteria<Menu> criteria2 = new Criteria<>();
			criteria2.add(Restrictions.eq("pid",fatherMenu.getId(), false));
			Order order = new Order(Direction.DESC, "creatTime");// 根据创建时间进行排序
			Sort sort = new Sort(order);
			pages=this.menuService.queryMenuByPage(criteria2, sort,Integer.valueOf(page)-1, Integer.valueOf(limit));
			if (pages.getTotalPages() > 0) {
				for (Menu menu : pages.getContent()) {
					List<Menu> menus=new ArrayList<>();
					menus.add(menu);
					List<Menu> nowMenus=this.menuService.getAllMenuByFatherMeun(menus);
					if(nowMenus.size()==0) {
						menuList.add(menu);
					}
					//主菜单添加
					List<Long> dateList=new ArrayList<>();
					Map<Long,Menu> map=new HashMap<>();
					for(int i=0;i<nowMenus.size();i++) {
						//menuList.add(nowMenus.get(i));
						if(nowMenus.get(i).getCreatTime()==null) {
							dateList.add(Long.valueOf(i));
							map.put(Long.valueOf(i),nowMenus.get(i));
						}else {
							dateList.add(nowMenus.get(i).getCreatTime().getTime());
							map.put(nowMenus.get(i).getCreatTime().getTime(),nowMenus.get(i));
						}
					}

					//时间排序完成
					Collections.sort(dateList,Collections.reverseOrder());
					for(int i=0;i<dateList.size();i++) {
						menuList.add(map.get(dateList.get(i)));
					}
				}
			}
		}
		List<Map<String, Object>> listMap = new ArrayList<Map<String, Object>>();
		// 查询所有的菜单
		List<Menu> sortMenuList=sortMenu(menuList);
		for (int i = 0; i < sortMenuList.size(); i++) {
			Menu menu = menuList.get(i);
			Power power = menu.getPower();
			String powerName = "";
			String url = "";
			if (power != null) {
				powerName = power.getPowerName();
				url = power.getUrl();
			}
			Map<String, Object> map = new HashMap<>();
			if (menu.getPid().equals("first")) {
				map.put("pId", "first");
			} else if (menu.getPid().equals("menu")) {
				map.put("pId", null);
			} else {
				map.put("pId", menu.getPid());
			}
			if(menu.getIconFlag()==1) {
				map.put("icon", menu.getIcon());
			}else {
				map.put("icon","");
			}
			//进行判断当前是否修改
			if(StringUtil.isNotBlank(editMenuId)) {
				Menu editMenu=this.menuService.findMenuById(editMenuId);
				Criteria<Menu> condition=new Criteria<>();
				condition.add(Restrictions.eq("pid","first", false));
				Menu firstMenu=this.menuService.uniqueMenuByCondtion(condition);
				if(!editMenu.getPid().equals(firstMenu.getId())) {
				    Menu father=this.menuService.getFatherMenuByChildMenu(editMenu);
				    if(father.getId().equals(menu.getId())) {
						map.put("lay_is_open", true);
				    }
				}
			}
			//map.put("lay_is_open", true);
			map.put("id", menu.getId());
			map.put("name", menu.getMenuName());
			map.put("powerName", powerName);
			map.put("url", url);
			listMap.add(map);
		
		}
		Map<String, Object> msgMap = new LinkedHashMap<String, Object>();
		msgMap.put("count", pages.getTotalElements());
		msgMap.put("code", 0);
		msgMap.put("is", true);
		msgMap.put("msg", "");
		msgMap.put("tip", "操作成功");
		msgMap.put("data", listMap);
		msgMap.put("pages", Integer.valueOf(page));
		return msgMap;
	}

	// 菜单添加
	@RequestMapping("menu-add-edit")
	@ResponseBody
	public Object menuAdd(HttpServletRequest request) throws Exception {
		// 获得相关数据
		String data = request.getParameter("data");
		JSONObject obj = JSONObject.fromObject(data);
		Menu menu = new Menu();
		menu.setId((String) obj.get("menuId"));
		menu.setPid((String) obj.get("pid"));
		String time=(String)obj.get("creatTime");
		if(StringUtil.isNotBlank(time)) {
			menu.setCreatTime(DateUtil.parseDateTime(time));
		}else {
			menu.setCreatTime(new Date());
		}
		
		if (obj.get("icon") != null) {
			menu.setIcon((String) obj.get("icon"));
		}
		menu.setIconFlag(Integer.valueOf((String) obj.get("iconFlag")));
		String addMenuName=((String) obj.get("menuName"));
		//包含排序
		if(addMenuName.indexOf("-")!=-1){
			String oneMenu=addMenuName.split("-")[0];
			String soft=addMenuName.split("-")[1];
			menu.setMenuName(oneMenu);
			menu.setSortFlag(soft);
		}else{
			menu.setMenuName((String) obj.get("menuName"));
		}
		Power power = null;
		String powerId = (String) obj.get("choosePowerId");
		if (!powerId.equals("clearPower")) {
			power = this.powerService.findPowerById((String) obj.get("choosePowerId"));
		}
		menu.setPower(power);
		// 进行保存
		Menu saveMenu = this.menuService.saveMenu(menu);
		//得到主界面pid
		Menu pMenu=this.menuService.findMenuById((String) obj.get("pid"));
		//主菜单权限设置为空
		pMenu.setPower(null);
		this.menuService.saveMenu(pMenu);
		return saveMenu;
	}

	// 菜单删除
	@RequestMapping("menu-delet")
	@ResponseBody
	public Object menuDelet(HttpServletRequest request) throws Exception {
		String menuId = request.getParameter("id");
		Criteria<Menu> criteria = new Criteria<>();
		criteria.add(Restrictions.eq("pid", menuId, false));
		List<Menu> childrenMenu = this.menuService.queryMenuByCondition(criteria, null);
		String ids = menuId;
		// 子节点先删除
		for (int i = 0; i < childrenMenu.size(); i++) {
			Menu menu = childrenMenu.get(i);
			String id = menu.getId();
			// 拼接
			ids += "," + id;
		}
		this.menuService.deleteMenuByIds(ids);
		return Success;
	}
    
	@RequestMapping("revise-password-view")
	public String revisePasswordView(HttpServletRequest request,HttpServletResponse response) {
		return revisePasswordView;
	}
	
	//人员密码修改
	@RequestMapping("revise-passWork")
	@ResponseBody
    public Map<String,Object> revisePassWork(HttpServletRequest request) throws Exception {
		User user=this.getCurrentSystemUser(request);
		String oldPassWord=request.getParameter("oldPassword");
		Map<String,Object> msg=new HashMap<>();
		//密码验证成功
		if(user.getLoginPsw().equals(MD5Util.encode(oldPassWord))) {
			String newPassWord=request.getParameter("newPassword");
			user.setLoginPsw(MD5Util.encode(newPassWord));
			this.userService.saveUser(user);
			msg.put("msg",0);
		}else {
			msg.put("msg",1);
		}
		return msg;
	}
	
	//人员登出
	@RequestMapping("login-out")
	public String loginOut(HttpServletRequest request,HttpServletResponse response) {
		request.getSession().removeAttribute("SYS_USER");
		return "redirect:/"+request.getContextPath();
	}
 	
}
