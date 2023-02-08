import request from '@/utils/request'

// 登录方法
export function login(username, password, code, uuid) {
  const data = {
    username,
    password,
    code,
    uuid
  }
  return request({
    url: '/login',
    method: 'post',
    data: data
  })
}



//获取访问的子门户标识
export function accessSubportal() {
  return request({
    url: '/access/subportal',
    method: 'get'
  })
}

// 企业微信登录方法
export function qywxlogin(code) {
  const data = {
    code
  }
  return request({
    url: '/qywxLogin',
    method: 'post',
    data: data
  })
}


// 企业微信登录方法
export function ssoTgc(tgc) {
  return request({
    url: '/ssoTgc?tgc='+tgc,
    method: 'post'
  })
}

// 获取用户详细信息
export function getInfo() {
  return request({
    url: '/getInfo',
    method: 'get'
  })
}

// 退出方法
export function logout() {
  return request({
    url: '/logout',
    method: 'post'
  })
}

// 获取验证码
export function getCodeImg() {
  return request({
    url: '/captchaImage',
    method: 'get'
  })
}


// 获取验证码
export function generateToken(params) {
  return request({
    url: '/generateToken',
    method: 'post',
    params:params
  })
}

// 切换用户
export function userSwitching(params) {
  return request({
    url: '/userSwitching',
    method: 'post',
    params:params
  })
}





