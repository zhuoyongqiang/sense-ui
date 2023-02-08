<template>
  <div class="home" v-loading="loading">
    <sub-portal-index :layoutList="layoutList"></sub-portal-index>
    <!-- 弹窗广告 -->
    <info-advertisement v-if="addAdvertisingSwitch && advertingStatus" :dialog="addAdvertisingSwitch && advertingStatus"></info-advertisement>
  </div>
  <!-- <div class="home" v-else-if="onload && !layoutList.length ">
    <el-row :gutter="20">
      <el-col :span="16">
        <el-row>
          <info-carousel :params="{isCarousel:'1'}" page-num="1" page-size="5" height="360px" width="780px"
                         :base-file-path="baseFilePath"></info-carousel>
        </el-row>
        <el-row v-if="isUserLogin">
          <info-todo></info-todo>
        </el-row>
        <el-row>
          <info-view :icon="require('@/assets/images/home/icon_news_party.png')"
                     title="党建之窗"
                     :params="{newsTypeId:'1002'}" page-num="1" page-size="6" height="210px"
                     :base-file-path="baseFilePath"></info-view>
        </el-row>
        <el-row>
          <info-view :icon="require('@/assets/images/home/icon_news_neologism.png')" title="奋进新语"
                     :params="{newsTypeId:'1003'}" page-num="1" page-size="6" height="210px"
                     :base-file-path="baseFilePath"></info-view>
        </el-row>
        <el-row>
          <info-view :icon="require('@/assets/images/home/icon_news_business.png')" title="业务集萃"
                     :params="{newsTypeId:'1004'}" page-num="1" page-size="6" height="210px"
                     :base-file-path="baseFilePath"></info-view>
        </el-row>
        <el-row v-if="isUserLogin">
          <info-view :icon="require('@/assets/images/home/icon_news_supervise.png')" title="党风政风监督曝光平台"
                     :params="{newsTypeId:'1008'}" page-num="1" page-size="6" height="210px"
                     :base-file-path="baseFilePath"></info-view>
        </el-row>
      </el-col>
      <el-col :span="8">

        <el-row v-if="!isUserLogin">
          <info-login></info-login>
        </el-row>

        <el-row v-if="isUserLogin">
          <info-notice :icon="require('@/assets/images/home/icon_news_notice.png')" title="通知公告"
                               :params="{newsTypeId:'1009'}" page-num="1" page-size="8" height="360px"
                               :base-file-path="baseFilePath"></info-notice>
        </el-row>
        <el-row v-if="isUserLogin">
          <info-link :icon="require('@/assets/images/home/icon_news_process.png')" title="快捷流程"
                     page-num="1" page-size="8"
                     :base-file-path="baseFilePath" height="215px"></info-link>
        </el-row>
        <el-row v-if="isUserLogin">
          <info-app></info-app>
        </el-row>
        <el-row>
          <info-banker :icon="require('@/assets/images/home/icon_news_banker.png')" title="青年银行家"
                       :params="{newsTypeId:'1005'}" height="215px" page-num="1" page-size="5"
                       :base-file-path="baseFilePath"></info-banker>
        </el-row>
        <el-row>
          <info-small-carousel :icon="require('@/assets/images/home/icon_news_finance.png')" title="智慧金融"
                               :params="{newsTypeId:'1006'}" page-num="1" page-size="5"
                               height="215px"
                               :base-file-path="baseFilePath"></info-small-carousel>
        </el-row>
        <el-row>
          <info-notice :icon="require('@/assets/images/home/icon_news_seashells.png')" title="机构风采"
                           height="300px"
                          :params="{newsTypeId:'1007'}" page-num="1" page-size="3"
                          :base-file-path="baseFilePath"></info-notice>
        </el-row>
      </el-col>
    </el-row>
  </div> -->
</template>

<script>
import store from "@/store";
import $ from 'jquery';
import SubPortalIndex from "@/views/components/subportal/index";

