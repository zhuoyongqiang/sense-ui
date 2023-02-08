<template>
  <div class="subportal-wrapper">
    <div class="left">
      <component class="panel" v-for="item in componentList.filter((v, i) => i % 2 === 0)" 
        :params="item.bindParam && JSON.parse(item.bindParam)"
        :isMore="item.isMore"
        :moreName="item.moreName"
        :morelink="item.morelink"
        :linkType="item.linkType"
        :icon="item.icon"
        :height="item.maxHeight"
        :componetTitle="item.title"
        :maxHeight="item.maxHeight"
        page-num="1"
        :page-size="item.bindNumber"
        :base-file-path="baseFilePath"
        :is="getComps(item)" :key="item.id"></component>
    </div>
    <div class="right">
      <component class="panel" v-for="item in componentList.filter((v, i) => i % 2 != 0)" 
        :params="item.bindParam && JSON.parse(item.bindParam)"
        :isMore="item.isMore"
        :moreName="item.moreName"
        :morelink="item.morelink"
        :linkType="item.linkType"
        :icon="item.icon"
        :componetTitle="item.title"
        :height="item.maxHeight"
        page-num="1"
        :page-size="item.bindNumber"
        :base-file-path="baseFilePath"
        :is="getComps(item)" :key="item.id"></component>
    </div>
  </div>
  <!-- <el-row :gutter="20">

    <el-col v-for="item in layoutList" :span="item.span" :key="item.id">
      <info-carousel v-if="item.bindType===true && item.sounceType===1"
                     :params="JSON.parse(item.bindParam)"
                     :isMore="item.isMore"
                     :moreName="item.moreName"
                     :morelink="item.morelink"
                     :linkType="item.linkType"
                     :icon="item.icon"
                     :title="item.title"
                     :maxHeight="item.maxHeight"
                     page-num="1"
                     :page-size="item.bindNumber"
                     :base-file-path="baseFilePath"></info-carousel>

      <info-notice v-if="item.bindType===true && item.sounceType===2"
                   :params="JSON.parse(item.bindParam)"
                   :isMore="item.isMore"
                   :moreName="item.moreName"
                   :morelink="item.morelink"
                   :linkType="item.linkType"
                   :icon="item.icon"
                   :title="item.title"
                   :maxHeight="item.maxHeight"
                   page-num="1"
                   :page-size="item.bindNumber"
                   :base-file-path="baseFilePath"></info-notice>

      <info-view  v-if="item.bindType===true && item.sounceType===3"
                  :params="JSON.parse(item.bindParam)"
                  :isMore="item.isMore"
                  :moreName="item.moreName"
                  :morelink="item.morelink"
                  :linkType="item.linkType"
                  :icon="item.icon"
                  :title="item.title"
                  :maxHeight="item.maxHeight"
                  page-num="1"
                  :page-size="item.bindNumber"
                  :base-file-path="baseFilePath"></info-view>

      <info-small-carousel  v-if="item.bindType===true && item.sounceType===4"
                            :params="JSON.parse(item.bindParam)"
                            :isMore="item.isMore"
                            :moreName="item.moreName"
                            :morelink="item.morelink"
                            :linkType="item.linkType"
                            :icon="item.icon"
                            :title="item.title"
                            :maxHeight="item.maxHeight"
                            page-num="1"
                            :page-size="item.bindNumber"
                            :base-file-path="baseFilePath"></info-small-carousel>

      <info-todo v-if="item.bindType===true && item.sounceType===5 && isUserLogin"
                 :isMore="item.isMore"
                 :moreName="item.moreName"
                 :morelink="item.morelink"
                 :linkType="item.linkType"
                 :icon="item.icon"
                 :title="item.title"
                 :maxHeight="item.maxHeight"
                 page-num="1"
                 :page-size="item.bindNumber"></info-todo>

      <info-link  v-if="item.bindType===true && item.sounceType===6"
                  :isMore="item.isMore"
                  :moreName="item.moreName"
                  :morelink="item.morelink"
                  :linkType="item.linkType"
                  :icon="item.icon"
                  :title="item.title"
                  :maxHeight="item.maxHeight"
                  page-num="1"
                  :page-size="item.bindNumber"
                  :base-file-path="baseFilePath" height="215px"></info-link>

      <info-app v-if="item.bindType===true && item.sounceType===7 && isUserLogin"
                :isMore="item.isMore"
                :moreName="item.moreName"
                :morelink="item.morelink"
                :linkType="item.linkType"
                :icon="item.icon"
                :title="item.title"
                :maxHeight="item.maxHeight"
                page-num="1"
                :page-size="item.bindNumber"></info-app>

      <info-seashells  v-if="item.bindType===true && item.sounceType===8"
                  :params="JSON.parse(item.bindParam)"
                  :isMore="item.isMore"
                  :moreName="item.moreName"
                  :morelink="item.morelink"
                  :linkType="item.linkType"
                  :icon="item.icon"
                  :title="item.title"
                  :maxHeight="item.maxHeight"
                  page-num="1"
                  :page-size="item.bindNumber"
                  :base-file-path="baseFilePath"></info-seashells>

      <info-banker  v-if="item.bindType===true && item.sounceType===9"
                       :params="JSON.parse(item.bindParam)"
                       :isMore="item.isMore"
                       :moreName="item.moreName"
                       :morelink="item.morelink"
                       :linkType="item.linkType"
                       :icon="item.icon"
                       :title="item.title"
                       :maxHeight="item.maxHeight"
                       page-num="1"
                       :page-size="item.bindNumber"
                       :base-file-path="baseFilePath"></info-banker>
      <info-login :height="item.maxHeight" v-if="item.bindType === true && item.sounceType === 10"></info-login>


      <info-iframe v-if="(item.bindType===null||item.bindType===false) && item.externalType===1"
                   :isMore="item.isMore"
                   :moreName="item.moreName"
                   :url="item.intenetlink"
                   :morelink="item.morelink"
                   :linkType="item.linkType"
                   :icon="item.icon"
                   :title="item.title"
                   :maxHeight="item.maxHeight"></info-iframe>

    </el-col>
  </el-row> -->
