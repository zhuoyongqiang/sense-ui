import request from "@/utils/request";

// 检查域账户名
export function checkStaffAccount(staffAccount) {
	const data = {
    staffAccount
  }
  return request({
    url: '/home/resetPwd/checkStaffAccount',
    method: 'post',
    params: data
	})
}

// 检查密保答案
export function checkPwdSet(data) {
  return request({
    url: '/home/resetPwd/checkPwdSet',
    method: 'post',
    data: data
	})
}

// 获取图片验证码
export function getVerifiCode(data) {
  return request({
    url: '/home/resetPwd/getVerifiCode',
    method: 'post',
    data: data
	})
}

// 验证图片验证码
export function verifiCode(data) {
  return request({
    url: '/home/resetPwd/checkImageCode',
    method: 'post',
    data: data
	})
}

// 发送短信验证码
export function sendCode(data) {
  return request({
    url: '/home/resetPwd/sendCode',
    method: 'post',
    data: data
	})
}

// 验证短信验证码
export function checkSmsCode(data) {
  return request({
    url: '/home/resetPwd/checkSmsCode',
    method: 'post',
    data: data
	})
}

// 发送邮件
export function sendEmail(data) {
  return request({
    url: '/home/resetPwd/sendEmail',
    method: 'post',
    data: data
	})
}

// 检查邮件
export function checkEmailUrl(data) {
  return request({
    url: '/home/resetPwd/checkEmailUrl',
    method: 'post',
    data: data
	})
}

// 修改密码
export function setPwd(data) {
  return request({
    url: '/home/resetPwd/setpwd',
    method: 'post',
    data: data
	})
}

// 查询所有密保问题
export function queryAllSp() {
  return request({
    url: '/home/resetPwd/queryAllSp',
    method: 'post'
	})
}

// 查询当前用户的密码问题及答案
export function queryUserSpSet() {
  return request({
    url: '/home/resetPwd/queryUserSpSet',
    method: 'post'
	})
}

// 保存用户的密保
export function updateUserSpSet(data) {
  return request({
    url: '/home/resetPwd/updateUserSpSet',
		method: 'post',
		data: data
	})
}
