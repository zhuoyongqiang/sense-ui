<template>
  <div class="trends" v-if="isUserLogin">
    <el-row class="tabsd" :class="{'scrolltabsd': showscrolltabsd}">
      <Tabs v-model="tabs.active" :data="tabs" @click="tabClick">
        <Tab v-for="(item, index) in tabData" :title="item.name" :key="item.id">
          <PullRefresh :disabled="refreshbtn" v-model="refreshing" @refresh="onRefresh">
              <List :data="listComp" @load="onLoad" @refresh="onRefresh">
                <ul class="trendsList">
                  <li v-for="item in newsList" @click="openTask(item)" class="publicFlexStart">
                    <el-row>
                      <el-col :span="24">
                        <div class="trendsListTitle">
                          <h3 class="publicHiddenTwoLine">{{ item.businessName }}</h3>
                        </div>
                      </el-col>
                    </el-row>
                    <el-row style="margin-top:0.15rem;">
                      <el-col :span="16">
                        <div class="rowIssuer">
                           <span class="issuerSpan">
                             <span style="margin-right:0.2rem;">
                               <i class="el-icon-user" style="margin-right:0.1rem;">
                                 {{ item.startNickName }}
                               </i>
                             </span>
                             <span style="margin-right:0.2rem;">
                               <i class="el-icon-date"> {{ parseTime(item.processStartTime?item.processStartTime:item.taskEndTime , '{y}-{m}-{d}') }}</i>

                             </span>
                           </span>
                        </div>
                      </el-col>
                      <el-col :span="8">
                        <div class="rowView">
                          <span style="margin-right:0.2rem;">
                            <i class="el-icon-monitor"> {{ item.clientName }} </i>
                          </span>
                        </div>
                      </el-col>
                    </el-row>
                  </li>
                </ul>
              </List>
            </PullRefresh>
            <!-- 无数据提醒 -->
            <div v-show="!listComp.loading && !listComp.err && newsList.length === 0 && listComp.finished === true" style="text-align: center; margin-top: 30%;font-size:0">
              <img src="./../../../assets/images/mobile/window/nodata.png" style="width: 3.7rem">
              <p style="font-size: .37rem; color:#2B3949; font-weight: 400;">当前暂无数据~  </p>
            </div>
        </Tab>
      </Tabs>
    </el-row>
    <!-- <el-row>
      <div class="load-more">
        <div class="finish" v-if="finish">
          <span v-if="!loadState">已经到底了</span>
        </div>
        <div class="more" v-if="!finish">
          <span><i class="el-icon-loading" style="margin-right:0.1rem;"></i>正在加载...</span>
        </div>
      </div>
    </el-row> -->
  </div>
</template>

