<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入名称"
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
          v-hasPermi="['info:newsType:add']"
        >新增
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table
      v-loading="loading"
      :data="newsTypeList"
      row-key="id"
      default-expand-all
      :tree-props="{children: 'children', hasChildren: 'hasChildren'}"
    >
      <el-table-column label="名称" align="center" prop="name"/>
      <el-table-column label="排序号" align="center" prop="sort"/>
      <el-table-column label="权限控制" align="center" prop="isQx" :formatter="isQxFormat"/>
      <el-table-column label="更多显示" align="center" prop="isMore" :formatter="isMoreFormat"/>
      <el-table-column label="封面宽度" align="center" prop="photoWidth"/>
      <el-table-column label="封面高度" align="center" prop="photoHeight"/>
      <el-table-column label="备注" align="center" prop="remark"/>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['info:newsType:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['info:newsType:remove']"
          >删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加或修改内容分类对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="所属分类" prop="parentId">
          <treeselect v-model="form.parentId" :options="newsTypeOptions" :normalizer="normalizer"
                      placeholder="请选择所属分类"/>
        </el-form-item>
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入名称"/>
        </el-form-item>
        <el-form-item label="权限控制" prop="isQx">
          <el-radio-group v-model="form.isQx">
            <el-radio
              v-for="dict in commonYesNoOptions"
              :key="Number(dict.dictValue)"
              :label="Number(dict.dictValue)"
            >{{ dict.dictLabel }}
            </el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="更多显示" prop="isMore">
          <el-radio-group v-model="form.isMore">
            <el-radio
              v-for="dict in commonYesNoOptions"
              :key="Number(dict.dictValue)"
              :label="Number(dict.dictValue)"
            >{{ dict.dictLabel }}
            </el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序号" prop="name">
          <el-input v-model="form.sort"/>
        </el-form-item>
        <el-form-item label="显示期数" prop="showPhase">
          <el-switch v-model="form.showPhase"></el-switch>
        </el-form-item>
        <el-form-item label="当前期数" prop="currentPhase">
          <el-input-number v-model="form.currentPhase" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="总期数" prop="totalPhase">
          <el-input-number v-model="form.totalPhase" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="封面宽度" prop="name">
          <el-input v-model="form.photoWidth"/>
        </el-form-item>
        <el-form-item label="封面高度" prop="name">
          <el-input v-model="form.photoHeight"/>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" placeholder="请输入备注"/>
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
  listNewsType,
  getNewsType,
  delNewsType,
  addNewsType,
  updateNewsType,
  exportNewsType
} from "@/api/console/info/newsType";
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

export default {
  name: "NewsType",
  components: {
    Treeselect
  },
  data() {
    return {
      // 遮罩层
      loading: true,
      // 显示搜索条件
      showSearch: true,
      // 内容分类表格数据
      newsTypeList: [],
      // 内容分类树选项
      newsTypeOptions: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        parentId: null,
        name: null,
        isQx: null,
        isMore: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        id: [
          {required: true, message: "主键不能为空", trigger: "blur"}
        ],
      },
      /**通用是否*/
      commonYesNoOptions: []
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询内容分类列表 */
    getList() {
      this.loading = true;
      listNewsType(this.queryParams).then(response => {
        this.newsTypeList = this.handleTree(response.data, "id", "parentId");
        this.loading = false;
      });
      this.getDicts('common_yes_no').then(response => {
        this.commonYesNoOptions = response.data;
      });
    },
    /** 转换内容分类数据结构 */
    normalizer(node) {
      if (node.children && !node.children.length) {
        delete node.children;
      }
      return {
        id: node.id,
        label: node.name,
        children: node.children
      };
    },
    /** 查询部门下拉树结构 */
    getTreeselect() {
      listNewsType().then(response => {
        this.newsTypeOptions = [];
        const data = {id: 0, name: '顶级节点', children: []};
        data.children = this.handleTree(response.data, "id", "parentId");
        this.newsTypeOptions.push(data);
      });
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
        parentId: null,
        name: null,
        isQx: null,
        isMore: null,
        sort: null,
        photoWidth: null,
        photoHeight: null,
        remark: null,
        createTime: null,
        updateTime: null,
        showPhase: false,
        currentPhase: 0,
        totalPhase: 0
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    //数据状态格式化
    isQxFormat(row, column) {
      return this.selectDictLabel(this.commonYesNoOptions, row.isQx);
    },
    //数据状态格式化
    isMoreFormat(row, column) {
      return this.selectDictLabel(this.commonYesNoOptions, row.isMore);
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.getTreeselect();
      this.open = true;
      this.title = "添加内容分类";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      this.getTreeselect();
      if (row != null) {
        this.form.parentId = row.id;
      }
      getNewsType(row.id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改内容分类";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateNewsType(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addNewsType(this.form).then(response => {
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
      this.$confirm('是否确认删除内容分类编号为"' + row.id + '"的数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delNewsType(row.id);
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
