<template>
  <div id="app" @mousemove="moveStatus">
    <keep-alive :include="cachedViews">
      <router-view v-if="$route.fullPath.includes('/mobile/')" :key="$route.fullPath"/>
      <router-view v-else/>
    </keep-alive>
  </div>
</template>

<script>
import Cookies from "js-cookie";
import { getConfigKey } from "./api/home/config";
export default  {
  name:  'App',
  data() {
    return {
      token: '',
      cachedViews: window.keepAliveViews
    }
  },
  // computed: {
  //   cachedViews() {
  //     console.log('==================window.keepAliveViews', window.keepAliveViews)
  //     return window.keepAliveViews
  //   }
  // },
  created() {
    this.getVersion()
  },
  watch:{
    $route(to,from){
      console.log(to.path);
    },
    token (newVal, oldVal) {
      if (!newVal && oldVal) {
        console.log('登出')
        this.$store.dispatch('LogOut').then(() => {
          localStorage.removeItem('userTime')
          location.href = '/index';
        })
      }
    }
  },
  mounted () {
    if(document.getElementById('loader-wrapper')) {
      const timer = setTimeout(() => {
        clearTimeout(timer)
        const child = document.getElementById('loader-wrapper');
        child.parentNode.removeChild(child)
        // document.getElementById('loader-wrapper').remove()
      }, 500)
    };
    // if (localStorage.getItem('data-theme')) {
    //   window.document.documentElement.setAttribute( "data-theme", localStorage.getItem('data-theme'));
    // }
  },
  methods: {
    moveStatus() {
      // this.token = Cookies.get('Admin-Token')
      if (!Cookies.get('Admin-Token') || Cookies.get('Admin-Token') === undefined) {
        if (localStorage.getItem('userTime')) {
          localStorage.removeItem('userTime')
        }
      }
      const whiteList = ['/login', '/index', '/home/reset', '/extends/oa', '/extends/more']
      if (window.location.href.indexOf('mobile') === -1 && !whiteList.some(v => (location.pathname).startsWith(v))) { // 不是手机端并且不是白名单
        this.computeStatus()
      }
    },
    computeStatus () {
      this.token = Cookies.get('Admin-Token')
      if (Cookies.get('Admin-Token')) {
        if (localStorage.getItem('userTime')) {
          if (Date.parse(new Date()) - Number(localStorage.getItem('userTime')) > 600000*6*4) { // 如果4个小时不动 就退出
            this.$alert('由于您长时间未操作，将重新登陆', '提示', {
              confirmButtonText: '确定',
              callback: action => {
                this.$store.dispatch('LogOut').then(() => {
                  localStorage.removeItem('userTime')
                  location.href = '/index';
                })
              }
            });
          } else {
            if (Date.parse(new Date()) - Number(localStorage.getItem('userTime')) > 3000) {
              localStorage.setItem('userTime',JSON.stringify(Date.parse(new Date())))
            }
          }
        }else {
          localStorage.setItem('userTime',JSON.stringify(Date.parse(new Date())))
        }
      } else {
        if (localStorage.getItem('userTime')) {
          localStorage.removeItem('userTime')
        }
      }
    },
    getVersion() {
      getConfigKey('version_controller').then(res => {
        localStorage.setItem('ifversion', res.msg)
      })
    }
  }
}
</script>

<style lang="scss">
  .el-scrollbar {
    .el-scrollbar__bar {
      opacity: 1 !important;
    }
  }
  .el-loading-mask{
    z-index: 1999;
  }
  // @import "@/assets/styles/theme/_handle.scss";
  //   * {
  //     @include settheme('settheme');
  //   }
</style>
