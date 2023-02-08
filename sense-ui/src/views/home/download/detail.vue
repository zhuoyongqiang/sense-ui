<template>
  <div class="detail-container" id="container" v-if="isPr">
    <div class="detail-left">
      <div class="left-header ">
        <div class="header-navbar">
          <el-breadcrumb separator-class="el-icon-arrow-right">
            <el-breadcrumb-item><a href="/index">首页</a></el-breadcrumb-item>
            <el-breadcrumb-item><a href="/home/download/meterial">下载中心</a></el-breadcrumb-item>
            <el-breadcrumb-item>正文</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </div>
      <div class="left-center">
        <div class="article-main">
          <div class="article-title">
            {{ form.name }}
          </div>
          <div class="article-info clearfix">
            <span><i class="el-icon-time"></i>上传于 {{ form.createTime }}</span>
            <span>作者：{{ form.uploadUserName }}</span>
            <span><i class="el-icon-view"></i>{{ form.browseNum }}次浏览</span>
            <div class="fr fontSet">
              <img src="../../../assets/images/window/font.png" style="vertical-align: middle" width="16px" height="16px">
              <span>【</span>
              <span @click="scale(item.label)" v-for="item in fontType" class="font" :class="{'active' : fontActive === item.label}" :key="item.label">{{item.text}}</span>
              <span>】</span>
            </div>
          </div>
          <iframe id="frame" ref="frame" name="frame" style="width:100%;min-height:50px" frameborder="no"></iframe>
          <div class="article-attach" >
            <el-table :data="form.fileList" style="width: 100%">
              <el-table-column
                prop="name"
                label="附件名称">
              </el-table-column>
              <el-table-column
                prop="type"
                label="附件格式">
              </el-table-column>
              <el-table-column
                v-if="form.isPriview=='1' ||  form.isDownload=='1'"
                label="操作"
                width="200">
                <template slot-scope="scope">
                  <a :href="scope.row.url" @click.prevent="onPreview(scope.row)"  v-if="form.isPriview && form.isPriview=='1' && (scope.row.type=='png' || scope.row.type=='jpg' || scope.row.type=='pdf' || scope.row.type=='PDF'|| scope.row.type=='xlsx'|| scope.row.type=='pptx'|| scope.row.type=='mp4')"   target="_blank"   style="color:blue">预览</a>
                  <!-- <a :href="scope.row.url" v-if="form.isDownload && form.isDownload=='1'" :download="scope.row.name" @click="handleDownload" style="color:blue">下载</a> -->
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </div>
    <el-backtop>
    </el-backtop>
    <div class="clear"></div>
    <!-- 图片预览 -->
    <el-image-viewer
      v-if="showViewer"
      :initialIndex="initialIndex"
      :on-close="()=>{showViewer=false}"
      :url-list="imgList" />
   <el-drawer
      :title="winTitle"
      :visible.sync="showEdit"
      size="99%"
      :with-header="true"
    >
    <previewDrawer
        :form="formData"
        :popTitle="winTitle"
        @hide="showEdit = false"
      ></previewDrawer>
      </el-drawer>
  </div>
  <div v-else-if="pageError">
    <div class="wscn-http404-container">
      <div class="wscn-http404">
        <div class="pic-404">
          <img class="pic-404__parent" src="@/assets/404_images/404.png" alt="404">
          <img class="pic-404__child left" src="@/assets/404_images/404_cloud.png" alt="404">
          <img class="pic-404__child mid" src="@/assets/404_images/404_cloud.png" alt="404">
          <img class="pic-404__child right" src="@/assets/404_images/404_cloud.png" alt="404">
        </div>
        <div class="bullshit">
          <div class="bullshit__oops">
            Oops!
          </div>
          <div class="bullshit__headline">
            <!-- {{ message }} -->
            没有找到您想要的页面或者资源已经下线了
          </div>
          <!-- <div class="bullshit__info">
            对不起，您正在寻找的页面不存在。尝试检查URL的错误，然后按浏览器上的刷新按钮或尝试在我们的应用程序中找到其他内容。
          </div> -->
          <router-link to="/" class="bullshit__return-home">
            返回首页
          </router-link>
        </div>
      </div>
    </div>
  </div>

