<template>
  <div class="trends" v-if="isUserLogin">

    <el-row class="tabsd" :class="{'scrolltabsd': showscrolltabsd}">
      <Tabs v-model="tabs.active" :data="tabs" @click="tabClick">
        <div class="block">
          <el-carousel :interval="4000" arrow="never" ref="slideCarousel" class="carouselWrap">
            <el-carousel-item v-for="item in carouselNewsList" :key="item.id">
              <div class="text">{{item.title}}</div>
              <img v-if="item.photo" :src="baseFilePath+item.photo" @click="showDetail(item.id)" width="100%" height="100%" alt="">
            </el-carousel-item>
          </el-carousel>
        </div>
        <Tab v-for="(item, index) in newsTypeList" :title="item.name" :key="item.id">
          <PullRefresh :disabled="refreshbtn" v-model="refreshing" @refresh="onRefresh">
              <List :data="listComp" @load="onLoad" @reload="onRefresh">
                <ul class="trendsList">
                  <li v-for="(item, index) in newsList" @click="showDetail(item.id)" class="publicFlexStart">
                    <el-row>
                      <el-col :span="item.photo?16:24">
                        <div class="trendsListTitle">
                          <!-- <img v-if="item.isNew" src="@/assets/images/mobile/window/icon-new.png" width="30" height="15" style="vertical-align:middle;margin-right:8px;"/> -->
                          <h3 class="publicHiddenTwoLine" :class="{'new' : item.isNew, 'first': item.isFirst === 1 && index === 0 }">{{ item.title }}</h3>
                        </div>
                      </el-col>
                      <el-col :span="item.photo?8:0">
                        <div class="newsImg" v-if="item.photo!=''">
                          <img v-if="item.photo" :src="baseFilePath+item.photo" width="100%" height="100%" alt="">
                        </div>
                      </el-col>
                    </el-row>
                    <el-row style="margin-top:0.15rem;">
                      <el-col :span="20">
                        <div class="rowIssuer">
                          <span class="issuer">{{ item.issuer }}</span><span class="issuerSpan">{{ item.effectTime | changeTime }}</span>
                        </div>
                      </el-col>
                      <el-col :span="4">
                        <div class="rowView">
                          <span><i class="el-icon-view" style="margin-right:0.1rem;"></i>{{item.newsReadNum==null?0:item.newsReadNum}}</span>
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
import {getConfigKey} from "@/api/home/config";
import {allNewsType} from "@/api/home/newsType";
import {listNews} from "@/api/home/news";
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import {mapGetters} from "vuex";
import { on, off } from '@/utils/event'
import scrollUtils from '@/utils/scroll'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'
import Tabs from '@/components/tabs/Tabs.vue'
import Tab from '@/components/tabs/Tab.vue'
import { cancelHttp } from '@/utils/request'
// import request from "@/utils/request";

