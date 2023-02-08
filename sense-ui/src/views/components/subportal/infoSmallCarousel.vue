<template>
  <div class="finance" :style="{'overflow': 'hidden','max-height':maxHeight,'height':maxHeight}">
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
    <div class="financeMain publicTip" v-if="dataList.length==0">
      <div class="emptyData">
         <img src="@/assets/images/empty.png" alt="">
         <p>暂无相关内容</p>
      </div>
    </div>
    <div class="financeMain publicTip" v-if="dataList.length!=0">
      <el-carousel :interval="5000" indicator-position="outside" arrow="never"
                   :autoplay="true">
        <el-carousel-item v-for="item in dataList" :key="item.id">
          <div class="financePadding" @click="showDetail(item.id)">
            <h3 class="financeTitle publicHidden">{{ item.title }}</h3>
            <el-image
              style="width: 100%; height: 100%"
              :src="baseFilePath+item.photo"
              fit="contain">
            </el-image>
            <!-- <img v-if="item.photo!=null && item.photo!=undefined && item.photo!=''" :src="baseFilePath+item.photo" alt="图片出错" width="100%" height="195px" style="cursor: pointer;border-radius: 4px;">
            <img v-else src="@/assets/images/thumbnail.png" width="100%" height="195px" style="cursor: pointer;border-radius: 4px;"> -->
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "InfoSmallCarousel",
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

<style lang="scss" scoped>
.finance {
  height: 300px;
}

.financeMain{
  height: calc(100% - 53px);
}

::v-deep .el-carousel--horizontal{
  height: 100%;
}
::v-deep .el-carousel__container{
  height: calc(100% - 32px)!important;
}
::v-deep .bankerPadding, .financeMain .el-carousel__item, .seashellPadding{
  padding: 0 20px;
}
.financePadding {
  position: relative;
  top: 0;
  height: 100%;
  cursor: pointer;
}

.financePadding .financeTitle {
  position: absolute;
  bottom: 0;
  width: 100%;
  height: 40px;
  line-height: 40px;
  background: rgba(0, 0, 0, 0.2);
  font-size: 14px;
  font-weight: 500;
  color: #FFFFFF;
  padding: 0 16px;
  z-index: 10;
}
</style>
