import request from '@/utils/request'
import {praseStrEmpty} from "@/utils/sense";

// 查询组列表
export function getGroup(query) {
  return request({
    url: '/console/system/group/list',
    method: 'get',
    params: query
  })
}
