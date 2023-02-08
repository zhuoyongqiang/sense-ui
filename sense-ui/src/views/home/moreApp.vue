<template>
  <div class="wrapper">
    <div class="container-wrapper">
      <navbar currentPage="应用中心" :hasBack="true"></navbar>
      <div class="main" v-loading="loading">
        <div class="mine">
          <div class="header">
            <span class="title">常用应用 |</span>
            <el-button @click="setting" type="primary" v-show="!isSetting">设置</el-button>
            <el-button @click="saveSetting" type="primary" v-show="isSetting">保存</el-button>
            <el-button @click="cancelSetting" type="danger" v-show="isSetting">取消</el-button>
          </div>
          <i class="tip" style="margin-bottom: 20px" v-show="!isSetting">可点击设置按钮编辑常用应用，拖动有效面板可调整位置与排序。</i>
          <i class="tip" style="margin-bottom: 20px" v-show="isSetting">勾选卡片成为常用应用，按住拖动可调整顺序。</i>
          <vab-draggable class="panel-content" filter=".addquickPanel" :disabled="draggableDisabled" v-bind="dragOptions" :move="onMove" :list="quickappList">
            <div class="panel-div" v-for="item in quickappList" :key="item.id">
              <div class="panel unLink" @click="quickOnclick(item)" :style="{'cursor': isSetting ? 'move' : 'pointer'}" :class="{'isLink': item.isDockFinish === '1'}">
                <el-image :src="baseFilePath + item.profileUrl" fit="contain">
                  <img slot="error" class="image-slot" src="@/assets/images/home/app_temp.png">
                </el-image>
                <!-- <img :src="item.image"> -->
                <span>{{item.appName}}</span>
                <i @click.stop="removeQuickLan(item)" class="el-icon-remove" v-show="isSetting" style="color: #ff4949; cursor: pointer"></i>
              </div>
            </div>
            <div class="panel-div addquickPanel" v-show="isSetting && quickappList.length < 8">
              <div class="panel">
              </div>
            </div>
          </vab-draggable>
        </div>
        <div class="all">
          <div class="header-container">
            <div class="title">全部应用</div>
            <div class="input-wrapper">
              <el-input class="search"
                placeholder="请输入应用名称进行搜索"
                prefix-icon="el-icon-search"
                v-model="searchInput"
                clearable>
              </el-input>
            </div>
          </div>
          <!-- <i class="tip" v-show="isSetting">可通过点击面板，点亮收藏图标，将应用添加为常用应用，反之取消收藏，将应用从常用应用中移除</i> -->
          <div class="menu">
            <el-breadcrumb>
              <el-breadcrumb-item v-for="item in breadCrumbList" :key="item.name" @click.native="changeBread(item)" :class="{active: breadActive === item.name}">{{item.name}}</el-breadcrumb-item>
            </el-breadcrumb>
            <div class="right-part">
              <div class="isLink">已接入系统</div>
              <div class="unLink">未接入系统</div>
            </div>
          </div>
          <div class="panel-content all-content" v-loading="appLoading">
            <div class="panel-div" v-for="item in appList.filter(v => v.isDockFinish === '1')" :key="item.appSn">
              <!-- <el-tooltip class="item" effect="dark" :disabled="!isSetting" :content="`点击可${item.saved ? '从常用应用移除' : '加入常用应用'}`" placement="top"> -->
                <div class="panel isLink" :style="{'cursor': isSetting && item.saved ? 'default' : 'pointer'}" @click="panelOnclick(item)">
                  <!-- <el-image :src="item.imgLink" v-show="isEXit(item.imgLink)"> -->
                  <el-image :src="baseFilePath + item.profileUrl" fit="cover">
                    <!-- <div slot="error" class="image-slot">
                      <i class="el-icon-picture-outline"></i>
                    </div> -->
                    <img slot="error" class="image-slot" src="@/assets/images/home/app_temp.png">
                  </el-image>
                  <span>{{item.appName}}</span>
                  <i v-show="isSetting" :class="item.saved ? 'el-icon-success' : 'el-icon-circle'"></i>
                </div>
              <!-- </el-tooltip> -->
            </div>
            <div class="unLinkContent">
              <div class="panel-div" v-for="item in appList.filter(v => v.isDockFinish === '2')" :key="item.appSn">
                <!-- <el-tooltip class="item" effect="dark" :disabled="!isSetting" :content="`点击可${item.saved ? '从常用应用移除' : '加入常用应用'}`" placement="top"> -->
                  <div class="panel unLink" :style="{'cursor': isSetting && item.saved ? 'default' : 'pointer'}" @click="panelOnclick(item)">
                    <!-- <el-image :src="item.imgLink" v-show="isEXit(item.imgLink)"> -->
                    <el-image :src="baseFilePath + item.profileUrl" fit="cover">
                      <!-- <div slot="error" class="image-slot">
                        <i class="el-icon-picture-outline"></i>
                      </div> -->
                      <img slot="error" class="image-slot" src="@/assets/images/home/app_temp.png">
                    </el-image>
                    <span>{{item.appName}}</span>
                    <i v-show="isSetting" :class="item.saved ? 'el-icon-success' : 'el-icon-circle'"></i>
                  </div>
                <!-- </el-tooltip> -->
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>

  </div>

