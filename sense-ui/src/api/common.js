import request from "@/utils/request";

export function uploadFile(data) {
  return request({
    url: '/common/upload',
    method: 'post',
    data: data
  })
}


export function getFilePath(query) {
  return request({
    url: '/common/getFilePath/',
    method: 'get',
    params: query,
    responseType:'blob'
  })
}
