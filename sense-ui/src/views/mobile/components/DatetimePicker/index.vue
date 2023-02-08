<template>
  <div class="dateTimmPicker-wrapper" :class="{'hidden' : !pickerShow}" v-show="data.show" @click.self="clickTarget">
    <transition name="slide-bottom">
      <Picker
        v-show="pickerShow"
        ref="picker"
        :data="picker"
        :style="data.style"
        @change="onChange"
        @confirm="onConfirm"
        @cancel="onCancel"
      />
    </transition>
    
  </div>
</template>
<script>
import range from './range'
import Picker from './Picker'
const currentYear = new Date().getFullYear()
const isValidDate = date => Object.prototype.toString.call(date) === '[object Date]' && !isNaN(date.getTime())
export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  components: { Picker },
  data () {
    let defaultOptions = {
      value: this.data.value,
      type: this.data.type || 'datetime',
      format: this.data.format || 'YYYY.MM.DD HH时 mm分',
      formatter: typeof this.data.formatter === 'function' ? this.data.formatter : (type, value) => value,
      // minDate: isValidDate(this.data.minDate) ? this.data.minDate : () => new Date(currentYear - 3, 0, 1),
      // maxDate: isValidDate(this.data.maxDate) ? this.data.maxDate : () => new Date(currentYear + 3, 11, 31),
      minDate: isValidDate(this.data.minDate) ? this.data.minDate : new Date(currentYear - 3, 0, 1),
      maxDate: isValidDate(this.data.maxDate) ? this.data.maxDate : new Date(currentYear + 6, 11, 31),
      minHour: this.data.minHour || 0,
      maxHour: this.data.maxHour || 23,
      minMinute: this.data.minMinute || 0,
      maxMinute: this.data.maxMinute || 59
    }
    return {
      ...defaultOptions,
      innerValue: this.correctValue(this.data.value, defaultOptions),
      pickerShow: false
    }
  },

  watch: {
    value (val) {
      val = this.correctValue(val)
      const isEqual = this.type === 'time' ? val === this.innerValue : val.valueOf() === this.innerValue.valueOf()
      if (!isEqual) {
        this.innerValue = val
      }
    },
    'data.show' (val) {
      if (val) {
        this.minDate = isValidDate(this.data.minDate) ? this.data.minDate : new Date(currentYear - 3, 0, 1),
        this.innerValue = this.data.value || new Date()
        this.pickerShow = true
        this.updateColumnValue(this.innerValue)
      }
    },
    innerValue (val) {
      this.updateColumnValue(val)
      this.$emit('input', val)
    }
  },
  computed: {
    ranges () {
      if (this.type === 'time') {
        return [{
          type: 'hour',
          range: [this.minHour, this.maxHour]
        }, {
          type: 'minute',
          range: [this.minMinute, this.maxMinute]
        }]
      }
      const { maxYear, maxDate, maxMonth, maxHour, maxMinute } = this.getBoundary('max', this.innerValue)
      const { minYear, minDate, minMonth, minHour, minMinute } = this.getBoundary('min', this.innerValue)
      const result = [{
        type: 'year',
        range: [minYear, maxYear]
      }, {
        type: 'month',
        range: [minMonth, maxMonth]
      }, {
        type: 'day',
        range: [minDate, maxDate]
      }, {
        type: 'hour',
        range: [minHour, maxHour]
      }, {
        type: 'minute',
        range: [minMinute, maxMinute]
      }]
      if (this.type === 'date') result.splice(3, 2)
      if (this.type === 'year-month') result.splice(2, 3)
      return result
    },
    columns () {
      const results = this.ranges.map(({ type, range }) => {
        const values = this.times(range[1] - range[0] + 1, index => {
          let value = range[0] + index
          value = value < 10 ? `0${value}` : `${value}`
          return this.formatter(type, value)
        })
        return {
          values
        }
      })
      return results
    },
    picker () {
      return {
        viewId: this.data.viewId,
        compId: this.data.compId + '-picker',
        title: this.data.title,
        columns: this.columns,
        itemHeight: this.data.itemHeight,
        showToolbar: this.data.showToolbar == null ? true : this.data.showToolbar,
        visibleItemCount: this.data.visibleItemCount,
        confirmButtonText: this.data.confirmButtonText,
        cancelButtonText: this.data.cancelButtonText
      }
    }
  },
  methods: {
    clickTarget (event) {
      console.log(event)
      this.onCancel()
    },
    pad (val) {
      return `00${val}`.slice(-2)
    },
    correctValue (value, defaultOptions) {
      let vm = defaultOptions == null ? this : defaultOptions
      // validate value
      const isDateType = vm.type !== 'time'
      if (isDateType && !isValidDate(value)) {
        value = vm.minDate
      } else if (!value) {
        const { minHour } = vm
        value = `${minHour > 10 ? minHour : '0' + minHour}:00`
      }
      // time type
      if (!isDateType) {
        let [hour, minute] = value.split(':')
        hour = this.pad(range(hour, vm.minHour, vm.maxHour))
        minute = this.pad(range(minute, vm.minMinute, vm.maxMinute))
        return `${hour}:${minute}`
      }
      // date type
      const { maxYear, maxDate, maxMonth, maxHour, maxMinute } = this.getBoundary('max', value, defaultOptions)
      const { minYear, minDate, minMonth, minHour, minMinute } = this.getBoundary('min', value, defaultOptions)
      const minDay = new Date(minYear, minMonth - 1, minDate, minHour, minMinute)
      const maxDay = new Date(maxYear, maxMonth - 1, maxDate, maxHour, maxMinute)
      value = Math.max(value, minDay)
      value = Math.min(value, maxDay)
      return new Date(value)
    },
    times (n, iteratee) {
      let index = -1
      const result = Array(n)
      while (++index < n) {
        result[index] = iteratee(index)
      }
      return result
    },
    getBoundary (type, value, defaultOptions) {
      let vm = defaultOptions == null ? this : defaultOptions
      const boundary = vm[`${type}Date`]
      const year = boundary.getFullYear()
      let month = 1
      let date = 1
      let hour = 0
      let minute = 0
      if (type === 'max') {
        month = 12
        date = this.getMonthEndDay(value.getFullYear(), value.getMonth() + 1)
        hour = 23
        minute = 59
      }
      if (value.getFullYear() === year) {
        month = boundary.getMonth() + 1
        if (value.getMonth() + 1 === month) {
          date = boundary.getDate()
          if (value.getDate() === date) {
            hour = boundary.getHours()
            if (value.getHours() === hour) {
              minute = boundary.getMinutes()
            }
          }
        }
      }
      return {
        [`${type}Year`]: year,
        [`${type}Month`]: month,
        [`${type}Date`]: date,
        [`${type}Hour`]: hour,
        [`${type}Minute`]: minute
      }
    },
    getTrueValue (formattedValue) {
      if (!formattedValue) return
      while (isNaN(parseInt(formattedValue, 10))) {
        formattedValue = formattedValue.slice(1)
      }
      return parseInt(formattedValue, 10)
    },
    getMonthEndDay (year, month) {
      if (this.isShortMonth(month)) {
        return 30
      } else if (month === 2) {
        return this.isLeapYear(year) ? 29 : 28
      } else {
        return 31
      }
    },
    isLeapYear (year) {
      return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
    },
    isShortMonth (month) {
      return [4, 6, 9, 11].indexOf(month) > -1
    },
    onConfirm () {
      this.pickerShow = false
      const timer = setTimeout(() => {
        clearTimeout(timer)
        this.data.show = false
        this.$emit('confirm', this.innerValue)
      }, 500);
      
    },
    onCancel () {
      this.pickerShow = false
      const timer = setTimeout(() => {
        clearTimeout(timer)
        this.data.show = false
        console.warn(this.data.show)
        this.$emit('cancel')
      }, 500);
    },
    onChange (picker) {
      const values = picker.getValues()
      let value
      if (this.type === 'time') {
        value = values.join(':')
      } else {
        const year = this.getTrueValue(values[0])
        const month = this.getTrueValue(values[1])
        const maxDate = this.getMonthEndDay(year, month)
        let date = this.getTrueValue(values[2])
        if (this.type === 'year-month') {
          date = 1
        }
        date = date > maxDate ? maxDate : date
        let hour = 0
        let minute = 0
        if (this.type === 'datetime') {
          hour = this.getTrueValue(values[3])
          minute = this.getTrueValue(values[4])
        }
        value = new Date(year, month - 1, date, hour, minute)
      }
      value = this.correctValue(value)
      this.innerValue = value
      this.$nextTick(() => {
        this.$nextTick(() => {
          this.$emit('change', picker)
        })
      })
    },
    updateColumnValue (value) {
      let values = []
      const { formatter, pad } = this
      if (this.type === 'time') {
        const currentValue = value.split(':')
        values = [
          formatter('hour', currentValue[0]),
          formatter('minute', currentValue[1])
        ]
      } else {
        values = [
          formatter('year', `${value.getFullYear()}`),
          formatter('month', pad(value.getMonth() + 1)),
          formatter('day', pad(value.getDate()))
        ]
        if (this.type === 'datetime') {
          values.push(
            formatter('hour', pad(value.getHours())),
            formatter('minute', pad(value.getMinutes()))
          )
        }
        if (this.type === 'year-month') {
          values = values.slice(0, 2)
        }
      }
      this.$nextTick(() => {
        this.$refs.picker.setValues(values)
      })
    }
  },
  mounted () {
    console.log(this.data.show)
    this.updateColumnValue(this.innerValue)
  }
}
</script>

<style lang="scss" scoped>
  .dateTimmPicker-wrapper{
    opacity: 1;
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    height: 100%;
    width: 100%;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
    padding-bottom: constant(safe-area-inset-bottom);
    padding-bottom: env(safe-area-inset-bottom);
    transition: opacity .5s;
    z-index: 100;
    background-color: rgba( #000, 0.2);
    &.hidden{
      opacity: 0;
    }
  }
  .slide-bottom {
    &-enter-active {
      animation: slide-bottom-enter 0.3s both ease;
    }
    &-leave-active {
      animation: slide-bottom-leave 0.3s both ease;
    }
  }
  @keyframes slide-bottom-enter {
    from {
      transform: translate3d(0, 100%, 0);
    }
  }
  @keyframes slide-bottom-leave {
    to {
      transform: translate3d(0, 100%, 0);
    }
  }
</style>
