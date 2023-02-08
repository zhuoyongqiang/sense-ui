<template>
  <div class="errNetwork">
    <img src="@/assets/images/mobile/errNetwork.png">
    <p>抱歉，网络异常，请联系系统管理员进行处理</p>
  </div>
</template>
<script>
import '@/store/REM.js'
export default {
  data() {
    return {
      
    }
  },
  created() {
    document.title = sessionStorage.title || '加载失败'
  },
  mounted() {
  },
}
</script>
<style lang="scss" scoped>
  .errNetwork{
    position: fixed;
    top: 4rem;
    left: 0;
    z-index: 10;
    width: 100%;
    text-align: center;
    img{
      width: 3.7rem;
      height: auto;
    }
    p{
      font-size: .37rem;
      color:#2B3949;
    }
  }
</style>