<template>
  <div class="wrapper" :style="{'height': height}">
    <div class="title-panel">
      <div class="idLogin">{{idLogin ? '账号登录' : '扫码登录'}}</div>
      <div class="scanLogin-panel" @click="changeLogin">
        <div class="title">{{codeLogin ? '账号登录' : '扫码登录'}}</div>
        <img v-show="idLogin" src="@/assets/images/home/icon_scancode.png">
      </div>
    </div>
    <div class="content-panel">
      <el-form ref="loginForm" :model="loginForm">
        <div v-show="idLogin" class="idLogin-panel">
          <el-input placeholder="账号" type="text" class="user" size="medium" prefix-icon="el-icon-users" v-model="loginForm.username"/>
          <el-input placeholder="密码" type="password" size="medium" class="userPassword" prefix-icon="el-icon-userPassword"  v-model="loginForm.password"/>
          <router-link to="#"></router-link>
          <div class="forgetPwd-box"><router-link to="/home/reset" class="forgetPwd">忘记密码？</router-link></div>
          <el-button @click.native.prevent="handleLogin" :loading="loading" type="primary" style="font-size: 14px">登录</el-button>
          <input type="submit" v-if="isIE" id="input" style="display:none">
        </div>
        <div id="qywxDiv" v-show="codeLogin" class="codeLogin">
          <div id="qywxlogin" class="qrCode">
            <!-- <img src="@/assets/images/login/code.png"> -->
          </div>
          <div class="tip">打开<span>企业微信app</span>扫一扫登录</div>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script>
import Cookies from "js-cookie";
import {encrypt, decrypt, clientEncrypt} from '@/utils/jsencrypt';
import {wwLogin} from '@/utils/wwLogin-1.0.0';
import {getConfigKey} from "@/api/home/config";
import {generateToken} from "@/api/login";
import {getToken, setToken, removeToken,getTGC,setTGC} from '@/utils/auth'
import axios from 'axios'
export default {
  name: "InfoLogin",
  props: ['params', 'height'],
  data() {
    return {
      isIE: !!window.ActiveXObject || 'ActiveXObject' in window,
      loading: false,
      idLogin: true,
      codeLogin: false,
      //登陆表单
      loginForm: {
        username: "",
        password: "",
        rememberMe: false,
        uuid: ""
      },
      redirect: undefined,
			qywxUrl: '',
			qywxAppId: '',
			qywxAgentId: ''
    }
  },
  created() {
    getConfigKey('qywx_url').then(response => {
      this.qywxUrl = response.msg;
		});
		getConfigKey('qywx_corpid').then(response => {
      this.qywxAppId = response.msg;
		});
		getConfigKey('qywx_AgentId').then(response => {
      this.qywxAgentId = response.msg;
    });
  },
  mounted () {
		// 监听当前页面下回车动作
    const _this = this
    document.onkeydown = function(e) {
      var key = window.event.keyCode;
      if (key == 13) {
        _this.handleLogin();
      }
    }
  },
  beforeDestroy() {
    document.onkeydown = null
  },
  methods: {
    changeLogin () {
      this.idLogin = !this.idLogin;
      this.codeLogin = !this.codeLogin;
      if (this.codeLogin) {
        this.scanhandleLogin()
      }
    },
    // 外网测试代码
    // refreshQYWXLogin() {
    //   var url = "http://sso.sensesw.com:8882/portal/login.html"
    //   var path = this.redirect || "/home/index"
    //   wwLogin({
    //         "id" : "qywxlogin",
    //         "appid" : "ww00a52dcb1e35a5c3",
    //         "agentid" : "1000012",
    //         "redirect_uri" : url+"/qrLogin?redirect="+encodeURIComponent(encodeURIComponent(path)),
    //         "state" : "",
    //         // "href" : "data:text/css;base64,LmltcG93ZXJCb3ggLnFyY29kZSB7d2lkdGg6IDIwMHB4O30NCi5pbXBvd2VyQm94IC50aXRsZSB7ZGlzcGxheTogbm9uZTt9DQouaW1wb3dlckJveCAuaW5mbyB7d2lkdGg6IDIwMHB4O30NCi5zdGF0dXNfaWNvbiB7ZGlzcGxheTpub25lfQ0KLmltcG93ZXJCb3ggLnN0YXR1cyB7dGV4dC1hbGlnbjogY2VudGVyO30=",
    //         "href": "data:text/css;base64,aHRtbCwgYm9keXsNCiAgaGVpZ2h0OiAxMjBweDsNCn0NCi53cnBfY29kZXsNCiAgbWFyZ2luLXRvcDogMCFpbXBvcnRhbnQ7DQp9DQouaW1wb3dlckJveCAucXJjb2RlIHt3aWR0aDogMTIwcHg7fQ0KLmltcG93ZXJCb3ggLnRpdGxlIHtkaXNwbGF5OiBub25lO30NCi5pbXBvd2VyQm94IC5pbmZvIHtkaXNwbGF5Om5vbmU7fQ0KLnN0YXR1c19pY29uIHtkaXNwbGF5Om5vbmV9DQouaW1wb3dlckJveCAuc3RhdHVzIHt0ZXh0LWFsaWduOiBjZW50ZXI7fQ=="
    //   }, "https://open.work.weixin.qq.com");
    // },
    scanhandleLogin() {
      // this.refreshQYWXLogin()
      var url = location.protocol+"//"+location.hostname;
			var path = this.redirect || "/home/index"
      wwLogin({
        "id" : "qywxlogin",
        "appid" : this.qywxAppId,
        "agentid" : this.qywxAgentId,
        "redirect_uri" : url+"/qrLogin?redirect="+encodeURIComponent(encodeURIComponent(path)),
        "state" : "",
        "href": "data:text/css;base64,aHRtbCwgYm9keXsNCiAgaGVpZ2h0OiAxMjBweDsNCn0NCi53cnBfY29kZXsNCiAgbWFyZ2luLXRvcDogMCFpbXBvcnRhbnQ7DQp9DQouaW1wb3dlckJveCAucXJjb2RlIHt3aWR0aDogMTIwcHg7fQ0KLmltcG93ZXJCb3ggLnRpdGxlIHtkaXNwbGF5OiBub25lO30NCi5pbXBvd2VyQm94IC5pbmZvIHtkaXNwbGF5Om5vbmU7fQ0KLnN0YXR1c19pY29uIHtkaXNwbGF5Om5vbmV9DQouaW1wb3dlckJveCAuc3RhdHVzIHt0ZXh0LWFsaWduOiBjZW50ZXI7fQ==",
			}, this.qywxUrl);
    },
    idhandleLogin() {
      if (this.loginForm.username && this.loginForm.password) {
        this.$refs.loginForm.validate(valid => {
          if (valid) {
            if (this.loading) {
              return
            }
            this.loading = true;
            // //单点
            // axios({
            //   withCredentials: true,
            //   method:'post',
            //   url: "http://192.168.0.199:8882/sso/gatewayLogin",
            //   params:{username:this.loginForm.username,password:this.loginForm.password,clientId:'APP999'},
            //   }).then(resp=>{
            //   if(resp.data.success){
            //     //请求到门户后台设置token
            //     Cookies.remove("subportal_templeteId");
            //     generateToken({loginName:resp.data.data.loginName}).then(response=>{
            //       if(response.code==200){
            //         this.loading=false;
            //         setToken(response.data.token);
            //         setTGC(response.data.uiap_tgc);
            //         if (this.isIE){
            //           document.getElementById('input').click()
            //         }
            //         if(response.data &&  response.data.subportalTempleteId) {
            //           Cookies.set("subportal_templeteId", response.data.subportalTempleteId);
            //         }
            //       } 
            //       if(this.params && this.params.isDialog) {
            //         this.$emit('loginSuccess');
            //       } else {
            //         window.location.href = "/home/index";
            //       }
            //     }).catch(resp=>{
            //       this.loading=false;
            //     })
            //   }else{
            //     this.loading=false;
            //     this.msgError(resp.data.msg)
            //   }
            // });
            if (this.loginForm.rememberMe) {
              Cookies.set("username", this.loginForm.username, {expires: 30});
              Cookies.set("password", encrypt(this.loginForm.password), {expires: 30});
              Cookies.set('rememberMe', this.loginForm.rememberMe, {expires: 30});
            } else {
              Cookies.remove("username");
              Cookies.remove("password");
              Cookies.remove('rememberMe');
            }
            Cookies.remove("subportal_templeteId");
            this.$store.dispatch("Login", this.loginForm).then(response => {
            this.$store.dispatch("Login", {...this.loginForm, password: clientEncrypt(this.loginForm.password)}).then(response => {
              // console.warn('Login', response)
              //判断登录用户是否存在绑定门户
              this.loading = false
              if(response.code===200){
                if (this.isIE){
                  document.getElementById('input').click()
                }
                if(response.data &&  response.data.subportalTempleteId) {
                  Cookies.set("subportal_templeteId", response.data.subportalTempleteId);
                }
              }
              if(this.params && this.params.isDialog) {
                this.$emit('loginSuccess')
              } else {
                window.location.href = "/home/index"
              }
            }).catch(() => {
              this.loading = false;
            });
            });
          }
        });
      } else {
        this.msgError('账号或密码不能为空')
      }
    },
    handleLogin() {
      if (this.idLogin) {
        this.idhandleLogin()
      }
    },
    keyDown() {
      this.handleLogin();
    },
  }
}
</script>

