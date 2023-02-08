<template>
  <div class="toDo">
    <el-row>
      <div class="publicBanner">
        <div class="bannerTitle" v-show="!hideMenu">
          <el-breadcrumb separator-class="el-icon-arrow-right">
            <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item>待办</el-breadcrumb-item>
          </el-breadcrumb>
          <div class="publicFlexBetwee">
            <div class="newsTitle">
              <h3>{{ formData.bpmNewsInstance ? formData.bpmNewsInstance.businessName : '' }} -
                {{ bpmNewsTask ? bpmNewsTask.taskName : '' }}</h3>
            </div>
            <div class="processType">
              <p class="wait" v-show="instanceStatus==1">
                等待 {{ resolveTaskListOfNickName(formData.taskList) }} 处理
              </p>
              <p class="type" v-show="instanceStatus==2">
                <img width="70" src="@/assets/images/bpm/icon_process_adopt.png" alt="">
              </p>
              <p class="type" v-show="instanceStatus==0">
                <img width="70" src="@/assets/images/bpm/icon_process_refuse.png" alt="">
              </p>
            </div>
          </div>
        </div>
      </div>
    </el-row>
    <el-row>
      <div class="mainMargin publicMain">
        <el-tabs v-model="activeName" @tab-click="handleClick">
          <el-tab-pane label="预览" name="first">
            <div class="publicFlexBetwee">
              <div class="news">
                <news-process :info-news.sync="formData.infoNews" v-if="formData.bpmNewsInstance.type=='NEWS'"></news-process>
                <app-account-process :form-data.sync="formData.bpmNewsInstance" v-if="formData.bpmNewsInstance.type=='APPACCOUNT'"></app-account-process> 
                <bpm-apply-user-process :form-data.sync="formData.bpmNewsInstance" v-if="formData.bpmNewsInstance.type=='APPLYUSER'"></bpm-apply-user-process>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="流程图" name="second">
            <step-process :flow-image-height.sync="flowImageHeight" :current-node-index.sync="currentNodeIndex"
                          :model-node-list="modelNodeList" :bpm-news-instance="formData.bpmNewsInstance"
                          :instance-id="instanceId"></step-process>
          </el-tab-pane>
          <el-tab-pane label="流程状态" name="third">
            <status-process :task-data.sync="taskData"></status-process>
          </el-tab-pane>


          <el-tab-pane label="附件" name="third2">
            <div class="article-attach" v-if="formData.infoNews==undefined || formData.infoNews.attachmentList==undefined || formData.infoNews.attachmentList.length==0">
              <p style="font-size: 14px;color: #666;te">暂无附件</p>
            </div>
           <div class="article-attach" v-if="formData.infoNews!=undefined && formData.infoNews.attachmentList!=undefined && formData.infoNews.attachmentList.length>0">
              <el-table :data="formData.infoNews.attachmentList" style="width: 100%">
                <el-table-column
                  prop="attachmentTitle"
                  label="附件名称"
                >
                </el-table-column>
                <el-table-column
                  prop="fileType"
                  label="附件格式"
                  width="200">
                </el-table-column>
                <el-table-column
                  label="操作"
                  width="200">
                  <template slot-scope="scope">
                     <el-link :underline="false" type="primary" style="text-decoration:none" :href="'/api/common/download/'+scope.row.id" target="_blank">预览</el-link>
                  </template>
                </el-table-column>
              </el-table>
            </div>
            </el-tab-pane>
        </el-tabs>
      </div>
      <div class="idea">
        <div class="publicMain publicFlexBetwee ">
          <div class="bottomFlex">
            <el-input type="textarea" style="height:100%;" v-model="idea" class="ideaWidth"
                      placeholder="请输入审批意见"></el-input>
          </div>
          <div class="bottomFlex">
            <el-button @click="mobileView=true" class="btn mobileBtn">移动端预览</el-button>
            <el-button class="btn agree" v-if="bpmNewsTask && bpmNewsTask.type==1" @click="agree">同意</el-button>
            <el-button class="btn agree" v-if="bpmNewsTask && bpmNewsTask.type==2" @click="publish">发布</el-button>
            <el-button class="btn agree" v-if="bpmNewsTask && (bpmNewsTask.type==1 || bpmNewsTask.type==2) && formData.bpmNewsInstance.type=='NEWS'" @click="edit">编辑</el-button>
            <el-button class="btn" @click="reject">驳回</el-button>
          </div>
        </div>
      </div>
    </el-row>
    <!--手机预览-->
    <el-dialog
      :visible.sync="mobileView"
      width="370px"
      class="mobileDialog"
    >
      <news-process :info-news.sync="formData.infoNews"></news-process>
    </el-dialog>

    <!--修改窗口-->
    <edit :dialog-obj.sync="editDialogObj" @callback="refresh"></edit>

  </div>
