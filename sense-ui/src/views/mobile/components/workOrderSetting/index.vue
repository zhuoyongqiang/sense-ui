<template>
  <div class="workOrderSetting-wrapper" :class="{'hidden' : !show}" v-show="data.show" @click.self="clickTarget">
    <transition name="slide-bottom">
      <div class="main" v-show="show">
        <div class="header-panel">
          <div class="title">工单设置</div>
          <i class="el-icon-close" @click="close"></i>
        </div>
        <div class="search-panel" v-show="data.edit">
          <el-input
            :disabled="loading"
            placeholder="请搜索工单类型"
            v-model.trim="selectUserText"
            suffix-icon="el-icon-search"
          ></el-input>
          <div class="cancel" v-show="selectUserText.length" @click="selectUserText = ''">取消</div>
        </div>
        <div class="scroll-view"  ref="scrollView" v-loading="loading">
          <div class="item" v-for="item in workOrderList" :key="item.id" @click="itemClick(item)">
            <span class="icon"><i :class="checkeds.some(v => v.id === item.id) || !data.edit ? 'el-icon-circle-check' : 'circle'"></i></span>
            <span class="text">{{item.label}}</span>
          </div>
        </div>
        <div class="footer" v-show="workOrderList.length && data.edit">
          <div @click="selectAll"><i :class="checkeds.length && checkeds.length === workOrderList.length ? 'el-icon-circle-check' : 'circle'"></i>全部</div>
          <div class="btn" @click="confirm">确定{{checkeds.length ? `(${checkeds.length})` : ''}}</div>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import '@/store/REM.js'
