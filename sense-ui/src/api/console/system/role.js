import request from '@/utils/request'

// 查询角色列表
export function listRole(query) {
  return request({
    url: '/console/system/role/list',
    method: 'get',
    params: query
  })
}

// 查询角色详细
export function getRole(roleId) {
  return request({
    url: '/console/system/role/' + roleId,
    method: 'get'
  })
}

// 新增角色
export function addRole(data) {
  return request({
    url: '/console/system/role',
    method: 'post',
    data: data
  })
}

// 修改角色
export function updateRole(data) {
  return request({
    url: '/console/system/role',
    method: 'put',
    data: data
  })
}

// 角色数据权限
export function dataScope(data) {
  return request({
    url: '/console/system/role/dataScope',
    method: 'put',
    data: data
  })
}

// 角色状态修改
export function changeRoleStatus(roleId, status) {
  const data = {
    roleId,
    status
  }
  return request({
    url: '/console/system/role/changeStatus',
    method: 'put',
    data: data
  })
}

// 删除角色
export function delRole(roleId) {
  return request({
    url: '/console/system/role/' + roleId,
    method: 'delete'
  })
}

// 导出角色
export function exportRole(query) {
  return request({
    url: '/console/system/role/export',
    method: 'get',
    params: query
  })
}

// 根据角色选择关联的新闻分类
export function getNewsTypeIdByRole(roleId) {
  return request({
    url: '/console/system/role/getNewsTypeIdByRole/' + roleId,
    method: 'get'
  })
}

// 获取角色选择框列表
export function optionRoleselect(roleId) {
  return request({
    url: '/console/system/role/optionselect',
    method: 'get'
  })
}

//批量授权用户
export function batchAddUser(data) {
  return request({
    url: '/console/system/role/batchAddUser',
    method: 'post',
    data
  })
}


