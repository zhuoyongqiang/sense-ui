import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

/* Layout */
import Layout from '@/layout'

/**
 * Note: 路由配置项
 *
 * hidden: true                   // 当设置 true 的时候该路由不会再侧边栏出现 如401，login等页面，或者如一些编辑页面/edit/1
 * alwaysShow: true               // 当你一个路由下面的 children 声明的路由大于1个时，自动会变成嵌套的模式--如组件页面
 *                                // 只有一个时，会将那个子路由当做根路由显示在侧边栏--如引导页面
 *                                // 若你想不管路由下面的 children 声明的个数都显示你的根路由
 *                                // 你可以设置 alwaysShow: true，这样它就会忽略之前定义的规则，一直显示根路由
 * redirect: noRedirect           // 当设置 noRedirect 的时候该路由在面包屑导航中不可被点击
 * name:'router-name'             // 设定路由的名字，一定要填写不然使用<keep-alive>时会出现各种问题
 * meta : {
    noCache: true                // 如果设置为true，则不会被 <keep-alive> 缓存(默认 false)
    title: 'title'               // 设置该路由在侧边栏和面包屑中展示的名字
    icon: 'svg-name'             // 设置该路由的图标，对应路径src/assets/icons/svg
    breadcrumb: false            // 如果设置为false，则不会在breadcrumb面包屑中显示
  }
 */

