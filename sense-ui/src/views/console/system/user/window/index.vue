<template>
  <el-dialog
    title="查看用户"
    :visible.sync="showInfo"
    width="1000px !important"
    :close-on-click-modal="false">
    <el-row :gutter="20">
      <!--用户数据-->
        <el-table v-loading="loading" :data="userList" empty-text="暂无相关人员">
           <el-table-column type="selection" width="50" align="center"/>
          <el-table-column label="账号" align="center" key="userName" prop="userName" width="140" 
                           :show-overflow-tooltip="true"/>
          <el-table-column label="姓名" align="center" key="nickName" prop="nickName" 
                           :show-overflow-tooltip="true"/>
          <el-table-column label="手机号" align="center" key="phonenumber" prop="phonenumber" 
                           :show-overflow-tooltip="true"/>
          <el-table-column label="所在部门" align="center"  prop="departmentDept.deptName" :show-overflow-tooltip="true"/>
          <el-table-column label="状态" align="center" key="status"  :formatter="statusFormat" />
        </el-table>
    </el-row>
    </el-dialog>
</template>

<script>
import {
  getUserInfoByRoleId,
  getUserInfoByPostId
} from "@/api/console/system/user";
export default {
  name: "viewUser",
  data() {
    return {
      // 遮罩层
      showInfo: false,
      loading: true,
      // 用户表格数据
      userList: undefined,
      // 部门树选项
      deptOptions: undefined,
      // 部门名称
      deptName: undefined,
      // 状态数据字典
      statusOptions: [],
      // 性别状态字典
      sexOptions: [],
      // 岗位选项
      postOptions: [],
      // 角色选项
      roleOptions: [],
      defaultProps: {
        children: "children",
        label: "label"
      },
    };
  },
  methods: {
    //查看用户，type=1角色   type=2岗位
    showUser(objId,type){
      this.getDicts("user_status_type").then(response => {
        this.statusOptions = response.data;
      });
      this.showInfo = true;
      if(type===1){
        getUserInfoByRoleId(objId).then(response => {
          this.loading=false;
          if(response.code==200) {
            this.userList = response.data;
          }
        })
      }else if(type===2){
        getUserInfoByPostId(objId).then(response => {
          this.loading=false;
          if(response.code==200) {
            this.userList = response.data;
          }
        })
      }
    },
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.statusOptions, row.status);
    }
  }
};
</script>