export default {
  name: "mobileWindow",
  components: {PullRefresh, List, Tabs, Tab},
  data() {
    return {
      activeName: undefined,
      windowTitle: undefined,
      currentNewsTypeId: undefined,
      newsTypeList: [],
      total: 0,
      pageNum: 0,
      pageSize: 10,
      searchTitle: undefined,
      defaultAvatarImg: require("@/assets/images/img_head.png"),
      newsList: [],
      baseFilePath: undefined,
      loadState: true, // 是否显示底部加载状态，默认true
      finish: false, // 是否加载完成
      startX: 0,
      startY: 0,
      allType: {
        name: "全部",
        id: 'all'
      },
      showType: "1", //显示类型， 为1时显示所有除了通知公告    为2时只显示通知公告
      carouselNewsList: [],
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
   if(this.isUserLogin){
      if (this.$route.query.state != null) {
        this.showType = this.$route.query.state;
      }
      if (this.showType == "1") {
        document.title = "国行动态";
      } else {
        document.title = "通知公告";
      }

      const iphone = navigator.userAgent.match(/(iPhone\sOS)\s([\d_]+)/)
      if (iphone) {
        this.isIos = true;
      }

      allNewsType({isMore: 1}).then(response => {
        if (response.code == 200) {
          if (this.showType == "1") {
            this.newsTypeList.push(this.allType);
            this.newsTypeList = this.newsTypeList.concat(response.data);
            for (var i = 0; i < this.newsTypeList.length; i++) {
              var newType = this.newsTypeList[i];
              if (newType.id == "1009") {
                this.newsTypeList.splice(i,1);
                break;
              }
            }
          } else {
            for (var i = 0; i < response.data.length; i++) {
              var newType = response.data[i];
              if (newType.id == "1009") {
                this.newsTypeList.push(newType);
                break;
              }
            }
          }
          this.$nextTick(() => {
            //走马灯手指可左右滑动
            this.slideBanner();
          })
          this.currentNewsTypeId = this.$route.params && this.$route.params.newsTypeId;
          let storageNewsTypeId = sessionStorage.getItem('mobileCurrentNewsTypeId');
          if (storageNewsTypeId) {
            this.currentNewsTypeId = storageNewsTypeId;
          }
          this.activeName = this.currentNewsTypeId;
          //sessionStorage mobileCurrentNewsTypeId
          sessionStorage.setItem('mobileCurrentNewsTypeId', this.currentNewsTypeId);
          this.onLoad()
          //定时滑动
          let time = setInterval(() => {
            let dom = document.getElementById('tab-' + this.currentNewsTypeId);
            if (dom) {
              this.addClass(dom, 'is-active');
              dom.scrollIntoView({block: 'center', inline: 'center'});
              clearInterval(time);
            }
          }, 10)
        }
      })
      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });

      //赋值轮播新闻信息
      this.setCarouselNewsList();
    }else{
      this.msgWarning('暂无访问权限');
    }

  },
  activated () {
    if (this.showType == "1") {
      document.title = "国行动态";
    } else {
      document.title = "通知公告";
    }
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
      this.tabs.active = this.newsTypeList.findIndex(v => v.id === val) || 0
    },
    'tabs.active' (val) {
      if (val < 0) {
        return
      }
      if (this.currentNewsTypeId === this.newsTypeList[this.tabs.active].id) {
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
    setCarouselNewsList() {
      let data = {};
      data.isLikeQuery = true;
      data.isCarousel = '1';
      data.pageNum = 1;
      data.pageSize = 4;
      data.title = this.searchTitle;
      listNews(data).then(response => {
        this.carouselNewsList = this.carouselNewsList.concat(response.rows);
      })
    },
    list() {
       cancelHttp()
      let data = {};
      data.isLikeQuery = true;
      if (this.currentNewsTypeId != 'all') {
        data.newsTypeId = this.currentNewsTypeId;
      }
      data.pageNum = this.pageNum;
      data.pageSize = this.pageSize;
      data.title = this.searchTitle;
      listNews(data, 'canCancel').then(response => {
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
        console.log('err', err)
        if (err && err.message === 'CANCEL') {
          // 请求中断，不做操作
        } else {
          this.listComp.finished = true;
          this.listComp.loading = false
          this.listComp.err = true
        }
      })
      
    },
    search() {
      this.newsList = [];
      this.list();
    },
    tabClick(index, title) {
      const tab = this.newsTypeList[index]
      this.currentNewsTypeId = tab.id || 'all';
      this.pageNum = 0;
      this.newsList = [];
     
      this.onLoad();
      //sessionStorage mobileCurrentNewsTypeId
      sessionStorage.setItem('mobileCurrentNewsTypeId', tab.id);
    },
    showDetail(id) {
      this.$router.push({
        path: '/mobile/home/detail/' + id
      });
    },
    // 滑动切换
    slideBanner() {
      //选中的轮播图
      var box = document.querySelector('.el-carousel__container');
      var startPoint = 0;
      var stopPoint = 0;
      //重置坐标
      var resetPoint = function () {
        startPoint = 0;
        stopPoint = 0;
      }
      //手指按下
      box.addEventListener("touchstart", function (e) {
        //手指点击位置的X坐标
        e.stopPropagation()
        startPoint = e.changedTouches[0].pageX;
      });
      //手指滑动
      box.addEventListener("touchmove", function (e) {
        //手指滑动后终点位置X的坐标
        e.stopPropagation()
        stopPoint = e.changedTouches[0].pageX;
      });
      //当手指抬起的时候，判断图片滚动离左右的距离
      let that = this
      box.addEventListener("touchend", function (e) {
        e.stopPropagation()
        if (stopPoint == 0 || startPoint - stopPoint == 0) {
          resetPoint();
          return;
        }
        if (startPoint - stopPoint > 0) {
          resetPoint();
          that.$refs.slideCarousel.next();
          return;
        }
        if (startPoint - stopPoint < 0) {
          resetPoint();
          that.$refs.slideCarousel.prev();
          return;
        }
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
