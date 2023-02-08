<template>
  <div class="picker-column"
  :style="columnStyle"
  @touchstart="onTouchStart"
  @touchmove.prevent="onTouchMove"
  @touchend="onTouchEnd"
  @touchcancle="onTouchEnd">
  <ul :style="wrapperStyle">
    <li v-for="(option, index) in options"
    :style="optionStyle"
    class="item  ellipsis"
    :class="{disabled: isDisabled(option), selected: index === currentIndex}"
    @click="setIndex(index, true)"
    :key="index">{{getOptionText(option)}}</li>
  </ul>
  </div>
</template>
<script>
const range = (num, arr) => Math.min(Math.max(num, arr[0]), arr[1])
const DEFAULT_DURATION = 200
export default {
  props: {
    valueKey: String, // 选项对象中，文字对应的key
    className: String, // 为对应列添加额外的class
    itemHeight: Number,
    visibleItemCount: Number, // 可见的选项个数
    initialOptions: {
      type: Array,
      default: () => []
    },
    defaultIndex: {
      type: Number,
      default: 0
    }
  },
  data () {
    return {
      startY: 0, // 起始Y坐标
      offset: 0, // 偏移
      duration: 0,
      startOffset: 0, // 初始偏移
      options: this.deepClone(this.initialOptions),
      currentIndex: this.defaultIndex
    }
  },
  created () { // 初始化
    this.$parent.children && this.$parent.children.push(this)
    this.setIndex(this.currentIndex)
  },
  destroyed () { // 销毁
    this.$parent.children && this.$parent.children.splice(this.$parent.children.indexOf(this), 1)
  },
  computed: {
    count () {
      return this.options.length
    },
    baseOffset () {
      return this.itemHeight * (this.visibleItemCount - 1) / 2
    },
    columnStyle () {
      return {
        height: (this.itemHeight * this.visibleItemCount) + 'px'
      }
    },
    wrapperStyle () {
      return {
        transition: `${this.duration}ms`,
        transform: `translate3d(0, ${this.offset + this.baseOffset}px, 0)`,
        lineHeight: this.itemHeight + 'px'
      }
    },
    optionStyle () {
      return {
        height: this.itemHeight + 'px'
      }
    }
  },
  methods: {
     // 深拷贝算法
    deepClone (obj) {
      let objClone = Array.isArray(obj) ? [] : {};
      if (obj && typeof obj === 'object') {
        for(let key in obj) {
          if (obj[key] && typeof obj[key] === 'object'){
            objClone[key] = this.deepClone(obj[key]);
          } else {
            objClone[key] = obj[key]
          }
        }
      }
  　　return objClone;
    },
    onTouchStart (event) {
      this.startY = event.touches[0].clientY
      this.startOffset = this.offset
      this.duration = 0
    },
    onTouchMove (event) {
      const deltaY = event.touches[0].clientY - this.startY
      this.offset = range(this.startOffset + deltaY, [-(this.count * this.itemHeight), this.itemHeight])
    },
    onTouchEnd (event) {
      if (this.offset !== this.startOffset) {
        this.duration = DEFAULT_DURATION
        const index = range(Math.round(-this.offset / this.itemHeight), [0, this.count - 1])
        this.setIndex(index, true)
      }
    },
    adjustIndex (index) {
      index = range(index, [0, this.count])
      for (let i = index; i < this.count; i++) {
        if (!this.isDisabled(this.options[i])) return i
      }
      for (let i = index - 1; i >= 0; i--) {
        if (!this.isDisabled(this.options[i])) return i
      }
    },
    isDisabled (option) {
      return this.isObj(option) && option.disabled
    },
    getOptionText (option) {
      return this.isObj(option) && this.valueKey in option ? option[this.valueKey] : option
    },
    isObj (x) {
      const type = typeof x
      return x !== null && (type === 'object' || type === 'function')
    },
    setIndex (index, userAction) {
      index = this.adjustIndex(index) || 0
      this.offset = -index * this.itemHeight
      if (index !== this.currentIndex) {
        this.currentIndex = index
        userAction && this.$emit('change', index)
      }
    },
    setValue (value) {
      const { options } = this
      for (let i = 0; i < options.length; i++) {
        if (this.getOptionText(options[i]) === value) {
          this.setIndex(i)
        }
      }
    },
    getValue () {
      return this.options[this.currentIndex]
    }
  }
}
</script>
