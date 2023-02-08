<template>
  <div class="wrapper">
    <div class="container-wrapper">
      <navbar currentPage="修改密码" :hasBack="false"></navbar>
      <el-row class="main">
        <el-col class="left" :xs="24" :sm="24" :md="needrules ? 12 : 24" v-loading="loading">
          <el-form ref="form" :model="form" :rules="rules" label-width="92px" autocomplete="off">
            <el-form-item prop="staffName">
              <span class="labelNamespan" slot="label">姓名</span>
              <el-input v-model="form.staffName" disabled></el-input>
            </el-form-item>
            <el-form-item prop="oldPasswd">
              <span class="labelNamespan" slot="label">旧密码</span>
              <el-input ref="oldPwdRef" placeholder="请输入" show-password autocomplete="off" v-model="form.oldPasswd"></el-input>
            </el-form-item>
            <el-form-item prop="newPasswd">
              <span class="labelNamespan" slot="label">新密码</span>
              <el-input  ref="newPwdRef" placeholder="请输入" show-password autocomplete="off" v-model="form.newPasswd"></el-input>
              <div class="pwdsafe" v-show="needrules">
                <div class="line">
                  <div class="active" :style="setActive.style"></div>
                </div>
                <div class="text">{{setActive.text}}</div>
              </div>
            </el-form-item>
            <el-form-item label="确认新密码" prop="confirmPasswd">
              <el-input ref="reNewPwdRef" placeholder="请输入" show-password autocomplete="off" v-model="form.confirmPasswd"></el-input>
            </el-form-item>
            <el-form-item class="btn" :class="{'single': !needrules}">
              <el-button type="primary" @click="onSubmit">确认</el-button>
              <el-button @click="close">返回</el-button>
            </el-form-item>
          </el-form>
        </el-col>
        <el-col class="right" v-show="needrules" :xs="24" :sm="24" :md="12">
          <div>
            <div class="title"><i class="el-icon-warning"></i>温馨提示</div>
            <ul>
              <li v-for="item in pwdRules" :key="item.id"><i :style="{'opacity': opacity ? 0 : 1}" :class="`el-icon-${item.checked ? 'success' : 'error'}`"></i>{{item.label}}</li>
            </ul>
          </div>
        </el-col>
      </el-row>
    </div>
	</div>
</template>

