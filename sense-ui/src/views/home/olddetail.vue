<template>
  <div class="detail-container" id="container" v-if="isPr">
    <div class="detail-left">
      <div class="left-header ">
        <div class="header-navbar">
          <!-- <el-breadcrumb separator-class="el-icon-arrow-right">
            <el-breadcrumb-item><a href="/index">首页</a></el-breadcrumb-item>
            <el-breadcrumb-item><a href="/home/window/all">新闻中心</a></el-breadcrumb-item>
            <el-breadcrumb-item ><a :href="secondLink">{{ newsTypeName }}</a></el-breadcrumb-item>
            <el-breadcrumb-item>正文</el-breadcrumb-item>
          </el-breadcrumb> -->
          <el-breadcrumb separator-class="el-icon-arrow-right">
            <el-breadcrumb-item><img class="icon" src="../../assets/images/home/navbarIcon/news.png"><a href="/home/window/all">新闻中心</a></el-breadcrumb-item>
            <el-breadcrumb-item ><a :href="secondLink">{{ newsTypeName }}</a></el-breadcrumb-item>
            <el-breadcrumb-item>正文</el-breadcrumb-item>
          </el-breadcrumb> 
        </div>
      </div>
      <div class="left-center">
        <div class="article-main">
          <div class="article-title">
            {{ form.title }}
          </div>
          <div class="article-info clearfix">
            <span><i class="el-icon-time"></i>发表于 {{ form.effectTime }}</span>
            <span>作者：{{ form.issuer }}</span>
            <span><i class="el-icon-view"></i>{{ form.readNum }}次浏览</span>
            <!-- <span v-show="form.currentPhase || form.totalPhase">（{{form.currentPhase}}期 / {{form.totalPhase}}期）</span> -->
            <div class="fr fontSet">
              <img src="../../assets/images/window/font.png" style="vertical-align: middle" width="16px" height="16px">
              <span>【</span>
              <span @click="scale(item.label)" v-for="item in fontType" class="font" :class="{'active' : fontActive === item.label}" :key="item.label">{{item.text}}</span>
              <span>】</span>
            </div>
          </div>
          <iframe id="frame" ref="frame" name="frame" style="width:100%;" frameborder="no"></iframe>
          <div class="article-attach" v-if="form.attachmentList!=undefined && form.attachmentList.length>0">
            <el-table :data="form.attachmentList" style="width: 100%">
              <el-table-column
                prop="attachmentTitle"
                label="附件名称"
              >
              </el-table-column>
              <el-table-column
                prop="fileType"
                label="附件格式"
                width="200">
              </el-table-column>
              <el-table-column
                label="操作"
                width="200">
                <template slot-scope="scope">
                  <el-link :underline="false" type="primary" style="text-decoration:none" :href="'/api/common/download/'+scope.row.id" target="_blank">预览</el-link>
                  <el-link v-if="scope.row.sftpDownloadUrl" :underline="false" type="primary" style="text-decoration:none" :href="'/api/common/fileDownload/'+scope.row.id" target="_blank">下载</el-link>
                </template>
              </el-table-column>
            </el-table>
          </div>
          <div>
            <div class="article-comment" v-if="form.isComment===1 && isUserLogin">
              <el-input v-model="comment.content" rows="5" type="textarea" placeholder="想要说点什么" maxlength="200" show-word-limit/>
              <el-button @click="sendComment" type="primary" icon="el-icon-edit" style="padding: 10px 20px;margin: 10px 0;">发表评论</el-button>
            </div>
            <div class="article-comment" v-if="form.isComment===1 && isUserLogin===false">
              <el-button @click="login" type="primary" icon="el-icon-lock" style="padding: 10px 20px;margin: 10px 0;">登陆后才能进行评价，点击登录</el-button>
            </div>

            <div class="article-list" v-if="form.isComment===1" style="margin-bottom: 20px;">
              <el-table v-loading="loading" :data="infoCommentList" empty-text='还没有任何评论'>
                <el-table-column label="评论">
                  <template slot-scope="scope">
                    <div class="comment_left">
                      <div class="avatar">
                        <img :src="scope.row.avatar" alt="" height="32" width="32" style="vertical-align: middle; border-radius: 40%;">
                      </div>
                      <div class="userinfo">
                        <p><i class="el-icon-postcard"></i>{{scope.row.deptName}}</p>
                        <p><i class="el-icon-user"></i>{{scope.row.userName}}</p>
                      </div>
                    </div>
                    <div class="comment_right">
                      <div class="content" style="margin-bottom: 20px;">
                        {{scope.row.content}}
                      </div>
                      <div class="fabuTime">
                        <i class="el-icon-date"></i>评论日期：{{scope.row.createTime}}
                      </div>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
              <pagination
                v-show="total>0"
                :total="total"
                :page.sync="queryCommentParams.pageNum"
                :limit.sync="queryCommentParams.pageSize"
                @pagination="getlistInfoCommentList"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="detail-right">
      <div class="detail-right-main" id="detail-right-main">
        <div>
          <list-read title="推荐阅读" page-num="1" page-size="3"
                     :base-file-path="baseFilePath"></list-read>
        </div>
        <div>
          <list-news title="最新资讯" :params="{newsTypeId:'1002'}" page-num="1" page-size="5"
                     :base-file-path="baseFilePath"></list-news>
        </div>
        <div>
          <list-hot title="热门排行" page-num="1" page-size="5"
                    :base-file-path="baseFilePath"></list-hot>
        </div>
      </div>
    </div>
    <el-backtop>
    </el-backtop>
    <div class="clear"></div>
    <el-dialog title="登录" :visible.sync="loginVisible" width="400px" v-if="isUserLogin===false" :close-on-click-modal="false" append-to-body>
      <info-login :params="{isDialog:true}" @loginSuccess="loginSuccess"></info-login>
    </el-dialog>
    <!-- 图片预览 -->
    <el-image-viewer
      v-if="showViewer"
      :initialIndex="initialIndex"
      :on-close="()=>{showViewer=false}"
      :url-list="imgList" />
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
  import {allNewsType} from "@/api/home/newsType";
  import {getNews} from "@/api/home/news";
  import ListHot from "@/views/components/home/ListHot";
  import ListNews from "@/views/components/home/ListNews";
  import ListRead from "@/views/components/home/ListRead";
  import {listInfoComment,addInfoComment} from "@/api/console/info/comment";
  import {getToken} from "@/utils/auth";
  import InfoLogin from "@/views/components/subportal/InfoLogin";
  import ElImageViewer from "@/components/imageViewer/image-viewer";
  import $ from 'jquery';

  export default {
    name: "detailTemplate",
    components: {ListHot, ListNews, ListRead,InfoLogin, ElImageViewer},
    data() {
      return {
        initialIndex: 0,
      	imgList: [],
      	showViewer: false,
        isPr:false,
        pageError: false,
        loginVisible:false,
        loading: false,
        currentNewsId: undefined,
        newsTypeList: [],
        leftHeight: undefined,
        baseFilePath: undefined,
        newsType: {},
        form: {},
        secondLink: '',
        newsTypeName: '',
        infoCommentList:[],
        comment: {
          content: ""
        },
        queryCommentParams: {
          pageNum: 1,
          pageSize: 10,
          status:1,
          objId: null
        },
        // 总条数
        total: 0,
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
      this.currentNewsId = this.$route.params && this.$route.params.newsId;
      this.fontActive = +localStorage.getItem('fontActive') ? localStorage.getItem('fontActive') : '1'
      allNewsType({}).then(response => {
        if (response.code == 200) {
          this.newsTypeList = response.data;
        }
      })
      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
      this.getInfo(this.currentNewsId);
    },
    methods: {
      login(){
        this.loginVisible = true;
      },
      loginSuccess(){
        this.loginVisible = false
        window.location.reload()
      },
      sendComment(){
        if(this.comment.content=='' && this.comment.content.length==0 ){
          this.msgWarning("请输入评论内容");
          return;
        }
        this.queryCommentParams.content=this.comment.content
        addInfoComment(this.queryCommentParams).then(response => {
          if(response.code==200){
            this.queryCommentParams.content = ''
            this.comment.content = ''
            this.msgWarning("评论成功提交，待审核。");
          }else{
            this.msgError(response.msg);
          }
        });
      },
      _isMobile() {
        let flag = navigator.userAgent.match(/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i)
        return flag;
      },
      getInfo(id) {
        getNews(id).then(response => {
          if (response.code == 200) {

            this.isPr=true;
            this.form = response.data;
            this.newsTypeName = this.form.newsTypeName;
            this.secondLink = '/home/window/' + this.form.newsTypeId;
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
              iframe.document.write('*{margin:0;padding:0; max-width: 100%; height:auto} body{overflow: hidden}');
              iframe.document.write('</style>');
              iframe.document.write('</head>');
              iframe.document.write('<body>');
              iframe.document.write(response.data.content);
              iframe.document.write('</body>');
              iframe.document.write('</html>');
              iframe.document.close();
              // this.resizeIframe()
              $(iframe.document).ready(function(){
                self.resizeIframe()
                self.bindImgelement()
                self.scale(self.fontActive)
              })
            },200);
            this.getlistInfoCommentList();
          }else{
            this.isPr=false;
            this.pageError = true
            // this.msgError(response.msg)
            // this.msgError('没有找到您想要的页面或者资源已经下线了')
          }
        })
      },
      /** 查询评论管理列表 */
      getlistInfoCommentList() {
        this.queryCommentParams.objId=this.form.id;
        this.queryCommentParams.orderSql=" create_time_ asc"

        listInfoComment(this.queryCommentParams).then(response => {
          this.infoCommentList = response.rows;
          this.total = response.total;
        });
      },
      setIframeHeight() {
        var iframe = document.getElementById("frame");
        try{
          var bHeight = iframe.contentWindow.document.body.scrollHeight;
          var dHeight = iframe.contentWindow.document.documentElement.scrollHeight;
          var height = Math.max(bHeight, dHeight);
          iframe.height = height + 20;
        }catch (ex){
          console.log('1', ex)
        }
      },
      resolveNewsType(newsTypeId) {
        for (let i = 0; i < this.newsTypeList.length; i++) {
          let obj = this.newsTypeList[i];
          if (obj.id == newsTypeId) {
            return obj;
          }
        }
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
              // 测试代码
              // aDivs[i].src = 'https://img0.baidu.com/it/u=2694049647,1435745352&fm=26&fmt=auto&gp=0.jpg'
              // this.imgList.push(aDivs[i].src)
              //   aDivs[i].onclick = (e) => {
              //     this.initialIndex = i
              //     this.showViewer = true
              //   }
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

<style scoped src="../../assets/styles/home/detail.css"></style>
<style lang="scss" scoped>
  @import '../../assets/styles/home/home.scss';
  @import '../../assets/styles/home/common.scss';
  * {
    margin: 0;
    padding: 0;
  }

  .detail-container {
    max-width: 1180px;
    margin: 24px auto;
  }

  .detail-left {
    width: 880px;
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
</style>
