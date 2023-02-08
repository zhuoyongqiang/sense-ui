import request from '@/utils/request'

// 查询内容列表
export function allNewsType(query) {
  return request({
    url: '/home/newsType/all',
    method: 'get',
    params: query
  })
}