<style lang="scss" scoped>
  @import '../../../assets/styles/home/home.scss';
  .wrapper{
    height: 246px;
    background-color: #fff;
    display: flex;
    flex-direction: column;
  }
  .title-panel{
    height: 48px;
    font-size: 16px;
    font-weight: 600;
    color: #333333;
    padding: 0 20px;
    border-bottom: 1px solid #F2F2F2;
    display: flex;
    justify-content: space-between;
    align-items: center;
    .scanLogin-panel{
      cursor: pointer;
      display: flex;
      align-items: center;
      .title{
        width: 68px;
        height: 24px;
        line-height: 24px;
        background: url('../../../assets/images/home/img_tipsbg.png') no-repeat 0 0;
        background-size: 68px 24px;
        font-size: 12px;
        text-align: center;
        font-weight: 500;
      }
      img{
        margin-left: 8px;
        width: 20px;
        height: 20px;
      }
    }
  }
  .content-panel{
    padding: 10px 20px 0;
    height: calc(100% - 48px);
    .el-form{
      height: 100%;
    }
    .idLogin-panel{
      ::v-deep .el-input{
        margin-bottom: 16px;

        .el-icon-users{
          background-position: 5px 10px;
        }
        .el-icon-userPassword{
          background-position: 5px 10px;
        }
      }
      .forgetPwd-box{
        text-align: right;
      }
      .forgetPwd{
        font-size: 14px;
        color:#767676;
        &:hover{
          color:#2272DE;
        }
      }
      .el-button{
        width: 100%;
        margin: 8px 0;
        height: 40px;
      }
    }
    .codeLogin{
      height: 100%;
      overflow: hidden;
      .qrCode{
        overflow: hidden;
        height: 120px;
      }
      .tip{
        margin-top: 20px;
        color: #767676;
        font-size: 14px;
        span{
          color:#2272DE;
          margin: 0 2px;
        }
      }
    }
   
  }
</style>
