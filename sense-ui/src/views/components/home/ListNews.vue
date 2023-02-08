<template>
  <div class="news">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <span>{{ title }}</span>
      </div>
    </div>
    <div class="newsList">
      <div class="newsImg" v-if="dataList.length>0" @click="showDetail(dataList[0].id)">
        <img v-if="dataList[0].photo!=null && dataList[0].photo!=undefined && dataList[0].photo!=''"
             :src='baseFilePath+dataList[0].photo' width="100%" height="100%" style="cursor: pointer;">
        <img v-else src="@/assets/images/thumbnail.png" width="100%" height="100%" style="cursor: pointer;">
        <p class="publicHiddenTwoLine">{{ dataList[0].title }}</p>
      </div>
      <ul v-if="dataList.length>1">
        <li v-for="item in dataList.slice(1)" :key="item.id">
          <p @click="showDetail(item.id)" class="publicHiddenTwoLine">{{ item.title }}</p>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "ListNews",
  props: ['title', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
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
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style scoped>
.news {
  min-height: 300px;
  background: #FFFFFF;
  border-radius: 4px;
  margin-bottom: 20px;
}

.newsList {
  padding: 0 20px;
}

.newsImg {
  position: relative;
  height: 143px;
  padding-top: 20px;
  margin-bottom: 4px;
}

.newsImg > img {
  object-fit: fill;
}

.newsImg > p {
  position: absolute;
  bottom: 0;
  font-size: 14px;
  color: #FFFFFF;
  letter-spacing: 0.13px;
  font-weight: 500;
  padding: 6px 6px;
  background: rgba(0, 0, 0, 0.2);
  width: 100%;
  overflow: hidden; /*超出的部分隐藏起来。*/
  white-space: nowrap; /*不显示的地方用省略号...代替*/
  text-overflow: ellipsis; /* 支持 IE */
}

.newsList > ul > li {
  font-size: 14px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
  padding: 16px 0;
  border-bottom: 1px solid #F2F2F2;
  cursor: pointer;
}

.newsList > ul > li:hover {
  color: #5B7FBF;
}

.newsList > ul > li:last-child {
  border: none;
}
</style>
