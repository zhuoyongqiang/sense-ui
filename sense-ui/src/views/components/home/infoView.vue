<template>
  <div class="flag">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title }}</span>
      </div>
      <div class="publicTitleMore">
        <router-link to='#'>
          <span @click="showMore">更多
          <i class="el-icon-arrow-right"></i>
          </span>
        </router-link>
      </div>
    </div>
    <div class="flagContent publicContent publicFlex" v-if="dataList.length==0">
      <div  class="emptyData">
         <img src="@/assets/images/empty.png" alt="">
         <p>暂无相关内容</p>
      </div>
    </div>
    <div class="flagContent publicContent publicFlex" v-if="dataList.length!=0">
      <div class="newsImg" v-for="(item,index) in dataList" :key="item.id" @click="showDetail(item.id)"
           v-if="index==0">
        <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src='baseFilePath+item.photo' alt=""
             width="350px" height="210px"
             style="border-radius: 4px;cursor: pointer;">
        <img v-else src="@/assets/images/thumbnail.png" width="350px" height="210px"
             style="border-radius: 4px;cursor: pointer;">
      </div>
      <div class="windowList">
        <ul>
          <li
            class="publicFlex"
            v-for="(item,index) in dataList" :key="item.id"
            @click="showDetail(item.id)"
          >
            <span class="windowTitle" :title="item.title"> <i v-if="item.isNew" class="news-icon"></i>{{ item.title }}</span>
            <span class="windowTime">{{ item.effectTime!=undefined && item.effectTime.length>10?item.effectTime.substring(5,10):item.effectTime }}</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "infoView",
  props: ['icon', 'title', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      dataList: []
    }
  },
  created() {
    this.init();
  },
  methods: {
    init() {
      let data = this.params;
      if (!data) {
        data = {};
      }
      data.pageNum = this.pageNum;
      data.pageSize = this.pageSize;
      listNews(data).then(response => {
        this.dataList = response.rows;
      });
    },
    showMore() {
      window.open('/home/window/' + this.params.newsTypeId)
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style scoped>


.flag {
  height: 300px;
}

.flagContent > ul > li {
  width: 100%;
  margin-bottom: 16px;
  cursor: pointer;
}

.flagImg {
  width: 150px;
}

.flagNews {
  width: calc(100% - 150px);
}

.flagContent > ul > li:hover .flagNews > h3 {
  color: #0B86F1 !important;
}

.flagNews > h3 {
  font-size: 14px;
  font-weight: 600;
  color: #333333;
  margin-bottom: 40px;
}

.flagNews > p {
  font-size: 14px;
  font-weight: 500;
  color: #797979;
}

.flagContent ul li + li > div:first-child {
  display: none;
}

.flagContent ul li:not(:first-child) .flagNews > h3 {
  font-size: 14px;
  font-weight: 500;
  color: #333333;
  float: left;
  margin-bottom: 0;
  width: 72%;
}

.flagContent ul li:not(:first-child) .flagNews {
  width: 100%;
}

.flagContent ul li:not(:first-child) .flagNews > p {
  color: #999999;
  float: right;
  width: 24%;
  text-align: right;
}

.newsImg {
  margin-right: 20px;
  width: 350px;
}

.newsImg > img {
  width: 100%;
}

.windowList {
  width: 370px;
}

.windowTime {
  text-align: right !important;
}

.windowList li:first-child span:first-child {
  font-size: 16px;
  font-weight: 600;
  color: #333333;
}

.windowTitle {
  font-size: 14px;
  font-weight: 500;
  color: #333333;
  width: calc(100% - 50px);
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  box-sizing: border-box;
  margin-right: 10px;
  display: inline-block;
  max-height: 44px;
}

.windowTime {
  font-size: 14px;
  font-weight: 500;
  color: #999999;
  width: 45px;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  box-sizing: border-box
}

.news-icon {
  background-image: url("~@/../src/assets/images/mobile/window/new.png");
  display: inline-block;
  background-size: 100% 100%;
  width: 28px;
  height: 14px;
  vertical-align: middle;
  margin-right: 3px;
  margin-bottom: 2px;
}

</style>
