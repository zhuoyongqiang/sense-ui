import request from '@/utils/request'


//保存配置
export function save(data) {
  return request({
    url: '/console/subportal/layout/save',
    method: 'post',
    data: data
  })
}


//获取配置
export function get(templateId) {
  return request({
    url: '/console/subportal/layout/'+templateId,
    method: 'get',
  })
}
