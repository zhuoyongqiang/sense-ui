<template>
  <div class="wrapper" v-loading="loading" :style="{'height': height}">
    <div class="carousel-panel">
      <el-carousel style="height: 100%" :interval="3000" arrow="never" indicator-position="none" @change="carouselChange">
        <el-carousel-item v-for="item in dataList" @click.native="showDetail(item.id)" :key="item.id">
          <el-image style="width: 100%; height: 100%"
            :src="baseFilePath + (item.photo || '')"
            fit="fit">
              <!-- <img  style="width: 100%; height: 100%" slot="error" src="https://img2.baidu.com/it/u=305287840,2213595844&fm=26&fmt=auto&gp=0.jpg"> -->
            </el-image>
        </el-carousel-item>
      </el-carousel>
      <div class="desc" v-show="dataList.length">{{dataList.length && dataList[activeCarousel].title}}</div>
    </div>
    <div class="content-panel">
      <div class="title" v-for="item in dataList" @click="showDetail(item.id)" :key="item.id">{{item.title}}</div>
    </div>
    <div class="empty" v-show="loaded && !dataList.length">
      <div class="empty-main">
        <img src="@/assets/images/empty.png">
        <div>暂无内容</div>
      </div>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "InfoCarousel",
  props: ['maxHeight', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      dataList: [],
      loading: false,
      loaded: false,
      activeCarousel: 0
    }
  },
  created() {
    this.init();
  },
  methods: {
    carouselChange (item) {
      this.activeCarousel = item
    },
    init() {
      let data = this.params;
      if (!data) {
        data = {};
      }
      data.pageNum = this.pageNum || 1;
      data.pageSize = this.pageSize || 5;
      this.loading = true
      this.loaded = false
      listNews(data).then(response => {
        // 测试代码
        // for (let i = 0; i < 10; i++) {
        //   this.dataList.push(response.rows[i] || {id: i, title: '阿斯顿发送到发送到法撒旦法撒旦法但是'})
        // }
        this.dataList = response.rows
        this.loading = false
        this.loaded = true
      }).catch(() => {
        this.loading = false
        this.loaded = true
      })
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style lang="scss" scoped>
  .wrapper{
    display: flex;
    height: 246px;
    background-color: #fff;
    overflow: hidden;
    position: relative;
  }
  .carousel-panel{
    width: 49%;
    min-width: 49%;
    position: relative;
    ::v-deep .el-carousel{
      height: 100%;
      .el-carousel__container{
        height: 100%;
        position: relative;
        cursor: pointer;
      }
      .el-carousel__item {
        // opacity: 0;
        transition: opacity 1s;
        opacity: 0;
        
        // transition-timing-function: linear;
        &.is-animating:not(.is-active){
          opacity: 0;
          transition-timing-function: ease-out;
          transform: translateX(0) !important;
        }
        &.is-active.is-animating{
          transition-timing-function: ease-in;
          opacity: 1;
          // width: 80%;
          // transform: translateX(12.5%) !important;
        }
      }
    }
    .desc{
      position: absolute;
      left: 0;
      bottom: 0;
      width: 100%;
      background-color: rgba($color: #000, $alpha: .3);
      // background-color: #000;
      // opacity: 0.3;
      color:#fff;
      font-weight: 600;
      font-size: 16px;
      text-align: center;
      height: 44px;
      line-height: 44px;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
      padding: 0 20px;
      z-index: 100;
    }
  }
  .content-panel{
    padding: 14px 20px;
    width: 51%;
    font-weight: 400;
    color: #303133;
    font-size: 14px;
    height: 100%;
    overflow: hidden;
    .title{
      width: 100%;
      cursor: pointer;
      margin-bottom: 15px;
      &:first-child{
        font-weight: 600;
        color: #2272DE;
        font-size: 18px;
        max-height: 50px;
        overflow: hidden;
        text-overflow: -o-ellipsis-lastline;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        line-clamp: 2;
        -webkit-box-orient: vertical;
        margin-bottom: 12px;
        line-height: 1.5;
      }
      &:not(:first-child){
        line-height: 1;
        padding-left: 13px;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        position: relative;
        &::before{
          content: '';
          position: absolute;
          left: 0;
          top:50%;
          transform: translate(0, -50%);
          width: 6px;
          height: 6px;
          background-color: #2272DE;
          opacity: 0.4;
        }
      }
      // &:not(:last-child) {
      //   margin-bottom: 16px;
      // }
    }
  }
  .empty{
    position: absolute;
    margin: 0;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    .empty-main{
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      position: absolute;
      text-align: center;
    }
  }
</style>