</template>
<script>
import {appType, findApp, updateUserApp} from "@/api/home/iam";
import VabDraggable from 'vuedraggable'
import navbar from '@/views/home/component/navbar'
export default {
  name: "moreApp",
  components: {
    VabDraggable,
    navbar
  },
  data() {
    return {
      baseFilePath: undefined,
      loading: false,
      appLoading: false,
      draggableDisabled: true, // 是否禁用拖拽功能
      isSetting: false, // 是否启用设置功能
      searchInput: '',
      quickappList:[], // 常用应用数组
      appList: [], // 所有应用数组
      originquickList: [], // 源常用应用列表
      originList: [], // 源所有应用列表
      breadActive: '全部',
      breadCrumbList: [
        {
          name: '全部'
        }
      ],
      timer: null,
      ITEM_LINKTYPE: {}
    }
  },
  created() {
    // 请求所有应用类别
    this.queryappType()
    this.getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
      // 请求常用应用
      this.loading = true
      this.queryQuickapp()
    });
  },
  mounted() {
  },
  watch: {
    searchInput (val) {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => {
        console.warn(val)
        if (val) {
          this.appList = this.originList.filter(v => v.appName.includes(val))
          if (!this.appList.length) {
            this.msgError('未搜索到内容')
          }
        } else {
          this.appList = this.originList
        }
      }, 1000)
    }
  },
  computed: {
    dragOptions() {
      return {
        animation: 600,
        group: 'description',
      }
    },
  },
  methods: {
    test(){
       window.open("http://192.168.0.100:8180/OAuthDemo/oauth/login", '_blank')
    },
    getWindowTitle() {
      return "我的应用"
    },
    queryappType () {
      let obj = {}
      appType().then(resp => {
        if (resp.code === 200) {
            resp.data.map((e) => {
              this.breadCrumbList.push({
                ...e,
                name: e.appTypeName
              })
              obj[e.appTypeSn] = e.appTypeName;
            })
          this.ITEM_LINKTYPE = obj
        }
      })
    },
    // 返回首页
    goBackIndex () {
      this.$router.push({ path: "/home/index" });
    },
    // 图片是否存在
    isEXit (imgUrl) {
      const ImgObj = new Image()
      ImgObj.src = imgUrl
      ImgObj.onload = (res) => {
        return true
      }
      ImgObj.onerror = function(err) {
        return false
      }
    },
    // 请求常用应用
    queryQuickapp () {
      findApp({
        common: '1'
      }).then(resp => {
        console.log(resp)
        if (resp.code === 200) {
          this.quickappList = resp.data
          this.originquickList = this.deepClone(this.quickappList)
          this.queryAllapp()
        }
      }).catch(err => {
        this.loading = false
      })
    },
    // 请求所有引用
    queryAllapp (item) {
      let data = {
        common: '2'
      }
      if (item) {
        data.appTypeSn = item.appTypeSn
      }
      findApp(data).then(resp => {
        if (resp.code === 200) {
          this.appList = resp.data.map(v => {
            return {
              ...v,
              saved: this.quickappList.some(k => k.appSn === v.appSn)
            }
          })
          console.warn('1', this.appList)
          this.originList = this.deepClone(this.appList)
        }
        this.loading = false
        this.appLoading = false
      }).catch(() => {
        this.loading = false
        this.appLoading = false
      })
    },
    onMove (e) {
      console.log(e);
      //不允许停靠
      if (!e.relatedContext.element) return false;
      //false表示阻止拖拽
      return true;
    },
    // 根据当前收藏状态分发添加或移除常用应用操作，由于页面上有保存按钮，此步做暂存操作
    quickStarClick (item) {
      if (item.saved) {
        return
      }
      if (!item.saved && this.quickappList.length >= 8) {
        this.msgError('常用应用最多增加至8个')
        return
      }
      item.saved = !item.saved
      if (item.saved) {
        this.quickappList.push(item)
      } else {
        // this.quickappList.splice(this.quickappList.findIndex(m => m.appSn === item.appSn), 1)
      }
    },
    // 所有应用点击事件
    panelOnclick (item) {
      if (this.isSetting) {
        this.quickStarClick(item)
      } else {
        console.warn('item', item)
        window.open(item.ssoLink, '_blank')
      }

    },
    // 常用应用点击事件
    quickOnclick (item) {
      if (!this.isSetting) {
        window.open(item.ssoLink, '_blank')
      }
    },
    // 保存操作
    async saveSetting () {
      if (JSON.stringify(this.quickappList) === JSON.stringify(this.originquickList)) {
        this.isSetting = false
        this.draggableDisabled = true
        return
      }
      try {
        const data = this.quickappList.map((m, i) => {
          return {
            appSn: m.appSn,
            order: i + 1
          }
        })
        await this.saveInterface(data)
        // console.warn(resp)
        this.msgSuccess("保存成功")
        this.isSetting = false
        this.loading = false
        this.draggableDisabled = true
        this.originquickList = this.deepClone(this.quickappList)
      } catch (err) {
        this.msgError("保存失败")
        this.loading = false
      }
    },
    // 从常用应用移除
    removeQuickLan (item) {
      this.quickappList.splice(this.quickappList.findIndex(m => m.appSn === item.appSn), 1)
      const iconIndex = this.appList.findIndex(k => k.appName === item.appName && k.ssoLink === item.ssoLink)
      if (iconIndex >= 0) {
        this.appList[iconIndex].saved = false
      }
      console.warn('originquickList', this.originquickList)
    },
    // 保存接口
    saveInterface (data) {
      this.loading = true
      return updateUserApp(data).then((resp) => {
        if (resp.code === 200) {
          return Promise.resolve(resp)
        } else {
          return Promise.reject(resp)
        }
      }).catch(err => {
        return Promise.reject(err)
      })
    },
    // 开启常用应用设置
    setting () {
      this.isSetting = true
      this.draggableDisabled = false
    },
    // 取消编辑
    cancelSetting () {
      this.isSetting = false
      this.draggableDisabled = true
      this.quickappList = this.deepClone(this.originquickList)
      this.appList = this.deepClone(this.originList)
    },
    // 切换面包屑
    changeBread (item) {
      if (item.name === this.breadActive) {
        return
      } else {
        this.searchInput = ''
        this.breadActive = item.name
        this.appList = []
        this.appLoading = true
        this.queryAllapp(item)
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
    background-color: #F5F6FA;
  }
  .container-wrapper{
    width: 1200px;
    margin: 0 auto;
  }
  .windowTitle2 {
    margin: 0 auto;
    height: 60px;
    // line-height: 60px;
    color: #666666;
    font-size: 12px;
    text-align: right;
    display: flex;
    justify-content: space-between;
    align-items: center;
    .back{
      height: 36px;
      line-height: 36px;
      width: 64px;
      text-align: center;
      // line-height: auto;
      border: 1px solid #DCDFE6;
      color:#333;
      background-color: #fff;
      cursor: pointer;
      padding:0 6px;
      border-radius: 4px;
      font-size: 14px;
    }
  }

  .el-breadcrumb {
    line-height: 60px;
  }
  .panel-content{
    display: flex;
    margin: 10px -14px;
    flex-wrap: wrap;
    align-content:flex-start;
    &.all-content{
      min-height: 500px;
    }
  }
  .panel-div{
    width: 16.6%;
    padding: 0 14px;
    box-sizing: border-box;
    margin-bottom: 20px;
    &:not(.addquickPanel){
      .panel{
        &:hover{
          position: relative;
          top: -5px;
        }
      }
    }
  }
  .panel{
    background-color: #fff;
    font-size: 13px;
    cursor: pointer;
    display: flex;
    align-items: center;
    // padding: 12px 16px;
    padding:0 12px;
    height: 64px;
    box-sizing: border-box;
    border-radius: 6px;
    // background-color: rgba(#000, .1);
    box-shadow: 0px 2px 4px 0px rgba(195, 195, 195, 0.5);
    &.unLink{
      position: relative;
      &::before{
        position: absolute;
        top: 50%;
        left: 0;
        height: 20px;
        width: 3px;
        border-radius: 0 100px 100px 0;
        background-color: #FF7235;
        transform: translate(0, -50%);
        content: '';
      }
    }

    &.isLink{
      position: relative;
      &::before{
        position: absolute;
        top: 50%;
        left: 0;
        height: 20px;
        width: 3px;
        border-radius: 0 100px 100px 0;
        background-color: #2272DE;
        transform: translate(0, -50%);
        content: '';
      }
    }

    .el-image{
      width: 32px;
      height: 32px;
      // border-radius: 50%;
      margin-right: 10px;
      ::v-deep .image-slot{
        width: 100%;
        height: 100%;
        text-align: center;
        line-height: 32px;
        i{
          font-size: 24px;
          vertical-align: middle;
        }
      }
    }
    span{
      // display: inline-block;
      flex: 1;
      line-height: 20px;
      max-height: 40px;
      text-overflow: -o-ellipsis-lastline;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      padding-right: 2px;
    }
    i{
      margin-left: 2px;
      margin-top: 10px;
      align-self: flex-start;
      font-size: 18px;
      &.el-icon-success{
        color:#BDD4F5;
        font-size: 18px;
      }
      &.el-icon-circle{
        width: 16px;
        height: 16px;
        border-radius: 50%;
        border: 2px solid #2272DE;
      }
      // &:hover{
      //   color: #333;
      // }
    }
  }
  .addquickPanel{
    .panel{
      background-color: #F5F6FA;
      box-shadow: none;
      border: 1px dashed #ccc;
      cursor: default;
    }
  }
  .tip{
    font-size: 14px;
    margin-top: 12px;
    display: inline-block;
    // color:#9f9f9f;
    color: #939393;
    font-style:normal;
  }
  .title{
    font-weight: bold;
    font-size: 16px;
    color:#303133;
  }
  .header-container{
    display: flex;
    // justify-content: space-between;
    align-items: center;
    .input-wrapper{
      // flex: 1;
      width: 300px;
      margin-left: 20px;
      .search{
        // border-radius: 16px;
        display: flex;
        align-items: center;
        ::v-deep input{
          border-radius: 16px!important;
        }
      }
    }
  }
  .menu{
    display: flex;
    justify-content: space-between;
    align-items: center;
    .right-part{
      display: flex;
      >div{
        font-size: 14px;
        color:#303133;
        &.isLink{
          position: relative;
          padding-left: 7px;
          &::before{
            position: absolute;
            top: 50%;
            left: 0;
            height: 10px;
            width: 3px;
            // border-radius: 0 4px 4px 0;
            background-color: #2272DE;
            transform: translate(0, -50%);
            content: '';
          }
        }
        &.unLink{
          margin-left: 16px;
          position: relative;
          padding-left: 7px;
          &::before{
            position: absolute;
            top: 50%;
            left: 0;
            height: 10px;
            width: 3px;
            // border-radius: 0 4px 4px 0;
            background-color: #FF7235;
            transform: translate(0, -50%);
            content: '';
          }
        }
      }
    }
  }
  .unLinkContent{
    width: 100%;
    display: flex;
    flex-wrap: wrap;
    align-content:flex-start;
  }
  .empty{
    width: 200px;
    height: 60px;
    margin: 30px auto;
  }
  .main ::v-deep .el-breadcrumb__item{
    .el-breadcrumb__inner{
      color: #606266;
      font-size: 14px;
      &:hover{
        color: #606266;
      }
    }
    >span{
      &:first-child{
        cursor: pointer!important;
      }
    }
    &.active{
        >span{
        &:first-child{
          cursor: default!important;
        }
      }
      .el-breadcrumb__inner{
        color: #2172DE;
        text-decoration: underline;
      }
    }
  }
  ::v-deep .mine .el-button{
    margin-left: 10px;
    &.el-button--primary{
      background-color: rgba(#1890ff, .1);
      border-color: transparent;
      color: #1890ff;
    }
    &.el-button--danger{
      background-color: rgba(#ff4949, .1);
      border-color: transparent;
      color: #ff4949;
    }
  }
</style>
