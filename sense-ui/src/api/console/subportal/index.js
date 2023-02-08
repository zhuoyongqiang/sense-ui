import request from '@/utils/request'
import axios from 'axios'
import {getToken} from '@/utils/auth'

// 查询
export function list(query) {
  return request({
    url: '/console/subportal/list',
    method: 'get',
    params: query
  })
}


//查询公共快捷方式详细
export function get(id) {
  return request({
    url: '/console/subportal/' + id,
    method: 'get'
  })
}

// 新增公共快捷方式
export function add(data) {
  return axios.post(process.env.VUE_APP_BASE_API + '/console/subportal/add', data, {
    headers: {
      'Content-Type': 'multipart/form-data',
      Authorization: "Bearer " + getToken(),
    }
  })
}

// 修改公共快捷方式
export function update(data) {
  return axios.put(process.env.VUE_APP_BASE_API + '/console/subportal/edit', data, {
    headers: {
      'Content-Type': 'multipart/form-data',
      Authorization: "Bearer " + getToken(),
    }
  })
}

// 删除公共快捷方式
export function del(id) {
  return request({
    url: '/console/subportal/' + id,
    method: 'delete'
  })
}
