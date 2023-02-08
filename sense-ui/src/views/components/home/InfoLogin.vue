<template>
  <div class="login">
    <el-form ref="loginForm" :model="loginForm">
      <div class="publicFlex">
        <div class="loginTitle">
          <h3>账号登录</h3>
        </div>
        <!-- <div class="otherLogin">
          <span>扫码登录</span>
          <img @click="changeLogin()" src="@/assets/images/home/icon_scancode.png" width="20" height="20"
               alt="">
        </div> -->
      </div>
      <div v-show="idLogin" class="idLogin">

        <el-input placeholder="账号" type="text" class="user" size="medium" prefix-icon="el-icon-users"  v-model="loginForm.username"/>

        <el-input placeholder="密码" type="password" size="medium" class="userPassword" prefix-icon="el-icon-userPassword"  v-model="loginForm.password"
                  @keyup.enter.native="handleLogin"/>
        <router-link to="#"></router-link>
        <router-link to="/home/reset">忘记密码？</router-link>
        <el-button @click.native.prevent="handleLogin" type="primary"
                   style="width:100%;height:40px;background: #2272DE;">登录
        </el-button>
      </div>
      <div id="qywxDiv" v-show="codeLogin" class="codeLogin">
        <img src="@/assets/images/home/icon_scancode.png" alt="" width="120" height="120">
        <p>打开 <span>企业微信app</span> 扫一扫登录</p>
      </div>
    </el-form>
  </div>
</template>

<script>
import Cookies from "js-cookie";
import {encrypt} from "@/utils/jsencrypt";
import {getConfigKey} from "@/api/home/config";
import {accessSubportal} from "@/api/login";

export default {
  name: "InfoLogin",
  props: ['params'],
  data() {
    return {
      idLogin: true,
      codeLogin: false,
      qywxCorpID: "",
      qywxAgentId: "",
      //登陆表单
      loginForm: {
        username: "",
        password: "",
        rememberMe: false,
        uuid: ""
      }
    }
  },
  created() {
    getConfigKey('qywx_CorpID').then(response => {
      this.qywxCorpID = response.msg;
    });
    getConfigKey('qywx_AgentId').then(response => {
      this.qywxAgentId = response.msg;
    });
  },
  methods: {
    changeLogin() {
      this.idLogin = !this.idLogin;
      this.codeLogin = !this.codeLogin;
      let protocol = window.location.protocol;
      let url = window.location.hostname;
      let port = window.location.port;
      let redirectUri = encodeURIComponent(protocol + "//" + url + ((port == 80 || port == 443)?"":":"+port)+"/index");
      window.WwLogin({
        "id" : "qywxDiv",
        "appid" : this.qywxCorpID,
        "agentid" : this.qywxAgentId,
        "redirect_uri" : redirectUri,
        "state" : "",
        "href" : "data:text/css;base64,LmltcG93ZXJCb3ggLnFyY29kZSB7d2lkdGg6IDIwMHB4O30KLmltcG93ZXJCb3ggLnRpdGxlIHtkaXNwbGF5OiBub25lO30KLmltcG93ZXJCb3ggLmluZm8ge3dpZHRoOiAyMDBweDt9Ci5zdGF0dXNfaWNvbiB7ZGlzcGxheTogbm9uZSAgIWltcG9ydGFudH0KLmltcG93ZXJCb3ggLnN0YXR1cyB7dGV4dC1hbGlnbjogY2VudGVyO30K",
      });
    },
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        if (valid) {
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
            //判断登录用户是否存在绑定门户
            if(this.params && this.params.isDialog) {
              this.$emit('loginSuccess')
            }
            if( response.code===200){
              if(response.data &&  response.data.subportalTempleteId) {
                Cookies.set("subportal_templeteId", response.data.subportalTempleteId);
              }
            }
            window.location.href = "/home/index"
          }).catch(() => {
            this.loading = false;
          });
        }
      });
    },
    keyDown() {
      this.handleLogin();
    }
  }
}
</script>

<style scoped>

</style>
