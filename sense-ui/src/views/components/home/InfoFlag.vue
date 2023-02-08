<template>
  <div class="flag" :style="{height:height}">
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
    <div class="flagContent publicContent publicFlex">
      <ul style="width: 100%;">
        <li
          v-for="item in dataList" :key="item.id"
          class="publicFlex"
        >
          <div class="flagImg">
            <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src='baseFilePath+item.photo'
                 width="135" height="90">
            <img v-else src="@/assets/images/thumbnail.png" width="135" height="90">
          </div>
          <div class="flagNews">
            <h3 class="publicHidden" @click="showDetail(item.id)">{{ item.title }}</h3>
            <p>{{ item.effectTime }}</p>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "InfoFlag",
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

</style>
