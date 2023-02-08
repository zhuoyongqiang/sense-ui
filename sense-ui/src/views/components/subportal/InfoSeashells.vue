<template>
  <div class="flag" :style="{'overflow': 'hidden','max-height':maxHeight,'height':maxHeight}">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title }}</span>
      </div>
      <div class="publicTitleMore" v-if="isMore">
        <a :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
          <span>
         {{moreName}}<i class="el-icon-arrow-right"></i>
          </span>
        </a>
      </div>
    </div>
    <div class="seashellsMain seashellPadding" v-if="dataList.length==0">
      <div class="emptyData">
         <img src="@/assets/images/empty.png" alt="">
         <p>暂无相关内容</p>
      </div>
    </div>
    <div class="seashellsMain seashellPadding"  v-if="dataList.length!=0">
      <ul @click="showDetail(item.id)" v-for="item in dataList">
        <li>
          <div class="publicFlex">
            <div class="userMain publicFlex">
              <div class="">
                <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src="baseFilePath+item.photo"
                     width="40" height="40">
                <img v-else src="@/assets/images/thumbnail.png" width="40" height="40">
              </div>
              <div class="userName">
                <h3>{{ item.title }}</h3>
                <p>{{ item.issuer }}</p>
              </div>
            </div>
            <div class="time">{{ item.effectTime!=undefined && item.effectTime.length>10?item.effectTime.substring(5,10):item.effectTime }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "InfoSeashells",
  props: ['maxHeight','isMore','moreName','morelink','linkType','icon','title', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
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
.seashellsMain ul:hover {
  text-decoration: none;
  cursor: pointer;

}
.userName > h3:hover{
  color:#3c72e5
}
.userName > h3 {
    font-size: 14px;
    font-weight: 500;
    color: #333333;
    width: 235px;
    display: -webkit-box;
    white-space: normal;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    margin-right: 10px;
    max-height: 44px;
}
</style>
