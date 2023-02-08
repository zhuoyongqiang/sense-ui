<template>
  <div class="windowTemplate">
    <el-row>
      <navbar :currentPage="currentPage"></navbar>
    </el-row>
     <el-row>
      <div class="search">
        <div class="search_type">
          <el-input placeholder="请输入内容" size="small" v-model="search" class="input-with-select">
            <el-select  v-model="searchSelect" slot="prepend" >
              <el-option label="搜索标题" value="1"></el-option>
              <el-option label="搜索作者" value="2"></el-option>
            </el-select>
            <el-button slot="append" icon="el-icon-search" @click="list"></el-button>
          </el-input>
        </div>
      </div>
    </el-row>
    <el-row>
      <div class="search_two">
        <el-select v-model="queryParams.releaseType" size="small" style="width:120px" placeholder="" @change="list" >
          <el-option
            v-for="item in searchTimes"
            :key="item.key"
            :label="item.value"
            :value="item.key">
        </el-option>
        </el-select>
        <el-select v-model="queryParams.orderSql" size="small" style="width:120px" placeholder="" @change="list" >
          <el-option
            v-for="item in searchOrder"
            :key="item.key"
            :label="item.value"
            :value="item.key">
          </el-option>
        </el-select>
      </div>
    </el-row>
    <el-row>
      <div class="window_tabsMain">
        <el-tabs v-model="activeName" lazy="true" @tab-click="tabClick">
          <el-tab-pane v-for="item in newsTypeList" :key="item.id" :label="item.name" :name="item.id">
            <ul  style="min-height: 600px;" v-loading="loading">
              <li class="newsList" @click="showDetail(item.id)" v-for="item in newsList" :key="item.id">
                <div class="publicFlexBetwee">
                   <img v-if="item.isTop=='1'" src="../../assets/download/top.png" class="newsImg-top" >
                  <div class="newsImg">
                    <!-- <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''"
                         :src="baseFilePath+item.photo" alt="" width="180"
                         height="120">
                    <img v-else
                         src="@/assets/images/thumbnail.png" alt="" width="180"
                         height="120"> -->
                    <el-image :src="baseFilePath+item.photo" fit="fit" style="width: 180px; height: 120px">
                      <img slot="error" src="@/assets/images/thumbnail.png">
                    </el-image>
                    <div class="newsMain">
                      <h3 class="publicHidden">{{ item.title }}</h3>
                      <p class="publicHiddenTwoLine">{{ item.author }}</p>
                      <p class="publicHiddenTwoLine"></p>
                      <span>{{ item.releaseTime.substr(0,10) }}</span>
                    </div>
                  </div>
                </div>
              </li>
              <div v-show="!loading && !total" style="width: 100%;text-align: center;color: #a5a5a5;    margin-top: 100px;">
                <img src="@/assets/images/empty.png" alt="">
                <p style="
                    color: #9e9e9e;
                    margin-top: 20px;
                    font-size: 14px;
                ">暂无相关内容</p>
              </div>
            </ul>

            <div class="page" v-show="!loading">
              <pagination
                v-show="total>0"
                :total="total"
                :page.sync="queryParams.pageNum"
                :limit.sync="queryParams.pageSize"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
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
import $ from 'jquery';
import {getConfigKey} from "@/api/home/config";
import {allNewsType} from "@/api/home/newsType";
import navbar from '@/views/home/component/navbar'
import {listNotice} from "@/api/console/info/notice";
export default {
  name: "windowTemplate",
  components: {navbar},
  data() {
    return {
      loading: false,
      windowTitle: undefined,
      currentNewsTypeId: undefined,
      newsTypeList: [],
      total: 0,
      activeName: undefined,
      search:undefined,
      searchSelect:'1',
      queryParams: {
        isLikeQuery:true,
        pageNum: 1,
        pageSize: 20,
        status:'1',
        dataStatus:'2',
        title: null,
        author:null,
        releaseType:null,
        orderSql:null,
        isTime:true
      },
      newsList: [],
      baseFilePath: undefined,
      currentPage: ['公告中心'],
      searchTimes:[
        {key:null,value:'全部时间'},
        {key:'day',value:'今天'},
        {key:'week',value:'最近一周'},
        {key:'month',value:'最近一个月'},
      ],
      searchOrder:[
        {key:null,value:'综合排序'},
        {key:'RELEASE_TIME asc',value:'时间升序'},
        {key:'RELEASE_TIME desc',value:'时间降序'},
      ]
    }
  },
  mounted: function () {
    this.menuHide();//需要触发的函数
    if (this._isMobile()) {
      $('.bannerTitle,.window_window_tabsMain,.newsList').css('width', '100%');
      $('.search').css('top', '-40px');
      $('.window_window_tabsMain').css('margin-top', '55px');
    }
  },
  created() {
    this.currentNewsTypeId = this.$route.params && this.$route.params.newsTypeId;
    if (this._isMobile()) {
      window.location.href = "/mobile/home/window/" + this.currentNewsTypeId;
    }
    this.activeName = this.currentNewsTypeId;
    allNewsType({isMore: 1}).then(response => {
      if (response.code == 200) {
        this.newsTypeList = response.data;
        this.list();
      }
    })
    getConfigKey('file_download_url').then(response => {
      this.baseFilePath = response.msg;
    });

  },
  methods: {
    list() {
      if (this.$parent && this.$parent.$refs && this.$parent.$refs.routerView) this.$parent.$refs.routerView.scrollTop = 0
      this.loading = true
      this.newsList = [];
      this.queryParams.pageNum = 1;
      this.queryParams.author=null;
      this.queryParams.title=null;
      if(this.searchSelect=='1'){
        this.queryParams.title = this.search;
      }else if(this.searchSelect=='2'){
        this.queryParams.author=this.search;
      }
      listNotice(this.queryParams).then(response => {
        this.newsList = response.rows;
        this.total = response.total;
        this.loading = false
      }).catch(err => {
        this.loading = false
      })
    },
    searchEvent() {
      this.list();
    },
    getWindowTitle() {
      for (let i = 0; i < this.newsTypeList.length; i++) {
        if (this.newsTypeList[i].id == this.currentNewsTypeId) {
          return this.newsTypeList[i].name;
        }
      }
    },
    tabClick(tab, event) {
      this.currentNewsTypeId = tab.name;
      this.activeName = tab.name;
      this.pageNum = 1;
      this.list();
    },
    handleSizeChange(val) {
      this.list();
    },
    handleCurrentChange(val) {
      this.list();
    },
    menuHide() {
      this.menu == false;
    },
    _isMobile() {
      let flag = navigator.userAgent.match(/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i)
      return flag;
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style lang="scss" scoped>
  ::v-deep .navbar-wrapper{
    width: 1200px;
    margin: 0 auto;
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

.windowTitle, .window_tabsMain {
  width: 1200px;
  margin: 0 auto;
  position: relative;
  top: 0;
  display: block;
}

.window_tabsMain {
  margin-top: 0px;
  margin-bottom: 40px;
  position: relative;
  top: 0;
}

.newsList {
  margin-bottom: 40px;
  width: 50%;
  display: inline-block;
  cursor: pointer;
  &:nth-child(odd) {
    .newsImg{
      margin-right: 40px;
      position: relative;

    }
  }
}
.publicFlexBetwee{
  position: relative;
  .newsImg-top{
    position: absolute;
    top:0;
    left: 0;
    z-index:100;
    color:black;
  }
}

.newsImg .el-image {
  float: left;
  margin-right: 20px;
}

.newsMain > h3 {
  padding-bottom: 8px;
  border-bottom: 1px solid #D6D6D6;
  font-size: 16px;
  font-weight: 500;
  color: #3C3C3C;

  display: -webkit-box;
  white-space: normal;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
  box-sizing: border-box;
  margin-right: 10px;
  max-height: 88px;
}

.newsMain:hover h3 {
  color: #2272DE;
  border-bottom: 1px solid #2272DE;
}

.newsMain > p {
  font-size: 12px;
  font-weight: 500;
  color: #666666;
  text-align: left;
  margin: 8px 0 8px 0;
  max-height: 34px;
  overflow: hidden;
}

.newsMain {
  float: left;
}

.newsMain {
  width: calc(100% - 200px);
  text-align: left;
  cursor: pointer;
  display: inline-block;
  // margin-left: 8px;
  float: left;

  height: 120px;
  position: relative;
}

.newsMain > span {
  font-size: 12px;
  font-weight: 500;
  color: #999999;
  position: absolute;
  bottom: 0px;
  padding: 0px;
  margin: 0px;
}

// .search {
//   position: absolute;
//   top: 0;
//   right: 0;
//   z-index: 100;
// }

// .search ::v-deep input {
//   width: 240px;
//   height: 32px;
//   line-height: 32px;
//   background: #F2F3F9;
//   border-radius: 20px !important;
// }

// .search .el-input__icon {
//   line-height: 32px;
// }

 .search{
    width: 1200px;
    height: 70px;
    margin: 0px auto;
    .search_type{
      width:40%;
      height: 40px;
      margin:0px auto;
      ::v-deep .el-select  .el-input {
        width: 110px;
        text-align: center;
      }
      .input-with-select .el-input-group__prepend {
        background-color: #fff;

      }
    }
  }
  .search_two{
    width: 1200px;
    height: 40px;
    margin: 0px auto;
    ::v-deep
    .el-input__inner{
      border: none;
      font-size: 14px;
      font-weight: bold;
    }
    .select__caret{
      font-size: 15px;
    }
    ::v-deep .el-icon-arrow-up:before {
      content: "\e790";
    }
  }

.windowTemplate .el-tabs >>> .el-tabs__header {
  margin-bottom: 40px;
}
.pagination-container {
  height: 32px;
  padding: 0 !important;
}

.el-breadcrumb {
  line-height: 60px;
}

::v-deep .publicHidden{
  border-bottom: none!important;
}

</style>