<script>
	import { updateUserPwd } from "@/api/console/system/user"; 
  import { findBlack, userWhite } from "@/api/home/iam"
  import {mapGetters} from "vuex";
  import * as rules from '@/utils/validate'
  import navbar from '@/views/home/component/navbar'
  import {MessageBox} from 'element-ui'
  export default {
    name: "updatePwdTemplate",
    components: {navbar},
    data() {
      const equalToPassword = (rule, value, callback) => {
        if (this.form.newPasswd !== value) {
          callback(new Error("两次输入的密码不一致"));
        } else {
          callback();
        }
      };
      const checkpwd = (rule, value, callback) => {
        if (this.needrules) {
          if (this.checkpwd(value)) {
            callback()
          } else {
            callback(new Error("不符合安全的密码策略"))
          }
        } else {
          callback()
        }
      }
      return {
        timer: null,
        countTime: null,
        opacity: true,
        loading: false,
        form: {
          staffName: this.$store.state.user.nickName,
          oldPasswd:"",
          newPasswd:"",
          confirmPasswd:"",
          readonly: true
        },
        setActive: {
          style: {
            width: '33.3%',
            backgroundColor: '#FF5555'
          },
          text: '密码强度较低'
        },
        blackwordlist: [],
        userWhiteList: [],
        // 表单校验
        rules: {
          oldPasswd: [{ required: true, message: "旧密码不能为空", trigger: "blur" }],
          newPasswd: [
            { required: true, message: "新密码不能为空", trigger: "blur" },
            { required: true, message: "新密码不能为空", trigger: "change" },
            { required: true, validator: checkpwd, trigger: "change" }],
          confirmPasswd: [
            { required: true, message: "确认密码不能为空", trigger: "blur" },
            { required: true, validator: equalToPassword, trigger: "blur" }
          ]
        },
        needrules: false,
        pwdRules: [
          {
            label: '新密码长度至少8位，最多32位',
            id: '01',
            checked: false
          },
          {
            label: '必须包含大写字母、小写字母、数字、特殊字符这四类中的三类',
            id: '02',
            checked: false
          },
          {
            label: '禁止包含账户名或账户名中超过两个正向连续字符的部分',
            id: '03',
            checked: false
          },
          {
            label: '禁止使用超过3位的连续字符组合或3位的相同字符组合，如abcd、cdefg、8888等',
            id: '04',
            checked: false
          }
        ]
      }
    },
    created() {
      // 初始请求用户白名单
      this.queryUserWhites()
    },
    mounted() {
    },
    watch: {
      'form.newPasswd' () {
        this.opacity = false
      },
      countTime (val) {
        if (val >= 0) {
          this.$nextTick(() => {
            document.getElementsByClassName('el-message-box__btns')[0].getElementsByTagName('span')[0].innerText = `关闭(${this.countTime})`
          })
        }
      }
    },
    methods: {
      // 获取白名单用户
      queryUserWhites () {
        userWhite().then(resp => {
          if (resp.code === 200) {
            if (resp.data.data.some(v => v.STAFF_ACCOUNT === this.$store.state.user.name)) {
              this.needrules = false
            } else {
              this.needrules = true
              this.queryBlacks()
            }
          } else {
            this.needrules = false
          }
        }).catch(err => {
          this.needrules = false
        })
      },
      // 获取黑名单
      queryBlacks() {
        findBlack().then(resp => {
          if (resp.code === 200) {
            this.blackwordlist = resp.data.data
            if (this.blackwordlist.length) {
              this.pwdRules.push(
                {
                  label: `黑名单方面，禁止包含${this.blackwordlist.map(v => this.detailInfo(v)).join('、') }`,
                  id: '05',
                  checked: false
                },
              )
            }
          } else {
            this.blackwordlist = []
          }
        }).catch(err => {
          this.blackwordlist = []
        })
      },
      detailInfo (item) {
        // IS_IGNORE_CASE   1：忽略大小写  2：不忽略大小写
        // IS_FULL     1：精确匹配   2：部分匹配
        if (item.IS_IGNORE_CASE === '1' && item.IS_FULL === '1') {
          return `${item.PASSWD}(无论大小写、精确匹配)`
        } else if (item.IS_IGNORE_CASE === '2' && item.IS_FULL === '1') {
          return `${item.PASSWD}(精确匹配)`
        } else if (item.IS_IGNORE_CASE === '1' && item.IS_FULL === '2') {
          return `${item.PASSWD}(无论大小写)`
        } else if (item.IS_IGNORE_CASE === '2' && item.IS_FULL === '2') {
          return `${item.PASSWD}`
        }
      },
      // 判断密码内容是否在黑名单中
      inBlackwords (value) {
        for (let i = 0; i < this.blackwordlist.length; i++) {
          // IS_IGNORE_CASE   1：忽略大小写  2：不忽略大小写
          // IS_FULL     1：精确匹配   2：部分匹配
          if (this.blackwordlist[i].IS_IGNORE_CASE === '1' && this.blackwordlist[i].IS_FULL === '1') {
            if (value.toLowerCase() === this.blackwordlist[i].PASSWD.toLowerCase()) {
              console.log('1')
              return true
            }
          } else if (this.blackwordlist[i].IS_IGNORE_CASE === '2' && this.blackwordlist[i].IS_FULL === '1') {
            if (value === this.blackwordlist[i].PASSWD) {
              console.log('2')
              return true
            }
          } else if (this.blackwordlist[i].IS_IGNORE_CASE === '1' && this.blackwordlist[i].IS_FULL === '2') {
            if (value.toLowerCase().includes(this.blackwordlist[i].PASSWD.toLowerCase())) {
              console.log('3')
              return true
            }
          } else if (this.blackwordlist[i].IS_IGNORE_CASE === '2' && this.blackwordlist[i].IS_FULL === '2') {
            if (value.includes(this.blackwordlist[i].PASSWD)) {
              console.log('4')
              return true
            }
          }
        }
        return false
      },
      // 密码强度检测
      checkpwd (pwd) {
        console.log('check')
        if (!pwd) {
          this.pwdRules.forEach(m => {
            m.checked = false
          })
          return false
        }
        this.pwdRules.forEach(m => {
          switch (true) {
            case m.label.includes('新密码长度至少8位，最多32位'):
              if (rules.limitLength(8, 32, pwd)) {
                m.checked = true
              } else {
                m.checked = false
              }
              break
            case m.label.includes('必须包含大写字母、小写字母、数字、特殊字符这四类中的三类'):
              if (rules.limitContent(pwd, ['REG_NUMBER', 'REG_UPPERCASE', 'REG_LOWERCASE', 'REG_SYMBOL'], 3)) {
                m.checked = true
              } else {
                m.checked = false
              }
              break
            case m.label.includes('禁止包含账户名或账户名中超过两个正向连续字符的部分'):
              if (rules.containsUserName(pwd)) {
                m.checked = true
              } else {
                m.checked = false
              }
              break
            case m.label.includes('禁止使用超过3位的连续字符组合或3位的相同字符组合，如abcd、cdefg、8888等'):
              if (!rules.isContinuousChar(pwd) && !rules._isKeyBoardContinuousChar(pwd)) {
                m.checked = true
              } else {
                m.checked = false
              }
              break
            case m.label.includes('黑名单'):
              if (!this.inBlackwords(pwd)) {
                m.checked = true
              } else {
                m.checked = false
              }
              break
            default:
              break
          }
        })
  
        const activeLen = this.pwdRules.filter(m => m.checked).length
        if (activeLen >= 2) {
          if (activeLen == this.pwdRules.length) {
            this.setActive.style = {
              width: '100%',
              backgroundColor: '#67C23A'
            }
            this.setActive.text = '密码强度高'
            return true
          } else {
            this.setActive.style = {
              width: '66.6%',
              backgroundColor: '#F6BD16'
            }
            this.setActive.text = '密码强度中'
            return false
          }
        } else {
          this.setActive.style = {
            width: '33.3%',
            backgroundColor: '#FF5555'
          }
          this.setActive.text = '密码强度较低'
          return false
        }
      },
      // 提交事件
      onSubmit() {
        this.$refs["form"].validate(valid => {
          if (valid) {
            this.loading = true
            updateUserPwd(this.form.oldPasswd, this.form.newPasswd)
            .then((res) => {
              this.loading = false
              if (res.code == 200) {
                this.countTime = 3
                this.timer = setInterval(() => {
                  if (this.countTime <= 0) {
                    clearInterval(this.timer)
                    MessageBox.close(false)
                    this.close()
                  } else {
                    this.countTime--
                  }
                }, 1000);
                MessageBox.confirm('修改成功', '提示', {
                  confirmButtonText: '关闭',
                  // cancelButtonText: '关闭',
                  showCancelButton: false,
                  type: 'success',
                }).then(() => {
                  MessageBox.close(false)
                  this.close()
                }).catch(() => {
                  MessageBox.close(false)
                  this.close()
                })
                // location.href = "/home/index"
              } else {
                this.loading = false
                this.msgError(res.msg);
              }
            })
            .catch(err => {
              this.loading = false
            })
          }
        });
      },
      close() {
        this.$router.push({ path: "/home/index" });
      },
    },
  }
