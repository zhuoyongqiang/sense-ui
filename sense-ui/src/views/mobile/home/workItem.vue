<!-- 工作事项 -->
<template>
  <div class="wrapper" v-loading="loading">
    <div class="search-wrapper">
      <el-input type="search" placeholder="请输入工单名称进行搜索" v-model="searchWord" suffix-icon="el-icon-search"></el-input>
    </div>
    <Tabs v-model="tabs.active" :data="tabs" @click="tabClick" v-if="isUserLogin">
      <div slot="beforeContent" class="condition-panel">
        <el-select v-model="appValue" placeholder="请选择" :popper-append-to-body="false">
          <el-option
            v-for="item in appList"
            :key="item.id"
            :label="item.name"
            :value="item.name">
          </el-option>
        </el-select>
        <el-select v-model="levelValue" placeholder="请选择" :popper-append-to-body="false">
          <el-option
            v-for="item in levelList"
            :key="item.value"
            :label="item.label"
            :value="item.value">
          </el-option>
        </el-select>
      </div>
      <Tab v-for="item in workItemType" :title="item.label" :key="item.label">
        <PullRefresh v-model="refreshing" @refresh="onRefresh">
          <List :data="list" @load="onLoad" @reload="onRefresh">
            <div class="module" v-for="item in dataList" :key="item.id" :class="getLevel(item.businessLevel).className" @click="openTask(item)">
              <div class="header">
                <i v-show="batchMode && tabs.active === 0" :class="selections.some(v => v.id === item.id) ? 'el-icon-success' : 'circle' "></i>
                <img class="icon" :src="require('@/assets/images/mobile/' + getLevel(item.businessLevel).className + '.png')">
                <div class="title">{{item.businessName}}</div>
                <div v-show="tabs.active" class="state" :style="{'color': getStateColor(item.processStatus)}">{{selectDictLabel(processStatusOptions, item.processStatus)}}</div>
                <div v-show="!tabs.active" class="level" :class="getLevel(item.businessLevel).className">{{getLevel(item.businessLevel).text}}</div>
              </div>
              <div class="body" :class="{'isbatchMode': batchMode}">
                <div class="cell"><div class="label">系统</div><div class="value">{{item.clientName}}</div></div>
                <div class="cell"><div class="label">工单编号</div><div class="value">{{item.businessKey}}</div></div>
                <div class="cell"><div class="label">申请人</div><div class="value">{{item.startNickName}}</div></div>
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
    <div class="batchBtn" v-show="dataList.length && tabs.active === 0 && !batchMode" @click="batchModeOpen">批量模式</div>
    <div class="batchMode" v-show="batchMode && tabs.active === 0">
      <div class="checkbox"><span @click="checkAll" v-show="dataList.length > 0"><i :class="selections.length && (selections.length === dataList.length || selections.length === 10) ? 'el-icon-success' : 'circle' "></i><span>全选</span></span></div>
      <span class="total">合计工单：<span class="count">{{selections.length}}</span></span>
      <div class="btn" @click="batchStart" :class="{'disabled' : !selections.length}">批量审批</div>
      <i class="el-icon-close" @click="closeBatchMode"></i>
    </div>

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
import Cookies from "js-cookie";
import {batchAction, listApply, listTodo, listFinish, getMobileBuildssolink} from "@/api/console/bpm/workflow";
import {allApp} from "@/api/console/system/app";
import '@/store/REM.js'
import Tabs from '@/components/tabs/Tabs.vue'
import Tab from '@/components/tabs/Tab.vue'
import PullRefresh from '@/components/loading/PullRefresh'
import List from '@/components/loading/List'
import { cancelHttp } from '@/utils/request'
export default {
  name: 'mobileWorkItem',
  components: {Tabs, Tab, PullRefresh, List},
  data() {
    return {
      tabs: {
        active: +sessionStorage.mobileWorkItemActive || 0, // tab激活序列
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
      workItemType: [
        {
          label: '待审批',
          total: null
        },
        {
          label: '已审批',
          total: null
        },
        {
          label: '我的申请',
          total: null
        }
      ],
      dataList: [],
      batchMode: false, // 是否开启全选模式
      processStatusOptions: [], // 流程状态数据字典
      commentsText: '同意', // 审批意见
      appList: [], // 系统列表
      appValue: '全部系统', // 所属系统
      levelList: [
        {
          value: 'all',
          label: '优先级'
        },
        {
          value: '0',
          label: '普通'
        },
        {
          value: '1',
          label: '重要'
        },
        {
          value: '2',
          label: '紧急'
        }
      ], // 紧急程度列表
      levelValue: 'all', // 紧急程度
      searchTimer: null,
      setIntervalTimer: null // 轮询
        
    }
  },
  filters: {
    format (val, format) {
      if (format === 'time') {
        return new Date(val).format("yyyy-MM-dd hh:mm:ss")
      }
      if (format === 'state') {
        if (this.processStatusOptions.length) {
          return this.selectDictLabel(val)
        } else {
          this.getDicts('bpm_process_status').then(response => {
            this.processStatusOptions = response.data;
            return this.selectDictLabel(val)
          })
        }
      }
    }
  },
   beforeCreate() {
    document.title = "统一待办";
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
      this.getDict()
      allApp(undefined).then(response => {
        this.appList = [];
        this.appList.push(
          {
            name: '全部系统',
            id: 'all'
          }
        )
        if(response !== undefined && response !==null && response.length > 0) {
          response.forEach((item, index, arr) => {
            //过滤是列表显示的应用集合
            if(item.isShow === 1) {
              let poDada = {
                name: item.name,
                id: item.id
              }
              this.appList.push(poDada);
            }
          });
        }
      });
    }

    window.addEventListener('online', () => {
      if (location.href.includes('/mobile/home/workItem')) {
        // this.onRefresh()
        window.location.reload()
      }
    })
    window.addEventListener('pageshow', () => {
    //外链回退到vue应用要执行的代码
      if (location.href.includes('/mobile/home/workItem')) {
        if (this.isUserLogin) {
          this.tabs.active = +sessionStorage.mobileWorkItemActive || 0
          this.onRefresh()
        } else {
          this.msgWarning('暂无访问权限');
        }
      }
    })
  },
  beforeDestroy() {
    clearInterval(this.setIntervalTimer)
  },
  destroyed() {
    window.removeEventListener('pageshow', () => {})
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    }
  },
  watch: {
    'tabs.active' (val, old) {
      sessionStorage.setItem('mobileWorkItemActive', val);
      this.onRefresh()
    },
    searchWord (val) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        clearTimeout(this.searchTimer)
        this.onRefresh()
      }, 1500);
    },
    appValue () {
      this.onRefresh()
    },
    levelValue () {
      this.onRefresh()
    }
  },
  methods: {
    // tab点击事件
    tabClick(index, title) {
      // return
      // const tab = this.workItemType[index]
      // if (index === this.tabs.active) {
      //   this.onRefresh()
      // }
    },
    /*********************
     * @function getDict
     * @desc 获取流程状态的中文字典
     */
    getDict () {
      this.getDicts('bpm_process_status').then(response => {
        this.processStatusOptions = response.data;
      })
    },
    /*********************
     * @function getStateColor
     * @desc 设置对应流程状态颜色
     * @param 0 - 驳回(红)， 1 - 审批中(蓝)， 2 - 通过(绿)
     */
    getStateColor (val) {
      switch (val) {
        case 0:
          return '#FF5555'
        case 1:
          return '#2272DE'
        case 2:
          return '#67C23A'
        default:
          break
      }
    },
    /*********************
     * @function getLevel
     * @desc 设置对应紧急状态class
     */
    getLevel (val) {
      switch (val) {
        case 0:
          return {
            className: 'common',
            color: '#2272DE'
          }
        case 1:
          return {
            className: 'important',
            color: '#BF8AFF',
            text: '重要'
          }
        case 2:
          return {
            className: 'urgent',
            color: '#FF8438',
            text: '紧急'
          }
        default:
          break
      }
    },
    /*********************
     * @function qeuryAll
     * @desc 请求各列表条数
     */
    qeuryAll () {
      switch (this.tabs.active) {
        case 0:
          this.onLoad()
          this.finish()
          this.apply()
          break
        case 1:
          this.onLoad()
          this.todo()
          this.apply()
          break
        case 2:
          this.onLoad()
          this.todo()
          this.finish()
          break
        default:
          this.todo()
          this.finish()
          this.apply()
          break
      }
      // this.todo() =》 获取请求后的返回值，页面显示待办条数
      // this.finish() =》 获取请求后的返回值，页面显示已办条数
      // this.apply() =》 获取请求后的返回值，页面显示申请条数
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
            resp = await this.todo()
            if (this.tabs.active === 0) {
              this.dataList = this.dataList.concat(resp.rows)
              this.workItemType[0].label = `待审批(${resp.total})`
            }
            break
          case 1:
            resp = await this.finish()
            if (this.tabs.active === 1) this.dataList = this.dataList.concat(resp.rows)
            break
          case 2:
            resp = await this.apply()
            if (this.tabs.active === 2) this.dataList = this.dataList.concat(resp.rows)
            break
          default:
            break
        }
        if (!this.setIntervalTimer) {
          this.setIntervalTimer = setInterval(() => {
            this.onRefresh()
          }, 30000);
        }
        this.list.loading = false
        this.list.err = false
        if (resp.total <= this.dataList.length) {
          this.list.finished = true
        } else {
          this.list.finished = false
        }
        this.list.complete = true
      } catch (err) {
        console.log(err)
        // 请求失败
        this.list.loading = false
        this.list.finished = true
        this.list.complete = true
        if (err.code && (err.code === 401 || err.code === 403)) {
          Cookies.remove('Qr-Code');
          window.location.reload()
        } else if (err.message !== 'CANCEL') {
          this.list.err = true
        }
      }
    },
    /******************
     * @function onLoad
     * @desc 上拉加载
     */
    onLoad () {
      this.list.loading = true
      this.list.err = false
      this.list.pageNum++
      this.queryList()
    },
    /*********************
     * @function onRefresh
     * @desc 刷新
     */
    onRefresh () {
      cancelHttp()
      this.dataList = []
      this.list.finished = true
      this.refreshing = true
      this.list.complete = false
      this.list.pageNum = 0
      this.selections = []
      if (this.batchMode && this.tabs.active === 0) {
        // 不关闭审批模式
      } else {
        this.batchMode = false
      }
      setTimeout(() => {
        this.list.finished = false
        this.refreshing = false
        window.scrollTo(0, 10)
      }, 0)
    },
    /*********************
     * @function todo
     * @desc 待办列表
     */
    todo() {
      return new Promise((resolve, reject) => {
        listTodo({
          pageNum: this.list.pageNum || 1,
          pageSize: this.list.pageSize || 10,
          businessName: this.searchWord,
          isLikeQuery: true,
          isBatchApproval: this.batchMode ? 1 : undefined,
          clientName: this.appValue === '全部系统' ? undefined : this.appValue,
          businessLevel: this.levelValue === 'all' ? undefined : +this.levelValue,
          isMobile: true
        }, 'canCancel').then(res => {
          if (res.code == 0) {
            this.workItemType[0].total = res.total
            resolve(res)
          } else {
            this.workItemType[0].total = null
            reject(res)
          }
        }).catch(err => {
          this.workItemType[0].total = null
          reject(err)
        })
      })
    },
    /*********************
     * @function finish
     * @desc 已办列表
     */
    finish() {
      return new Promise((resolve, reject) => {
        listFinish({
          pageNum: this.list.pageNum || 1,
          pageSize: this.list.pageSize || 10,
          businessName: this.searchWord,
          clientName: this.appValue === '全部系统' ? undefined : this.appValue,
          businessLevel: this.levelValue === 'all' ? undefined : this.levelValue,
          isLikeQuery: true,
          isMobile: true
        }, 'canCancel').then(res => {
          if (res.code == 0) {
            this.workItemType[1].total = res.total
            resolve(res)
          } else {
            this.workItemType[1].total = null
            reject(res)
          }
        }).catch((err) => {
          this.workItemType[1].total = null
          reject(err)
        })
      })
    },
    /*********************
     * @function apply
     * @desc 我的申请列表
     */
    apply() {
      return new Promise((resolve, reject) => {
        listApply({
          pageNum: this.list.pageNum || 1,
          pageSize: this.list.pageSize || 10,
          businessName: this.searchWord,
          clientName: this.appValue === '全部系统' ? undefined : this.appValue,
          businessLevel: this.levelValue === 'all' ? undefined : this.levelValue,
          isLikeQuery: true,
          isMobile: true
        }, 'canCancel').then(res => {
          if (res.code == 0) {
            this.workItemType[2].total = res.total
            resolve(res)
          } else {
            this.workItemType[2].total = null
            reject(res)
          }
        }).catch((err) => {
          this.workItemType[2].total = null
          reject(err)
        })
      })
    },
    /*********************
     * @function openProcess
     * @desc
     */
    openProcess(row) {
      //判断是门户的待办还是其他系统的待办跳转不同的位置办理
      if('APP001'=== row.clientId ){
        // this.$router.push({
        //   path: '/mobile/home/detail/' + row.newsInstId
        // });
        console.log(this.tabs.active)
        location.href = '/mobile/home/approve/' + row.newsInstId + `&process=${this.tabs.active}`
        // location.href = '/mobile/home/detail/' + row.newsInstId
      }else{
        getMobileBuildssolink(2, row.id).then(response => {
          if(response.code === 200){
            // alert(response.msg)
            location.href = response.msg;
          }else{
            this.msgWarning(response.msg)
          }
        });
      }
    },
    /*********************
     * @function openTask
     * @desc 列表项点击事件
     */
    openTask(row) {
      if (this.batchMode && this.tabs.active === 0) {
        const index = this.selections.findIndex(k => k.id === row.id)
        if (index >= 0) {
          this.selections.splice(index, 1)
        } else {
          this.selections.push(row)
        }
        return
      }
      if(this.tabs.active !== 0) {
        // 当前列表不为待办列表时
        this.openProcess(row)
        return;
      }else{
        if('APP001'=== row.clientId) {
          // this.$router.push({
          //   path: '/mobile/home/approve/' + row.id
          // })
          location.href = '/mobile/home/approve/' + row.id
        } else {
          getMobileBuildssolink(1, row.id).then(response => {
            if(response.code===200){
              location.href = response.msg;
            }else{
              this.msgWarning(response.msg)
            }
          })
        }
      }
    },
    /*********************
     * @function batchModeOpen
     * @desc 开启批量审批模式
     */
    batchModeOpen () {
      this.batchMode = true
      this.onRefresh()
    },
    /*********************
     * @function closeBatchMode
     * @desc 关闭批量审批模式
     */
    closeBatchMode () {
      this.batchMode = false
      this.onRefresh()
    },
    /*********************
     * @function batchStart
     * @desc 打开审批意见
     */
    batchStart () {
      if (this.selections.length) this.dialogVisible = true
    },
    /*********************
     * @function batchSubmit
     * @desc 批量提交
     */
    batchSubmit(){
      this.loading = true
      this.dialogVisible = false
      let data = {
        ids: this.selections.map(item => item.taskId),
        remark: this.commentsText
      }
      // setTimeout(() => {
      //   this.loading = false
      //   this.onRefresh()
      // }, 2000);
      batchAction(data).then(response => {
        //释放loadding
        if (response.code == 200) {
          this.loading = false
          this.onRefresh()
        } else {
          this.msgError(response.msg)
          this.loading = false
        }
      }).catch(() => {
        this.msgError('服务异常，请稍后再试')
        this.loading = false
      })

    },
    confirm () {
      this.batchSubmit()
    },
    /*********************
     * @function checkAll
     * @desc 全选
     */
    checkAll () {
      if (this.selections.length === this.dataList.length || this.selections.length === 10) {
        this.selections = []
      } else {
         if (this.dataList.length > 10) {
          this.msgWarning('一次最多选择10条数据处理')
          this.selections = this.deepClone(this.dataList.slice(0, 10))
        } else {
          this.selections = this.deepClone(this.dataList)
        }
      }
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
          width: 4.43rem;
          height: .8rem;
          .el-popper{
            width: 100%;
            .el-select-dropdown__wrap{
              margin-right: 0;
              margin-bottom: 0;
            }
          }
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
    &.common{
       &::after{
        background-color: #2272DE;
      }
    }
    &.urgent{
       &::after{
        background-color: #FF8438;
      }
    }
    &.important{
      &::after{
        background-color: #BF8AFF;
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
        width: .43rem;
        height: .43rem;
        margin-right: .11rem;
        padding-top: .05rem;
      }
      .title{
        flex: 1;
        font-weight: 600;
        color: #303133;
        word-break: break-all;
        margin-right: .27rem;
      }
      .state{
        font-weight: 400;
        font-size: .37rem;
        line-height: .53rem;
        // padding-top: .05rem;
      }
      .level{
        line-height: .53rem;
        border-radius: .05rem;
        font-weight: 400;
        padding: .05rem .11rem;
        font-size: .27rem;
        &.urgent{
          background-color: rgba($color: #FF8438, $alpha: .14);
          color: #FF8438;
        }
        &.important{
          background-color: rgba($color: #CD82EF, $alpha: .14);
          color: #CD82EF;
        }
      }
    }
    .body{
      font-size: .4rem;
      // text-align: justify;
      word-break: break-all;
      color: #8a8282;
      padding: 0 .21rem .21rem;
      &.isbatchMode{
        padding-left: .75rem;
      }
      .cell{
        display: flex;
        align-items: flex-start;
        // justify-content: space-between;
        margin-bottom: .16rem;
        font-weight: 400;
        padding-left: .54rem;
        box-sizing: border-box;
        line-height: .53rem;
        .label{
          width: 1.53rem;
          // background-color: blue;
          min-width: 1.53rem;
          // text-align: justify;
          // text-align-last: justify;
          color: #606266;
          font-size: .37rem;
          margin-right: .32rem;
          height: .53rem;
          font-weight: 400;
          // &::after{
          //   display: inline-block;/*行内元素*/
          //   content: '';
          //   width: 100%;/*可以挤掉文字，保证不跟文字在同一行*/
          //   height: 0;
          //   visibility: hidden;
          // }
        }
        .value{
          font-size: .37rem;
          color:#303133;
        }
      }
    }
  }
  .batchBtn{
    // position: fixed;
    right: .32rem;
    position: absolute;
    width: 3.33rem;
    height: 1.17rem;
    line-height: 1.17rem;
    background: #2272DE;
    box-shadow: 0px .26rem .32rem 0 #D5DEE8;
    border-radius: .59rem;
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
  
  .batchMode{
    width: 100%;
    height: 1.7rem;
    background-color: #fff;
    display: flex;
    align-items: center;
    font-weight: 400;
    font-size: .37rem;
    padding: 0 .32rem;
    box-sizing: border-box;
    white-space: nowrap;
    box-shadow: 0px -2px 10px 0px rgba(227, 227, 227, 0.7);
    position: relative;
    z-index: 10;
    // box-shadow: 10px -10px 5px #888888;
    .checkbox{
      flex: 1;
      height: .55rem;
      display: inline-flex;
      align-items: center;
      >span{
        display: inline-flex;
        align-items: center;
        i{
          margin-right: .16rem;
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
      }
    }
    .total{
      .count{
        font-weight: 600;
        color: #2272DE;
        font-size: .43rem;
      }
    }
    .btn{
      width: 3.33rem;
      min-width: 3.33rem;
      height: 1.17rem;
      line-height: 1.17rem;
      background-color: #2272DE;
      box-shadow: 0px .05rem .32rem 0 #D5DEE8;
      border-radius: .59rem;
      color: #fff;
      text-align: center;
      margin: 0 .27rem 0 .43rem;
      user-select: none;
      &.disabled{
        opacity: .5;
      }
    }
    .el-icon-close{
      font-size: .43rem;
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