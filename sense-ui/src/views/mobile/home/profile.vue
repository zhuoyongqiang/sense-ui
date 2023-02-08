<!-- 工作事项 -->
<template>
  <div class="wrapper" v-loading="loading">
    <div class="search-wrapper">
      <el-input :placeholder="tabs.active ? '请输入委托人' : '请输入被委托人'" v-model="searchWord" suffix-icon="el-icon-search"></el-input>
    </div>
    <Tabs v-model="tabs.active" :data="tabs" @click="tabClick" v-if="isUserLogin">
      <div slot="beforeContent" class="condition-panel">
        <el-select v-model="stateValue" placeholder="请选择" :popper-append-to-body="false">
          <el-option
            v-for="item in stateList"
            :key="item.value"
            :label="item.label"
            :value="item.value">
          </el-option>
        </el-select>
        <el-select v-model="timeValue" placeholder="请选择" @click.native="datetimeData.show = true" :popper-append-to-body="false" class="timeSelect">
        </el-select>
      </div>
      <Tab v-for="item in profileType" :title="item.label" :key="item.label">
        <PullRefresh v-model="refreshing" @refresh="onRefresh">
          <List :data="list" @load="onLoad" @reload="onRefresh">
            <div class="module" v-for="item in dataList" :key="item.id" :class="getStatus(item.status).className" @click="toDetail(item)">
              <div class="header">
                <div class="icon"><img class="icon" v-if="getStatus(item.status).icon" :src="require('@/assets/images/mobile/' + getStatus(item.status).icon + '.png')"></div>
                <div class="title">{{'委托事项 ' + item.createTime.slice(0, 10)}}</div>
                <div class="statusDiv"><span class="status" :class="getStatus(item.status).className">{{getStatus(item.status).text}}</span></div>
              </div>
              <div class="body">
                <div class="cell"><div class="label">{{tabs.active ? '委托人' : '被委托人'}}</div><div class="value">{{tabs.active ? item.nickName : item.entrustUserNickname}}</div></div>
                <div class="cell"><div class="label">所属系统</div><div class="value">{{formatSystem(item.appsList)}}</div></div>
                <div class="cell"><div class="label">开始时间</div><div class="value">{{item.startDate}}</div></div>
                <div class="cell"><div class="label">结束时间</div><div class="value">{{item.endDate}}</div></div>
              </div>
              <div class="footer"></div>
            </div>
          </List>
        </PullRefresh>
        <!-- 无数据提醒 -->
        <div v-show="!list.loading && !list.err && dataList.length === 0 && list.finished === true && list.complete" style="text-align: center; margin-top: 30%;font-size:0">
          <img src="./../../../assets/images/mobile/window/nodata.png" style="width: 3.7rem">
          <p style="font-size: .37rem; color:#2B3949; font-weight: 400;">当前暂无数据~  </p>
        </div>
      </Tab>
    </Tabs>
    <div class="batchBtn-panel">
      <div class="batchBtn" @click="toNewprofile"><i class="el-icon-plus"></i>&nbsp;新建委托</div>
    </div>

    <!-- 日期时间选择器 -->
    <datetime-picker
      :data="datetimeData"
      @cancel="hideDateTimePicker"
      @confirm="dateTimePickerConfirm"
    />

    <!-- 意见域 -->
    <el-dialog
      title="审批意见"
      :visible.sync="dialogVisible"
      width="83%"
      top="24vh!important"
      :center="true"
      :show-close="false">
      <el-input
        type="textarea"
        :rows="5"
        placeholder="请输入"
        v-model="commentsText">
      </el-input>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="confirm">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>
