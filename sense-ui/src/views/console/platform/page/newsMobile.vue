<template>
  <div class="mobileNews">
    <p class="newsTitle">{{ infoNews ? infoNews.title : '' }}</p>
    <ul>
      <li>{{ infoNews ? infoNews.effectTime : '' }}</li>
      <li>{{ infoNews ? infoNews.issuer : '' }}</li>
      <li>0次浏览</li>
    </ul>
    <div class="newsMain" v-html="infoNews?infoNews.content:''"></div>
  </div>
</template>

<script>

export default {
  name: "mobileNews",
  props: ['infoNews', 'clientHeight']
}
</script>


<style scoped>
.mobileNews {
  text-align: left;
  padding: 0 6px;
}

.newsTitle {
  font-size: 24px;
  font-weight: 600;
  margin-top: 6px;
  color: #333333;
}

.newsMain {
  font-weight: 500;
  color: #333333;
  font-size: 16px;
  margin: 6px 0;
  line-height: 1.7;
}

.newsMain >>> img {
  width: 100% !important;
  height: auto !important;
}

.mobileNews ul li {
  display: inline-block;
  margin: 6px 6px 0 0;
  font-size: 12px;
  color: #8F9193;
}

.mobileNews ul li > i {
  margin-right: 3px;
}

.mobileNews ul li:last-child {
  margin-right: 0;

}

</style>
