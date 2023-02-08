<template>
  <el-dialog
    :title="title"
    :visible.sync="showInfo"
    width="700px !important"
    :close-on-click-modal="false"
  >
    <el-form ref="form" :model="form" :rules="rules" label-width="80px">
      <el-row>
        <el-form-item label="邮箱账号" prop="email">
          <el-input
            v-model="form.email"
            placeholder="请输入邮箱账号，系统不会记录您的登录密码"
          ></el-input>
          <!-- <input style="width: 0; height: 0; margin: 0; padding:0 ;border: 0; overflow: hidden"> -->
          <!-- <el-input style="position: fixed;bottom:-9999px"></el-input> -->
        </el-form-item>

        <el-form-item label="登录密码" prop="password">
          <!-- <input style="width: 0; height: 0; margin: 0; padding:0 ;border: 0; overflow: hidden"> -->
          <el-input
            type="password"
            v-model="form.password"
            placeholder="请输入登录密码"
            auto-complete="new-password"
          ></el-input>
          <!-- <p style="font-size: 12px; color: #989898">
            提示:系统不会记录您的登录密码
          </p> -->
        </el-form-item>
        <el-form-item label="邮件自动回复" label-width="106px" style="margin-bottom: 6px">
          <el-switch
            v-model="form.enable"
            active-color="#13ce66"
            inactive-color="#ddd"
            :active-text="form.enable ? '开启' : '关闭'"
          >
          </el-switch>
        </el-form-item>
        <el-form-item labelWidth="14px" style="margin-bottom: 10px">
          <el-checkbox v-model="form.enableScheduled" :disabled="!form.enable"
            >只在以下时间范围内答复</el-checkbox
          >
        </el-form-item>
        <el-form-item
          label="开始时间"
          prop="scheduledStartTime"
          label-width="108px"
          :rules="[
            {
              required: form.enableScheduled,
              message: '请选择开始时间',
              trigger: 'blur',
            },
            {
              validator: validateStartTime,
              trigger: 'blur'
            }
          ]"
        >
          <el-date-picker
            clearable
            :disabled="!form.enableScheduled"
            style="width: 100%"
            v-model="form.scheduledStartTime"
            format="yyyy-MM-dd HH:mm:ss"
            value-format="yyyy-MM-dd HH:mm:ss"
            :picker-options="pickerOptions"
            type="datetime"
            placeholder="选择开始时间"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item
          label="结束时间"
          prop="scheduledEndTime"
          label-width="108px"
          :rules="[
            {
              required: form.enableScheduled,
              message: '请选择结束时间',
              trigger: 'blur',
            },
            {
              validator: validateEndTime,
              trigger: 'blur'
            }
          ]"
        >
          <el-date-picker
            clearable
            :disabled="!form.enableScheduled"
            style="width: 100%"
            v-model="form.scheduledEndTime"
            format="yyyy-MM-dd HH:mm:ss"
            value-format="yyyy-MM-dd HH:mm:ss"
            :picker-options="pickerOptions"
            type="datetime"
            placeholder="选择结束时间"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item label="回复模板" style="margin-bottom: 6px">
          <el-tag v-for="(item, index) in autoReplytems" style="margin: 0 10px 10px 0; cursor: pointer" :key="index"
            @click="confirmReply(item.mailTemplateContent)"
          >{{item.mailTemplateTile}}</el-tag>
          <el-tag v-show="!autoReplytems.length" type="warning">暂无回复模板，请联系管理员设置</el-tag>
        </el-form-item>
        <el-form-item
          style="margin-bottom: 8px"
          label="回复内容"
          prop="internalRepl"
          :rules="[
            {
              required: form.enable,
              message: '请输入回复内容',
              trigger: 'blur',
            },
          ]"
        >
          <el-input
            type="textarea"
            :disabled="!form.enable"
            rows="8"
            v-model="form.internalRepl"
            :placeholder="form.enable ? '请输入回复内容' : ''"
          ></el-input>
          <!-- <p style="font-size: 12px;color: #989898">提示:行内发的邮件自动回复内容</p> -->
          <!-- <div class="comTemple" @click="openInner">常用模板</div> -->
        </el-form-item>
      </el-row>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="cancel">取 消</el-button>
      <el-button type="primary" :loading="submitLoading" @click="submit"
        >保存</el-button
      >
    </div>
  </el-dialog>
</template>

