import {getConfigKey} from "@/api/home/config"

function getwxConfig () {
  // return Promise.all([getConfigKey('qywx_url'), getConfigKey('qywx_corpid'), getConfigKey('qywx_AgentId')])
  return Promise.all([getConfigKey('qywx_url'), getConfigKey('qywx_corpid')])
}

function wxRedirect () {
  // 目前该方法只适用于统一待办页面即页面链接没有携带问号参数的页面，有缺陷
  // H5微信重定向须从当前链接获取到初始微信授权时目标页面的原始地址，目的是为了剔除微信授权重定向后给页面链接拼接的参数
  return getwxConfig().then(resp => {
    const qywxUrl = resp[0].msg
    const qywxAppId = resp[1].msg
    // const qywxAgentId = resp[0].msg
    // const redirec_uri = 'https%3a%2f%2fxib03.test.xib.com.cn%3a8501%2fmobile%2fhome%2fworkItem'
    const originURL = document.location.origin + location.pathname // 去除链接上参数
    console.log(originURL)
    const redirec_uri = encodeURIComponent(originURL)
    // https://open.weixin.qq.com/connect/oauth2/authorize?appid=ww8848971b33e26852&redirect_uri=https%3a%2f%2fnewsapi.xib.com.cn%2fmobile%2fhome%2fworkItem&response_type=code&scope=snsapi_base#wechat_redirect
    // const redirecUrl = `https://xib02.test.xib.com.cn:8088/connect/oauth2/authorize?appid=${qywxAppId}&redirect_uri=${redirec_uri}&response_type=code&scope=snsapi_base&state=1#wechat_redirect`
    const redirecUrl = `https://open.weixin.qq.com/connect/oauth2/authorize?appid=${qywxAppId}&redirect_uri=${redirec_uri}&response_type=code&scope=snsapi_base&state=1#wechat_redirect`
    location.replace(redirecUrl)
    // window.open(redirecUrl)
    // location.replace("http://www.example.com");
  }).catch(err => {
    console.warn(err)
    throw new Error('toErrPage')
    // return 'toErrPage'
  })
}

export {wxRedirect}
