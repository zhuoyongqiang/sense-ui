<!-- 新建委托 pageMode(new) | 委托详情 pageMode(!==new) -->
<template>
  <div class="wrapper" ref="wrapper" v-loading="loading" :style="{'overflow-y': (treeData.show || datetimeData.show || loading) ? 'hidden' : 'auto' }">
    <div class="notice" v-show="next"><i class="el-icon-warning"></i>温馨提示：当前委托与其他委托，时间区间上存在冲突！</div>
    <!-- <div class="header" v-show="pageMode !== 'new'">
      <div class="icon"><img :src="require('@/assets/images/mobile/window/approveNavbar.png')"></div>
      <div class="title">{{'委托事项 ' + new Date().format('yyyy-MM-dd')}}</div>
    </div> -->
    <div class="header" v-show="pageMode !== 'new'">
      <div class="icon"><img class="icon" v-if="getStatus(profileStatus).icon" :src="require('@/assets/images/mobile/' + getStatus(profileStatus).icon + '.png')"></div>
      <div class="title">{{'委托事项 ' + createTime.slice(0, 10)}}</div>
      <div class="statusDiv"><span class="status" :class="getStatus(profileStatus).className">{{getStatus(profileStatus).text}}</span></div>
    </div>
    <div class="client-panel"><span class="label">委托人</span><span class="value">{{userName}}</span></div>
    <div class="system-panel">
      <div class="title">{{pageMode === 'new' ? '选择' : ''}}所属系统</div>
      <div class="content" ref="ul">
        <div class="content-block" ref="block">
          <div class="item flex1" v-for="item in sysList" :key="item.sn" @click="sysItemClick(item)">
            <span class="label">{{item.name}}</span><i v-show="sysSelections.includes(item.sn)" class="el-icon-check"></i>
          </div>
          <div class="item setting" v-show="(pageMode === 'new' && sysSelections.includes('APP013')) || (pageMode !== 'new' && workOrders.length)" @click="workOrderSetting">
            <i class="el-icon-setting"></i><span class="label">工单设置</span><span class="num" v-show="workOrders.length">{{workOrders.length}}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="entrust-panel">
      <div class="cell">
        <div class="label">委托已有的待办</div>
        <el-switch
          :disabled="pageMode !== 'new'"
          v-model="entrust"
          :active-text="entrust ? '开启' : '关闭'"
          active-color="#70A5E3"
          inactive-color="#B9B9B9">
        </el-switch>
      </div>
      <div class="cell">
        <div class="label">开始时间</div>
        <div class="value" v-if="pageMode === 'new'" @click="startTimeClick(startTime)" :class="{'placeholder': !startTime}">{{startTime ? (new Date(startTime).format('yyyy-MM-dd hh:mm')) : '请选择'}}<i class="el-icon-arrow-right"></i></div>
        <div class="value" v-else>{{startTime}}</div>
      </div>
      <div class="cell">
        <div class="label">结束时间</div>
        <div class="value" v-if="pageMode === 'new'" @click="endTimeClick(endTime)" :class="{'placeholder': !endTime}">{{endTime ? (new Date(endTime).format('yyyy-MM-dd hh:mm')) : '请选择'}}<i class="el-icon-arrow-right"></i></div>
        <div class="value" v-else>{{endTime}}</div>
      </div>
      <div class="cell">
        <div class="label">被委托人</div>
        <div class="value" v-if="pageMode === 'new'"  @click="entrustPicker" :class="{'placeholder': !entrustUser.label}">{{nameformat(entrustUser.label) || '请选择'}}<i class="el-icon-arrow-right"></i></div>
        <div class="value" v-else>{{entrustUser.label}}</div>
      </div>
    </div>
    <!-- <div class="email-panel" v-if="pageMode !== 'new'">
      <div class="cell flex">
        <div class="label">邮件通知</div>
        <el-switch
          :disabled="pageMode !== 'new'"
          v-model="email"
          active-color="#70A5E3"
          inactive-color="#B9B9B9">
        </el-switch>
      </div>
      <div v-show="email" class="cell flex">
        <div class="label">发件人邮箱</div>
        <div class="value" v-if="pageMode === 'new'">
          <el-input v-model="email_send_username" placeholder="请输入"></el-input>
        </div>
        <div class="value" v-else>{{email_send_username}}</div>
      </div>
      <div v-show="email && pageMode === 'new'" class="cell flex">
        <div class="label">邮箱密码</div>
        <div class="value">
          <el-input type="password" v-model="email_send_password" placeholder="请输入"></el-input>
        </div>
      </div>
      <div v-show="email" class="cell flex" @click="receiverPicker">
        <div class="label">收件人</div>
        <div class="value" v-if="pageMode === 'new'" :class="{'placeholder': !receiver.length}">{{!receiver.length ? '请选择' : ''}}
          <span class="tags">
            <el-tag
              v-for="tag in receiver"
              :key="tag.name"
              closable
              :type="tag.type"
               @close="receiverDelete(tag)">
              {{nameformat(tag.label)}}
            </el-tag>
          </span>
          <i class="el-icon-arrow-right"></i>
        </div>
        <div class="value" v-else>{{receiver.map(tag => nameformat(tag.label)).join('，')}}</div>
      </div>
      <div v-show="email" class="cell flex" @click="copyPicker">
        <div class="label">抄送</div>
        <div class="value" v-if="pageMode === 'new'" :class="{'placeholder': !copy.length}">{{!copy.length ? '请选择(非必填)' : ''}}
          <span class="tags">
            <el-tag
              v-for="tag in copy"
              :key="tag.name"
              closable
              :type="tag.type"
              @close="copyDelete(tag)">
              {{nameformat(tag.label)}}
            </el-tag>
          </span>
          <i class="el-icon-arrow-right"></i>
        </div>
        <div class="value" v-else>{{copy.map(tag => nameformat(tag.label)).join('，')}}</div>
      </div>
      <div v-show="email" class="cell">
        <div class="label">邮件主题</div>
        <div class="value">
          <el-input
            type="textarea"
            :rows="2"
            :placeholder="pageMode !== 'new' ? '' : '请输入'"
            :disabled="pageMode !== 'new'"
            v-model.trim="emailTheme">
          </el-input>
        </div>
      </div>
      <div v-show="email" class="cell">
        <div class="label">邮件内容</div>
        <div class="value">
          <el-input
            type="textarea"
            :rows="2"
            :placeholder="pageMode !== 'new' ? '' : '请输入'"
            :disabled="pageMode !== 'new'"
            v-model.trim="emailContent">
          </el-input>
        </div>
      </div>
    </div> -->
    <div class="entrustDesc-panel">
      <div class="cell">
        <div class="label">委托说明</div>
        <div class="value">
          <el-input
            :disabled="pageMode !== 'new'"
            type="textarea"
            :rows="2"
            :placeholder="pageMode !== 'new' ? '' : '请输入(选填)'"
            v-model.trim="remark">
          </el-input>
        </div>
      </div>
    </div>
    <div class="btn-panel">
      <el-button v-if="pageMode === 'new'" @click="submit" class="btn" :disabled="disabled">确认</el-button>
      <el-button v-if="cando && profileStatus === 1" @click="cancel" class="btn cancelbtn">撤销</el-button>
      <el-button v-if="cando && (profileStatus === 2 || profileStatus === 3)" @click="deleteProfile" class="btn deletebtn">删除</el-button>
    </div>
    <span v-if="isChange" />

    <!-- 日期时间选择器 -->
    <datetime-picker v-if="pageMode === 'new'"
      :data="datetimeData"
      @cancel="hideDateTimePicker"
      @confirm="dateTimePickerConfirm"
    />
    <!-- 人员选择器 -->
    <tree v-if="pageMode === 'new'" :data="treeData"
      @onConfirm="treeonConfirm"></tree>
    <!-- 工单设置 -->
    <workOrderSetting :data="woSettingData"
      @onConfirm="workOrderConfirm"></workOrderSetting>
    <!-- 撤销弹框 -->
    <el-dialog
      :visible.sync="dialogVisible"
      width="83%"
      top="24vh!important"
      :center="true"
      class="profile-dialog"
      :show-close="false">
      <span v-show="diallogContent">{{diallogContent}}</span>
      <span v-show="!diallogContent">是否{{profileStatus === 1 ? '撤销' : '删除'}}待办委托？</span>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="dialogConfirm()">确 定</el-button>
      </span>
    </el-dialog>
    <!-- 提示 -->
    <el-dialog
      :visible.sync="dialogAlert"
      width="50%"
      top="24vh!important"
      :center="true"
      class="alert-dialog"
      :close-on-click-modal="false"
      :show-close="false">
      <div><i :class="alertMsg.includes('成功') ? 'el-icon-success' : 'el-icon-error'"></i></div>
      <span slot="footer" class="dialog-footer" :class="alertMsg.includes('成功') ? 'success' : 'error'">
        {{alertMsg}}
      </span></el-dialog>
  </div>
