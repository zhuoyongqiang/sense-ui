import request from '@/utils/request'


//查询所有BANNER
export function allBanner(query) {
  return request({
    url: '/console/info/banner/all',
    method: 'get',
    params: query
  })
}

// 查询BANNER列表
export function listBanner(query) {
  return request({
    url: '/console/info/banner/list',
    method: 'get',
    params: query
  })
}

// 查询BANNER详细
export function getBanner(id) {
  return request({
    url: '/console/info/banner/' + id,
    method: 'get'
  })
}

// 新增BANNER
export function addBanner(data) {
  return request({
    url: '/console/info/banner',
    method: 'post',
    data: data
  })
}

// 修改BANNER
export function updateBanner(data) {
  return request({
    url: '/console/info/banner',
    method: 'put',
    data: data
  })
}

// 删除BANNER
export function delBanner(id) {
  return request({
    url: '/console/info/banner/' + id,
    method: 'delete'
  })
}

