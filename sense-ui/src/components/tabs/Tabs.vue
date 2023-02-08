<template>
  <div class="tabs-wrapper" :class="type">
    <div ref="wrap" :style="[data.style, wrapStyle]" class="wrap content-bottom" :class="{scrollable}">
      <div class="nav" :class="type" ref="nav">
        <div v-if="type === 'line' && tabs.length" class="indicator" :style="lineStyle"></div>
        <div v-for="(tab, tabIndex) in tabs"
          :key="tabIndex"
          ref="tabs"
          class="tab"
          :class="{active: tabIndex === curActive, disabled: tab.disabled}"
          style="{ color: red }"
          @click="onClick(tabIndex)">
          <span class="title" ref="title">{{tab.title}}</span>
          <span v-if="tab.info" class="info">{{tab.info}}</span>
        </div>
      </div>
    </div>
    <slot name="beforeContent"></slot>
    <div class="content" ref="content">
      <slot />
    </div>
  </div>
</template>
<script>
import { raf } from '@/utils/raf'
import { on, off } from '@/utils/event'
import scrollUtils from '@/utils/scroll'
import isDef from '@/utils/isDef'
import Touch from '@/mixins/touch'
import Props from '@/mixins/props'

export default {
  name: 'tabs',
  mixins: [Props, Touch],
  props: ['value'],
  data () {
    return {
      tabs: [],
      position: '',
      curActive: null,
      lineStyle: {},
      events: {
        resize: false,
        sticky: false,
        swipeable: false
      },
      type: this.data.type || 'line',
      duration: this.data.duration || 0.2,
      swipeThreshold: this.data.swipeThreshold || 4,
      offsetTop: this.data.offsetTop || 0
    }
  },
  computed: {
    active () {
      return this.value
    },
    scrollable () {
      return this.tabs.length > this.swipeThreshold
    },
    wrapStyle () {
      switch (this.position) {
        case 'top':
          return {
            top: this.offsetTop + 'px',
            position: 'fixed'
          }
        case 'bottom':
          return {
            top: 'auto',
            bottom: 0
          }
        default:
          return null
      }
    }
  },
  watch: {
    active (val) {
      if (val !== this.curActive) {
        this.correctActive(val)
      }
    },
    tabs (tabs) {
      console.warn(tabs)
      this.correctActive(this.curActive || this.active)
      this.scrollIntoView()
      this.setLine()
    },
    curActive () {
      this.scrollIntoView()
      this.setLine()
      // scroll to correct position
      if (this.position === 'page-top' || this.position === 'content-bottom') {
        scrollUtils.setScrollTop(window, scrollUtils.getElementTop(this.$el))
      }
    },
    sticky () {
      this.handlers(true)
    },
    swipeable () {
      this.handlers(true)
    }
  },
  mounted () {
    this.correctActive(this.active)
    this.setLine()
    this.$nextTick(() => {
      this.handlers(true)
      this.scrollIntoView(true)
    })
  },
  activated () {
    this.$nextTick(() => {
      this.handlers(true)
      this.scrollIntoView(true)
    })
  },
  deactivated () {
    this.handlers(false)
  },
  beforeDestroy () {
    this.handlers(false)
  },
  methods: {
    // whether to bind sticky listener
    handlers (bind) {
      const { events } = this
      const sticky = this.data.sticky && bind
      const swipeable = this.data.swipeable && bind
      // listen to window resize event
      if (events.resize !== bind) {
        events.resize = bind
        if (bind) {
          on(window, 'resize', this.setLine, true)
        } else {
          off(window, 'resize', this.setLine, true)
        }
      }
      // listen to scroll event
      if (events.sticky !== sticky) {
        events.sticky = sticky
        this.scrollEl = this.scrollEl || scrollUtils.getScrollEventTarget(this.$el)
        if (sticky) {
          on(this.scrollEl, 'scroll', this.onScroll, true)
        } else {
          off(this.scrollEl, 'scroll', this.onScroll, true)
        }
        this.onScroll()
      }
      // listen to touch event
      if (events.swipeable !== swipeable) {
        events.swipeable = swipeable
        const { content } = this.$refs
        const action = swipeable ? on : off
        action(content, 'touchstart', this.touchStart)
        action(content, 'touchmove', this.touchMove)
        action(content, 'touchend', this.onTouchEnd)
        action(content, 'touchcancel', this.onTouchEnd)
      }
    },
    // watch swipe touch end
    onTouchEnd () {
      const { direction, deltaX, curActive } = this
      const minSwipeDistance = 50
      /* istanbul ignore else */
      if (direction === 'horizontal' && this.offsetX >= minSwipeDistance) {
        /* istanbul ignore else */
        if (deltaX > 0 && curActive !== 0) {
          this.setCurActive(curActive - 1)
        } else if (deltaX < 0 && curActive !== this.tabs.length - 1) {
          this.setCurActive(curActive + 1)
        }
      }
    },
    // adjust tab position
    onScroll () {
      const scrollTop = scrollUtils.getScrollTop(window) + this.offsetTop
      const elTopToPageTop = scrollUtils.getElementTop(this.$el)
      const elBottomToPageTop = elTopToPageTop + this.$el.offsetHeight - this.$refs.wrap.offsetHeight
      if (scrollTop > elBottomToPageTop) {
        this.position = 'bottom'
      } else if (scrollTop > elTopToPageTop) {
        this.position = 'top'
      } else {
        this.position = ''
      }
    },
    // update nav bar style
    setLine () {
      this.$nextTick(() => {
        if (!this.$refs.tabs || this.type !== 'line') {
          return
        }
        const tab = this.$refs.tabs[this.curActive]
        const width = this.data.lineWidth || tab.offsetWidth
        const left = tab.offsetLeft + (tab.offsetWidth - width) / 2
        this.lineStyle = {
          width: `${width}px`,
          backgroundColor: this.data.lineColor || '#2272DE',
          transform: `translateX(${left}px)`,
          transitionDuration: `${this.duration}s`
        }
      })
    },
    // correct the value of active
    correctActive (active) {
      active = +active
      const exist = this.tabs.some(tab => tab.index === active)
      const defaultActive = (this.tabs[0] || {}).index || 0
      this.setCurActive(exist ? active : defaultActive)
    },
    setCurActive (active) {
      active = this.findAvailableTab(active, active < this.curActive)
      if (isDef(active) && active !== this.curActive) {
        this.$emit('input', active)
        if (this.curActive !== null) {
          this.$emit('change', active, this.tabs[active].title)
        }
        this.curActive = active
      }
    },
    findAvailableTab (index, reverse) {
      const diff = reverse ? -1 : 1
      while (index >= 0 && index < this.tabs.length) {
        if (!this.tabs[index].disabled) {
          return index
        }
        index += diff
      }
    },
    // emit event when clicked
    onClick (index) {
      const { title, disabled } = this.tabs[index]
      if (disabled) {
        this.$emit('disabled', index, title)
      } else {
        this.setCurActive(index)
        this.$emit('click', index, title)
      }
    },
    // scroll active tab into view
    scrollIntoView (immediate) {
      if (!this.scrollable || !this.$refs.tabs) {
        return
      }
      const tab = this.$refs.tabs[this.curActive]
      const { nav } = this.$refs
      const { scrollLeft, offsetWidth: navWidth } = nav
      const { offsetLeft, offsetWidth: tabWidth } = tab
      this.scrollTo(nav, scrollLeft, offsetLeft - (navWidth - tabWidth) / 2, immediate)
    },
    // animate the scrollLeft of nav
    scrollTo (el, from, to, immediate) {
      if (immediate) {
        el.scrollLeft += to - from
        return
      }
      let count = 0
      const frames = Math.round(this.duration * 1000 / 16)
      const animate = () => {
        el.scrollLeft += (to - from) / frames
        /* istanbul ignore next */
        if (++count < frames) {
          raf(animate)
        }
      }
      animate()
    },
    // render title slot of child tab
    renderTitle (el, index) {
      this.$nextTick(() => {
        const title = this.$refs.title[index]
        title.parentNode.replaceChild(el, title)
      })
    }
  }
}
</script>
<style lang="scss" scoped>

  .tabs-wrapper {
    position: relative;

    .wrap {
      top: 0;
      left: 0;
      right: 0;
      z-index: 99;
      overflow: hidden;
      position: absolute;

      &.scrollable {
        .tab {
          flex: 0 0 22%;
        }

        .nav {
          overflow: hidden;
          overflow-x: auto;
          -webkit-overflow-scrolling: touch;

          &::-webkit-scrollbar {
            display: none;
          }
        }
      }
    }

    .nav {
      display: flex;
      user-select: none;
      position: relative;
      background-color: #fff;

      &.line {
        height: 100%;
        padding-bottom: 15px; /* 15px padding to hide scrollbar in mobile safari */
        box-sizing: content-box;
        .indicator {
          z-index: 1;
          left: 0;
          bottom: 15px;
          height: 2px;
          position: absolute;
          background-color: transparent!important;
          &::after{
            position: absolute;
            left: 50%;
            bottom: 0;
            transform: translateX(-50%);
            width: .53rem;
            height: .11rem;
            background-color: #2272DE;
            content: '';
          }
        }
      }

      &.card {
        margin: 0 15px;
        border-radius: 2px;
        box-sizing: border-box;
        border: 1px solid #09a1f0;
        height: 30px;

        .tab {
          color: #09a1f0;
          border-right: 1px solid #09a1f0;
          line-height: 30px - 2px;

          &:last-child {
            border-right: none;
          }

          &.active {
            color: #fff;
            background-color: #2272DE;
          }
        }
      }
    }
    &.line {
      padding-top: 44px;

      .wrap {
        height: 44px;
      }
    }

    &.card {
      padding-top: 30px;

      .wrap {
        height: 30px;
      }
    }

    .content {
      min-height: 300px;
    }
  }

  .tab {
    flex: 1;
    cursor: pointer;
    padding: 0 5px;
    font-size: 14px;
    position: relative;
    color: #454545;
    line-height: 44px;
    text-align: center;
    box-sizing: border-box;
    background-color: #fff;
    min-width: 0; /* hack for flex ellipsis */

    span {
      display: block;
      color:#606266;
      font-size: .37rem;
    }
    .info {
      position: absolute;
      right: 36px;
      top: 8px;
      color: #fff;
      background: red;
      font-size: 10px;
      padding: 0 3px;
      min-width: 8px;
      height: 14px;
      line-height: 14px;
      border-radius: 7px;
    }

    &:active {
      // background-color: #008ce6;
    }

    &.active {
      .title{
        font-size: .48rem;
        font-weight: 600;
        color: #2272DE;
      }
    }

    &.disabled {
      color: grey;

      &:active {
        background-color: #fff;
      }
    }
  }

</style>
