<template>
  <div class="windowTemplate">
    <el-row>
      <navbar currentPage="待办中心"></navbar>
    </el-row>
    <el-row>
      <div class="todoMain">
        <el-tabs v-model="activeName" lazy="true" @tab-click="tabClick">
          <el-tab-pane label="我的待办" name="todo">
            <el-row>
              <el-form :model="toDoQueryParams" :inline="true">
                <el-form-item label="工单编号" prop="businessKey">
                  <el-input
                    v-model="toDoQueryParams.businessKey"
                    placeholder="请输入工单编号"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="工单名称" prop="requestName">
                  <el-input
                    v-model="toDoQueryParams.requestName"
                    placeholder="请输入工单名称"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="所属系统" prop="clientName">
                  <el-select v-model="toDoQueryParams.clientName"  @change="list" filterable clearable placeholder="请选择">
                    <el-option
                      v-for="item in appList "
                      :key="item.id"
                      :label="item.name"
                      :value="item.name">
                    </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" icon="el-icon-search" style="padding: 6px 10px;" @click="list">搜索</el-button>
                  <el-button icon="el-icon-refresh" style="padding: 6px 10px;" @click="resetTaskQuery">重置</el-button>
                </el-form-item>
                <el-row>
                  <el-form-item>
                    <el-switch
                      v-model="batchApprove"
                      @change="switchModeBatchTask"
                      active-text="批量模式">
                    </el-switch>
                  </el-form-item> 
                  <el-form-item v-if="batchApprove">
                    <el-button type="primary" icon="el-icon-circle-check" style="padding: 6px 10px" @click="batchAgrees">批准</el-button>
                    <span style="margin-left: 14px; font-size:14px;color:#606266">请勾选如下审批工单，并点击“批准”即可完成批量审批</span>
                  </el-form-item>
                </el-row>
              </el-form>
            </el-row>
            <el-dialog
              title="审批意见"
              :visible.sync="commentsDialogVisible"
              width="400px"
              :before-close="commentsDialoghandleClose">
              <el-input
                style="padding: 5px;"
                type="textarea"
                :rows="4"
                v-model="commentsText"
                resize="none"
                maxlength="100"
                show-word-limit
                placeholder="请输入审批意见">
              </el-input>
              <span slot="footer" class="dialog-footer">
                <el-button @click="commentsDialoghandleClose" style="padding: 6px 10px;">关 闭</el-button>
                <el-button type="primary" @click="batchSubmit" :loading="confirmLoading" style="padding: 6px 10px;">确 定</el-button>
              </span>
            </el-dialog>
            <el-table :data="dataList" @row-click="todoClick" @selection-change="handleSelectionTaskChange"  v-loading="taskLoading">
              <el-table-column
                type="selection"
                width="55"
                v-if="batchApprove">
              </el-table-column>
              <el-table-column label="所属系统" prop="clientName" width="100" :show-overflow-tooltip="true"/>
              <el-table-column label="工单编号" prop="businessKey" width="220" :show-overflow-tooltip="true"/>
              <el-table-column label="工单名称" prop="requestName" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span v-show="getLevel(scope.row.businessLevel).text" style="font-size: 12px;background-color: transparent;border-radius: 2px;padding: 2px 4px;margin-right: 7px;" class="level" :style="{'color':getLevel(scope.row.businessLevel).color , 'backgroundColor': getLevel(scope.row.businessLevel).bgColor}">{{getLevel(scope.row.businessLevel).text && `${getLevel(scope.row.businessLevel).text}`}}</span>
                  <span>{{scope.row.requestName}}</span>
                </template>
              </el-table-column>
              <el-table-column label="申请人" prop="startNickName" width="100"/>
              <el-table-column label="创建日期" prop="taskStartTime" width="100" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span :title="parseTime(scope.row.taskStartTime, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.taskStartTime, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>
             <!-- <el-table-column label="接收日期" align="center" prop="operateDate" width="100">
                <template slot-scope="scope">
                  <span :title="parseTime(scope.row.operateDate, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.operateDate, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>-->
              <!--
              <el-table-column label="批量审核" align="center" prop="isBatchApproval" width="100">
              <template slot-scope="scope">
              <span v-if="scope.row.isBatchApproval === 1">支持</span>
              <span v-else>不支持</span>
              </template>
              </el-table-column>
                  -->
            </el-table>
            <div class="page">
              <pagination
                v-show="total>0"
                :total="total"
                :page.sync="pageNum"
                :limit.sync="pageSize"
                @pagination="list">
              </pagination>
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的已办" name="finish">
            <span slot="label">
              <span>我的已办</span>
              <el-tooltip slot="label" style="margin-left: 8px" class="item" effect="dark" content="如需查询2021年8月1日之前工单，请通过应用中心登录原系统查询" placement="top">
                <i class="el-icon-warning"></i>
              </el-tooltip>
            </span>
            <el-row>
              <el-form :model="finishQueryParams" :inline="true">
                <el-form-item label="工单编号" prop="businessKey">
                  <el-input
                    v-model="finishQueryParams.businessKey"
                    placeholder="请输入工单编号"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="工单名称" prop="requestName">
                  <el-input
                    v-model="finishQueryParams.requestName"
                    placeholder="请输入工单名称"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="所属系统" prop="clientName">
                  <el-select v-model="finishQueryParams.clientName"  @change="list" filterable clearable placeholder="请选择">
                    <el-option
                      v-for="item in appList "
                      :key="item.id"
                      :label="item.name"
                      :value="item.name">
                    </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" icon="el-icon-search" style="padding: 6px 10px;" @click="list">搜索</el-button>
                  <el-button icon="el-icon-refresh" style="padding: 6px 10px;" @click="resetFinishQuery">重置</el-button>
                </el-form-item>
              </el-form>
            </el-row>
            <el-table :data="dataList" @row-click="finishClick">
              <el-table-column label="所属系统" prop="clientName" width="100" :show-overflow-tooltip="true"/>
              <el-table-column label="工单编号" prop="businessKey" width="220" :show-overflow-tooltip="true"/>
              <el-table-column label="工单名称" prop="requestName" :show-overflow-tooltip="true"/>
              <el-table-column label="申请人"  prop="startNickName" width="100"/>
              <el-table-column label="创建日期" prop="taskStartTime" width="100" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span :title="parseTime(scope.row.taskStartTime, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.taskStartTime, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>


           <!--  <el-table-column label="接收日期" align="center" prop="operateDate" width="100">
                <template slot-scope="scope">
                  <span :title="parseTime(scope.row.operateDate, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.operateDate, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>-->
              <el-table-column label="流程状态" prop="processStatus" :formatter="processStatusFormat" width="100"/>
            </el-table>
            <div class="page">
              <pagination
                v-show="total>0"
                :total="total"
                :page.sync="pageNum"
                :limit.sync="pageSize"
                @pagination="list">
              </pagination>
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的申请" name="apply">
            <span slot="label">
              <span>我的申请</span>
              <el-tooltip slot="label" style="margin-left: 8px" class="item" effect="dark" content="如需查询2021年8月1日之前工单，请通过应用中心登录原系统查询" placement="top">
                <i class="el-icon-warning"></i>
              </el-tooltip>
            </span>
            <el-row>
              <el-form :model="applyQueryParams" :inline="true">
                <el-form-item label="工单编号" prop="businessKey">
                  <el-input
                    v-model="applyQueryParams.businessKey"
                    placeholder="请输入工单编号"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="工单名称" prop="requestName">
                  <el-input
                    v-model="applyQueryParams.requestName"
                    placeholder="请输入工单名称"
                    clearable
                    size="small"
                    @keyup.enter.native="list"
                  />
                </el-form-item>
                <el-form-item label="所属系统" prop="clientName">
                  <el-select v-model="applyQueryParams.clientName"  @change="list" filterable clearable placeholder="请选择">
                    <el-option
                      v-for="item in appList "
                      :key="item.id"
                      :label="item.name"
                      :value="item.name">
                    </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" icon="el-icon-search" style="padding: 6px 10px;" @click="list">搜索</el-button>
                  <el-button icon="el-icon-refresh" style="padding: 6px 10px;" @click="resetApplyQuery">重置</el-button>
                </el-form-item>
              </el-form>
            </el-row>
            <el-table :data="dataList" @row-click="finishClick">
              <el-table-column label="所属系统" prop="clientName" width="100" :show-overflow-tooltip="true"/>
              <el-table-column label="工单编号" prop="businessKey" width="220" :show-overflow-tooltip="true"/>
              <el-table-column label="工单名称" prop="requestName" :show-overflow-tooltip="true"/>
              <el-table-column label="申请人"  prop="startNickName" width="100"/>
              <el-table-column label="创建日期" prop="taskStartTime" width="100" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span :title="parseTime(scope.row.processStartTime, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.processStartTime, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>
             <!-- <el-table-column label="接收日期" align="center" prop="operateDate" width="100">
                 <template slot-scope="scope">
                  <span :title="parseTime(scope.row.operateDate, '{y}-{m}-{d} {h}:{i}:{s}')">{{ parseTime(scope.row.operateDate, '{y}-{m}-{d}') }}</span>
                </template>
              </el-table-column>-->
              <el-table-column label="流程状态" prop="processStatus" width="100" :formatter="processStatusFormat"/>
            </el-table>
            <div class="page">
              <pagination
                v-show="total>0"
                :total="total"
                :page.sync="pageNum"
                :limit.sync="pageSize"
                @pagination="list">
              </pagination>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-row>
  </div>
