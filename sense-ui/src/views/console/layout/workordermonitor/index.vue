<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="100px">

      <el-form-item label="流程编号" prop="workflowCode">
        <el-input
          v-model="queryParams.workflowCode"
          placeholder="请输入流程编号"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>

      <el-form-item label="工单名称" prop="requestName">
        <el-input
          v-model="queryParams.requestName"
          placeholder="请输入工单名称"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="所属系统" prop="clientName">
        <el-input
          v-model="queryParams.clientName"
          placeholder="请输入所属系统"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="办理人" prop="receivers">
        <el-input
          v-model="queryParams.receivers"
          placeholder="请输入办理人"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>


      <el-form-item label="是否准入" prop="access">
          <el-select v-model="queryParams.access"
                     size="small"
                     @change="handleQuery"
                     clearable>
            <el-option
              v-for="dict in workOrderAccessOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="dict.dictValue"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="节点状态" prop="status">
          <el-select v-model="queryParams.status"
                     size="small"
                     @change="handleQuery"
                     clearable>
            <el-option
              v-for="dict in workOrderStatusOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="dict.dictValue"
            />
          </el-select>
       </el-form-item>
      <el-form-item label="工单状态" prop="taskType">
        <el-select v-model="queryParams.taskType"
                   size="small"
                   @change="handleQuery"
                   clearable>
          <el-option
            v-for="dict in workOrderStatusOptions"
            :key="dict.dictValue"
            :label="dict.dictLabel"
            :value="dict.dictValue"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="紧急程度" prop="requestLevel">
        <el-select v-model="queryParams.requestLevel"
                   size="small"
                   @change="handleQuery"
                   clearable>
          <el-option
            v-for="dict in levelOptions"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
       <el-form-item label="工单开始时间">
          <el-date-picker
            v-model="dateRange"
            size="small"
            style="width: 342px"
            value-format="yyyy-MM-dd"
            type="daterange"
            range-separator="-"
            start-placeholder="起始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          @click="handleDelete"
        >删除
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="流程编号" align="center" prop="workflowCode" :show-overflow-tooltip="true"/>
      <el-table-column label="工单名称" align="center" prop="requestName" :show-overflow-tooltip="true"/>
      <el-table-column label="所属系统" align="center" prop="clientName" :show-overflow-tooltip="true" width="150"/>
      <el-table-column label="办理人" align="center" prop="receivers" :show-overflow-tooltip="true" width="80"/>

      <el-table-column label="节点状态" align="center" width="80">
        <template slot-scope="scope">
          <span >{{ workOrderStatusFormat1(scope.row)}}</span>
        </template>
      </el-table-column>
      <el-table-column label="工单状态" align="center" width="80">
        <template slot-scope="scope">
          <span >{{ workOrderStatusFormat(scope.row)}}</span>
        </template>
      </el-table-column>
      <el-table-column label="工单开始时间" align="center" :show-overflow-tooltip="true" width="150">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.startDate, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="是否准入" align="center" width="80">
        <template slot-scope="scope">
          <span >{{ workOrderAccessOFormat(scope.row)}}</span>
        </template>
      </el-table-column>
      <el-table-column label="紧急程度" align="center" width="80">
        <template slot-scope="scope">
          <span v-if="scope.row.requestLevel===0">正常</span>
          <span v-else-if="scope.row.requestLevel===1">重要</span>
          <span v-else-if="scope.row.requestLevel===2">紧急</span>
          <span v-else>未知</span>
        </template>
      </el-table-column>
     <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="150">
        <template slot-scope="scope">
         <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
          >删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
    <!--修改窗口-->
    <edit ref="editInfo" :visible.sync="editInfovisible" @callback="handleQuery"></edit>
  </div>
</template>
<script>
import Edit from "@/views/console/layout/workordermonitor/profile/edit";
import {list,findById,remove} from "@/api/console/layout/workordermonitor/index";
export default {
  name: "workOrder",
  components: {Edit},
  data() {
    return {
      editInfovisible : false,
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 表格数据
      dataList: [],
      levelOptions:[{
        label:"正常",
        value:0
      },{
        label:"重要",
        value:1
      },{
        label:"紧急",
        value:2
      }],
      /**工单类型字典*/
      workOrderStatusOptions: [],
       /**是否准入*/
      workOrderAccessOptions: [],
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        requestId: null,
        requestName: null,
        clientName: null,
        receivers: null,
        creator: null,
        status: null,
        access: null
      },
      dateRange: []
    };
  },
  created() {
    this.getList();
    this.loadtDicts();
  },
  methods: {
    loadtDicts(){
      this.getDicts('bpm_process_status').then(response => {
         this.workOrderStatusOptions = response.data;
      })

      this.getDicts('work_order_access').then(response => {
        this.workOrderAccessOptions = response.data;
      })
    },
    workOrderStatusFormat1(row, column) {
      let val=this.selectDictLabel(this.workOrderStatusOptions, row.status);
      if(val){
         return val
      }else{
         return '未知'
      }
    },
    workOrderStatusFormat(row, column) {
      let val=this.selectDictLabel(this.workOrderStatusOptions, row.taskType);
      if(val){
        return val
      }else{
        return '未知'
      }
    },
    workOrderAccessOFormat(row, column) {
      let val=this.selectDictLabel(this.workOrderAccessOptions, row.access);
      if(val){
         return val
      }else{
         return '未知'
      }
    },
    /** 查询列表 */
    getList() {
      this.loading = true;
      let search =this.queryParams;
      search.params = {};
      if (null != this.dateRange && '' != this.dateRange) {
         search.params["beginTime"] = this.dateRange[0];
         search.params["endTime"] =  this.dateRange[1];
      }
      list(search).then(response => {
        this.dataList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.dateRange = [];
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      const id = row.id || this.ids
      this.editInfovisible=true;
      this.$nextTick(function () {
        this.$refs.editInfo.load(id)
     } )
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      if(ids && ids.length==0){
        this.msgWarning("请选择需要删除项");
        return ;
      }
      this.$confirm('确认是否删除选择项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return remove(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      })
    }
  }
};
</script>
