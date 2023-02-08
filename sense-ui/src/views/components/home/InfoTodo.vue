<template>
  <div class="needTo">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane :label="'我的待办('+ todoCount +')'" name="todo">
        <ul class="needToList">
            <li v-for="(item,index) in todoList" :key="index"
                :class="processStyleCss(item.processStatus)"
                @click="openTask(item)"
            >
            <p>
              <span class="publicHidden needToTitle" :title="item.businessName">{{ item.businessName }}</span>
              <span class="needStatus">{{ processStatusVal(item.processStatus) }}</span>
            </p>
          </li>
        </ul>
        <div v-if="todoCount==0" class="emptyData">
          <img src="@/assets/images/empty.png" alt="">
          <p>暂无相关内容</p>
        </div>
      </el-tab-pane>
      <el-tab-pane :label="'我的已办('+finishCount+')'" name="finish">
        <ul class="needToList">
          <li v-for="(item,index) in finishList" :key="index"
              :class="processStyleCss(item.processStatus)"
              @click="openProcess(item)"
          >
            <p>
              <span class="publicHidden needToTitle" :title="item.businessName">{{ item.businessName }}</span>
              <span class="needStatus">{{ processStatusVal(item.processStatus) }}</span>
            </p>
          </li>
        </ul>
        <div v-if="finishCount==0" class="emptyData">
          <img src="@/assets/images/empty.png" alt="">
          <p>暂无相关内容</p>
        </div>
      </el-tab-pane>
      <el-tab-pane :label="'我的申请('+applyCount+')'" name="apply">
        <ul class="needToList">
          <li v-for="(item,index) in applyList" :key="index"
              :class="processStyleCss(item.processStatus)"
              @click="openProcess(item)">
            <p>
              <span class="publicHidden needToTitle" :title="item.businessName">{{ item.businessName }}</span>
              <span class="needStatus">{{ processStatusVal(item.processStatus) }}</span>

            </p>
          </li>
        </ul>
        <div v-if="applyCount==0" class="emptyData">
          <img src="@/assets/images/empty.png" alt="">
          <p>暂无相关内容</p>
        </div>
      </el-tab-pane>
    </el-tabs>
    <div class="needToTitle">
      <div class="needToIcon">
        <img src="@/assets/images/home/icon_news_needto.png" width="20" height="20" alt="">
        <span>待办</span>
      </div>
      <div class="needToMore">
        <router-link to='#'>
          <span @click="showMore">更多<i class="el-icon-arrow-right"></i></span>

        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import {listApply, listTodo, listFinish,getBuildssolink} from "@/api/console/bpm/workflow";

export default {
  name: "InfoTodo",
  data() {
    return {
      activeName: 'todo',
      //我的申请
      applyList: [],
      applyCount: 0,
      //我的待办
      todoList: [],
      todoCount: 0,
      //我的已办
      finishList: [],
      finishCount: 0
    }
  },
  created() {
    this.refData();
  },
  computed: {
    processStyleCss() {
      return function (status) {
        if (status == 0) {// 驳回
          return 'unfinish';
        } else if (status == 1) {// 审批中
          return 'finish';
        } else if (status == 2) {// 通过
          return 'finishing';
        } else {//其他
          return '';
        }
      }
    },
    processStatusVal() {
      return function (status) {
        if (status == 0) {
          return '流程驳回';
        } else if (status == 1) {
          return '审批中';
        } else if (status == 2) {
          return '流程通过';
        } else {
          return '其他';
        }
      }
    }
  },
  methods: {
    refData(){
      this.apply();
      this.todo();
      this.finish();
    },
    apply() {
      let params = {};
      params.pageNum = 1;
      params.pageSize = 6;
      listApply(params).then(res => {
        if (res.code == 0) {
          this.applyList = res.rows;
          this.applyCount = res.total;
        } else {
          this.applyList = [];
          this.applyCount = 0;
        }
      })
    },
    todo() {
      let params = {};
      params.pageNum = 1;
      params.pageSize = 6;
      listTodo(params).then(res => {
        if (res.code == 0) {
          this.todoList = res.rows;
          this.todoCount = res.total;
        } else {
          this.todoList = [];
          this.todoCount = 0;
        }
      })
    },
    finish() {
      let params = {};
      params.pageNum = 1;
      params.pageSize = 6;
      listFinish(params).then(res => {
        if (res.code == 0) {
          this.finishList = res.rows;
          this.finishCount = res.total;
        } else {
          this.finishList = [];
          this.finishCount = 0;
        }
      })
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
                  self.refData();
                },1000)
              }
            }, 1000);

          }else{
            this.msgWarning(response.msg)
          }
        });
       }
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
    showMore() {
      window.open('/home/moreTodo');
    },
    /**TAB点击事件*/
    handleClick(tab, event) {
      let name = tab.name;
      if ('todo' == name) {
        this.todo();
      } else if ('finish' == name) {
        this.finish();
      } else if ('apply' == name) {
        this.apply();
      }
    }
  }
}
</script>

<style scoped>
.needTo >>> .el-tabs__nav-scroll {
  padding: 0 20% 10px 20% !important;
}

.needTo {
  height: 300px;
  background: #FFFFFF;
  border-radius: 4px;
  margin-bottom: 20px;
}

.needToIcon {
  position: absolute;
  top: 13px;
  left: 20px;
}

.needToIcon img {
  vertical-align: sub;
}

.needToIcon span {
  margin-left: 4px;
  font-size: 18px;
  font-weight: 600;
  color: #333333;
}

.needToMore {
  position: absolute;
  top: 13px;
  right: 20px;
}

.needToMore > a {
  font-size: 14px;
  font-weight: 400;
  color: #505050;
}

.needToMore > a > i {
  font-weight: 600;
  color: #505050;
}

.needTo .el-tabs__item {
  font-size: 14px;
  font-weight: 500;
  color: #999999;
  padding: 16px 20px 4px 20px;
  height: auto;
  line-height: normal;
}

.needTo .el-tabs__item.is-active {
  color: #0B86F1;
}

.needTo .el-tabs__active-bar {
  background-color: #0B86F1;
}

.needTo .el-tabs__nav-wrap::after {
  height: 1px;
  background-color: #F2F2F2;
}

.needToList li {
  padding: 8px 20px 8px 20px;
  border-bottom: 1px solid #F2F2F2;
  cursor: pointer;
}

.needToList li:hover {
  background-color: #F5F6FA;
}

.needToList li:last-child {
  border: none;
}

.needToList li > p {
  width: 100%;
  height: 24px;
  line-height: 24px;
}

.needToTitle {
  width: 90%;
  font-size: 14px;
}

.needToTime {
  width: 130px;
  float: right;
  font-size: 13px;
  color: #999;
}

.needToList li > p > span {
  display: inline-block;
}

.needToUser {
  font-size: 13px;
  font-weight: 500;
  color: #797979;
  float: right;
  margin-right: 8px;
}

.finishing .needStatus {
  width: 10%;
  text-align: center;
  color: #00BE84;
  font-size: 13px;
  float: right;
}

.finish .needStatus {
  width: 60px;
  text-align: center;
  color: #0B86F1;
  font-size: 13px;
  float: right;
}

.unfinish .needStatus {
  width: 60px;
  text-align: center;
  color: #FF454F;
  font-size: 13px;
  float: right;
}

</style>
