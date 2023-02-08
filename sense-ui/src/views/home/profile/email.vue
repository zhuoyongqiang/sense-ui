<template>
  <el-dialog
    :title="title"
    :visible.sync="data.show"
    width="80% !important"
    :close-on-click-modal="false"
  >
    <el-form ref="form" :model="form" :rules="rules" label-width="120px" :disabled="loading">
      <el-row>
        <el-col :span="10">
          <el-form-item label="邮箱账号" prop="email_send_username" label-width="120px">
            <el-input v-model="form.email_send_username" :placeholder="!!form.id ? '' : '请输入'" clearable></el-input>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="10">
          <el-form-item label="邮箱密码" prop="email_send_password" label-width="120px">
            <el-input type="password" v-model="form.email_send_password" placeholder="请输入" autocomplete="new-password" clearable></el-input>
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="收件人" prop="sendEmailText" label-width="120px">
      <el-input type="textarea" autosize v-model="form.sendEmailText" :placeholder="!!form.id ? '' : '请选择'" readonly unselectable="on" @click.native="openFindGroup('1')"> <i
        class="el-icon-search"
        slot="suffix"
        resize="none"
        @click="openFindGroup('1')">
      </i></el-input>
      </el-form-item>
      <el-form-item label="抄送人" label-width="120px">
        <el-input type="textarea" autosize v-model="form.sendCCEmailText" :placeholder="!!form.id ? '' : '请选择'" readonly unselectable="on" @click.native="openFindGroup('2')"> <i
          class="el-icon-search"
          slot="suffix"
          @click="openFindGroup('2')">
        </i></el-input>
      </el-form-item>
      <el-form-item label="邮件主题" prop="emailTheme" label-width="120px">
        <el-input v-model="form.emailTheme"/>
      </el-form-item>
      <el-form-item label="邮件内容" prop="emailContent" label-width="120px">
        <el-input type="textarea" :rows="12" v-model="form.emailContent"></el-input>
      </el-form-item>
      <el-form-item style="text-align: center" class="button-panel">
        <el-button type="primary" @click="submit" :loading="loading">确认</el-button>
        <el-button @click="cancel">返回</el-button>
      </el-form-item>
    </el-form>
    <!-- 机构选择树 -->
    <findGroup ref="findGroup" @confirm="confirm"></findGroup>
    <!-- <component ref="findGroup" :is="findGroupName" @confirm="confirm"></component> -->
  </el-dialog>
</template>
<script>
import findGroup from "@/views/home/profile/profile/findGroup";
import { sendEmail } from "@/api/console/layout/workentrust";
import {clientEncrypt} from '@/utils/jsencrypt';
// const findGroup = resolve =>require(['@/views/home/profile/profile/findGroup'], resolve)
export default {
  props: {
    data: {
      type: Object,
      require: true
    }
  },
  components: {findGroup},
  data() {
    return {
      loading: false, // 加载动画
      findGroupName: '',
      title: '发送邮件',
      form: {
        email_send_username: null, // 邮箱账号
        email_send_password: null, // 邮箱密码
        sendEmailText: null, // 收件人
        sendEmailAddressList: [], // 收件人邮箱
        sendCCEmailText: null, // 抄送人
        sendCCEmailAddressList: [], // 抄送人邮箱
        emailTheme: null, // 邮件主题
        emailContent: null, // 邮件内容
      },
      checkeds: {}, // 存储选中项
      rules: {
        email_send_username: [
          { required: true, message: "请输入邮箱账号", trigger: "blur" }
        ],
        email_send_password: [
          { required: true, message: "请输入邮箱密码", trigger: "blur" }
        ],
        sendEmailText: [
          { required: true, message: "请选择收件人", trigger: "blur" }
        ],
        emailTheme: [
          { required: true, message: "请填写邮件主题", trigger: "blur" }
        ],
        emailContent: [
          { required: true, message: "请填写邮件内容", trigger: "blur" }
        ]
      }
    }
  },
  mounted() {
    this.form.email_send_username = this.$store.state.user.email
  },
  methods: {
    openFindGroup(type){
      if (this.loading) return
      this.$nextTick(function () {
        this.$refs.findGroup.show(type)
      })
    },
    // 弹框关闭事件
    cancel () {
      this.data.show = false
    },
    // 弹框确定事件
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.loading = true
          const {
            email_send_username,
            email_send_password,
            sendEmailAddressList,
            sendCCEmailAddressList,
            emailTheme,
            emailContent
          } = this.form
          const params = {
            email_send_username,
            email_send_password: clientEncrypt(email_send_password),
            sendEmailAddressList,
            sendCCEmailAddressList,
            emailTheme,
            emailContent
          }
          console.log('============发送邮件============')
          console.warn(params)
          sendEmail(params).then(resp => {
            this.loading = false
            if (resp.code === 200) {
              this.$message.success('发送成功')
            } else {
              this.$message.error(resp.msg)
            }
          }).catch(err => {
            this.loading = false
            this.$message.error('发送失败')
            console.log('发送邮件失败：', err)
          })
        } else {
          console.log('error submit!!');
          return false;
        }
      });
    },
    // 人员选择器确定事件
    /**************
     * @param text 拼接的名称+邮箱地址，展示用
     * @param grouptype 人员选择器类别，1: 收件人，2：抄送人
     * @param data 选中的人员
     */
    confirm (grouptype, data) {
      console.log(grouptype)
      console.log(typeof(grouptype))
      console.log(data[grouptype])
      if (grouptype === '1') {
        // 收件人
        if (data[grouptype].length) {
          this.$set(this.form, 'sendEmailText', (data[grouptype].map((m) => `${m.label}<${m.email}>`)).join(';'))
          this.$set(this.form, 'sendEmailAddressList', data[grouptype].map(v => v.email))
          // this.$set(this.checkeds, grouptype, data[grouptype])
          this.$refs.form.validateField('sendEmailText');
        }
      } else if (grouptype === '2') {
        // 抄送人
        if (data[grouptype].length) {
          this.$set(this.form, 'sendCCEmailText', (data[grouptype].map((m) => `${m.label}<${m.email}>`)).join(';'))
          this.$set(this.form, 'sendCCEmailAddressList', data[grouptype].map(v => v.email))
          // this.$set(this.checkeds, grouptype, data[grouptype])
           this.$refs.form.validateField('sendCCEmailText');
        }
      }
    },
  },
}
</script>
<style lang="scss" scoped>
  ::v-deep .el-dialog{
    .button-panel{
      .el-button{
        width: 96px;
        height: 40px;
        font-size: 14px;
        font-weight: 400;
        margin: 0 12px;
        &.el-button--default{
          background-color: #F5F7FA;
          color: #909399;
          &:hover{
            border-color: #DCDFE6;
            opacity: .8;
          }
        }
      }
    }
  }
</style>