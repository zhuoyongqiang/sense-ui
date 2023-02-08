import request from "@/utils/request";

export function getConfigKey(configKey) {
  return request({
    url: '/home/config/configKey/' + configKey,
    method: 'get'
  })
}

// 请求登录前首页模板
export function loginPreTemplate() {
  return request({
    url: '/console/subportal/layout/loginPreTemplate',
    method: 'get'
  })
}

// 请求登录后首页模板
export function loginPostTemplate() {
  return request({
    url: '/console/subportal/layout/loginPostTemplate',
    method: 'get'
  })
}