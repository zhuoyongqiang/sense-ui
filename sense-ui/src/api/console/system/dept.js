import request from '@/utils/request'

// 查询部门列表
export function listDept(query) {
  return request({
    url: '/console/system/dept/list',
    method: 'get',
    params: query
  })
}

// 查询部门列表（排除节点）
export function listDeptExcludeChild(deptId) {
  return request({
    url: '/console/system/dept/list/exclude/' + deptId,
    method: 'get'
  })
}

// 查询部门详细
export function getDept(deptId) {
  return request({
    url: '/console/system/dept/' + deptId,
    method: 'get'
  })
}

// 查询部门下拉树结构
export function treeselect(params) {
  return request({
    url: '/console/system/dept/treeselect',
    method: 'get',
    params
  })
}

// 查询部门下拉树结构
export function treeselectByUser(params) {
  return request({
    url: '/console/system/dept/treeselectByUser',
    method: 'get',
    params
  })
}

// 查询部门下拉树结构
export function treeselectPro() {
  return request({
    url: '/console/system/dept/treeselectPro',
    method: 'get'
  })
}

// 根据指定sn长度查询部门下拉树结构
export function treeselectByLength(length) {
  return request({
    url: '/console/system/dept/treeselectByLength?length='+length,
    method: 'get'
  })
}

// 根据角色ID查询部门树结构
export function roleDeptTreeselect(roleId) {
  return request({
    url: '/console/system/dept/roleDeptTreeselect/' + roleId,
    method: 'get'
  })
}

// 新增部门
export function addDept(data) {
  return request({
    url: '/console/system/dept',
    method: 'post',
    data: data
  })
}

// 修改部门
export function updateDept(data) {
  return request({
    url: '/console/system/dept',
    method: 'put',
    data: data
  })
}

// 删除部门
export function delDept(deptId) {
  return request({
    url: '/console/system/dept/' + deptId,
    method: 'delete'
  })
}
