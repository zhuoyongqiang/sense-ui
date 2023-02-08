<template>
  <div class="mobileNewsContainer" v-if="isShow">
    <div class="mobileNews">
      <div class="bgImg">
        <p class="newsTitle">{{ form.title }}</p>
        <ul class="headerInfoWrap">
          <li>{{ form.issuer }}</li>
          <li></li>
        </ul>
        <div class="navbar-wrapper">
          <div class="left"><img src="~@/../src/assets/images/mobile/mobileDetailTime.png" /><span>{{ form.effectTime }}</span></div>
          <div class="middle">
            <img src="~@/../src/assets/images/window/font.png">
            <div>【</div>
            <div class="font-label">
              <div :class="fontType==='0'?'activefont':''" @click="changeFontType('0')">标准</div>
              <div :class="fontType==='1'?'activefont':''" @click="changeFontType('1')">中</div>
              <div :class="fontType==='2'?'activefont':''" @click="changeFontType('2')">大</div>
            </div>
            <div>】</div>
          </div>
          <div class="right"><img src="~@/../src/assets/images/mobile/mobileDetailEye.png" /><span>{{ form.readNum }}次浏览</span></div>
        </div>
        <!-- <ul class="headerInfoWrap smInfo">
          <li>
            <img src="~@/../src/assets/images/mobile/mobileDetailTime.png" />{{ form.effectTime }}
            <div class="fontclickul">
              <div style="margin-right: 0">
                <img src="~@/../src/assets/images/window/font.png">
              </div>
              <div>【</div>
              <div :class="fontType==='0'?'activefont':''" @click="changeFontType('0')">标准</div>
              <div :class="fontType==='1'?'activefont':''" @click="changeFontType('1')">中</div>
              <div :class="fontType==='2'?'activefont':''" @click="changeFontType('2')">大</div>
              <div style="margin-right: 0">】</div>
            </div>
          </li>
          <li><img src="~@/../src/assets/images/mobile/mobileDetailEye.png" />{{ form.readNum }}次浏览</li>
        </ul> -->
      </div>
      <div class="newsMain" :class="{'Fontnormal':fontType === '0','fontMid':fontType === '1','fontBig':fontType === '2'}">
        <div class="newaMain_body" v-html="form.content" ref="content"></div>
      </div>
      <div class="newsAttach" v-show="attachSwitch === '1' && form.attachmentList && form.attachmentList.length">
        <div class="title">本文附件</div>
        <div v-for="item in form.attachmentList" :key="item.id" @click="toPreview(item.attachmentUrl)" class="link">{{item.attachmentTitle}}</div>
      </div>
      
      <!-- 测试代码 -->
      <!-- <div class="newsAttach" v-show="attachSwitch === '1'">
        <div class="title">本文附件</div>
        <div @click="toPreview('https://fls.onlinedo.cn/index/OutInterface/downloadOrPreview?base=eyJub25jZV9zdHIiOiJ4b1V0WHNPMUtNMUVQZWZYRkw2QVZSOFdDUXRteEVWbSIsImZpbGVfZGlyZWN0b3J5IjoiXC9vdXRwdXRcLzI0NTEyNDY2NjQ3OVwvXHU0ZTAzXHU2NzA4XHU4YmVmXHU5OTEwXHU4ZDM5Lmh0bWwiLCJ0eXBlIjoxLCJzaWduIjoiQTFEOUM0QTRBMjRCNzExRjIyMjgyMjg1MkU0QUQyMzUifQ==')" class="link">iphone手机设备号.xlsx</div>
        <div class="link">nc报销单查询接口字段信息.docx</div>
      </div> -->

      <div class="newsArrow">
        <div class="newsArrowContent">
          <a v-if="prefixNewsId!=undefined" @click="toNews(prefixNewsId)" class="newsArrowLeft">
            <img src="~@/../src/assets/images/mobile/mobileDetailLeft.png" />上一篇
          </a>
          <div v-if="prefixNewsId!=undefined && suffixNewsId!=undefined" class="hr"></div>
          <a v-if="suffixNewsId!=undefined" @click="toNews(suffixNewsId)" class="newsArrowRight">
            下一篇
            <img src="~@/../src/assets/images/mobile/mobileDetailRight.png" />
          </a>
          <div class="clear"></div>
        </div>
      </div>

    </div>
