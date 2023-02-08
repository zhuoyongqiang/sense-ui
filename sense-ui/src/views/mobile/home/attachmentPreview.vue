<template>
  <div class="attachmentPreview-wrapper">
    <div class="iframe-panel">
      <iframe id="iframepage" width="100%" height="100%" :src="url" frameborder="0"></iframe>
    </div>
  </div>
</template>
<script>
export default {
  name: 'attachmentPreview',
  data() {
    return {
      url: ''
    }
  },
  beforeCreate() {
    document.title = '文档预览'
    document.querySelector('body').setAttribute('style', 'overflow: hidden')
    document.getElementById("view").setAttribute('content','user-scalable=yes, width=device-width, minimum-scale=1, initial-scale=1, maximum-scale=3');
  },
  created() {
    if (sessionStorage.getItem('setiFrame')) {
      return
    }
    this.url = this.changeURL(sessionStorage.getItem('attach'))
  },
  beforeDestroy() {
     document.querySelector('body').removeAttribute('style')
     document.getElementById("view").setAttribute('content','width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no');
     sessionStorage.removeItem('setiFrame')
  },
  mounted() {
  },
  methods: {
    changeURL (url) {
      sessionStorage.setItem('setiFrame', '1')
      var reg = /^http(s)?:\/\/(.*?)\//
      // 'https://xib03.test.xib.com.cn:8501'
      var ToReplace = document.location.origin + '/attachmentPreview/'
      return url.replace(reg, ToReplace)
    }
  },
}
</script>
<style lang="scss">
  .attachmentPreview-wrapper{
    overflow: hidden;
    height: 100%;
    .iframe-panel{
      overflow: hidden;
      height: 100%;
    }
  }
</style>