import scrollUtils from "@/utils/scroll";
import {workTypeAll} from "@/api/console/layout/workentrust/index";
export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      show: false,
      scroller: null,
      selectUserText: "",
      searchTimer: null,
      loading: false,
      dataList: [], // 列表数据
      checkeds: [], // 选中项
      lastcheckeds: [], // 最终确定选中项
      originWorkOrderList: [], // 展示的列表数据
      workOrderList: [], // 过滤后的展示列表数据
    };
  },
  watch: {
    selectUserText (val) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        clearTimeout(this.searchTimer)
        if (val) {
          this.workOrderList = this.originWorkOrderList.filter(v => (v.label).includes(val))
        } else {
          this.workOrderList = this.deepClone(this.originWorkOrderList)
          this.$nextTick(() => {
            scrollUtils.setScrollTop(this.scroller, 0);
          })
        }
      }, 1000);
    },
    'data.show' (val) {
      if (val) {
        this.show = true
        this.$nextTick(() => {
          scrollUtils.setScrollTop(this.scroller, 0);
        })
      } else {
        this.reset()
      }
    },
    'data.filter': {
      handler (val) {
        if (this.dataList.length) {
          this.originWorkOrderList = []
          for (let i = 0; i < val.length; i++) {
            for (let j = 0; j < this.dataList.length; j++) {
              if (this.dataList[j].appId === val[i].sn) {
                if (this.originWorkOrderList.every(v => v.id !== this.dataList[j].id)) {
                  this.originWorkOrderList.push(
                    {
                      ...this.dataList[j],
                      label: `${val[i].name}/${this.dataList[j].label}`
                    }
                  )
                }
              }
            }
          }
          if (this.data.edit) {
            this.workOrderList = this.deepClone(this.originWorkOrderList)
          } else {
            if (this.data.workOrderList.length) {
              for (let i = 0; i < this.data.workOrderList.length; i++) {
                for (let j = 0; j < this.originWorkOrderList.length; j++) {
                  if (this.data.workOrderList[i].appId === this.originWorkOrderList[j].appId && this.data.workOrderList[i].sn === this.originWorkOrderList[j].sn) {
                    console.warn('3', this.originWorkOrderList)
                    this.workOrderList.push(this.originWorkOrderList[j])
                  }
                }
              }
            }
          }
          console.log(this.originWorkOrderList)
        }
      },
      deep: true
    },
    'data.workOrderList': {
      handler (val) {
        console.warn('workOrderList', val)
        if (this.originWorkOrderList.length) {
          for (let i = 0; i < this.data.workOrderList.length; i++) {
            for (let j = 0; j < this.originWorkOrderList.length; j++) {
              if (this.data.workOrderList[i].appid === this.originWorkOrderList[j].appId && this.data.workOrderList[i].sn === this.originWorkOrderList[j].sn) {
                this.workOrderList.push(this.originWorkOrderList[j])
              }
            }
          }
        }
        console.warn('originWorkOrderList', this.originWorkOrderList)
      },
      deep: true
    }
  },
  created() {
    this.getData()
  },
  mounted() {
    this.$nextTick(() => {
      this.scroller = scrollUtils.getScrollEventTarget(this.$refs.scrollView);
    })
  },
  beforeDestroy() {
    clearTimeout(this.searchTimer)
  },
  methods: {
    reset () {
      console.warn('reset')
      if (this.data.edit) {
        this.selectUserText = ''
        this.checkeds = this.deepClone(this.lastcheckeds)
        this.workOrderList = this.deepClone(this.originWorkOrderList)
        this.$nextTick(() => {
          scrollUtils.setScrollTop(this.scroller, 0);
        })
      }
    },
    clickTarget (event) {
      console.warn(event)
      this.close()
    },
    close () {
      this.show = false
      const timer = setTimeout(() => {
        clearTimeout(timer)
        this.data.show = false
      }, 500);
    },
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
    getData() {
      this.loading = true;
      workTypeAll().then(resp => {
        this.loading = false
        if (resp.code) {
          this.msgError(resp.msg)
          reject(resp)
        } else {
          if (resp.length > 0) {
            this.dataList = []
            for (let i = 0; i < resp.length; i++) {
              this.dataList.push(
                {
                  ...resp[i],
                  label: `${resp[i].type}/${resp[i].name}`
                }
              )
            }
          } else {
          }
        }
      }).catch(err => {
        this.loading = false
      })
    },
    /*******************
     * @function itemClick
     * @desc 列表点击事件
     */
    itemClick (item) {
      const index = this.checkeds.findIndex(v => v.id === item.id)
      if (index < 0) {
        this.checkeds.push(item)
      } else {
        this.checkeds.splice(index, 1)
      }
    },
    /*********************
     * @function selectAll
     * @desc 全选
     */
    selectAll () {
      this.checkeds = this.deepClone(this.workOrderList)
    },
    /******************
     * @function confirm
     * @desc 确定按钮
     */
    confirm () {
      this.lastcheckeds = this.deepClone(this.checkeds)
      this.$emit('onConfirm', this.deepClone(this.checkeds))
      this.close()
    }
  },
};
</script>
<style lang="scss" scoped>
.workOrderSetting-wrapper {
  opacity: 1;
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  height: 100%;
  width: 100%;
  overflow: hidden;
  // -webkit-overflow-scrolling: touch;
  background-color: rgba($color: #000, $alpha: 0.2);
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
  // display: flex;
  // flex-direction: column;
  // justify-content: flex-end;
  transition: opacity .5s;
  &.hidden{
    opacity: 0;
  }
  .main {
    height: 90%;
    background-color: #fff;
    border-radius: 0.5rem 0.5rem 0 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: fixed;
    bottom: 0;
    width: 100%;
    .header-panel {
      height: 1.28rem;
      line-height: 1.28rem;
      text-align: center;
      position: relative;
      .el-icon-arrow-left {
        position: absolute;
        top: 50%;
        left: 0.45rem;
        color: #afb0b2;
        font-size: 0.4rem;
        transform: translateY(-50%);
      }
      .title {
        font-size: 0.43rem;
      }
      .el-icon-close {
        position: absolute;
        top: 50%;
        right: 0.45rem;
        color: #afb0b2;
        font-size: 0.4rem;
        transform: translateY(-50%);
      }
    }
    ::v-deep .search-panel {
      padding: 0 0.43rem;
      margin-bottom: 0.43rem;
      display: flex;
      align-items: center;
      font-size: .43rem;
      .el-input {
        display: block;
        flex: 1;
        i{
          font-size: .37rem;
          font-weight: bold!important;
        }
      }
      input {
        height: 1.01rem;
        line-height: 1.01rem;
        background: #F7F8FA;
        border-radius: .11rem!important;
        border-color: transparent;
        font-weight: 400;
        color: #606266;
        font-size: .35rem;
      }
      i{
        color: #2272DE;
      }
      .cancel{
        font-weight: 400;
        color: #2272DE;
        margin-left: .21rem;
      }
    }
    .scroll-view {
      flex: 1;
      overflow-y: auto;
      .item{
        font-size: .43rem;
        font-weight: 400;
        color: #606266;
        display: flex;
        align-items: flex-start;
        padding: .267rem 0;
        margin: 0 .43rem;
        border-bottom: 1px solid #EBEDF0;
        .icon{
          height: .586rem;
          display: flex;
          align-items: center;
        }
        i{
          margin-right: .21rem;
          width: .53rem;
          height: .53rem;
          display: inline-block;
          color:#2272DE;
        }
        .el-icon-circle-check{
          font-size: .53rem;
        }
        .circle{
          position: relative;
          &::after{
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            display: inline-block;
            content: '';
            border: 1px solid #2272DE;
            width: .47rem;
            height: .47rem;
            border-radius: 50%;
          }
        }
        span{
          word-break: break-all;
          line-height: .586rem;
        }
      }
    }
    .footer{
      display: flex;
      align-items: center;
      font-size: .43rem;
      justify-content: space-between;
      height: 1.28rem;
      padding: 0 .43rem;
      >div{
        display: flex;
        align-items: center;
      }
      i{
        margin-right: .21rem;
        width: .53rem;
        height: .53rem;
        display: inline-block;
        color:#2272DE;
        &.el-icon-circle-check{
          font-size: .53rem;
        }
        &.circle{
          position: relative;
          &::after{
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            display: inline-block;
            content: '';
            border: 1px solid #2272DE;
            width: .47rem;
            height: .47rem;
            border-radius: 50%;
          }
        }
      }
      .btn{
        color:#2272DE
      }
    }
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

.fade-enter {
  opacity: 0;
}
.fade-enter-to {
  opacity: 1;
}
.fade-enter-active {
  transition: all 0.5s;
}
.fade-leave-active {
  transition: 0s;
}
</style>