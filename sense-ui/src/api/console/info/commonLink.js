import request from '@/utils/request'
import axios from 'axios'
import {getToken} from '@/utils/auth'

// 查询公共快捷方式列表
export function listCommonLink(query) {
  return request({
    url: '/console/info/commonLink/list',
    method: 'get',
    params: query
  })
}


// 查询公共快捷方式详细
export function getCommonLink(id) {
  return request({
    url: '/console/info/commonLink/' + id,
    method: 'get'
  })
}

// 新增公共快捷方式
export function addCommonLink(data) {
  return axios.post(process.env.VUE_APP_BASE_API + '/console/info/commonLink/add', data, {
    headers: {
      'Content-Type': 'multipart/form-data',
      Authorization: "Bearer " + getToken(),
    }
  })
}

// 修改公共快捷方式
export function updateCommonLink(data) {
  return axios.post(process.env.VUE_APP_BASE_API + '/console/info/commonLink/edit', data, {
    headers: {
      'Content-Type': 'multipart/form-data',
      Authorization: "Bearer " + getToken(),
    }
  })
}

// 删除公共快捷方式
export function delCommonLink(id) {
  return request({
    url: '/console/info/commonLink/' + id,
    method: 'delete'
  })
}

// 导出公共快捷方式
export function exportCommonLink(query) {
  return request({
    url: '/console/info/commonLink/export',
    method: 'get',
    params: query
  })
}