<script>
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import {mapGetters} from "vuex";
import { on, off } from '@/utils/event'
import scrollUtils from '@/utils/scroll'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'
import Tabs from '@/components/tabs/Tabs.vue'
import Tab from '@/components/tabs/Tab.vue'
import {listApply, listFinish, listTodo,getMobileBuildssolink} from "@/api/console/bpm/workflow";
export default {
  name: "mobileworkflow",
  components: {PullRefresh, List, Tabs, Tab},
  data() {
    return {
      activeName: undefined,
      windowTitle: undefined,
      currentNewsTypeId: undefined,
      tabData: [],
      total: 0,
      pageNum: 0,
      pageSize: 10,
      searchTitle: undefined,
      defaultAvatarImg: require("@/assets/images/img_head.png"),
      newsList: [],
      loadState: true, // 是否显示底部加载状态，默认true
      finish: false, // 是否加载完成
      startX: 0,
      startY: 0,
      isIos: false,
      refreshbtn: false,
      refreshing: false,
      listComp: {
        pageNum: 0,
        total: -1,
        loading: false,
        finished: false,
        err: false,
        immediateCheck: false
      },
      tabs:{
        active: 0,
        swipeable: true
      },
      homeTop: 0,
      showscrolltabsd: true
    }
  },
  computed: {
    ...mapGetters([
      'avatar'
    ]),
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2;')
  },
  filters: {
    changeTime :function (value) {
      return value.substr(0,value.length - 6);
    }
  },
  mounted() {
    document.title = "任务列表";
    if(this.isUserLogin){
      this.tabData = [{
        id:1,
        name:"我的待办"
      },{
        id:2,
        name:"我的已办"
      },{
        id:3,
        name:"我的申请"
      }]

      this.currentNewsTypeId = 1;
      this.onLoad()
      const iphone = navigator.userAgent.match(/(iPhone\sOS)\s([\d_]+)/)
      if (iphone) {
        this.isIos = true;
      }
    }else{
      this.msgWarning('暂无访问权限');
    }
  },
  activated () {
    if (!document.getElementsByClassName('content')[0]) {
      return
    }
    document.getElementsByClassName('content')[0].scrollTop = this.homeTop || 0
    const srollEl = scrollUtils.getScrollEventTarget(document.getElementsByClassName('content')[0])
    on(srollEl, 'scroll', this.onScroll, true)
  },
  deactivated () {
    const srollEl = scrollUtils.getScrollEventTarget(document.getElementsByClassName('content')[0])
    off(srollEl, 'scroll', this.onScroll, true)
  },
  beforeRouteLeave (to, from, next) {
    // console.log('leave')
    let app = document.getElementsByClassName('content')[0]
    this.homeTop = app.scrollTop || 0
    next()
  },
  watch: {
    currentNewsTypeId (val) {
      this.tabs.active = this.tabData.findIndex(v => v.id === val) || 0
    },
    'tabs.active' (val) {
      if (val < 0) {
        return
      }
      if (this.currentNewsTypeId === this.tabData[this.tabs.active].id) {
        return
      } else {
        // this.currentNewsTypeId = this.newsTypeList[this.tabs.active].id
        this.tabClick(val)
      }
    }
  },
  methods: {
    onScroll () {
      const scrollTop = scrollUtils.getScrollTop(document.getElementsByClassName('content')[0])
      this.showscrolltabsd = true
      if (scrollTop) {
        this.showscrolltabsd = false
      } else {
        this.showscrolltabsd = true
      }
    },
    hasClass(elements, cName) {
      return !!elements.className.match(new RegExp("(\\s|^)" + cName + "(\\s|$)"));
    },
    addClass(elements, cName) {
      if (!this.hasClass(elements, cName)) {
        elements.className += " " + cName;
      }
    },
    scrollToEnd(e) {
      let scrollHeight = this.$el.scrollHeight;
      let clientHeight = this.$el.clientHeight;
      let scrollTop = this.$el.scrollTop;
      if (scrollTop + clientHeight >= scrollHeight) {
        setTimeout(() => {
          this.pageNum = this.pageNum + 1;
          this.list();
        }, 300)
      }
    },
    defaultAvatar() {
      let img = event.srcElement;
      img.src = this.defaultAvatarImg;
      img.onerror = null; //防止闪图
    },
    list() {
      let params = {};
      params.pageNum = this.pageNum;
      params.pageSize = this.pageSize;
      params.title = this.searchTitle;
      params.isLikeQuery = true;
      params.isMobile = true;
      //1待办  2已办 3我的申请
      if (this.currentNewsTypeId === 1) {
        listTodo(params).then(response => {
          // this.finish = true;
          if (response.rows.length < this.pageSize) {
            this.listComp.finished = true;
          } else {
            this.listComp.finished = false;
          }
          this.listComp.loading = false
          this.newsList = this.newsList.concat(response.rows);
          this.total = response.total;
        }).catch(err => {
          this.listComp.finished = true;
          this.listComp.loading = false
          this.listComp.err = true
        });
      }else if (this.currentNewsTypeId === 2) {
        listFinish(params).then(response => {
          // this.finish = true;
          if (response.rows.length < this.pageSize) {
            this.listComp.finished = true;
          } else {
            this.listComp.finished = false;
          }

          this.listComp.loading = false
          this.newsList = this.newsList.concat(response.rows);
          this.total = response.total;
        }).catch(err => {
          this.listComp.finished = true;
          this.listComp.loading = false
          this.listComp.err = true
        });
      }else if (this.currentNewsTypeId === 3) {
        listApply(params).then(response => {
          // this.finish = true;
          if (response.rows.length < this.pageSize) {
            this.listComp.finished = true;
          } else {
            this.listComp.finished = false;
          }

          this.listComp.loading = false
          this.newsList = this.newsList.concat(response.rows);
          this.total = response.total;
        }).catch(err => {
          this.listComp.finished = true;
          this.listComp.loading = false
          this.listComp.err = true
        });
      }
    },
    search() {
      this.newsList = [];
      this.list();
    },
    tabClick(index, title) {
      const tab = this.tabData[index]
      this.currentNewsTypeId = tab.id || 'all';
      this.pageNum = 0;
      this.newsList = [];
      this.onLoad();
      sessionStorage.setItem('mobileCurrentNewsTypeId', tab.id);
    },
    showDetail(id) {
      this.$router.push({
        path: '/mobile/home/detail/' + id
      });
    },
    /******************
     * @function onLoad
     * @desc 上拉加载
     */
    onLoad () {
      this.listComp.loading = true
      this.listComp.err = false
      this.pageNum++
      this.list()
    },
    /*********************
     * @function onRefresh
     * @desc 刷新
     */
    onRefresh () {
      this.listComp.finished = true
      this.refreshing = true
      this.pageNum = 0
      setTimeout(() => {
        this.newsList = []
        this.listComp.finished = false
        this.refreshing = false
        window.scrollTo(0, 10)
      }, 0)
    },
    openProcess(row) {
      //判断是门户的待办还是其他系统的待办跳转不同的位置办理
      if('APP001'=== row.clientId){
        this.$router.push({
          path: '/mobile/home/detail/' + row.newsInstId
        });
      }else{
        getMobileBuildssolink(2,row.id).then(response => {
          if(response.code === 200){
            location.href = response.msg;
          }else{
            this.msgWarning(response.msg)
          }
        });
      }
    },
    openTask(row) {
      if(this.currentNewsTypeId !==1){
        this.openProcess(row)
        return;
      }else{
        if('APP001'=== row.clientId){
          this.$router.push({
            path: '/mobile/home/approve/' + row.id
          });
        }else{
          getMobileBuildssolink(1,row.id).then(response => {
            if(response.code===200){
              location.href = response.msg;
            }else{
              this.msgWarning(response.msg)
            }
          });
        }
      }
    }
  }
}
</script>

