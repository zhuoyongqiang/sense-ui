import request from '@/utils/request'


// 删除广告
export function removeFile(params) {
  return request({
    url: '/common/file/remove',
    method: 'post',
    params
    
  })
}

