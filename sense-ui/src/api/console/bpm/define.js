import request from '@/utils/request'

// 查询新闻定义列表
export function listBpmNewsDefine(query) {
  return request({
    url: '/bpm/BpmNewsDefine/list',
    method: 'get',
    params: query
  })
}

// 查询新闻定义详细
export function getBpmNewsDefine(id) {
  return request({
    url: '/bpm/BpmNewsDefine/' + id,
    method: 'get'
  })
}

// 新增新闻定义
export function addBpmNewsDefine(data) {
  return request({
    url: '/bpm/BpmNewsDefine',
    method: 'post',
    data: data
  })
}

// 修改新闻定义
export function updateBpmNewsDefine(data) {
  return request({
    url: '/bpm/BpmNewsDefine',
    method: 'put',
    data: data
  })
}

// 删除新闻定义
export function delBpmNewsDefine(id) {
  return request({
    url: '/bpm/BpmNewsDefine/' + id,
    method: 'delete'
  })
}

// 部署新闻定义
export function deployBpmNewsDefine(id) {
  return request({
    url: '/bpm/BpmNewsDefine/deploy/' + id,
    method: 'post'
  })
}