<script>
import {getInfo} from "@/api/login";
import { getConfigKey } from "@/api/home/config";
import { my, add, update } from "@/api/console/system/autoReply";
import {clientEncrypt} from '@/utils/jsencrypt';
export default {
  name: "autoReply",
  data() {
    const validateStartTime = (rule, value, callback) => {
      if (value) {
        console.log(value)
        const now = new Date().format('yyyy-MM-dd hh:mm') + ':00'
        console.log('now', now)
        if (value < now) {
          callback(new Error("开始时间必须大于当前时间！"));
        } else {
          callback();
        }
      } else {
        if (this.form.enableScheduled) {
          callback(new Error("请选择自动回复开始时间！"));
        } else {
          callback()
        }
      }
    };
    const validateEndTime = (rule, value, callback) => {
      if (value) {
        console.log(value)
        const start = this.form.scheduledStartTime
        console.log('start', start)
        if (start && value <= start) {
          callback(new Error("结束时间必须大于开始时间！"));
        } else {
          callback();
        }
      } else {
        if (this.form.enableScheduled) {
          callback(new Error("请选择自动回复结束时间！"));
        } else {
          callback()
        }
      }
    };
    return {
      validateStartTime, // 开始时间检验规则
      validateEndTime, // 结束时间检验规则
      form: {
        email: '',
        enableScheduled: false
      },
      title: "",
      showInfo: false,
      innerVisible: false,
      autoReplytems: [],
      submitLoading: false, // 提交按钮加载动画
      // 表单校验
      rules: {
        email: [
          { required: true, message: "请输入邮箱账号", trigger: "blur" },
          {
            validator: function (rule, value, callback) {
              if (
                /^\w{1,64}@[a-z0-9\-]{1,256}(\.[a-z]{2,6}){1,2}$/i.test(
                  value
                ) == false
              ) {
                callback(new Error("邮箱格式错误"));
              } else {
                callback();
              }
            },
            trigger: "blur",
          },
        ],
        password: [
          { required: true, message: "请输入邮箱登录密码", trigger: "blur" },
        ],
      },
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now() - 8.64e7; //如果没有后面的-8.64e7就是不可以选择今天的
        },
      },
    };
  },
  watch: {
    "form.enable"(val) {
      if (!val) {
        // this.form.enableScheduled = false;
        this.$set(this.form, 'enableScheduled', false)
      }
    },
  },
  mounted() {
  },
  methods: {
     /***********************
     * @function getInfo
     * @desc 获取当前用户信息
     */
    getUserInfo () {
      getInfo().then(resp => {
        if (resp.code === 200) {
          this.$set(this.form, 'email', resp.user.email)
        }
      })
    },
    /*************************
     * @desc 打开常用模板弹框
     * @function openInner
     */
    openInner() {
      if (this.autoReplytems.length) {
        this.innerVisible = true;
      } else {
        this.msgWarning("暂无常用模板，请联系管理员设置");
      }
    },
    /****************
     * @desc 获取常用模板的数据字典
     * @function
     */
    queryDict() {
      getConfigKey("AUTH_REPLY_CONTENTS").then((response) => {
        if (response.msg) {
          const data = JSON.parse(response.msg);
          this.autoReplytems = data;
        }
      });
    },
    /***************
     * @desc 确定选中的自动回复
     * @function confirmReply
     */
    confirmReply(item) {
      if (this.form.enable) {
        this.$set(this.form, "internalRepl", item);
      }
    },
    load() {
      this.getUserInfo()
      this.queryDict();
      this.form = {};
      my().then((response) => {
        if (response.data) {
          this.form = response.data;
          Object.keys(response.data).forEach(k => {
           if (k !== 'email') {
              // this.form[k] = response.data[k]
              this.$set(this.form, k, response.data[k])
            }
          })
        }
      });
      this.title = "设置自动邮件回复";
      if (this.$refs["form"] !== undefined) {
        this.$refs["form"].resetFields();
      }

      this.showInfo = true;
    },
    cancel() {
      this.showInfo = false;
      this.form = {};
    },
    submit() {
      // if(this.form.enable) {
      //   console.log(this.form.internalRepl, 'this.form.internalRepl')
      //   if (this.form.internalRepl === '') {
      //     this.msgWarning('行内回复内容不能为空!')
      //     return;
      //   }
      // }
      if (this.submitLoading) {
        return;
      }
      if (this.form.scheduledEndTime <= this.form.scheduledStartTime) {
        this.msgWarning("自动答复结束时间须晚于自动答复开始时间");
        return;
      }
      let param = {
        email: this.form.email,
        password: clientEncrypt(this.form.password),
        enable: this.form.enable || false,
        enableScheduled: this.form.enableScheduled || false,
      };
      if (this.form.enable) {
        param.internalRepl = this.form.internalRepl;
      }
      if (this.form.enableScheduled) {
        param.scheduledStartTime = this.form.scheduledStartTime;
        param.scheduledEndTime = this.form.scheduledEndTime;
      }
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.submitLoading = true;
          if (this.form.id !== undefined) {
            update({
              id: this.form.id,
              ...param,
            }).then((response) => {
              this.submitLoading = false;
              if (response.code === 200) {
                this.msgSuccess("操作成功");
                this.cancel();
              } else {
                this.msgWarning(response.msg);
              }
            });
          } else {
            add(param).then((response) => {
              this.submitLoading = false;
              if (response.code === 200) {
                this.msgSuccess("操作成功");
                this.cancel();
              } else {
                this.msgWarning(response.msg);
              }
            });
          }
        }
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.comTemple {
  text-align: right;
  color: #2272de;
  cursor: pointer;
}
::v-deep .el-dialog{
  .el-dialog__header{
    padding: 16px 20PX;
  }
  .el-dialog__body{
    padding: 0 20px;
  }
}
</style>
