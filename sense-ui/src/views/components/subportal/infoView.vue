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
     <div class="main-panel" v-loading="loading">
      <div class="img-panel">
        <transition name="moveL">
          <el-image v-if="honey"
            :src="honey"
            fit="fit"></el-image>
        </transition>
      </div>
      <div class="content-panel">
        <div class="item" v-for="item in dataList" :key="item.id"  @click="showDetail(item.id)" @mouseenter="changeHoney(item)">
          <div class="title">{{item.title}}</div>
          <div class="date">{{item.effectTime.slice(0, 10)}}</div>
        </div>
      </div>
      <div class="empty" v-show="loaded && !dataList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>暂无内容</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {listNews} from "@/api/home/news";

export default {
  name: "infoView",
  props: ['maxHeight','isMore','moreName','morelink','linkType','icon','componetTitle', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      loading: false,
      loaded:  false,
      dataList: [],
      honey: ''
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
      data.pageNum = this.pageNum || 1;
      data.pageSize = this.pageSize || 6;
      this.loading = true
      this.loaded = false
      listNews(data).then(response => {
        this.dataList = response.rows
        this.honey = this.baseFilePath + (this.dataList[0].photo || '')
        this.loading = false
        this.loaded =true
      }).catch(() => {
        this.loading = false
        this.loaded =true
      })
    },
    changeHoney (item) {
      if (this.honey === this.baseFilePath + (item.photo || '')) {
        return
      }
      this.honey = ''
      // this.honey = this.baseFilePath + item.photo
      const timer = setTimeout(() => {
        clearTimeout(timer)
        this.honey = this.baseFilePath + (item.photo || '')
      }, 100)

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
      padding: 10px 0 10px 20px;
      width: 51%;
      font-weight: 400;
      color: #303133;
      font-size: 14px;
      height: 100%;
      overflow: hidden;
      .item{
        width: 100%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
        .title{
          flex: 1;
        }
        &:first-child{
          .title{
            line-height: 1.5;
            font-weight: 600;
            color: #333333;
            font-size: 16px;
            max-height: 44px;
            overflow: hidden;
            text-overflow: -o-ellipsis-lastline;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
          }
          .date{
            align-self: flex-start;
            margin-top: 2px;
          }
        }
        &:not(:first-child){
          .title{
            height: 20px;
            line-height: 20px;
            font-weight: 500;
            color: #333333;
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
          }
        }
        .date{
          width: 85px;
          min-width: 85px;
          font-size: 14px;
          color:#999999;
          text-align: right;
          font-weight: 500;
        }
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
