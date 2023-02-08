<template>
  <div class="wrapper" :style="{'height': height}">
    <div class="title-panel">
      <el-image :src="icon" style="width: 20px; height: 20px">
        <div slot="error" class="image-slot">
          <i class="el-icon-picture-outline" style="font-size: 20px"></i>
        </div>
      </el-image>
      <div class="title">{{componetTitle || '待办'}}</div>
      <div class="tab">
        <div class="tab-item" :class="{'active': activeName === 'todo'}" @click="changeTab('todo')" ref="todo">待办{{`(${todoCount || 0})`}}</div>
        <div class="tab-item" :class="{'active': activeName === 'finish'}" @click="changeTab('finish')" ref="finish">已办</div>
        <div class="tab-item" :class="{'active': activeName === 'apply'}" @click="changeTab('apply')" ref="apply">我的申请</div>
        <div class="line" style="left: 0" ref="line"></div>
      </div>
      <a v-show="isMore" :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
        <span>更多<i class="el-icon-arrow-right"></i></span>
      </a>
    </div>
    <div class="content-panel" v-loading="loading">
      <div class="content-main">
        <div v-for="item in dataList" :key="item.id" class="content-item" @click="itemClick(item)">
        <img class="icon" src="../../../assets/images/home/icon_file.png">
        <div class="level" v-show="activeName === 'todo' && getLevel(item.businessLevel).text" :style="{'color':getLevel(item.businessLevel).color, 'backgroundColor': getLevel(item.businessLevel).bgColor}">{{getLevel(item.businessLevel).text && `${getLevel(item.businessLevel).text}`}}</div>
        <div class="text">{{item.requestName | setName(item)}}</div>
        <div v-show="activeName === 'todo' && item.startNickName" class="user">{{item.startNickName}}</div>
        <div class="state" v-show="activeName !== 'todo'" :style="processStatusVal(item.processStatus).style">{{processStatusVal(item.processStatus).text}}</div>
        </div>
      </div>
      <el-pagination v-show="dataList.length > 0"
        layout="prev, pager, next"
        :current-page.sync="curentPage"
        :page-size="curentSize"
        @current-change="handleCurrentChange"
        :total="dataTotal">
      </el-pagination>
      <div class="empty" v-show="loaded && !dataList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>暂无内容</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {listApply, listTodo, listFinish,getBuildssolink} from "@/api/console/bpm/workflow";

