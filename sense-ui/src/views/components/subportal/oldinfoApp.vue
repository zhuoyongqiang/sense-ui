<template>
  <div class="wrapper" :style="{'height': height}">
    <div class="title-panel">
      <el-image :src="icon" style="width: 20px; height: 20px">
        <div slot="error" class="image-slot">
          <i class="el-icon-picture-outline" style="font-size: 20px"></i>
        </div>
      </el-image>
      <div class="title">{{componetTitle || '常用应用'}}</div>
      <a v-show="isMore" :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
        <span>更多<i class="el-icon-arrow-right"></i></span>
      </a>
    </div>
    <div class="content-panel" v-loading="loading">
      <div class="item" ref="item" v-for="item in appList.slice(0, 8)" @click="sso(item.ssoLink)" :key="item.id">
        <div class="main" :title="item.appName">
          <el-image :src="baseFilePath + item.profileUrl" style="width: 32px; height: 32px">
            <img slot="error" src="@/assets/images/home/app_temp.png">
          </el-image>
          <div class="name">{{ item.appName }}</div>
        </div>
      </div>
      <div class="empty" v-show="loaded && !appList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>无常用应用</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import $ from "jquery";
import {findApp} from "@/api/home/iam";

export default {
  name: "InfoApp",
  props: ['maxHeight','isMore','moreName','morelink','linkType','icon','componetTitle', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
  data() {
    return {
      loading: false,
      loaded: false,
      appList: []
    }
  },
  created() {
    this.getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
      this.init();
    });
  },
  methods: {
    init() {
      this.loading = true
      this.loaded = false
      findApp({
        common: 1
      }).then(res => {
        if (res.code == 200) {
          this.loading = false
          this.loaded = true
          this.appList = res.data
          // for(let i = 0 ; i < 10; i++){
          //   this.appList.push(res.data[0]);
          // }
          
          this.$nextTick(() => {
            if (this.$refs.item) {
              this.$refs.item.forEach((m, i) => {
                const tiemr = setTimeout(() => {
                  if (!m.className.includes('active')) m.className += ' active'
                  
                }, i * 100);
              })
            }
          })
        } else {
          this.loading = false
          this.loaded = true
        }
      }).catch(err => {
        this.loading = false
        this.loaded = true
      })
    },
    sso(url) {
      window.open(url);
    }
  }
}
</script>


<style lang="scss" scoped>
  .wrapper{
    height: 216px;
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
      height: 50%;
      width: 25%;
      text-align: center;
      font-weight: 400;
      color: #2D314C;
      font-size: 13px;
      line-height: 1.5;
      display: flex;
      align-items: center;
      opacity: 0;
      transform: translateY(-100%);
      // margin: 12px 0 16px;
      transition: transform .5s;
       &.active{
        opacity: 1;
        transform: translateY(0);
      }
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
  }
</style>
