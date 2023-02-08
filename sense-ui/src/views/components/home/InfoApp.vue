<template>
  <div class="process">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img src="@/assets/images/home/icon_news_process.png" width="20" height="20" alt="">
        <span>常用应用</span>
      </div>
      <div class="publicTitleMore">
        <router-link to='#'>
          <span @click="showMore">更多
          	<i class="el-icon-arrow-right"></i>
          </span>
        </router-link>
      </div>
    </div>

    <div class="processMian" v-if="dataList.length==0" style="height:197px">
        <div class="emptyData">
            <img src="@/assets/images/empty.png" alt="">
            <p>暂无相关内容</p>
        </div>
     </div>
		<div class="processMian" style="min-height: 247px" v-if="dataList.length!=0">
      <ul>
        <li v-for="(item,index) in dataList" @click="sso(item.ssoLink)" v-if="index < 8" :key='index'>
          <div :title="item.appName">
						<img v-if="item.imgLink!=null && item.imgLink!=undefined && item.imgLink!=''" :src="item.imgLink" alt="" width="32" height="32">
						<img v-else src="@/assets/images/home/app_temp.png" alt="" width="32" height="32">
            <div class="icondiv">{{ item.appName }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import $ from "jquery";
import {findApp} from "@/api/home/iam";

export default {
  name: "InfoApp",
  data() {
    return {
      dataList: []
    }
  },
  created() {
    this.init();
  },
  methods: {
    init() {
      findApp({
        common: 1
      }).then(res => {
        if (res.code == 200) {
          this.dataList = res.data;
        }
      })
		},
		showMore() {
      window.open('/home/moreApp')
    },
    sso(url) {
      window.open(url);
    }
  }
}
</script>

<style scoped>
	.icondiv{
		width: 100%;
		overflow: hidden;
		white-space: nowrap;
		text-overflow: ellipsis;
		-webkit-box-sizing: border-box;
		box-sizing: border-box;
		height: 21px;
		font-size: 12px;
		text-align: center;
	}
  p{
    margin-top: 0!important;
  }
</style>
