<template>
  <div class="home">
    <el-row :gutter="20">
      <el-col :span="16">
        <el-row>
          <!--首页导航查询条件首页是否轮播设置-->
          <info-carousel :params="{isCarousel:'1'}" page-num="1" page-size="5" height="360px" width="780px"
                         :base-file-path="baseFilePath"></info-carousel>
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
      </el-col>
      <el-col :span="8">
        <el-row>
          <info-notice :icon="require('@/assets/images/home/icon_news_notice.png')" title="通知公告"
                       :params="{newsTypeId:'1009'}" page-num="1" page-size="8" height="360px"
                       :base-file-path="baseFilePath"></info-notice>
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
          <info-seashells :icon="require('@/assets/images/home/icon_news_seashells.png')" title="机构风采"
                          :params="{newsTypeId:'1007'}" page-num="1" page-size="3"
                          :base-file-path="baseFilePath"></info-seashells>
        </el-row>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import InfoCarousel from "@/views/components/home/InfoCarousel";
import InfoWindow from "@/views/components/home/InfoWindow";
import InfoSmallCarousel from "@/views/components/home/InfoSmallCarousel";
import InfoSeashells from "@/views/components/home/InfoSeashells";
import InfoBanker from "@/views/components/home/InfoBanker";
import {getConfigKey} from "@/api/home/config";
import {getToken} from "@/utils/auth";
import InfoView from "@/views/components/home/infoView";
import InfoNotice from "@/views/components/home/infoNotice";

export default {
  name: 'home',
  components: {
    InfoView,
    InfoBanker,
    InfoSeashells,
    InfoSmallCarousel,
    InfoWindow,
    InfoCarousel,
    InfoNotice
  },
  props: ['welcome', 'login'],
  data() {
    return {
      baseFilePath: undefined
    }
  },
  beforeCreate() {		//在页面创建之前设置body的背景色
    document.querySelector('body').setAttribute('style', 'background:#F2F2F2')
  },
  beforeDestroy() {		//在页面销毁之前移除body的属性，目的是设置的颜色只对当前页面有效
    document.querySelector('body').removeAttribute('style')
  },
  mounted: function () {

  }
  ,
  created() {
    getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
    });
  }
  ,
  methods: {
    _isMobile() {
      let flag = navigator.userAgent.match(/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i)
      return flag;
    }
  }
}
</script>

<style lang="scss" scoped>
  @import '../../assets/styles/home/home.css';
  @import '../../assets/styles/home/common.css';
</style>