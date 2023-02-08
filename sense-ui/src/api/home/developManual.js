import request from '@/utils/request'

// 查询文档目录列表
export function listCatalog(query) {
  return request({
    url: '/doc/catalog/list',
    method: 'get',
    params: query
  })
}

// 查询文档目录详细
export function getCatalog(id) {
  return request({
    url: '/doc/catalog/' + id,
    method: 'get'
  })
}

// 新增文档目录
export function addCatalog(data) {
  return request({
    url: '/doc/catalog',
    method: 'post',
    data: data
  })
}

// 修改文档目录
export function updateCatalog(data) {
  return request({
    url: '/doc/catalog',
    method: 'put',
    data: data
  })
}

// 删除文档目录
export function delCatalog(id) {
  return request({
    url: '/doc/catalog/' + id,
    method: 'delete'
  })
}

// 导出文档目录
export function exportCatalog(query) {
  return request({
    url: '/doc/catalog/export',
    method: 'get',
    params: query
  })
}

// 查询文档内容列表
export function listContent(query) {
  return request({
    url: '/doc/content/list',
    method: 'get',
    params: query
  })
}

// 查询文档内容详细
export function getContent(id) {
  return request({
    url: '/doc/content/' + id,
    method: 'get'
  })
}

// 新增文档内容
export function addContent(data) {
  return request({
    url: '/doc/content',
    method: 'post',
    data: data
  })
}

// 修改文档内容
export function updateContent(data) {
  return request({
    url: '/doc/content',
    method: 'put',
    data: data
  })
}

// 删除文档内容
export function delContent(id) {
  return request({
    url: '/doc/content/' + id,
    method: 'delete'
  })
}

// 导出文档内容
export function exportContent(query) {
  return request({
    url: '/doc/content/export',
    method: 'get',
    params: query
  })
}

// 根据目录ID查询内容
export function getContentByCatalog(id){
  return request({
    url: '/doc/content/byCatalogId/' + id,
    method: 'get'
  })
}
