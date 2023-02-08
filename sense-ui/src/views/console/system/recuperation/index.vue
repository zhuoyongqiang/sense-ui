<template>
  <div class="windowTemplate">
    <el-row>
      <navbar currentPage="离职用户" :hasBack="true"></navbar>
    </el-row>
    <el-row>
      <div class="todoMain">
        <el-row>
          <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
            <el-form-item label="域账号" prop="userName">
              <el-input
                v-model="queryParams.userName"
                placeholder="请输入域账号"
                clearable
                size="small"
                @keyup.enter.native="handleQuery"
              />
            </el-form-item>
            <el-form-item label="姓名" prop="nickName">
              <el-input
                v-model="queryParams.nickName"
                placeholder="请输入姓名"
                clearable
                size="small"
                @keyup.enter.native="handleQuery"
              />
            </el-form-item>
            <el-form-item label="入职时间" prop="entryDate">
              <el-date-picker
                v-model="entryDate"
                type="daterange"
                :editable="false"
                size="small"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="yyyy-MM-dd"
                @change="putEntryDate">
              </el-date-picker>
            </el-form-item>
            <el-form-item label="离职时间" prop="exitTime">
              <el-date-picker
                v-model="exitTime"
                type="daterange"
                :editable="false"
                size="small"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="yyyy-MM-dd"
                @change="putExitTime">
              </el-date-picker>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
              <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>
        </el-row>
        <el-table v-loading="loading" :data="recuperationList" ref="refTable">

          <el-table-column label="域账号" align="center" prop="userName" />
          <el-table-column label="姓名" align="center" prop="nickName" />
          <el-table-column label="入职时间" align="center" prop="entryDate" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.entryDate, '{y}-{m}-{d}') }}</span>
            </template>
          </el-table-column>
          <!-- <el-table-column label="状态" align="center" prop="status" /> -->
          <el-table-column label="离职时间" align="center" prop="exitTime" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.exitTime, '{y}-{m}-{d}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center">
            <template slot-scope="scope">
              <el-button type="text" size="small" @click="toDetail(scope.row)">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>

        <pagination
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </div>
    </el-row>
    <el-dialog :visible.sync="show" title="应用账号详情" width="80%" append-to-body>
      <el-table
        v-loading="detailLoading"
        :data="tableData"
        :row-class-name="getRowClassName"
        style="width: 100%"
        class="expand-table">
        <el-table-column type="expand">
          <template slot-scope="scope">
            <el-table
              :show-header="false"
              :data="scope.row.recuperationList.slice(1, 10)"
              style="width: 100%; height:auto; max-height: 40vh;overflow:auto">
                <el-table-column label="应用名称" align="center">
                  <template>
                    <span>{{scope.row.name }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="应用账号" align="center">
                  <template>
                    <span>{{scope.row.staffAcount }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="账号创建时间" align="center">
                  <template>
                    <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="账号状态" align="center">
                  <template>
                    <span>{{scope.row.status }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="执行（禁用）时间" align="center" prop="recuperationTime" >
                  <template slot-scope="scopeE">
                    <span>{{ parseTime(scopeE.row.recuperationTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="执行人" align="center" prop="recycler" />
            </el-table>
            <div class="tip" v-show="scope.row.recuperationList.length > 10"><span class="text">仅展示近10条操作记录</span></div>
          </template>
        </el-table-column>
        <el-table-column label="应用名称" align="center" prop="name" />
          <el-table-column label="应用账号" align="center" prop="staffAcount" />
          <el-table-column label="账号创建时间" align="center" prop="createTime" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="账号状态" align="center" prop="status" />
          <el-table-column label="最近执行（禁用）时间" align="center" prop="recuperationTime" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.recuperationTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="最近执行人" align="center" prop="recycler" />
      </el-table>
      <!-- <div class="dialogDiv">
        <el-table :data="childProp"  border style="width: 100%">
          <el-table-column label="应用名称" align="center" prop="name" />
          <el-table-column label="应用账号" align="center" prop="staffAcount" />
          <el-table-column label="账号创建时间" align="center" prop="createTime" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="账号状态" align="center" prop="status" />
          <el-table-column label="执行（禁用）时间" align="center" prop="recuperationTime" >
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.recuperationTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
            </template>
          </el-table-column>
          <el-table-column label="执行人" align="center" prop="recycler" />
        </el-table>
      </div> -->
    </el-dialog>
  </div>
</template>

<script>
import { listRecuperation, getRecuperation, accountList } from "@/api/console/system/recuperation";
import navbar from '@/views/home/component/navbar'

export default {
  name: "Recuperation",
  components: {
    navbar
  },
  data() {
    return {
      // 遮罩层
      loading: true,
      // 详情加载遮罩层
      detailLoading: false,
      // 导出遮罩层
      exportLoading: false,
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
      // sense表格数据
      recuperationList: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        nickName: null,
        params: {}
      },
      entryDate:null,
      exitTime: null,
      show: false,
      childProp: null,
      tableData: [] // 详情列表
    };
  },
  created() {
    this.getList();
  },
  methods: {
    getRowClassName ({row, rowIndex}) {
      if (row.recuperationList.length < 2) {
        return 'row-expand-cover'
      }
    },
    /** 查询sense列表 */
    getList() {
      this.loading = true;
      listRecuperation(this.queryParams).then(response => {
        this.recuperationList = response.rows;
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
      this.resetForm("queryForm");
      this.entryDate = null;
      this.exitTime = null;
      this.queryParams.params = {}
      this.handleQuery();
    },
    toDetail(row){
      this.tableData = []
      this.show = true
      this.detailLoading = true
      accountList(row.userId).then((resp) => {
        this.detailLoading = false
        if (resp.code === 200) {
          // this.childProp = resp.rows
          this.tableData = resp.rows.map(v => {
            return {
              ...v,
              recuperationTime: v.recuperationList.length ? v.recuperationList[0].recuperationTime : null,
              recycler: v.recuperationList.length ? v.recuperationList[0].recycler : null
            }
          })
        }
      }).catch(() => {
        this.detailLoading = false
        this.$msgError('应用详情加载失败')
      })
      // console.log(val)
      // this.childProp = val.row.children

    },
    putEntryDate(val){
      if(val){
        // this.queryParams.params = {"startEntryDate":val[0],"endEntryDate":val[1]}
        this.queryParams.params.startEntryDate=val[0];
        this.queryParams.params.endEntryDate=val[1];
      }else{
        this.queryParams.params.startEntryDate='';
        this.queryParams.params.endEntryDate='';
      }
    },
    putExitTime(val){
      if (val){
        this.queryParams.params.startDate=val[0];
        this.queryParams.params.endDate=val[1];
      }else {
        this.queryParams.params.startDate='';
        this.queryParams.params.endDate='';
      }
    }

  }
};
</script>

<style lang="scss" scoped>
  ::v-deep .navbar-wrapper{
    width: 1200px;
    margin: 0 auto;
  }

  .windowTemplate {
    // min-width: 1280px;
    background: #ffffff;
  }

  .windowTitle2 {
    margin: 0 auto;
    height: 60px;
    line-height: 60px;
    color: #666666;
    font-size: 12px;
    text-align: right;
  }

  .windowTitle2, .todoMain {
    max-width: 1200px;
    margin: 0 auto;
    position: relative;
    top: 0;
  }

  .todoMain {
    margin-top: 0px;
    margin-bottom: 40px;
    position: relative;
    top: 0;
  }

  .search {
    position: absolute;
    top: 0;
    right: 0;
    z-index: 111111;
  }



  .search .el-input__icon {
    line-height: 32px;
  }

  .page {
    margin-top: 12px;
    margin-bottom: 15px;
  }

  .el-breadcrumb {
    line-height: 60px;
  }
  .dialogDiv {
    height: 500px;
    overflow: auto;
  }

  
  ::v-deep .expand-table{
    .el-table__body{
      min-width: 100%;
      width: auto!important;
    }
    .el-table::before{
      display: none;
    }
  }
  ::v-deep .row-expand-cover .el-table__expand-icon{
    visibility: hidden;
  }
  ::v-deep .el-table__expanded-cell{
    padding: 10px 0 10px 50px;
  }
  .tip{
    color:#2272DE;
    text-align: center;
    margin-top: 10px;
    position: relative;
    height: 32px;
    .text{
      position: absolute;
      top: 50%;
      left: 50%;
      z-index: 10;
      transform: translate(-50%, -50%);
      background-color: #fff;
      padding: 0 10px;
    }
    &::after{
      content: '';
      display: block;
      position: absolute;
      top: 50%;
      left: 0;
      // background-color: #ccc;
      transform: translate(0, -50%);
      z-index: 1;
      width: 100%;
      height: 1px;
      background: linear-gradient(to right, #ccc, #ccc 5px, transparent 5px, transparent);
      background-size: 10px 100%;
    }
  }
</style>
