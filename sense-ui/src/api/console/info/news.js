import request from '@/utils/request'

// 查询内容列表
export function listNews(query) {
  return request({
    url: '/console/info/news/list',
    method: 'get',
    params: query
  })
}

// 查询转载内容列表
export function listTransportNews(query) {
  return request({
    url: '/console/info/news/listTransport',
    method: 'get',
    params: query
  })
}


// 查询内容详细
export function getNews(id) {
  return request({
    url: '/console/info/news/' + id,
    method: 'get'
  })
}

// 查询内容详细
export function preview(id) {
  return request({
    url: '/console/info/news/preview/' + id,
    method: 'get'
  })
}


// 新增内容
export function addNews(data) {
  return request({
    url: '/console/info/news',
    method: 'post',
    data: data
  })
}

// 修改内容
export function updateNews(data) {
  return request({
    url: '/console/info/news',
    method: 'put',
    data: data
  })
}

// 删除内容
export function delNews(id) {
  return request({
    url: '/console/info/news/' + id,
    method: 'delete'
  })
}

// 导出内容
export function exportNews(query) {
  return request({
    url: '/console/info/news/export',
    method: 'get',
    params: query
  })
}

// 重新推送新闻
export function sendNews(data) {
  return request({
    url: '/console/info/news/send',
    method: 'post',
    data: data
  })
}



//禁用新闻
export function disable(id) {
  return request({
    url: '/console/info/news/disable/' + id,
    method: 'put'
  })
}


//启用新闻
export function enabled(id) {
  return request({
    url: '/console/info/news/enabled/' + id,
    method: 'put'
  })
}

// 查询消息列表
export function noticeOfnews (params) {
  return request({
    url: '/console/info/news/msgList',
    method: 'get',
    params
  })
}

// 批量撤回消息
export function revokeMsgByIds (data) {
  return request({
    url: '/console/info/news/revokeMsgByIds',
    method: 'post',
    data
  })
}

// 全量撤回
export function revokeMsgByNewsId (data) {
  return request({
    url: '/console/info/news/asyn/revokeMsgByNewsId',
    method: 'post',
    data
  })
}

// 批量删除消息
export function deleteMsg (data) {
  return request({
    url: `/console/info/news/msg/${data.join(',')}`,
    method: 'delete'
  })
}