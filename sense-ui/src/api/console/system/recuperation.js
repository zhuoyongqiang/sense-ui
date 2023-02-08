import request from '@/utils/request'

// 查询sense列表
export function listRecuperation(query) {
  return request({
    url: '/im/recuperation/list',
    method: 'get',
    params: query
  })
}

// 查询sense详细
export function getRecuperation(id) {
  return request({
    url: '/im/recuperation/' + id,
    method: 'get'
  })
}

// 查询详情
export function accountList(id) {
  return request({
    url: '/im/recuperation/list/accountList/' + id,
    method: 'get'
  })
}