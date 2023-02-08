import request from '@/utils/request'


//查询所有应用
export function allApp(query) {
  return request({
    url: '/console/system/app/all',
    method: 'get',
    params: query
  })
}

// 查询应用列表
export function listApp(query) {
  return request({
    url: '/console/system/app/list',
    method: 'get',
    params: query
  })
}

// 查询应用详细
export function getApp(id) {
  return request({
    url: '/console/system/app/' + id,
    method: 'get'
  })
}

// 新增应用
export function addApp(data) {
  return request({
    url: '/console/system/app',
    method: 'post',
    data: data
  })
}

// 修改应用
export function updateApp(data) {
  return request({
    url: '/console/system/app',
    method: 'put',
    data: data
  })
}

// 删除应用
export function delApp(id) {
  return request({
    url: '/console/system/app/' + id,
    method: 'delete'
  })
}

// 导出应用
export function exportApp(query) {
  return request({
    url: '/console/system/app/export',
    method: 'get',
    params: query
  })
}


// 上传图片
export function uploadFile(data) {
  return request({
    url: '/console/system/app/upload',
    method: 'post',
    params: data,
    headers:{
      'Authorization': "Bearer " + getToken(),
      'Content-Type':'multipart/form-data'
    },
    
  })
}