</template>

<script>
import NewsProcess from '@/views/console/platform/page/newsProcess.vue';
import appAccountProcess from '@/views/console/platform/page/appAccountProcess';
import bpmApplyUserProcess from '@/views/console/platform/page/bpmApplyUserProcess';
import StepProcess from "@/views/console/platform/page/stepProcess";
import {agree, getTaskInfo, getTaskListByInstanceId, publish, reject} from "@/api/console/bpm/workflow";
import {globalAgree} from "@/api/console/bpm/openAppAccount";
import {applyUserAgree,applyReject} from "@/api/console/bpm/applyUser";
import StatusProcess from "@/views/console/platform/page/statusProcess";
import Edit from "@/views/console/info/news/edit";

export default {
  name: "toDo",
  components: {StatusProcess, NewsProcess, StepProcess, Edit,appAccountProcess,bpmApplyUserProcess},
  data() {
    return {
      hideMenu: false,
      activeName: 'first',
      type: 'wait',
      idea: '',
      mobileView: false,
      taskId: undefined,
      instanceId: undefined,
      formData: {
       infoNews:{
         attachmentList:[]
       },
       bpmNewsInstance:{}
      },
      flowImageHeight: undefined,
      taskData: [],
      instanceStatus: -1,
      modelNodeList: [],
      bpmNewsTask: {},
       //打开窗口对象
      editDialogObj: {
        id: undefined,
        bpmNewsTask: null,
        open: false,
        title: '修改新闻',
        isApprove: true
      },
      countTime: 3,
      timer: null
    };
  },
  created() {
    if (window.name) {
      this.hideMenu = true
    }
    this.taskId = this.$route.params && this.$route.params.taskId;
    getTaskInfo(this.taskId).then(res => {
      if (res.code == 200) {
        this.formData = res.data;
        console.log(this.formData);
        if(res.data.infoNews!=null){
          this.editDialogObj.id = res.data.infoNews.id;
        }
        this.editDialogObj.bpmNewsTask = res.data.bpmNewsTask;
        this.bpmNewsTask = res.data.bpmNewsTask;
        this.instanceId = this.bpmNewsTask.newsInstId;
        this.instanceStatus = res.data.bpmNewsInstance.status;
        //流程图
        let modelNodeList = [];
        modelNodeList.push({taskName: '发起人', node: 'START', modelNode: 'START'})
        for (let i in this.formData.modelNodeList) {
          modelNodeList.push(this.formData.modelNodeList[i]);
        }
        modelNodeList.push({taskName: '结束', node: 'END', modelNode: 'END'})
        this.modelNodeList = modelNodeList;
        //流程高度
        this.flowImageHeight = this.modelNodeList.length * 60 + 60 + 'px';
      } else {
        if (res.code === 302) {
          location.replace('/home/bpm/process/' + res.msg)
        } else {
          this.$alert(res.msg);
        }
      }
    })
  },
  beforeDestroy() {
    clearInterval(this.timer)
  },
  watch: {
    countTime (val) {
      if (val >= 0) {
        this.$nextTick(() => {
          document.getElementsByClassName('el-message-box__btns')[0].getElementsByTagName('span')[0].innerText = `关闭(${this.countTime})`
        })
      }
    }
  },
  computed: {
    currentNodeIndex() {
      if (this.instanceStatus == 2) {
        return this.modelNodeList.length;
      } else {
        if (JSON.stringify(this.formData) != '{}') {
          let task = this.bpmNewsTask;
          let list = this.modelNodeList;
          if (task != undefined && list != undefined) {
            for (let i = 0; i < list.length; i++) {
              if (list[i].node == task.modelNode) {
                return i;
              }
            }
          }
        }
        return 0;
      }
    }
  },
  methods: {
    handleClick(tab, event) {
      if (tab.index == 2) {
        this.renderProcessData();
      }
    },
    renderProcessData() {
      getTaskListByInstanceId(this.instanceId).then(res => {
        this.taskData = res;
      })
    },
    /**解析任务集合的用户名称*/
    resolveTaskListOfNickName(taskList) {
      let str = '';
      if (taskList) {
        for (let i = 0; i < taskList.length; i++) {
          str += taskList[i].nickName;
          if (i < taskList.length - 1) {
            str += '/';
          }
        }
      }
      return str;
    },
    //发布
    publish() {
      let self = this;
      self.$confirm('是否发布？', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        let params = {};
        params.id = self.taskId;
        if (self.idea == '') {
          params.remark = '发布';
        } else {
          params.remark = self.idea;
        }
        return publish(params);
      }).then((res) => {
        if (res.code == 200) {
          this.timer = setInterval(() => {
            if (this.countTime <= 0) {
              clearInterval(this.timer)
              this.closeWindow()
            } else {
              this.countTime--
            }
          }, 1000);
          this.$alert('发布成功', '提示', {
            confirmButtonText: `关闭(${this.countTime})`,
            callback: action => {
              self.closeWindow();
            }
          })
        } else {
          self.$message.error(res.msg);
        }
      })
    },
    //同意
    agree() {
      let self = this;
      self.$confirm('是否同意？', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        let params = {};
        params.id = self.taskId;
        if (self.idea == '') {
          params.remark = '同意';
        } else {
          params.remark = self.idea;
        }
        if(self.formData.bpmNewsInstance.type=='APPACCOUNT'){
           return globalAgree(params);
        }else if(self.formData.bpmNewsInstance.type=='APPLYUSER'){
          return applyUserAgree(params);
        }else{
           return agree(params);
        }
      }).then((res) => {
        if (res.code == 200) {
          this.timer = setInterval(() => {
            if (this.countTime <= 0) {
              clearInterval(this.timer)
              this.closeWindow()
            } else {
              this.countTime--
            }
          }, 1000);
          this.$alert('您已审批完成', '提示', {
            confirmButtonText: `关闭(${this.countTime})`,
            callback: action => {
              self.closeWindow();
            }
          })
        } else {
          self.$message.error(res.msg);
        }
      })
    },
    //驳回
    reject() {
      let self = this;
      self.$confirm('是否驳回？', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        let params = {};
        params.id = self.taskId;
        if (self.idea == '') {
          params.remark = '驳回';
        } else {
          params.remark = self.idea;
        }
        if(self.formData.bpmNewsInstance.type=='APPACCOUNT'){
           return applyReject(params);
        }else if(self.formData.bpmNewsInstance.type=='APPLYUSER'){
          return applyReject(params);
        }else{
           return reject(params);
        }
      }).then((res) => {
        if (res.code == 200) {
          this.timer = setInterval(() => {
            if (this.countTime <= 0) {
              clearInterval(this.timer)
              this.closeWindow()
            } else {
              this.countTime--
            }
          }, 1000);
          this.$alert('已驳回', '提示', {
            confirmButtonText: `关闭(${this.countTime})`,
            callback: action => {
              self.closeWindow();
            }
          })
        } else {
          self.$message.error(res.msg);
        }
      })
    },
    // 编辑
    edit () {
      this.editDialogObj.open = true;
    },
    refresh () {
      location.reload()
    },
    //关闭窗口
    closeWindow() {
      // let parentWin = window.opener;
      // if (parentWin) {
      // }
      clearInterval(this.timer)
      if (navigator.userAgent.indexOf('MSIE') > 0) {
        window.top.close();
      } else {
        window.close();
      }
    }
  }
};
</script>

