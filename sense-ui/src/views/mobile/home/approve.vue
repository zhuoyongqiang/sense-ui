<template>
  <div class="wrapper" v-loading="loading">
    <div class="done-tip" v-show="showTip && this.type !== '2'">
      <img src="../../../assets/images/mobile/xib-workflow-status-icon.png" class="doneImg">
      <span>待办已处理，工单详情及审批结果如下</span>
      <i class="el-icon-close" @click="showTip = false"></i>
    </div>
    <div class="header-panel">
      <img src="../../../assets/images/mobile/window/approveNavbar.png" class="icon">
      <div class="title">新闻审核</div>
      <!-- <span class="code">{{taskId}}</span> -->
    </div>
    <div class="nav-panel">
      <div :class="{'active': activeName === '新闻信息'}"><span @click="navClick('新闻信息')">新闻信息</span></div>
      <div :class="{'active': activeName === '发布预览'}"><span @click="navClick('发布预览')">发布预览</span></div>
      <div :class="{'active': activeName === '流程图'}"><span  @click="navClick('流程图')">流程图</span></div>
      <div :class="{'active': activeName === '审批意见'}"><span @click="navClick('审批意见')">审批意见</span></div>
    </div>

    <div class="scroll-view-container" ref="container">
      <div class="scroll-view" ref="detail" id="newsScrollView" v-show="activeName === '新闻信息'">
        <div class="desc-panel">
          <div class="cell flex"><div class="label">新闻标题</div><div class="value">{{form.title}}</div></div>
          <div class="cell flex"><div class="label">作者</div><div class="value">{{form.issuer}}</div></div>
          <div class="cell flex"><div class="label">发布时间</div><div class="value">{{form.effectTime}}</div></div>
          <div class="cell flex"><div class="label">所属分类</div><div class="value">{{form.newsTypeName}}</div></div>
        </div>
        <div class="content-panel">
          <div class="title">正文内容</div>
          <div class="newsMain" v-html="form.content"></div>
        </div>
        <div class="attach-panel newsAttach" v-show="attachSwitch === '1' && form.attachmentList && form.attachmentList.length">
          <div class="title">本文附件</div>
          <div v-for="item in form.attachmentList" :key="item.id" @click="toPreview(item.attachmentUrl)" class="link">{{item.attachmentTitle}}</div>
        </div>
        <!-- 测试代码 -->
        <!-- <div class="attach-panel newsAttach">
          <div class="title">本文附件</div>
          <div @click="toPreview('https://fls.onlinedo.cn/index/OutInterface/downloadOrPreview?base=eyJub25jZV9zdHIiOiJ4b1V0WHNPMUtNMUVQZWZYRkw2QVZSOFdDUXRteEVWbSIsImZpbGVfZGlyZWN0b3J5IjoiXC9vdXRwdXRcLzI0NTEyNDY2NjQ3OVwvXHU0ZTAzXHU2NzA4XHU4YmVmXHU5OTEwXHU4ZDM5Lmh0bWwiLCJ0eXBlIjoxLCJzaWduIjoiQTFEOUM0QTRBMjRCNzExRjIyMjgyMjg1MkU0QUQyMzUifQ==')" class="link">iphone手机设备号.xlsx</div>
          <div class="link">nc报销单查询接口字段信息.docx</div>
        </div> -->
      </div>
      
      <div class="scrool-view" v-show="activeName === '发布预览'">
        <div class="newsTitle-panel">
          <div class="title">{{form.title}}</div>
          <div class="issuer">{{form.issuer}}</div>
          <div class="time"><i class="el-icon-time"></i> {{form.effectTime}}</div>
        </div>
        <div class="newsContent-panel">
          <div class="newsMain" ref="content" v-html="form.content"></div>
        </div>
      </div>

      <div class="scrool-view" v-show="activeName === '流程图'">
        <div class="step-panel">
          <step-process :flow-image-height.sync="flowImageHeight" :current-node-index.sync="currentNodeIndex"
            :model-node-list="modelNodeList" :bpm-news-instance="formData.bpmNewsInstance"
            :instance-id="instanceId"></step-process>
        </div>
      </div>

      <div class="scrool-view" v-show="activeName === '审批意见'">
        <div class="timeline-panel">
          <div class="timelineItem" v-for="(item, index) in taskData.filter(v => v.status === 0 || v.status === 2)" :key="index" >
            <div class="left"></div>
            <div class="right">
              <div class="header">
                <div class="name">{{item.nickName}}</div>
                <div class="org" v-show="false">总行</div>
                <div class="time">{{item.endTime}}</div>
              </div>
              <div class="card">
                <div class="card-header">
                  <div>经办人-{{item.taskName}}</div>
                  <span :class="{'success' : item.status === 2, 'fail': item.status === 0}">{{processStatus(item.status)}}</span>
                </div>
                <div class="card-content">{{item.remark}}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="footer" v-show="bpmNewsTask && (bpmNewsTask.type==1 || bpmNewsTask.type==2)">
      <div class="input">
        <el-input
          type="textarea"
          :autosize="{minRows: 1}"
          placeholder="审批意见"
          resize="none"
          v-model="idea"/>
      </div>
      <div class="btn-wrapper">
         <div class="btn rejectbtn" v-if="bpmNewsTask && (bpmNewsTask.type==1 || bpmNewsTask.type==2)" @click="rejectEvent"><i class="el-icon-close"></i>驳回</div>
         <div class="btn" v-if="bpmNewsTask && bpmNewsTask.type==1" @click="agreeEvent"><i class="el-icon-check"></i>通过</div>
         <div class="btn" v-if="bpmNewsTask && bpmNewsTask.type==2" @click="publishEvent">发布</div>
      </div>
    </div>
  </div>
