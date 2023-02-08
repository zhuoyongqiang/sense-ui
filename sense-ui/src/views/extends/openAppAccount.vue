<template>
  <div class="app-container">
    <el-row :gutter="24" type="flex" justify="space-around">
     <el-col :span="14"  >
      <el-card>
        <h2 style="text-align:center;margin-bottom:20px">开通账号</h2>
        <el-form ref="form" :model="user"  size="small"  label-width="80px">
        <el-col :span="12"  >
          <el-form-item label="工号:"  >
            <el-input class="read_text" readonly v-model="user.staffNo"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="姓名:"   >
            <el-input  class="read_text" readonly v-model="user.nickName"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12"  >
          <el-form-item label="账号:"  prop="account" 
            :rules=" {required: true, message: '请输入账号', trigger: 'blur' }">
            <el-input   v-model="user.account"></el-input>
          </el-form-item>
        </el-col>
          <el-col :span="12"  >
          <el-form-item label="密码:"  prop="password" 
            :rules=" {required: true, message: '请输入密码', trigger: 'blur' }">
            <el-input type="password"  v-model="user.password"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item  label="性别:" prop="sex">
             <el-input  class="read_text" readonly v-model="user.sex"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item  label="手机号:"  >
            <el-input  class="read_text" readonly v-model="user.phonenumber"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item   label="部门:" >
            <el-input  class="read_text" readonly v-model="user.departmentDept.deptName"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
           <el-form-item   label="岗位:"  >
              <el-input  class="read_text" readonly v-model="user.post"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
            <el-form-item   label="单位:"  >
              <el-input  class="read_text" readonly v-model="user.orgDept.deptName"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item   label="应用:"  >
            <el-checkbox-group v-model="checkList" v-if="appList.length>0" style="margin-left:2%">
              <el-checkbox v-for="item in appList" :label="item" :key="item.sn">{{item.name}}</el-checkbox>
            </el-checkbox-group>
            <div v-else class="empty_app" >暂无可开通的应用</div>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item style="text-align:center;" v-if="appList.length>0">
            <el-button type="primary" size="small" @click="submitForm('form')">提交</el-button>
          </el-form-item>
        </el-col>
      </el-form>
      </el-card>
    </el-col>
  </el-row>
  </div>
</template>

<script>
import {getUserByUserName,getNotOpenApp,openAppAccount,create} from '@/api/console/bpm/openAppAccount';
import axios from 'axios';
export default {
  name:"openAppAccount",
  data(){
    return{
      //用户信息
      user:{
        account:undefined,
        password:undefined,
        staffNo:undefined,
        nickName:undefined,
        sex:undefined,
        phonenumber:undefined,
        post:undefined,
        orgDept:{},
        departmentDept:{}
      },
      //表单
      form:{},
      //未开通应用列表
      appList:[],
      //选中列表
      checkList:[],
    }
  },
  created(){
  var name=this.$store.getters.name;
   if(name==null){
     this.$message.error("找不到当前用户");
     return
   }
   //查询当前用户的基础信息
   getUserByUserName({userName:name}).then(resp=>{
      resp.data.sex=resp.data.sex==1 ? '男' : '女';
      this.user=resp.data;
      //获取应用列表
      getNotOpenApp({userSn:resp.data.staffNo}).then(resp=>{
        this.appList=resp.data;
      })
      this.appList.push({sn:"11",name:"测试"})
   })
  },
  methods: {
    submitForm(formName){
      if(this.checkList.length==0){
        this.$message.error("请选择要开通的账号");
        return false;
      }
      this.$refs[formName].validate((valid) => {
        if (valid) {
          let params={
            title:"开通账号申请"
          }
          let data={
            user:this.user,
            apps:this.checkList
          }
          //发起流程
          create(params,data).then(resp=>{
            if(resp.code==200){
               this.$message({
                type: 'success',
                message:"提交成功"
              });
              this.$router.push("/home/commonLink").catch({});
            }
          });
        } else {
          return false;
        }
      });
    },
  },
}
</script>

<style lang="scss" scoped>
.read_text ::v-deep{
  .el-input__inner{
    border: 0 ;
  }
}
.empty_app{
  border-radius: 4px;
  height: 100px;
  line-height: 100px;
  text-align: center;
  width: 100%;
  font-size:18px ;
  color:orangered;
}

</style>