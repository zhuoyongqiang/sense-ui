export default {
  data () {
    return {
      closeTimer: null,
      page: window.location.href
    }
  },
  methods: {
    closeWindow () {
      if (window.ghmhhistoryLength > 1) {
        this.checkclose()
        // window.history.back(-1)
        window.history.go(window.ghmhhistoryLength - history.length - 1)
      } else {
        // eslint-disable-next-line
        WeixinJSBridge.call('closeWindow')
      }
    },
    // 由于window.history.length只增不减，无法用来判断页面是否处于浏览器的最顶级记录栈，
    // 故在此放置一个延时器，延时器启动后如果页面还没被关闭，则调用关闭微信浏览器的api
    checkclose () {
      this.closeTimer = setTimeout(() => {
        clearTimeout(this.closeTimer)
        // 保险起见这里增加页面判断，防止定时器生效时页面已被移除
        if (window.location.href === this.page) {
          // eslint-disable-next-line
          WeixinJSBridge.call('closeWindow')
        }
      }, 300)
    }
  },
  deactivated () {
    this.closeTimer && clearTimeout(this.closeTimer)
  },
  beforeDestroy () {
    this.closeTimer && clearTimeout(this.closeTimer)
  }
}
