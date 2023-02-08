<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="24" :xs="24">
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
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
        <el-table v-loading="loading" :data="newsList" @selection-change="handleSelectionChange">
          <el-table-column label="分类" align="center" width="140" prop="newsTypeName"/>
          <el-table-column label="封面" align="center" width="80" prop="photo">
            <template slot-scope="scope">
              <img :src="baseFilePath+scope.row.photo" width="40px" height="40px"/>
            </template>
          </el-table-column>
          <el-table-column label="标题" :show-overflow-tooltip="true" align="center" prop="title"/>
          <el-table-column label="作者" align="center" width="150" prop="issuer"/>
          <el-table-column label="机构" align="center" width="120" prop="branchDeptId" :formatter="branchDeptIdFormat"/>
          <el-table-column label="审批状态" align="center" width="100" prop="newsProcessStatus"
                           :formatter="newsProcessStatusFormat">
            <template slot-scope="scope">
              <span v-if="scope.row.newsProcessStatus==null" style="color:#409EFF;">
                未提交
              </span>
              <span v-if="scope.row.newsProcessStatus==0" style="color:#409EFF;">
                {{ newsProcessStatusFormat(scope.row) }}
              </span>
              <span v-else-if="scope.row.newsProcessStatus==1" style="color:#E6A23C;">
                {{ newsProcessStatusFormat(scope.row) }}
              </span>
              <span v-else-if="scope.row.newsProcessStatus==2" style="color:#67C23A;">
                {{ newsProcessStatusFormat(scope.row) }}
              </span>
              <span v-else>{{ newsProcessStatusFormat(scope.row) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="发布时间" align="center" prop="effectTime" width="140">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.effectTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="250" class-name="small-padding">
            <template slot-scope="scope">
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
                v-hasPermi="['info:newsTransport:edit']"
              >修改
              </el-button>

              <el-button
                size="mini"
                icon="el-icon-position"
                type="text"
                v-if="scope.row.newsProcessStatus!=1"
                @click="startTransport(scope.row)"
                v-hasPermi="['info:newsTransport:transport']"
              >转载
              </el-button>

              <el-button
                size="mini"
                type="text"
                icon="el-icon-s-order"
                v-if="scope.row.newsProcessStatus!=null"
                @click="handleProcess(scope.row)"
                v-hasPermi="['info:newsTransport:process']"
              >流程
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
  </div>
</template>

<script>
import {listTransportNews} from "@/api/console/info/news";
import {listNewsType} from "@/api/console/info/newsType";
import {transport, getLatestNewsInstance} from "@/api/console/bpm/workflow";
import {listDept} from "@/api/console/system/dept";
import Edit from "@/views/console/info/news/edit";
import preview from "@/views/console/info/news/preview";
export default {
  name: "NewsTransport",
  components: {Edit,preview},
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
        title: null,
        issuer: null
      },
      // 分类名称
      newsTypeName: undefined,
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
      }
    };
  },
  created() {
    this.getDictionary();
    this.getList();
    this.getNewsTypeList();
  },
  methods: {
    /**预览按钮操作*/
    handlePreview(row) {
      this.previewInfovisible = true;
      this.$nextTick(function () {
        this.$refs.previewInfo.show(row.id)
      })
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
        console.log(response)
        this.deptList = response.data;
      });
      this.getDicts('bpm_process_status').then(response => {
        this.newsProcessStatusOptions = response.data;
      })
    },
    /** 查询内容列表 */
    getList() {
      this.loading = true;
      listTransportNews(this.queryParams).then(response => {
        this.newsList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /**查询分类树结构*/
    getNewsTypeList() {
      this.loading = true;
      listNewsType(this.queryParams).then(response => {
        this.newsTypeOptions = response.data;
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
        if (list[i].deptId == row.branchDeptId) {

          return list[i].deptName;
        }
      }
    },
    //新闻类型格式化
    newsTypeFormat(row, column) {
      let list = this.newsTypeOptions;
      for (let i in list) {
        if (list[i].id == row.newsTypeId) {
          return list[i].name;
        }
      }
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
    /** 修改按钮操作 */
    handleUpdate(row) {
      const id = row.id || this.ids
      this.editDialogObj.id = id;
      this.editDialogObj.open = true;
      this.editDialogObj.title = '修改新闻';
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
    /**转载新闻*/
    startTransport(row) {
      this.$confirm('转载会把权限提升为全行可见，是否转载该新闻？', "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "info"
      }).then(function (res) {
        return transport(row.id);
      }).then((res) => {
        if (res.code == 200) {
          this.getList();
          this.msgSuccess("发起成功");
        } else {
          this.msgError(res.msg);
        }
      })
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
