<template>
  <div class="wrapper" :style="{'height': height}">
    <div class="title-panel">
      <el-image :src="icon" style="width: 20px; height: 20px">
        <div slot="error" class="image-slot">
          <i class="el-icon-picture-outline" style="font-size: 20px"></i>
        </div>
      </el-image>
      <div class="title">{{componetTitle}}</div>
      <a v-show="isMore" :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
        <span>更多<i class="el-icon-arrow-right"></i></span>
      </a>
    </div>
     <div class="main-panel" >
      <div class="content-panel">
        <div class="content-panel-type" v-if="checkPermi([item.viewRoleKey])" :style="'color:'+ item.color+';background-image: url('+baseFilePath+item.cover+')'" v-for="item in downLoadTypeList" :key="item.sn" @click="handleTypeClick(item.sn)">
          {{item.name}}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {allMeterialCategory} from "@/api/console/download/meterialCategory";
import {checkPermi } from "@/utils/permission";
export default {
  name: "infoView",
  props: ['maxHeight','isMore','moreName','morelink','linkType','icon','componetTitle',  'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      loaded:  false,
      downLoadTypeList:[],
      baseFilePath:undefined,
    }
  },
  created() {
    //参数列表
    this.getConfigKey('file_download_url').then(response => {
      this.baseFilePath = response.msg;
    });
     //下载中心类型
    allMeterialCategory({status:1}).then(response=>{
      //确认权限类型
      this.downLoadTypeList = response;
    });
  },
  methods: {
    checkPermi,
    handleTypeClick(type){
      window.open("/home/download/"+type)
    }
  }
}
</script>

<style lang="scss" scoped>
  .wrapper{
    height: 300px;
    background-color: #fff;
    box-sizing: border-box;
  }
  .title-panel{
    height: 48px;
    width: 100%;
    padding: 0 20px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid #F2F2F2;
    .title{
      margin-left: 8px;
      color: #333333;
      font-weight: 600;
      font-size: 16px;
      flex: 1;
    }
    a{
      font-size: 14px;
      color:#505050;
    }
  }
  .main-panel{
    height: calc(100% - 48px);
    padding: 20px 20px;
    box-sizing: border-box;
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    align-content:flex-start;
    overflow: hidden;
    position: relative;
    .img-panel{
      width: 49%;
      min-width: 49%;
      height: 100%;
      overflow: hidden;
      .el-image{
        width: 100%;
        height: 100%;
        transition: all .5s;
        &:hover{
          transform: scale(1.5);
        }
      }
    }
    .content-panel{
      display: flex;
      justify-content: flex-start;
      align-items: center;
      width: 100%;
      font-weight: 400;
      color: #303133;
      font-size: 18px;
      min-height: 100px;
      flex-wrap: wrap;
      padding-right:5%;
      .content-panel-type{
        margin:  10px 0 10px 5%;
        width: 15%;
        height: 75px;
        background-size : 100% 100%;
        background-repeat:'no-repeat';
        text-align: center;
        padding-left:5%;
        line-height: 80px;
        font-family: '楷体';
        font-weight: 600;
        color:#47bfee;
        cursor:pointer ;
      }
    }
  }
  .moveL-enter-active{
    opacity: 1;
  }
  .moveL-enter-active,
    .moveL-leave-active {
        transition: all 2s linear;
        transform: translateX(0%);
    }
  .moveL-enter{
      transform: translateX(-100%);
      opacity: 0;
  }
  .moveL-leave-to {
      transform: translateX(100%);
      opacity: 0;
  }
</style>
