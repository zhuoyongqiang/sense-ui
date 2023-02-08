import request from '@/utils/request'

// 新增内容
export function addImg(data) {
    return request({
      url: '/console/info/mediaImg',
      method: 'post',
      data: data
    })
  }

//查询内容
export function listImgs(query){
    return request({
      url: '/console/info/mediaImg/list',
      method: 'get',
      params: query
    })
}

//删除内容
export function delImg(id){
  return request({
    url: '/console/info/mediaImg/'+id,
    method: 'delete'
  })
}