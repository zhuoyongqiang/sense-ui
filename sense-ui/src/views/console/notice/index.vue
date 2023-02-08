<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="标题" >
        <el-input
          v-model="queryParams.title"
          placeholder="请输入标题"
          clearable
          size="small"
        />
      </el-form-item>
      <el-form-item label="首页显示" >
        <el-select v-model="queryParams.isRotation" clearable placeholder="请选择">
          <el-option
            clearable
            v-for="item in commonNormalDisableOptions"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
       <el-form-item label="状态">
        <el-select v-model="queryParams.status" clearable placeholder="请选择">
          <el-option
           clearable
            v-for="item in commonStatus"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="数据状态" >
        <el-select v-model="queryParams.dataStatus" clearable placeholder="请选择">
          <el-option
            clearable
            v-for="item in noticeDataStatus"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
       <el-form-item label="浏览量" >
        <el-input-number v-model="queryParams.minNum"   controls-position="right"  :precision="0" :min="0"  ></el-input-number>～
        <el-input-number v-model="queryParams.maxNum"   controls-position="right" :precision="0" :min="0"  ></el-input-number>
      </el-form-item>
      <el-form-item label="发布时间" >
          <el-date-picker
            clearable
            v-model="queryParams.releaseStartTime"
            type="datetime"
            value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="选择开始时间">
          </el-date-picker>
          ～
          <el-date-picker
            clearable
            v-model="queryParams.releaseEndTime"
            value-format="yyyy-MM-dd HH:mm:ss"
            type="datetime"
            placeholder="选择结束时间">
          </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['info:notice:add']"
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
          v-hasPermi="['info:notice:edit']"
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
          v-hasPermi="['info:notice:delete']"
        >删除
        </el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="公告标题" align="center" prop="title" width="100" show-overflow-tooltip/>
      <el-table-column label="作者" align="center" prop="author" width="100" />
      <el-table-column label="首页显示" align="center" prop="isRotation" :formatter="rotationFormat" />
      <el-table-column label="是否置顶" align="center" prop="isTop" :formatter="topFormat"  />
      <el-table-column label="状态" align="center" prop="status" :formatter="statusFormat" />
      <el-table-column label="数据状态" align="center" prop="dataStatus" >
        <template slot-scope="scope">
          <span v-if="scope.row.dataStatus=='1'" style="color:orangered">临时保存</span>
          <span v-if="scope.row.dataStatus=='2'" style="color:#67C23A">发布</span>
        </template>
      </el-table-column>
      <el-table-column label="浏览量" align="center" prop="browseNum" width="70"/>
      <el-table-column label="排序号" align="center" prop="sort" width="70"/>
      <el-table-column label="发布时间" align="center" prop="releaseTime"  width="140">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.releaseTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime"  width="140">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['info:notice:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['info:notice:delete']"
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
    <edit-dialog  :dialogObj="dialogObj" @success="dialogSuccess"></edit-dialog>
  </div>
</template>
<script>
import editDialog from './edit'
import {allNotice, listNotice, getNotice,delNotice} from "@/api/console/info/notice";
export default {
  name: "notice",
  components: {editDialog},
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
      // 公告表格数据
      list: [],
      //弹出层对象
      dialogObj:{
        //对象ID
        id:undefined,
        // 弹出层标题
        title: "",
        // 是否显示弹出层
        open: false,
        //打开操作
        event:undefined
      },
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        title: null,
        isRotation:null,
        status:null,
        dataStatus:undefined,
        dateRange:null,
        minNum:undefined,
        maxNum:undefined,
        releaseStartTime:undefined,
        releaseEndTime:undefined,
      },
      //字典
      commonNormalDisableOptions:[],
      //数据状态集合
      noticeDataStatus:[],
      //状态集合
      commonStatus:[]
    };
  },
  created() {
    this.getList();
    this.getDicts('common_yes_no').then(response => {
      this.commonNormalDisableOptions = response.data;
    });
    this.getDicts('notice_data_status').then(response => {
      this.noticeDataStatus = response.data;
    });
    this.getDicts('common_status').then(response => {
      this.commonStatus = response.data;
    });
  },
  methods: {
    /** 查询公告列表 */
    getList() {
      this.loading = true;
      listNotice(this.queryParams).then(response => {
        this.list = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 表单重置
    reset() {
      this.form = {
        status:'1',
        isRotation:'1',
        sort:1,
        
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
      this.queryParams.mixNum=undefined;
      this.queryParams.maxNum=undefined;
      this.handleQuery();
    },
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.commonStatus, row.status);
    },
    //数据状态格式化
    dataStatusFormat(row, column) {
      return this.selectDictLabel(this.noticeDataStatus, row.dataStatus);
    },
    //首页显示格式化
    rotationFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isRotation);
    },
    //是否轮播格式化
    topFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isTop);
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
      this.dialogObj.open=true;
      this.dialogObj.title="添加公告";
      this.dialogObj.event="add";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      this.dialogObj.open=true;
      this.dialogObj.title="修改公告";
      this.dialogObj.id=id;
      this.dialogObj.event="edit";
    },
    //新增修改成功后的回调
    dialogSuccess(){
      this.dialogObj.open=false;
      this.getList();
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认删除选中数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delNotice(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      })
    },
  }
};
</script>
<style lang="scss" scoped>
  .image-upload{
    ::v-deep {
      .el-upload-list__item-thumbnail{
        width: 100%;
        height: 200px;
        position: absolute;
        top: 0;
        bottom: 0;
        right: 0;
      }
     
      .el-upload-list--picture .el-upload-list__item{
        width: 100%;
        height: 200px;
        z-index: 100;
      }
      .el-upload-list__item-name{
          width: 0px;
          display: none;

      }
      .el-icon-close-tip{
        display: none;
        width: 0;
      }
      .el-icon-close{
        z-index: 1000;
      }
    } 
  }
</style>
