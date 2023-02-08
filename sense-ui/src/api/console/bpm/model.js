import request from '@/utils/request'

// 查询新闻流程列表
export function listBpmModel(query) {
  return request({
    url: '/bpm/model/list',
    method: 'get',
    params: query
  })
}

// 查询新闻流程详细
export function getBpmModel(id) {
  return request({
    url: '/bpm/model/' + id,
    method: 'get'
  })
}

// 新增新闻流程
export function addBpmModel(data) {
  return request({
    url: '/bpm/model',
    method: 'post',
    data: data
  })
}

// 修改新闻流程
export function updateBpmModel(data) {
  return request({
    url: '/bpm/model',
    method: 'put',
    data: data
  })
}

// 删除新闻流程
export function delBpmModel(id) {
  return request({
    url: '/bpm/model/' + id,
    method: 'delete'
  })
}

// 导出新闻流程
export function exportBpmModel(query) {
  return request({
    url: '/bpm/model/export',
    method: 'get',
    params: query
  })
}

//获取节点审批人
export function resolveNodeUser(node, newsInstanceId) {
  let query = {
    node: node,
    newsInstanceId: newsInstanceId
  };
  return request({
    url: '/bpm/model/resolveNodeUser',
    method: 'get',
    params: query
  })
}
