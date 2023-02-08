<template>
  <div class="trends" v-if="isUserLogin">
    <div class="search-wrapper" :style="{backgroundColor: isIos ? '#4378be' : '#4f77aa'}">
      <!-- <el-input readonly placeholder="标题关键词等" suffix-icon="el-icon-search" @click.native="toSearch"></el-input> -->
      <el-input placeholder="标题关键词等" v-model="searchTitle" clearable :suffix-icon="searchTitle ? '' : 'el-icon-search'"></el-input>
    </div>
    <div class="picker-wrapper">
      <el-select v-model="orgValue" disabled>
        <el-option
          v-for="item in Orgoptions"
          :key="item.value"
          :label="item.label"
          :value="item.value">
        </el-option>
      </el-select>
      <el-select v-model="dateValue" @change="dateChange">
        <el-option
          v-for="item in timeRange"
          :key="item.value"
          :label="item.label"
          :value="item.value">
        </el-option>
      </el-select>
    </div>
    <div class="tabsd content">
      <PullRefresh :disabled="refreshbtn" v-model="refreshing" @refresh="onRefresh">
        <List :data="listComp" @load="onLoad" @reload="onRefresh">
          <div v-for="item in newsList" :key="item.id" @click="showDetail(item)" class="wrapper">
            <div class="header">
                <img src="../../../assets/images/mobile/window/notice.png"/>
                <div class="title">{{item.title}}</div>
                <div class="readTag" :class="{'already': item.read}">{{item.read ? '已读' : '未读'}}</div>
              </div>
              <div class="main" v-show="item.abtract">
                
                <div class="img-container" v-if="item.photo">
                  <el-image style="width: 100%; height: 100%" :src="baseFilePath+item.photo" fit="cover" lazy></el-image>
                </div>
                <div class="text">{{item.abtract}}</div>
              </div>
              <div class="footer">
                <span class="time">{{ item.effectTime | changeTime }}</span>
                <span class="more">查看详情</span>
              </div>
          </div>
        </List>
      </PullRefresh>
      <!-- 无数据提醒 -->
      <div v-show="!listComp.loading && !listComp.err && newsList.length === 0 && listComp.finished === true" style="text-align: center; margin-top: 30%;font-size:0">
        <img src="./../../../assets/images/mobile/window/nodata.png" style="width: 3.7rem">
        <p style="font-size: .37rem; color:#2B3949; font-weight: 400;">当前暂无数据~  </p>
      </div>
    </div>
  </div>
</template>

<script>
import {getConfigKey} from "@/api/home/config";
import {allNewsType} from "@/api/home/newsType";
import {listNews, read} from "@/api/home/news";
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import { on, off } from '@/utils/event'
import scrollUtils from '@/utils/scroll'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'

