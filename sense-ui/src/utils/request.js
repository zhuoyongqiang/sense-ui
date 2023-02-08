import axios from 'axios'
import {Notification, MessageBox, Message} from 'element-ui'
import {getToken} from '@/utils/auth'
import errorCode from '@/utils/errorCode'
import {reject} from "@/api/console/bpm/workflow";
let version = require('./../settings.js').version;
import store from './../store'
let ifShowMessage = true

axios.defaults.headers['Content-Type'] = 'application/json;charset=utf-8'
axios.defaults.withCredentials=true;
// 创建axios实例
const service = axios.create({
  // axios中请求配置有baseURL选项，表示请求URL公共部分
  baseURL: process.env.VUE_APP_BASE_API,
  // 超时
  timeout: 30000
})

let source = axios.CancelToken.source()

export const cancelHttp = () => {
  source.cancel('CANCEL')
  reset()
}

const reset = () => {
  source = axios.CancelToken.source()
}

// request拦截器
service.interceptors.request.use(config => {
  // 是否需要设置 token
  if(config.canCancel){
  config.cancelToken = source.token
  }
  const isToken = (config.headers || {}).isToken === false
  if (getToken() && !isToken) {
    config.headers['Authorization'] = 'Bearer ' + getToken() // 让每个请求携带自定义token 请根据实际情况自行修改
  }
  // get请求映射params参数
  if (config.method === 'get' && config.params) {
    let url = config.url + '?';
    for (const propName of Object.keys(config.params)) {
      const value = config.params[propName];
      var part = encodeURIComponent(propName) + "=";
      if (value !== null && typeof (value) !== "undefined") {
        if (typeof value === 'object') {
          for (const key of Object.keys(value)) {
            let params = propName + '[' + key + ']';
            var subPart = encodeURIComponent(params) + "=";
            url += subPart + encodeURIComponent(value[key]) + "&";
          }
        } else {
          url += part + encodeURIComponent(value) + "&";
        }
      }
    }
    url = url.slice(0, -1);
    config.params = {};
    config.url = url;
  }
  return config
}, error => {
  console.log(error)
  Promise.reject(error)
})

// 响应拦截器
service.interceptors.response.use(res => {
  // 拦截开始
  if (localStorage.getItem('ifversion') === '1') {
    if (res.headers.version && window.location.href.indexOf('mobile') === -1 && window.location.href.indexOf('index') !== -1) { // 只在首页进行版本拦截
      if (res.headers.version !== version) { // 版本号不对的情况
        if (ifShowMessage) {
          ifShowMessage = false
          MessageBox.alert('发现新版本，将进行重新加载', '提示', {
            confirmButtonText: '确定',
            callback: action => {
              ifShowMessage = true
              store.dispatch('LogOut').then(() => {
                localStorage.removeItem('userTime')
                // location.href = '/index';
                setTimeout(() =>{
                  location.reload()
                },100)
              })
            }
          });
        }
      }
    }
  }
    return res.data;
  },
  error => {
    console.log('err' + error)
    return Promise.reject(error)
  }
)

export default service