export default {
  name: "InfoTodo",
  props: ['maxHeight','isMore','moreName','morelink','linkType','icon','componetTitle', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      curentPage: 1,
      curentSize: this.pageSize || 5,
      loading: false,
      loaded: false,
      activeName: null,
      //我的申请
      applyCount: null,
      //我的待办
      todoCount: null,
      //我的已办
      finishCount: null,
      dataList: [],
      dataTotal: null,
      timer: null,
      processStatusOptions: [], // 流程状态数据字典
    }
  },
  filters: {
    setName (val, item) {
      return `${item.clientName}_${val}`
    }
  },
  created() {
    this.getDicts('bpm_process_status').then(response => {
      this.processStatusOptions = response.data;
    })
    this.activeName = 'todo'
    this.finish()
    this.apply()
  },
  mounted() {
    //三十秒刷新一次列表
    this.$nextTick(() => {
      this.timer  =  setInterval(() =>{
        this.curentPage = 1
        this.refData();
      }, 30000);
    })
  },
  beforeDestroy() {
    // console.log('清除定时器')
    clearInterval(this.timer)
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
          return {
            text: this.selectDictLabel(this.processStatusOptions, status),
            style: {
              color: '#FF5555',
              backgroundColor: 'rgba(255, 85, 85, .1)',
            }
          };
        } else if (status == 1) {
          return {
            text: this.selectDictLabel(this.processStatusOptions, status),
            style: {
              color: '#2272DE',
              backgroundColor: 'rgba(34, 114, 222, .1)',
            }
          };
        } else if (status == 2) {
          return {
            text: this.selectDictLabel(this.processStatusOptions, status),
            style: {
              color: '#00BE84',
              backgroundColor: 'rgba(0, 190, 132, .1)',
            }
          };
        } else {
          return {
            text: '其他',
            style: {
              color: '#999',
              backgroundColor: 'rgba(153, 153, 153, .1)',
            }
          };
        }
      }
    }
  },
  watch: {
    activeName: {
      handler (tab) {
        let name = tab;
        this.curentPage = 1
        localStorage.setItem('toDoActive', tab)
        this.$nextTick(() => {
          this.$refs.line.style.left = this.$refs[tab].offsetLeft + (this.$refs[tab].clientWidth - this.$refs.line.clientWidth) / 2 + 'px'
          if ('todo' == name) {
            this.todo();
          } else if ('finish' == name) {
            this.finish();
          } else if ('apply' == name) {
            this.apply();
          }
        })
      },
      immediate: false
    }
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
    refData(){
      this.apply();
      this.todo();
      this.finish();
    },
    changeTab (val) {
      if (this.loading) {
        // 不做处理
      } else {
        this.activeName = val
      }
    },
    apply() {
      let params = {};
      params.pageNum =  this.curentPage;
      params.pageSize = this.curentSize;
      this.dataList = []
      if (this.activeName === 'apply') {
        this.loading = true
        this.loaded = false
      }
      listApply(params).then(res => {
        if (res.code == 0) {
          this.applyCount = res.total;
          if (this.activeName === 'apply') {
            this.dataList = res.rows;
            this.dataTotal = res.total
          }
        } else {
          this.applyCount = null
          if (this.activeName === 'apply') {
            this.dataList = [];
            this.dataTotal = null
          }
        }
        if (this.activeName === 'apply') {
          this.loading = false
          this.loaded = true
        }
      }).catch(() => {
        this.applyCount = null;
        if (this.activeName === 'apply') {
          this.dataList = []
          this.dataTotal = null
          this.loading = false
          this.loaded = true
        }
      })
    },
    todo() {
      let params = {};
      params.pageNum =  this.curentPage;
      params.pageSize = this.curentSize;
      this.dataList = []
      if (this.activeName === 'todo') {
        this.loading = true
        this.loaded = false
      }
      listTodo(params).then(res => {
        if (res.code == 0) {
          this.todoCount = res.total;
          if (this.activeName === 'todo') {
            this.dataList = res.rows
            this.dataTotal = res.total
          }
        } else {
          this.todoCount = null;
          if (this.activeName === 'todo') {
            this.dataList = []
            this.dataTotal = null
          }
        }
        if (this.activeName === 'todo') {
          this.loading = false
          this.loaded = true
        }
      }).catch(err => {
        this.todoCount = null;
        if (this.activeName === 'todo') {
          this.dataList = []
          this.dataTotal = null
          this.loading = false
          this.loaded = true
        }
      })
    },
    finish() {
      let params = {};
      params.pageNum =  this.curentPage;
      params.pageSize = this.curentSize;
      this.dataList = []
      if (this.activeName === 'finish') {
        this.loading = true
        this.loaded = false
      }
      listFinish(params).then(res => {
        if (res.code == 0) {
          this.finishCount = res.total;
          if (this.activeName === 'finish') {
            this.dataList = res.rows;
            this.dataTotal = res.total
          }
        } else {
          this.finishCount = null;
          if (this.activeName === 'finish') {
            this.dataList = [];
            this.dataTotal = null
          }
        }
        if (this.activeName === 'finish') {
          this.loading = false
          this.loaded = true
        }
      }).catch(() => {
        this.finishCount = null;
         if (this.activeName === 'finish') {
          this.dataList = [];
          this.dataTotal = null
          this.isError = true
          this.loading = false
        }
      })
    },
    handleCurrentChange (page) {
      this.curentPage = page
      this[this.activeName]()
    },
    itemClick (item) {
      switch (this.activeName) {
        case 'todo':
          this.openTask(item)
          break
        case 'finish': case 'apply':
          this.openProcess(item)
          break
        default:
          break
      }
    },
    openApproval(taskId) {
      let self = this;
      let w = screen.width * 0.9;
      let h = screen.height * 0.8;
      let iTop = (window.screen.height - 30 - h) / 2;       //获得窗口的垂直位置;
      let iLeft = (window.screen.width - 10 - w) / 2;        //获得窗口的水平位置;

      let windowHandler = window.open('/home/bpm/task/' + taskId, '审批流程', "top="+iTop+",left="+iLeft+",width="+w+",height="+h+",resizable=no,scrollbars=yes,status=no,menubar=no,toolbar=no,location=no,direction=no");
      windowHandler.focus();
      const loop = setInterval(item => {
        if (windowHandler.closed) {
          clearInterval(loop);
          self.todo();
        }
      }, 1000);
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

<style lang="scss" scoped>
  .wrapper{
    height: 270px;
    background-color: #fff;
    box-sizing: border-box;
  }
  .title-panel{
    height: 48px;
    width: 100%;
    padding: 0 20px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid #F2F2F2;
    .title{
      margin-left: 8px;
      color: #333333;
      font-weight: 600;
      font-size: 16px;
    }
    .tab{
      flex: 1;
      display: flex;
      margin-left: 76px;
      position: relative;
      .tab-item{
        margin-right: 40px;
        color:#999999;
        font-size: 14px;
        cursor: pointer;
        font-weight: 500;
        &.active{
          color: #2272DE;
        }
      }
      .line{
        height: 2px;
        width: 46px;
        position:absolute;
        left: 0;
        bottom: -7px;
        background-color: #2272DE;
        transition: all .5s;
      }
    }
    a{
      font-weight: 400;
      color: #505050;
      font-size: 14px;
    }
  }
  .content-panel{
    height: calc(100% - 48px);
    min-height: calc(100% - 48px);
    position: relative;
    .content-main{
      height: calc(100% - 37px);
      overflow: hidden;
    }
    ::v-deep .el-pagination{
     text-align: right;
    //  height: 37px;
    padding: 4px 10px;
    }
    .content-item{
      display: flex;
      align-items: center;
      // height: 44px;
      border-bottom: 1px solid #F2F2F2;
      padding: 6px 20px;
      cursor: pointer;
      .icon{
        width: 18px;
        height: 18px;
        margin-right: 7px;
      }
      .level{
        font-size: 12px;
        background-color: transparent;
        border-radius: 2px;
        padding: 2px 4px;
        margin-right: 7px;
      }
      .text{
        flex: 1;
        font-weight: 500;
        font-size: 14px;
        color: #333;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
      }
      .user{
        font-weight: 500;
        margin-left: 10px;
        color:#333;
        font-size: 14px;
        height: 24px;
        line-height: 24px;
      }
      .state{
        margin-left: 10px;
        width: 60px;
        min-width: 60px;
        height: 24px;
        line-height: 24px;
        font-weight: 400;
        font-size: 13px;
        text-align: center;
      }
    }
    .empty{
      position: absolute;
      margin: 0;
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      .empty-main{
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        position: absolute;
        text-align: center;
      }
    }
  }
//   >>>.el-tabs__nav-wrap::after {
//   display: none;
// }


//   >>>.el-tabs .el-tabs__header {
//     margin: 0;
//   }

// .needTo >>> .el-tabs__nav-scroll {
//   padding: 0 20px !important;
//   margin-bottom: 3px;
// }
// .needTo >>> .el-tabs__item {
//   height: 30px;
//   line-height: 30px;
//   padding: 0 10px;
// }


// .needTo {
//   height: 300px;
//   background: #FFFFFF;
//   border-radius: 4px;
//   margin-bottom: 20px;
// }

// .needToIcon {
//   position: absolute;
//   top: 13px;
//   left: 20px;
// }

// .needToIcon img {
//   vertical-align: sub;
// }

// .needToIcon span {
//   margin-left: 4px;
//   font-size: 18px;
//   font-weight: 600;
//   color: #333333;
// }

// .needToMore {
//   position: absolute;
//   top: 13px;
//   right: 20px;
// }

// .needToMore > a {
//   font-size: 14px;
//   font-weight: 400;
//   color: #505050;
// }

// .needToMore > a > i {
//   font-weight: 600;
//   color: #505050;
// }

// .needTo .el-tabs__item {
//   font-size: 14px;
//   font-weight: 500;
//   color: #999999;
//   padding: 16px 20px 4px 20px;
//   height: auto;
//   line-height: normal;
//   padding: 0 10px !important;
//   height: 30px !important;
//   line-height: 30px !important;
// }

// .needTo .el-tabs__item.is-active {
//   color: #0B86F1;
// }

// .needTo .el-tabs__active-bar {
//   background-color: #0B86F1;
// }

// .needTo .el-tabs__nav-wrap::after {
//   height: 1px;
//   background-color: #F2F2F2;
// }

// .needToList li {
//   padding: 8px 20px 8px 20px;
//   border-bottom: 1px solid #F2F2F2;
//   cursor: pointer;
// }

// .needToList li:hover {
//   background-color: #F5F6FA;
// }

// .needToList li:last-child {
//   border: none;
// }

// .needToList li > p {
//   width: 100%;
//   height: 24px;
//   line-height: 24px;
// }

// .needword {
//   display: flex;
// }
// .needToTitle {
//   flex: 1;
//   font-size: 14px;
// }

// .needToTime {
//   width: 130px;
//   float: right;
//   font-size: 13px;
//   color: #999;
// }

// .needToList li > p > span {
//   display: inline-block;
// }

// .needToUser {
//   font-size: 13px;
//   font-weight: 500;
//   color: #797979;
//   float: right;
//   margin-right: 8px;
// }

// .finishing .needStatus {
//   width: 10%;
//   min-width: 80px;
//   text-align: center;
//   color: #00BE84;
//   font-size: 13px;
//   float: right;
// }

// .finish .needStatus {
//   width: 10%;
//   min-width: 80px;
//   text-align: center;
//   color: #0B86F1;
//   font-size: 13px;
//   float: right;
// }

// .unfinish .needStatus {
//   width: 10%;
//   min-width: 80px;
//   text-align: center;
//   color: #FF454F;
//   font-size: 13px;
//   float: right;
// }

</style>
