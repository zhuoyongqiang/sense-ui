import router from './router'
import store from './store'
import {Message} from 'element-ui'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import {getToken,setToken,removeToken,getCode,setCode,getTGC} from '@/utils/auth'
import axios from 'axios'
NProgress.configure({showSpinner: false})

// const whiteList = ['/login','/oauth', '/qrLogin', '/home/detail', '/home/window', '/home/reset', '/console/login', '/extends/oa', '/extends/more']
const whiteList = ['/oauth','/oautherror']
axios.defaults.withCredentials = true;
router.beforeEach((to, from, next) => {
    //PC拦截器
    NProgress.start()
    // //获取tgc票据
    // let tgc = getTGC();
    // //获取tgc为空和token不等于空，则进行注销操作
    // if(tgc === undefined && getToken() != undefined){removeToken()}
    // //tgc不能与空和token等于空，则进行认证操作
    // if( tgc && getToken() === undefined) {
    //   store.dispatch("ssoTgc", tgc).then(res => {
    //    location.reload();
    //   }).catch(() => {});
    // }
    if (getToken()) {
      if (to.path === '/index') {
        next({ path: '/home/index' })
        NProgress.done()
      } else if (store.getters.roles.length === 0) {
        // 判断当前用户是否已拉取完user_info信息
        store.dispatch('GetInfo').then(res => {
          // 拉取user_info
          const roles = res.roles
          store.dispatch('GenerateRoutes', {roles}).then(accessRoutes => {
            // 根据roles权限生成可访问的路由表
            router.addRoutes(accessRoutes)
            next({...to, replace: true}) // hack方法 确保addRoutes已完成
          })
        }).catch(err => {
          //如果获取用户信息获取，则进行退出判断处理，并跳转到首页
          //如果是白名单内的地址，则进行放行，其他地址进行拦截到首页
          if (to.path === '/index' || whiteList.some(v => (to.path).startsWith(v))) {
            removeToken()
            next()
          }else {
            store.dispatch('LogOut').then(() => {
              // Message.error(err)
              next({path: '/home/index'})
            })
          }
        })
      } else {
        next()
      }
    } else {
      //测试服
      if (to.path === '/index' || whiteList.some(v => (to.path).startsWith(v))) {
        next()
      } else  {
        next('/index')
      }
      //正式服
    //   if (to.path === '/oauth' || whiteList.some(v => (to.path).startsWith(v))) {
    //     next()
    //   } else {
    //     //CIAM测试服
    //     //window.location.href="https://stage.identity.bosch.com.cn/ids/connect/authorize?response_type=code&scope=openid%20email%20profile%20phone%20offline_access&client_id=ciamids_1A28E6CC-B6EB-435B-9D3B-A214410A765A&redirect_uri=https://sso.rbtssws.com.cn/oauth&nonce=0815";
    //     //CIAM正式服
    //     window.location.href="https://identity.bosch.com.cn/ids/connect/authorize?response_type=code&scope=openid%20email%20profile%20phone%20offline_access&client_id=ciamids_8F62EF2E-4C24-4684-B9E4-F045C4823BD6&redirect_uri=https://sso.rbtssws.com.cn/oauth&nonce=0815";
    //   }
    //   NProgress.done()
  
    }
})

router.afterEach(() => {
  NProgress.done()
})
