<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!--分类数据-->
      <el-col :span="4" :xs="24">
        <div class="head-container">
          <el-input
            v-model="newsTypeName"
            placeholder="请输入分类名称"
            clearable
            size="small"
            prefix-icon="el-icon-search"
            style="margin-bottom: 20px"
          />
        </div>
        <div class="head-container">
          <el-tree
            :data="newsTypeTreeOptions"
            :props="newsTypeDefaultProps"
            :expand-on-click-node="false"
            :filter-node-method="filterNode"
            :highlight-current="true"
            ref="tree"
            default-expand-all
            @node-click="newsTypeHandleNodeClick"
          />
        </div>
      </el-col>
      <!--内容数据-->
      <el-col :span="20" :xs="24">
        <el-form :model="queryParams" ref="queryForm" :inline="true" class="search-bar" v-show="showSearch">
          <el-form-item label="标题" prop="title">
            <el-input
              v-model="queryParams.title"
              placeholder="请输入标题"
              clearable
              size="small"
              @keyup.enter.native="handleQuery"
            />
          </el-form-item>
          <el-form-item label="作者" prop="issuer">
            <el-input
              v-model="queryParams.issuer"
              placeholder="请输入作者"
              style="width: 120px"
              clearable
              size="small"
              @keyup.enter.native="handleQuery"
            />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="queryParams.status"
                       size="small"
                       style="width: 120px"
                       clearable>
              <el-option
                v-for="dict in newsStatusOptions"
                :key="dict.dictValue"
                :label="dict.dictLabel"
                :value="dict.dictValue"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="置顶" prop="isFirst">
            <el-select v-model="queryParams.isFirst"
                       size="small"
                       style="width: 120px"
                       clearable>
              <el-option
                v-for="dict in commonYesNoOptions"
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
              icon="el-icon-plus"
              size="mini"
              @click="handleAdd"
              v-hasPermi="['info:news:add']"
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
              v-hasPermi="['info:news:edit']"
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
              v-hasPermi="['info:news:remove']"
            >删除
            </el-button>
          </el-col>
          <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
        </el-row>

        <el-table v-loading="loading" :data="newsList" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="55" align="center"/>
          <el-table-column label="分类" align="center" width="80" prop="newsTypeName"/>
          <el-table-column label="封面" align="center" width="60" prop="photo">
            <template slot-scope="scope">
              <img v-if="scope.row.photo!=null" :src="baseFilePath+scope.row.photo" width="40px" height="40px"/>
              <img v-else src="@/assets/images/thumbnail.png" width="40" height="40">
            </template>
          </el-table-column>
          <el-table-column label="标题" :show-overflow-tooltip="true" align="center" prop="title"/>
          <el-table-column label="作者" align="center" width="80" prop="issuer"/>
          <el-table-column label="置顶" align="center" width="50" prop="isFirst" :formatter="isFirstFormat"/>
          <el-table-column label="机构" align="center" width="80" prop="branchDeptId" :formatter="branchDeptIdFormat"/>
          <el-table-column label="权限" align="center" width="80" prop="isScope">
            <template slot-scope="scope">
              <span v-if="scope.row.isScope==0">全行可见</span>
              <span v-else-if="scope.row.isScope==1">部分可见</span>
            </template>
          </el-table-column>
          <el-table-column label="数据状态" align="center" width="80" prop="status">
            <template slot-scope="scope">
              <span v-if="scope.row.status==0" style="color:#409EFF;">{{ newsStatusFormat(scope.row) }}</span>
              <span v-else-if="scope.row.status==1" style="color:#67C23A;">{{ newsStatusFormat(scope.row) }}</span>
              <span v-else-if="scope.row.status==2" style="color:#E6A23C;">{{ newsStatusFormat(scope.row) }}</span>
              <span v-else style="color:#F56C6C;">{{ newsStatusFormat(scope.row) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="审批状态" align="center" width="80" prop="newsProcessStatus"
                           :formatter="newsProcessStatusFormat">
            <template slot-scope="scope">
              <span v-if="scope.row.newsProcessStatus==null" style="color:#409EFF;">
                未提交
              </span>
              <span v-if="scope.row.newsProcessStatus==0" style="color:#409EFF;">{{
                  newsProcessStatusFormat(scope.row)
                }}</span>
              <span v-else-if="scope.row.newsProcessStatus==1" style="color:#E6A23C;">{{
                  newsProcessStatusFormat(scope.row)
                }}</span>
              <span v-else-if="scope.row.newsProcessStatus==2" style="color:#67C23A;">{{
                  newsProcessStatusFormat(scope.row)
                }}</span>
              <span v-else style="color:#F56C6C;">{{ newsProcessStatusFormat(scope.row) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="发布时间" align="center" prop="effectTime" width="140">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.effectTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="180" class-name="small-padding">
            <template slot-scope="scope">
              <el-button
                size="mini"
                type="text"
                icon="el-icon-s-promotion"
                v-if="scope.row.newsProcessStatus!=1 && scope.row.newsProcessStatus!=2 && scope.row.status != 1"
                @click="startProcess(scope.row)"
                v-hasPermi="['info:news:start']"
              >发起
              </el-button>
              <el-button
                size="mini"
                type="text"
                icon="el-icon-s-order"
                v-if="scope.row.newsProcessStatus!=null"
                @click="handleProcess(scope.row)"
                v-hasPermi="['info:news:process']"
              >流程
              </el-button>
              <el-button
                size="mini"
                type="text"
                icon="el-icon-s-platform"
                @click="handlePreview(scope.row)"
                v-hasPermi="['info:news:preview']"
              >预览
              </el-button>
              <el-button
                size="mini"
                type="text"
                icon="el-icon-edit"
                @click="handleUpdate(scope.row)"
                v-hasPermi="['info:news:edit']"
              >修改
              </el-button>
              <el-button
                v-if="scope.row.status==2"
                size="mini"
                type="text"
                icon="el-icon-s-promotion"
                @click="enabled(scope.row)"
              >启用
              </el-button>
              <el-button
                v-if="scope.row.status==1"
                size="mini"
                type="text"
                icon="el-icon-s-promotion"
                @click="disable(scope.row)"
              >禁用
              </el-button>
							<el-button
                v-if="scope.row.status==1"
                size="mini"
                type="text"
                icon="el-icon-mobile-phone"
                @click="handleSend(scope.row)"
                v-hasPermi="['info:news:send']"
              >重推
              </el-button>
              <el-button
                v-if="scope.row.status==1"
                size="mini"
                type="text"
                icon="el-icon-bell"
                @click="handleMsg(scope.row)"
              >消息
              </el-button>
              <!-- <el-button
                size="mini"
                type="text"
                icon="el-icon-delete"
                @click="handleDelete(scope.row)"
                v-if="scope.row.newsProcessStatus !== 1"
                v-hasPermi="['info:news:remove']"
              >删除
              </el-button> -->
              <el-button
                size="mini"
                type="text"
                icon="el-icon-delete"
                @click="handleDelete(scope.row)"
                v-hasPermi="['info:news:remove']"
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
      </el-col>
    </el-row>
    <!--修改窗口-->
    <edit :dialog-obj.sync="editDialogObj" @callback="getList"></edit>


    <preview ref="previewInfo" :visible.sync="previewInfovisible"></preview>

    <!-- 消息弹框组件 -->
    <notice :data="noticeData"></notice>
  </div>
</template>

<script>
  import {listNews, delNews,disable,enabled,sendNews} from "@/api/console/info/news";
  import {listNewsType} from "@/api/console/info/newsType";
  import {create, getLatestNewsInstance} from "@/api/console/bpm/workflow";
  import {listDept} from "@/api/console/system/dept";
  import Edit from "@/views/console/info/news/edit";
  import preview from "@/views/console/info/news/preview";
  import notice from '@/views/console/info/news/notice'
  export default {
  name: "News",
  components: {Edit,preview, notice},
  data() {
    return {
      previewInfovisible: false,
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
      // 内容表格数据
      newsList: [],
      // 弹出层标题
      title: "",
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        newsTypeId: null,
        title: null,
        issuer: null,
        isFirst: null,
        status: null
      },
      // 分类名称
      newsTypeName: undefined,
      // 分类树选项
      newsTypeTreeOptions: undefined,
      //分类树配置
      newsTypeDefaultProps: {
        children: "children",
        label: "name"
      },
      /**通用是否*/
      commonYesNoOptions: [],
      /**数据状态字典*/
      newsStatusOptions: [],
      /**流程状态字典*/
      newsProcessStatusOptions: [],
      /**选择的内容类型*/
      selectedNewsType: {},
      /**文件基本路径*/
      baseFilePath: undefined,
      //流程弹出框
      startProcessDialogObj: {
        title: undefined,
        open: false,
        modelKey: undefined
      },
      //部门集合
      deptList: [],
      //打开窗口对象
      editDialogObj: {
        id: undefined,
        open: false,
        title: ''
      },
      // 消息组件参数
      noticeData: {
        id: null,
        show: false
      }
    };
  },
  created() {
    this.getDictionary();
    this.getList();
    this.getNewsTypeList();
  },
  methods: {
    enabled(rows){
      enabled(rows.id).then(response => {
        if (response.code === 200) {
          this.getList();
          this.msgSuccess("启用成功");
        } else {
          this.msgError(response.msg);
        }
      });
    },
    disable(rows){
      disable(rows.id).then(response => {
        if (response.code === 200) {
          this.getList();
          this.msgSuccess("禁用成功");
        } else {
          this.msgError(response.msg);
        }
      });
    },
    /** 初始化字典 */
    getDictionary() {
      this.getDicts('common_yes_no').then(response => {
        this.commonYesNoOptions = response.data;
      });
      this.getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
      this.getDicts('info_news_status').then(response => {
        this.newsStatusOptions = response.data;
      });
      listDept({}).then(response => {
        this.deptList = response.data;
      });
      this.getDicts('bpm_process_status').then(response => {
        this.newsProcessStatusOptions = response.data;
      })
    },
    /** 查询内容列表 */
    getList() {
      this.loading = true;
      listNews(this.queryParams).then(response => {
        this.newsList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /**查询分类树结构*/
    getNewsTypeList() {
      this.loading = true;
      listNewsType({}).then(response => {
        this.newsTypeTreeOptions = this.handleTree(response.data, "id", "parentId");
        this.loading = false;
      });
    },
    //是否置顶格式化
    isFirstFormat(row, column) {
      return this.selectDictLabel(this.commonYesNoOptions, row.isFirst);
    },
    //数据状态格式化
    newsStatusFormat(row, column) {
      return this.selectDictLabel(this.newsStatusOptions, row.status);
    },
    //审批状态格式化
    newsProcessStatusFormat(row, column) {
      return this.selectDictLabel(this.newsProcessStatusOptions, row.newsProcessStatus);
    },
    //权限名称格式化
    branchDeptIdFormat(row, column) {
      let list = this.deptList;
      for (let i in list) {
        if (list[i].sn == row.branchDeptId) {
          return list[i].deptName;
        }
      }
    },
    /** 筛选节点*/
    filterNode(value, data) {
      if (!value) return true;
      return data.label.indexOf(value) !== -1;
    },
    /** 节点单击事件*/
    newsTypeHandleNodeClick(data) {
      this.queryParams.newsTypeId = data.id;
      this.selectedNewsType.id = data.id;
      this.selectedNewsType.name = data.name;
      this.editDialogObj.photoWidth = data.photoWidth;
      this.editDialogObj.photoHeight = data.photoHeight;
      this.getList();
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.queryParams.newsTypeId = null;
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
      this.editDialogObj.id = undefined;
      this.editDialogObj.newsTypeId = this.selectedNewsType.id;
      this.editDialogObj.open = true;
      this.editDialogObj.title = "添加新闻";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      const id = row.id || this.ids
      this.editDialogObj.id = id;
      this.editDialogObj.open = true;
      this.editDialogObj.title = '修改新闻';
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      // let idss = []
      // if (this.ids && this.ids.length) {
      //   idss = this.ids.filter(id => {
      //     return this.newsList.find(m => m.id === id).newsProcessStatus !== 1
      //   })
      // }
      const ids = row.id || this.ids;
      // if (Array.isArray(ids) && ids.length <= 0) {
      //   this.msgError('所选中的新闻处于审批中，不可删除');
      //   return
      // }
      this.$confirm('删除该新闻后，该新闻及新闻关联的审批流程将一并删除，请确认是否同意并继续？', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delNews(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      }).catch(() => {})
    },
		/** 重推企业微信按钮操作 */
    handleSend(row) {
			const ids = row.id || this.ids;
			const title = row.title;
			const status = row.status;
			if (status != '1') {
				this.msgError("只有发布状态的新闻可以重新推送");
				return;
			}
      this.$confirm('是否确认给企业微信重推内容标题为"' + title + '"的数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
				var data = {"id": ids};
        return sendNews(data);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("操作成功");
        } else {
          this.msgError(response.msg);
        }
      })
    },
    /**流程按钮操作*/
    handleProcess(row) {
      const id = row.id;
      getLatestNewsInstance(id).then(res => {
        if (res.data) {
          window.open('/home/bpm/process/' + res.data.id);
        } else {
          this.$message.info('不存在相关流程');
        }
      });
    },
    /**预览按钮操作*/
    handlePreview(row) {
      this.previewInfovisible = true;
      this.$nextTick(function () {
        this.$refs.previewInfo.show(row.id)
      })
    },
    //处理审批人
    startProcess(row) {
      this.$confirm('是否发起流程？', "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "info"
      }).then(function (res) {
        return create(row.id);
      }).then((res) => {
        if (res.code == 200) {
          this.getList();
          this.msgSuccess("发起成功");
        } else {
          this.msgError(res.msg);
        }
      })
    },
    // 消息按钮
    handleMsg (row) {
      const id = row.id;
      //
      this.noticeData.id = id
      this.noticeData.newsTitle = row.title
      this.noticeData.show = true
    }
  }
};

</script>
<style scoped>

.head-container >>> .el-tree-node {
  height: 34px;
  line-height: 34px;
}

.head-container >>> .el-tree-node__content {
  height: 34px;
}

.app-container >>> .el-dialog__body {
  padding: 10px 20px;
}

.search-bar .el-form-item--mini .el-form-item__label {
  line-height: 32px;
}
</style>
