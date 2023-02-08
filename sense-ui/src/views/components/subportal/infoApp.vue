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
    <el-scrollbar class="content-scroll" >
    <div class="content-panel" v-loading="loading">
      <div class="item" ref="item" v-for="item in appList"  @click="sso(item)" :key="item.id">
        <div class="main" :title="item.appName">
          <el-image :src="item.profileUrl" style="width: 45px; height: 45px">
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
    </el-scrollbar>
  </div>
</template>

<script>
import $ from "jquery";
import {findAppByUserName} from "@/api/home/iam";
import {addInfoLog } from "@/api/console/info/log";
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
    this.init();
  },
  methods: {
    init() {
     var userName= this.$store.getters.name
      this.loading = true
      this.loaded = false
      findAppByUserName({
        userName: userName
      }).then(res => {
        if (res.code == 200) {
          this.loading = false
          this.loaded = true
          this.appList = res.data
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
    sso(item) {
      if (item != undefined && item.ssoLink != 'none') {
        if(item.isDeptSn==1){
          if(item.ssoLink.indexOf("?")!=-1){
            var deptSn=this.$store.getters.deptSn
            if(deptSn!=undefined && deptSn!=''){
              item.ssoLink=item.ssoLink+"&deptSn="+deptSn;
            }
          }else{
            item.ssoLink=item.ssoLink+"?deptSn="+deptSn;
          }
        }
        console.log(item);
        addInfoLog({
          title:item.appName,
          objId:item.id,
          type:'4'
        }).then(resp=>{
        })
        window.open(item.ssoLink);
      }
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
 
  .content-scroll{
    height:  calc(100% - 48px);
     
  }
  .content-scroll ::v-deep .el-scrollbar__wrap{
    overflow-x: hidden !important;
  }
  .content-panel{
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    align-content:flex-start;
    position: relative;
    padding: 30px 0px 0px 0px;
    .item{
      overflow: hidden;
      height: 50%;
      width: 20%;
      text-align: center;
      font-weight: 400;
      color: #2D314C;
      font-size: 13px;
      line-height: 1.5;
      display: flex;
      align-items: center;
      opacity: 0;
      padding-bottom:30px;
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
        width: 45px;
        height: 45px;
        margin-bottom: 10px;
        vertical-align: bottom;
      }
      .name{
        font-weight: 400;
        color: #2D314C;
        font-size: 14px;
        white-space: wrap;
        // text-overflow: ellipsis;
        overflow: hidden;
        // width: 56px;
        width: 80%;
        margin: 5px auto;
        height: 20px;
      }
    }
    .empty{
      position: absolute;
      margin: 0;
      top: 120px;
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
