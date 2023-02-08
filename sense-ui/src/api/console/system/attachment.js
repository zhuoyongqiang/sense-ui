import request from '@/utils/request'

// 查询内容附件列表
export function listAttachment(query) {
  return request({
    url: '/console/system/attachment/list',
    method: 'get',
    params: query
  })
}

// 查询内容附件详细
export function getAttachment(id) {
  return request({
    url: '/console/system/attachment/' + id,
    method: 'get'
  })
}

// 新增内容附件
export function addAttachment(data) {
  return request({
    url: '/console/system/attachment',
    method: 'post',
    data: data
  })
}

// 修改内容附件
export function updateAttachment(data) {
  return request({
    url: '/console/system/attachment',
    method: 'put',
    data: data
  })
}

// 删除内容附件
export function delAttachment(id) {
  return request({
    url: '/console/system/attachment' + id,
    method: 'delete'
  })
}

// 导出内容附件
export function exportAttachment(query) {
  return request({
    url: '/console/system/attachment/export',
    method: 'get',
    params: query
  })
}