export default {
  name: "mobileNotice",
  components: {PullRefresh, List},
  data() {
    return {
      orgValue: '02',
      Orgoptions: [
        {
          value: '01',
          label: '集团'
        },
        {
          value: '02',
          label: '机构'
        },
        {
          value: '03',
          label: '组织'
        }
      ],
      dateValue: 'all',
      timeRange: [
        {
          value: 'all',
          label: '所有日期'
        },
        {
          value: 'week',
          label: '近一周'
        },
        {
          value: 'month',
          label: '近一个月'
        }
      ],
      currentNewsTypeId: '1009',
      total: 0,
      pageNum: 0,
      pageSize: 10,
      searchTitle: undefined,
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
      showType: "2", //显示类型， 为1时显示所有除了通知公告    为2时只显示通知公告
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
      homeTop: 0,
      showscrolltabsd: true,
      timer: null,
      startTime: null,
      endTime: null
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
  },
  filters: {
    changeTime :function (value) {
      return value.substr(0,value.length - 6);
    }
  },
  watch: {
    'searchTitle' (newval) {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => {
        this.onRefresh()
      }, 2000)
    },
    dateValue (val) {
      this.onRefresh()
    }
  },
  created () {
    document.title = "";
  },
  mounted() {
   if (this.isUserLogin) {
      const iphone = navigator.userAgent.match(/(iPhone\sOS)\s([\d_]+)/)
      if (iphone) {
        this.isIos = true;
      }
      allNewsType({isMore: 1}).then(response => {
        if (response.code == 200) {
          if (response.data.every(v => v.id !== '1009')) return 
          // for (var i = 0; i < response.data.length; i++) {
          //   var newType = response.data[i];
          //   if (newType.id == "1009") {
          //     this.newsTypeList.push(newType);
          //     break;
          //   }
          // }
          this.onLoad()
        }
      })
      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
    }else{
      this.msgWarning('暂无访问权限');
    }

  },
  activated () {
    // 页面每次加载时更改页面标题
    // 设置已读未读标识
    document.title = "通知公告";
    if (!document.getElementsByClassName('content')[0]) {
      return
    }
    document.getElementsByClassName('content')[0].scrollTop = this.homeTop || 0
    if (this.newsList.length) {
      const readTagArr = sessionStorage.getItem('readTag') && JSON.parse(sessionStorage.getItem('readTag'))
      if (readTagArr && readTagArr.length) {
        readTagArr.forEach(v => {
          if (this.newsList.find(k => k.id === v)) this.$set(this.newsList.find(k => k.id === v), 'read', true)
        })
        sessionStorage.removeItem('readTag')
      }
    }
  },
  deactivated () {
    // 清除计时器
    clearTimeout(this.timer)
  },
  beforeRouteLeave (to, from, next) {
    // 路由离开前记录页面滚动位置
    let app = document.getElementsByClassName('content')[0]
    this.homeTop = app.scrollTop || 0
    next()
  },
  methods: {
    // 重新加载事件
    reLoad () {
      this.onRefresh()
    },
    // 设置查询时间
    setTimeRange (type) {
      let end = new Date().format('yyyy-MM-dd')
      let start = new Date()
      switch (type) {
        case 'all':
          // 所有日期
          end = ''
          start = ''
          break
        case 'week':
          // start.setTime(start.getTime() - 3600 * 1000 * 24 * 7)
          start = new Date(start.getTime() - 3600 * 1000 * 24 * 7).format('yyyy-MM-dd')
          console.warn(end, start)
          break
        case 'month':
          // start.setTime(start.getTime() - 3600 * 1000 * 24 * 30)
          start = new Date(start.getTime() - 3600 * 1000 * 24 * 30).format('yyyy-MM-dd')
          console.warn(end, start)
          break
        default:
          break
      }
      this.startTime = start
      this.endTime = end
    },
    // 日期变动触发事件
    dateChange (val) {
      this.setTimeRange(val)
      this.onRefresh()
    },
    // 列表加载事件
    list() {
      let data = {};
      data.isLikeQuery = true;
      data.newsTypeId = '1009';
      data.pageNum = this.pageNum;
      data.pageSize = this.pageSize;
      data.title = this.searchTitle;
      if (this.startTime) {
        data.params = {
          startTime: this.startTime,
          endTime: this.endTime
        }
      }
      
      listNews(data).then(response => {
        // this.finish = true;
        if (response.rows.length < this.pageSize) {
          this.listComp.finished = true;
        } else {
          this.listComp.finished = false;
        }
        this.listComp.loading = false
        response.rows.forEach(v => {
          this.newsList.push(v)
        });
        // this.newsList = this.newsList.concat(response.rows);
        this.total = response.total;
      }).catch(err => {
        this.listComp.finished = true;
        this.listComp.loading = false;
        this.listComp.err = true
        console.warn(err)
      })
      
    },
    // 跳转新闻详情
    showDetail(item) {
      // this.newsList.find(v => v.id === id).isRead = true
      // 向后端标记新闻已读，异步操作，不阻塞页面跳转
      if (!item.read) {
        read(item.id).then(() => {
        }).catch(err => {
          console.warn(err)
        })
        this.$set(this.newsList.find(v => v.id === item.id), 'read', true)
      }
      this.$router.push({
        path: '/mobile/home/detail/' + item.id
      })
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

<style lang="scss" scoped>

.trends {
  background: #F6F8FC;
  height: 100%;
  display: flex;
  flex-direction: column;
}
.tabsd{
  flex: 1;
  overflow-y: auto;
}
.block{
  padding: 0 .32rem;
}

.search-wrapper{
  height: 1.38rem;
  display: flex;
  align-items: center;
  padding: 0 .43rem;
}
.search-wrapper ::v-deep .el-input{
  border-radius: .51rem;
  overflow: hidden;
  font-size: .37rem;
}
.search-wrapper ::v-deep .el-input__inner{
  height: .85rem;
  line-height: .85rem;
}
.search-wrapper ::v-deep .el-input__icon{
  color:#2272DE;
  font-weight: bold;
  font-size: 20px;
}

.picker-wrapper{
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: .27rem .3rem .2rem;
  box-sizing: border-box;
  >div{
    width: calc(50% - .15rem);
  }
  // ::v-deep .el-date-editor{
  //   width: 100%;
  // }
}
.picker-wrapper ::v-deep .el-input {
  // border-color: #fff;
  input{
    font-size: .37rem;
    border-radius: 4px!important;
    border-color: #fff!important;
    background-color: #fff;
    color:#606266;
    &::placeholder {
        color: #606266;
    }
  }
  // &:not(.is-disabled) input {
  //   border-color: #fff!important;
  // }
}
.picker-wrapper ::v-deep .el-input__icon{
  font-size: 20px;
}
.picker-wrapper ::v-deep .el-icon-arrow-up:before {
  // content: "\e790";
  content: '\e78f';
}
.picker-wrapper ::v-deep .el-icon-arrow-down:after {
  // content: '\e78f';
  content: "\e790";
}
.picker-wrapper ::v-deep .el-date-editor{}

.wrapper{
  margin: 0 .32rem .21rem .32rem;
  padding: .32rem .26rem .21rem;
  background: #FFFFFF;
  box-shadow: 0px 2px 14px 0px rgba(227, 218, 218, 0.5);
  border-radius: .11rem;
}
.newsImg {
  width: 100%;
  height: 1.92rem;
  border-radius: 2px;
  overflow: hidden;
}

.header{
  display: flex;
  align-items: center;
  margin-bottom: .2rem;
  width: 100%;
  >img{
    width: 30px;
    height: 30px;
    margin-right: .21rem;
  }
  .title{
    // align-self: flex-start;
    width: 100%;
    font-size: .37rem;
    color:#303133;
    font-weight: 600;
    line-height: .53rem;
    word-break: break-all;
    text-overflow: ellipsis;
    display: -webkit-box; /** 对象作为伸缩盒子模型显示 **/
    -webkit-box-orient: vertical; /** 设置或检索伸缩盒对象的子元素的排列方式 **/
    -webkit-line-clamp: 2; /** 显示的行数 **/
    overflow: hidden;  /** 隐藏超出的内容 **/
    position: relative;
    text-align: justify;
    
  }
  .readTag{
    align-self: flex-start;
    font-size: .26rem;
    border-radius: .05rem;
    color:#2272DE;
    background-color: rgba($color: #2272DE, $alpha: .2);
    padding: 0.06rem .11rem;
    // height: .43rem;
    // line-height: .41rem;
    box-sizing: border-box;
    white-space: nowrap;
    margin-left: .32rem;
    // margin-top: 2px;
    &.already{
      background-color: #EAEAEA;
      color:#A9A9A9;
    }
  }
}

.main{
  padding-left: 1.01rem;
  .img-container{
    width: 100%;
    max-height: 2.5rem;
    overflow: hidden;
    background-size: cover;
    background-position: center center;
    background-repeat: no-repeat;
    height: 2.6rem;
    margin-bottom: .21rem;
  }
  img{
    width: 100%;
    height: auto;
  }
  .text{
    font-size: .37rem;
    color:#606266;
    word-break: break-all;
    text-overflow: ellipsis;
    display: -webkit-box; /** 对象作为伸缩盒子模型显示 **/
    -webkit-box-orient: vertical; /** 设置或检索伸缩盒对象的子元素的排列方式 **/
    -webkit-line-clamp: 2; /** 显示的行数 **/
    overflow: hidden;  /** 隐藏超出的内容 **/
    margin-bottom: .21rem;
  }
}

.footer{
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: .32rem;
  position: relative;
  padding-top: .18rem;
  &::after{
    position: absolute;
    height: 1px;
    width: 100%;
    background-color: #F2F2F3;
    transform: scaleY(.5);
    content: '';
    top: 0;
    left: 0;
  }
  // margin-top: .48rem;
  .time{    
    color:#8F9193;
    
  }
  .more{
    color:#2272DE;
  }
}

</style>
