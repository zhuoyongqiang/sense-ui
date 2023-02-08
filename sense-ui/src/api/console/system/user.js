import request from '@/utils/request'
import {praseStrEmpty} from "@/utils/sense";

// 查询用户列表
export function listUser(query) {
  return request({
    url: '/console/system/user/list',
    method: 'get',
    params: query
  })
}
// 查询用户列表
export function listPro(query) {
  return request({
    url: '/console/system/user/listPro',
    method: 'get',
    params: query
  })
}

// 查询用户列表
export function getUsersByPhone() {
  return request({
    url: '/console/system/user/getUsersByPhone',
    method: 'get',
  })
}


// 查询角色关联的用户
export function getUserInfoByRoleId(roleId) {
  return request({
    url: '/console/system/user/getUserInfoByRoleId/' + praseStrEmpty(roleId),
    method: 'get',
  })
}

// 查询岗位关联的用户
export function getUserInfoByPostId(roleId) {
  return request({
    url: '/console/system/user/getUserInfoByPostId/' + praseStrEmpty(roleId),
    method: 'get',
  })
}

// 查询用户列表
export function listByOrgdept(query) {
  return request({
    url: '/console/system/user/listByOrgdept',
    method: 'get',
    params: query
  })
}


// 查询用户详细
export function getUser(userId) {
  return request({
    url: '/console/system/user/' + praseStrEmpty(userId),
    method: 'get'
  })
}

// 新增用户
export function addUser(data) {
  return request({
    url: '/console/system/user',
    method: 'post',
    data: data
  })
}

// 修改用户
export function updateUser(data) {
  return request({
    url: '/console/system/user',
    method: 'put',
    data: data
  })
}

// 删除用户
export function delUser(userId) {
  return request({
    url: '/console/system/user/' + userId,
    method: 'delete'
  })
}

// 导出用户
export function exportUser(query) {
  return request({
    url: '/console/system/user/export',
    method: 'get',
    params: query
  })
}

// 用户密码重置
export function resetUserPwd(userId, password) {
  const data = {
    userId,
    password
  }
  return request({
    url: '/console/system/user/resetPwd',
    method: 'put',
    data: data
  })
}

// 用户状态修改
export function changeUserStatus(userId, status) {
  const data = {
    userId,
    status
  }
  return request({
    url: '/console/system/user/changeStatus',
    method: 'put',
    data: data
  })
}

// 查询用户个人信息
export function getUserProfile() {
  return request({
    url: '/console/system/user/profile',
    method: 'get'
  })
}

// 修改用户个人信息
export function updateUserProfile(data) {
  return request({
    url: '/console/system/user/profile',
    method: 'put',
    data: data
  })
}

// 用户密码重置
export function updateUserPwd(oldPasswd, newPasswd) {
  const data = {
    oldPasswd,
    newPasswd
  }
  return request({
    url: '/console/system/user/profile/updatePwd',
    method: 'put',
    params: data
  })
}

// 用户头像上传
export function uploadAvatar(data) {
  return request({
    url: '/console/system/user/profile/avatar',
    method: 'post',
    data: data
  })
}

// 下载用户导入模板
export function importTemplate() {
  return request({
    url: '/console/system/user/importTemplate',
    method: 'get'
  })
}

//获取当天生日的用户列表
export function getTodayBirthdayUserList() {
  return request({
    url: '/console/system/user/find/getTodayBirthdayUserList',
    method: 'get'
  })
}


// 获取用户的常用联系人集合
export function listContactsUserList(query) {
  return request({
    url: '/console/system/user/find/contactsUserList',
    method: 'get',
    params: query
  })
}

// 删除联系人
export function deleteContactsUserList(query) {
  return request({
    url: '/console/system/user/delete/contactsUserList',
    method: 'delete',
    data: query
  })
}

// 新增联系人
export function insertContactsUserList(query) {
  return request({
    url: '/console/system/user/insert/contactsUserList',
    method: 'post',
    data: query
  })
}

// 查询全机构人员(含机构)
export function treeselectNewPro() {
  return request({
    url: '/console/system/dept/treeselectNewPro',
    method: 'get'
  })
}

// 查询历史记录
export function getContactsHistory() {
  return request({
    url: '/console/system/group/getContactsHistory',
    method: 'get'
  })
}

// 移除历史记录，支持单条或者批量
export function removeContactsHistory(data) {
  return request({
    url: '/console/system/group/removeContactsHistory',
    method: 'delete',
    data
  })
}

// 新增历史记录
export function contactsHistory(data) {
  return request({
    url: '/console/system/group/contactsHistory',
    method: 'post',
    data
  })
}

// 插入用户授权应用
export function insertUserApp(params,data) {
  return request({
    url: '/console/system/user/insertUserApp',
    method: 'post',
    params:params,
    data:data
  })
}

// 修改主店
export function changeMainShop(params) {
  return request({
    url: '/console/system/user/changeMainShop',
    method: 'post',
    params:params
  })
}

export function insertBeachUserApp(data) {
  return request({
    url: '/console/system/user/insertBeachUserApp',
    method: 'post',
    data:data
  })
}

