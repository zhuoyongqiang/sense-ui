<template>
  <div class="loading-wrapper" :class="[type, color]" :style="data.style">
    <span :class="type">
      <i v-for="(item, itemIndex) in (type === 'spinner' ? 12 : 0)" :key="itemIndex" />
      <svg v-if="type === 'circular'" class="circular" viewBox="25 25 50 50">
        <circle cx="50" cy="50" r="20" fill="none" />
      </svg>
    </span>
  </div>
</template>
<script>
// Loading不需要组件注册
import Props from '@/mixins/props'
export default {
  mixins: [Props],
  computed: {
    type () {
      return this.data.type || 'circular'
    },
    color () {
      return this.data.color
    }
  }
}
</script>
<style lang="scss" src="./loading.scss" scoped>
</style>
