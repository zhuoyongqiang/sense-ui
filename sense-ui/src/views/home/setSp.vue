<template>
  <div class="wrapper">
    <navbar currentPage="密保设置" :hasBack="false"></navbar>
    <div class="main">
      <el-form ref="quesform" label-width="78px" :model="quesform" :rules="rules" >
        <el-form-item label="问题：">
          <el-select v-model="quesform.spId" placeholder="请选择" style="width:100%">
            <el-option
              v-for="item in quesList"
              :key="item.id"
              :label="item.name"
              :value="item.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="答案：" prop="spValue">
          <el-input v-model="quesform.spValue" style="width:100%" clearable></el-input>
        </el-form-item>
        <el-form-item class="btn">
          <el-button type="primary" @click="onSubmit">保存</el-button>
          <el-button @click="close">返回</el-button>
        </el-form-item>
      </el-form>
    </div>
	</div>
</template>

<script>
	import { queryAllSp, queryUserSpSet, updateUserSpSet } from "@/api/home/reset";
  import {MessageBox} from 'element-ui'
	import navbar from '@/views/home/component/navbar'
  export default {
    name: "setSpTemplate",
		components: {navbar},
    data() {
      return {
        timer: null,
        countTime: null,
        quesform: {
          spId: "",
          spName:"",
          spValue:"",
				},
				quesList: [],
        // 表单校验
        rules: {
          spValue: [{ required: true, message: "答案不能为空", trigger: "blur" }]
        }
      }
    },
    created() {
			this.userSpSet();
			this.list();
    },
    watch: {
      countTime (val) {
        if (val >= 0) {
          this.$nextTick(() => {
            document.getElementsByClassName('el-message-box__btns')[0].getElementsByTagName('span')[0].innerText = `关闭(${this.countTime})`
          })
        }
      }
    },
    beforeDestroy() {
      clearInterval(this.timer)
    },
    methods: {
      onSubmit() {
        this.$refs["quesform"].validate(valid => {
          if (valid) {
						updateUserSpSet(this.quesform).then((res) => {
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
                MessageBox.confirm('保存成功', '提示', {
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
                });
                // this.$alert('保存成功', '提示', {
                //   confirmButtonText: `关闭(${this.countTime})`,
                //   closeOnPressEscape: true,
                //   callback: action => {
                //     self.close();
                //   }
                // })
							} else {
								this.msgError(res.msg);
							}
						})
          }
        });
			},
			list() {
				queryAllSp().then((res) => {
					if (res.code == 200) {
						this.quesList = res.data;
					} else {
						this.msgError(res.msg);
					}
				})
			},
			userSpSet() {
				queryUserSpSet().then((res) => {
					if (res.code == 200) {
						if (res.data != null && res.data.length > 0) {
							this.quesform.spId = res.data[0].spId;
							this.quesform.spName = res.data[0].spName;
							this.quesform.spValue = res.data[0].value;
						}
					} else {
						this.msgError(res.msg);
					}
				})
			},
      close() {
        this.$router.push('/home/index')
      }
    },
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
    display: flex;
    justify-content: center;
    .el-form{
      width: 450px;
      font-size: 14px;
    }
    ::v-deep .el-form-item {
      margin-bottom: 24px;
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
      .el-form-item__content{
        align-items: center;
        width: 360px;
        >div{
          margin-right: 0!important;
        }
      }
    }
    .btn{
      margin-bottom: 24px;
      ::v-deep .el-form-item__content{
        text-align: center;
        .el-button{
          font-size: 14px;
          width: 96px;
          height: 40px;
          margin: 0 8px;
          font-weight: 400;
          border-radius: 4px;
          &.el-button--primary{
            background-color: #2272DE;
          }
          &.el-button--default{
            background-color: #F5F7FA;
            color: #909399;
          }
        }
      }
    }
  }
</style>
