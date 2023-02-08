<template>
  <div class="wrapper">
    <navbar currentPage="设置密码"></navbar>
    <div class="main">
      <!-- <el-steps :active="active" align-center>
        <el-step title="填写域登录名" @click.native="jump(0)"></el-step>
        <el-step title="重置方式" @click.native="jump(1)"></el-step>
        <el-step title="验证" @click.native="jump(2)"></el-step>
        <el-step :title="active === 3 && resetMethod === 'emailReset' ? '邮箱验证' : '设置密码' " @click.native="jump(3)"></el-step>
        <el-step title="完成" @click.native="jump(4)"></el-step>
      </el-steps> -->
      <div class="step">
        <div class="step-item" :class="{'active': active === 0}">
          <div class="step-line"><div class="step-num">1</div></div>
          <div class="step-text">填写域登录名</div>
        </div>
        <div class="step-item" :class="{'active': active === 1}">
          <div class="step-line"><div class="step-num">2</div></div>
          <div class="step-text">重置方式</div>
        </div>
        <div class="step-item" :class="{'active': active === 2}">
          <div class="step-line"><div class="step-num">3</div></div>
          <div class="step-text">验证</div>
        </div>
        <div class="step-item" :class="{'active': active === 3}">
          <div class="step-line"><div class="step-num">4</div></div>
          <div class="step-text">{{resetMethod === 'emailReset' ? '邮箱验证' : '设置密码'}}</div>
        </div>
        <div class="step-item" :class="{'active': active === 4}" v-show="resetMethod !== 'emailReset'">
          <div class="step-line"><div class="step-num">5</div></div>
          <div class="step-text">完成</div>
        </div>
      </div>
      <div class="container">
        
        <!-- 域登录名 -->
        <el-form ref="firstStepform" class="firstStepform inputform" :rules="firstStepRules" label-width="80px" :model="firstStepform" v-show="active === 0" @submit.native.prevent>
          <el-form-item label="域登录名" prop="name">
            <el-input v-model="firstStepform.name" style="width:360px" placeholder="请输入"></el-input>
          </el-form-item>
        </el-form>

        <!-- 重置方式 -->
        <div class="panel-container"  v-show="active === 1">
          <div class="panel" :class="{'disabled': isHideSp}" @click="resetMethods('quesReset', isHideSp)">
            <div class="title"><img src="../../assets/images/home/reset/safeQ.png"> 密保重置<span v-show="isHideSp">(未设置)</span><div class="choose-area"><i :class="`el-icon-${resetMethod === 'quesReset' ? 'success' : 'circle'}`"></i></div></div>
            <div class="desc">通过账号设置密码问题重置密码</div>
          </div>
          <div class="panel" :class="{'disabled': isHideMobile}" @click="resetMethods('mobileReset', isHideMobile)">
            <div class="title"><img src="../../assets/images/home/reset/mobile.png">手机号重置<span v-show="isHideMobile">(未设置)</span><div class="choose-area"><i :class="`el-icon-${resetMethod === 'mobileReset' ? 'success' : 'circle'}`"></i></div></div>
            <div class="desc">通过接收手机验证码方式重置密码</div>
          </div>
					<div class="panel" :class="{'disabled': isHideEmail}" @click="resetMethods('emailReset', isHideEmail)">
            <div class="title"><img src="../../assets/images/home/reset/email.png">邮箱重置<span v-show="isHideEmail">(未设置)</span><div class="choose-area"><i :class="`el-icon-${resetMethod === 'emailReset' ? 'success' : 'circle'}`"></i></div></div>
            <div class="desc">通过接收邮件方式重置密码</div>
          </div>
        </div>

        <!-- 密保问题 -->
        <div class="white-panelContainer quesPanel" v-show="active === 2 && resetMethod === 'quesReset'">
          <el-form ref="quesform" style="width: 100%" :rules="quesRules" label-width="80px" :model="quesform" @submit.native.prevent>
            <div class="quesTitle">问题：{{quesform.questTitle}}</div>
            <el-form-item prop="questResult">
              <el-input v-model="quesform.questResult" placeholder="请回答" style="width: 402px" clearable></el-input>
            </el-form-item>
          </el-form>
        </div>
        

        <!-- 手机号重置 -->
        <div class="white-panelContainer mobilePanel" v-show="active === 2 && resetMethod === 'mobileReset'">
          <el-form ref="smsform" :rules="smsRules" label-width="92px" :model="smsform" @submit.native.prevent>
            <el-form-item label="手机号" prop="mobile">
              <el-input readonly disabled v-model="smsform.mobile"></el-input>
            </el-form-item>
            <el-form-item label="图形验证码" prop="imgcode">
              <el-input v-model="smsform.imgcode"></el-input>
              <div class="imgCode-panel"><img class="imgCode" :src="imgSrc" @click="getImageCode"></div>
            </el-form-item>
            <el-form-item label="短信验证码" prop="smscode">
              <el-input v-model="smsform.smscode"></el-input>
              <el-button class="countBtn" @click="getSmscode">{{0 >= count ? '获取验证码' : `${count}秒`}}</el-button>
            </el-form-item>
          </el-form>
        </div>
        
				<!-- 邮箱重置 -->
        <el-form ref="emailform" :rules="emailRules" label-width="120px" :model="emailform" @submit.native.prevent
					v-show="active === 2 && resetMethod === 'emailReset'">
          <el-form-item label="邮箱" prop="email">
            <el-input readonly disabled v-model="emailform.email" style="width:240px"></el-input>
          </el-form-item>
          <el-form-item label="图形验证码" prop="imgcode">
            <el-input v-model="emailform.imgcode" style="width:240px"></el-input>
            <img class="imgCode" :src="imgSrc" @click="getImageCode">
          </el-form-item>
        </el-form>

				<!-- 设置密码验证 -->
        <div class="white-panelContainer setPwdPanel">
          <el-form ref="fourStepform" :rules="fourStepRules" label-width="78px" :model="fourStepform" @submit.native.prevent
            v-show="active === 3 && resetMethod != 'emailReset'">
            <el-form-item label="新密码" prop="pwd" :show-message="!needrules" :style="{'margin-bottom': needrules ? '6px' : '18px'}">
              <el-input type="password" v-model="fourStepform.pwd" autocomplete="off" style="width:360px" show-password></el-input>
            </el-form-item>
            <el-form-item class="line-item" v-show="needrules">
              <div class="pwdsafe">
                <div class="line">
                  <div class="active" :style="setActive.style"></div>
                </div>
                <div class="text">{{setActive.text}}</div>
              </div>
              <ul>
                <li v-for="item in pwdRules" :key="item.id"><i :style="{'opacity': opacity ? 0 : 1}" :class="`el-icon-${item.checked ? 'success' : 'error'}`"></i>{{item.label}}</li>
              </ul>
            </el-form-item>
            <el-form-item label="确认密码" prop="secpwd">
              <el-input type="password" v-model="fourStepform.secpwd" autocomplete="off" show-password style="width: 360px"></el-input>
            </el-form-item>
          </el-form>
        </div>
        

        <!-- 邮箱验证 -->
				<div style="text-align:center" v-show="active === 3 && resetMethod === 'emailReset'">
        	<!-- <i class="el-icon-success" style="color:#1890ff"></i>&nbsp;<span>邮件已发送，请进入邮箱修改密码！</span><span class="reLogin" @click="toLogin">登录</span> -->
        	<i class="el-icon-success" style="color:#1890ff"></i>&nbsp;<span>邮件已发送，请进入邮箱修改密码！</span>
      	</div>

         <!-- 重置完成 -->

          <div class="finishedPanel" v-show="active === 4">
            <div><img src="../../assets/images/home/reset/success.png"></div>
            <div>恭喜，密码重置成功！</div>
            <!-- <i class="el-icon-success" style="color:#1890ff"></i>&nbsp;<span>密码重置完成，</span><span class="reLogin" @click="toLogin">重新登录</span> -->
          </div>
      </div>

     
			<!-- [0, 2, 3].includes(active) -->
      <!-- <div class="button" v-show="active === 0 || active === 2 || (active === 3 && resetMethod != 'emailReset')"> -->
      <div class="button">
        <el-button type="primary" @click="prev" v-show="active !== 0 && active !==3 && active !== 4" plain>上一步</el-button>
        <el-button type="primary" @click="next" :loading="loading">{{active === 4 || (active === 3 && resetMethod === 'emailReset')? '去登录' : '下一步'}}</el-button>
      </div>
    </div>
  </div>
