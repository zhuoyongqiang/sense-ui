<template>
  <div class="read">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <span>{{ title }}</span>
      </div>
    </div>
    <div class="readList">
      <ul @click="showDetail(i.id)" v-for="(i,v) in dataList" :key="v">
        <li class="publicHiddenTwoLine">{{ i.title }}</li>
        <li>{{ i.effectTime }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
import {listRecommend} from "@/api/home/news";

export default {
  name: "read",
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
      listRecommend(data).then(response => {
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
.read {
  min-height: 300px;
  background: #FFFFFF;
  border-radius: 4px;
  margin-bottom: 20px;
}

.readList {
  padding: 0 20px;
}

.readList > ul {
  padding: 16px 0;
  border-bottom: 1px solid #F2F2F2;
  cursor: pointer;
}

.readList > ul:last-child {
  border: none;
}

.readList > ul:hover > li:first-child {
  color: #5B7FBF;
}

.readList > ul > li:first-child {
  font-size: 14px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.readList > ul > li:last-child {
  margin-top: 8px;
  font-size: 12px;
  color: #999999;
  letter-spacing: 0;
  font-weight: 500;
}
</style>