<style scoped>

.toDo {
  background: #FFF;
}

.bannerTitle, .tabsMain {
  max-width: 1180px;
  margin: 0 auto;
  position: relative;
  top: 0;
}

.publicMain {
  max-width: 1180px;
  background: #ffffff;
  margin: 0 auto;
}

.publicBanner {
  padding-top: 20px;
  background: #ffffff;
  border-radius: 4px;
  text-align: left;
}

.bannerTitle .el-breadcrumb {
  margin-bottom: 8px;
}

.wait {
  font-size: 14px;
  font-weight: 500;
  color: #2272DE;
  text-align: right;
  line-height: 33px;
}

.processType {
  position: relative;
}

.type {
  position: absolute;
  top: -29px;
  right: 0;
  z-index: 1000;
}

.bannerTitle ::v-deep .el-breadcrumb__item {
  color: #999999;
  font-size: 12px;
  font-weight: 500;
}

.bannerTitle ::v-deep .el-breadcrumb__item:last-child .el-breadcrumb__inner {
  color: #666666;

}

.newsTitle > h3 {
  font-size: 24px;
  color: #333333;
  letter-spacing: 0;

}

.btn {
  width: 84px;
  height: 40px;
  border: 1px solid #2272DE;
  border-radius: 4px;
  font-size: 14px;
  color: #2272DE;
  letter-spacing: 0.13px;
  font-weight: 500;
  padding: 0;
}

