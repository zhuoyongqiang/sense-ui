import request from '@/utils/request'


//查询所有下载中心
export function allMeterial(data) {
  return request({
    url: '/console/dwl/meterial/all',
    method: 'post',
    data: data
  })
}

// 查询下载中心列表
export function listMeterial(query) {
  return request({
    url: '/console/dwl/meterial/list',
    method: 'get',
    params: query
  })
}

// 查询下载中心详细
export function getMeterial(id) {
  return request({
    url: '/console/dwl/meterial/' + id,
    method: 'get'
  })
}

// 新增下载中心
export function addMeterial(data) {
  return request({
    url: '/console/dwl/meterial',
    method: 'post',
    data: data
  })
}

// 修改下载中心
export function updateMeterial(data) {
  return request({
    url: '/console/dwl/meterial',
    method: 'put',
    data: data
  })
}

// 删除下载中心
export function delMeterial(id) {
  return request({
    url: '/console/dwl/meterial/' + id,
    method: 'delete'
  })
}


// 修改下载量
export function editDownloadNum(data) {
  return request({
    url: '/console/dwl/meterial/editDownloadNum',
    method: 'put',
    data: data
  })
}

// 修改浏览量
export function editBrowseNum(data) {
  return request({
    url: '/console/dwl/meterial/editBrowseNum',
    method: 'put',
    data: data
  })
}
