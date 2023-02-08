import request from '@/utils/request'
import {praseStrEmpty} from "@/utils/sense";

// 查询我的设置对象
export function my() {
  return request({
    url: '/console/system/autoRelpy/my',
    method: 'get'
  })
}


// 新增
export function add(data) {
  return request({
    url: '/console/system/autoRelpy',
    method: 'post',
    data: data
  })
}

// 修改
export function update(data) {
  return request({
    url: '/console/system/autoRelpy',
    method: 'put',
    data: data
  })
}
