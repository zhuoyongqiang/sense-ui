<template>
  <div class="bannerBox">
    <el-carousel :height="height" :interval="5000" arrow="never" >
      <el-carousel-item v-for="item in dataList" :key="item.id" v-if="dataList.length!=0">
        <a @click="showDetail(item.id)">
          <h3 class="bannerTitle publicHidden">{{ item.title }}</h3>
          <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src="baseFilePath+item.photo" alt="">
          <img v-else src="@/assets/images/thumbnail.png">
        </a>
      </el-carousel-item>
      <el-carousel-item v-if="dataList.length==0">
         <h3 class="bannerTitle publicHidden">暂无相关内容</h3>
      </el-carousel-item>
    </el-carousel>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";
export default {
  name: "InfoCarousel",
  props: ['baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
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

<style>

.bannerBox {
  border-radius: 4px;
  overflow: hidden;
  position: relative;
  top: 0;
  margin-bottom: 20px;
}

.bannerBox img {
  width: 100%;
  height: 100%;
}

.bannerBox h3 {
  position: absolute;
  bottom: 0;
  height: 50px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 0px 0px 4px 4px;
  font-size: 18px;
  font-weight: 600;
  color: #FFFFFF;
  white-space: nowrap;
  overflow: hidden;
  line-height: 50px;
  box-sizing: border-box;
  text-indent: 20px;
  width: 100%;
  padding-right: 120px;
}

.bannerBox .el-carousel__button {
  width: 10px;
  height: 4px;
  background: #FFFFFF;
  border-radius: 2px;
  opacity: 0.4;
}

.bannerBox .el-carousel__indicator--horizontal {
  padding: 23px 4px;
}

.bannerBox .el-carousel__indicators--horizontal {
  right: 20px;
  left: auto;
  transform: translateX(0%);
}
</style>