</template>
<script>
  import {getConfigKey} from "@/api/home/config";

  import {getToken} from "@/utils/auth";
  import InfoLogin from "@/views/components/subportal/InfoLogin";
  import ElImageViewer from "@/components/imageViewer/image-viewer";
  import previewDrawer from "./previewDrawer.vue";
  import $ from 'jquery';
  import {getMeterial,editDownloadNum} from "@/api/console/download/meterial";
  import {checkPermi } from "@/utils/permission";
  export default {
    name: "meterialDetail",
    components: {InfoLogin, ElImageViewer,previewDrawer},
    data() {
      return {
        initialIndex: 0,
      	imgList: [],
      	showViewer: false,
        isPr:false,
        pageError: false,
        loginVisible:false,
        loading: false,
        meterialId: undefined,
        leftHeight: undefined,
        baseFilePath: undefined,
        newsType: {},
        token:'',
        form: {},
        secondLink: '',
        newsTypeName: '',
        infoCommentList:[],


        formData: null,
        showEdit: false,
        winTitle: "",

        comment: {
          content: ""
        },
        fontActive: '1',
        fontType: [
          {
            label: '1',
            text: '标准'
          },
          {
            label: '1.5',
            text: '中'
          },
          {
            label: '2',
            text: '大'
          }
        ],
        timer: null
      }
    },
    beforeCreate: function () {
      document.getElementsByTagName("body")[0].className = "body_bg";
    },
    beforeDestroy: function () {
      document.body.removeAttribute("class", "body_bg");
      clearInterval(this.timer)
    },
    computed: {
      isUserLogin() {
        if (getToken()) {
          return true;
        }
        return false;
      }
    },
    mounted() {
      let self = this;
      // 直接导入使用，也可以在main.js中引入
      var elementResizeDetectorMaker = require("element-resize-detector")
      // 创建实例，无参数
      var resizeMaker = elementResizeDetectorMaker();
      /* //监听id为test的元素 大小变化
      resizeMaker.listenTo(document.getElementById("detail-right-main"), function (element) {
        self.leftHeight = element.offsetHeight;
      }); */
      // this.timer = setInterval(()=>{
      // 	this.resizeIframe()
      // }, 100)
    },
    created() {
      this.meterialId = this.$route.params && this.$route.params.meterialId;
      this.fontActive = +localStorage.getItem('fontActive') ? localStorage.getItem('fontActive') : '1'
      getConfigKey('file_download_url').then(response => {
        this.baseFilePath = response.msg;
      });
      this.getInfo(this.meterialId);

      this.token=getToken();
    },
    methods: {
      //预览
      onPreview(item){
        console.log('onPreview-item:',item)
        this.winTitle = "附件：" + item.name;
        this.formData = item;
        this.showEdit = true;
      },
      //点击下载
      handleDownload(){
        editDownloadNum({id:this.meterialId}).then(resp=>{});
      },
      //权限
      checkPermi,
      getInfo(id) {
        getMeterial(id).then(response => {
          if (response.code == 200) {
            this.isPr=true;
            this.form = response.data;
            console.log(this.form);

            // document.title = this.form.title;
            const self = this
            //利用iframe加载原生内容，防止CSS加载破环结构
            const timer = setTimeout(() =>{
              clearTimeout(timer)
              const iframe = window.frames['frame'];
              iframe.document.open();
              iframe.document.write('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
              iframe.document.write('<html xmlns="http://www.w3.org/1999/xhtml">');
              iframe.document.write('<head>');
              iframe.document.write('<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />');
              iframe.document.write('<style>');
              iframe.document.write('*{margin:0;padding:0; max-width: 100%;height:auto} body{overflow: hidden}');
              iframe.document.write('</style>');
              iframe.document.write('</head>');
              iframe.document.write('<body>');
              iframe.document.write(response.data.content==undefined ? '' : response.data.content);
              iframe.document.write('</body>');
              iframe.document.write('</html>');
              iframe.document.close();
              // this.resizeIframe()
              $(iframe.document).ready(function(){
                self.resizeIframe()
                self.bindImgelement()
                self.scale(self.fontActive)
              })
              //记录访问日志
            },200);
          }else{
            this.isPr=false;
            this.pageError = true
            // this.msgError(response.msg)
            // this.msgError('没有找到您想要的页面或者资源已经下线了')
          }
        })
      },
      resizeIframe () {
        // console.log(this.$refs.frame.contentWindow.document.body.scrollHeight, this.$refs.frame.contentWindow.document.documentElement.scrollHeight)
        const max = Math.max(this.$refs.frame.contentWindow.document.body.scrollHeight, this.$refs.frame.contentWindow.document.documentElement.scrollHeight)
        if(+this.$refs.frame.height !== max){
          this.$refs.frame.height = max + 20
        }
        this.timer = setTimeout(()=>{
          clearTimeout(this.timer)
          this.resizeIframe()
        }, 100)
      },
      ConvertToArray (nodes) {
      let array = []
        try{
          array=Array.prototype.slice.call(nodes, 0);//非ie浏览器  ie8-将NodeList实现为COM对象，不能用这种方式检测
        } catch(ex){//ie8-
          console.warn('ex', ex)
          array=new Array();
          for(var i=0;i< nodes.length; i++){
            array.push(nodes[0]);
          }
        }
      return array;
    },
    bindImgelement () {
      this.$nextTick(async () => {
        const aDivs = this.ConvertToArray(this.$refs.frame.contentWindow.document.querySelectorAll('img'))
        if (aDivs.length) {
          for (let i = 0; i< aDivs.length; i++) {
            try {
              await this.checkImgExists(aDivs[i].src)
              this.imgList.push(aDivs[i].src)
                aDivs[i].onclick = (e) => {
                  this.initialIndex = i
                  this.showViewer = true
                }
            } catch (err) {
              aDivs[i].alt = '图片加载失败'
            }
          }
        }
      })
    },
    // 读取图片
    checkImgExists(imgurl) {
      return new Promise((resolve, reject) => {
        const ImgObj = new Image()
        ImgObj.src = imgurl
        ImgObj.onload = (res) => {
          resolve(imgurl)
        }
        ImgObj.onerror = function(err) {
          console.warn('图片载入出现异常', err)
          reject(err)
        }
      })
    },
      scale (size) {
        this.fontActive = size
        localStorage.setItem('fontActive', size)
        this.$refs.frame.contentWindow.document.body.style.transformOrigin = '0 0'
        this.$refs.frame.contentWindow.document.body.style.transform = `scale(${size})`
        this.$refs.frame.contentWindow.document.body.style.width = Math.round(100 / size) + '%'
        // this.$refs.frame.contentWindow.document.body.style.overflow = 'hidden'
        this.$refs.frame.height = 0
        this.resizeIframe()
        // this.$refs.frame.height = 0
        // this.$refs.frame.height = Math.max(this.$refs.frame.contentWindow.document.body.scrollHeight, this.$refs.frame.contentWindow.document.documentElement.scrollHeight) + 20;

      }
    }
  }
</script>

<style scoped src="../../../assets/styles/home/detail.css"></style>
<style lang="scss" scoped>
  @import '../../../assets/styles/home/home.scss';
  @import '../../../assets/styles/home/common.scss';
  * {
    margin: 0;
    padding: 0;
  }

  .detail-container {
    max-width: 1280px;
    margin: 10px auto;
  }

  .detail-left {
    width: 100%;
    float: left;
    background: #ffffff;
    border-radius: 5px;
  }

  .left-header {
    border-bottom: solid 1px #F2F2F2;
  }

  .header-navbar {
    padding: 20px 0px 20px 24px;
  }

  .article-main {
    padding: 18px 24px 12px 24px;
  }

  .article-title {
    padding: 12px 0px;
    font-size: 24px;
    font-weight: 600;
  }

  .article-info {
    padding: 12px 0px;
  }

  .article-info span i {
    margin-right: 4px;
  }

  .article-info span {
    font-size: 12px;
    color: #444;
    margin-right: 12px;
  }

  .article-content {
    padding: 12px 0 12px 0;
    line-height: 32px;
  }

  .article-attach {
    color: #333333;
  }

  .article-attach a {
    text-decoration: underline;
    margin-right: 12px;
  }

  .detail-right {
    width: 280px;
    float: right;
  }

  .clear {
    clear: both;
  }
  .fontSet{
    color:#797979;
    font-size: 12px;
    .font{
      cursor: pointer;
    }
    .active{
      color: #2272DE;
    }
  }
  ::v-deep .el-breadcrumb{
    font-size: 14px;
    height: 20px;
    line-height: 20px;
    .el-breadcrumb__item{
      .el-breadcrumb__inner.is-link, .el-breadcrumb__inner a{
        color: #606266!important;
      }
      &:first-child{
        .el-breadcrumb__inner, .el-breadcrumb__inner a{
          font-weight: 600!important;
          color: #303133!important;
        }
      }
      .el-breadcrumb__inner{
      }
    }
    .icon{
      font-size: 0;
      width: 16px;
      height: 16px;
      margin-right: 6px;
      vertical-align: -3px;
    }
  }
  .wscn-http404-container{
  transform: translate(-50%,-50%);
  position: fixed;
  top: 50%;
  left: 50%;
  margin-top: 56px;
}
.wscn-http404 {
  margin: 0 auto;;
  position: relative;
  width: 1200px;
  padding: 0 50px;
  overflow: hidden;
  .pic-404 {
    position: relative;
    float: left;
    width: 600px;
    overflow: hidden;
    &__parent {
      width: 100%;
    }
    &__child {
      position: absolute;
      &.left {
        width: 80px;
        top: 17px;
        left: 220px;
        opacity: 0;
        animation-name: cloudLeft;
        animation-duration: 2s;
        animation-timing-function: linear;
        animation-fill-mode: forwards;
        animation-delay: 1s;
      }
      &.mid {
        width: 46px;
        top: 10px;
        left: 420px;
        opacity: 0;
        animation-name: cloudMid;
        animation-duration: 2s;
        animation-timing-function: linear;
        animation-fill-mode: forwards;
        animation-delay: 1.2s;
      }
      &.right {
        width: 62px;
        top: 100px;
        left: 500px;
        opacity: 0;
        animation-name: cloudRight;
        animation-duration: 2s;
        animation-timing-function: linear;
        animation-fill-mode: forwards;
        animation-delay: 1s;
      }
      @keyframes cloudLeft {
        0% {
          top: 17px;
          left: 220px;
          opacity: 0;
        }
        20% {
          top: 33px;
          left: 188px;
          opacity: 1;
        }
        80% {
          top: 81px;
          left: 92px;
          opacity: 1;
        }
        100% {
          top: 97px;
          left: 60px;
          opacity: 0;
        }
      }
      @keyframes cloudMid {
        0% {
          top: 10px;
          left: 420px;
          opacity: 0;
        }
        20% {
          top: 40px;
          left: 360px;
          opacity: 1;
        }
        70% {
          top: 130px;
          left: 180px;
          opacity: 1;
        }
        100% {
          top: 160px;
          left: 120px;
          opacity: 0;
        }
      }
      @keyframes cloudRight {
        0% {
          top: 100px;
          left: 500px;
          opacity: 0;
        }
        20% {
          top: 120px;
          left: 460px;
          opacity: 1;
        }
        80% {
          top: 180px;
          left: 340px;
          opacity: 1;
        }
        100% {
          top: 200px;
          left: 300px;
          opacity: 0;
        }
      }
    }
  }
  .bullshit {
    position: relative;
    float: left;
    width: 300px;
    padding: 30px 0;
    overflow: hidden;
    &__oops {
      font-size: 32px;
      font-weight: bold;
      line-height: 40px;
      color: #1482f0;
      opacity: 0;
      margin-bottom: 20px;
      animation-name: slideUp;
      animation-duration: 0.5s;
      animation-fill-mode: forwards;
    }
    &__headline {
      font-size: 20px;
      line-height: 24px;
      color: #222;
      font-weight: bold;
      opacity: 0;
      margin-bottom: 10px;
      animation-name: slideUp;
      animation-duration: 0.5s;
      animation-delay: 0.1s;
      animation-fill-mode: forwards;
    }
    &__info {
      font-size: 13px;
      line-height: 21px;
      color: grey;
      opacity: 0;
      // margin-bottom: 30px;
      animation-name: slideUp;
      animation-duration: 0.5s;
      animation-delay: 0.2s;
      animation-fill-mode: forwards;
    }
    &__return-home {
      margin-top: 30px;
      display: block;
      float: left;
      width: 110px;
      height: 36px;
      background: #1482f0;
      border-radius: 100px;
      text-align: center;
      color: #ffffff;
      opacity: 0;
      font-size: 14px;
      line-height: 36px;
      cursor: pointer;
      animation-name: slideUp;
      animation-duration: 0.5s;
      animation-delay: 0.3s;
      animation-fill-mode: forwards;
    }
    @keyframes slideUp {
      0% {
        transform: translateY(60px);
        opacity: 0;
      }
      100% {
        transform: translateY(0);
        opacity: 1;
      }
    }
  }
}

::v-deep .el-drawer__body {
  flex: 1;
  padding: 5px;
  overflow: auto;
}
.el-table ::v-deep .cell {
  white-space: pre-line;
}

::v-deep .el-drawer__header {
  align-items: center;
  color: #72767b;
  display: flex;
  margin:0px;
  margin-left: 10px;
  padding: var(--el-drawer-padding-primary);
  padding-bottom: 0;
  padding-top: 5px;
}
.el-button + .el-button {
  margin-left: 0px;
}

</style>