</template>

<script>
import closeWindow from '@/mixins/closeWindow'
import {agree,getTaskInfo, getProcessInfo, getTaskListByInstanceId, publish, reject} from "@/api/console/bpm/workflow";
import {getConfigKey} from "@/api/home/config";
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import StepProcess from "@/views/console/platform/page/stepProcess";
import scrollTriangle from '@/components/scrollTriangle/index.js'

export default {
  name: "mobileapprove",
  components: {StepProcess},
  mixins: [closeWindow],
  data() {
    return {
      homeTop: 0,
      showTip: false, // 是否展示已办提示
      documentTitle: '',
      activeName: '新闻信息',
      attachSwitch: '0',
      loading: false,
      taskId: undefined,
      instanceId:undefined,
      form: {
        titie:'',
        content:''
      },
      formData: {},
      bpmNewsTask: {},
      prefixNewsId: undefined,
      suffixNewsId: undefined,
      idea: '',
      images: [],
      flowImageHeight: undefined,
      modelNodeList: [],
      instanceId: undefined,
      taskData: [],
      bpmProcessStatusOptions: [],
      instanceStatus: null,
      previewEl: null,
      scrollBottom: false,
      type: null, // 区分已办和我的申请，1或null - 已办，2 - 我的申请
      // images: [
      //   'https://img0.baidu.com/it/u=4076493291,331486562&fm=26&fmt=auto',
      //   'https://img0.baidu.com/it/u=3852342839,1648795188&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083',
      //   'https://img0.baidu.com/it/u=3852342839,1648795188&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083',
      //   'https://img0.baidu.com/it/u=3161564990,324578674&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083',
      //   'https://img1.baidu.com/it/u=618247683,1170799102&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1082',
      //   'https://img1.baidu.com/it/u=618247683,1170799102&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1082'
      // ]
    }
  },
  created() {
    if(this.isUserLogin){
      // 获取流程状态数据字典
      this.getDicts("bpm_process_status").then(response => {
        this.bpmProcessStatusOptions = response.data;
      })
      getConfigKey('attachSwitch').then(resp => {
        if (resp.code === 200) {
          this.attachSwitch = resp.msg
        }
      })
      // 根据链接上的参数区分是否为待办或已办
      const urlCode = this.$route.params && this.$route.params.taskId
      let type
      if (urlCode.includes('&')) {
        this.instanceId = urlCode.split('&')[0]
        type = urlCode.split('&')[1]
      } else {
        this.taskId = urlCode
      }
      if (type && (type === 'process' || (type.includes('=') && type.split('=')[0] === 'process'))) {
        // 查询已办详情
        this.type = type.includes('=') && type.split('=')[1]
        this.queryDetail()
      } else {
        // 查询待办详情
        this.queryTODOdetail()
      }
    }else{
       this.msgWarning('暂无访问权限');
       const timer = setTimeout(() => {
        clearTimeout(timer)
        this.closeWindow()
      }, 1000);
    }
  },
  activated () {
    // 页面每次加载时更改页面标题
    document.title = this.documentTitle
    if (!document.getElementById('newsScrollView')) {
      return
    }
    document.getElementById('newsScrollView').scrollTop = this.homeTop || 0
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2;')
  },
  beforeDestroy() {
    if (this.previewEl) {
      this.previewEl.close()
    }
    scrollTriangle.unstall()
  },
  watch: {
    $route(to, from) {
       // 如果不是从文档预览过来的，且目标页面是当前页面，则清除当前页面的缓存
      if (!from.path.includes('attachmentPreview') && to.path.includes('/mobile/home/approve')) {
        const index = window.keepAliveViews.findIndex(v => v === 'mobileapprove')
        if (index >= 0) {
          window.keepAliveViews.splice(index, 1)
        }
      }
    }
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    },
    currentNodeIndex() {
      if (this.instanceStatus == 2) {
        return this.modelNodeList.length;
      } else {
        if (JSON.stringify(this.formData) != '{}') {
          let task = this.formData.bpmNewsTask;
          let list = this.modelNodeList;
          if (task != undefined && list != undefined) {
            for (let i = 0; i < list.length; i++) {
              if (list[i].node == task.modelNode) {
                return i;
              }
            }
          }
        }
        return 0;
      }
    }
  },
  beforeRouteLeave (to, from, next) {
    if (to.path.includes('attachmentPreview')) {
      // 路由离开前记录页面滚动位置
      let app = document.getElementById('newsScrollView')
      this.homeTop = app.scrollTop || 0
       // 将当前组件进行缓存，便于文件预览时的回退，不会引起页面重构
      if (!window.keepAliveViews.includes('mobileapprove')) {
        window.keepAliveViews.push('mobileapprove')
      }
    } else {
      const index = window.keepAliveViews.findIndex(v => v === 'mobileapprove')
      if (index >= 0) {
        window.keepAliveViews.splice(index, 1)
      }
    }
    const timer = setTimeout(() => {
      clearTimeout(timer)
      next()
    }, 100);
  },
  methods:{
    processStatus (val) {
      return this.selectDictLabel(this.bpmProcessStatusOptions, val);
    },
    navClick (navName) {
      if (navName === this.activeName) {

      } else {
        this.activeName = navName
      }
    },
    /**********************
     * @desc 查询待办详情
     * @function queryTODOdetail
     * @abstract 状态码返回403时，msg内容为流程id，凭此查询已办详情
     */
    queryTODOdetail () {
      this.loading = true
      getTaskInfo(this.taskId).then(res => {
        this.loading = false
        if (res.code == 200) {
          this.formData = res.data
          document.title = res.data.bpmNewsInstance.businessName;
          this.documentTitle = res.data.bpmNewsInstance.businessName
          if(res.data.infoNews === null){
            this.form.title = res.data.bpmNewsInstance.businessName
            this.form.content = ""
            this.loading = false
          }else{
            this.form = res.data.infoNews;
            // 测试代码
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3562420915,3666779717&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=618247683,1170799102&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1082">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=4076493291,331486562&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3852342839,1648795188&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=4139035421,3795625589&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img2.baidu.com/it/u=2204597794,3390627479&fm=26&fmt=auto">')
            this.$nextTick(() => {
              this.loading = false
              this.bindImgelement()
              scrollTriangle.install({
                // 如果el和scrollEl相同，或者只传递el，则滚动提示挂载在document.body下，居于页面滚动
                // 并且el为监听滚动的dom
                id: 'scrollTriangle', // 滑动提示组件的id
                el: this.$refs.container, // 挂载滚动提示的载体dom
                scrollEl: this.$refs.detail // 监听滚动的dom
              })
            })
          }
          this.bpmNewsTask = res.data.bpmNewsTask;
          this.instanceId = this.bpmNewsTask.newsInstId;
          this.instanceStatus = res.data.bpmNewsInstance.status;
           //流程图
          let modelNodeList = [];
          modelNodeList.push({taskName: '发起人', node: 'START', modelNode: 'START'})
          for (let i in res.data.modelNodeList) {
            modelNodeList.push(res.data.modelNodeList[i]);
          }
          modelNodeList.push({taskName: '结束', node: 'END', modelNode: 'END'})
          this.modelNodeList = modelNodeList;
          //流程高度
          this.flowImageHeight = this.modelNodeList.length * 60 + 60 + 'px';
          // 获取流程审批
          getTaskListByInstanceId(this.instanceId).then(res => {
            this.taskData = res;
          })
          this.form.readNum = 0
        } else {
          // this.loading = false
          // this.msgWarning('待办已处理');
          // const timer = setTimeout(() => {
          //   clearTimeout(timer)
          //   this.closeWindow()
          // }, 1000);
          if (res.code === 302) {
            this.instanceId = res.msg
            this.queryDetail()
          } else {
            this.loading = false
            this.msgWarning(res.msg);
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.closeWindow()
            }, 1000);
          }
        }
      })
    },
    /**********************
     * @desc 查询已办详情
     * @function queryDetail
     */
    queryDetail () {
      this.showTip = true
      this.loading = true
      getProcessInfo(this.instanceId).then(res => {
        this.loading = false
        if (res.code == 200) {
          this.formData = res.data
          document.title = res.data.bpmNewsInstance.businessName;
          this.documentTitle = res.data.bpmNewsInstance.businessName
          if(res.data.infoNews === null){
            this.form.title = res.data.bpmNewsInstance.businessName
            this.form.content = ""
            this.loading = false
          }else{
            this.form = res.data.infoNews;
            // 测试代码
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3562420915,3666779717&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=618247683,1170799102&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1082">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=4076493291,331486562&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img0.baidu.com/it/u=3852342839,1648795188&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=1083">')
            // this.form.content += ('<img src="https://img1.baidu.com/it/u=4139035421,3795625589&fm=26&fmt=auto">')
            // this.form.content += ('<img src="https://img2.baidu.com/it/u=2204597794,3390627479&fm=26&fmt=auto">')
            this.$nextTick(() => {
              this.loading = false
              this.bindImgelement()
              scrollTriangle.install({
                // 如果el和scrollEl相同，或者只传递el，则滚动提示挂载在document.body下，居于页面滚动
                // 并且el为监听滚动的dom
                id: 'scrollTriangle', // 滑动提示组件的id
                el: this.$refs.container, // 挂载滚动提示的载体dom
                scrollEl: this.$refs.detail // 监听滚动的dom
              })
            })
          }
          this.instanceStatus = res.data.bpmNewsInstance.status;
           //流程图
          let modelNodeList = [];
          modelNodeList.push({taskName: '发起人', node: 'START', modelNode: 'START'})
          for (let i in this.formData.modelNodeList) {
            modelNodeList.push(this.formData.modelNodeList[i]);
          }
          modelNodeList.push({taskName: '结束', node: 'END', modelNode: 'END'})
          this.modelNodeList = modelNodeList;
          //流程高度
          this.flowImageHeight = this.modelNodeList.length * 60 + 60 + 'px';
          // 获取流程审批
          getTaskListByInstanceId(this.instanceId).then(res => {
            this.taskData = res;
          })
          this.form.readNum = 0
        } else {
          this.loading = false
          this.msgWarning(res.data.msg);
        }
      })
    },
    /**********************
     * @desc 跳转文件预览页面
     * @function toPreview
     */
    toPreview (url) {
      sessionStorage.setItem('attach', url)
      this.$router.push(`/mobile/home/attachmentPreview`)
    },
    ConvertToArray (nodes) {
      let array = []
        try{
          array=Array.prototype.slice.call(nodes, 0);//非ie浏览器  ie8-将NodeList实现为COM对象，不能用这种方式检测
        } catch(ex){//ie8-
          array=new Array();
          for(var i=0;i< nodes.length; i++){
            array.push(nodes[0]);
          }
        }
      return array;
    },
    bindImgelement () {
      this.$nextTick(async () => {
        const aDivs = this.ConvertToArray(this.$refs.content.querySelectorAll('img'))
        if (aDivs.length) {
          for (let i = 0; i< aDivs.length; i++) {
            try {
              await this.checkImgExists(aDivs[i].src)
                aDivs[i].setAttribute('preview', '0')
                // aDivs[i].onclick = (e) => {
                //   console.log(i)
                //   this.$imagePreview({
                //     images: this.images,
                //     index: i,
                //     defaultOpt: {
                //       fullscreenEl: false,
                //       showHideOpacity: false,
                //       errorMsg: '<div class="pswp__error-msg">图片加载失败</div>',
                //     }
                //   })
                // }
            } catch (err) {
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
          this.$previewRefresh()
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
          reject(err)
        }
      })
    },
     //同意
    agreeEvent() {
      let self = this;
      let params = {};
      params.id = self.taskId;
      if (self.idea == '') {
        params.remark = '同意';
      } else {
        params.remark = self.idea;
      }
      agree(params).then(res => {
        if (res.code == 200) {
          self.msgSuccess("处理完成");
          self.bpmNewsTask.type=1000;
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.closeWindow()
          }, 1000);
        } else {
          this.msgError(res.msg);
        }
      })
    },
    //驳回
    rejectEvent() {
      let self = this;
      let params = {};
      params.id = self.taskId;
      if (self.idea == '') {
        params.remark = '驳回';
      } else {
        params.remark = self.idea;
      }
      reject(params).then(res => {
        if (res.code == 200) {
          self.msgSuccess("处理完成");
          self.bpmNewsTask.type=1000;
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.closeWindow()
          }, 1000);
        } else {
          this.msgError(res.msg);
        }
      })
    },
    //发布
    publishEvent() {
      let self = this;
      let params = {};
      params.id = self.taskId;
      if (self.idea == '') {
        params.remark = '发布';
      } else {
        params.remark = self.idea;
      }
      publish(params).then(res => {
        if (res.code == 200) {
          self.msgSuccess("处理完成");
          self.bpmNewsTask.type=1000;
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.closeWindow()
          }, 1000);
        } else {
          self.msgError(res.msg);
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.wrapper {
  background: #F7F8FA;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  padding-bottom: constant(safe-area-inset-bottom); /* 兼容 iOS < 11.2 */
  padding-bottom: env(safe-area-inset-bottom); /* 兼容 iOS >= 11.2 */
}
.done-tip{
  // height: 75rem;
  height: 20vw;
  display: flex;
  align-items: center;
  background-color: #eff8eb;
  padding: 0 .43rem;
  box-sizing: border-box;
  .doneImg{
    width: 1.7rem;
    height: auto;
    margin-right: .4rem;
  }
  span{
    font-size: .37rem;
    color:#303133;
  }
  i{
    margin-left: .21rem;
    font-size: .43rem;
  }
}
.scroll-view-container{
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  position: relative;
  .scroll-view{
    overflow-y: auto;
    height: 100%;
  }
  // margin-bottom: .53rem;
}
.header-panel{
  display: flex;
  align-items: center;
  padding: .43rem 0;
  overflow: hidden;
  .icon{
    width: .48rem;
    height: .48rem;
    margin-left: .32rem;
    vertical-align: bottom;
    margin-top: 2px;
  }
  .title{
    font-size: .48rem;
    font-weight: 600;
    color: #303133;
    margin: 0 .21rem 0 .11rem;
    white-space: nowrap;
  }
  .code{
    font-size: .27rem;
    font-weight: 400;
    color: #2272DE;
    background-color: rgba(#2272DE, .08);
    border: 1px solid #2272DE;
    padding: 4px .11rem 2px;
    border-radius: .05rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}

.nav-panel{
  display: flex;
  padding: 0 .16rem;
  margin-bottom: .32rem;
  >div{
    font-size: 0;
    width: 25%;
    min-width: 25%;
    text-align: center;
    span{
      display: inline-flex;
      width: 2.18rem;
      height: .8rem;
      align-items: center;
      // line-height: .8rem;
      // padding: 0 .2rem;
      justify-content: center;
      background-color: #EBEEF2;
      border-radius: .4rem;
      font-weight: 400;
      color: #606266;
      font-size: .37rem;
      text-align: center;
      transition: all .5s;
    }
    &.active{
      span{
        background-color: #2272DE;
        color: #fff
      }
    }
  }
}

.desc-panel{
  background-color: #fff;
  border-radius: .11rem;
  margin: 0 .32rem .267rem;
  padding: .32rem .32rem 0;
  .cell{
    font-size: .43rem;
    padding: .267rem 0;
    padding-bottom: 0;
    &:not(:last-child){
       border-bottom: 1px solid #F2F2F3;
    }
    &.flex{
      display: flex;
      // align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      align-items: flex-start;
      line-height: .693rem;
    }
    .label{
      // margin-top: .27rem;
      font-weight: 400;
      color: #303133;
      padding-bottom: .267rem;
      width: 2.13rem;
      min-width: 2.13rem;
    }
    .value{
      // margin-top: .27rem;
      font-weight: 400;
      color: #606266;
      padding-bottom: .267rem;
      line-height: 1.5;
    }
  }
}

.content-panel{
  background-color: #fff;
  border-radius: .11rem;
  margin: 0 .32rem .32rem;
  padding: .32rem .32rem 0;
  flex: 1;
  .title{
    font-size: .43rem;
    font-weight: 400;
    color: #303133;
    margin-bottom: .267rem;
  }
  ::v-deep .newsMain{
    min-height: calc(100% - .7rem);
    >*{
      font-size: .43rem;
    }
    *{
      // font-size: .43rem;
      line-height: 1.5!important;
      word-break: break-all;
      text-align: justify;
    }
    li{
      list-style-position: inside;
    }
    img {
      width: 100%!important;
      height: auto !important;
    }
  }
}

.attach-panel{
  background-color: #fff;
  border-radius: .11rem;
  margin: 0 .32rem .32rem;
  padding: .32rem .32rem;
  .title{
    font-size: .43rem;
    font-weight: 400;
    color: #303133;
    margin-bottom: .267rem;
  }
  &.newsAttach {
    color: #333333;
    font-size: .37rem;
    .link{
      cursor: pointer;
      color: #2272DE;
      text-decoration: underline;
      margin-top: .16rem;
      text-align: justify;
      word-break: break-all;
    }
  }
}

.newsTitle-panel{
  background: url('../../../assets/images/mobile/mobileDetailBG.png') no-repeat 0 0;
  background-size: 100% auto;
  padding: .32rem .43rem;
  color: #465261;
  .title{
    font-weight: 500;
    font-size: .64rem;
    line-height: 1.5;
  }
  .issuer{
    font-size: .43rem;
    font-weight: 400;
    margin: .43rem 0 .26rem;
  }
  .time{
    display: flex;
    align-items: center;
    font-size: .35rem;
    font-weight: 400;
    color: #798391;
    i{
      font-size: .37rem;
      margin-right: .11rem;
    }
  }
}
.newsContent-panel{
  background-color: #fff;
  box-shadow: 0px -.08rem .16rem 0px rgba(208, 217, 228, 0.5);
  border-radius: .43rem .43rem 0 0;
  padding: .32rem .32rem;
  flex: 1;
  ::v-deep .newsMain{
    min-height: 100%;
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
}

.step-panel{
  margin: 0 .32rem .32rem;
  background: #fff;
  overflow: hidden;
  min-height: calc(100% - .32rem);
  padding: .32rem .32rem 0;
}

.timeline-panel{
  .timelineItem{
    display: flex;
    margin-bottom: .08rem;
    .left{
      margin-left: .19rem;
      width: .45rem;
      position: relative;
      &::before{
        position: absolute;
        content: '';
        width: .16rem;
        height: .16rem;
        left: 50%;
        top: .2rem;
        transform: translate(-50%, 0);
        background: #2272DE;
        box-sizing: border-box;
        box-shadow: 0 0 0 .05rem rgba(#2272DE, .2);
        display: inline-block;
        border-radius: 50%;
        z-index: 2;
      }
    }
    .right{
      flex: 1;
      .header{
        display: flex;
        align-items: center;
        padding-right: .32rem;
      }
      .name{
        color:#303133;
        font-size: .37rem;
        margin-left: .11rem;
      }
      .org{
        font-weight: 400;
        color: #606266;
        font-size: .32rem;
        margin-left: .21rem;
      }
      .time{
        flex: 1;
        text-align: right;
        font-weight: 400;
        color: #AFB0B2;
        font-size: .32rem;
      }
      .card{
        margin-top: .21rem;
        margin-bottom: .35rem;
        background-color: #fff;
        padding: .27rem .43rem;
        box-shadow: 0px 2px 10px 1px #ECEEF4;
        border-radius: 4px 0px 0px 4px;
        .card-header{
          display: flex;
          justify-content: space-between;
          font-weight: 600;
          color: #303133;
          font-size: .37rem;
          span{
            border-radius: .27rem;
            padding: .11rem .32rem;
            &.success{
              background-color: rgba(#67C23A, .08);
              color: #67C23A;
            }
            &.fail{
              background-color: rgba(#FF5555, .08);
              color: #FF5555;
            }
          }
        }
        .card-content{
          margin-top: .21rem;
          font-weight: 400;
          color: #606266;
          font-size: .37rem;
          text-align: justify;
        }
      }
    }
    &:not(:last-child){
      .left{
        &::after{
          position: absolute;
          content: '';
          top: .41rem;
          left: 50%;
          bottom: 0;
          transform: translateX(-50%);
          display: inline-block;
          // width: 1px;
          border-left: 1px dashed #C5CBD3;
        }
      }
    }
  }
}

.footer{
  background: #fff;
  box-shadow: 0px -1px 8px 0px rgba(235, 237, 241, 0.7);
  border-radius: .32rem .32rem 0 0;
  ::v-deep .el-textarea{
    padding: .32rem .32rem 0;
    textarea{
      background-color: #F7F8FA;
      border: none;
      font-size: .37rem;
      padding: .21rem .32rem;
      box-sizing: border-box;
    }
  }
  .btn-wrapper{
    display: flex;
    margin: .37rem .32rem .586rem;
    justify-content: space-between;
    align-items: center;
    font-size: .43rem;
    height: 1.17rem;
    .more{
      display: flex;
      align-items: center;
      white-space: nowrap;
      margin-right: .53rem;
      font-weight: 400;
      color: #303133;
      font-size: .43rem;
      i{
        border-radius: 50%;
        border: .08rem solid #303133;
        font-size: .32rem;
        margin-right: .16rem;
      }
    }
    .btn{
      flex: 1;
      line-height: 1.17rem;
      text-align: center;
      border-radius: .11rem;
      box-sizing: border-box;
      color:#fff;
      font-weight: 600;
      font-size: .43rem;
      background-color: #2272DE;
      i{
        font-weight: 600;
        margin-right: .11rem;
      }
      &.rejectbtn{
        color: #FF5555;
        background-color: #FFF2F2;
      }
      &:not(:last-child){
        margin-right: .43rem;
      }
    }
  }
  
}

::v-deep .step{
  .el-step__head{
    font-size: 0;
  }
}
.arrow-panel{
    position: absolute;
    bottom: 10px;
    width: 100%;
  }
  @keyframes buling {
    0%{
      opacity: 1;
    }
    60%{
      opacity: .33;
    }

    100%{
      opacity: .66;
    }
  }
  @for $i from 1 through 3 {
    .arrow-bottom#{$i} {
      bottom: 16px * $i;
      animation: buling 0.9s ease-in-out -0.3s * $i infinite;
    }
  }
  .arrow-bottom{
    display: inline-block;
    border-style: solid;
    border-width: 2px 2px 0 0;
    border-color: rgba(#2272DE, 0.8);
    height: 10px;
    width: 10px;
    // margin:50px auto 0;
    transform: rotate(135deg);
    transform-origin: center center;
    position: absolute;
    right: 28px;
  }

// .footer{
//   box-shadow: 0 -.03rem .56rem 0 rgba(220, 220, 221, 0.4);
// }

// .footer ::v-deep .el-textarea{
//   padding: .43rem .43rem 0 .43rem;

// }

// .footer ::v-deep .el-textarea textarea{
//   background-color: #f7f7f7;
//   border: none;
//   font-size: .43rem;
//   padding: .29rem .37rem;
//   box-sizing: border-box;
// }

</style>
