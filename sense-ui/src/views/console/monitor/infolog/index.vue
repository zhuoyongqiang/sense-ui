<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="68px">
      <el-form-item label="名称">
        <el-input v-model="queryParams.title" placeholder="请输入名称" clearable size="small" />
      </el-form-item>
      <el-form-item label="用户姓名">
        <el-input v-model="queryParams.stffName" placeholder="请输入用户姓名" clearable size="small" />
      </el-form-item>
      <el-form-item label="点击时间">
        <el-date-picker clearable v-model="queryParams.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss"
          placeholder="选择开始时间">
        </el-date-picker>
        ～
        <el-date-picker clearable v-model="queryParams.endTime" value-format="yyyy-MM-dd HH:mm:ss" type="datetime"
          placeholder="选择结束时间">
        </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>
    <el-tabs v-model="queryParams.type" style="padding-left:10px;" @tab-click="handleClick">
      <el-tab-pane :label="item.dictLabel" :name="item.dictValue" v-for="item in infoLogTypes" :key="item.id">
        <el-table v-loading="loading" :data="list">
          <el-table-column label="名称" align="center" prop="title" show-overflow-tooltip />
          <el-table-column label="用户账号" align="center" prop="stffAccount" />
          <el-table-column label="用户姓名" align="center" prop="stffName" />
          <el-table-column label="用户手机号" align="center" prop="phonenumber" />
          <el-table-column label="点击时间" align="center" prop="createTime">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
        </el-table>
        <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize" @pagination="getList" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import { listInfoLog } from "@/api/console/info/log";
export default {
  name: "InfoLog",
  components: {},
  data() {
    return {
      // 总条数
      total: 0,
      // 广告表格数据
      list: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        title: null,
        stffName: null,
        startTime: null,
        endTime: null,
        type: '1'
      },
      // 表单参数
      form: {},
      //选中的ID
      checkId: null,
      //字典
      infoLogTypes: [],

    };
  },
  created() {
    this.getList();
    this.getDicts('info_log_type').then(response => {
      this.infoLogTypes = response.data;
    });
  },
  methods: {
    /** 查询日志列表 */
    getList() {
      this.loading = true;
      listInfoLog(this.queryParams).then(response => {
        this.list = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    //tab点击
    handleClick() {
      this.queryParams = {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        title: null,
        stffName: null,
        startTime: null,
        endTime: null,
        type: this.queryParams.type
      },
      this.getList();
    },
    // 表单重置
    reset() {
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
      this.queryParams.mixNum = undefined;
      this.queryParams.maxNum = undefined;
      this.handleQuery();
    },
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.status);
    },
  }
};
</script>
<style lang="scss" scoped>
.image-upload {
  ::v-deep {
    .el-upload-list__item-thumbnail {
      width: 100%;
      height: 200px;
      position: absolute;
      top: 0;
      bottom: 0;
      right: 0;
    }

    .el-upload-list--picture .el-upload-list__item {
      width: 100%;
      height: 200px;
      z-index: 100;
    }

    .el-upload-list__item-name {
      width: 0px;
      display: none;

    }

    .el-icon-close-tip {
      display: none;
      width: 0;
    }

    .el-icon-close {
      z-index: 1000;
    }
  }
}
</style>
