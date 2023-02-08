<template>
  <div class="wrapper">
    <div class="hedaer-wrapper" v-if="!hideMenu">
      <div class="logo-panel">
        <img class="main-logo" src="@/assets/images/img_log.png" @click="handleLogoClick"/>
        <!-- <div class="main-title" :style="{'opacity': logoTitle ? 1 : 0}">{{logoTitle || '办公门户'}}</div> -->
      </div>
      <div class="nav-panel" v-show="isUserLogin">
        <div class="nav-item" @click="navClick(item, index)" v-for="(item, index) in dynicRoutes" :key="item.path">
          <span class="item" :class="{'active': navActive === index}">{{item.meta && item.meta.title}}</span>
        </div>
      </div>
       <div class="download-shop" ref="downloadPanel" @click="handleCollection">
        <img v-if="isShop=='0'" src="../../assets/icons/no_collection.png" style="vertical-align: middle;" />
        <span v-if="isShop=='0'"  style="vertical-align: middle;" > 设为主账号：</span>
        <img v-if="isShop=='1'" src="../../assets/icons/collection.png" style="vertical-align: middle;" />
        <span v-if="isShop=='1'" style="vertical-align: middle;" > 当前账号:</span>
      </div>
      <div class="download-panel" ref="downloadPanel">
        <img src="../../assets/images/icon_company.png">
        <div class="download-title">
            <span v-if="deptartments.length<=0"><font style="font-size:13px">{{deptName}}</font></span>
             <el-dropdown v-else>
              <span class="el-dropdown-link">
                <font style="font-size:13px">{{deptName}}</font>
                <i class="el-icon-arrow-down el-icon--right"></i>
              </span>
              <el-dropdown-menu v-if="deptartments.length>0" slot="dropdown">
                <el-dropdown-item  v-for="item in deptartments" :key="item.deptId" @click.native="handleDeptCommon(item.sn)"> 
                  <span style="font-size:13px;font-weight:600;font-family: '楷体';margin-right:10px; ">切换账号：{{item.deptName}}</span>
                </el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
        </div>
      </div>
      <div class="user" v-show="isUserLogin && menu">
        <el-dropdown trigger="click" size="medium">
          <div class="el-dropdown-link">
            <img class="avatar" :src='avatar' @error="defaultAvatar()">
            {{ nickName }}
            <i class="el-icon-arrow-down el-icon--right"></i>
          </div>
           <el-dropdown-menu slot="dropdown" >
            <!-- <el-dropdown-item @click.native="goUpdatePwd()"><i class="el-icon-lock"></i>修改密码</el-dropdown-item> 
            <el-dropdown-item @click.native="goTodoEntrust()"><i class="el-icon-s-promotion"></i>待办委托</el-dropdown-item> 
            <el-dropdown-item @click.native="goToLeavePeople()" v-show="hasLeavePeople"><i class="el-icon-s-custom"></i>离职用户</el-dropdown-item> 
            <el-dropdown-item @click.native="logout()"><i class="el-icon-circle-close"></i>系统退出</el-dropdown-item>  -->
            <el-dropdown-item >
              <a href="/file/operationManual.pdf" target="_blank" ><i class="el-icon-link"></i>操作手册</a>
            </el-dropdown-item>
             <el-dropdown-item @click.native="handleLogOut"><i class="el-icon-close"></i>退出登录</el-dropdown-item>
          </el-dropdown-menu> 
        </el-dropdown>
      </div>
      <!--渐变线-->
      <div class="border-div"></div>
    </div>
    <!--内容区-->
    <div class="index-main" ref="routerView" :style="{'paddingTop': hideMenu ? 0 : '56px', 'paddingRight': `${scrollWidth}px`}">
      <div class="container-wrapper" :style="{'marginRight': `-${scrollWidth}px`}">
        <router-view :welcome="welcome" :login="login"></router-view>
      </div>
    </div>
    <!-- 返回顶部 -->
    <div class="goTop" v-show="goTopShow" @click="goTop">
      <i class="el-icon-caret-top goTopIcon"></i>
    </div>
  </div>
</template>

