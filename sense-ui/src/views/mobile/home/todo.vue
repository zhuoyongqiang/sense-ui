<template>
  <div class="trends" v-if="isUserLogin">
    <PullRefresh :disabled="refreshbtn" v-model="refreshing" @refresh="onRefresh">
      <List :data="listComp" @load="onLoad" @refresh="onRefresh">
        <div v-for="item in todoList" :key="item.taskId" @click="showDetail(item.taskId)" class="panel">
          <div class="header">
            <el-row>
              <el-col :span="12">
                <div class="processName">{{item.taskName}}</div>
              </el-col>
              <el-col :span="12">
                <div class="time">{{ item.taskStartTime | changeTime }}</div>
              </el-col>
            </el-row>
          </div>

          <div class="content">{{item.businessName}}</div>

          <div class="btn-wrapper">
            <el-button>点击查看</el-button>
          </div>
        </div>
      </List>
    </PullRefresh>
    <!-- 无数据提醒 -->
    <div v-show="!listComp.loading && !listComp.err && todoList.length === 0 && listComp.finished === true" style="text-align: center; margin-top: 50%;font-size:0">
      <img src="./../../../assets/images/mobile/window/nodata.png" style="width: 3.7rem">
      <p style="font-size: .37rem; color:#2B3949; font-weight: 400;">当前暂无数据~  </p>
    </div>
  </div>
</template>

<script>
import {getConfigKey} from "@/api/home/config";
import {listTodo} from "@/api/console/bpm/workflow";
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'

export default {
  name: "mobileTodo",
  components: {PullRefresh, List},
  data() {
    return {
      newsTypeList: [],      
      todoList: [],
      baseFilePath: undefined,
      loadState: true, // 是否显示底部加载状态，默认true
      finish: false, // 是否加载完成
      isIos: false,
      refreshbtn: false,
      refreshing: false,
      listComp: {
        pageNum: 0,
        pageSize: 10,
        total: -1,
        loading: false,
        finished: false,
        err: false,
        immediateCheck: true
      },
    }
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2;')
    document.title = "新闻待办";
  },
  filters: {
    changeTime :function (value) {
      return new Date(value).format('yyyy-MM-dd hh:mm:ss')
      // return value
    }
  },
  mounted() {
   if(this.isUserLogin){

      const iphone = navigator.userAgent.match(/(iPhone\sOS)\s([\d_]+)/)
      if (iphone) {
        this.isIos = true;
      }

      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });

    }else{
      this.msgWarning('暂无访问权限');
    }

  },
  watch: {
  },
  methods: {    
    list() {
      listTodo({
        pageNum: this.listComp.pageNum,
        pageSize: this.listComp.pageSize
      }).then(res => {
        this.listComp.loading = false
        this.todoList = this.todoList.concat(res.rows);
        this.todoCount = res.total;
        if (this.todoList.length >= res.total) {
          this.listComp.finished = true;
        } else {
          this.listComp.finished = false;
        }
      }).catch(err => {
        this.listComp.finished = true;
        this.listComp.loading = false
        this.listComp.err = true
        console.warn(err)
      })
    },
    showDetail(id) {
      this.$router.push({
        path: '/mobile/home/approve/' + id
      });
    },
    /******************
     * @function onLoad
     * @desc 上拉加载
     */
    onLoad () {
      this.listComp.loading = true
      this.listComp.err = false
      this.listComp.pageNum++
      this.list()
    },
    /*********************
     * @function onRefresh
     * @desc 刷新
     */
    onRefresh () {
      this.listComp.finished = true
      this.refreshing = true
      this.listComp.pageNum = 0
      setTimeout(() => {
        this.todoList = []
        this.listComp.finished = false
        this.refreshing = false
        window.scrollTo(0, 10)
      }, 0)
    }
  }
}
</script>

<style lang="scss" scoped>

.trends {
  background: #F6F8FC;
  height: 100%;
  overflow-y: auto;
}
.header{
  position: relative;
  padding: .21rem .21rem;
  margin-bottom: .21rem;
  &::after{
    position: absolute;
    bottom: 0;
    left: 0;
    content: '';
    height: 1px;
    background-color: #e9e9e9;
    transform: scaleY(.5);
    width: 100%;
  }
}
.processName{
  font-size: .37rem;
}
.time{
  font-size: .37rem;
  color: #bbb;
  text-align: right;
}
.panel{
  border-radius: 8px;
  background-color: #fff;
  margin: .42rem .42rem;
  // padding: .21rem .16rem;
  box-shadow: 0px 2px 14px 0px rgba(227, 218, 218, 0.2);
}
.content{
  font-size: .4rem;
  // text-align: justify;
  color: #8a8282;
  padding: 0 .32rem .21rem;
}
.btn-wrapper{
  padding: 0 .32rem .21rem;
  box-sizing: border-box;
  font-size: .43rem;
  text-align: right;
  margin-top: .26rem;
  .el-button{
    border-radius: 30px;
    border-color: #aaa;
  }
}
</style>

