<template>
  <div class="banner">
    <div id="myCarousel" class="bannerBox">
      <el-carousel height="235px" :interval="5000" arrow="never">
        <el-carousel-item v-for="item in dataList" :key="item.id">
          <a  @click="showDetail(item.id)">
            <h3 class="bannerTitle publicHidden">{{ item.title }}</h3>
            <img :src="baseFilePath+item.photo" alt="">
          </a>
        </el-carousel-item>
      </el-carousel>
    </div>
    <div class="newsList">
      <ul>
        <h2 v-for="(item,index) in oaList" :key="item.id" v-if="index==0" :class="index==0?'special':''">
          <p @click="showDetail(item.id)">
            {{ item.title }}
          </p>
        </h2>
        <li v-for="(item,index) in oaList" :key="item.id" v-if="index!=0">
          <p @click="showDetail(item.id)">
            {{ item.title }}
            <img v-if="item.isNew" src="@/assets/images/icon_new.png" width="30" height="15" alt="">
          </p>
          <p>{{ item.effectTime }}</p>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listNews, listOA} from "@/api/home/news";
import {getConfigKey} from "@/api/home/config";

export default {
  name: "oa",
  data() {
    return {
      dataList: [],
      oaList: [],
      baseFilePath: undefined
    }
  },
  created() {
    getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
    });
    this.initCarousel();
    this.initNews();
  },
  methods: {
    initCarousel() {
      let data = {};
      data.pageNum = 1;
      data.pageSize = 6;
      //<!--首页导航查询条件首页是否轮播设置-->
      data.isCarousel = '1';
      listNews(data).then(response => {
        this.dataList = response.rows;
      });
    },
    initNews() {
      listOA({}).then(response => {
        this.oaList = response;
      });
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
}

body {
  width: 100%;
  height: 100%;
  font-size: 14px;
  font-family: PingFang-SC-Medium, PingFang-SC;
  font-weight: 500;
  color: #333333;
  background: #F5F6FA;
}

#myCarousel {
  width: calc(50% - 5px);
  float: left;
  height: 100%;
  border-radius: 4px;
  overflow: hidden;
}

.banner >>> .el-carousel__indicators--horizontal {
  right: 20px;
  left: auto;
}

.banner >>> .el-carousel__button {
  width: 10px;
  height: 4px;
  background: #FFFFFF;
  border-radius: 2px;
  opacity: 0.4;
}

.banner >>> .el-carousel__indicator.is-active button {
  opacity: 1 !important;
}

.banner >>> .el-carousel__indicator--horizontal {
  padding: 15px 4px;
}

.newsList {
  width: calc(50% - 10px);
  float: right;
  height: 100%;
}

.banner {
  width: 100%;
  height: 275px;
  overflow: hidden;
  padding: 20px;
  background: #ffff;
}

.newsList > ul, .newsList > ul > li {
  width: 100%;
  list-style: none;
  cursor: pointer;
  overflow: hidden;
}

.newsList > ul > li {
  padding: 5px 20px;
  padding: 5px 20px 5px 10px;
  font-size: 14px;
}

.newsList > ul > h2 {
  background: #f5f5f5;
  padding: 15px 20px;
}

.newsList > ul > h2 > p:hover {
  text-decoration: underline;
}

.newsList > ul > h2 > p {
  margin: 0;
  font-size: 28px;
  line-height: normal;
  text-align: center;
  font-weight: 600;
  overflow: hidden;
  display: -webkit-box;
  text-overflow: ellipsis;
  -webkit-line-clamp: 2; /*要显示的行数*/
  -webkit-box-orient: vertical;
  white-space: break-spaces;
  color: #2272DE;
}

.newsList > ul > li > p:hover {
  text-decoration: underline;
}

.newsList > ul > li > p {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  margin: 0;
  line-height: 20px;
}

/* .newsList > ul > li:first-child p:first-child {
  font-size: 28px;
  line-height: normal;
  text-align: center;
  font-weight: 600;
  overflow: hidden;
  display: -webkit-box;
  text-overflow: ellipsis;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  white-space: break-spaces;
  color: #2272DE;
} */

.newsList > ul > li > p:first-child {
  width: 70%;
  float: left;
}

.newsList > ul > li > p:last-child {
  width: 23%;
  text-align: right;
  float: right;
  color: #999999;
}

.bannerBox h3 {
  position: absolute;
  bottom: 0;
  height: 35px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 0px 0px 4px 4px;
  font-size: 14px;
  font-weight: 600;
  color: #FFFFFF;
  white-space: nowrap;
  overflow: hidden;
  line-height: 35px;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  text-indent: 20px;
  width: 100%;
  padding-right: 70px;
}

.bannerBox img {
  width: 100%;
  height: 100%;
}

.publicHidden {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
}
</style>
