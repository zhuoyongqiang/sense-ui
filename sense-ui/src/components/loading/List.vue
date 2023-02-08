<template>
  <div class="list-wrapper"
    :style="data.style"
  >
    <slot />
    <div v-show="data.loading" class="loading">
      <slot name="loading">
        <Loading :data="{color: 'black'}" />
        <span class="loading-text">{{data.loadingText || '加载中...'}}</span>
      </slot>
    </div>
    <div v-show="data.err" class="loading fail">
      <span class="loading-text">加载失败，<span class="reload" @click="reLoad">请点击重试</span></span>
    </div>
  </div>
</template>
<script>
import Props from '@/mixins/props'
import scrollUtils from '@/utils/scroll'
import { on, off } from '@/utils/event'
import Loading from './Loading'
export default {
  mixins: [Props],
  components: {
    Loading
  },
  data () {
    return {
      immediateCheck: this.data.immediateCheck == null ? true : this.data.immediateCheck,
      offset: this.data.offset || 300
    }
  },
  mounted () {
    this.scroller = scrollUtils.getScrollEventTarget(this.$el)
    this.handler(true)
    if (this.immediateCheck) {
      this.$nextTick(this.check)
    }
  },
  destroyed () {
    this.handler(false)
  },
  activated () {
    this.handler(true)
  },
  deactivated () {
    this.handler(false)
  },
  watch: {
    'data.loading' () {
      this.$nextTick(this.check)
    },
    'data.finished' () {
      this.$nextTick(this.check)
    }
  },
  methods: {
    check () {
      if (this.data.loading || this.data.finished) {
        return
      }
      const el = this.$el
      const { scroller } = this
      const scrollerHeight = scrollUtils.getVisibleHeight(scroller)
      /* istanbul ignore next */
      if (!scrollerHeight || scrollUtils.getComputedStyle(el).display === 'none' || el.offsetParent === null) {
        return
      }
      const scrollTop = scrollUtils.getScrollTop(scroller)
      const targetBottom = scrollTop + scrollerHeight
      let reachBottom = false
      /* istanbul ignore next */
      if (el === scroller) {
        reachBottom = scroller.scrollHeight - targetBottom < this.offset
      } else {
        const elBottom =
          scrollUtils.getElementTop(el) -
          scrollUtils.getElementTop(scroller) +
          scrollUtils.getVisibleHeight(el)
        reachBottom = elBottom - scrollerHeight < this.offset
      }
      /* istanbul ignore else */
      if (reachBottom) {
        this.$emit('input', true)
        this.$emit('load')
      }
    },
    handler (bind) {
      /* istanbul ignore else */
      if (this.binded !== bind) {
        this.binded = bind
        if (bind) {
          on(this.scroller, 'scroll', this.check)
        } else {
          off(this.scroller, 'scroll', this.check)
        }
        // (bind ? on : off)(this.scroller, 'scroll', this.check)
      }
    },
    reLoad () {
      this.$emit('reload')
    }
  }
}
</script>
<style lang="scss" scoped>
  .list-wrapper {
    .loading {
      text-align: center;
      margin-right: 5px;
      .loading-wrapper, .loading-text {
        display: inline-block;
        white-space: nowrap;
        vertical-align: middle;
      }
      .loading-wrapper {
        width: 16px;
        height: 16px;
        margin-right: 5px;
      }
    }
    .loading-text {
      display: inline-block;
      white-space: nowrap;
      vertical-align: middle;
      font-size: 15px;
      color: #999;
      line-height: 50px;
    }
    .reload{
      color: rgba($color: #2272DE, $alpha: .7);
      text-decoration: underline;
    }
  }
</style>
