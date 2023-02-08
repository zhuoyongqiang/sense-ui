import request from '@/utils/request'

// 查询component列表
export function listComponent(query) {
  return request({
    url: '/console/system/component/list',
    method: 'get',
    params: query
  })
}

// 查询component详细
export function getComponent(id) {
  return request({
    url: '/console/system/component/' + id,
    method: 'get'
  })
}


// 删除component
export function delComponent(id) {
  return request({
    url: '/console/system/component/' + id,
    method: 'delete'
  })
}

// 根据类型获取全部组件
export function loadComponent(id) {
  return request({
    url: '/console/system/component/loadCmponent/' + id,
    method: 'get'
  })
}

//加载组件类信息
export function loadRunClass(id) {
  return request({
    url: '/console/system/component/loadRunClass/' + id,
    method: 'get'
  })
}
