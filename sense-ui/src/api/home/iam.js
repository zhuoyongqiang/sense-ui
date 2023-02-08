import request from "@/utils/request";

//获取应用类别
export function appType() {
  return request({
    url: '/iam/api/find/appType',
    method: 'post'
  })
}

//获取应用列表
export function findApp(data) {
  return request({
    url: '/iam/api/find/app',
    method: 'post',
    data: data
  })
}

//更新用户个性化排序
export function updateUserApp(data) {
  return request({
    url: '/iam/api/updateUserApp',
    method: 'put',
    data: data
  })
}

// 获取设置密码的黑名单
export function findBlack() {
  return request({
    url: '/iam/api/find/black',
    method: 'post'
  })
}

// 获取设置密码的白名单
export function userWhite() {
  return request({
    url: '/iam/api/find/userWhite',
    method: 'post'
  })
}

// 根据用户名获取所属应用
export function findAppByUserName(params) {
  return request({
    url: '/iam/api/find/appByUserName',
    method: 'get',
    params:params
  })
}
