import request from '@/utils/request'

export function list(query) {
  return request({
    url: '/console/layout/workEntrust/list',
    method: 'get',
    params: query
  })
}

export function mylist(query) {
  return request({
    url: '/console/layout/workEntrust/mylist',
    method: 'get',
    params: query
  })
}

export function againAction(id) {
  return request({
    url: '/console/layout/workEntrust/again',
    method: 'post',
    data: {id:id}
  })
}

export function listByEntrustId(query) {
  return request({
    url: '/console/layout/workEntrust/listByEntrustId',
    method: 'get',
    params: query
  })
}

//获取所有工单类型
export function workTypeAll(query) {
  return request({
    url: '/console/layout/workEntrust/getWorkTypeAll',
    method: 'get',
    params: query
  })
}
// 查询详细
export function findById(id) {
  return request({
    url: '/console/layout/workEntrust/' + id,
    method: 'get'
  })
}

// 修改
export function update(data) {
  return request({
    url: '/console/layout/workEntrust',
    method: 'put',
    data: data
  })
}

//新增
export function add(data) {
  return request({
    url: '/console/layout/workEntrust',
    method: 'post',
    data: data
  })
}


export function revoke(id) {
  return request({
    url: '/console/layout/workEntrust/revoke/' + id,
    method: 'post'
  })
}


export function remove(id) {
  return request({
    url: '/console/layout/workEntrust/' + id,
    method: 'delete'
  })
}

// 发送邮件
export function sendEmail (data) {
  return request({
    url: '/console/layout/workEntrust/sendEmail',
    method: 'post',
    data
  })
}