</template>

<script>
  import {batchAction,listApply, listFinish, listTodo,getBuildssolink} from "@/api/console/bpm/workflow";
  import {allApp} from "@/api/console/system/app";
  import navbar from '@/views/home/component/navbar'

  export default {
    name: "moreTodoTemplate",
    components: {navbar},
    data() {
      return {
        confirmLoading:false,
        timer:undefined,
        taskLoading:false,
        handleSelectionTaskList:[],
        actionType: 1,
        commentsText:'同意',
        commentsDialogVisible:false,
        batchApprove: false,
        appList:[],
        dataList: [],
        toDoQueryParams:{
          businessKey:undefined,
          requestName:undefined,
          clientName:undefined
        },
        finishQueryParams:{
          businessKey:undefined,
          requestName:undefined,
          clientName:undefined
        },
        applyQueryParams:{
          businessKey:undefined,
          requestName:undefined,
          clientName:undefined
        },
        total: 0,
        pageNum: 1,
        pageSize: 10,
        activeName: '',
        search: undefined,
        processStatusOptions: []
      }
    },
    created() {
      this.getDicts('bpm_process_status').then(response => {
        this.processStatusOptions = response.data;
      })
      this.activeName = localStorage.getItem('toDoActive') || 'todo'
      this.list();
      this.loadTimer();
      allApp(undefined).then(response => {
        this.appList = [];
        if(response !== undefined && response !==null && response.length > 0) {
          response.forEach((item, index, arr) => {
            //过滤是列表显示的应用集合
            if(item.isShow === 1) {
              let poDada = {
                name: item.name,
                id: item.id
              }
              this.appList.push(poDada);
            }
          });
        }
      });
    },
    methods: {
      getLevel (val) {
        switch (val) {
          case 0:
            return {
              className: 'common',
              color: '#2272DE'
            }
          case 1:
            return {
              className: 'important',
              color: '#BF8AFF',
              bgColor: 'rgba(205, 130, 239, .14)',
              text: '重要'
            }
          case 2:
            return {
              className: 'urgent',
              color: '#FF8438',
              bgColor: 'rgba(255, 132, 56, .14)',
              text: '紧急'
            }
          default:
            break
        }
      },
      closeTimer(){
        if(this.timer){
          clearInterval(this.timer);
        }
      },
      loadTimer(){
        //定时刷新待办列表，默认1分钟刷新一次
        this.timer  =  setInterval(() =>{
          this.list();
        },60000);
      },
      //批量提交
      batchSubmit(){
        this.taskLoading = true
        let data = {
          ids:this.handleSelectionTaskList,
          remark:this.commentsText
        }
        this.confirmLoading=true;
        let self = this
        batchAction(data).then(response => {
          //释放loadding
          if (response.code == 200) {
            setTimeout(function () {
              self.list();
              self.msgSuccess("处理成功");
              self.taskLoading = false
              self.commentsDialogVisible = false;
              self.confirmLoading=false;
              //重新加载定时器
            },2000)
          } else {
            self.commentsDialogVisible = false;
            self.taskLoading = false
            self.msgError(response.msg);
            self.confirmLoading=false;
          }

        })

      },
      batchAgrees(){
        if(this.handleSelectionTaskList.length === 0){
          this.msgWarning("未选择处理项");
          return;
        }
        this.commentsText='同意'
        this.commentsDialogVisible = true
      },
      commentsDialoghandleClose(){
        this.commentsText=''
        this.commentsDialogVisible = false
      },
      handleSelectionTaskChange(selection){
        this.handleSelectionTaskList = selection.map(item => item.taskId)
      },
      switchModeBatchTask(val){
        //开启批量模式列表不自动刷新，关闭批量后禁止加载自动刷新
        if(val){
          //摧毁定时器防止刷新
          this.closeTimer();
          //查询批量审批
          this.toDoQueryParams.isBatchApproval = 1
        }else{
          this.loadTimer();
          this.toDoQueryParams.isBatchApproval = undefined;
        }
        this.resetTaskQuery()
      },
      // 返回首页
      goBackIndex () {
        this.$router.push({ path: "/home/index" });
      },
      todoClick(row, column, event){
        this.openTask(row)
      },
      finishClick(row, column, event){
        this.openProcess(row);
      },
      /** 重置按钮操作 */
      resetTaskQuery() {
        this.toDoQueryParams.businessKey=undefined;
        this.toDoQueryParams.requestName=undefined;
        this.toDoQueryParams.clientName=undefined;
        this.pageNum=1;
        this.pageSize=10;
        this.list();
      },
      /** 重置按钮操作 */
      resetFinishQuery() {
        this.finishQueryParams.businessKey=undefined;
        this.finishQueryParams.requestName=undefined;
        this.finishQueryParams.clientName=undefined;
        this.pageNum=1;
        this.pageSize=10;
        this.list();

      },
      /** 重置按钮操作 */
      resetApplyQuery() {
        this.applyQueryParams.businessKey=undefined;
        this.applyQueryParams.requestName=undefined;
        this.applyQueryParams.clientName=undefined;
        this.pageNum=1;
        this.pageSize=10;
        this.list();

      },
      list() {
        this.dataList = [];
        this.total = 0;
        if (this.activeName == 'todo') {
          let params = this.toDoQueryParams;
          params.pageNum = this.pageNum;
          params.pageSize = this.pageSize;
          params.isLikeQuery = true;
          listTodo(params).then(response => {
            this.dataList = response.rows;
            this.total = response.total;
            this.pageNum=params.pageNum;
            this.pageSize=params.pageSize;
          });
        } else if (this.activeName == 'finish') {
          let params = this.finishQueryParams;
          params.pageNum = this.pageNum;
          params.pageSize = this.pageSize;
          params.isLikeQuery = true;
          listFinish(params).then(response => {
            this.dataList = response.rows;
            this.total = response.total;
            this.pageNum=params.pageNum;
            this.pageSize=params.pageSize;
          });
        } else if (this.activeName == 'apply') {
          let params = this.applyQueryParams;
          params.pageNum = this.pageNum;
          params.pageSize = this.pageSize;
          params.isLikeQuery = true;
          listApply(params).then(response => {
            this.dataList = response.rows;
            this.total = response.total;
            this.pageNum=params.pageNum;
            this.pageSize=params.pageSize;
          });
        }
      },
      // 流程状态字典翻译
      processStatusFormat(row, column) {
        return this.selectDictLabel(this.processStatusOptions, row.processStatus);
      },
      tabClick(tab, event) {
        this.activeName = tab.name;
        this.pageNum=1;
        this.pageSize=10;
        this.list();
      },
      handleSizeChange(val) {
        this.list();
      },
      handleCurrentChange(val) {
        this.list();
      },
      openProcess(row) {
        let self = this;
        let w = screen.width * 0.9;
        let h = screen.height * 0.8;
        let iTop = (window.screen.height - 30 - h) / 2;       //获得窗口的垂直位置;
        let iLeft = (window.screen.width - 10 - w) / 2;        //获得窗口的水平位置;
        //判断是门户的待办还是其他系统的待办跳转不同的位置办理
        if('APP001'=== row.clientId){
          window.open('/home/bpm/process/' + row.newsInstId, '查看流程', "resizable=yes,top=" + iTop + ",left=" + iLeft + ",width=" + w + ",height=" + h + ",status=no,menubar=no,toolbar=no,Scrollbars=no,Location=no,Direction=no,resizable=no");
        }else{
          getBuildssolink(2,row.id).then(response => {
            if(response.code===200){
              let ssoUrl=response.msg;
              window.open(ssoUrl, '查看流程', "top="+iTop+",left="+iLeft+",width="+w+",height="+h+",resizable=no,scrollbars=yes,status=no,menubar=no,toolbar=no,location=no,direction=no");;
            }else{
              this.msgWarning(response.msg)
            }
          });
        }
      },
      openTask(row) {
        let self = this;
        let w = screen.width * 0.9;
        let h = screen.height * 0.8;
        let iTop = (window.screen.height - 30 - h) / 2;       //获得窗口的垂直位置;
        let iLeft = (window.screen.width - 10 - w) / 2;        //获得窗口的水平位置;
        //判断是门户的待办还是其他系统的待办跳转不同的位置办理
        if('APP001'=== row.clientId){
          let windowHandler = window.open('/home/bpm/task/' + row.taskId, '审批流程', "top="+iTop+",left="+iLeft+",width="+w+",height="+h+",resizable=no,scrollbars=yes,status=no,menubar=no,toolbar=no,location=no,direction=no");
          windowHandler.focus();
          const loop = setInterval(item => {
            if (windowHandler.closed) {
              clearInterval(loop);
              self.todo();
            }
          }, 1000);
        }else{
          getBuildssolink(1,row.id).then(response => {
            if(response.code===200){
              let ssoUrl=response.msg;
              let newWin = window.open(ssoUrl, '审批流程', "top="+iTop+",left="+iLeft+",width="+w+",height="+h+",resizable=no,scrollbars=yes,status=no,menubar=no,toolbar=no,location=no,direction=no");;
              let loop = setInterval(function() {
                if(newWin .closed) {
                  clearInterval(loop);
                  setTimeout(function () {
                    self.list();
                  },1000)
                }
              }, 1000);
            }else{
              this.msgWarning(response.msg)
            }
          });
        }
      }
    }
  }