<!--    <div class="fontbtn">-->
<!--      <div class="fontshow" v-show="!fontShow" @click="showfont">A</div>-->
<!--      <div class="fontclickul"  v-show="fontShow">-->
<!--        -->
<!--      </div>-->
<!--    </div>-->
  </div>
</template>

<script>
import closeWindow from '@/mixins/closeWindow'
import {getToken} from "@/utils/auth";
import {getNews, getPrefixAndSuffixNewsId, read} from "@/api/home/news";
import {getConfigKey} from "@/api/home/config";
import '@/store/REM.js'

export default {
  name: "mobileDetail",
  mixins: [closeWindow],
  data() {
    return {
      homeTop: 0,
      baseFilePath: undefined,
      form: {},
      prefixNewsId: undefined,
      suffixNewsId: undefined,
      isShow:false,
      timer: null,
      fontType: '0',
      openMethods: '',
      attachSwitch: '0',
      previewEl: null
    }
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  created() {
    if (localStorage.getItem('fontType')) {
      this.fontType = localStorage.getItem('fontType')
    }
    getConfigKey('attachSwitch').then(resp => {
      if (resp.code === 200) {
        this.attachSwitch = resp.msg
      }
    })
  },
  watch: {
    $route(to, from) {
       console.log('路由变动 =====route', 'to:', to, '; from:',from)
       // 如果不是从文档预览过来的，且目标页面是当前页面，则清除当前页面的缓存
      if (!from.path.includes('attachmentPreview') && to.path.includes('/mobile/home/detail')) {
        console.log('路由变动====清除缓存')
        const index = window.keepAliveViews.findIndex(v => v === 'mobileDetail')
        if (index >= 0) {
          window.keepAliveViews.splice(index, 1)
        }
      }
    }
  },
  mounted() {
    this.onLoad()
  },
  activated () {
    // 页面每次加载时更改页面标题
    document.title = "新闻详情";
    if (!document.getElementsByClassName('mobileNewsContainer')[0]) {
      return
    }
    document.getElementsByClassName('mobileNewsContainer')[0].scrollTop = this.homeTop || 0
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2;')
  },
  beforeRouteLeave (to, from, next) {
    if (to.path.includes('attachmentPreview')) {
      // 路由离开前记录页面滚动位置
      let app = document.getElementsByClassName('mobileNewsContainer')[0]
      this.homeTop = app.scrollTop || 0
       // 将当前组件进行缓存，便于文件预览时的回退，不会引起页面重构
      if (!window.keepAliveViews.includes('mobileDetail')) {
        window.keepAliveViews.push('mobileDetail')
      }
    } else {
      console.log('清除缓存=====beforeRouteLeave')
      const index = window.keepAliveViews.findIndex(v => v === 'mobileDetail')
      if (index >= 0) {
        window.keepAliveViews.splice(index, 1)
      }
    }
    console.log(to)
    const timer = setTimeout(() => {
      clearTimeout(timer)
      next()
    }, 100);
  },
  beforeDestroy() {
    if (this.previewEl) {
      this.previewEl.close()
    }
    clearTimeout(this.timer)
  },
  deactivated () {
    // 清除计时器
    clearTimeout(this.timer)
  },
  methods: {
    onLoad () {
      this.isShow=false;
      this.currentNewsId = this.$route.params && this.$route.params.newsId;
      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
      //手机端没有登录就不进行加载，防止行内人分享连接
      if(this.isUserLogin){
          document.title = '新闻详情';
          this.getInfo(this.currentNewsId);
      }else{
          document.title = '暂无权限';
          this.msgWarning('暂无访问权限');
      }
    },
    changeFontType(type) {
      this.fontType = type
      localStorage.setItem('fontType',type)
      this.fontShow = false
    },
    setRead (id) {
      read(id).then(() => {
        let arr = sessionStorage.getItem('readTag') ? JSON.parse(sessionStorage.getItem('readTag')) : []
        if (!arr.includes(id)) {
           arr.push(id)
        }
        sessionStorage.setItem('readTag', JSON.stringify(arr))
      }).catch(err => {
        console.warn(err)
      })
      // this.timer = setTimeout(() => {
      //   clearTimeout(this.timer)
      //   read(id).then(resp => {
      //     let arr = sessionStorage.getItem('readTag') ? JSON.parse(sessionStorage.getItem('readTag')) : []
      //     if (!arr.includes(id)) {
      //       arr.push(id)
      //     }
      //     sessionStorage.setItem('readTag', JSON.stringify(arr))
      //   }).catch(err => {
      //     console.warn(err)
      //   })
      // }, 5000)
    },
    getInfo(id) {
      getNews(id).then(response => {
        if (response.code == 200) {
          this.isShow=true
          this.form = response.data;
           // 测试代码
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3562420915,3666779717&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=618247683,1170799102&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1082">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=4076493291,331486562&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3852342839,1648795188&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=4139035421,3795625589&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img2.baidu.com/it/u=2204597794,3390627479&fm=26&fmt=auto">')
            this.$nextTick(() => {
              this.bindImgelement()
            })
          if (!this.activeName) {
            this.activeName = this.form.newsTypeId;
          }
          // 判断当前新闻是否已读，已读则不调用已读接口
          if (!response.data.read) {
            this.setRead(this.currentNewsId)
          }
          //获取上一篇和下一篇的ID
          getPrefixAndSuffixNewsId(id, this.form.newsTypeId).then(response => {
            if (response.code == 200) {
              console.warn(response.data.suffixNewsId)
              this.prefixNewsId = response.data.prefixNewsId;
              this.suffixNewsId = response.data.suffixNewsId;
            }
          })
          const timer = setTimeout(() => {
            clearTimeout(timer)
            window.scrollTo(0, 0)
          }, 0)
        }else{
          this.isShow=false
          document.title = '您浏览的新闻不存在或者没有阅读权限';
          this.msgWarning('您浏览的新闻不存在或者没有阅读权限。');
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.closeWindow()
          }, 1000);
        }
      })
    },
    toNews(id) {
      this.$router.push({
        path: '/mobile/home/detail/' + id
      })
      // window.location.href = '/mobile/home/detail/' + id;
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
        // console.log(this.$refs.content)
        const aDivs = this.ConvertToArray(this.$refs.content.querySelectorAll('img'))
        if (aDivs.length) {
          for (let i = 0; i< aDivs.length; i++) {
            try {
              await this.checkImgExists(aDivs[i].src)
                aDivs[i].setAttribute('preview', '0')
            } catch (err) {
              console.log('???????????????:', err)
              // 测试代码
              // m.src = 'https://img0.baidu.com/it/u=2694049647,1435745352&fm=26&fmt=auto&gp=0.jpg'
              // this.imgList.push(m.src)
              //   m.onclick = (e) => {
              //     this.initialIndex = i
              //     this.showViewer = true
              //   }
              // aDivs[i].alt = '图片加载失败'
            }
          }
          // 刷新图片预览配置，添加图片预览效果
          this.$previewRefresh()
          // 获取图片预览实例
          this.$preview.on('imageLoadComplete', (e, item) =>{
            if (this.$preview.self) {
              this.previewEl = this.$preview.self
            }
          })
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
    /**********************
     * @desc 跳转文件预览页面
     * @function toPreview
     */
    toPreview (url) {
      console.log('123', url)
      sessionStorage.setItem('attach', url)
      this.$router.push('/mobile/home/attachmentPreview')
    }
  }
}
</script>


<style lang="scss" scoped>

.mobileNewsContainer {
  background: #FFF;
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
  min-height: 100%;
}

.mobileNews {
  text-align: left;
  /* //padding: 0.43rem; */
}
.fontbtn{
  position: fixed;
  z-index: 99;
  right: 0.5rem;
  bottom: 1.5rem;
}
.fontshow{
  width: 1rem;
  height: 1rem;
  border-radius: 50%;
  background-color: #0B86F1;
  font-size: 0.5rem;
  color: #FFFFFF;
  display: flex;
  align-items: center;
  justify-content: center;
}
.fontclickul{
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.3rem;
  margin-left: 0.3rem;
}
.headerInfoWrap .fontclickul img {
  width: 0.4rem;
  height: 0.4rem;
  display: block;
}
.fontclickul div {
  margin-right:0.29rem;
}
.activefont{
  color: #0B86F1;
}
.newsTitle {
  font-size: 0.6rem;
  font-weight: 500;
  color: #465261;
  line-height: 1rem;
}
.headerInfoWrap{
  display: flex;
  justify-content: space-between;
  color: #465261;
  font-size: 0.4rem;
  margin-top: 0.3rem;
}
.headerInfoWrap img{
  width: 0.35rem;
  height: 0.35rem;
  margin-right: 0.1rem;
  position: relative;
  top: 0.01rem;
}
.headerInfoWrap li{
  display: flex;
  align-items: center;
  line-height: 0.55rem;
}
.smInfo{
  color: #798391;
  font-size: 0.325rem;
  margin-top: 0;
}
.newsMain {
  font-weight: 400;
  color: #333333;
  // margin: 0.43rem 0;
  padding: 0.8rem 0.43rem 0.43rem 0.43rem;
  margin-top: -0.5rem;
  border-radius: 0.4rem 0.4rem 0 0;
  background: #fff;
  width: 100%;
  overflow-x: hidden;
  font-size: .37rem;
  line-height: 1.5;
}
::v-deep .newsMain .newaMain_body{
  >*{
    font-size: .43rem;
  }
  *{
    line-height: 1.5!important;
    word-break: break-all;
    text-align: justify;
  }
  li{
    list-style-position: inside;
  }
  img {
    width: 100% !important;
    height: auto !important;
  }
}
.Fontnormal .newaMain_body{
  zoom: 1;
}
.fontMid .newaMain_body{
  zoom: 1.2;
  /* padding: 0.67rem 0.36rem 0.36rem 0.36rem; */
  /* border-radius: 0.33rem 0.33rem 0 0; */
  /* margin: 0.36rem 0; */
  /* margin-top: -0.42rem; */
}
.fontBig .newaMain_body{
  zoom: 1.4;
  /* padding: 0.57rem 0.31rem 0.31rem 0.31rem;
  border-radius: 0.28rem 0.28rem 0 0;
  margin: 0.31rem 0;
  margin-top: -0.36rem; */
}

.mobileNews ul li {
  margin: 0.13rem 0.33rem 0 0;
  /*font-size: 0.37rem;*/
  /*color: #8F9193;*/
}

.mobileNews ul li > i {
  margin-right: 0;
}

.mobileNews ul li:last-child {
  margin-right: 0;

}

.mobileNews .newsMain >>> img {
  width: 100% !important;
  height: auto !important;
}

.newsAttach {
  color: #333333;
  font-size: .37rem;
  margin: 0 .43rem;
  .link{
    cursor: pointer;
    color: #2272DE;
    text-decoration: underline;
    margin-top: .16rem;
    text-align: justify;
    word-break: break-all;
  }
}
.newsArrow {
  margin: 0.43rem 0;
  display: flex;
  justify-content: flex-end;
  align-items:center;
  margin-right: 0.45rem;
  position: relative;
  z-index: 0;
}
.newsArrow .hr{
  width : 1px;
  height: 0.4rem;
  background: rgba(34, 114, 222, 0.4);
}
.newsArrowContent{
  color: #2272DE;
  border-radius: 0.45rem;
  height: 0.9rem;
  line-height:0.9rem;
  display: flex;
  align-items: center;
  background: rgba(34, 114, 222, 0.05);
  font-size: 0.35rem;
}
.newsArrow a{

  display: flex;
  align-items:center;
}
.newsArrow a.newsArrowLeft{
  padding: 0 0.4rem 0 0.3rem;
}
.newsArrow a.newsArrowRight{
  padding: 0 0.3rem 0 0.3rem;
}
.newsArrow img{
  width: 0.4rem;
  height: 0.4rem;
}
.newsArrowLeft img {
  margin-right: 0.1rem;
}
.newsArrowRight img {
  margin-left: 0.1rem;
}

.clear {
  clear: both;
}

.bgImg {
    padding: 0.4rem 0.4rem 0.8rem 0.4rem;
    background: url("~@/../src/assets/images/mobile/mobileDetailBG.png") center center no-repeat;
    background-size: 100% auto;
  }


.navbar-wrapper{
  margin-top: .16rem;
  display: flex;
  color: #798391;
  font-size: .35rem;
  align-items: center;
  justify-content: space-between;
}
.navbar-wrapper img{
  width: .37rem;
  height: .37rem;
  margin-right: .11rem;
}
.navbar-wrapper >div{
  display: flex;
  align-items: center;
  white-space: nowrap;
}
.navbar-wrapper .middle{
  flex: 1;
  padding: 0 .16rem;
  display: flex;
  max-width: 40vw;
}
.navbar-wrapper .middle .font-label{
  flex: 1;
  display: flex;
  justify-content: space-between;
  margin: 0 .11rem;
  font-size: .4rem;
  >div{
    cursor: pointer;
  }
}
</style>
