import request from '@/utils/request'

// 查询评论管理列表
export function listInfoComment(query) {
  return request({
    url: '/console/info/comment/list',
    method: 'get',
    params: query
  })
}

// 查询评论管理详细
export function getInfoComment(id) {
  return request({
    url: '/console/info/comment/' + id,
    method: 'get'
  })
}

// 新增评论管理
export function addInfoComment(data) {
  return request({
    url: '/console/info/comment',
    method: 'post',
    data: data
  })
}

// 修改评论管理
export function updateInfoComment(data) {
  return request({
    url: '/console/info/comment',
    method: 'put',
    data: data
  })
}

// 删除评论管理
export function delInfoComment(id) {
  return request({
    url: '/console/info/comment/' + id,
    method: 'delete'
  })
}

// 导出评论管理
export function exportInfoComment(query) {
  return request({
    url: '/console/info/comment/export',
    method: 'get',
    params: query
  })
}

//批量通过
export function accessOkInfoComment(id) {
  return request({
    url: '/console/info/comment/accessOk/' + id,
    method: 'post'
  })
}

//批量拒绝
export function accessNotInfoComment(id) {
  return request({
    url: '/console/info/comment/accessNot/' + id,
    method: 'post'
  })
}