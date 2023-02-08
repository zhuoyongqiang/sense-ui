<template>
  <div class="process">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title }}</span>
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
        <li v-for="(item,index) in dataList" @click="jump(item.url)" v-if="index < 8" :key='index'>
          <div :title=item.name>
            <img :src="'data:image/png;base64,'+item.image" alt="" width="32" height="32">
            <div class="icondiv">{{ item.name }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {selectByUserList} from "@/api/home/commonLink";

export default {
  name: "InfoLink",
  props: ['icon', 'title', 'params', 'pageNum', 'pageSize'],
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
      let data = this.params;
      if (!data) {
        data = {};
      }
      data.pageNum = this.pageNum;
      data.pageSize = this.pageSize;
      selectByUserList(data).then(response => {
        this.dataList = response;
      });
    },
    showMore() {
      window.open('/home/commonLink')
    },
    jump(url) {
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
</style>