<style scoped>

.trends {
  background: #F6F8FC;
  height: 100%;
}
.tabsd{
  height: 100%;
}
.tabsd ::v-deep .tabs-wrapper{
  height: 100%;
  display: flex;
  flex-direction: column;
}
.block{
  padding: 0 .32rem;
}
.block ::v-deep .el-carousel__indicators--horizontal{
  left: .21rem;
  bottom: .16rem;
  transform: none;
}
.block ::v-deep .el-carousel__indicator--horizontal{
  padding: 0 .11rem;
}
.block ::v-deep .el-carousel__item{
  border-radius: .32rem !important;
}
.block ::v-deep .el-carousel__item.is-active{

}
.block ::v-deep .el-carousel__button{
  width: .11rem;
  height: .11rem;
  border-radius: 50%;
}
.block ::v-deep .el-carousel__indicator.is-active .el-carousel__button{
  width: .32rem;
  height: .11rem;
  border-radius: .05rem;
}

.tabsd ::v-deep .tabs-wrapper .nav {
  background: #F6F8FC;
}
.tabsd ::v-deep .tabs-wrapper .tab:active{
  background-color: transparent;
}


.tabsd ::v-deep .tabs-wrapper .tab.active{

}

.tabsd ::v-deep .tabs-wrapper .content {
  margin-top: .15rem;
  background: #F6F8FC;
  flex: 1;
  overflow-y: auto;
}

.tabsd ::v-deep .tabs-wrapper .wrap.scrollable .tab{
  flex: 0 0 auto;
  padding: 0 .32rem;
  /* background-color: transparent; */
}

.tabsd.scrolltabsd ::v-deep .tabs-wrapper .wrap.scrollable .tab {
  background-color: transparent;
}

