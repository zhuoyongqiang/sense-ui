<template>
  <div class="wrapper">
    <div class="container">
      <div class="main">
        <div class="left">
          <img src="../assets/images/window/login.gif">
        </div>
        <div class="right">
          <div class="qrcodethumbnail" @click="changeloginMethod"></div>
          <img class="qrcodethumbnailImg" :src="require(`../assets/images/login/${loginMethod === 'input' ? 'img_qrcode' : 'img_computer'}.png`)">
          <transition name="fade">
            <div class="inputPart" v-show="loginMethod === 'input'">
              <div class="title">统一身份认证中心</div>
              <div class="input-wrapper">
                <el-tabs v-model="activeName" @tab-click="handleClick">
                  <el-tab-pane label="账号登录" name="first">
                    <el-form :model="loginForm" :rules="loginRules" ref="loginForm" label-width="0">
                      <!-- <input type="password" style="display: none;"> -->
                      <el-form-item prop="username">
                        <el-input v-model="loginForm.username" placeholder="账号"><img slot="prefix" src="../assets/images/login/icon_user.png" class="input-icon" /></el-input>
                      </el-form-item>
                      <el-form-item prop="password">
                        <el-input v-model="loginForm.password" show-password placeholder="密码"><img slot="prefix" src="../assets/images/login/icon_password.png" class="input-icon" /></el-input>
                        <!-- <el-input v-model="loginForm.password"
                          v-if="hackConfirmPassword"
                          ref="confirmPassword"
                          :showPassword="showConfirmPassword"
                          @input="(value) => {showPassword(value, 'confirmPassword')}"
                          placeholder="密码">
                          <img slot="prefix" src="../assets/images/login/icon_password.png" class="input-icon" /></el-input> -->
                      </el-form-item>
                      <input type="submit" v-if="isIE" id="input" style="display:none">
                    </el-form>
                    <div class="operation">
                      <div @click="loadView('/home/reset')">忘记密码</div>
                    </div>
                    <el-button
                      :loading="loading"
                      class="submit-button"
                      size="medium"
                      type="primary"
                      @click.native.prevent="handleLogin"
                    >{{loading ? '登录中' : '登录'}}</el-button>
                  </el-tab-pane>
                  <!-- <el-tab-pane label="人脸登录" name="second">
                    <div style="margin:40px auto; border-radius: 50%; border: 1px solid blue; width: 178px; height:178px"></div>
                    <div style="text-align: center; color:#2272DE;font-size: 14px">请靠近一点</div>
                  </el-tab-pane> -->
                </el-tabs>
              </div>
            </div>
          </transition>
          <transition name="fade">
            <div class="scanpart" v-show="loginMethod === 'scan'">
              <div class="title">二维码登录</div>
              <div id="qywxlogin" class="qrCode">
                <img src="../assets/images/login/code.png">
              </div>
            </div>
          </transition>
          <div v-show="loginMethod === 'input'" class="downloadLink" @click="dialogVisible = true">下载企业微信</div>
        </div>
      </div>
    </div>
    <div class="copyright">
      <span>Copyright © 2018-2021 sense.vip All Rights Reserved.</span>
    </div>
    <div class="download" v-show="dialogVisible">
      <div class="code-main">
        <div class="title">移动端下载</div>
        <el-image class="img" :src="imgUrl"></el-image>
        <div class="text">扫一扫</div>
      </div>
      <div class="link-main">
        <div class="title">桌面版下载</div>
        <a href="#">请打开360软件管家，搜索“<span>云办公</span>”下载</a>
        <a href="#"><span>桌面版国行企业微信</span>支持办公网络即时通讯，让沟通更高效</a>
      </div>
    </div>
    <div class="shadow" v-show="dialogVisible" @click="dialogVisible = false"></div>
  </div>
</template>

<script>
import Cookies from "js-cookie";
import {encrypt, decrypt, clientEncrypt} from '@/utils/jsencrypt';
import {wwLogin} from '@/utils/wwLogin-1.0.0';
import {getConfigKey} from "@/api/home/config";
import jpg from '@/assets/images/home/qychatCode.png'

