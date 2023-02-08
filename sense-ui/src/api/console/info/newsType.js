import request from '@/utils/request'

// 查询岗位列表
export function listNewsType(query) {
  return request({
    url: '/console/info/newsType/list',
    method: 'get',
    params: query
  })
}

// 查询岗位详细
export function getNewsType(id) {
  return request({
    url: '/console/info/newsType/' + id,
    method: 'get'
  })
}

// 新增岗位
export function addNewsType(data) {
  return request({
    url: '/console/info/newsType',
    method: 'post',
    data: data
  })
}

// 修改岗位
export function updateNewsType(data) {
  return request({
    url: '/console/info/newsType',
    method: 'put',
    data: data
  })
}

// 删除岗位
export function delNewsType(id) {
  return request({
    url: '/console/info/newsType/' + id,
    method: 'delete'
  })
}

// 导出岗位
export function exportNewsType(query) {
  return request({
    url: '/console/info/newsType/export',
    method: 'get',
    params: query
  })
}