</template>

<script>
  import InfoCarousel from "@/views/components/subportal/infoCarousel";
  import InfoNotice from "@/views/components/subportal/infoNotice";
  import InfoSmallCarousel from "@/views/components/subportal/infoSmallCarousel";
  import InfoSeashells from "@/views/components/subportal/InfoSeashells";
  import InfoLink from "@/views/components/subportal/infoLink";
  import InfoView from "@/views/components/subportal/infoView";
  import InfoIframe from "@/views/components/subportal/infoIframe";
  import InfoTodo from "@/views/components/subportal/infoTodo";
  import InfoApp from "@/views/components/subportal/infoApp";
  import InfoBanker from "@/views/components/subportal/InfoBanker";
  import InfoLogin from "@/views/components/subportal/InfoLogin";

  import {getConfigKey} from "@/api/home/config";
  import {getToken} from "@/utils/auth";
  import {get} from "@/api/subportal/index";
  import $ from 'jquery';
  import scrollUtils from '@/utils/scroll'
  import { on, off } from '@/utils/event'
  export default {
    props: ['templeteId', 'layoutList'],
    name: 'oldsubportalIndex',
    components: {
      InfoCarousel,
      InfoNotice,
      InfoLink,
      InfoView,
      InfoIframe,
      InfoSmallCarousel,
      InfoSeashells,
      InfoBanker,
      InfoTodo,
      InfoApp,
      InfoLogin
    },
    mounted:function(){
      console.warn(this.layoutList)
      this.scroller = scrollUtils.getScrollEventTarget(this.$el)
      this.handler(true)
      // if(this.templeteId===undefined){
      //   this.msgWarning("访问门户不存在")
      //   return
      // }
      // this.get(this.templeteId);//需要触发的函数
      
    },
    beforeDestroy() {
      this.handler(false)
    },
    watch: {
      layoutList: {
        handler() {
          this.componentList = this.layoutList.filter(m => !!this.getComps(m))
          this.$nextTick(() => {
            this.scrollToTop('init')
            this.scrollToTop()
          })
        },
        immediate: true
      }
    },
    created() {
      getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
    },
    computed: {
      isUserLogin() {
        if (getToken()) {
          return true;
        }
        return false;
      }
    },
    data() {
      return {
        loading: true,
        baseFilePath: undefined,
        componentList: []
        // layoutList: [],
      }
    },
    methods: {
      getComps (item) {
        switch (item.sounceType) {
          case 1:
            if (item.bindType) {
              return 'InfoCarousel'  
            } else {
              return null
            }
          case 2:
            if (item.bindType && ((item.bindParam.includes('1009') && this.isUserLogin) || (!item.bindParam.includes('1009')))) {
              return 'InfoNotice'  
            } else {
              return null
            }
          case 3:
            if (item.bindType) {
              return 'InfoView'  
            } else {
              return null
            }
          case 4:
            if (item.bindType) {
              return 'InfoSmallCarousel'  
            } else {
              return null
            }
          case 5:
            if (item.bindType && this.isUserLogin) {
              return 'infoTodo'  
            } else {
              return null
            }
          case 6:
            if (item.bindType && this.isUserLogin) {
              return 'InfoLink'  
            } else {
              return null
            }
          case 7:
            if (item.bindType && this.isUserLogin) {
              return 'InfoApp'  
            } else {
              return null
            }
          case 8:
            if (item.bindType) {
              return 'InfoSeashells'  
            } else {
              return null
            }
          case 9:
            if (item.bindType) {
              return 'InfoBanker'  
            } else {
              return null
            }
          case 10:
            if (item.bindType && !this.isUserLogin) {
              return 'InfoLogin'  
            } else {
              return null
            }
          default:
            if (!item.bindType && item.externalType === 1) {
              return 'InfoIframe'
            } else {
              return null
            }
        }
      },
      // get(templeteId) {
      //   console.log(templeteId)
      //   this.loading=true;
      //   if ((templeteId === 'loginPostTemplate' || templeteId === 'loginPreTemplate') && sessionStorage.getItem('subportal_layout')) {
      //     this.layoutList = JSON.parse(sessionStorage.getItem('subportal_layout'));
      //     this.loading=false;
      //     return
      //   }
      //   get(templeteId).then(response => {
      //     this.loading=false;
      //     if (response.code === 200) {
      //       if(response.data!==undefined) {
      //         if(response.data.subLayout!==null) {
      //           if(response.data.subLayout.layout!==null) {
      //             this.layoutList = response.data.subLayout.layout;
      //           }
      //         }
      //       }
      //     }else {
      //       if(response.msg===null){
      //         this.msgWarning("访问门户不存在")
      //       }else {
      //         this.msgWarning(response.msg)
      //       }
      //     }

      //   });
      // }
      handler (bind) {
      /* istanbul ignore else */
        if (this.binded !== bind) {
          this.binded = bind
          if (bind) {
            on(this.scroller, 'scroll', this.scrollToTop)
          } else {
            off(this.scroller, 'scroll', this.scrollToTop)
          }
        }
      },
      convertToArray (nodes) {
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
      scrollToTop(init) {
      // 获取视窗高度
      var domHight = this.scroller.offsetHeight;
      // dom滚动位置
      var scrollTop = this.scroller.scrollTop;
      // 获取监听元素
      var scrollHeight;
      // 获取监听元素距离视窗顶部距离
      var offsetTop;
      // 获取监听元素距离顶部高度-窗口高度 
      var top;
      // 元素距离底部的高度+元素本身高度
      var bottom;
      this.convertToArray(document.getElementsByClassName(`panel`)).map((id, i) => {
        scrollHeight = id.scrollHeight;
        offsetTop = id.offsetTop + 56;
        top = offsetTop - domHight > 0 ? offsetTop - domHight : 0;
        bottom = scrollHeight + offsetTop;
        // 页面滚动位置 > 元素距离顶部高度-窗口高度 && 页面滚动位置 < 元素距离顶部高度+元素本身高度
        if (scrollTop >= top && scrollTop <= bottom) {
          console.log('元素出现在可视区: ' + (i + 1));
          if(!id.className.includes('active')){
             if(typeof init === 'string' && !id.className.includes('init')){
              id.className += ' init' 
            } else{
             id.className += ' active' 
            }
          }
        } else {
          console.log('元素不在了: ' + (i + 1));
        }
      });
    },

    }
  }
</script>

<style lang="scss" scoped>  
  .subportal-wrapper{
    width: 100%;
    display: flex;
    .left{
      width: 801px;
      >div{
        margin-bottom: 16px;
        border-radius: 4px;
        &.init{
          transform: translateX(-100px);
           &.active{
            transform: translateX(0);
          }
        }
      }
    }
    .right{
      width: 383px;
      padding-left: 16px;
      >div{
        margin-bottom: 16px;
        border-radius: 4px;
        &.init{
          transform: translateX(100px);
           &.active{
            transform: translateX(0);
          }
        }
      }
    }
  }
  .panel{
    opacity: 0;
    transform: translateY(50px);

    &.active{
      transition: all 1s;
      opacity: 1;
      transform: translateY(0);
    }
  }
  /* .alr{
    min-height: 100px;
    background: #ddd;
    margin-bottom: 20px;
  } */
</style>
