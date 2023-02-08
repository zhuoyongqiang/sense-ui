import request from '@/utils/request'


//查询所有下载类型
export function allMeterialType(query) {
  return request({
    url: '/console/dwl/meterialType/all',
    method: 'get',
    params: query
  })
}

// 查询下载类型列表
export function listMeterialType(query) {
  return request({
    url: '/console/dwl/meterialType/list',
    method: 'get',
    params: query
  })
}

// 查询下载类型详细
export function getMeterialType(id) {
  return request({
    url: '/console/dwl/meterialType/' + id,
    method: 'get'
  })
}

// 新增下载类型
export function addMeterialType(data) {
  return request({
    url: '/console/dwl/meterialType',
    method: 'post',
    data: data
  })
}

// 修改下载类型
export function updateMeterialType(data) {
  return request({
    url: '/console/dwl/meterialType',
    method: 'put',
    data: data
  })
}

// 删除下载类型
export function delMeterialType(id) {
  return request({
    url: '/console/dwl/meterialType/' + id,
    method: 'delete'
  })
}

