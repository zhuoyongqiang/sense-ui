<template>
  <div v-if="!data.hide" class="picker">
    <div v-if="data.showToolbar" class="toolbar">
      <div class="cancel" @click="emit('cancel')">{{data.cancelButtonText}}</div>
      <div class="title" v-if="data.title">{{data.title}}</div>
      <div class="confirm" @click="emit('confirm')">{{data.confirmButtonText}}</div>
    </div>
    <div class="columns" @touchmove.prevent :style="columnsStyle">
      <div class="frame"></div>
      <PickerColumn :class="(simple ? [columns] : columns).length === 5 ? 'more': ''"
        v-for="(item, itemIndex) in (simple ? [columns] : columns)"
        :key="itemIndex"
        :value-key="data.valueKey"
        :initial-options="simple ? item : item.values"
        :class-name="item.className"
        :default-index="item.defaultIndex"
        :item-height="data.itemHeight"
        :visible-item-count="data.visibleItemCount"
        @change="onChange(itemIndex)"
      />
    </div>
  </div>
</template>
<script>
import PickerColumn from './PickerColumn'
export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  components: {
    PickerColumn
  },
  data () {
    return {
      children: [],
      columns: this.data.columns
    }
  },
  computed: {
    frameStyle () {
      return {
        height: this.data.itemHeight + 'px'
      }
    },
    columnsStyle () {
      return {
        height: this.data.itemHeight * this.data.visibleItemCount + 'px'
      }
    },
    simple () {
      return this.data.columns.length && !this.data.columns[0].values
    }
  },
  watch: {
    columns () {
      this.setColumns()
    },
    'data.columns' () {
      this.columns = this.data.columns
      this.columns.defaultIndex = this.data.defaultIndex
    },
    data (val, oldVal) {
      //
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
    setColumns () {
      const columns = this.simple ? [{
        values: this.columns
      }] : this.columns
      columns.forEach((column, index) => {
        this.setColumnValues(index, this.deepClone(column.values))
      })
    },
    emit (event) {
      if (this.simple) {
        this.$emit(event, this.getColumnValue(0), this.getColumnIndex(0))
      } else {
        this.$emit(event, this.getValues(), this.getIndexes())
      }
    },
    onChange (columnIndex) {
      if (this.simple) {
        this.$emit('change', this, this.getColumnValue(0), this.getColumnIndex(0))
      } else {
        this.$emit('change', this, this.getValues(), columnIndex)
      }
    },
    getColumn (index) {
      return this.children[index]
    },
    getColumnValue (index) {
      const column = this.getColumn(index)
      return column && column.getValue()
    },
    setColumnValue (index, value) {
      const column = this.getColumn(index)
      column && column.setValue(value)
    },
    getColumnIndex (columnIndex) {
      return (this.getColumn(columnIndex) || {}).currentIndex
    },
    setColumnIndex (columnIndex, optionIndex) {
      const column = this.getColumn(columnIndex)
      column && column.setIndex(optionIndex)
    },
    getColumnValues (index) {
      return (this.children[index] || {}).options
    },
    setColumnValues (index, options) {
      const column = this.children[index]
      if (column && JSON.stringify(column.options) !== JSON.stringify(options)) {
        column.options = options
        column.setIndex(0)
      }
    },
    getValues () {
      return this.children.map(child => child.getValue())
    },
    setValues (values) {
      values.forEach((value, index) => {
        this.setColumnValue(index, value)
      })
    },
    getIndexes () {
      return this.children.map(child => child.currentIndex)
    },
    setIndexes (indexes) {
      indexes.forEach((optionIndex, columnIndex) => {
        this.setColumnIndex(columnIndex, optionIndex)
      })
    }
  }
}
</script>
<style lang="scss" scoped>
  .picker {
    width: 100%;
    overflow: hidden;
    user-select: none;
    position: fixed;
    bottom: 0;
    background-color: #fff;
    border-radius: 8px 8px 0 0;
    // box-shadow: 0px -1px 10px 1px rgba(130, 93, 93, 0.14);
    padding-bottom: constant(safe-area-inset-bottom);
    padding-bottom: env(safe-area-inset-bottom);
    .toolbar {
      display: flex;
      justify-content: space-between;
      height: 40px;
      line-height: 40px;
      // border-bottom: 1px solid #eaeaea;
      font-size: 18px;
      .cancel, .confirm {
        padding: 0 16px;
        font-weight: 400;
        color: #2272DE;
        font-size: 14px;
        &:active {
          background-color: #fff; 
        }
      }
      .cancel{
        color: #AFB0B2;
      }
      .title {
        max-width: 50%;
        text-align: center;
        font-weight: 500;
        color: #323233;
        font-size: 16px;
      }
    }
    .columns {
      display: flex;
      position: relative;
    }
    .frame {
      top: 0;
      left: 0;
      width: 100%;
      height: 100% !important;
      z-index: 1;
      position: absolute;
      pointer-events: none;
      transform: translate3d(0,0,0);
      background: linear-gradient(180deg, #fff, rgba(#fff, .3) 43%, transparent 43%, transparent, transparent 57%, rgba(#fff, .3) 57%,#fff);
    }
    ::v-deep .picker-column {
      flex: 1;
      overflow: hidden;
      text-align: center;

      &.more:first-child{
        flex: 0.85;
        padding-left: 12px;
        .item{
          text-align: left;
        }
      }
      &.more:nth-last-child(2){
        flex: 0.85;
        // padding-right: 12px;
        .item{
          // text-align: right;
        }
      }
      .item {
        padding: 0 5px;
        color: #606266;
        font-weight: 400;
        font-size: 15px;
        transform: translate3d(0,0,0);
        &.selected {
          color: #303133;
          font-weight: 500;
          border: solid #F2F2F3;
          border-width: 1px 0 1px 0;
          transform: scale(1.2) translate3d(0,0,0);
          transform-origin: 50% 50%;
        }
        &.disabled {
          opacity: .3;
        }
      }
      .ellipsis{
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
      }
    }
  }
</style>