<script>
  import $ from 'jquery';
  import Cookies from "js-cookie";
  import {getToken} from "@/utils/auth";
  import {mapGetters} from "vuex";
  import { on, off } from '@/utils/event';
  import jpg from '@/assets/images/home/qychatCode.png'
  import {getConfigKey} from "@/api/home/config";
  import {oauthParams} from '@/utils/oauth';
  import {getUsersByPhone} from "@/api/console/system/user"
  import {userSwitching} from '@/api/login';
  import { setToken, getCiamToken} from '@/utils/auth'
  import { changeMainShop} from '@/api/console/system/user';
  export default {
    name: "homeLayout",
    data() {
      return {
        scrollWidth: 20,
        hideMenu: false,
        imgUrl: jpg,
        showDownload: false,
        welcome: true,
        login: false,
        menu: true,
        activeIndex: '/home/main',
        search: '',
        defaultAvatarImg: require("@/assets/images/img_head.png"),
        navActive: 0,
        dynicRoutes: [],
        scrollTop: "",
        goTopShow: false,
        logoTitle:'',
        deptartments:[],
        currentDept:undefined,
        isShop:'0'
      }
    },
    computed: {
      ...mapGetters([
        'nickName',
        'avatar',
        'deptName'
      ]),
      isUserLogin() {
        if (getToken()) {
          return true;
        }
        return false;
      },
      hasLeavePeople () {
        const homeRoutes = (this.$store.state.permission.addRoutes.some(v => v.path === '/home') && this.$store.state.permission.addRoutes.find(v => v.path && v.path === '/home').children) || []
        return homeRoutes.some(v => v.path === '/home/recuperation')
      }
    },
    created() {
      getConfigKey('logo_title').then(response => {
        this.logoTitle = response.msg
        // 测试代码
        // setTimeout(() => {
        //   this.logoTitle = '办公门户'
        // }, 2000);
      })
      this.scrollWidth = this.getScrollWidth()
      console.log('滚动条宽度', this.scrollWidth)
      if (window.name) {
        this.hideMenu = true
        return
      }
      if (!this.isUserLogin) {
        return
      }
      this.deptartments=[];
      //查询当前用户手机号的对应用户列表
      getUsersByPhone().then(resp=>{
        var loginName=this.$store.getters.name;
        resp.forEach(element => {
          if(element.userName!=loginName){
            this.deptartments.push(element.departmentDept);
          }else{
            this.isShop=element.isShop;
            this.currentDept=element.departmentDept.sn;
          }
        });
      })
      // 过滤门户前端的路由
      const consoleRoutes = (this.$store.state.permission.addRoutes.some(v => v.meta && v.meta.title === '门户前端') && this.$store.state.permission.addRoutes.find(v => v.meta && v.meta.title && v.meta.title === '门户前端').children) || []
      const homeRoutes = (this.$store.state.permission.addRoutes.some(v => v.path === '/home') && this.$store.state.permission.addRoutes.find(v => v.path && v.path === '/home').children) || []
      console.log('consoleRoutes', consoleRoutes)
      console.log('homeRoutes', homeRoutes)
      const filterConsoleRoutes = [];
      consoleRoutes.forEach(item => {
        if(item.path.indexOf("/console") !== -1 && !item.hidden) {
          filterConsoleRoutes.push(item);
        }
      });
      const routes = filterConsoleRoutes.concat(homeRoutes.filter(v => v.nav && !v.hidden));
      const routesPathMap = [];
      const filterroutesPathMap = [
        {
          path: '/home/index',
          name: 'homeIndex',
          hidden: false,
          meta: {title: '首页'}
        }
      ];
      routes.forEach(item => {
        if(routesPathMap.indexOf(item.path) === -1) {
          routesPathMap.push(item.path);
          filterroutesPathMap.push(item);
        }
      });
      this.dynicRoutes = filterroutesPathMap
      //其他菜单
      // if (Cookies.get('publicRoutes')) {
      //   const public_routes = JSON.parse(Cookies.get('publicRoutes'))
      //   this.dynicRoutes = this.dynicRoutes.concat(public_routes)
      //   if (this.$route.path.startsWith('/home/detail')) {
      //     this.navActive = this.dynicRoutes.findIndex(v => v.name === 'window')
      //   } else {
      //     this.navActive = this.dynicRoutes.findIndex(v => v.name === this.$route.path || v.name === this.$route.name)
      //   }
      // } else {
      //   getConfigKey('public_routes').then(response => {
      //   // console.log(response.msg)
      //     if(response.msg !== ''){
      //       var jsonArray = eval('(' + response.msg + ')');
      //       // console.log(typeof(jsonArray))
      //       // console.log(jsonArray)
      //       Cookies.set("publicRoutes", jsonArray);
      //       const public_routes = JSON.parse(Cookies.get('publicRoutes'))
      //       this.dynicRoutes = this.dynicRoutes.concat(public_routes)
      //       if (this.$route.path.startsWith('/home/detail')) {
      //         this.navActive = this.dynicRoutes.findIndex(v => v.name === 'window')
      //       } else {
      //         this.navActive = this.dynicRoutes.findIndex(v => v.name === this.$route.path || v.name === this.$route.name)
      //       }
      //     }
      //   })
      // }
    },
    mounted () {
      document.title = '博世车联门户'
      this.hiddenMenu();
      if (this._isMobile()) {
        this.menu = false;
        // $('.menu').css('display', 'none');
        // $('.logo>img').css({
        //   //'width': '180px',
        //   'object-fit': 'contain'
        // });
        // $('.userMenu').css('float', 'right');
        // $('.userMenu').css('width', '40%');
        // $('#app .el-dropdown-menu').css('top', '64px');
        // $('.el-header').css('padding', '0');
      }
       this.$refs.routerView.addEventListener("scroll", this.handleScroll);
      // window.addEventListener("scroll", this.handleScroll);

      // this.activeIndex = this.$route.path
      // this.handler(true)
    },
    beforeDestroy() {
      this.$refs.routerView.removeEventListener('scroll', this.handleScroll)
    },
    updated () {},
    watch: {
      $route(to, from) {
        document.title = '博世车联门户'
        if (this.$route.path.startsWith('/home/detail')) {
          this.navActive = this.dynicRoutes.findIndex(v => v.name === 'window')
        } else {
          this.navActive = this.dynicRoutes.findIndex(v => v.name === this.$route.path || v.name === this.$route.name)
        }
        this.$refs.routerView.scrollTop = 0
        // console.log(this.dynicRoutes.find(v => v.path === to.path))
        if (this.$route.path == '/window') {
          this.menu = false;
          $('.userMenu').css('float', 'right');
        } else {
          this.menu = true;
        }
      },
      scrollTop(val) {
        if (this.scrollTop > 500) {
            this.goTopShow = true;
        } else {
            this.goTopShow = false;
        }
      },
      activeIndex (val) {
        // console.log('m', val)
      }
    },
    methods: {
      //设置主店
      handleCollection(deptSn){
        var deptSn=this.currentDept;
        changeMainShop({deptSn:deptSn}).then(resp=>{
          if(resp.code==200){
            this.isShop='1';
            this.$message.success("设置默认账号成功");
          }
        })
      },
      //切换用户
      handleDeptCommon(deptSn){
        //切换用户接口
        userSwitching({deptSn:deptSn}).then(resp=>{
          if(resp.code==200){
            setToken(resp.data.ssoResult.token);
            window.location.reload()
          }else{
            this.$message.error(resp.msg)
          }
        });
      },
      //图标跳转
      handleLogoClick(){
        this.$router.push( {path:'/home/index'})
      },
      ahrefOnclick () {
        const cacheactiveIdnex = this.activeIndex
        this.activeIndex = undefined
        const timer = setTimeout(() => {
          clearTimeout(timer)
          this.activeIndex = cacheactiveIdnex
        }, 100);
      },
      logPrint (path) {
        // console.warn('path', path)
      },
      defaultAvatar() {
        let img = event.srcElement;
        img.src = this.defaultAvatarImg;
        img.onerror = null; //防止闪图
      },
      home() {
        const path=window.location.href;
        if(path.indexOf('/home/index')===-1){
          this.$router.push( {path:'/home/index'})
        }else{
          window.location.reload();
        }

      },
      handleSelect(key, keyPath) {
        // console.log(key, keyPath);
      },
      /********************
       * @desc 跳转离职用户
       * @function goToLeavePeople
       */
      goToLeavePeople () {
        if (this.$route.path === '/home/recuperation') {
          // 不做处理
        } else {
          this.$router.push('/home/recuperation')
        }
      },
      goTodoEntrust(){
        // window.location.href = '/home/todoEntrust';
        if (this.$route.path === '/home/todoEntrust') {
          // 不做处理
        } else {
          this.$router.push('/home/todoEntrust')
        }
      },
      goUpdatePwd(){
        // window.location.href = '/home/updatePwd';
        if (this.$route.path === '/home/updatePwd') {
          // 不做处理
        } else {
          this.$router.push('/home/updatePwd')
        }
      },
      goSetSp(){
        if (this.$route.path === '/home/setSp') {
          // 不做处理
        } else {
          this.$router.push('/home/setSp')
        }
        // window.location.href = '/home/setSp';
      },
      async handleLogOut() {
        this.$confirm('确定注销并退出系统吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          window.location.href="https://identity.bosch.com.cn/ids/connect/endsession?id_token_hint="+getCiamToken()+"&post_logout_redirect_uri=https://sso.rbtssws.com.cn/logout"
        })
      },
      Login() {
        this.welcome = true;
        this.login = false;
      },
      hiddenMenu() {
        if (this.$route.path == '/window') {
          this.menu = false;
          // $('.userMenu').css('float', 'right')
        } else {
          this.menu = true;
        }
      },
      _isMobile() {
        let flag = navigator.userAgent.match(/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i)
        return flag;
      },
      changeTheme (theme) {
        window.document.documentElement.setAttribute( "data-theme", theme);
        localStorage.setItem('data-theme', theme)
      },
      // 导航点击事件
      navClick (item, index) {
        if (item.path.startsWith('http')) {
          window.open(item.path)
        } else {
          // console.warn('item', item)
          this.navActive = index;
          window.open(item.path)
          // this.$router.push(item.path).catch(error=> error);
        }
      },
      getScrollWidth() {
        let noScroll, scroll, oDiv = document.createElement("DIV");
        oDiv.style.cssText = "position:absolute; top:-1000px; width:100px; height:100px; overflow:hidden;";
        noScroll = document.body.appendChild(oDiv).clientWidth;
        oDiv.style.overflowY = "scroll";
        scroll = oDiv.clientWidth;
        document.body.removeChild(oDiv);
        return noScroll-scroll;
      },
       handleScroll() {
        this.scrollTop = this.$refs.routerView.scrollTop
        if (this.scrollTop > 500) {
            this.goTopShow = true;
        }
      },
      goTop() {
        let el = this.$refs.routerView
        let step = 0;
        let interval = setInterval(() => {
          if (el.scrollTop <= 0) {
            clearInterval(interval);
            return;
          }
          step += 10;
          el.scrollTop -= step;
        }, 20)
      }
    },

  };
