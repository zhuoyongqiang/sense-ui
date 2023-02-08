<template>
  <el-dialog
    title="分配用户"
    :visible.sync="dialog"
    @close="handleClose"
    width="1000px"
    :close-on-click-modal="false">
    <el-row :gutter="20">
      <el-form :model="queryParams" ref="queryForm" :inline="true"  label-width="68px">
           <el-form-item label="姓名" prop="nickName">
              <el-input
                v-model="queryParams.nickName"
                placeholder="请输入姓名"
                clearable
                size="small"
                style="width: 240px"
                @keyup.enter.native="handleQuery"
              />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>

      <!--用户数据-->
        <el-table v-loading="loading" :data="userList" empty-text="暂无相关人员" @selection-change="handleSelectionChange">
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
        <pagination
          v-show="total>0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
    </el-row>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitData">确 定</el-button>
      </div>
    </el-dialog>
</template>

<script>
import {
  listUser,
} from "@/api/console/system/user";
import {
  batchAddUser
} from "@/api/console/system/role";
export default {
  name: "viewUser",
  data() {
    return {
      dialog: false,
      // 选中数组
      ids: [],
      // 总条数
      total: 0,
      // 遮罩层
      loading: true,
      // 用户表格数据
      userList: undefined,
      // 状态数据字典
      statusOptions: [],
       // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        nickName: undefined,
        status:'1'
      },
      //角色ID
      roleId:undefined,
    };
  },
  methods: {
    showUser(roleId){
      this.roleId=roleId;
      this.getList();
      this.getDicts("user_status_type").then(response => {
        this.statusOptions = response.data;
      });
      this.dialog = true;
    },
    /**搜索 */
    getList(){
      this.loading = true;
      listUser(this.queryParams).then(response=>{
        this.userList = response.rows;
        this.total = response.total;
        this.loading = false;
      })
    },
     /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.page = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.userId);
    },
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.statusOptions, row.status);
    },
    //提交
    submitData(){
      if(this.ids.length<=0){
        this.$message.error("请选择用户");
      }
       //用户成功回调
      batchAddUser({ids:this.ids,roleId:this.roleId}).then(resp=>{
        if(resp.code==200){
          this.$message.success(resp.msg)
          this.dialog=false;
        }else{
          this.$message.error(resp.msg)
        }
      });
    },
    handleClose(){
      this.queryParams= {
        pageNum: 1,
        pageSize: 10,
        nickName: undefined,
        status:'1'
      },
      //角色ID
      this.roleId=undefined,
      this.ids=[];
    }
  }
};
</script>
