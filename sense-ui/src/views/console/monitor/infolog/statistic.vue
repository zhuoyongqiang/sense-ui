<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="68px">
      <el-form-item label="名称">
        <el-input v-model="queryParams.title" placeholder="请输入名称" clearable size="small" />
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
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['info:infoLogStatistic:export']"
        >导出
        </el-button>
      </el-col>
    </el-row>
    <el-tabs v-model="queryParams.type" style="padding-left:10px;" @tab-click="handleClick">
      <el-tab-pane :label="item.dictLabel" :name="item.dictValue" v-for="item in infoLogTypes" :key="item.id">
        <el-table v-loading="loading" :data="list">
          <el-table-column label="名称" align="center" prop="title" show-overflow-tooltip />
          <el-table-column label="点击次数" align="center" prop="logCount" />
        </el-table>
        <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize" @pagination="getList" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import { selectStatistics } from "@/api/console/info/log";
import axios from 'axios';
import {getToken} from "@/utils/auth";
export default {
  name: "InfoLogStatistic",
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
      selectStatistics(this.queryParams).then(response => {
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
    //导出
    handleExport(){
      axios({
        method: 'post',
        url: process.env.VUE_APP_BASE_API + '/console/info/infoLog/export',
        params: this.queryParams,
        responseType: 'blob',
        headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ' + getToken()
        }
     }).then(resp => {
        const blob = new Blob([resp.data], {type: 'application/octet-stream;charset=utf-8'});
        let fiName=this.getTabName();
        let fileName = fiName+"点击日志统计表.xlsx";
        if (window.navigator && window.navigator.msSaveOrOpenBlob) {
            window.navigator.msSaveOrOpenBlob(blob, fileName);
        } else {
            let eLink = document.createElement('a');
            eLink.download = fileName;
            eLink.style.display = 'none';
            eLink.href = URL.createObjectURL(blob);
            //window.location=  eLink.href ;
            document.body.appendChild(eLink);
            eLink.click();
            URL.revokeObjectURL(eLink.href); // 释放URL 对象
            document.body.removeChild(eLink);
        }
      }).catch(resp => {
        this.$notify.error(resp.msg || '导出失败')
      })
    },
    //获取当前类型的名称
    getTabName(){
      for (let index = 0; index < this.infoLogTypes.length; index++) {
        const element = this.infoLogTypes[index];
        if(element.dictValue==this.queryParams.type){
            return element.dictLabel;
        }
      }
    }
  }
};
</script>
<style lang="scss" scoped>
</style>
