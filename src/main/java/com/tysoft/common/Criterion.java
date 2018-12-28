package com.tysoft.common;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

/**     
 * @Title: Criterion.java   
 * @Package com.lottery.respository.common   
 * @Description: TODO(条件接口 用户提供条件表达式接口)   
 * @author 李世康     
 * @date 2017年10月27日 上午8:35:49   
 * @version V1.0     
 */
public interface Criterion {
	public enum Operator {
        EQ, NE, LIKE, GT, LT, GTE, LTE, AND, OR, ISNOTNULL, ISNULL,LEFTLIKE,RIGHTLIKE
    }

    public Predicate toPredicate(Root<?> root, CriteriaQuery<?> query,
                                 CriteriaBuilder builder);
}
