import request from '@/utils/request'


//批量处理
export function batchAction(data) {
  return request({
    url: '/console/bpm/news/batchAction',
    method: 'post',
    data: data
  })
}
//申请列表
export function listApply(query, canCancel) {
  return request({
    url: '/console/bpm/news/listApply',
    method: 'get',
    params: query,
    canCancel
  })
}

//待办列表
export function listTodo(query, canCancel) {
  return request({
    url: '/console/bpm/news/listTodo',
    method: 'get',
    params: query,
    canCancel
  })
}

//已办列表
export function listFinish(query, canCancel) {
  return request({
    url: '/console/bpm/news/listFinish',
    method: 'get',
    params: query,
    canCancel
  })
}

//发起
export function create(newsId) {
  return request({
    url: '/console/bpm/news/create/' + newsId,
    method: 'post'
  })
}

//转载
export function transport(newsId) {
  return request({
    url: '/console/bpm/news/transport/' + newsId,
    method: 'post'
  })
}

//同意
export function agree(data) {
  return request({
    url: '/console/bpm/news/agree',
    method: 'post',
    data: data
  })
}

//驳回
export function reject(data) {
  return request({
    url: '/console/bpm/news/reject',
    method: 'post',
    data: data
  })
}

//发布
export function publish(data) {
  return request({
    url: '/console/bpm/news/publish',
    method: 'post',
    data: data
  })
}

// 获取任务详情
export function getTaskInfo(taskId) {
  return request({
    url: '/console/bpm/news/getTaskInfo/' + taskId,
    method: 'get'
  })
}

//获取流程详情
export function getProcessInfo(instanceId) {
  return request({
    url: '/console/bpm/news/getProcessInfo/' + instanceId,
    method: 'get'
  })
}

//根据实例ID获取任务
export function getTaskListByInstanceId(instanceId) {
  return request({
    url: '/console/bpm/news/getTaskListByInstanceId/' + instanceId,
    method: 'get'
  })
}

//获取最新的新闻流程实例
export function getLatestNewsInstance(newsId) {
  return request({
    url: '/console/bpm/news/getLatestNewsInstance/' + newsId,
    method: 'get'
  })
}


export function getBuildssolink(type,id) {
  return request({
    url: '/console/layout/workOrderMonitor/buildssolink/' + type+'/'+id,
    method: 'get'
  })
}
export function getMobileBuildssolink(type,id) {
  return request({
    url: '/console/layout/workOrderMonitor/mobile/buildssolink/' + type+'/'+id,
    method: 'get'
  })
}

