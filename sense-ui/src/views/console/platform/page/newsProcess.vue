<template>
  <div class="newsProcess">
    <p class="newsTitle">{{ infoNews ? infoNews.title : '' }}</p>
    <ul>
      <li><i class="el-icon-time"></i>发表于 {{ infoNews ? infoNews.effectTime : '' }}</li>
      <li>作者： {{ infoNews ? infoNews.issuer : '' }}</li>
      <li><i class="el-icon-view" style="margin-right:6px;"></i>0次浏览</li>
    </ul>
    <div class="newsMain" v-html="infoNews?infoNews.content:''"></div>
  </div>
</template>

<script>
export default {
  name: "newsProcess",
  props: ['infoNews']
}
</script>

<style scoped>
.newsProcess {
  text-align: left;
}

.newsTitle {
  padding: 12px 0px;
  font-size: 24px;
  font-weight: 600;
}

.newsMain {
  color: #333333;
  line-height: 32px;
  margin: 20px 0;
}
.newsMain ::v-deep img{
  max-width: 100%;
}

.newsProcess ul li {
  display: inline-block;
  margin: 12px 12px 0 0;
  font-size: 12px;
  font-weight: 500;
  color: #333333;
}
</style>