</script>

<style lang="scss" scoped>

  ::v-deep .navbar-wrapper{
    max-width: 1200px;
    margin: 0 auto;
  }
  ::v-deep .el-tabs__item i{
    color: #FFB426;
  }
  ::v-deep .el-tabs__item.is-active i{
    color: #FFB426;
  }
  .windowTitle2 {
    margin: 0 auto;
    height: 60px;
    line-height: 60px;
    color: #666666;
    font-size: 12px;
    text-align: right;
    display: flex;
    justify-content: space-between;
    align-items: center;
    .back{
      height: 36px;
      line-height: 36px;
      width: 64px;
      text-align: center;
      // line-height: auto;
      border: 1px solid #DCDFE6;
      color:#333;
      background-color: #fff;
      cursor: pointer;
      padding:0 6px;
      border-radius: 4px;
      font-size: 14px;
    }
  }

  .windowTitle2, .todoMain {
    max-width: 1200px;
    margin: 0 auto;
    position: relative;
    top: 0;
  }


  .el-scrollbar>div>ul>li {
    padding: 0 10px !important;;
  }
  >>>.el-input__inner {
    height: 28px;
    line-height: 28px;
    border-radius: 4px !important;
  }

  * {
    margin: 0;
    padding: 0;
  }

  .windowTemplate {
    // min-width: 1280px;
    background: #ffffff;
  }

  .windowTitle {
    margin: 0 auto;
    height: 60px;
    line-height: 60px;
    color: #666666;
    font-size: 12px;
    text-align: right;
  }

  .windowTitle, .todoMain {
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
    min-height: 600px;
  }

  .search {
    position: absolute;
    top: 0;
    right: 0;
    z-index: 111111;
  }

  .search ::v-deep input {
    width: 240px;
    height: 32px;
    line-height: 32px;
    background: #F2F3F9;
    border-radius: 20px !important;
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

  ::v-deep .el-table--mini{
    font-size: 14px;
  }
  ::v-deep .el-table{
    .cell{
      font-size: 14px;
    }
    .el-table__row{
      cursor: pointer;
    }
  }


  ::v-deep .el-dialog{
    display: flex;
    flex-direction: column;
    margin:0 !important;
    position:absolute;
    top:50%;
    left:50%;
    transform:translate(-50%,-50%);
    /*height:600px;*/
    max-height:calc(100% - 30px);
    max-width:calc(100% - 30px);
  }
  ::v-deep .el-dialog ::v-deep .el-dialog__body{
    flex:1;
    overflow: auto;
  }

  ::v-deep .el-dialog__body {
     padding: 0 10px;
     color: #606266;
     font-size: 14px;
     word-break: break-all;
   }
</style>
