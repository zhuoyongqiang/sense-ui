import request from '@/utils/request'


//查询所有点击日志
export function allInfoLog(query) {
  return request({
    url: '/console/info/infoLog/all',
    method: 'get',
    params: query
  })
}

// 查询点击日志列表
export function listInfoLog(query) {
  return request({
    url: '/console/info/infoLog/list',
    method: 'get',
    params: query
  })
}

// 查询点击日志详细
export function getInfoLog(id) {
  return request({
    url: '/console/info/infoLog/' + id,
    method: 'get'
  })
}

// 新增点击日志
export function addInfoLog(data) {
  return request({
    url: '/console/info/infoLog',
    method: 'post',
    data: data
  })
}


// 根据类型统计日志
export function selectStatistics(query) {
  return request({
    url: '/console/info/infoLog/selectStatistics',
    method: 'get',
    params: query
  })
}


