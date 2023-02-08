<template>
  <div class="hotNews">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <span>{{ title }}</span>
      </div>
    </div>
    <div class="hotList">
      <ul>
        <li @click="showDetail(item.id)" v-for="(item,i) in dataList"><p class="publicHidden"><span>{{
            i + 1
          }}</span>{{ item.title }}</p></li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listHot} from "@/api/home/news";

export default {
  name: "hotNews",
  props: ['title', 'baseFilePath', 'params', 'pageNum', 'pageSize', 'height'],
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
      listHot(data).then(response => {
        this.dataList = response.data;
      });
    },
    showDetail(id) {
      window.open('/home/detail/' + id);
    }
  }
}
</script>

<style scoped>
.hotNews {
  min-height: 300px;
  background: #FFFFFF;
  border-radius: 4px;
  margin-bottom: 20px;
}

.hotList {
  padding: 0 20px;
}

.hotList > ul > li > p > span {
  margin-right: 12px;
  font-family: Gilroy-Bold;
  font-size: 16px;
  color: #CDD0D7;
  letter-spacing: 0;
  font-weight: 400;
}

.hotList > ul > li:nth-child(1) > p > span,
.hotList > ul > li:nth-child(2) > p > span,
.hotList > ul > li:nth-child(3) > p > span {
  color: #FF454F;
}

.hotList > ul > li > p {
  font-size: 14px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
  cursor: pointer;
  margin-top: 20px;
}
</style>
