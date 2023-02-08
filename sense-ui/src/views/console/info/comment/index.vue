<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="文档标题" prop="objTitle">
        <el-input
          v-model="queryParams.objTitle"
          placeholder="请输入文档标题"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="评论人" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="请输入评论人"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>

      <el-form-item label="评论状态" prop="status">
        <el-select v-model="queryParams.status"
                       size="small"
                       style="width: 120px"
                       clearable>
              <el-option
                v-for="dict in statusOptions"
                :key="dict.dictValue"
                :label="dict.dictLabel"
                :value="dict.dictValue"
              />
            </el-select>
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
          icon="el-icon-circle-check"
          size="mini"
          :disabled="multiple"
          @click="handleAccessOk"
        >通过</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="primary"
		  plain
          icon="el-icon-circle-close"
          size="mini"
          :disabled="multiple"
          @click="handleAccessNot"
        >未通过</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
		  plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['info:infoComment:remove']"
        >删除</el-button>
      </el-col>

      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="infoCommentList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="文档标题" align="left" :show-overflow-tooltip=true>
        <template slot-scope="scope">
          <a style="color:#409EFF" :href="'/home/detail/'+scope.row.objId" target="_blank">{{scope.row.objTitle}}</a>
        </template>
      </el-table-column>

      <el-table-column label="评论内容" align="left" prop="content"  width='200' :show-overflow-tooltip=true />
      <el-table-column label="评论人" align="center" prop="userName" width="100" />
      <el-table-column label="评论时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{m}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" :formatter="statusFormat"  width="80" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width"  >
        <template slot-scope="scope">
          <el-button
          v-if="scope.row.status==3"
            size="mini"
            type="text"
            icon="el-icon-circle-check"
            @click="handleAccessOk(scope.row)"
          >通过</el-button>

          <el-button
          v-if="scope.row.status==3"
            size="mini"
            type="text"
            icon="el-icon-circle-close"
            @click="handleAccessNot(scope.row)"
          >未通过</el-button>

          <el-button
            size="mini"
            type="text"
             icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
          >删除</el-button>
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

    <!-- 添加或修改评论管理对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="70%" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="文档标题" prop="objTitle" >
          <el-input v-model="form.objTitle" :disabled="true"/>
        </el-form-item>
        <el-form-item label="评论人" prop="userName" >
          <el-input v-model="form.userName" :disabled="true"/>
        </el-form-item>
        <el-form-item label="归属部门" prop="deptName" >
          <el-input v-model="form.deptName" :disabled="true"/>
        </el-form-item>
        <el-form-item label="评论时间" prop="createTime">
          <el-input v-model="form.createTime" :disabled="true"/>
        </el-form-item>
        <el-form-item label="评论内容" prop="content" :rules="[{ required: true, message: '评论内容不能为空', trigger: 'blur' }]">
          <el-input v-model="form.content" rows="5" type="textarea" placeholder="请输入评论内容" maxlength="200" show-word-limit/>
        </el-form-item>

         <el-form-item label="评论状态" prop="status" :rules="[{ required: true, message: '评论状态不能为空', trigger: 'blur' }]">
            <el-radio-group v-model="form.status">
              <el-radio
                v-for="dict in statusOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
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
import {accessOkInfoComment,accessNotInfoComment,listInfoComment, getInfoComment, delInfoComment, addInfoComment, updateInfoComment, exportInfoComment } from "@/api/console/info/comment";

export default {
  name: "InfoComment",
  components: {
  },
  data() {
    return {
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
      // 评论管理表格数据
      infoCommentList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 主键ID字典
      idOptions: [],
      // 对象ID字典
      objIdOptions: [],
      // 内容字典
      contentOptions: [],
      // 创建时间字典
      createTimeOptions: [],
      // 状态 1正常 2禁用字典
      statusOptions: [],
      // 回复标识字典
      parentIdOptions: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        objTitle: null,
        userName: null,
        status: null,
        isLikeQuery:true
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
      }
    };
  },
  created() {
    this.getList();
    this.getDicts("info_comment_status").then(response => {
      this.statusOptions = response.data;
    });

  },
  methods: {
    /** 查询评论管理列表 */
    getList() {
      this.loading = true;
      listInfoComment(this.queryParams).then(response => {
        this.infoCommentList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 状态 1正常 2禁用字典翻译
    statusFormat(row, column) {
      return this.selectDictLabel(this.statusOptions, row.status);
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
        objId: null,
        content: null,
        createTime: null,
        status: null,
        parentId: null
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
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加评论管理";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getInfoComment(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改评论管理";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateInfoComment(this.form).then(response => {
              this.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addInfoComment(this.form).then(response => {
              this.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },


     /** 通过按钮 */
    handleAccessOk(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认通过选中项?', "提示", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function() {
          return accessOkInfoComment(ids);
        }).then(() => {
          this.getList();
          this.msgSuccess("处理成功");
        })
    },
     /** 未通过按钮 */
    handleAccessNot(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认未通过选中项?', "提示", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function() {
          return accessNotInfoComment(ids);
        }).then(() => {
          this.getList();
          this.msgSuccess("处理成功");
        })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认删除选中项?', "警告", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function() {
          return delInfoComment(ids);
        }).then(() => {
          this.getList();
          this.msgSuccess("删除成功");
        })
    },
    /** 导出按钮操作 */
    handleExport() {
      const queryParams = this.queryParams;
      this.$confirm('是否确认导出所有评论管理数据项?', "警告", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function() {
          return exportInfoComment(queryParams);
        }).then(response => {
          this.download(response.msg);
        })
    }
  }
};
</script>
