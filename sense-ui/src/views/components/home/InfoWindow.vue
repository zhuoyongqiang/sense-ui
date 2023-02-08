<template>
  <div class="window">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title }}</span>
      </div>
      <div class="publicTitleMore">
        <router-link to='#'>
          <span @click="showMore">更多</span>
          <i class="el-icon-arrow-right"></i>
        </router-link>
      </div>
    </div>
    <div class="windowContent publicContent publicFlex">
      <div class="windowImg publicTips">
        <el-carousel :height="height" :interval="5000" style="width:350px" ref="carousel" @change="carousel"
                     arrow="never"
                     :autoplay="autoplay">
          <el-carousel-item v-for="item in dataList" :key="item.id">
            <a @click="showDetail(item.id)">
              <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src="baseFilePath+item.photo" width="100%" height="100%">
              <img v-else src="@/assets/images/thumbnail.png"  width="100%" height="100%">
              <div class="zhe"></div>
            </a>
          </el-carousel-item>
        </el-carousel>
      </div>
      <div class="windowList">
        <ul>
          <li
            class="publicFlex"
            v-for="(item,index) in dataList" :key="index"
            :class="{windowActive :windowActive==index}"
            v-on:mouseover="chooseCard(index)"
            @click="showDetail(item.id)"
          >
            <span class="windowTitle">{{ item.title }}</span>
            <span class="windowTime">{{ item.effectTime }}</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "InfoWindow",
  props: ['icon', 'title', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      autoplay: false,
      windowActive: 0,
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
    carousel(e) {
      this.windowActive = e;
    },
    chooseCard: function (index) {
      this.windowActive = index;
      this.$refs.carousel.setActiveItem(index);
    },
    showMore() {
      window.open('/home/window/' + this.params.newsTypeId);
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style scoped>

.windowTitle {
  font-size: 14px;
  font-weight: 500;
  color: #333333;
  width: 275px;
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
  width: 85px;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  box-sizing: border-box
}

.windowTime {
  text-align: right;
}

</style>
