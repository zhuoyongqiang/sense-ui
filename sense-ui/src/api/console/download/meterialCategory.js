import request from '@/utils/request'


//查询所有下载中心
export function allMeterialCategory(query) {
  return request({
    url: '/console/dwl/meterialCastgory/all',
    method: 'get',
    params: query
  })
}

// 查询下载中心列表
export function listMeterialCategory(query) {
  return request({
    url: '/console/dwl/meterialCastgory/list',
    method: 'get',
    params: query
  })
}

// 查询下载中心详细
export function getMeterialCategory(id) {
  return request({
    url: '/console/dwl/meterialCastgory/' + id,
    method: 'get'
  })
}

// 新增下载中心
export function addMeterialCategory(data) {
  return request({
    url: '/console/dwl/meterialCastgory',
    method: 'post',
    data: data
  })
}

// 修改下载中心
export function updateMeterialCategory(data) {
  return request({
    url: '/console/dwl/meterialCastgory',
    method: 'put',
    data: data
  })
}
