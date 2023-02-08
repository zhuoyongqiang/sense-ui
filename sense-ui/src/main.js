import Vue from 'vue'

import Cookies from 'js-cookie'

import Element from 'element-ui'
import './assets/styles/element-variables.scss'

import '@/assets/styles/index.scss' // global css
import '@/assets/styles/sense.scss' // sense css
import App from './App'
import store from './store'
import router from './router'
import permission from './directive/permission'

import '../public/static/ueditor/ueditor.config.js'    //引入富文本框js
import '../public/static/ueditor/ueditor.all.js'
import '../public/static/ueditor/lang/zh-cn/zh-cn.js'
import '../public/static/ueditor/ueditor.parse.min.js'

import echarts from 'echarts'                     //引入echars
Vue.prototype.$echarts = echarts


import './assets/icons' // icon
import './permission' // permission control
import { getDicts } from "@/api/console/system/dict/data";
import { getConfigKey } from "@/api/console/system/config";
import { parseTime, resetForm, addDateRange, selectDictLabel, selectDictLabels, download, handleTree } from "@/utils/sense";
import Pagination from "@/components/Pagination";
// 自定义表格工具扩展
import RightToolbar from "@/components/RightToolbar"

import vcolorpicker from 'vcolorpicker'
import Preview from '@/views/mobile/components/imgPreview/index.js'
var opts={
	mainClass : 'pswp--minimal--dark',
	barsSize : {
		top: 0,
		bottom: 0
	},
  // history: true,
	captionEl : false,
	fullscreenEl : false,
	shareEl : false,
	bgOpacity : 0.85,
	tapToClose : true,
	tapToToggleControls : false,
}
Vue.use(Preview,opts)

// 全局方法挂载
Vue.prototype.getDicts = getDicts
Vue.prototype.getConfigKey = getConfigKey
Vue.prototype.parseTime = parseTime
Vue.prototype.resetForm = resetForm
Vue.prototype.addDateRange = addDateRange
Vue.prototype.selectDictLabel = selectDictLabel
Vue.prototype.selectDictLabels = selectDictLabels
Vue.prototype.download = download
Vue.prototype.handleTree = handleTree

Vue.prototype.msgSuccess = function (msg) {
  this.$message({ showClose: true, message: msg, type: "success" });
}

Vue.prototype.msgError = function (msg) {
  this.$message({ showClose: true, message: msg, type: "error" });
}

Vue.prototype.msgWarning = function (msg) {
  this.$message({ showClose: true, message: msg, type: "warning" });
}

Vue.prototype.msgInfo = function (msg) {
  this.$message.info(msg);
}

// 全局组件挂载
Vue.component('Pagination', Pagination)
Vue.component('RightToolbar', RightToolbar)

Vue.use(vcolorpicker)

Vue.use(permission)

/**
 * If you don't want to use mock-server
 * you want to use MockJs for mock api
 * you can execute: mockXHR()
 *
 * Currently MockJs will be used in the production environment,
 * please remove it before going online! ! !
 */

Vue.use(Element, {
  size: Cookies.get('size') || 'mini' // set element-ui default size
})

// 屏蔽控制台输出
if (process.env.NODE_ENV === 'production') {
  console.log = () => {}
  console.info = () => {}
  console.warn = () => {}
  // console.error = () => {}
}

// 记录初始进入项目的页面历史记录长度
window.ghmhhistoryLength = window.history.length

Date.prototype.format = function(format)
{
 var o = {
 "M+" : this.getMonth()+1, //month
 "d+" : this.getDate(),    //day
 "h+" : this.getHours(),   //hour
 "m+" : this.getMinutes(), //minute
 "s+" : this.getSeconds(), //second
 "q+" : Math.floor((this.getMonth()+3)/3),  //quarter
 "S" : this.getMilliseconds() //millisecond
 }
 if(/(y+)/.test(format)) format=format.replace(RegExp.$1,
 (this.getFullYear()+"").substr(4 - RegExp.$1.length));
 for(var k in o)if(new RegExp("("+ k +")").test(format))
 format = format.replace(RegExp.$1,
 RegExp.$1.length==1 ? o[k] :
 ("00"+ o[k]).substr((""+ o[k]).length));
 return format;
}

Vue.config.productionTip = false

new Vue({
  el: '#app',
  router,
  store,
  render: h => h(App)
})