</script>

<style lang="scss" scoped>
  .wrapper{
    background-color: #F5F6FA;
  }
  .container-wrapper{
    padding: 0 68px;
  }
  .windowTitle2 {
    margin: 0 auto;
    height: 60px;
    // line-height: 60px;
    color: #666666;
    font-size: 12px;
    text-align: right;
  }

  .el-breadcrumb {
    line-height: 60px;
  }
  
  .main{
    background-color: #fff;
    // display: flex;
    // flex-wrap: wrap;
    >div{
      height: calc(100vh * .67);
      min-height: 410px;
      box-sizing: border-box;
      // padding: 60px 80px 40px;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .left{
      .el-form{
        width: 450px;
        ::v-deep .el-form-item{
          &:not(.btn){
            // height: 36px;
            margin-bottom: 24px;
            label, input{
              height: 36px;
              line-height: 36px;
            }
          }
        }
        ::v-deep label{
          color:#303133;
        }
        .pwdsafe{
          display: flex;
          align-items: center;
          margin-top: 4px;
          .line{
            width: 150px;
            height: 7px;
            background: #E9E9E9;
            border-radius: 2px;
            margin-right: 10px;
            position: relative;
            overflow: hidden;
            .active{
              position: absolute;
              top: 0;
              left: 0;
              height: 7px;
              width: 33.3%;
              background-color: red;
            }
          }
          .text{
            color: #C0C4CC;
            font-size: 12px;
          }
        }
        .labelNamespan{
          display: inline-block;
          width: 42px;
          text-align: justify;
          text-align-last: justify;
        }
      }
      .btn{
        ::v-deep .el-form-item__content{
          text-align: right;
        }
        &.single{
          ::v-deep .el-form-item__content{
          text-align: center;
        }
        }
        ::v-deep .el-button{
          font-size: 14px;
          font-weight: 400;
          width: 96px;
          height: 40px;
          border-radius: 4px;
          &.el-button--default{
            background-color: #F5F7FA;
            border: 1px solid #DCDFE6;
            margin-left: 24px;
            color: #909399;
            &:hover, &:active{
              color: #333;
              background-color: rgba($color: #000, $alpha: .1);
            }
          }
        }
      }
    }
    .right{
      background-color: #FEFBF2;
      .title{
        font-size: 14px;
        font-weight: 600;
        color: #FFB426;
        i{
          margin-right: 6px;
          font-size: 16px;
        }
      }
      ul{
        margin-top: 11px;
        padding-left: 20px;
        li{
          margin-bottom: 7px;
          list-style: none;
          font-size: 12px;
          color: #828282;
          display: flex;
          align-items: center;
          i{
            font-size: 14px;
            margin-right: 4px;
            vertical-align: top;
          }
          .el-icon-error{
            color: #FF5555;
          }
          .el-icon-success{
            color: #67C23A;
          }
        }
      }
    }
  }
//   .windowTitle2 {
//     margin: 0 auto;
//     height: 60px;
//     line-height: 60px;
//     color: #666666;
//     font-size: 12px;
//     text-align: right;
//   }

//   .windowTitle2, .todoMain {
//     max-width: 1180px;
//     margin: 0 auto;
//     position: relative;
//     top: 0;
//   }

// .windowTemplate {
//   min-width: 1280px;
//   background: #ffffff;
// }

// .windowTitle {
//   margin: 0 auto;
//   height: 60px;
//   line-height: 60px;
//   color: #666666;
//   font-size: 12px;
//   text-align: right;
// }

// .windowTitle, .todoMain {
//   max-width: 1180px;
//   margin: 0 auto;
//   position: relative;
//   top: 0;
// }

// .todoMain {
//   margin-top: 0px;
//   margin-bottom: 40px;
//   position: relative;
//   top: 0;
// }

// .search {
//   position: absolute;
//   top: 0;
//   right: 0;
//   z-index: 111111;
// }

// .search .el-input__icon {
//   line-height: 32px;
// }

// .page {
//   margin-top: 12px;
//   margin-bottom: 15px;
// }

// .el-breadcrumb {
//   line-height: 60px;
// }

// .pwdPolicTips li {
//   list-style: none;
//   margin-right: 5px;
//   padding-top: 10px;
// }

</style>
