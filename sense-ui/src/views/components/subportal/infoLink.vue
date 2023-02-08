<template>
  <div class="wrapper" :style="{'height': height}">
    <div class="title-panel">
      <el-image :src="icon" style="width: 20px; height: 20px">
        <div slot="error" class="image-slot">
          <i class="el-icon-picture-outline" style="font-size: 20px"></i>
        </div>
      </el-image>
      <div class="title">{{componetTitle || '常用流程'}}</div>
      <a v-show="isMore" :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
        <span>更多<i class="el-icon-arrow-right"></i></span>
      </a>
    </div>
    <div class="content-panel" v-loading="loading">
      <div class="item" ref="item" v-for="item in dataList.slice(0, 12)" @click="jump(item.url)" :key="item.appTypeId">
        <div class="main" :title="item.name">
          <el-image :src="baseFilePath + item.image">
            <img slot="error" class="image-slot" src="@/assets/icons/default_application.png">
          </el-image>
          <div class="name">{{ item.name }}</div>
        </div>
      </div>
      <div class="empty" v-show="loaded && !dataList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>无常用流程</div>
        </div>
      </div>
    </div>
  </div>
  <!-- <div class="process" :style="{'overflow': 'hidden','max-height':maxHeight,'height':maxHeight}">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title || '常用流程' }}</span>
      </div>
      <div class="publicTitleMore" v-if="isMore">
        <a :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
          <span>
         {{moreName}}<i class="el-icon-arrow-right"></i>
          </span>
        </a>
      </div>
    </div>
    <div class="processMian" v-if="dataList.length==0" style="height:197px">
      <div class="emptyData">
        <img src="@/assets/images/empty.png" alt="">
        <p>暂无相关内容</p>
      </div>
    </div>

    <div class="processMian" style="min-height: 247px" v-if="dataList.length!=0">
      <ul>
        <li v-for="(item,index) in dataList" @click="jump(item.url)" v-if="index < 8" :key='index'>
          <div :title=item.name>
            <img :src="'data:image/png;base64,'+item.image" alt="" width="32" height="32">
            <div class="icondiv">{{ item.name }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div> -->
</template>

<script>
  import {selectByUserList} from "@/api/home/commonLink";

  export default {
    name: "InfoLink",
    props: ['maxHeight','isMore','moreName','morelink','linkType','icon','componetTitle', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
    data() {
      return {
        loading: false,
        loaded: false,
        dataList: [],
        loaded: false
      }
    },
    created() {
      this.init();
      this.getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });


    },
    methods: {
      init() {
        let data = this.params;
        if (!data) {
          data = {};
        }
        data.pageNum = this.pageNum || 1;
        data.pageSize = this.pageSize || 20;
        this.loading = true
        selectByUserList(data).then(response => {
          this.dataList = (Array.isArray(response) && response) || [];
          this.$nextTick(() => {
            if (this.$refs.item) {
              this.$refs.item.forEach((m, i) => {
                console.warn('m', m)
                const tiemr = setTimeout(() => {
                  if (!m.className.includes('active')) m.className += ' active'
                  
                }, i * 100);
              })
            }
          })
          this.loading = false
          this.loaded = true
        }).catch(() => {
          this.dataList = []
          this.loading = false
          this.loaded = true
        })
      },
      showMore() {
        window.open('/home/commonLink')
      },
      jump(url) {
        window.open(url);
      }
    }
  }
</script>

<style lang="scss" scoped>
  .wrapper{
    height: 270px;
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
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    align-content:flex-start;
    overflow: hidden;
    position: relative;
    .item{
      opacity: 0;
      height: 33.3%;
      width: 25%;
      text-align: center;
      font-weight: 400;
      color: #2D314C;
      font-size: 13px;
      line-height: 1.5;
      // margin: 12px 0 16px;
      display: flex;
      align-items: center;
      transform: translateY(-100%);
      // transform: scale(0);
      transition: transform .5s;
      &.active{
        opacity: 1;
        transform: translateY(0);
      }
      // &.active{
      //   opacity: 1;
      //   transform: scale(1);
      // }
      &:hover{
        position: relative;
        top: -4px;
        cursor: pointer;
      }
      .main{
        width: 100%;
      }
      img{
        width: 32px;
        height: 32px;
        margin-bottom: 10px;
        vertical-align: bottom;
      }
      .name{
        font-weight: 400;
        color: #2D314C;
        font-size: 13px;
        white-space: wrap;
        // text-overflow: ellipsis;
        overflow: hidden;
        // width: 56px;
        width: 80%;
        margin: 0 auto;
        height: 20px;
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
    .el-image{
      width: 32px;
      height: 32px;
      border-radius: 50%;
      ::v-deep .image-slot{
        width: 100%;
        height: 100%;
        text-align: center;
        line-height: 32px;
        i{
          font-size: 24px;
          vertical-align: middle;
        }
      }
    }
  }
</style>
