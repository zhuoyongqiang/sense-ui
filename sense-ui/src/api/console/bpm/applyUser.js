import request from '@/utils/request'


/**
 * 发起流程
 * @param {参数} params 
 * @returns 
 */
 export const create = (params,data) => {
  return request({
    url: '/bpm/userApply/create',
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
 export const applyUserAgree = (data) => {
  return request({
    url: '/bpm/userApply/agree',
    method: 'post',
    data
  })
}


/**
 * 驳回
 * @param {参数} data 
 * @returns 
 */
 export const applyReject = (data) => {
  return request({
    url: '/bpm/userApply/reject',
    method: 'post',
    data
  })
}