</template>
<script>
import store from '@/store'
import {getInfo} from "@/api/login";
import {getToken} from "@/utils/auth";
import '@/store/REM.js'
import {allApp} from "@/api/console/system/app";
import {add,findById,revoke, remove,workTypeAll,listByEntrustId,againAction} from "@/api/console/layout/workentrust/index";
import DatetimePicker from '@/views/mobile/components/DatetimePicker/index'
import tree from '@/views/mobile/components/userPicker/index'
import workOrderSetting from '@/views/mobile/components/workOrderSetting/index'
export default {
  name: 'mobileProfileDetail',
  components: {
    DatetimePicker,
    tree,
    workOrderSetting
  },
  data() {
    return {
      alertMsg: '',
      dialogAlert: false,
      cando: false, // 判断当前用户是否为委托人，是的话提供可操作按钮
      pageMode: '', // new(新建-可编辑)
      profileStatus: null, // 委托状态
      loading: false, // 加载状态
      // disabled: true, // 提交按钮是否可操作
      createTime: '', // 创建时间
      userName: null,
      sysList: [], //  所属系统列表
      sysSelections: [], // 勾选的系统列表
      workOrders: [], // 工单
      entrust: true, // 是否开启委托 | 默认开启
      entrustUser: {}, // 被委托人
      startTime: '', // 开始时间
      endTime: '', // 开始时间
      email: false, // 是否开启邮件通知
      email_send_username: '', // 发件人
      email_send_password: '', // 邮箱密码
      receiver: [ // 收件人
      ],
      copy: [], // 抄送
      emailTheme: '', // 邮件主题
      emailContent: '', // 邮件内容
      remark: '', // 委托说明
      next: false, // 提交标识，初始置为false，当存在冲突委托时置为true，重新提交
      profileExit: false, // 是否存在冲突委托
      curentTime: '', // 标记日期选择器当前操作的日期字段
      datetimeData: { // 日期时间选择器配置
        value: new Date(),
        type: 'datetime',
        title: '选择时间',
        minDate: new Date(),
        showToolbar: true,
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        visibleItemCount: 7,
        itemHeight: 44,
        formatter: this.formatter,
        show: false
      },
      treeData: { // 人员选择器配置
        show: false,
        title: ''
      },
      currentTree: '', // 标记人员选择器当前操作的人员选择字段
      woSettingData: { // 工单设置配置
        show: false,
        edit: false,
        filter: [],
        workOrderList: []
      },
      dialogVisible: false, // 撤销弹框显示、隐藏
      diallogContent: '', // 提示框内容
      isChange: false
    }
  },
  beforeCreate() {
    if (!this.$route.params.profileId) {
      document.title = "新建委托";
    } else {
      document.title = '待办委托明细'
    }
  },
  created() {
    const _this = this
    window.onresize = function () {
      console.warn('123高度变化')
      // this.$refs.wrapper.scrollTo = 0
      _this.isChange = !_this.isChange
    }
    if (this.isUserLogin) {
      console.warn('this.$route.params.profileId', this.$route.params.profileId)
      if (!this.$route.params.profileId) {
        this.pageMode = 'new'
        // 初始化请求系统列表
        this.querySystemList()
        // 获取当前用户信息
        getInfo().then(resp => {
          if (resp.code === 200) {
            this.userName = resp.user.nickName
            this.email_send_username = resp.user.email
          }
        })
        // 请求机构树
        this.queryOrgtree()
      } else {
        this.loading = true
        // 初始化请求系统列表
        this.querySystemList()
      }
    }
  },
  computed: {
    isUserLogin() {
      if (getToken()) {
        return true;
      }
      return false;
    },
    disabled () {
      // 必填项
      // 选择所属系统
      // 填写开始时间
      // 填写结束时间
      // 选择被委托人
      if (this.sysSelections.length && this.startTime && this.endTime && this.entrustUser.label) {
        return false
      } else {
        console.log('true')
        return true
      }
    }
  },
  methods: {
    /**********
     * @desc 请求全机构人员树
     * @function treeselectNewPro
     */
    queryOrgtree() {
      store.dispatch('orgTree/TreeselectNewPro').then(res => {
        // 获取机构树
      }).catch(err => {
      })
    },
    /***********************
     * @function getInfo
     * @desc 获取当前用户信息
     */
    // getUserInfo () {
    //   getInfo().then(resp => {
    //     if (resp.code === 200) {
    //       this.userName = resp.user.nickName
    //     }
    //   })
    // },
    /************************
     * @function querySystemList
     * @desc 请求所属系统列表
     */
    querySystemList () {
      allApp({}).then(response => {
        if(response.length>0){
          this.sysList = []
          for(let i in response){
            if(response[i].status==0)continue;
            if(response[i].isEntrust==0)continue;
            let obj={
              ...response[i],
              sn:response[i].sn,
              name:response[i].name
            }
            this.sysList.push(obj)
          }
          if (this.pageMode !== 'new') {
            this.queryDetail(this.$route.params.profileId)
          } else {
            this.$nextTick(() => {
              console.log('1', this.$refs.block)
              this.$refs.ul.style.height = this.$refs.block.offsetHeight + 'px'
            })
          }
        }
      })
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
          return {
            className: '',
            icon: '',
            text: ''
          }
          break
      }
    },
    /***********************
     * @function queryDetail
     * @desc 根据路由参数，获取委托详情
     */
    queryDetail (id) {
      findById(id).then(resp => {
        this.loading = false
        if (resp.code === 200) {
          this.profileStatus = resp.data.status
          this.sysSelections = resp.data.appsList
          this.woSettingData.workOrderList = resp.data.taskTypeList.map(v => {
            return {
              appId: v.split('_')[0],
              sn: v.split('_')[1]
            }
          })
          if (resp.data.appsList.includes('APP013')) {
            this.woSettingData.edit = false
            this.woSettingData.filter = this.sysList.filter(v => v.sn === 'APP013')
          }
          this.workOrders = resp.data.taskTypeList
          this.$nextTick(() => {
            console.log('1', this.$refs.block)
            this.$refs.ul.style.height = this.$refs.block.offsetHeight + 'px'
          })
          this.entrust = resp.data.entrustWork
          this.startTime = resp.data.startDate
          this.endTime = resp.data.endDate
          this.createTime = resp.data.createTime
          this.entrustUser = {
            id: resp.data.entrustUserName,
            label: resp.data.entrustUserNickname,
            name: resp.data.entrustUserNickname
          }
          this.email = resp.data.emailEnable
          if (resp.data.emailEnable) {
            this.emailTheme = resp.data.emailTheme || '暂无'
            this.emailContent = resp.data.emailContent || '暂无'
            if (resp.data.sendEmailText) {
              this.receiver = resp.data.sendEmailText.split(';').map(v => {
                return {
                  label: v
                }
              })
            }
            if (resp.data.sendCCEmailText) {
              this.copy = resp.data.sendCCEmailText.split(';').map(v => {
                return {
                  label: v
                }
              })
            }
          }
          this.remark = resp.data.remark || '暂无'
          this.next = resp.data.next
          // 获取当前用户信息，获取委托人是否为本人
          getInfo().then(respInfo => {
            if (respInfo.code === 200) {
              if (resp.data.userName === respInfo.user.userName) {
                this.userName = resp.data.nickName + '(本人)'
                this.cando = true
              } else {
                this.userName = resp.data.nickName + '(他人)'
              }
            }
          })
        } else {
          this.msgError('数据异常')
        }
      })
    },
    /************************
     * @function sysItemClick
     * @desc 所属系统点击事件
     */
    sysItemClick (item) {
      if (this.pageMode !== 'new') {
        return
      }
      const index = this.sysSelections.findIndex(v => v === item.sn)
      console.warn('sysItemClick', index)
      if (index >= 0) {
        this.sysSelections.splice(index, 1)
      } else {
        this.sysSelections.push(item.sn)
      }
      if (this.sysSelections.includes('APP013')) {
        this.woSettingData.edit = true
        this.woSettingData.filter = this.sysList.filter(v => v.sn === 'APP013')
      }
      this.$nextTick(() => {
        console.log('1', this.$refs.block)
        this.$refs.ul.style.height = this.$refs.block.offsetHeight + 'px'
      })
    },
    /*************************
     * @function workOrderSetting
     * @desc 工单设置
     */
    workOrderSetting () {
      this.woSettingData.show = true
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
    },
    /***************************
     * @function dateTimePickerConfirm
     * @desc 时间选择器确定事件
    */
    dateTimePickerConfirm (value) {
      console.log('value', value)
      let res = new Date(value).getTime()
      console.log(new Date(res))
      this[this.curentTime] = res
      this.datetimeData.show = false
      if (this.startTime && this.endTime && new Date(this.startTime).format('yyyy-MM-dd hh:mm') >= new Date(this.endTime).format('yyyy-MM-dd hh:mm')) {
        // 如果开始时间大于或等于结束时间，重置清空结束时间
        this.endTime = ''
      }
    },
    /********
     * @function startTimeClick
     * @desc 开始时间点击事件
     */
    startTimeClick () {
      if (this.pageMode !== 'new') {
        return
      }
      this.curentTime = 'startTime'
      this.datetimeData.minDate = null
      this.datetimeData.value = this.startTime ? new Date(this.startTime) : new Date()
      this.datetimeData.show = true
    },
    /***********
     * @function endTimeClick
     * @desc 结束时间点击事件
     */
    endTimeClick () {
      if (this.pageMode !== 'new') {
        return
      }
      this.curentTime = 'endTime'
      if (this.startTime) {
        this.datetimeData.minDate = new Date(new Date(this.startTime).getTime() + 1000 * 60)
        this.datetimeData.value = new Date(new Date(this.startTime).getTime() + 1000 * 60)
      } else {
        this.datetimeData.minDate = new Date()
        this.datetimeData.value = new Date()
      }
      if (this.endTime) {
        this.datetimeData.value = new Date(this.endTime)
      }
      this.datetimeData.show = true
    },
    /***************
     * @function entrustPicker
     * @desc 被委托人选择框点击事件
     */
    entrustPicker () {
      if (this.pageMode !== 'new') {
        return
      }
      this.currentTree = 'entrust'
      this.treeData.title = '选择被委托人'
      this.treeData.show = true
    },
    /*****************
     * @function receiverPicker
     * @desc 收件人选择框点击事件
     */
    receiverPicker () {
      if (this.pageMode !== 'new') {
        return
      }
      this.currentTree = 'receiver'
      this.treeData.title = '选择收件人'
      this.treeData.show = true
    },
    /*******************
     * @function receiverDelete
     * @desc 收件人删除事件
     */
    receiverDelete (tag) {
      this.receiver.splice(this.receiver.indexOf(tag), 1);
    },
    /*******************
     * @function receiverDelete
     * @desc 抄送人删除事件
     */
    copyDelete (tag) {
      this.copy.splice(this.copy.indexOf(tag), 1);
    },
    /******************
     * @function copyPicker
     * @desc 抄送选择框点击事件
     */
    copyPicker () {
      if (this.pageMode !== 'new') {
        return
      }
      this.currentTree = 'copy'
      this.treeData.title = '选择抄送人'
      this.treeData.show = true
    },
    /*****************
     * @function treeonConfirm
     * @desc 人员选择器确定事件
     */
    treeonConfirm (val) {
      console.warn('treeonConfirm', val)
      switch (this.currentTree) {
        // 当前标记人员选择器为被委托人时，由于是单选操作，直接做赋值
        case 'entrust':
          this.entrustUser = {
            ...val,
            id: val.id,
            label: val.label,
            name: val.nickName
          }
          break
        // 当前标记人员选择器为收件人或抄送人时，由于是多选操作，需要做数组push和去重
        case 'receiver': case 'copy':
          if (!this[this.currentTree].some(v => v.label === val.label )) {
            this[this.currentTree].push({
              ...val,
              id: val.id,
              label: val.label,
              name: val.nickName,
              type: 'info'
            })
          }
          break
        default:
          break
      }
     
      // this.entrustUser = val.label
    },
    /********************
     * @function workOrderConfirm
     * @desc 工单设置确定按钮
     */
    workOrderConfirm (val) {
      console.warn('workOrderConfirm', val)
      this.workOrders = val
    },
    /***********************
     * @function nameformat
     * @desc 不影响pc端展示的前提下，格式化展示名称效果
     */
    nameformat (name) {
      console.warn('name,', name)
      if (name && name.includes('@')) {
        const reg = /[\u4e00-\u9fa5]+/g;
        console.warn('march', name.match(reg))
        return name.match(reg).join("，")
      } else {
        return name
      }
    },
    /********************
     * @function submit
     * @desc 新建委托
     * @param sendCCEmailAddressList | 抄送人id | Array< caigl@xib.com.cn >
     * @param sendCCEmailText | 抄送人名称 | Array< 蔡桂林<caigl@xib.com.cn> >
     * @param sendEmailAddressList | 收件人id | Array < caigl@xib.com.cn >
     * @param sendEmailText | 收件人名称 | Array < 蔡桂林<caigl@xib.com.cn> >
     */
    submit () {
      this.loading = true
      let param = {
        appsList: this.sysSelections,
        appsName: this.sysList.reduce((arr, cur) => {
          if (this.sysSelections.includes(cur.sn)) {
            console.log('curname', cur.name)
            arr.push(cur.name)
          }
          return arr
        }, []).join(','),
        checkAppList: this.sysSelections,
        emailEnable: this.email,
        // startDate: new Date(this.startTime).format('yyyy-MM-dd hh:mm:ss'),
        startDate: new Date(this.startTime).format('yyyy-MM-dd hh:mm') + ':00',
        endDate: new Date(this.endTime).format('yyyy-MM-dd hh:mm') + ':00',
        entrustUserName: this.entrustUser.staffAccount,
        entrustUserNickname: this.entrustUser.name,
        entrustWork: this.entrust,
        remark: this.remark,
        next: this.next,
        // appsList: ["APP007", "APP020", "APP004", "APP013"]
        // appsName: "采购管理,智能报销,人力资源,协同办公"
        // checkAppList: ["APP007", "APP020", "APP004", "APP013"]
        // emailContent: "test邮件内容"
        // emailEnable: true
        // emailTheme: "test邮件主题"
        // endDate: "2021-09-27 00:00:00"
        // entrustUserName: "caigl"
        // entrustUserNickname: "蔡桂林"
        // entrustWork: true
        // next: false
        // remark: "test委托说明"
        // sendCCEmailAddressList: ["caigl@xib.com.cn"]
        // sendCCEmailText: "蔡桂林<caigl@xib.com.cn>"
        // sendEmailAddressList: ["caigl@xib.com.cn"]
        // sendEmailText: "蔡桂林<caigl@xib.com.cn>"
        // startDate: "2021-09-25 00:00:00"
        // taskTypeList: ["APP013_10002", "APP013_10001"]
      }
      if (this.sysSelections.includes('APP013')) {
        param.taskTypeList = this.workOrders.map(v => v.appId + '_' + v.sn)
      }
      // if (this.email) {
      //   param.email_send_username = this.email_send_username
      //   param.email_send_password = this.email_send_password
      //   param.emailTheme = this.emailTheme
      //   param.emailContent = this.emailContent
      //   param.sendCCEmailAddressList = this.copy.map(v => v.email)
      //   param.sendCCEmailText = this.copy.map(v => v.label).join(',')
      //   param.sendEmailAddressList = this.receiver.map(v => v.email)
      //   param.sendEmailText = this.receiver.map(v => v.label).join(',')
      // }
      console.warn('param', param)
      // setTimeout(() => {
      //   this.msgSuccess('新建成功')
      //   this.loading = false
      // }, 2000);
      add(param).then(response => {
        this.loading = false
        console.warn((response.code === 1000003))
        console.warn((response))
        if(response.code===200) {
          this.pageMode = ''
          this.profileStatus = ''
          this.alertMsg = '新建成功'
          this.dialogAlert = true
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.$router.go(-1)
          }, 1000);
        } else if(response.code === 1000003) {
          // 存在冲突
          this.profileExit = true
          this.diallogContent = response.msg
          this.dialogVisible = true
          console.warn('dialogVisible', this.dialogVisible)
          // this.$confirm(response.msg, '温馨提示', {
          //   confirmButtonText: '继续执行',
          //   cancelButtonText: '取消执行',
          //   type: 'warning'
          // }).then(() => {
          //   this.form.next = true;
          //   this.submit();
          // }).catch(() => {
          //   this.form.next = false;
          // });
        }else{
          this.alertMsg = response.msg
          this.dialogAlert = true
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.dialogAlert = false
          }, 1000);
        }
      }).catch((err) => {
        this.alertMsg = '新建失败'
        this.dialogAlert = true
        const timer = setTimeout(() => {
          clearTimeout(timer)
          this.dialogAlert = false
        }, 1000);
        this.loading = false
      })
    },
    /***************************
     * @function cancel
     * @desc 撤销操作,唤起撤销弹框
     */
    cancel () {
      this.dialogVisible = true
    },
    /*******************
     * @function dialogConfirm
     * @desc 根据profileExit的布尔值判断，当前弹框属于需要根据委托状态调用接口的弹框，还是用于直接调用提交接口的弹框
     * @desc 根据委托状态，值为1时即为正在委托，调用撤销接口
     * @desc 根据委托状态，值为2时即为已撤销，调用删除接口
     */
    dialogConfirm () {
      if (this.profileExit) {
        this.next = true
        this.dialogVisible = false
        this.submit()
      } else {
        if (this.profileStatus === 1) {
          this.loading = true
          revoke(this.$route.params.profileId).then((resp) => {
            if (resp.code && resp.code === 200) {
              this.loading = false
              this.profileStatus = 2
              this.dialogVisible = false
              this.pageMode = ''
              this.profileStatus = ''
              this.alertMsg = '撤销成功'
              this.dialogAlert = true
              const timer = setTimeout(() => {
                clearTimeout(timer)
                this.$router.go(-1)
              }, 1000);
            } else {
              this.alertMsg = resp.msg
              this.dialogAlert = true
              const timer = setTimeout(() => {
                clearTimeout(timer)
                this.dialogAlert = false
              }, 1000);
            }
          }).catch(() => {
            this.alertMsg = '撤销失败'
            this.loading = false
            this.dialogAlert = true
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.dialogAlert = false
            }, 1000);
          })
        } else {
          this.loading = true
          remove(this.$route.params.profileId).then((resp) => {
            if (resp.code && resp.code === 200) {
              this.loading = false
              this.dialogVisible = false
              this.pageMode = ''
              this.profileStatus = ''
              this.alertMsg = '删除成功'
              this.dialogAlert = true
              const timer = setTimeout(() => {
                clearTimeout(timer)
                this.$router.go(-1)
              }, 1000);
            } else {
              this.alertMsg = resp.msg
              this.dialogAlert = true
              const timer = setTimeout(() => {
                clearTimeout(timer)
                this.dialogAlert = false
              }, 1000);
            }
          }).catch(() => {
            this.alertMsg = '删除失败'
            this.loading = false
            this.dialogAlert = true
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.dialogAlert = false
            }, 1000);
          })
        }
      }
    },
    /***************************
     * @function cancel
     * @desc 删除操作,唤起删除弹框
     */
    deleteProfile () {
      this.dialogVisible = true
    }
  },
}
</script>
<style lang="scss" scoped>
  .wrapper{
    background-color: #F7F8FA;
    width: 100%;
    height: 100%;
    // padding-top: .267rem;
    .notice{
      font-size: .32rem;
      background-color: #fff8e6;
      line-height: .667rem;
      padding: 0 .32rem;
      color:#ffba00;
      i{
        margin-right: .11rem;
      }
    }
    .header{
      position: relative;
      padding: .32rem .32rem 0;
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
    // .header{
    //   position: relative;
    //   padding: .053rem .32rem 0;
    //   font-size: .37rem;
    //   display: flex;
    //   align-items: flex-start;
    //   .icon{
    //     margin-right: .11rem;
    //     height: .667rem;
    //     display: flex;
    //     align-items: center;
    //     img{
    //       width: .48rem;
    //       height: .48rem;
    //     }
    //   }
    //   .title{
    //     flex: 1;
    //     line-height: .667rem;
    //     word-break: break-all;
    //     font-weight: 600;
    //     color: #303133;
    //   }
    // }
    .client-panel{
      display: flex;
      justify-content: space-between;
      background-color: #fff;
      box-shadow: 0px 2px 10px 1px #ECEEF4;
      border-radius: .11rem;
      padding: .35rem .32rem;
      // margin: 0 .32rem .267rem;
      margin: .267rem .32rem;
      font-weight: 400;
      font-size: .43rem;
      .label{
        color: #303133;
      }
      .value{
        color:#606266;
      }
    }
    .system-panel{
      box-shadow: 0px 2px 10px 1px #ECEEF4;
      border-radius: .11rem;
      background-color: #fff;
      margin: 0 .32rem .267rem;
      padding:0 .32rem;
      .title{
        font-weight: 400;
        color: #303133;
        font-size: .43rem;
        padding: .35rem 0;
        border-bottom: 1px solid #F2F2F3;
      }
      .content{
        height: 0;
        overflow: hidden;
        transition: height .5s;
        transform: translate3d(0,0,0);
        >div{
          padding: .11rem 0;
        }
      }
      .item{
        font-weight: 400;
        color: #606266;
        font-size: .37rem;
        display: flex;
        align-items: center;
        padding: .21rem .32rem;
        &.flex1{
          .label{
            flex: 1;
          }
        }
        &.setting{
          color: #2272DE;
        }
        .el-icon-check{
          color: #2272DE;
          font-weight: bold;
        }
        .el-icon-setting{
          color: #2272DE;
          margin-right: .11rem;
        }
        .num{
          margin-left: .21rem;
          background: #2272DE;
          border-radius: .21rem;
          width: .667rem;
          line-height: .37rem;
          color:#fff;
          text-align: center;
        }
      }
    }
    .entrust-panel{
      box-shadow: 0px 2px 10px 1px #ECEEF4;
      border-radius: .11rem;
      background-color: #fff;
      margin: 0 .32rem .267rem;
      padding:0 .32rem;
      .cell{
        display: flex;
        padding: .32rem 0;
        justify-content: space-between;
        font-weight: 400;
        color: #303133;
        font-size: .43rem;
        border-bottom: 1px solid #F2F2F3;
        .label{
          white-space: nowrap;
        }
        .value{
          flex: 1;
          text-align: right;
          color: #606266;
          &.placeholder{
            color:#C0C4CC;
            i{
              font-size: .43rem;
              margin-left: .11rem;
            }
          }
        }
      }
    }
    .email-panel{
      box-shadow: 0px 2px 10px 1px #ECEEF4;
      border-radius: .11rem;
      background-color: #fff;
      margin: 0 .32rem .267rem;
      padding:0 .32rem;
      .cell{
        padding: .32rem 0;
        font-weight: 400;
        color: #303133;
        font-size: .43rem;
        border-bottom: 1px solid #F2F2F3;
        &.flex{
          display: flex;
          align-items: center;
          justify-content: space-between;
        }
        .label{
          white-space: nowrap;
          margin-right: .32rem;
        }
        .value{
          flex: 1;
          text-align: right;
          color: #606266;
           display: flex;
          align-items: center;
          justify-content: flex-end;
          &.placeholder{
            color:#C0C4CC;
            i{
              font-size: .43rem;
              margin-left: .11rem;
            }
          }
          ::v-deep .el-tag{
            margin: .11rem .11rem;
          }
          ::v-deep .el-textarea{
            margin-top: .32rem;
            textarea{
              color:#606266;
              background-color: #fff;
              border: none;
              padding: 0;
              font-size: .43rem;
              font-weight: 400;
              resize: none;
              &::placeholder{
                color:#C0C4CC;
              }
            }
          }
        }
      }
      ::v-deep .el-input{
        input{
          border-color: transparent;
          text-align: right;
          font-size: .43rem;
        }
      }
    }
    .entrustDesc-panel{
      box-shadow: 0px 2px 10px 1px #ECEEF4;
      border-radius: .11rem;
      background-color: #fff;
      margin: 0 .32rem .267rem;
      padding:0 .32rem;
      .cell{
        padding: .32rem 0;
        font-weight: 400;
        color: #303133;
        font-size: .43rem;
        border-bottom: 1px solid #F2F2F3;
        &.flex{
          display: flex;
          justify-content: space-between;
        }
        .value{
          color: #606266;
          &.placeholder{
            color:#C0C4CC;
            i{
              font-size: .43rem;
              margin-left: .11rem;
            }
          }
          ::v-deep .el-textarea{
            margin-top: .32rem;
            textarea{
              &:disabled, &[disabled] {
                -webkit-text-fill-color: #606266;
                opacity: 1;
              }
              color:#606266!important;
              border: none;
              padding: 0;
              font-size: .43rem;
              background-color: #fff;
              font-weight: 400;
              resize: none;
              &::placeholder{
                color:#C0C4CC;
              }
            }
          }
        }
      }
    }
    .btn-panel{
      display: flex;
      align-items: center;
      padding: 0 .32rem .64rem;
      box-sizing: border-box;
      background-color: #F7F8FA;
      .btn{
        padding: 0;
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
        &.is-disabled{
          opacity: .3;
        }
      }
      .cancelbtn{
        background-color: #fff;
        border: 1px solid #2272DE;
        color: #2272DE;
      }
      .deletebtn{
        color:#FF5555;
        background-color: #F1E0E0;
        border: 1px solid transparent;
        box-shadow: 0px .05rem .21rem 0 #F1E0E0;
      }
    }
  }
  ::v-deep .el-loading-mask{
    position: fixed;
  }
  ::v-deep .el-switch{
    // 移动端div点击有蓝色透明的阴影效果的解决方法
    -webkit-tap-highlight-color: transparent;
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    user-select:none;
    -webkit-tap-highlight-color: rgba(255,0,0,0);
    .el-switch__core{
      width: 1.39rem!important;
      height: .7rem;
      border-color: transparent !important;
      border-radius: .35rem;
      &::after{
        top: .11rem;
        width: .48rem;
        height: .48rem;
        top: 50%;
        // right: .11rem!important;
        // left: auto!important;
        transform: translateY(-50%);
      }
    }
    &.is-checked{
      .el-switch__core{
        background-color: rgba($color: #2272DE, $alpha: .2)!important;
        &::after{
          background-color: #2272DE;
          margin-left: -.53rem;
        }
      }
    }
  }
  ::v-deep .profile-dialog .el-dialog{
    border-radius: .21rem;
    font-size: 0;
    overflow: hidden;
    .el-dialog__header{
     padding: 0
    }
    .el-dialog__body{
      text-align: center;
      padding: .64rem .64rem;
      font-weight: 400;
      color: #303133;
      font-size: .43rem;
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
            color:#FF5555;
            border-left: 1px solid #F2F2F3;
            box-sizing: border-box;
          }
        }
      }
    }
  }

  ::v-deep .alert-dialog .el-dialog{
    border-radius: .21rem;
    font-size: 0;
    overflow: hidden;
    box-shadow: none;
    .el-dialog__body{
      text-align: center;
      i{
        font-size: 2rem;
        &.el-icon-success{
          color: #67C23A;
        }
        &.el-icon-error{
          color:#FF5555;
        }
      }
    }
    .el-dialog__header{
     padding: 0;
    }
    .el-dialog__footer{
      padding: 0;
      .dialog-footer{
        font-size: .43rem;
        height: 1.28rem;
        display: inline-block;
        &.success{
          color:#67C23A;
        }
        &.error{
          color:#FF5555;
        }
      }
    }
  }
</style>