<script>
import {getToken} from "@/utils/auth";
import {list,mylist,findById,remove,revoke} from "@/api/console/layout/workentrust/index";
import {batchAction, listApply, listTodo, listFinish, getMobileBuildssolink} from "@/api/console/bpm/workflow";
import {allApp} from "@/api/console/system/app";
import '@/store/REM.js'
import Tabs from '@/components/tabs/Tabs.vue'
import Tab from '@/components/tabs/Tab.vue'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'
import DatetimePicker from '@/views/mobile/components/DatetimePicker/index'
export default {
  name: 'mobileProfile',
  components: {Tabs, Tab, PullRefresh, List, DatetimePicker},
  data() {
    return {
      tabs: {
        active: 0, // tab激活序列
        swipeable: true // 是否允许左右滑动切换tab
      },
      loading: false,
      dialogVisible: false,
      searchWord: '', // 搜索关键词
      isIos: false, // 判断当前系统是否是ios，跟随原生导航栏颜色
      refreshing: false, // 是否触发刷新
      list: { // 加载列表配置项
        immediateCheck: true, // 是否初始化立即触发加载
        pageNum: 0, // 页数
        pageSize: 10, // 每页条数
        total: -1, // 总条数
        err: false, // 是否报错
        loading: false, // 是否加载中
        finished: false, // 是否加载完成，不再触发触底加载
        complete: false, // 是否结束加载
      },
      selections: [], // 选择项数组
      profileType: [
        {
          label: '我的委托'
        },
        {
          label: '委托我的'
        }
      ],
      dataList: [],
      sysList: [], // 所属系统列表
      processStatusOptions: [], // 流程状态数据字典
      commentsText: '同意', // 审批意见
      stateList: [], // 状态列表
      stateValue: '', // 列表过滤条件 - 状态
      timeValue: '所有时间', // 时间范围
      searchTimer: null,
      datetimeData: {
        value: new Date(),
        type: 'date',
        title: '选择时间',
        showToolbar: true,
        confirmButtonText: '确定',
        cancelButtonText: '重置',
        visibleItemCount: 7,
        itemHeight: 44,
        formatter: this.formatter,
        show: false
      },
    }
  },
  beforeRouteEnter (to, from, next) {
    // ...
    next(vm => {
      if (!from.path.includes('mobile')) {
        vm.openMethods = 'window'
      } else {
        vm.openMethods = 'router'
      }
    })
  },
   beforeCreate() {
    document.title = "委托待办";
    const iphone = navigator.userAgent.match(/(iPhone\sOS)\s([\d_]+)/)
    if (iphone) {
      this.isIos = true;
    }
  },
  created() {
    // if (this.isUserLogin) {
    //   this.tabs.active = +sessionStorage.getItem('mobileWorkItemActive') || 0
    // } else {
    //   this.msgWarning('暂无访问权限');
    // }
    
    
    if (this.isUserLogin) {
      // 请求状态列表
      this.queryStatusList()
      // 请求所属系统列表
      this.querySystemList()
    } else {
      this.msgWarning('暂无访问权限');
    }
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  mounted() {
    this.tabs.active = +sessionStorage.getItem('mobileProfileActive') || 0
  },
  watch: {
    'tabs.active' (val, old) {
      sessionStorage.setItem('mobileProfileActive', val);
      this.onRefresh()
    },
    searchWord (val) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        clearTimeout(this.searchTimer)
        this.onRefresh()
      }, 1500);
    },
    stateValue () {
      this.onRefresh()
    },
    timeValue () {
      this.onRefresh()
    }
  },
  methods: {
    // tab点击事件
    tabClick(index, title) {
    },
    /***************************
     * @function formatter
     * @desc 格式化时间选择器展示
    */
    formatter(type, val) {
      if (type === 'year') {
        return `${val}年`;
      } else if (type === 'month') {
        return `${val}月`;
      } else if (type === 'day') {
        return `${val}日`;
      } else if (type === 'hour') {
        return `${val}时`;
      } else if (type === 'minute') {
        return `${val}分`;
      }
      return val;
    },
    /***************************
     * @function hideDateTimePicker
     * @desc 时间选择器取消事件
    */
    hideDateTimePicker () {
      if (this.datetimeData.cancelButtonText === '重置') {
        this.datetimeData.value = new Date()
        this.timeValue = '所有时间'
      }
    },
    /***************************
     * @function dateTimePickerConfirm
     * @desc 时间选择器确定事件
    */
    dateTimePickerConfirm (value) {
      let res = new Date(value).getTime()
      console.log(new Date(res))
      this.datetimeData.value = new Date(value)
      this.timeValue = new Date(value).format('yyyy-MM-dd')
      this.dateTimePickerShow = false
    },
    /*********************
     * @function queryStatusList
     * @desc 请求状态列表，构建状态选择器
     */
    queryStatusList () {
      this.stateList.push(
        {
          label: '正在委托',
          value: 1
        },
        {
          label: '已撤销',
          value: 2
        },
        {
          label: '已过期',
          value: 3
        }
      )
      this.stateList.unshift({
        label: '所有状态',
        value: 'all'
      })
      this.stateValue = 'all'
    },
    /*********************
     * @function getStatus
     * @desc 设置对应委托状态
     */
    getStatus (val) {
      switch (val) {
        case 1:
          return {
            className: 'blue',
            icon: 'profile',
            text: '正在委托'
          }
        case 2:
          return {
            className: 'gray',
            icon: 'unprofile',
            text: '已撤销'
          }
        case 3:
          return {
            className: 'gray',
            icon: 'unprofile',
            text: '已过期'
          }
        default:
          break
      }
    },
    /**********************
     * @function formatSystem
     * @desc 设置对应系统中文
     */
    formatSystem (apps) {
      if (apps && apps.length) {
        if (this.sysList.length) {
          const result = this.sysList.reduce((arr, cur) => {
            if (apps.includes(cur.sn)) {
              console.log('curname', cur.name)
              arr.push(cur.name)
            }
            return arr
          }, []).join(',')
          console.warn('result', result)
          return result
        }
      }
    },
    /************************
     * @function querySystemList
     * @desc 请求所属系统数据字典
     */
    querySystemList () {
      return new Promise((resolve, reject) => {
        allApp({}).then(response => {
          if(response.length>0){
            this.sysList = []
            for(let i in response){
              // if(response[i].status==0)continue;
              // if(response[i].isEntrust==0)continue;
              let obj={
                sn:response[i].sn,
                name:response[i].name
              }
              this.sysList.push(obj)
            }
            resolve()
          } else {
            resolve()
          }
        })
      })
    },
    /*********************
     * @function queryList
     * @desc 加载列表
     */
    async queryList() {
      let resp
      try {
        switch (this.tabs.active) {
          case 0:
            resp = await this.getList()
            if (this.tabs.active === 0) {
              this.dataList = this.dataList.concat(resp.rows)
            }
            break
          case 1:
            resp = await this.getMylist()
            if (this.tabs.active === 1) this.dataList = this.dataList.concat(resp.rows)
            break
          default:
            break
        }
        this.list.loading = false
        this.list.err = false
        if (resp.total <= this.dataList.length) {
          this.list.finished = true
        } else {
          this.list.finished = false
        }
        this.list.complete = true
        console.log('vvvv', this.list)
      } catch (err) {
        console.log(err)
        // 请求失败
        this.list.loading = false
        this.list.finished = true
        this.list.err = true
        this.list.complete = true
      }
    },
    /******************
     * @function onLoad
     * @desc 上拉加载
     */
    onLoad () {
      console.log('onLoad')
      this.list.loading = true
      this.list.err = false
      this.list.pageNum++
      console.log('this.list.pageNum', this.list.pageNum)
      this.queryList()
    },
    /*********************
     * @function onRefresh
     * @desc 刷新
     */
    onRefresh () {
      console.log('onRefresh')
      this.dataList = []
      this.list.finished = true
      this.refreshing = true
      this.list.complete = false
      this.list.pageNum = 0
      this.selections = []
      setTimeout(() => {
        this.list.finished = false
        this.refreshing = false
        window.scrollTo(0, 10)
      }, 0)
    },
    /****************************
     * @function getList
     * @desc 查询 【我委托的】列表
     */
    getList() {
      let param = {
        pageNum: this.list.pageNum || 1,
        pageSize: this.list.pageSize || 10
      }
      if (this.searchWord) {
        param.entrustUserNickname = this.searchWord
      }
      if (this.stateValue !== 'all') {
        param.status = this.stateValue
      }
      if (this.timeValue !== '所有时间') {
        param.params = {
          dateTime: this.timeValue
        }
      }
      return new Promise((resolve, reject) => {
        list(param).then(res => {
          if (res.code == 0) {
            resolve(res)
          } else {
            reject(res)
          }
        }).catch(err => {
          reject(err)
        })
      })
    },
    /****************************
     * @function getMylist
     * @desc 查询 【委托我的】列表
     */
    getMylist () {
      return new Promise((resolve, reject) => {
        let param = {
          pageNum: this.list.pageNum || 1,
          pageSize: this.list.pageSize || 10,
          }
        if (this.searchWord) {
          param.nickName = this.searchWord
        }
        if (this.stateValue !== 'all') {
          param.status = this.stateValue
        }
        if (this.timeValue !== '所有时间') {
        param.params = {
          dateTime: this.timeValue
        }
      }
        mylist(param).then(res => {
          if (res.code == 0) {
            resolve(res)
          } else {
            reject(res)
          }
        }).catch(err => {
          reject(err)
        })
      })
    },
    /*********************
     * @function toNewprofile
     * @desc 新建委托
     */
    toNewprofile () {
      this.$router.push({
        path: '/mobile/home/profile/detail'
      });
    },
    /*********************
     * @function toDetail
     * @desc 跳转详情页
     */
    toDetail (item) {
      this.$router.push({
        path: '/mobile/home/profile/detail/' + item.id
      });
    },
    confirm () {
    }
  }
}
</script>
<style lang="scss" scoped>
  .wrapper{
    width: 100%;
    height: 100%;
    background-color: #fff;
    display: flex;
    flex-direction: column;
    padding-bottom: calc(constant(safe-area-inset-bottom));
    padding-bottom: calc(env(safe-area-inset-bottom)); ///兼容 IOS>11.2/
    box-sizing: border-box;
    .search-wrapper{
      // position: fixed;
      // top: 0;
      // left: 0;
      // width: 100%;
      height: 1.28rem;
      display: flex;
      align-items: center;
      // background-color: #2272DE;
      background-color: #fff;
      padding: 0 .43rem;
      box-sizing: border-box;
      z-index: 100;
      ::v-deep .el-input{
        font-size: .37rem;
        input{
          background-color: #F7F8FA;
          color:#333;
          border-radius: 4px!important;
          height: .85rem;
          line-height: .85rem;
          padding: 0 1rem 0 .32rem;
          border-color: transparent!important;
          &::placeholder{
            color:#C0C4CC;
          }
        }
        i{
          font-weight: bolder;
          color:#2272DE;
        }
      }
    }
    ::v-deep .tabs-wrapper{
      flex: 1;
      // padding-top: calc(1.28rem + 45px);
      // padding-bottom: 1.7rem;
      // box-sizing: border-box;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      background-color: #F7F8FA;
      .indicator{
        &::after{
          width: .85rem!important;
        }
      }
      .tab{
        .title{
          font-weight: 400;
          color: #AFB0B2;
          font-size: .43rem;
        }
        &.active{
          .title{
            font-size: .43rem;
            font-weight: 500;
            color:#2272DE;
          }
        }
      }
      >.wrap{
        // border-bottom: 1px solid #f2f2f2;
        // position: fixed;
        // top: 1.28rem;
        // position: relative;
        // overflow-x: hidden;
        // height: auto;
      }
      .condition-panel{
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0 .43rem;
        height: 1.23rem;
        width: 100%;
        box-sizing: border-box;
        background-color: #fff;
        border-bottom: 1px solid #E0DFDF;
        .el-select{
          flex: 1;
          height: .8rem;
          &:last-child{
            margin-left: .29rem;
          }
          .el-input__inner{
            border-color: #ECECEC;
            border-radius: .11rem!important;
            height: .8rem;
            line-height: .8rem;
          }
          .el-input.is-focus .el-input__inner{
            border-color: #ECECEC;
          }
          input{
            font-size: .37rem;
            font-weight: 400;
            color: #606266;
          }
          .el-icon-arrow-up{
            position: relative;
            transform-origin: 50% 50%;
            width: .36rem;
            margin-right: .24rem;
            &::before{
              position: absolute;
              top: 50%;
              right: 0;
              transform: translateY(-50%);
              content: '';
              width: 0;
              height: 0;
              border-left: .18rem solid transparent;
              border-right: .18rem solid transparent;
              border-bottom: .2rem solid rgba($color: #606266, $alpha: .4);
              border-radius: .27rem;
            }
          }
        }
      }
      >.content{
        height: 100%;
        min-height: auto;
        overflow-y: auto;
        position: relative;
        .pane{
          .pull-refresh-wrapper{
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
          }
        }
      }
    }
  }
  .module{
    border-radius: 4px;
    background-color: #fff;
    margin: .32rem .32rem;
    box-shadow: 0px 2px 8px 0px rgba(227, 227, 227, 0.5);
    position: relative;
    padding-left: 4px;
    overflow: hidden;
    &::after{
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      width: 4px;
      content: '';
      background-color: transparent;
    }
    &.blue{
       &::after{
        background-color: #2272DE;
      }
    }
    &.gray{
       &::after{
        background-color: #B5B5B5;
      }
    }
    i{
      margin-right: .24rem;
      display: inline-block;
      width: .53rem;
      height: .53rem;
    }
    .circle{
      position: relative;
      &::after{
        position: absolute;
        content: '';
        border-radius: 50%;
        width: .50rem;
        height: .50rem;
        left: 1px;
        border: 1px solid #CCD0D6;
        box-sizing: border-box;
        display: inline-block;
      }
    }
    .el-icon-success{
      font-size: .53rem;
      color:#2272DE;
      border-color: transparent;
    }
    .header{
      position: relative;
      padding: .21rem .21rem;
      margin-bottom: .21rem;
      font-size: .37rem;
      display: flex;
      align-items: flex-start;
      &::after{
        position: absolute;
        bottom: 0;
        left: 0;
        content: '';
        height: 1px;
        background-color: #e9e9e9;
        transform: scaleY(.5);
        width: 100%;
      }
      .icon{
        height: .586rem;
        display: flex;
        align-items: center;
        margin-right: .11rem;
        img{
          width: .32rem;
          height: .32rem;
        }
      }
      .title{
        flex: 1;
        font-weight: 600;
        color: #303133;
        word-break: break-all;
        margin-right: .27rem;
        line-height: .586rem;
      }
      .statusDiv{
        height: .586rem;
        display: flex;
        align-items: center;
      }
      .status{
        font-weight: 400;
        font-size: .32rem;
        border-radius: .267rem;
        padding: 0 .21rem;
        height: .533rem;
        line-height: .533rem;
        &.gray{
          background-color: rgba(#B5B5B5, .2);
          color: #B5B5B5;
        }
        &.blue{
          background-color: rgba(#2272DE, .14);
          color:#2272DE;
        }
      }
    }
    .body{
      font-size: .4rem;
      // text-align: justify;
      word-break: break-all;
      color: #8a8282;
      padding: 0 .21rem .21rem;
      .cell{
        display: flex;
        align-items: flex-start;
        // justify-content: space-between;
        margin-bottom: .16rem;
        font-weight: 400;
        padding-left: .54rem;
        box-sizing: border-box;
        .label{
          width: 1.81rem;
          min-width: 1.81rem;
          color: #606266;
          font-size: .37rem;
          line-height: .53rem;
        }
        .value{
          font-size: .37rem;
          color:#303133;
          line-height: .53rem;
        }
      }
    }
  }
  // 这边代码有问题，得改
  .batchBtn-panel{
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding: 0 .32rem .64rem;
    box-sizing: border-box;
    background-color: #F7F8FA;
    .batchBtn{
      width: 100%;
      height: 1.17rem;
      line-height: 1.17rem;
      background: #2272DE;
      box-shadow: 0px .26rem .32rem 0 #D5DEE8;
      border-radius: .11rem;
      font-weight: 600;
      font-size: .43rem;
      color:#fff;
      text-align: center;
      bottom: calc(constant(safe-area-inset-bottom) + .27rem);
      bottom: calc(env(safe-area-inset-bottom) + .27rem); ///兼容 IOS>11.2/
      &:active{
        opacity: .8;
      }
    }
  }

  ::v-deep .el-dialog{
    border-radius: .21rem;
    font-size: 0;
    overflow: hidden;
    .el-dialog__header{
      padding: .64rem 0 .32rem;
      .el-dialog__title{
        font-weight: 500;
        color: #303133;
        font-size: .43rem;
      }
    }
    .el-dialog__body{
      background: #F7F8FA;
      border-radius: 4px;
      margin: 0 .43rem .32rem;
      padding: 0;
      textarea{
        -webkit-appearance: none;
      }
    }
    .el-dialog__footer{
      padding: 0;
      .dialog-footer{
        border-top: 1px solid #F2F2F3;
        display: inline-block;
        width: 100%;
        .el-button{
          height: 1.28rem;
          width: 50%;
          margin: 0;
          border: none;
          background-color: #fff;
          font-size: .43rem;
          font-weight: 400;
          &:active{
            background: none !important;
          }
          &:last-child{
            color:#2272DE;
            border-left: 1px solid #F2F2F3;
            box-sizing: border-box;
          }
        }
      }
    }
  }
  .timeSelect{
    ::v-deep .el-select-dropdown{
      display: none;
    }
  }
  ::v-deep .el-select-dropdown{
    box-shadow: 0px 2px 6px 1px rgba(229, 229, 229, 0.5);
    margin-top: .11rem;
    border-radius: .05rem;
    border: none;
    .el-scrollbar__view{
      padding: 0;
      >li{
        font-weight: 400;
        text-align: center;
        height: 1.17rem;
        line-height: 1.17rem;
        font-size: .37rem;
        &.selected{
          color:#2272DE;
        }
        &.hover{
          background-color: #F7F8FA;
        }
        &:hover{
          background-color: #F7F8FA;
        }
      }
    }
    .popper__arrow{
      display: none;
    }
  }
</style>