</template>
<script>
import {checkStaffAccount, checkPwdSet, getVerifiCode, verifiCode, sendCode, checkSmsCode, sendEmail, checkEmailUrl, setPwd} from "@/api/home/reset";
import navbar from '@/views/home/component/navbar'
import { findBlack, userWhite } from "@/api/home/iam"
import * as rules from '@/utils/validate'
export default {
  components: {navbar},
  data () {
    var validateImgcode = async (rule, value, callback) => {
      if (value) {
        try {
          const res = await this.checkImgcode()
          if (res === '200') {
            callback();
          } else {
            callback(new Error(res))
          }
        } catch (err) {
          callback(new Error(err))
        }
      }
    };
    var validatesecpwd = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入新密码'));
      } else {
        if (value !== this.fourStepform.pwd) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }
    }
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
      loading: false,
      opacity: true,
      active: 0, // 激活的步骤条
			mobile: '', // 手机号
			email: '', //邮箱
      resetMethod: '', // 重置方式
      isHideMobile: true,	//是否展示手机重置
			isHideSp: true,			//是否展示密保重置
			isHideEmail: true,  //是否展示邮件重置
			global: '',
			imgSrc: '',
      firstStepform: { // 域登录名
        name: ''
      },
      firstStepRules: { // 域登录名输入规则
        name: [{ required: true, message: '请输入域登录名', trigger: 'blur' }]
      },
      quesform: { // 密保问题表单
				questId: "",
				questTitle: "",
				questResult: ""
      },
      quesRules: { // 密保问题规则
        questResult: [
          { required: true, message: '密保答案不能为空', trigger: 'blur' }
        ]
      },
      smsform: { // 手机号重置表单
        mobile: '',
        imgcode: '',
        smscode: ''
      },
      smsRules: { // 手机号重置规则
        mobile: [
          { required: true, message: '手机号缺失', trigger: 'blur' }
        ],
        imgcode: [
          { required: true, message: '请输入图片验证码', trigger: 'blur' },
          { validator: validateImgcode, trigger: 'blur' }
        ],
        smscode: [{ required: true, message: '请输入短信验证码', trigger: 'blur' }]
			},
			emailform: { // 邮件重置表单
        email: '',
        imgcode: ''
      },
      emailRules: { // 手机号重置规则
        email: [
          { required: true, message: '邮箱缺失', trigger: 'blur' }
        ],
        imgcode: [
          { required: true, message: '请输入图片验证码', trigger: 'blur' }
        ]
      },
      timer: null, // 计时器
      count: -1, // 倒计时
      fourStepform: { // 密码
        pwd: '',
        secpwd: ''
      },
      fourStepRules: { // 密码规则
        pwd: [
          { required: true, message: "新密码不能为空", trigger: "blur" },
          { required: true, message: "新密码不能为空", trigger: "change" },
          { required: true, validator: checkpwd, trigger: "change" },
        ],
        secpwd: [
          { required: true, message: '请再次输入新密码', trigger: 'blur' },
          { validator: validatesecpwd, trigger: 'blur' }
        ]
      },
      needrules: false, // 是否需要校验密码规则
      blackwordlist: [], // 黑名单
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
      ],
      setActive: {
        style: {
          width: '33.3%',
          backgroundColor: '#FF5555'
        },
        text: '密码强度较低'
      },
    }
	},
	created() {
    this.queryBlacks()
	},
  beforeDestroy() {
    document.onkeydown = null
  },
  watch: {
    'fourStepform.pwd' () {
      this.opacity = false
    }
  },
	mounted() {
    var lett = this;
		document.onkeydown = function(e) {
			var key = window.event.keyCode;
			if (key == 13) {
				lett.next();
			}
		}
    if (this.$route.query && this.$route.query.token) {
				var data = {};
					data.global = this.$route.query.token;
					checkEmailUrl(data).then((res) => {
						if (res.code == 200) {
							this.global = res.global;
							this.active = 3;
						} else {
							this.msgError(res.msg);
							setTimeout(function(){
								location.href = "/home/reset";
							},3000)
						}
					})
      }
  },
  methods: {
    // 获取白名单用户
    queryUserWhites () {
      userWhite().then(resp => {
        if (resp.code === 200) {
          if (resp.data.data.some(v => v.STAFF_ACCOUNT === this.firstStepform.name)) {
            this.needrules = false
          } else {
            this.needrules = true
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
            return true
          }
        } else if (this.blackwordlist[i].IS_IGNORE_CASE === '2' && this.blackwordlist[i].IS_FULL === '1') {
          if (value === this.blackwordlist[i].PASSWD) {
            return true
          }
        } else if (this.blackwordlist[i].IS_IGNORE_CASE === '1' && this.blackwordlist[i].IS_FULL === '2') {
          if (value.toLowerCase().includes(this.blackwordlist[i].PASSWD.toLowerCase())) {
            return true
          }
        } else if (this.blackwordlist[i].IS_IGNORE_CASE === '2' && this.blackwordlist[i].IS_FULL === '2') {
          if (value.includes(this.blackwordlist[i].PASSWD)) {
            return true
          }
        }
      }
    },
    // 密码强度检测
      checkpwd (pwd) {
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
    // 步骤条-点击跳转
    jump (step) {
      if (this.active <= step) return
      this.active = step
    },
    prev() {
      this.active--
    },
    // 下一步
    next () {
      console.log(this.active)
      if (this.loading) {
        return
      }
      this.loading = true
      switch (this.active) {
        case 0:
          // 重置第一步，填写域登录名
          this.$refs.firstStepform.validate((valid) => {
            if (valid) {
							checkStaffAccount(this.firstStepform.name).then((res) => {
								if (res.code == 200) {
									this.global = res.global;
									if (res.pwdset == 0) {
										this.isHideSp = true;
									} else {
										this.isHideSp = false;
										this.quesform.questId = res.dataset.id;
										this.quesform.questTitle = res.dataset.name;
									}
									if (res.ismobile == 0) {
										this.isHideMobile = true;
									} else {
										this.isHideMobile = false;
										this.mobile = res.mobile;
									}
									if (res.isemail == 0) {
										this.isHideEmail = true;
									} else {
										this.isHideEmail = false;
										this.email = res.email;
									}
                  this.resetMethod = ''
                  // 请求用户白名单
                  this.queryUserWhites()
									this.active++;
                  this.loading = false
								} else {
									this.msgError(res.msg);
                  this.loading = false
								}
							})
            } else {
              this.loading = false
              return false
            }
          })
          break
        case 1:
          if (this.resetMethod) {
            this[this.resetMethod]()
          } else {
            this.loading = false
            this.msgError('未选择重置方式')
          }
          break
        case 2:
          this.opacity = true
          // 手动操作校验、展示登录错误信息
          if (this.resetMethod === 'mobileReset') {
            this.$refs.smsform.validate(valid => {
              if (valid) {
								var data = {};
								data.global = this.global;
								data.imgCode = this.smsform.imgcode;
								data.smsCode = this.smsform.smscode;
								checkSmsCode(data).then((res) => {
									if (res.code == 200) {
										this.global = res.global;
										this.active++;
                    this.loading = false
									} else {
                    this.loading = false
										this.msgError(res.msg);
									}
								})
              } else {
                this.loading = false
              }
            })
          } else if (this.resetMethod === 'quesReset') {
            this.$refs.quesform.validate((valid) => {
              if (valid) {
								var data = {};
								data.global = this.global;
								data.staffAccount = this.firstStepform.name;
								data.spId = this.quesform.questId;
								data.spValue = this.quesform.questResult;
								checkPwdSet(data).then((res) => {
									if (res.code == 200) {
										this.global = res.global;
										this.active++;
                    this.loading = false
									} else {
                    this.loading = false
										this.msgError(res.msg);
									}
								})
              } else {
                this.loading = false
              }
            })
          } else if (this.resetMethod === 'emailReset') {
            this.$refs.emailform.validate(valid => {
              if (valid) {
								var data = {};
								data.global = this.global;
								data.imgCode = this.emailform.imgcode;
								sendEmail(data).then((res) => {
									if (res.code == 200) {
										this.active++;
                    this.loading = false
									} else {
                    this.loading = false
										this.msgError(res.msg);
									}
								})
              } else {
                this.loading = false
              }
            })
          }
          break
        case 3:
          if (this.resetMethod === 'emailReset') {
            this.loading = false
            this.toLogin()
          } else {
            this.opacity = false
            this.$refs.fourStepform.validate((valid) => {
              if (valid) {
                var data = {};
                data.global = this.global;
                data.staffAccount = this.firstStepform.name;
                data.newPasswd = this.fourStepform.pwd;
                setPwd(data).then((res) => {
                  if (res.code == 200) {
                    this.global = res.global;
                    this.active++;
                    this.loading = false
                  } else {
                    this.loading = false
                    this.msgError(res.msg);
                  }
                })
              } else {
                this.loading = false
                return false
              }
            })
          }
          break
        case 4:
          this.loading = false
          this.toLogin()
          break
        default:
          break
      }
    },
    // 重置方式选择
    resetMethods (fn, disabled) {
      if (disabled) {
        this.msgError('当前重置方式未设置，无法进行勾选')
        return
      }
      this.resetMethod = fn
      // this[fn]()
    },
    // 密保问题重置
    quesReset () {
			if (this.isHideSp) {
				return;
			}
			this.active++
      this.loading = false
    },
    // 手机号重置
    mobileReset () {
			if (this.isHideMobile) {
				return;
			}
			// 请求图片验证码
			this.getImageCode();
      this.active++
      this.loading = false
      this.$refs.smsform.resetFields()
      this.smsform.mobile = this.mobile
		},
		// 邮件重置
    emailReset () {
			if (this.isHideEmail) {
				return;
			}
			// 请求图片验证码
			this.getImageCode();
      this.active++
      this.loading = false
      this.$refs.emailform.resetFields()
      this.emailform.email = this.email
		},
		getImageCode () {
			var data = {};
			data.global = this.global;
			getVerifiCode(data).then((res) => {
				if (res.code == 200) {
					this.imgSrc = 'data:image/jpeg;base64,' + res.msg;
				} else {
					this.msgError(res.msg);
				}
			})
		},
    // 判断图片验证码是否正确
    checkImgcode () {
      return new Promise((resolve, reject) => {
				var data = {};
				data.global = this.global;
				data.imgCode = this.smsform.imgcode;
				verifiCode(data).then((res) => {
					if (res.code == 200) {
						resolve('200');
					} else {
						resolve(res.msg)
					}
				})
      })
    },
    // 获取验证码
    getSmscode () {
      if (this.count >= 0) {
        return
			}
			var that = this;
      this.$refs.smsform.validateField('imgcode', (err) => {
        if (!err) {
					var data = {};
					data.global = this.global;
					data.imgCode = this.smsform.imgcode;
					sendCode(data).then((res) => {
						if (res.code !== 200) {
              this.count = 60
							that.timer = setInterval(()=>{
								that.count--;
								if (that.count === 0) {
									clearInterval(that.timer);
									that.count = -1;
								}
							},1000)
						} else {
							that.msgError(res.msg);
						}
					})
        }
      })
    },
    // 跳转登录页
    toLogin () {
      this.$router.push("/index");
    }
  }
}
</script>
<style lang="scss" scoped>
  .wrapper{
    padding: 0 68px;
  }
  .main{
    border-radius: 2px;
    background-color: #fff;
    padding: 66px 107px 40px;
  }
  .step{
    display: flex;
    .step-item{
      flex: 1;
      cursor: default;
      user-select: none;
      .step-line{
        height: 10px;
        background-color: #2272DE;
        position: relative;
        opacity: 0.16;
        .step-num{
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background-color: #2272DE;
          border-radius: 50%;
          border: 4px solid #fff;
          width: 29px;
          height: 29px;
          text-align: center;
          line-height: 21px;
          color: #fff;
          font-size: 15px;
          font-weight: 600;
        }
      }
      .step-text{
        margin-top: 25px;
        color: #606266;
        font-weight: 400;
        font-size: 14px;
        text-align: center;
        opacity: 1;
      }
      &:first-child{
        .step-line{
          border-radius: 10px 0 0 10px;
        }
      }
      &:last-child{
        .step-line{
          border-radius: 0 10px 10px 0;
        }
      }
      &:not(:first-child){
        .step-line{
          &::before{
            position: absolute;
            left: 0;
            top: 0;
            width: 10px;
            height: 10px;
            border-width: 5px 10px;
            border-style: solid;
            border-color: transparent transparent transparent #fff;
            content: '';
          }
        }
      }
      &:not(:last-child){
        .step-line{
          &::after{
            position: absolute;
            right: -10px;
            top: 0;
            width: 5px;
            height: 10px;
            border-width: 5px 10px;
            border-style: solid;
            border-color: transparent transparent transparent #2272DE;
            background-color: #fff;
            content: '';
          }
        }
      }
      // 激活样式组
      &.active{
        .step-line{
          opacity: 1;
        }
        .step-text{
          color: #2272DE;
        }
      }
    }
  }

  .container{
    margin: 46px 0 40px;
    width: 100%;
    display: flex;
    justify-content: center;
    ::v-deep .el-form-item {
      .el-form-item__label{
        line-height: 36px;
        color:#303133;
      }
      .el-form-item__content{
        line-height: 36px;
      }
      .el-input{
        font-size: 14px;
      }
      input{
        height: 36px;
        line-height: 36px;
        border-radius: 4px!important;
      }
    }

    >.panel-container{
      >.panel{
        &:not(.disabled){
          &:hover{
            // background-color: rgb(235, 197, 128);
            cursor: pointer;
          }
        }
      }
    }
  }
  .panel-container{
    width: 100%;
  }
  .panel{
    margin: 0 0 16px 0;
    background-color: #F5F6FA;
    border-radius: 2px;
    padding: 16px 16px;
    border-radius: 4px;
    &.disabled{
      background-color: #fafafa;
    }
    .title{
      display: flex;
      align-items: center;
      color:#606266;
      font-size: 14px;
      font-weight: 600;
      height: 20px;
      img{
        width: 16px;
        height: auto;
        margin-right: 8px;
      }
      .choose-area{
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        i{
          color: #2272DE;
          font-size: 20px;
        }
        i.el-icon-circle{
          border-radius: 50%;
          border: 1px solid #2272DE;
          width: 18px;
          height: 18px;
          box-sizing: border-box;
          margin-right: 1px;
        }
      }
    }
    .desc{
      margin-top: 15px;
      font-size: 14px;
      font-weight: 400;
      color: #606266;
    }
  }

  .white-panelContainer{
    margin-top: 16px;
  }

  .quesPanel{
    .quesTitle{
      font-size: 14px;
      color: #303030;
      font-weight: 500;
      margin-bottom: 15px;
    }
  }
  .mobilePanel{
    ::v-deep .el-form-item__content{
      align-items: center;
      width: 360px;
      >div{
        margin-right: 0!important;
      }
    }
    .imgCode-panel{
      // line-height: normal;
      height: 36px;
      margin-left: 9px;
    }
    .imgCode{
      height: 36px;
    }
    .countBtn{
      width: 72px;
      min-width: 72px;
      margin-left: 9px;
      text-align: center;
      padding: 0;
      height: 36px;
      background: #2272DE;
      border-radius: 4px;
      color: #fff;
      font-size: 12px;
    }
  }
  .setPwdPanel{
    .line-item{
      ::v-deep .el-form-item__content{
        display: block;
        padding-left: 78px;
      }
    }
    .pwdsafe{
      line-height: normal;
      display: flex;
      align-items: center;
      margin-top: 4px;
      width: 100%;
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
    ul{
      margin-top: 11px;
      li{
        line-height: normal;
        margin-bottom: 7px;
        list-style: none;
        font-size: 12px;
        color: #A9A9A9;
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
  .finishedPanel{
    text-align: center;
    font-size: 14px;
    color: #303030;
    font-weight: 400;
    img{
      width: 56px;
      height: auto;
      margin-bottom: 16px;
    }
  }
  // .imgCode{
  //   height: 42px;
  // }
  .reLogin{
    color:#1890ff;
    text-decoration: underline;
    cursor: pointer;
  }
  .button{
    text-align: center;
    ::v-deep .el-button{
      width: 96px;
      height: 40px;
      font-size: 14px;
      background-color: #2272DE;
      border-radius: 4px;
      &:active{
        opacity: .8;
      }
      &.is-plain{
        background-color: #E8F0FB;
        color:#2272DE;
        border-color: #A7C7F2;
      }
      margin: 0 10px;
      // &:not(:first-child) {
      //   margin-left: 20px;
      // }
    }
  }
  ::v-deep .el-form-item{
    display: flex;
    align-items: center;
    .el-form-item__content{
      margin-left: 0!important;
      display: flex;
      align-items: center;
      >div{
        margin-right: 16px;
      }
    }
  }
  ::v-deep .el-step__head.is-finish .el-step__icon.is-text{
    // border-color: rgba($color: #1890ff, $alpha: .32);
    border-color: lightblue;
    border-width: 3px;
    background-color: #1890ff;
    color: #fff;
  }
</style>
