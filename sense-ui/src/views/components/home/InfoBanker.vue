<template>
  <div class="finance">
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
     <div class="bankerMain publicTip" v-if="dataList.length==0">
        <div class="emptyData">
         <img src="@/assets/images/empty.png" alt="">
         <p>暂无相关内容</p>
      </div>
    </div>
    <div class="bankerMain publicTip"  v-if="dataList.length!=0">
      <el-carousel height="215px" :interval="5000" indicator-position="outside" arrow="never" :autoplay="true">
        <el-carousel-item v-for="item in dataList" :key="item.id">
          <div class="publicFlex bankerPadding">
            <div @click="showDetail(item.id)" class="bankerNews">
              <h3 class="publicHidden">{{ item.effectTime!=undefined && item.effectTime.length>10?item.effectTime.substring(5,10):item.effectTime }}</h3>
              <h3 class="publicHidden">{{ item.title }}</h3>
              <p class="publicHidden">{{ item.issuer }}</p>
              <p class="publicHiddenThreeLine">{{ item.abtract }}</p>
              <p class="more">了解更多</p>
            </div>
            <div class="bankerImg">
              <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src="baseFilePath+item.photo"
                   width="158" height="190" style="border-radius: 4px;">
              <img v-else src="@/assets/images/thumbnail.png" width="158" height="200" style="border-radius: 4px;">
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>
  </div>
</template>

<script>

import {listNews} from "@/api/home/news";

export default {
  name: "InfoBanker",
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

<style>
  .banker > div > div >.el-carousel__container{
    height: 215px !important;
  }
</style>
