<!-- 社会招聘卡片 -->
<template>
  <div class="scrollTriangle arrow-panel" :id="id" :style="(isFixed && ('position: fixed'))" v-show="showScrollTip">
    <span class="arrow-bottom arrow-bottom1"></span>
    <span class="arrow-bottom arrow-bottom2"></span>
    <span class="arrow-bottom arrow-bottom3"></span>
</div>
</template>

<script>
import Props from '@/mixins/props'
export default {
  name: 'scrollTriangle',
  mixins: [Props],
  components: {
  },
  data () {
    return {
      showScrollTip: false,
      id: this.data.id,
      scrollEl: this.data.scrollEl,
      isFixed: this.data.scrollEl === this.data.parentEl
    }
  },
  mounted () {
    this.init()
  },
  destroyed () {
  },
  beforeDestroy () {
    document.onclick = null
    window.removeEventListener('resize', this.handlerScrollDetail)
    this.data.scrollEl.removeEventListener('scroll', this.handlerScrollDetail)
  },
  methods: {
    init () {
      window.addEventListener('resize', this.handlerScrollDetail)
      this.data.scrollEl.addEventListener('scroll', this.handlerScrollDetail)
      document.onclick = () => {
        this.handlerScrollDetail('1')
      }
      this.handlerScrollDetail()
    },
    handlerScrollDetail (isClick) {
      this.scrollDetail(this.data.scrollEl, isClick === '1')
    },
    scrollDetail (m, isClick) {
      console.log(this.data.parentEl.clientHeight)
      if (!this.data.parentEl.clientHeight) {
        return
      }
      const target = m.target || m
      const timer = setTimeout(() => {
        clearTimeout(timer)
        if (!this.data.parentEl.clientHeight) {
          return
        }
        this.$nextTick(() => {
          if (target.scrollHeight - 10 <= target.clientHeight + target.scrollTop) {
            // 判断是否滚动到底部， 关闭底部滚动提示
            this.showScrollTip = false
          } else {
            this.showScrollTip = true
          }
        })
      }, isClick && this.data.scrollEl.clientHeight ? 500 : 0)
    }
  }
}
</script>

<style lang="scss" scoped>
.arrow-panel{
    position: absolute;
    bottom: 10px;
    width: 100%;
  }
  @keyframes buling {
    0%{
      opacity: 1;
    }
    60%{
      opacity: .33;
    }

    100%{
      opacity: .66;
    }
  }
  @for $i from 1 through 3 {
    .arrow-bottom#{$i} {
      bottom: 16px * $i;
      animation: buling 0.9s ease-in-out -0.3s * $i infinite;
    }
  }
  .arrow-bottom{
    display: inline-block;
    border-style: solid;
    border-width: 2px 2px 0 0;
    border-color: rgba(#2272DE, 0.8);
    height: 10px;
    width: 10px;
    // margin:50px auto 0;
    transform: rotate(135deg);
    transform-origin: center center;
    position: absolute;
    right: 28px;
  }
</style>
