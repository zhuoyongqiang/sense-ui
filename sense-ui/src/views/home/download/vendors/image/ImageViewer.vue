<template>
  <viewer :images="images" style="height: 100%;">
    <el-image v-for="item in images" alt="图片" :src="item.src" fit="cover" :key="item.index"  />
  </viewer>
</template>

<script>
export default {
  name: 'ImageViewer',
  props: {
    image: String,
  },
  computed: {
    images() {
      return this.image ? [{ src: this.image }] : [];
    }
  }
}
</script>

<style scoped>
.image {
  display: block;
  width: auto;
  height: 100%;
  margin: 0 auto;
}
</style>
