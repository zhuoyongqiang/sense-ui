<template>
<div class="app-container" >
  <div  class="apply_user_main">
    <el-row :gutter="24" type="flex" justify="space-around">
     <el-col :span="24"  >
        <h2 style="text-align:center;margin-bottom:20px">注册用户</h2>
        <el-form ref="form" :model="user"  size="small" label-width="100px" class="formStyle">
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
            <el-input  v-model="user.sex"></el-input>
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
        </el-form>
    </el-col>
  </el-row>   
  </div>
  </div>
</template>
<script>
import {treeselect} from "@/api/console/system/dept";
import { optionselect } from "@/api/console/system/post";
import {openAppAccount,create} from '@/api/console/bpm/applyUser';
export default {
  name:"bpmApplyUserProcess",
  props: ['formData'],
  data(){
    return{
      //用户信息
      user:{
        staffNo:undefined,
        nickName:undefined,
        sex:undefined,
        phonenumber:undefined,
        email:undefined,
        departmentCodeId:undefined,
        postCode:undefined
      },
      //部门集合
      departments:[],
      //岗位集合
      posts:[],
    }
  },
  created(){
   let data=JSON.parse(this.formData.businessData);
    //表单数据
    this.user=data.user;
    this.user.sex=this.user.sex==1 ? '男' :'女';
    this.con=data.html
    //部门列表
    treeselect().then(resp => {
      this.departments = resp.data;
    });
    //岗位列表
    optionselect().then(resp=>{
      this.posts=resp.data
    })
  },
  methods: {
    
  },
}
</script>

<style lang="scss" >
.apply_user_main{
  .formStyle{
    pointer-events: none;
  }
  .el-input__inner{
    border-color:white;
  }
  .el-input{
    border-color:white
  }
  .el-input__icon{
    display: none;
  }
}

</style>