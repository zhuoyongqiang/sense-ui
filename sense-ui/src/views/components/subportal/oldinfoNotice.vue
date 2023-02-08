<!-- -->
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
     <div class="content-panel" v-loading="loading">
      <div class="item" v-for="item in dataList" :key="item.id" @click="showDetail(item.id)">
        <div class="title">{{item.title}}</div>
        <div class="date">{{item.effectTime.slice(0, 10)}}</div>
      </div>
      <div class="empty" v-show="loaded && !dataList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>暂无内容</div>
        </div>
      </div>
    </div>
  </div>
  <!-- <div class="flag wrapper" :style="{'overflow': 'hidden'}">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ componetTitle }}</span>
      </div>
      <div class="publicTitleMore" v-if="isMore">
        <a :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
          <span>
         {{moreName}}<i class="el-icon-arrow-right"></i>
          </span>
        </a>
      </div>
    </div>
    <div class="flagContent publicContent publicFlex" v-if="dataList.length==0">
      <div  class="emptyData">
        <img src="@/assets/images/empty.png" alt="">
        <p>暂无相关内容</p>
      </div>
    </div>
    <div class="flagContent publicContent publicFlex" v-if="dataList.length!=0">
      <div class="windowList">
        <ul>
          <li
            class="publicFlex"
            :title="item.title"
            v-for="(item) in dataList" :key="item.id"
            @click="showDetail(item.id)"
          >
            <span class="windowTitle"> <i v-if="item.isNew" class="news-icon"></i>{{ item.title }}</span>
            <span class="windowTime">{{ item.effectTime!=undefined && item.effectTime.length>10?item.effectTime.substring(5,10):item.effectTime }}</span>
           </li>
        </ul>
      </div>
    </div>
  </div> -->
</template>

<script>
import {listNews} from "@/api/home/news";
export default {
  name: "infoNotice",
  props: ['isMore','moreName','morelink','linkType','icon','componetTitle', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height','maxHeight'],
  data() {
    return {
      loading: false,
      loaded: false,
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
      data.pageNum = this.pageNum || 1;
      data.pageSize = this.pageSize || 6;
      this.loading = true
      this.loaded = false
      listNews(data).then(response => {
        this.dataList = response.rows;
        this.loading = false
        this.loaded = true
      }).catch(() => {
        this.loading = false
        this.loaded = true
      })
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
  .content-panel{
    height: calc(100% - 48px);
    padding: 14px 20px;
    font-weight: 400;
    color: #303133;
    font-size: 14px;
    position: relative;
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

.news-icon {
  background-image: url("~@/../src/assets/images/mobile/window/new.png");
  display: inline-block;
  background-size: 100% 100%;
  width: 28px;
  height: 14px;
  vertical-align: middle;
  margin-right: 3px;
  margin-bottom: 2px;
}

</style>
