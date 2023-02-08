import { constantRoutes } from '@/router'
import { getRouters } from '@/api/menu'
import Layout from '@/layout/index'
import home from '@/views/home/main'
import ParentView from '@/components/ParentView';

const permission = {
  state: {
    routes: [],
    addRoutes: [],
    sidebarRouters: []
  },
  mutations: {
    SET_ROUTES: (state, routes) => {
      state.addRoutes = routes
      state.routes = constantRoutes.concat(routes)
    },
    SET_SIDEBAR_ROUTERS: (state, routers) => {
      state.sidebarRouters = constantRoutes.concat(routers)
    },
  },
  actions: {
    // 生成路由
    GenerateRoutes({ commit }) {
      return new Promise(resolve => {
        // 向后端请求路由数据
        getRouters().then(res => {
          if(res.data.length === 0){
            const sidebarRoutes = [];
            const rewriteRoutes =  [];
            rewriteRoutes.push({ path: '*', redirect: '/404', hidden: true })
            commit('SET_ROUTES', rewriteRoutes)
            commit('SET_SIDEBAR_ROUTERS', sidebarRoutes)
            resolve(rewriteRoutes)
            return;
          }

          const sdata = JSON.parse(JSON.stringify(res.data))
          let rdata = JSON.parse(JSON.stringify(res.data))
          let handleRoutes = sdata.filter(v => v.meta.title === '门户前端')
          rdata.push({
            alwaysShow: true,
            path: '/home', //首页
            name: 'main',
            hidden: true,
            redirect: 'home/index',
            children: [],
            component: 'home',
          })
          rdata.forEach(v => {
            if (v.meta && v.meta.title === '门户前端') {
              v.children = v.children.reduce((res, cur) => {
                if (!cur.path.startsWith('/home') && !cur.path.startsWith('home')) {
                  return res.concat(cur)
                } else {
                  return res
                }
              }, [])
            }
          })
          let outRouters = handleRoutes[0].children.reduce((result, current) => {
            if (!current.path.startsWith('/console') && !current.path.startsWith('console')) {
                // rdata.find(v => v.path === '/home').children.push({...current})
                rdata.find(v => v.path === '/home').children.push({...current, nav: true})
              return result
            } else {
              return result
            }
          }, [])
          // console.warn('outRouters', outRouters)
          const sidebarRoutes = filterAsyncRouter(sdata)
          const rewriteRoutes = filterAsyncRouter(rdata, true)
          rewriteRoutes.push({ path: '*', redirect: '/404', hidden: true })
          commit('SET_ROUTES', rewriteRoutes)
          commit('SET_SIDEBAR_ROUTERS', sidebarRoutes)
          resolve(rewriteRoutes)
        })
      })
    }
  }
}

// 遍历后台传来的路由字符串，转换为组件对象
function filterAsyncRouter(asyncRouterMap, isRewrite = false) {
  return asyncRouterMap.filter(route => {
    if (isRewrite && route.children) {
      route.children = filterChildren(route.children)
    }
    if (route.component) {
      // Layout ParentView 组件特殊处理
      if (route.component === 'Layout') {
        route.component = Layout
      } else if (route.component === 'ParentView') {
        route.component = ParentView
      } else if (route.component === 'home'){
        route.component = home
      }else {
        route.component = loadView(route.component)
      }
    }
    if (route.children != null && route.children && route.children.length) {
      route.children = filterAsyncRouter(route.children, route, isRewrite)
    }
    return true
  })
}

function filterChildren(childrenMap) {
  var children = []
  childrenMap.forEach((el, index) => {
    if (el.children && el.children.length) {
      if (el.component === 'ParentView') {
        el.children.forEach(c => {
          c.path = el.path + '/' + c.path
          if (c.children && c.children.length) {
            children = children.concat(filterChildren(c.children, c))
            return
          }
          children.push(c)
        })
        return
      }
    }
    children = children.concat(el)
  })
  return children
}

export const loadView = (view) => { // 路由懒加载
  return (resolve) => require([`@/views/${view}`], resolve)
}

export default permission
