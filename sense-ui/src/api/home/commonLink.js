import request from "@/utils/request";

export function listCommonLink(query) {
  return request({
    url: '/home/commonLink/list',
    method: 'get',
    params: query
  })
}

//获取当前用户的常用连接
export function selectByUserList() {
  return request({
    url: '/console/info/commonLink/selectByUserList',
    method: 'get'
  })
}


//添加和保存用户常用连接
export function saveByUser(data) {
  return request({
    url: '/console/info/commonLink/saveByUser',
    method: 'post',
    data: data
  })
}
//更新用户个性化排序
export function updateUserById(data) {
  return request({
    url: '/console/info/commonLink/updateUserById',
    method: 'put',
    data: data
  })
}


//移除用户常用连接
export function removeByUser(data) {
  return request({
    url: '/console/info/commonLink/removeByUser',
    method: 'delete',
    data: data
  })
}