</script>

<style lang="scss" scoped>
  .wrapper{
    background-color: #F5F6FA;
    overflow-x: hidden;
  }
  .hedaer-wrapper{
    width: 100%;
    background-color: #fff;
    height: 56px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px 0 0;
    box-sizing: border-box;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 2000;
    .logo-panel{
      margin-right: 64px;
      margin-left:10% ;
      display: flex;
      align-items: center;
      .main-logo{
        height: 40px;
        width: 78px;
        // margin-right: 64px;
      }
      .main-title{
        font-size: 20px;
        color:#fff;
        margin-left: 20px;
        border-left: 1px solid #fff;
        padding-left: 20px;
      }
    }
    // 导航栏样式
    .nav-panel{
      display: flex;
      align-self: flex-start;
      font-size: 16px;
      font-weight: 400;
      color: rgba($color: #000, $alpha: .65);
      flex: 1;
      flex-wrap: wrap;
      overflow: hidden;
      height: 100%;
      margin-right: 20px;
      .nav-item{
        // height: 64px;
        line-height: 56px;
      }
      .item{
        // color: rgba($color: #fff, $alpha: .65);
        border: 2px solid transparent;
        padding: 7px 20px;
        cursor: pointer;
        white-space: nowrap;
        transition: all 0.3s;
        &.active, &:active{
          background-color: white;
          box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.15);
          border-radius: 18px;
          border-color:white;
          color:#000;
        }
        &.active {
          cursor: default;
        }
      }
    }
    .download-shop{
      height: 50px;
      position: relative;
      margin-right: 10px;
      line-height: 50px;
      font-weight: bold;
      font-family: '楷体';
      font-size: 14px;
      letter-spacing: 1px;
    }
    .download-panel{
      height: 100%;
      position: relative;
      margin-right: 100px;
      line-height: 100%;
      img{
        width: 20px;
        height: 20px;
        cursor: pointer;
        margin-top: 20px;
      }
      .download-title{
        margin-left: 8px;
        display: inline-block;
        align-items: center;
        font-weight: bold;
        font-family: '楷体';
        font-size: 13px;
        height: 28px;
        vertical-align:middle
      }
 
      .download{
        display: none;
        width: 272px;
        height: 280px;
        position: absolute;
        background-color: #fff;
        z-index: 2000;
        right: 0;
        top: 56px;
        border-radius: 8px;
        padding: 15px 20px;
        box-sizing: border-box;
        box-shadow: 0px 2px 12px 0px rgba(212, 212, 212, 0.5);
        .title{
          font-size: 12px;
          font-weight: 600;
          color: #303133;
          position: relative;
          padding-left: 20px;
          text-align: left;
          margin-bottom: 8px;
        }
        .code-main{
          text-align: center;
          margin-bottom: 13px;
          .title{
            &::before{
              content: '';
              position: absolute;
              left: 0;
              top: 50%;
              width: 16px;
              height: 16px;
              transform: translateY(-50%);
              background: url('../../assets/images/home/icon_mobile.png') no-repeat;
              background-size: 16px 16px;
            }
          }
          .img{
            margin: 8px 0 6px;
            width: 108px;
            height: 108px;
            vertical-align: middle;
          }
          .text{
            font-size: 12px;
            font-weight: 400;
            color: #2272DE;
          }
        }
        .link-main{
          text-align: left;
          color: #303133;
          font-size: 12px;
          .title{
            &::before{
              content: '';
              position: absolute;
              left: 0;
              top: 50%;
              width: 16px;
              height: 16px;
              transform: translateY(-50%);
              background: url('../../assets/images/home/icon_pc.png') no-repeat;
              background-size: 16px 16px;
            }
          }
          a{
            cursor: default;
            display: block;
            &:not(:first-child){
              margin-bottom: 2px;
            }
          }
          span{
            color: #2272DE;
          }
        }
      }
      &:hover{
        .download{
          display: block;
        }
      }
    }
    // 右侧用户样式
    .user{
      padding-right: 5%;
      cursor: pointer;
      ::v-deep .el-dropdown{
        white-space: nowrap;
        font-size: 13px;
        font-weight: 500;
        color:#000;
      }
      .el-dropdown-link{
        font-size: 13px;
        font-weight: 500;
        color:#000;
        display: flex;
        align-items: center;
      }
      .avatar{
        width: 32px;
        height: 32px;
        border-radius: 50%;
        margin-right: 4px;
      }
    }
    //渐变线
    .border-div{
      position: absolute;
      bottom: 0px;
      height: 3px;
      width: 100%;
      background-image:  url("../../assets/images/img_nav_bg.png");
      background-size : 100% 100%;
    }
  }
  // 子路由容器
  .index-main{
    background-color: #f0f0f0;
    padding-top: 56px;
    height: 100vh;
    overflow-y: scroll;
    >.container-wrapper{
    }
  }
  .goTop {
    position: fixed;
    right: 40px;
    bottom: 60px;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #fff;
    padding: 10px;
    cursor: pointer;
    box-shadow: 0 0 6px rgba(0, 0, 0, 0.12);
  }
  .goTop:hover .goTopIcon {
      color: rgba(51, 153, 255, 1);
  }
  .goTopIcon {
      font-size: 20px;
      color: rgba(51, 153, 255, 0.8);
  }

  ::v-deep .el-icon-my-collection{
    background: url("../../assets/icons/collection.png") center no-repeat;
  }
   ::v-deep.el-icon-my-statistic:before{
    font-size: 14px;
    visibility: hidden;
    margin-left: 1px;
  }
</style>
