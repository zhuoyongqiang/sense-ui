<template>
<div class="app-container" id="content_html">
    <el-row :gutter="24" type="flex" justify="space-around">
     <el-col :span="14"  >
      <el-card>
        <h2 style="text-align:center;margin-bottom:20px">注册用户</h2>
        <el-form ref="form" :model="user"  size="small" label-width="100px">
          <el-form-item label="工号:"  prop="staffNo" 
            :rules=" {required: true, message: '请输入工号', trigger: 'blur' }">
            <el-input   v-model="user.staffNo"></el-input>
          </el-form-item>
          <el-form-item label="姓名:"  prop="nickName" 
            :rules=" {required: true, message: '请输入姓名', trigger: 'blur' }">
            <el-input   v-model="user.nickName"></el-input>
          </el-form-item>
          <el-form-item  label="性别:" prop="sex"
            :rules=" {required: true, message: '请输入性别', trigger: 'blur' }">
            <el-radio v-model="user.sex"  label="1">男</el-radio>
            <el-radio v-model="user.sex" label="2">女</el-radio>
          </el-form-item>
          <el-form-item  label="手机号:"  prop="phonenumber" 
            :rules=" {required: true, message: '请输入手机号', trigger: 'blur' }">
            <el-input  v-model="user.phonenumber"></el-input>
          </el-form-item>
          <el-form-item   label="邮箱:"  prop="email" >
            <el-input   v-model="user.email"></el-input>
          </el-form-item>
          <el-form-item   label="部门:"  prop="departmentCodeId" 
            :rules=" {required: true, message: '请选择部门', trigger: 'blur' }">
            <div class="block">
              <el-cascader
                v-model="user.departmentCodeId"
                style="width:100%"
                :options="departments"
                filterable
                :props="{ expandTrigger: 'hover' ,multiple: false, value:'id',emitPath:false}"
              ></el-cascader>
            </div>
          </el-form-item>
          <el-form-item   label="岗位:"  prop="postCode" 
            :rules=" {required: true, message: '请选择岗位', trigger: 'blur' }">
             <el-select style="width:100%" v-model="user.postCode"  placeholder="请选择">
                <el-option
                  v-for="item in posts"
                  :key="item.postCode"
                  :label="item.postName"
                  :value="item.postCode"
                ></el-option>
              </el-select>
          </el-form-item>
          <el-form-item style="text-align:center">
            <el-button type="primary" size="small" @click="submitForm('form')">提交</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </el-col>
  </el-row>
  </div>
</template>
<script>
import {treeselect} from "@/api/console/system/dept";
import { optionselect } from "@/api/console/system/post";
import { optionRoleselect } from "@/api/console/system/role";
import {openAppAccount,create} from '@/api/console/bpm/applyUser';
export default {
  name:"bpmApplyUser",
  data(){
    return{
      //用户信息
      user:{
        staffNo:undefined,
        nickName:undefined,
        sex:'1',
        phonenumber:undefined,
        email:undefined,
        departmentCodeId:undefined,
        postCode:undefined,
        roleIds:[],
      },
      //部门集合
      departments:[],
      //岗位集合
      posts:[],
      //角色集合
      roles:[],

    }
  },
  created(){
    //部门列表
    treeselect().then(resp => {
      this.departments = resp.data;
    });
    //岗位列表
    optionselect().then(resp=>{
      this.posts=resp.data
    })
     //角色列表
    optionRoleselect().then(resp=>{
      this.roles=resp.data
    })
    
  },
  methods: {
    submitForm(formName){
      this.$refs[formName].validate((valid) => {
        if (valid) {
          let params={
            title:"新增用户申请"
          }
          let data={
            user:this.user,
            apps:this.checkList,
            html:html
          }
          //发起流程
          create(params,data).then(resp=>{
            if(resp.code==200){
               this.$message({
                type: 'success',
                message:"提交成功"
              });
              this.$router.push("/home/commonLink").catch({});
            }else{
              this.$message.error(resp.msg)
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


</style>