import request from "@/utils/request";

// 查询内容列表
export function listNews(query, canCancel) {
  return request({
    url: '/home/news/list',
    method: 'get',
    params: query,
    canCancel
  })
}

// 设置新闻已读未读状态
export function read (query) {
  return request({
    url: `/home/news/read/${query}`,
    method: 'post'
  })
}

// 热门列表
export function listHot(query) {
  return request({
    url: '/home/news/hot',
    method: 'get',
    params: query
  })
}

// 推荐列表
export function listRecommend(query) {
  return request({
    url: '/home/news/recommend',
    method: 'get',
    params: query
  })
}

// 查询内容详细
export function getNews(id) {
  return request({
    url: '/home/news/' + id,
    method: 'get'
  })
}

//初始化OA新闻
export function listOA(query) {
  return request({
    url: '/home/news/oa',
    method: 'get',
    params: query
  })
}

//获取上一篇和下一篇的ID
export function getPrefixAndSuffixNewsId(infoNewsId, newsTypeId) {
  return request({
    url: '/home/news/getPrefixAndSuffixNewsId/' + infoNewsId + '/' + newsTypeId,
    method: 'get'
  })
}
