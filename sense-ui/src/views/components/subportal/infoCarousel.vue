<template>
  <div class="wrapper" v-loading="loading" :style="{'height': height}">
    <div class="carousel-panel" v-if="dataList && dataList.length>0">
      <el-carousel style="height: 100%" :interval="3000" arrow="always" :indicator-position=" dataList.length==1 ? 'none' :'outside'" >
        <el-carousel-item v-for="item in dataList" @click.native="showDetail(item)" :key="item.id">
          <el-image style="width: 100%; height: 100%"
            :src="item.cover"
            fit="fit">
            </el-image>
        </el-carousel-item>
      </el-carousel>
    </div>
    <div class="empty" v-show="!dataList.length">
      <div class="empty-main">
        <img src="@/assets/images/empty.png">
        <div>暂无内容</div>
      </div>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";
import {allBanner} from "@/api/console/info/banner";
import {addInfoLog } from "@/api/console/info/log";
export default {
  name: "InfoCarousel",
  props: ['maxHeight', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      dataList: [],
      loading:true,
    }
  },
  created() {
    this.init();
  },
  methods: {
    init() {
      this.loading=true
      //查询所有banner
      allBanner({
        isRotation:1,
        status:1,
        isTime:true
      }).then(resp=>{
        this.loading=false;
        this.dataList=resp;
      }).catch(err=>{
        this.loading=true;
      })
    },
    showDetail(item) {
      if(item.bannerUrl!=undefined &&item.bannerUrl!=null && item.bannerUrl!=''  ){
        addInfoLog({
          title:item.title,
          objId:item.id,
          type:'2'
        }).then(resp=>{
           
        })
        window.open(item.bannerUrl);
      }
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
    width: 100%;
    position: relative;
    ::v-deep .el-carousel{
      height: 100%;
      .el-carousel__container{
        height: 100%;
        position: relative;
        cursor: pointer;
      }
       .el-carousel__indicators{
        position: absolute;
        bottom: 1%;
      }
      .el-carousel__indicators--outside button{
        background-color: #2b64b5;
        height: 4px;
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