// 公共路由
export const constantRoutes = [
  {
    path: '/redirect',
    component: Layout,
    hidden: true,
    children: [
      {
        path: '/redirect/:path(.*)',
        component: (resolve) => require(['@/views/redirect'], resolve)
      }
    ]
	},
	// {
  //   path: '/login',
  //   component: (resolve) => require(['@/views/login'], resolve),
  //   hidden: true
  // },
  
  {
    path: '/qrLogin',
    component: (resolve) => require(['@/views/qrLogin'], resolve),
    hidden: true
  },
  // {
  //   path: '/console/login',
  //   component: (resolve) => require(['@/views/console/login'], resolve),
  //   hidden: true
  // },
  {
    path: '/console',
    component: Layout,
    redirect: 'welcome'
  },
  {
    path: '/404',
    component: (resolve) => require(['@/views/error/404'], resolve),
    hidden: true
  },
  {
    path: '/oautherror',
    component: (resolve) => require(['@/views/error/oautherror'], resolve),
    hidden: true
  },
  {
    path: '/401',
    component: (resolve) => require(['@/views/error/401'], resolve),
    hidden: true
  },
  {
    path: '/user',
    component: Layout,
    hidden: true,
    redirect: 'noredirect',
    children: [
      {
        path: 'userDetails',
        component: (resolve) => require(['@/views/console/system/user/profile/index'], resolve),
        name: 'userDetails',
        meta: {title: '个人中心', icon: 'user'}
      }
    ]
  },
  {
    path: '/dict',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'type/data/:dictId(.+)',
        component: (resolve) => require(['@/views/console/system/dict/data'], resolve),
        name: 'Data',
        meta: {title: '字典数据', icon: ''}
      }
    ]
  },
  {
    path: '/job',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'log',
        component: (resolve) => require(['@/views/console/monitor/job/log'], resolve),
        name: 'JobLog',
        meta: {title: '调度日志'}
      }
    ]
  },
  {
    path: '/console/gen',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'edit/:tableId(.+)',
        component: (resolve) => require(['@/views/console/tool/gen/editTable'], resolve),
        name: 'GenEdit',
        meta: {title: '修改生成配置'}
      }
    ]
  },
  {
    path: '/console/bpm',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'model/:defineId(.+)',
        component: (resolve) => require(['@/views/console/bpm/model/index'], resolve),
        name: 'BpmModel',
        meta: {title: '定义模型'}
      }
    ]
  },
  {
    path: '',
    component: () => import('@/views/home/main.vue'),
    hidden: true,
    redirect: 'home/index',
    children: [
      {
        path: 'index',
        component: (resolve) => require(['@/views/home/index'], resolve),
        name: 'homeDefaultIndex'
      }
    ]
  },
  {
    path: '/home', //首页
    name: 'home',
    hidden: true,
    redirect: 'home/index',
    component: (resolve) => require(['@/views/home/main.vue'], resolve),
    children: [
      {
        path: '/advertisement',
        component: (resolve) => require(['@/views/components/subportal/InfoAdvertisement'], resolve),
        hidden: true
      },
      {
        path: '/oauth',
        component: (resolve) => require(['@/views/oauth'], resolve),
        hidden: true
      },
      {
        path: '/logout',
        component: (resolve) => require(['@/views/logout'], resolve),
        hidden: true
      },
      {
        path: '/openAppAccount',
        component: (resolve) => require(['@/views/extends/openAppAccount'], resolve),
        hidden: true
      },
      {
        path: '/bpmApplyUser',
        component: (resolve) => require(['@/views/extends/bpmApplyUser'], resolve),
        hidden: true
      },
      {
        path: 'index',
        name: 'homeIndex',
        component: (resolve) => require(['@/views/home/index.vue'], resolve)
      },
      {
        path: 'updatePwd',
        name: 'updatePwd',
        component: (resolve) => require(['@/views/home/updatePwd.vue'], resolve)
			},
			{
        path: 'setSp',
        name: 'setSp',
        component: (resolve) => require(['@/views/home/setSp.vue'], resolve)
      },
      {
        path: 'window/:newsTypeId(.+)',
        name: 'window',
        component: (resolve) => require(['@/views/home/window.vue'], resolve)
      },
      {
        path: 'download/:type(.+)',
        name: 'download',
        component: (resolve) => require(['@/views/home/download/index.vue'], resolve)
      },
      {
        path: 'moreTodo',
        name: 'moreTodo',
        component: (resolve) => require(['@/views/home/moreTodo.vue'], resolve)
      },
      {
        path: 'commonLink',
        name: 'commonLink',
        component: (resolve) => require(['@/views/home/commomLink.vue'], resolve)
      },
      {
        path: 'reset',
        name: 'reset',
        component: (resolve) => require(['@/views/home/reset.vue'], resolve)
      },
      {
        path: 'todoEntrust',
        name: 'todoEntrust',
        component: (resolve) => require(['@/views/home/todoEntrust.vue'], resolve)
      },
      {
        path: 'detail/:newsId(.+)',
        name: 'detail',
        component: (resolve) => require(['@/views/home/detail.vue'], resolve)
      },
      {
        path: 'meterialDetail/:meterialId(.+)',
        name: 'meterialDetail',
        component: (resolve) => require(['@/views/home/download/detail.vue'], resolve)
      },
      {
        path: 'bpm/task/:taskId(.+)',
        name: 'approval',
        component: (resolve) => require(['@/views/console/platform/page/toDo.vue'], resolve)
      },
      {
        path: 'bpm/process/:instanceId(.+)',
        name: 'process',
        component: (resolve) => require(['@/views/console/platform/page/toDetail.vue'], resolve)
      },
      {
        path: 'moreApp',
        name: 'moreApp',
        component: (resolve) => require(['@/views/home/moreApp.vue'], resolve)
      },
      {
        path: 'developManual',
        name: 'developManual',
        component: (resolve) => require(['@/views/home/developManual/index.vue'], resolve)
      }
    ]
  },
  {
    path: '/mobile/home/window/:newsTypeId(.+)',
    name: 'mobileWindow',
    meta: {
      keepAlive: true
    },
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/window.vue'], resolve)
  },
  {
    path: '/mobile/home/workflow',
    name: 'mobileworkflow',
    meta: {
      keepAlive: true
    },
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/workflow.vue'], resolve)
  },
  {
    path: '/mobile/home/notice',
    name: 'mobileNotice',
    meta: {
      keepAlive: true
    },
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/notice.vue'], resolve)
  },
  {
    path: '/mobile/home/todo',
    name: 'mobileTodo',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/todo.vue'], resolve)
  },
  {
    path: '/mobile/home/approve/:taskId(.+)',
    name: 'mobileapprove',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/approve.vue'], resolve)
  },
  {
    path: '/mobile/home/redirect/approve/:taskId(.+)',
    name: 'mobileapproveredirect',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/redirect/approve.vue'], resolve)
  },
  {
    path: '/mobile/home/detail/:newsId(.+)',
    name: 'mobileDetail',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/mobileNews.vue'], resolve)
  },
  {
    path: '/mobile/home/attachmentPreview',
    name: 'attachmentPreview',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/attachmentPreview.vue'], resolve)
  },
  {
    // 工作事项
    path: '/mobile/home/workItem',
    name: 'mobileWorkItem',
    hidden: true,
    meta: {
      title: '统一待办'
    },
    component: (resolve) => require(['@/views/mobile/home/workItem.vue'], resolve)
  },
  {
    // 待办委托
    path: '/mobile/home/profile',
    name: 'mobileProfile',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/profile.vue'], resolve)
  },
  {
    // 待办委托 - 详情
    path: '/mobile/home/profile/detail/:profileId?',
    name: 'mobileProfileDetail',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/profileDetail.vue'], resolve)
  },
  {
    // 缺省页
    path: '/mobile/home/errPage',
    name: 'mobileerrPage',
    hidden: true,
    component: (resolve) => require(['@/views/mobile/home/errPage.vue'], resolve)
  },
  {
    path: '/extends/oa', //首页
    name: 'extendsOA',
    hidden: true,
    component: (resolve) => require(['@/views/extends/oa.vue'], resolve),
  },
  {
    path: '/extends/more', //首页
    name: 'extendsMore',
    hidden: true,
    component: (resolve) => require(['@/views/extends/more.vue'], resolve),
  }

]

const keepAliveViews = []
const keepAliveroutes = constantRoutes.filter(v => v.name && v.meta && v.meta.keepAlive)
keepAliveroutes.map(v => {
  keepAliveViews.push(v.name)
})

window.keepAliveViews = keepAliveViews
export default new Router({
  mode: 'history', // 去掉url中的#
  scrollBehavior: (to, from, savedPosition) => function () {
    if (savedPosition) {
      return savedPosition
    } else {
      return {x: 0, y: 0}
    }
  },
  routes: constantRoutes
})