.mobileBtn {
  width: 100px;
}

.agree {
  color: #ffffff;
  background: #2272DE;
}

.publicMain ::v-deep .el-tabs__item {
  height: 50px;
  line-height: 50px;
  font-size: 16px;
  color: #333333;
  letter-spacing: 0.15px;
  font-weight: 500;
  padding: 0 30px;
}

.publicMain ::v-deep .el-tabs .el-tabs__header {
  border-bottom: 1px solid #E5E5E5;
  padding-left: 60px;
}

.publicMain ::v-deep .el-tabs__item.is-active {
  font-size: 16px;
  color: #2272DE;
  letter-spacing: 0;
  font-weight: 500;
}

.publicMain ::v-deep .el-tabs__active-bar {
  background-color: #2272DE;
}

.publicMain ::v-deep .el-tabs .el-tabs__content {
  padding: 20px 60px 40px 60px;
}

.news {
  border: solid 1px #CCC;
  border-radius: 4px;
  padding: 20px 40px;
  width: 880px;
  margin: 0 auto;
}

.idea {
  width: 100%;
  height: 80px;
  line-height: 80px;
  background: #FFFFFF;
  box-shadow: 0px -2px 10px 0px rgba(0, 0, 0, 0.07);
  position: fixed;
  bottom: 0;
}

.ideaWidth {
  width: 600px;
  vertical-align: middle;
}

.mainMargin {
  margin-bottom: 100px;
}

.mobileDialog ::v-deep .el-dialog {
  height: 700px;
  background: url("~@/../src/assets/images/bpm/img_mobile.png");
  background-size: 100% 100%;
  background-repeat: no-repeat;
  box-shadow: none;
}

.mobileDialog ::v-deep .el-dialog .el-dialog__headerbtn {
  width: 40px;
  height: 40px;
  background: #FFFFFF;
  border-radius: 4px;
  right: -48px;
  font-size: 18px;
  font-weight: 800;
}

.mobileDialog ::v-deep .el-dialog .el-dialog__headerbtn:hover .el-dialog__close,
.mobileDialog ::v-deep .el-dialog .el-dialog__headerbtn:focus .el-dialog__close {
  color: #999999;
}

.mobileDialog ::v-deep .el-dialog .el-dialog__body {
  margin: 50px 11px 0px 11px;
  padding: 0;
  overflow: auto;
  height: 570px;
}

.mobileDialog ::v-deep .el-dialog .el-dialog__body > div {
  margin: 0 16px;
}

.bottomFlex {
  display: inline-block;
  margin: 0px 15px;
}
</style>
