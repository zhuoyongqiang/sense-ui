<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="任务名称" prop="taskName">
        <el-input
          v-model="queryParams.taskName"
          placeholder="请输入名称"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="任务标识" prop="node">
        <el-input
          v-model="queryParams.node"
          placeholder="请输入标识"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['bpm:define:model']"
        >新增
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['bpm:define:model']"
        >修改
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['bpm:define:model']"
        >删除
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['bpm:define:model']"
        >导出
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="bpmModelList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>

      <el-table-column label="标识" align="center" prop="node" width="80"/>
      <el-table-column label="任务名称" align="center" prop="taskName" width="100"/>
      <el-table-column label="顺序" align="center" prop="order" width="60"/>
      <el-table-column label="类型" align="center" prop="type" width="100" :formatter="formatNodeType"/>
      <el-table-column label="审批人规则" align="center" prop="assigneeRule"/>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="140" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['bpm:define:model']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['bpm:define:model']"
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

    <!-- 添加或修改新闻流程对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="120px">
        <div class="subtitle"><b>基本设置</b></div>
        <el-form-item label="标识" prop="node">
          <el-input v-model="form.node" placeholder="请输入标识"/>
        </el-form-item>
        <el-form-item label="任务名称" prop="taskName">
          <el-input v-model="form.taskName" placeholder="请输入任务名称"/>
        </el-form-item>
        <el-form-item label="顺序" prop="order">
          <el-input-number v-model="form.order" label="请输入顺序"></el-input-number>
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type">
            <el-option
              v-for="item in nodeTypeOptions"
              :key="item.dictValue"
              :label="item.dictLabel"
              :value="item.dictValue"
            ></el-option>
          </el-select>
        </el-form-item>
        <div class="subtitle"><b>审批人筛选规则</b></div>
        <el-form-item label="是否发起人">
          <el-checkbox v-model="isStartUser"></el-checkbox>
        </el-form-item>
        <el-form-item label="是否上级领导">
          <el-checkbox v-model="isLeader"></el-checkbox>
        </el-form-item>
        <el-form-item label="指定的用户">
          <el-input v-model="assignee" placeholder="请输入账号，多个以逗号分隔"/>
        </el-form-item>
        <el-form-item label="指定的岗位">
          <el-input v-model="position" placeholder="请输入岗位，多个以逗号分隔"/>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import {
  listBpmModel,
  getBpmModel,
  delBpmModel,
  addBpmModel,
  updateBpmModel,
  exportBpmModel
} from "@/api/console/bpm/model";

export default {
  name: "BpmModel",
  components: {},
  data() {
    return {
      //新闻定义ID
      newDefineId: undefined,
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 新闻流程表格数据
      bpmModelList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        taskName: null,
        order: null,
        type: null,
        assigneeRule: null,
        createTime: null,
        updateTime: null,
        node: null
      },
      // 表单参数
      form: {},
      //是否由发起人审批
      isStartUser: false,
      //是否由上级领导审批
      isLeader: false,
      //指定的审批人
      assignee: undefined,
      //指定的岗位
      position: undefined,
      // 表单校验
      rules: {},
      //审批节点类型
      nodeTypeOptions: [],
      //通用是否选项
      commonYesNoOptions: []
    };
  },
  created() {
    this.newDefineId = this.$route.params && this.$route.params.defineId;
    this.getList();
  },
  methods: {
    /** 查询新闻流程列表 */
    getList() {
      this.loading = true;
      this.queryParams.newsDefineId = this.newDefineId;
      listBpmModel(this.queryParams).then(response => {
        this.bpmModelList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
      this.getDicts("bpm_node_type").then(response => {
        this.nodeTypeOptions = response.data;
      });
    },
    /**格式化节点类型*/
    formatNodeType(row) {
      return this.selectDictLabel(this.nodeTypeOptions, row.type);
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        taskName: null,
        order: null,
        type: null,
        assigneeRule: null,
        createTime: null,
        updateTime: null,
        node: null
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加新闻流程";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getBpmModel(id).then(response => {
        this.form = response.data;
        let assigneeRule = eval('(' + this.form.assigneeRule + ')');
        this.isStartUser = assigneeRule.isStartUser ? assigneeRule.isStartUser : false;
        this.isLeader = assigneeRule.isLeader ? assigneeRule.isLeader : false;
        this.assignee = assigneeRule.assignee ? assigneeRule.assignee.join(',') : '';
        this.position = assigneeRule.position ? assigneeRule.position.join(',') : '';
        this.form.type = response.data.type + "";
        this.open = true;
        this.title = "修改新闻流程";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          let assigneeRule = {};
          let assigneeArr = [];
          if (this.assignee && this.assignee != '') {
            assigneeArr = this.assignee.split(',')
          }
          let positionArr = [];
          if (this.position && this.position != '') {
            positionArr = this.position.split(',');
          }
          assigneeRule.isStartUser = this.isStartUser;
          assigneeRule.isLeader = this.isLeader;
          assigneeRule.assignee = assigneeArr;
          assigneeRule.position = positionArr;
          this.form.assigneeRule = JSON.stringify(assigneeRule);
          this.form.newsDefineId = this.newDefineId;
          if (this.form.id != null) {
            updateBpmModel(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addBpmModel(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("新增成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认删除新闻流程编号为"' + ids + '"的数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delBpmModel(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      })
    },
    /** 导出按钮操作 */
    handleExport() {
      const queryParams = this.queryParams;
      this.$confirm('是否确认导出所有新闻流程数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return exportBpmModel(queryParams);
      }).then(response => {
        this.download(response.msg);
      })
    }
  }
};
</script>

<style lang="scss" scoped>
  ::v-deep .el-form{
    width: 80%;
    margin: 0 auto;
  }
  ::v-deep .el-form label{
    font-weight: normal;
  }
  .subtitle{
    padding-left: 10px;
    margin-left: 10px;
    margin-bottom: 20px;
    position: relative;
    color:#2272DE;
    &::before{
      position: absolute;
      display: inline-block;
      width: 3px;
      height: 16px;
      background-color: #2272DE;
      content: '';
      left: 0;
      top: 50%;
      transform: translateY(-50%);
    }
  }
</style>
