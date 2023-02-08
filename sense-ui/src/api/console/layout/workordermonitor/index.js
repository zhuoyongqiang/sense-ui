import request from '@/utils/request'

export function list(query) {
  return request({
    url: '/console/layout/workOrderMonitor/list',
    method: 'get',
    params: query
  })
}

// 查询详细
export function findById(id) {
  return request({
    url: '/console/layout/workOrderMonitor/' + id,
    method: 'get'
  })
}

// 修改
export function update(data) {
  return request({
    url: '/console/layout/workOrderMonitor',
    method: 'put',
    data: data
  })
}


// 删除新闻定义
export function remove(id) {
  return request({
    url: '/console/layout/workOrderMonitor/' + id,
    method: 'delete'
  })
}