import InfoAdvertisement from '@/views/components/subportal/InfoAdvertisement'
import InfoCarousel from "@/views/components/home/InfoCarousel";
import InfoWindow from "@/views/components/home/InfoWindow";
import InfoFlag from "@/views/components/home/InfoFlag";
import InfoSmallCarousel from "@/views/components/home/InfoSmallCarousel";
import InfoSeashells from "@/views/components/home/InfoSeashells";
import InfoBanker from "@/views/components/home/InfoBanker";
import InfoLink from "@/views/components/home/InfoLink";
import {getConfigKey, loginPreTemplate, loginPostTemplate} from "@/api/home/config";
import {get} from "@/api/subportal/index";
import InfoTodo from "@/views/components/home/InfoTodo";
import InfoWelcome from "@/views/components/home/InfoWelcome";
import InfoLogin from "@/views/components/home/InfoLogin";
import InfoApp from "@/views/components/home/InfoApp";
import {getToken} from "@/utils/auth";
import InfoView from "@/views/components/home/infoView";
import InfoNotice from "@/views/components/home/infoNotice";
import Cookies from "js-cookie";
export default {
  name: 'home',
  components: {
    SubPortalIndex,
    InfoView,
    InfoLink,
    InfoBanker,
    InfoSeashells,
    InfoSmallCarousel,
    InfoFlag,
    InfoWindow,
    InfoCarousel,
    InfoTodo,
    InfoWelcome,
    InfoLogin,
    InfoApp,
    InfoNotice,
    InfoAdvertisement
  },
  props: ['welcome', 'login'],
  data() {
    return {
      templeteId:undefined,
      layoutList: [],
      baseFilePath: undefined,
      loading: false ,// 接口请求标识，防止接口请求未完成时，无模板id的逻辑优先出现
      addAdvertisingSwitch:false,
      //每天第一次登录显示
      advertingStatus:false
    }
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2')
  },
  beforeDestroy() {		//在页面销毁之前移除body的属性，目的是设置的颜色只对当前页面有效
    document.querySelector('body').removeAttribute('style')
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  mounted () {
    // 初始化布局
    this.setLayout()
    // if (this.isUserLogin) {
    //   loginPostTemplate().then(resp => {
    //     this.templeteId = resp.data.subLayout.templateId
    //     Cookies.set("subportal_templeteId", resp.data.subLayout.templateId);
    //     sessionStorage.setItem('subportal_layout', JSON.stringify(resp.data.subLayout.layout))
    //   }).catch((err) => {
    //     console.warn('loginPostTemplate请求失败,', err)
    //   })
    //   // const subportal_templeteId = Cookies.get("subportal_templeteId");
    //   // //登录后和绑定门户不能与空，则绑定跳转模板
    //   // if(subportal_templeteId && this.isUserLogin){
    //   //   this.templeteId = subportal_templeteId;
    //   // }
    // } else {
    //   loginPreTemplate().then(response => {
    //     this.templeteId = response.data.subLayout.templateId
    //     Cookies.set("subportal_templeteId", response.data.subLayout.templateId);
    //     sessionStorage.setItem('subportal_layout', JSON.stringify(response.data.subLayout.layout))
    //   }).catch((err) => {
    //     console.warn('loginPreTemplate请求失败,', err)
    //   })
    // }

  },
  created() {
    getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
    });
    getConfigKey('adverting_switch').then(response => {
      if(response.msg && response.msg==='true'){
        this.addAdvertisingSwitch=true;
      }else{
        this.addAdvertisingSwitch=false;
      }
    });
    //设置用户今天第一天登录
    var date= window.localStorage.getItem('adverting');
    var isRead=window.localStorage.getItem('advertingRead');
    //今天已经显示并且勾选了我已查看则不在显示广告弹窗
    if(isRead!=null && isRead=='true'  && date!=null &&  new Date(date).toDateString() === new Date().toDateString()){
      this.advertingStatus=false;
    }else{
      this.advertingStatus=true
    }
    if(date==null || !(new Date(date).toDateString() === new Date().toDateString())){
      window.localStorage.setItem('adverting',new Date());
      window.localStorage.setItem('advertingRead',false);
    }
  },
  methods: {
    async setLayout () {
      this.loading = true
      try {
        if (this.isUserLogin) {
        
          // 登录状态下，判断cookie中是否已有模板标识（登录信息里自带模板id
          // 已有模板标识的情况下从cookie中读取
          // 没有模板标识的情况下，请求登录后模板接口
          if (Cookies.get("subportal_templeteId")) {
            this.templeteId = Cookies.get("subportal_templeteId")
            console.log(this.templeteId);
            const respTemp = await get(this.templeteId)
            this.layoutList = respTemp.data.subLayout.layout
            this.loading = false
          } else {
            const resploginPostT = await loginPostTemplate()
            this.templeteId = resploginPostT.data.subLayout.templateId
            this.layoutList = resploginPostT.data.subLayout.layout && resploginPostT.data.subLayout.layout
            this.loading = false
          }
        } else {
          // 没有登录的情况下，请求登录前模板接口
          const resploginPreT = await loginPreTemplate()
          this.templeteId = resploginPreT.data.subLayout.templateId
          this.layoutList = resploginPreT.data.subLayout.layout && resploginPreT.data.subLayout.layout
          this.loading = false
        }
      } catch (err) {
        // 当接口存在异常，或不存在模板标识时，默认渲染静态模板布局
        console.log('请求模板失败，', err)
        this.loading = false
        if (this.isUserLogin) {
          // 登录后默认模板
          this.layoutList = [
            {
              // 幻灯片
              id: 1,
              span:24,
              sounceType: 1,
              bindType: true,
              bindParam: JSON.stringify({isCarousel:'1'}),
              pageNum: 1,
              pageSize: 5,
              baseFilePath: this.baseFilePath
            },
            {
              // 常用流程模板
              id: 2,
              sounceType: 6,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAADVklEQVRYCe1ZTWgTQRR+s/mpTepBQWvQgygUREOhIHgq9V6924tCQRA8eNKLPVUEvYgehYJezF1trxYvWoRCUREURNASf6CiqY35Xefb9bmTpLOZ7CQkBx8sO3n7vjffvJl583YjSMruG1sHyvXKTdcVU0RuBrr+icgL4S4nncTljSupT8IjV6usuZJn/0i19iyINpKxxLjjRW7AyIEuAgZujj+trSMYBA24Of1fc2GhcDOS4GBLvBv0zo0n6Ky8juyJee7efKvR/bUK3ZOXrYj09R9yPUaT0bSghdPDNHVw+3Euf6jS7MMiffkVuQuymuIwchgyiMPGRiITxLRy5Mo1l+ae/KbDdwrehTZ0ENjANqpEJog1xzL/tES3npe9qcR0og0di2rLOtN7ZILZUX9DoKMHL1s3g6pTbU2JsV3HBOURRNdODtGOOFpmAltgzBGB344JzsuOLp0YCjzI1kw2mG5+0KwDBthOZfv8oPFyaizeQg6mc5N+xzytIMc61RVIrqzX6NHbqqoObRvnwbiM9er5ETq0yw86chyEd7Kul2a799/rNHF3k6p1HaJRbzzFiB6TK5RcurBY9JIwE2h06//iRA1bYCDwAV+mYkxweixYZ7dXSvTxp+ullencFl1cKtKL9Sptll3vQhs6PEPagS0wLKov1unuxkOZ2BeMZfFd4xrCmdvu3AXm6qRPQ/WlI8b6oFfWaO6ZnYEp1lGnomJUX+38BL2GWOKoGlZivTST6uj4Ah4YFvgyPf5Cd7FttWKLx4BCI2hbrdjiQwliCjjHRalWbPG8HLQRVCuQKNWKLb4tQS7fYchHGIOadaot26i6KHj2o40gG5jck7Lyyu51KC1zOS60oeuGKMmj0R1efI7v9x/j8EcRqoparSRjgp7NjqiPG9rt8OhLJ1qCeCtjglyZ8FTpqhVdJ+3w6EsnoXnw8ZnUv52sc/Bajv7VV1mhyKOQT4h8oU6rn+t0TE710b+vojo8Cgqc2TrRRhAAvDKG5TKuVnSvlaaJWkcO+tAIMhA5DWmDd2anL+Y2eCOCTLQf966kmV4S/0/QNroygiJv66R3eJF38MG6dx3YeQY3B1/T8cHazlX30eAEbg4+9eNruhCUG4zpxt8QlAMncPsDwNagMmxyuZQAAAAASUVORK5CYII=',
              bindType: true,
              isMore: true,
              morelink: '/home/commonLink',
              linkType: 2
            },
            {
              // 待办模板
              id: 4,
              sounceType: 5,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAACI0lEQVRYCe2ZO0sDQRDHZzfRQE6DBgnGB6JiYSEBtRYLtfEDGLUSQb+BdnYK8YOYykYRAjZBECsRKwtBFIWISHyAkZjHupPjmouaubu95IRME26Zmf3tf/aWvQkDaeFEru+rXNgVgk0DiCiONc5YhjGRbuUtG9nN4AOrwJUKl0JyNg6qemYGkG31tcR4RTmPwSEuCoZsXC9r9Qq8MIJsvPF77i8pRFQCetuagE7r01TQrKA832AkTNeF7mmeycZzbzuD8zUNLtbbIDETIGXwk7wUOCFcalmDwU5dk/Goj5S1Lgqa4fJFAdsneW8A/gQX3/+E9F1JHWBEY3C6osHZqgYTFs723+COb4okOHQilXhu2A+xbh+MRXxwuKjBZE/t/aMCjgyYui7C00e5supQgMFBPPgnpCo4MuDzp4D5vRwJUiUcGRAdr57LNSFVw1kCrAXpBhzOybSdN3l5tWajXRyOloIQ0fR37D0v4EVug4EO/RnPOTxKrLytvxGQ3mJz8E/ldgMO57UFiIFmSBxTqRzmQ7MNiMEG5OVjCW5fy7Cwn1NSVsxtmK09aATX49eRgk1AqYCl++DskB/6Q3gntm/378LSPiUDItzWFO0WTMGnnpGe34NkBY0Ve7bEWDYDklJCVT6eL3ET0Gmp/4OCLON0le7FswzHhrV7EzjLjGwcu+nYsHaWSn10pYku2Ti2+rGbzhgk5ReAB8qNf0NAEpmQ7Rupov5bYgzkYQAAAABJRU5ErkJggg==',
              bindType: true,
              isMore: true,
              morelink: '/home/moreTodo',
              linkType: 2
            },
            {
              // 常用应用模板
              id: 5,
              sounceType: 7,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAADVklEQVRYCe1ZTWgTQRR+s/mpTepBQWvQgygUREOhIHgq9V6924tCQRA8eNKLPVUEvYgehYJezF1trxYvWoRCUREURNASf6CiqY35Xefb9bmTpLOZ7CQkBx8sO3n7vjffvJl583YjSMruG1sHyvXKTdcVU0RuBrr+icgL4S4nncTljSupT8IjV6usuZJn/0i19iyINpKxxLjjRW7AyIEuAgZujj+trSMYBA24Of1fc2GhcDOS4GBLvBv0zo0n6Ky8juyJee7efKvR/bUK3ZOXrYj09R9yPUaT0bSghdPDNHVw+3Euf6jS7MMiffkVuQuymuIwchgyiMPGRiITxLRy5Mo1l+ae/KbDdwrehTZ0ENjANqpEJog1xzL/tES3npe9qcR0og0di2rLOtN7ZILZUX9DoKMHL1s3g6pTbU2JsV3HBOURRNdODtGOOFpmAltgzBGB344JzsuOLp0YCjzI1kw2mG5+0KwDBthOZfv8oPFyaizeQg6mc5N+xzytIMc61RVIrqzX6NHbqqoObRvnwbiM9er5ETq0yw86chyEd7Kul2a799/rNHF3k6p1HaJRbzzFiB6TK5RcurBY9JIwE2h06//iRA1bYCDwAV+mYkxweixYZ7dXSvTxp+ullencFl1cKtKL9Sptll3vQhs6PEPagS0wLKov1unuxkOZ2BeMZfFd4xrCmdvu3AXm6qRPQ/WlI8b6oFfWaO6ZnYEp1lGnomJUX+38BL2GWOKoGlZivTST6uj4Ah4YFvgyPf5Cd7FttWKLx4BCI2hbrdjiQwliCjjHRalWbPG8HLQRVCuQKNWKLb4tQS7fYchHGIOadaot26i6KHj2o40gG5jck7Lyyu51KC1zOS60oeuGKMmj0R1efI7v9x/j8EcRqoparSRjgp7NjqiPG9rt8OhLJ1qCeCtjglyZ8FTpqhVdJ+3w6EsnoXnw8ZnUv52sc/Bajv7VV1mhyKOQT4h8oU6rn+t0TE710b+vojo8Cgqc2TrRRhAAvDKG5TKuVnSvlaaJWkcO+tAIMhA5DWmDd2anL+Y2eCOCTLQf966kmV4S/0/QNroygiJv66R3eJF38MG6dx3YeQY3B1/T8cHazlX30eAEbg4+9eNruhCUG4zpxt8QlAMncPsDwNagMmxyuZQAAAAASUVORK5CYII=',
              bindType: true,
              isMore: true,
              morelink: '/home/moreApp',
              linkType: 2
            },
            {
              // 下载中心模板
              id: 6,
              sounceType: 3,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '下载中心',
              bindParam: JSON.stringify({newsTypeId:'1003'}),
              isMore: true,
              morelink: '/home/window/1003',
              linkType: 2
            },
            {
              // 通知公告模板
              id: 7,
              sounceType: 2,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEHUlEQVRYCe2YX2wUdRDHP3tX2tIWCpWClArUBlAUhfAvEP40ATExSIy8IARqjA+8QHwwJCY8kBgeMEAMDxJNgEACGCHxgTcxcOGfAiKgIUSoUKAFIxQKBWnhjnPm1r3b3ds9ym4vPRIn2duZ2Znf77vz+/1m5tZAKLlpai2JxBfCNZBkqOp6jQxugBEjGl1lrDzeYqTAxRNnBVxVr4HynNi4TVH0zch/kSswcIpYAiarGkktq+cbFIIy2RDp9T2XKw5yHiSChU3/Awy7PkVhB0j79+kL05bDq+/A3+fhh8/hwc3046BMzyxx3Qxo3AMTl0DZQBg5HeZ8FhSTwy9cBMskfTZ8CmPmOQZNCS/UZeu8NFVi13XfN9rBAb62AGZ9AqX9M9M+fgi61CkyMno7Fy2G4VNAo14/CyoGQ2cH7FoKd1vslik+N8AR02DwGCmNrp2gE7w0yTnYuX1wdi8s3u7Uq1RSAaPmwsszBdxUeYlSp01pPxjyyjMCnLECJjc6B/KS2uWtf1wL105CZW22RWklfCCgB3g8U+uH7fD793DxQLavaPwj+MZCT4e08kkcTu2En76BRFdancWUV2eDa7sMlw7B5cNw/Teptk+y3CyFP8DicssGjm8VPpmRldM3vvmHU+cltTVBbD3UypZo+UWAHfFcSi9X1fkDtHsc+8ouPTt/+lvQKwC5dn+AEfLs0r0IhgVRIqloUH12NrDGvXNF8uAtS3Lc8w9QT3HjXrPCOKa2CXE5ZLuWQdufNqXJ5n+J+72YG5ziKCoBn8qT/wjqST+6WRL05KzopBW35KQ3xdKinck/QJ3txBbzss/cTT7/S9xNIH5m3Ytg/WzJ065E3fqr2YX4jWzX6ynuL3tRlzJH1bC7WLw/wMQjc/Oq5YINln3mfl/SwkH5r98kFSUXFVdIA7HDLHdad5uPmWWu+Wd4JG3WU8gf4CWpk6Pn+rtXDIJ3FWAMDqzz7eeorMnU4r4DzI5bu+6E1PLW0ybYC/t982B0zds1azxRNB+FuESxS3q1O1flkmRqXRqV4jLTrWokvP6eudz3WmHCIlPfeQ/OSHn7p036vbtQPUp8bPU9Itu/cpjZfY+dbwLVCLvISG6c6NpcLgsvUQHOlHZs3PtSHYyMhXYpVj7TNmybALdTtfSW2hPqNWSs03ffKs/tEgygNWnNeHhrNWgU3eQF0G5TLltEu2ptYDtuwOFN9qdpPhxAHSbaB6Z8JM3thyZvDd16Br772JIC32UjhKTEY2lav4ad8o9OQSl1/AWHvjT5kL/hI+gGoLVXN3u80/0kkOyfZgINJ04avR6k8Evcg2C8hnoOAKa+CXthLwCdYJMIGrECgOIDwYhF9Gu6gLztY9GLasEk2CL6qV+/pkvJ2k0hLLdiUCyCSbH9CyRBDPZeS+FOAAAAAElFTkSuQmCC',
              bindType: true,
              title: '通知公告',
              bindParam: JSON.stringify({newsTypeId:'1009'}),
              isMore: true,
              morelink: '/home/window/1009',
              linkType: 2
            },
            {
              // 党建之窗模板
              id: 9,
              sounceType: 3,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEBElEQVRYCe2Ya2xURRSAv7stWiQ1IiAtLUgUAghBoSAmBSw/1CDKSwJRIUQ0+gd+EBK0hJQ2hbQi0WCIqYma6I+SQATCM4CRJkRSHkkDIUp42UJLC0h5Bmhtu56z0+Wyy9179/aRXRNOsndn58zjm3PmnJm9FiLBqbOzaWlbi0UewWCm1iVMLKueIBWkBpZbe7bUWiG41rbjAvZswqCcJrasRlICL6eGLEeSwSmwGky8Ggi51WkFyVAnWy6Q8D3nZgiJh4CbPhl0jwE764Xus2DGczB3NvTr2ynG7gNsuAKHKmH9l/D+nA5Ddh+gItVegm/L4KP5sGwJWJZv0FTfPcId1HVTJsOZs9C3D9y6DYePhbX2d+VR+HU7vDcd0p6E0m+gtdXWe5Q6Bqhw61ZDZoY9/L7fnQG1xY+/yGImwesT4VojlP1k9/Mo+XexE1z9Zfh6Q+ypWlpgz36jn/kODH0xdtsojT9AdeVXxZGW0wHr6qCtLWroqJ+79xnXBmTKeRLdcYo/wMJ8GOBwGxv7CkwY5z7l1X/g3N+mTe5r0KuXe/t2rT/AQ4ftQW/fAf2oqFUKPveG1NSjkpICo0eassfTH2D5ZvheNvi2nfDBIvjwYzjSHrk9ehjIV3NiT3nlqq17fpBddin5A9SBNGV89wM0NcP9JigqhWNVZgqFXPUFxIK8025xbf3M06aPx9M/YPSA/0qEFpZA1XGjcYPs3dvufe++XXYpdR5QB28WaxasgRMnzVQhd4slx0e5e/hQG+XyQ+62ax8pdQ2gDqsuXykp6OSfZpIn2t2dJ8lZZeTwyPxXW2fqPZ5W8I0ZQY82/tQ906CkEF4SoLCcPQ/ZWeao0zoNlgWf6v+OcIuY3/FZcLBEXO6EmINEKHRvrSiCmot29ZAXbDit3X8gLjhtGh/g0sUSnZKkP1locp72dJO796BYrllO0iSRv323k8axLj7ATVtM57mz5JIgwTB+rONgEZWavJ1ELwvXbzhpHOviu800yGUgLKNGwJoCqG+AXXslvZyAi7UmJ6bJ/svKhBw5+ma9G+4R+a1H5bS3TN9IjeMvb0A9MxfLho4WvWqpyzsiSz6DGzfhj0rP3t6A+UslRYjVVP46DRUHxcVjxEryieeGrBbe+5vcdiRi9Wad2d/sY110lwAOzDZw1RcgfxVoAGzdARky0dtvmmNNy0/1NO00itX9p2Qx23ZBdY2p16eeNkUrYMQw+LncrncpeedBTRFjRoPemG/eij1UerrcUiQw1HVuosGjC7pU79bqgc4b8EHTxBRkOcktjwE765//gQX1nXCyirDJC0wqkpVP2QL6Nl1OBDnBk0yUSdgC+qpf36bLubVRQBPv7hCDsAiTsv0HWNwLiQCqJcIAAAAASUVORK5CYII=',
              bindType: true,
              title: '党建之窗',
              bindParam: JSON.stringify({newsTypeId:'1002'}),
              isMore: true,
              morelink: '/home/window/1002',
              linkType: 2
            },
            {
              // 机构风采模板
              id: 8,
              sounceType: 2,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEB0lEQVRYCe1YS0gVYRT+5t6bD3ykUlJpmr0MepqVRVYSaLVIgjYFFS7b1KJFq6KgIIgwaFObFi16EEVQC6kwzIow0DKwBz2tK1mZRmller2dz/Fnpjvj3Lld4s7CAzPzP8/55rz+M6NBKHyiLB+h0FFpVSCMyRxLGGn4AGgN8Pv3arubgtowuMFQq4DLSRgoW8FaNwL+hb4RzXkMHBGLwsSqvmGz2r6BFwbDFb6E+5yTHiQeRIPepjGA8donEBeD9FxgxhqgqBzIygfSJurs+j4DX4PAm7vAq9tA76d/FqOFa0vDMe9OmwCs2AnM3Qj4/M7bh0JA2zXg/imgr8t5rc1s7ACnrwY2HAKS0mzYOQz97gPq9gOvGx0WWadiA7hoC1CxR04iU2y9ewA8vwF0PDRMSdPnlQDFVUDBMkNqeAhoqAUeXTDGorTcA6Tmqo8Z4HreATcPC7AWZxF5i4HKfUB2gb6OIO+dBJ7VAd87nffKrDuA9Lmay4ZZg6Ktq6LJ/u9RBQwvSM6QlxPN5YtWzfT1vR5EzWfFPyWwbMhkK5tZNcSAUD5HzcUCjjz4ItzT90Vx1J9ZU4HSbcCOi5INKv6eG+lFB0h/YrQqolndak7t4ZN7mk4bI2FT8kgRDa87CKRkGfMjregAGRgqlTAgovmcRYRpoFU0RR4kTQNazgFdr/R+cjowa63eNt1HB+hPBqoOAEu2G8sZrfGSmUfOdGBo0ODInBlBgYi+3k3NBjYdBybN+3uaqSReMvPIlwgPJOkcB34CL29ZuNtrcL0k4khw3BrHkWWRzAEFjv44im9bNVi4HJgmF4kqpwkCYu64SPytsEyCrRqYGeFn1Fz9EUn2120lWAHmzjEWvhCV586WJFuojzGie9qNeacWcydPk6KVejGRao1QDPwCzkqaceBpBdj10hBbXAn8+mb0Wbm0XgIGhTEjm4GUIaAzp+jXeHmOz5OXkpfMdPFxGGx2BEfBVoAskZgK1BmakmkAXLUb4PUv1CsnxYt68e25wOT5OgfKikJWgNxwRUCU7wIWbAbGpURhMco0fauzDQi2SF14B/j4VEwuUVuyRd9A/2atGIXsATIwGiXNMPPTrEtrgJwRP2TE8cAnhQaAnz3Aj249wrvfArzoJrzCAkIRz2MWDYpYI7rICvYAFZN+8b8nwqj9vlEs8AToeBzbeayKBVXRsDZkAeuC7PNg5EZWwiw2leZYlWw9o5sscm1kn2blWlXJkAd5uayu3ZVbSqinC1YF0tMlvwLp6Y8mBZJPz352mkH+57a7KP7PIJzYjwF00o6bOR+G/wm7WZqANYJNTKw1JEC0S5Fag49/0wWknPZeI8Ek2Hz81c+/6fIZeN4T5qbLEYtgIrY/i89hudORdPQAAAAASUVORK5CYII=',
              bindType: true,
              title: '机构风采',
              bindParam: JSON.stringify({newsTypeId:'1007'}),
              isMore: true,
              morelink: '/home/window/1007',
              linkType: 2
            },
            {
              // 业务集萃模板
              id: 10,
              sounceType: 3,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '业务集萃',
              bindParam: JSON.stringify({newsTypeId:'1004'}),
              isMore: true,
              morelink: '/home/window/1004',
              linkType: 2
            },
            {
              // 智慧金融
              id: 12,
              sounceType: 2,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '智慧金融',
              bindParam: JSON.stringify({newsTypeId:'1006'}),
              isMore: true,
              morelink: '/home/window/1006',
              linkType: 2
            },
            {
              // 青年银行家
              id: 11,
              sounceType: 3,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAADRklEQVRYCd1ZTWgTQRR+s8mmbZKDClKD4u9BFGxB8eDBmmtBFBTBH0RB8OhF0FO9CIKCCPUmCHrQgAVRETxaetGTkIiKF39QiEGolsZo87fOt3G6Q7OZnc7mDz9YZvrmzXvfvvfmTdgy4lh1tbSuXK9ccxyWJnJSkPUOLM+YMx2z7AuzF+NfmUuuVsk6nGfvSDV7ZkSzsYg9armR6zNyoIuAgZvVSGvzG/SDBNys3tecKhROihPsb0TbQe/0qE2n+LNtdcQ19+57je5mK3SHP2HBElfmeD2aYTjB6PaBIUpv9H/P6U9VOvPkNxV+GbugUClWkcMrgzh0wsCYINIqIleuOTTx/A9tmZx3H8whA6ADXVMYE0TNCVyeWaAbL8tuKpFOzCETkHWFTHc0JigOBBzdf918GGSZrKtLTOgZE0zG+GX0D36HQJbJumKP7mhMUNdBWL3/l2Cx7PU29MOlkGWy7lK9oL+NI4jbQuD4Du9E+8lkXbGuO/pfARq7cZXtXtvYPjE24O4QJxeEhQwL0DVFqKvu6bH4YrNuRQDX3f5MqdVyoNw4xbCMexYEWkHcxa3WdeShIigc9O2vGUGwk+OyDkmUF8SR7TYd3Bql0eEIrUkysiPNLUYmXOE/Gr4VHcoWavT4fZWm3laoWpc11HPtFKc3RGhyfIg2rwxVtvThR53OPeO1+9lrUyqKWt5Ojtj06Gg8NDkQwQvCFmzqIDDFiNzN8UGKWo1UlioOXX+xQDM8AkhbKaDFxTkPlMMYt3N+zwDFbebags0vc/XASCpTjJp7dTa5GLkcJ3TiYYk+/vSuOZ0oCJ1NKxjdOxSnEU4YQLp33ioqa1KZYhwIUXOIXBhyIIQXgw3YAmAbPlRQEsRpFUBaTSMnbGCEDdgSkH0ImTwqCaJ2BFBz7YJsS/bhZ98Lkc8q+pzA3vUR2pXyCAu5yZiIebtkH57UmykJyk340r5Bb1cbZ7IPP7PKFOfnl9Hy/axryIJ8KCN4eKrknjK0m04AV96DN+pGqiSYK9QpV/BOXCdIBtnsUGyC3Oqvc4Isr6/ebU2Wt/DButtudf2Bm4Wv6bzbzepu6pYeOIGbhU/9+JrOGGX6I934NwRlwAnc/gIjVC3NmbgHugAAAABJRU5ErkJggg==',
              bindType: true,
              title: '青年银行家',
              bindParam: JSON.stringify({newsTypeId:'1005'}),
              isMore: true,
              morelink: '/home/window/1005',
              linkType: 2
            },
            {
              // 党风党政监督曝光平台
              id: 12,
              sounceType: 2,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEBElEQVRYCe2Ya2xURRSAv7stWiQ1IiAtLUgUAghBoSAmBSw/1CDKSwJRIUQ0+gd+EBK0hJQ2hbQi0WCIqYma6I+SQATCM4CRJkRSHkkDIUp42UJLC0h5Bmhtu56z0+Wyy9179/aRXRNOsndn58zjm3PmnJm9FiLBqbOzaWlbi0UewWCm1iVMLKueIBWkBpZbe7bUWiG41rbjAvZswqCcJrasRlICL6eGLEeSwSmwGky8Ggi51WkFyVAnWy6Q8D3nZgiJh4CbPhl0jwE764Xus2DGczB3NvTr2ynG7gNsuAKHKmH9l/D+nA5Ddh+gItVegm/L4KP5sGwJWJZv0FTfPcId1HVTJsOZs9C3D9y6DYePhbX2d+VR+HU7vDcd0p6E0m+gtdXWe5Q6Bqhw61ZDZoY9/L7fnQG1xY+/yGImwesT4VojlP1k9/Mo+XexE1z9Zfh6Q+ypWlpgz36jn/kODH0xdtsojT9AdeVXxZGW0wHr6qCtLWroqJ+79xnXBmTKeRLdcYo/wMJ8GOBwGxv7CkwY5z7l1X/g3N+mTe5r0KuXe/t2rT/AQ4ftQW/fAf2oqFUKPveG1NSjkpICo0eassfTH2D5ZvheNvi2nfDBIvjwYzjSHrk9ehjIV3NiT3nlqq17fpBddin5A9SBNGV89wM0NcP9JigqhWNVZgqFXPUFxIK8025xbf3M06aPx9M/YPSA/0qEFpZA1XGjcYPs3dvufe++XXYpdR5QB28WaxasgRMnzVQhd4slx0e5e/hQG+XyQ+62ax8pdQ2gDqsuXykp6OSfZpIn2t2dJ8lZZeTwyPxXW2fqPZ5W8I0ZQY82/tQ906CkEF4SoLCcPQ/ZWeao0zoNlgWf6v+OcIuY3/FZcLBEXO6EmINEKHRvrSiCmot29ZAXbDit3X8gLjhtGh/g0sUSnZKkP1locp72dJO796BYrllO0iSRv323k8axLj7ATVtM57mz5JIgwTB+rONgEZWavJ1ELwvXbzhpHOviu800yGUgLKNGwJoCqG+AXXslvZyAi7UmJ6bJ/svKhBw5+ma9G+4R+a1H5bS3TN9IjeMvb0A9MxfLho4WvWqpyzsiSz6DGzfhj0rP3t6A+UslRYjVVP46DRUHxcVjxEryieeGrBbe+5vcdiRi9Wad2d/sY110lwAOzDZw1RcgfxVoAGzdARky0dtvmmNNy0/1NO00itX9p2Qx23ZBdY2p16eeNkUrYMQw+LncrncpeedBTRFjRoPemG/eij1UerrcUiQw1HVuosGjC7pU79bqgc4b8EHTxBRkOcktjwE765//gQX1nXCyirDJC0wqkpVP2QL6Nl1OBDnBk0yUSdgC+qpf36bLubVRQBPv7hCDsAiTsv0HWNwLiQCqJcIAAAAASUVORK5CYII=',
              bindType: true,
              title: '党风党政监督曝光平台',
              bindParam: JSON.stringify({newsTypeId:'1008'}),
              isMore: true,
              morelink: '/home/window/1008',
              linkType: 2
            },
          ]
        } else {
          // 未登录前默认模板
          this.layoutList = [
            {
              // 幻灯片
              id: 1,
              sounceType: 1,
              bindType: true,
              bindParam: JSON.stringify({isCarousel:'1'}),
              pageNum: 1,
              pageSize: 5,
              baseFilePath: this.baseFilePath
            },
            {
              // 登录模板
              id: 2,
              sounceType: 10,
              bindType: true
            },
            {
              // 奋进新语模板
              id: 3,
              sounceType: 3,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '奋进新语',
              bindParam: JSON.stringify({newsTypeId:'1003'}),
              isMore: true,
              morelink: '/home/window/1003',
              linkType: 2
            },
            {
              // 机构风采模板
              id: 4,
              sounceType: 2,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEB0lEQVRYCe1YS0gVYRT+5t6bD3ykUlJpmr0MepqVRVYSaLVIgjYFFS7b1KJFq6KgIIgwaFObFi16EEVQC6kwzIow0DKwBz2tK1mZRmller2dz/Fnpjvj3Lld4s7CAzPzP8/55rz+M6NBKHyiLB+h0FFpVSCMyRxLGGn4AGgN8Pv3arubgtowuMFQq4DLSRgoW8FaNwL+hb4RzXkMHBGLwsSqvmGz2r6BFwbDFb6E+5yTHiQeRIPepjGA8donEBeD9FxgxhqgqBzIygfSJurs+j4DX4PAm7vAq9tA76d/FqOFa0vDMe9OmwCs2AnM3Qj4/M7bh0JA2zXg/imgr8t5rc1s7ACnrwY2HAKS0mzYOQz97gPq9gOvGx0WWadiA7hoC1CxR04iU2y9ewA8vwF0PDRMSdPnlQDFVUDBMkNqeAhoqAUeXTDGorTcA6Tmqo8Z4HreATcPC7AWZxF5i4HKfUB2gb6OIO+dBJ7VAd87nffKrDuA9Lmay4ZZg6Ktq6LJ/u9RBQwvSM6QlxPN5YtWzfT1vR5EzWfFPyWwbMhkK5tZNcSAUD5HzcUCjjz4ItzT90Vx1J9ZU4HSbcCOi5INKv6eG+lFB0h/YrQqolndak7t4ZN7mk4bI2FT8kgRDa87CKRkGfMjregAGRgqlTAgovmcRYRpoFU0RR4kTQNazgFdr/R+cjowa63eNt1HB+hPBqoOAEu2G8sZrfGSmUfOdGBo0ODInBlBgYi+3k3NBjYdBybN+3uaqSReMvPIlwgPJOkcB34CL29ZuNtrcL0k4khw3BrHkWWRzAEFjv44im9bNVi4HJgmF4kqpwkCYu64SPytsEyCrRqYGeFn1Fz9EUn2120lWAHmzjEWvhCV586WJFuojzGie9qNeacWcydPk6KVejGRao1QDPwCzkqaceBpBdj10hBbXAn8+mb0Wbm0XgIGhTEjm4GUIaAzp+jXeHmOz5OXkpfMdPFxGGx2BEfBVoAskZgK1BmakmkAXLUb4PUv1CsnxYt68e25wOT5OgfKikJWgNxwRUCU7wIWbAbGpURhMco0fauzDQi2SF14B/j4VEwuUVuyRd9A/2atGIXsATIwGiXNMPPTrEtrgJwRP2TE8cAnhQaAnz3Aj249wrvfArzoJrzCAkIRz2MWDYpYI7rICvYAFZN+8b8nwqj9vlEs8AToeBzbeayKBVXRsDZkAeuC7PNg5EZWwiw2leZYlWw9o5sscm1kn2blWlXJkAd5uayu3ZVbSqinC1YF0tMlvwLp6Y8mBZJPz352mkH+57a7KP7PIJzYjwF00o6bOR+G/wm7WZqANYJNTKw1JEC0S5Fag49/0wWknPZeI8Ek2Hz81c+/6fIZeN4T5qbLEYtgIrY/i89hudORdPQAAAAASUVORK5CYII=',
              bindType: true,
              title: '机构风采',
              bindParam: JSON.stringify({newsTypeId:'1007'}),
              isMore: true,
              morelink: '/home/window/1007',
              linkType: 2
            },
            {
              // 党建之窗模板
              id: 5,
              sounceType: 3,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAEBElEQVRYCe2Ya2xURRSAv7stWiQ1IiAtLUgUAghBoSAmBSw/1CDKSwJRIUQ0+gd+EBK0hJQ2hbQi0WCIqYma6I+SQATCM4CRJkRSHkkDIUp42UJLC0h5Bmhtu56z0+Wyy9179/aRXRNOsndn58zjm3PmnJm9FiLBqbOzaWlbi0UewWCm1iVMLKueIBWkBpZbe7bUWiG41rbjAvZswqCcJrasRlICL6eGLEeSwSmwGky8Ggi51WkFyVAnWy6Q8D3nZgiJh4CbPhl0jwE764Xus2DGczB3NvTr2ynG7gNsuAKHKmH9l/D+nA5Ddh+gItVegm/L4KP5sGwJWJZv0FTfPcId1HVTJsOZs9C3D9y6DYePhbX2d+VR+HU7vDcd0p6E0m+gtdXWe5Q6Bqhw61ZDZoY9/L7fnQG1xY+/yGImwesT4VojlP1k9/Mo+XexE1z9Zfh6Q+ypWlpgz36jn/kODH0xdtsojT9AdeVXxZGW0wHr6qCtLWroqJ+79xnXBmTKeRLdcYo/wMJ8GOBwGxv7CkwY5z7l1X/g3N+mTe5r0KuXe/t2rT/AQ4ftQW/fAf2oqFUKPveG1NSjkpICo0eassfTH2D5ZvheNvi2nfDBIvjwYzjSHrk9ehjIV3NiT3nlqq17fpBddin5A9SBNGV89wM0NcP9JigqhWNVZgqFXPUFxIK8025xbf3M06aPx9M/YPSA/0qEFpZA1XGjcYPs3dvufe++XXYpdR5QB28WaxasgRMnzVQhd4slx0e5e/hQG+XyQ+62ax8pdQ2gDqsuXykp6OSfZpIn2t2dJ8lZZeTwyPxXW2fqPZ5W8I0ZQY82/tQ906CkEF4SoLCcPQ/ZWeao0zoNlgWf6v+OcIuY3/FZcLBEXO6EmINEKHRvrSiCmot29ZAXbDit3X8gLjhtGh/g0sUSnZKkP1locp72dJO796BYrllO0iSRv323k8axLj7ATVtM57mz5JIgwTB+rONgEZWavJ1ELwvXbzhpHOviu800yGUgLKNGwJoCqG+AXXslvZyAi7UmJ6bJ/svKhBw5+ma9G+4R+a1H5bS3TN9IjeMvb0A9MxfLho4WvWqpyzsiSz6DGzfhj0rP3t6A+UslRYjVVP46DRUHxcVjxEryieeGrBbe+5vcdiRi9Wad2d/sY110lwAOzDZw1RcgfxVoAGzdARky0dtvmmNNy0/1NO00itX9p2Qx23ZBdY2p16eeNkUrYMQw+LncrncpeedBTRFjRoPemG/eij1UerrcUiQw1HVuosGjC7pU79bqgc4b8EHTxBRkOcktjwE765//gQX1nXCyirDJC0wqkpVP2QL6Nl1OBDnBk0yUSdgC+qpf36bLubVRQBPv7hCDsAiTsv0HWNwLiQCqJcIAAAAASUVORK5CYII=',
              bindType: true,
              title: '党建之窗',
              bindParam: JSON.stringify({newsTypeId:'1002'}),
              isMore: true,
              morelink: '/home/window/1002',
              linkType: 2
            },
            {
              // 业务集萃模板
              id: 6,
              sounceType: 2,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '业务集萃',
              bindParam: JSON.stringify({newsTypeId:'1004'}),
              isMore: true,
              morelink: '/home/window/1004',
              linkType: 2
            },
            {
              // 青年银行家
              id: 7,
              sounceType: 3,
              icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAADRklEQVRYCd1ZTWgTQRR+s8mmbZKDClKD4u9BFGxB8eDBmmtBFBTBH0RB8OhF0FO9CIKCCPUmCHrQgAVRETxaetGTkIiKF39QiEGolsZo87fOt3G6Q7OZnc7mDz9YZvrmzXvfvvfmTdgy4lh1tbSuXK9ccxyWJnJSkPUOLM+YMx2z7AuzF+NfmUuuVsk6nGfvSDV7ZkSzsYg9armR6zNyoIuAgZvVSGvzG/SDBNys3tecKhROihPsb0TbQe/0qE2n+LNtdcQ19+57je5mK3SHP2HBElfmeD2aYTjB6PaBIUpv9H/P6U9VOvPkNxV+GbugUClWkcMrgzh0wsCYINIqIleuOTTx/A9tmZx3H8whA6ADXVMYE0TNCVyeWaAbL8tuKpFOzCETkHWFTHc0JigOBBzdf918GGSZrKtLTOgZE0zG+GX0D36HQJbJumKP7mhMUNdBWL3/l2Cx7PU29MOlkGWy7lK9oL+NI4jbQuD4Du9E+8lkXbGuO/pfARq7cZXtXtvYPjE24O4QJxeEhQwL0DVFqKvu6bH4YrNuRQDX3f5MqdVyoNw4xbCMexYEWkHcxa3WdeShIigc9O2vGUGwk+OyDkmUF8SR7TYd3Bql0eEIrUkysiPNLUYmXOE/Gr4VHcoWavT4fZWm3laoWpc11HPtFKc3RGhyfIg2rwxVtvThR53OPeO1+9lrUyqKWt5Ojtj06Gg8NDkQwQvCFmzqIDDFiNzN8UGKWo1UlioOXX+xQDM8AkhbKaDFxTkPlMMYt3N+zwDFbebags0vc/XASCpTjJp7dTa5GLkcJ3TiYYk+/vSuOZ0oCJ1NKxjdOxSnEU4YQLp33ioqa1KZYhwIUXOIXBhyIIQXgw3YAmAbPlRQEsRpFUBaTSMnbGCEDdgSkH0ImTwqCaJ2BFBz7YJsS/bhZ98Lkc8q+pzA3vUR2pXyCAu5yZiIebtkH57UmykJyk340r5Bb1cbZ7IPP7PKFOfnl9Hy/axryIJ8KCN4eKrknjK0m04AV96DN+pGqiSYK9QpV/BOXCdIBtnsUGyC3Oqvc4Isr6/ebU2Wt/DButtudf2Bm4Wv6bzbzepu6pYeOIGbhU/9+JrOGGX6I934NwRlwAnc/gIjVC3NmbgHugAAAABJRU5ErkJggg==',
              bindType: true,
              title: '青年银行家',
              bindParam: JSON.stringify({newsTypeId:'1005'}),
              isMore: true,
              morelink: '/home/window/1005',
              linkType: 2
            },
            {
              // 智慧金融
              id: 8,
              sounceType: 2,
              icon: 'data:image/png;base64,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',
              bindType: true,
              title: '智慧金融',
              bindParam: JSON.stringify({newsTypeId:'1006'}),
              isMore: true,
              morelink: '/home/window/1006',
              linkType: 2
            }
          ]
        }
        
        this.onload = true
      }
    },
    _isMobile() {
      let flag = navigator.userAgent.match(/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i)
      return flag;
    }
  }
}
</script>

<style lang="scss" scoped>
  @import '../../assets/styles/home/home.scss';
  @import '../../assets/styles/home/common.scss';
  .home{
    min-height: 100vh;
  }
  
</style>