.newsImg {
  width: 100%;
  height: 1.92rem;
  border-radius: 2px;
  overflow: hidden;
}
.trendsList{
  margin-top: .21rem;
}
.trendsList li {
  font-size: 0px;
  margin: 0 .32rem .21rem .32rem;
  padding: .32rem .26rem .21rem;
  text-align: left;
  background: #FFFFFF;
  box-shadow: 0px 2px 14px 0px rgba(227, 218, 218, 0.5);
  border-radius: .32rem;
}

.trendsListTitle {
  width: 100%;
  padding-right: 0.43rem;
}

/* .trendsListTitle > span {
  display: inline-block;
  width: .85rem;
  height: .37rem;
  border-radius: .11rem;
  background: linear-gradient(to bottom, #FE872A 0%, #FE2826 100%);
} */

.trendsListTitle > h3 {
  letter-spacing: 1.5px;
  font-size: 0.4rem;
  font-weight: 700;
  color: #303133;
  line-height: 0.6rem;
  margin-bottom: 0.27rem;
  height: 1.17rem;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.trendsListTitle > h3.new::before{
   display: inline-block;
   vertical-align: middle;
    width: .85rem;
    height: .37rem;
    position: relative;
    top: -2px;
    content: '';
    font-size: .32rem;
    margin-right: .21rem;
    background: url("../../../assets/images/mobile/window/icon-new.png");
    background-size: 100% auto;
}
.trendsListTitle > h3.first::before{
   display: inline-block;
   vertical-align: middle;
    width: .85rem;
    height: .37rem;
    position: relative;
    top: -2px;
    content: '';
    font-size: .32rem;
    margin-right: .21rem;
    background: url("../../../assets/images/mobile/window/icon-top.png");
    background-size: 100% auto;
}
.trendsListTitle > p {
  font-size: 0.37rem;
  font-weight: 400;
  color: #8F9193;
}

/*
.trendsList li:first-child .trendsListTitle > h3 {
  color: #2272DE;
}
*/

.rowIssuer {
  font-size: 0.35rem;
  color: #AFB0B2;
}

.rowIssuer .issuer{
    color: #606266;
}
.rowView {
  font-size: 0.37rem;
  color: #8F9193;
  float: right;
}

.publicFlexStart {
  border-bottom: 1px solid #F2F2F3;
}

.load-more {
  text-align: center;
  font-size: 0.4rem;
  color: #ababab;
  height: 1.2rem;
  line-height: 1.2rem;
}

.avatar {
  vertical-align: middle;
  border-radius: 50%;
  float: left;
}

.searchBar {
  margin: 0px;
  padding: 0.15rem 0.15rem 0rem 0.15rem;
}


.searchTitle {
  height: 0.9rem;
  margin-left: 1rem;
  display: block;
}

.searchTitle >>> .el-input {
  display: block;
}

.searchTitle ::v-deep input {
  width: 100%;
  height: 0.8rem;
  line-height: 0.8rem;
  background: #F2F3F9;
  border: 0px;
}

.searchTitle .el-input__icon {
  line-height: 0.8rem;
}
  .carouselWrap {
    /* width: calc(100% - 0.8rem); */
    /* margin-left: 0.4rem; */
    height: 4.625rem;
    overflow: hidden;
    /* border-radius: .32rem !important; */
    position: relative;
  }
.carouselWrap .text{
  position: absolute;
  left: .21rem;
  bottom: .6rem;
  font-size: .43rem;
  color:#fff;
  width: calc(100% - .42rem);
  /* text-align: justify; */
  overflow:hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}
.carouselWrap img {
  border-radius: .32rem !important;
}
.blueBg {
  width: 37.5rem;
  position: fixed;
  height: 25rem;
  background:  #4f77aa;
  border-radius: 0 0 19.75rem 0;
  top: -22.5rem;
  left:-16rem;
}

.iosNavBg {
  width: 37.5rem;
  position: fixed;
  height: 25rem;
  background:  #4378be;
  border-radius: 0 0 19.75rem 0;
  top: -22.5rem;
  left:-16rem;
}

  .issuerSpan {
    margin-left: 0.25rem;
  }
</style>

<style>

  .el-carousel__container {
    height: 100%;
    border-radius: .32rem;
    overflow: hidden;
  }

</style>
