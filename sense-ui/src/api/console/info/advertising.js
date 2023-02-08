import request from '@/utils/request'


//查询所有广告
export function allAdvertising(query) {
  return request({
    url: '/console/info/advertising/all',
    method: 'get',
    params: query
  })
}

// 查询广告列表
export function listAdvertising(query) {
  return request({
    url: '/console/info/advertising/list',
    method: 'get',
    params: query
  })
}

// 查询广告详细
export function getAdvertising(id) {
  return request({
    url: '/console/info/advertising/' + id,
    method: 'get'
  })
}

// 新增广告
export function addAdvertising(data) {
  return request({
    url: '/console/info/advertising',
    method: 'post',
    data: data
  })
}

// 修改广告
export function updateAdvertising(data) {
  return request({
    url: '/console/info/advertising',
    method: 'put',
    data: data
  })
}

// 删除广告
export function delAdvertising(id) {
  return request({
    url: '/console/info/advertising/' + id,
    method: 'delete'
  })
}

