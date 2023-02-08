<template>
  <div class="adver_banner">
    <el-dialog
    :close-on-press-escape="false"
    :close-on-click-modal="false"
    :center="true"
    :visible.sync="dialogVisible"
    width="50%">
    <div>
      <el-carousel height="300px"   :interval="3000" :indicator-position="dataList.length>1 ? 'outside' :'none'" >
        <el-carousel-item v-for="item in dataList" :key="item.id"  >
          <el-image :src="item.cover" @click="handleClick(item)">
            <div slot="error" class="image-slot">
              <i class="el-icon-picture"></i>
            </div>
          </el-image>
        </el-carousel-item>
        <div class="carousel_bottom">
           <el-checkbox v-model="isRead" @change="handleRead" style="font-weight:bold">我已查看</el-checkbox>
        </div>
      </el-carousel>
      <div class="empty" v-show="!dataList.length">
        <div class="empty-main">
          <img src="@/assets/images/empty.png">
          <div>暂无内容</div>
        </div>
      </div>
    </div>
    </el-dialog>
  </div>
</template>
<script>
import {allAdvertising} from "@/api/console/info/advertising";
import {addInfoLog } from "@/api/console/info/log";
export default {
  props:["dialog"],
  name:'advertisement',
  data() {
    return {
      dialogVisible: false,
      //数据集合
      dataList:[],
      //我已阅读
      isRead:false
    };
  },
  created(){
    this.dialogVisible=this.dialog;
    allAdvertising({
      isRotation:1,
      status:1,
      isTime:true
    }).then(resp=>{
      this.dataList=resp;
    })
  },
  methods: {
    handleRead(value){
      //设置用户
      window.localStorage.setItem('advertingRead',this.isRead);
    },
    handleClick(item){
      addInfoLog({
        title:item.title,
        objId:item.id,
        type:'1'
      }).then(resp=>{
        
      })
      window.open(item.advertUrl);
    },
  }
};
</script>
<style lang="scss">
  .adver_banner{
      .el-carousel__item{
        border-radius: 10px;
      }
      .el-carousel__item:nth-child(2n) {
        background-color: #99a9bf;
      }
      .el-carousel__item:nth-child(2n+1) {
        background-color: #d3dce6;
      }
      .el-carousel__item .el-image {
        border-radius: 10px;
        width: 100%;
        height: 100%;
        font-size: 50px;
        cursor: pointer;
        .image-slot{
          height: 100%;
          width: 100%;
          text-align: center;
          padding-top:13% ;
        }
      }
      .el-dialog__header {
        border-radius: 10px;
        padding: 0; 
        padding-bottom: 0; 
      }
      .el-dialog__body {
        border-radius: 10px;
          padding: 0 0;
          color: #606266;
          font-size: 14px;
          word-break: break-all;
      }
      .el-dialog__headerbtn{
        font-size: 20px;
        z-index: 100;
         .el-dialog__close {
          color: #792f2f;
        }
      }
      .el-carousel__indicators{
        position: absolute;
        transform: translate(-50%, 10px);
      }
      .el-carousel__indicators--outside button{
        background-color: #2b64b5;
        height: 4px;
        
      }
      .el-dialog{
        border-radius: 10px;
        position: relative;
        top:20%;
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
    .carousel_bottom{
      position: absolute;
      bottom: 5px;
      right: 2%;
      z-index: 1000;
    }
  }

</style>