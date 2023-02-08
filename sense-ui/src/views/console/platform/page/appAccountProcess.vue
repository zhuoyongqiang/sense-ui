<template>
  <div class="app-container">
    <el-row :gutter="24" type="flex" justify="space-around">
     <el-col :span="24">
        <h2 style="text-align:center;margin-bottom:20px">开通账号</h2>
        <el-form ref="form" :model="user"  size="small" class="app_form" label-width="80px">
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
          <el-form-item label="账号:" >
            <el-input  class="read_text"  v-model="user.account"></el-input>
          </el-form-item>
        </el-col>
          <el-col :span="12"  >
          <el-form-item label="密码:"  >
            <el-input class="read_text" type="password"  v-model="user.password"></el-input>
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
            <span style="margin-left:2%;font-size:13px;color:darkslategray" v-for="item in apps" :key="item.sn">{{item.name}}</span>
          </el-form-item>
        </el-col>
      </el-form>
    </el-col>
  </el-row>
  </div>
</template>

<script>
export default {
  name: "appAccountProcess",
  props: ['formData'],
  data(){
    return{
       user:{
        account:undefined,
        password:undefined,
        orgDept:{},
        departmentDept:{}
      },
      apps:[],
      htmlData:undefined
    }
  },
  created(){
    let data=JSON.parse(this.formData.businessData);
    this.user=data.user;
    this.apps=data.apps;
    this.htmlData=data.html;
  }
}
</script>
<style lang="scss" scoped>

.app-container{
  width: 100%;
  height: 100%;
  .app_form{
    width: 100%;
    height: 100%;
    margin-bottom: 50px;
  }

}
.read_text ::v-deep{
  .el-input__inner{
    border: 0 ;
  }
}

</style>
