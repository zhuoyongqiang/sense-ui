import request from '@/utils/request'

/**
 * 获取用户信息
 * @param {参数} params 
 * @returns 
 */
export const getUserByUserName = (params) => {
  return request({
    url: '/console/system/user/getByUserName',
    method: 'get',
    params
  })
}


/**
 * 获取当前用户的未开通应用
 * @param {参数} params 
 * @returns 
 */
 export const getNotOpenApp = (params) => {
  return request({
    url: '/bpm/appAccount/getNotOpenApp',
    method: 'get',
    params
  })
}

/**
 * 发起流程
 * @param {参数} params 
 * @returns 
 */
 export const create = (params,data) => {
  return request({
    url: '/bpm/appAccount/create',
    method: 'post',
    params,
    data
  })
}

/**
 * 同意
 * @param {参数} data 
 * @returns 
 */
 export const globalAgree = (data) => {
  return request({
    url: '/bpm/appAccount/agree',
    method: 'post',
    data
  })
}