export default {
  name: "Login",
  data() {
    return {
      isIE: !!window.ActiveXObject || 'ActiveXObject' in window,
      imgUrl: jpg,
      dialogVisible: false,
      // showConfirmPassword: false,
      // hackConfirmPassword: false,
      loginMethod: 'input',
      activeName: 'first',
      checked: false,
			cookiePassword: "",
      loginForm: {
        username: "",
        password: "",
        rememberMe: false,
        uuid: ""
      },
      loginRules: {
        username: [
          {required: true, trigger: "blur", message: "用户名不能为空"}
        ],
        password: [
          {required: true, trigger: "blur", message: "密码不能为空"}
        ]
      },
      loading: false,
			redirect: undefined,
			qywxUrl: '',
			qywxAppId: '',
			qywxAgentId: ''
    };
  },
  watch: {
    $route: {
      handler: function (route) {
        if (this.$route.query.redirectUri != null) {
					this.redirect = this.$route.query.redirectUri;
				}
      },
      immediate: true
    }
  },
  created() {
		this.getCookie();
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
		// this.hackConfirmPassword = true;
    const _this = this
    document.onkeydown = function(e) {
      console.log('onkeydown')
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
    getCookie() {
      const username = Cookies.get("username");
      const password = Cookies.get("password");
      const rememberMe = Cookies.get('rememberMe')
      this.loginForm = {
        username: username === undefined ? this.loginForm.username : username,
        password: password === undefined ? this.loginForm.password : decrypt(password),
        rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
      };
    },
    handleLogin() { 
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true;
          if (this.loginForm.rememberMe) {
            Cookies.set("username", this.loginForm.username, {expires: 30});
            Cookies.set("password", encrypt(this.loginForm.password), {expires: 30});
            Cookies.set('rememberMe', this.loginForm.rememberMe, {expires: 30});
          } else {
            Cookies.remove("username");
            Cookies.remove("password");
            Cookies.remove('rememberMe');
          }
          // console.log()
          this.$store.dispatch("Login", {...this.loginForm, password: clientEncrypt(this.loginForm.password)}).then(() => {
            if (this.isIE){
              document.getElementById('input').click()
            }
						var path = this.redirect || "/home/index"
						window.location.href = path;
          }).catch(() => {
            this.loading = false;
          });
        }
      });
    },
    loadView (path) {
      this.$router.push(path)
    },
    changeloginMethod () {
      console.log(this.loginMethod)
			this.loginMethod = (this.loginMethod === 'input' ? 'scan': 'input')
			if (this.loginMethod === 'scan') {
				this.refreshQYWXLogin();
			}
    },
    handleClick(tab, event) {
      console.log(tab, event);
    },
    // showPassword(value, type) {
    //   if(value != "" && !this.showConfirmPassword) {
    //     // type 为 password
    //     this.showConfirmPassword = true;
    //   }else if("" == value && this.showConfirmPassword) {
    //     // 重建并获取焦点
    //     this.hackConfirmPassword = false;
    //     this.$nextTick(()=>{
    //       this.hackConfirmPassword = true;
    //       setTimeout(()=>{
    //         this.$refs.confirmPassword.$el.children[0].focus();
    //       }, 5)
    //     })
    //     // type 为 text
    //     this.showConfirmPassword = false;
    //   }
		// },
		refreshQYWXLogin() {
			var url = location.protocol+"//"+location.hostname;
			var path = this.redirect || "/home/index"
			wwLogin({
        "id" : "qywxlogin",
        "appid" : this.qywxAppId,
        "agentid" : this.qywxAgentId,
        "redirect_uri" : url+"/qrLogin?redirect="+encodeURIComponent(encodeURIComponent(path)),
        "state" : "",
        "href" : "data:text/css;base64,LmltcG93ZXJCb3ggLnFyY29kZSB7d2lkdGg6IDIwMHB4O30NCi5pbXBvd2VyQm94IC50aXRsZSB7ZGlzcGxheTogbm9uZTt9DQouaW1wb3dlckJveCAuaW5mbyB7d2lkdGg6IDIwMHB4O30NCi5zdGF0dXNfaWNvbiB7ZGlzcGxheTpub25lfQ0KLmltcG93ZXJCb3ggLnN0YXR1cyB7dGV4dC1hbGlnbjogY2VudGVyO30=",
			}, this.qywxUrl);
		}
  }
};
</script>
<style scoped lang="scss">
  .wrapper{
    background-image: linear-gradient(151deg, #E5EFFF 0%, #ACC3E9 100%);
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 600px;
    min-width: 1000px;
  }
  .container{
    flex: 1;
    display: flex;
    align-items: center;
    min-height: 560px;
    .main{
      display: flex;
      height: 560px;
      border-radius: 10px;
      overflow: hidden;
    }
    .left{
      height: 100%;
      img{
        width: 560px;
        height: auto;
      }
    }
    .right{
      width: 440px;
      height: 100%;
      padding: 102px 60px 0;
      box-sizing: border-box;
      background-color: #fff;
      position: relative;
      .qrcodethumbnail{
        position: absolute;
        top:0;
        right: 0;
        width: 100px;
        height: 100px;
        background-color: transparent;
        z-index: 20;
        transform: translate(50%, -50%) rotate(45deg);
        cursor: pointer;
      }
      .qrcodethumbnailImg{
         position: absolute;
        top:0;
        right: 0;
        width: 72px;
        height: 72px;
        z-index: 10;
      }
      .title{
        color:#333;
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 50px;
      }
      ::v-deep .el-form-item{
        margin-bottom: 20px;
      }
      ::v-deep .el-input__inner{
        width: 320px;
        height: 36px;
        border-radius: 4px!important;
        &::placeholder{
          color:#979797;
          font-size: 14px;
          font-weight: 400;
        }
      }
      ::v-deep .el-input__prefix{
        display: flex;
        align-items: center;
      }
      .input-icon{
        width: 20px;
        height: 20px;
      }
      .operation{
        display: flex;
        justify-content: flex-end;
        color:#1A1A1A;
        font-size: 14px;
        font-weight: 400;
        >div{
          cursor: pointer;
        }
        ::v-deep .el-checkbox{
          .el-checkbox__inner{
            width: 16px;
            height: 16px;
          }
          .el-checkbox__input.is-checked + .el-checkbox__label{
            color: #1A1A1A;
          }
        }
      }
      .scanpart{
        position: absolute;
        left: 50%;
        top: 102px;
        transform: translateX(-50%);
        z-index: 1;
        .title{
          text-align: center;
        }
/*         .qrCode{
          width: 200px;
          height: 200px;
          margin: 0 auto;
          img{
            width: 100%;
            height: auto;
          }
        } */
        .tip{
          margin-top: 20px;
          text-align: center;
          color: #666;
          font-size: 14px;
        }
      }
      .downloadLink{
        text-align: right;
        font-size: 14px;
        font-weight: 400;
        color: #2272DE;
        margin-top: 16px;
        cursor: pointer;
      }
    }
    .submit-button{
      width: 100%;
      margin-top: 40px;
    }
  }
  .copyright{
    margin: 20px 0;
  }
  .shadow{
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: transparent;
    z-index: 99;
  }
  .download{
    width: 272px;
    height: 280px;
    background-color: #fff;
    border-radius: 8px;
    padding: 15px 20px;
    box-sizing: border-box;
    box-shadow: 0px 2px 12px 0px rgba(212, 212, 212, 0.5);
    position: absolute;
    top:50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 999;
    .title{
      font-size: 12px;
      font-weight: 600;
      color: #303133;
      position: relative;
      padding-left: 20px;
      text-align: left;
      margin-bottom: 8px;
      &::before{
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        width: 3px;
        height: 10px;
        transform: translateY(-50%);
        background-color: #2272DE;
      }
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
          background: url('../assets/images/home/icon_mobile.png') no-repeat;
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
          background: url('../assets/images/home/icon_pc.png') no-repeat;
          background-size: 16px 16px;
        }
      }
      a{
        display: block;
        cursor: default;
        &:not(:first-child){
          margin-bottom: 2px;
        }
      }
      span{
        color: #2272DE;
      }
    }
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
    transform: scale(0);
  }
  .fade-enter-to, .fade-leave {
    opacity: 1;
    transform: scale(1);
  }
  .fade-enter-active, .fade-leave-active {
    transition: all .5s;
  }
  ::v-deep .el-tabs__nav-wrap{
    &::after{
      display: none;
    }
  }
  ::v-deep .el-tabs__active-bar{
    width: 20px!important;
    background-color: #4285F4;
    border-radius: 2px;
    height: 3px;
  }
  ::v-deep .el-tabs__item{
    font-size: 18px;
    font-weight: 500;
    color:#979797;
    &.is-active{
      font-weight: 600;
       color:#4285F4;
    }
  }
</style>
