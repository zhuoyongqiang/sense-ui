<template>
  <div class="wrapper">
    <div class="container-wrapper">
      <navbar currentPage="流程中心" :hasBack="true"></navbar>
      <div class="main" v-loading="loading">
        <div class="mine">
          <div class="header">
            <span class="title">常用流程 |</span>
            <el-button @click="setting" type="primary" v-show="!isSetting">设置</el-button>
            <el-button @click="saveSetting" type="primary" v-show="isSetting">保存</el-button>
            <el-button @click="cancelSetting" type="danger" v-show="isSetting">取消</el-button>
          </div>
          <i class="tip" style="margin-bottom: 20px" v-show="!isSetting">可点击设置按钮编辑快捷流程的快速入口，拖动有效面板可调整位置与排序。</i>
          <i class="tip" style="margin-bottom: 20px" v-show="isSetting">勾选卡片成为快速入口，按住拖动可调整顺序。</i>
          <vab-draggable class="panel-content" filter=".addquickPanel" :disabled="draggableDisabled" v-bind="dragOptions" :move="onMove" :list="myiconList">
            <div class="panel-div" v-for="item in myiconList" :key="item.id">
              <div class="panel" @click="quickOnclick(item)" :style="{'cursor': isSetting ? 'move' : 'pointer'}">
                <el-image :src="baseFilePath + item.image">
                  <img slot="error" class="image-slot" src="@/assets/icons/default_application.png">
                </el-image>
                <!-- <img :src="item.image"> -->
                <span>{{item.name}}</span>
                <i @click.stop="removeQuickLan(item)" class="el-icon-remove" v-show="isSetting" style="color: #ff4949; cursor: pointer"></i>
              </div>
            </div>
            <div class="panel-div addquickPanel" v-show="isSetting && myiconList.length < 12">
              <div class="panel">
              </div>
            </div>
          </vab-draggable>
        </div>
        <div class="all">
          <div class="header-container">
            <div class="title">全部流程</div>
            <div class="input-wrapper">
              <el-input class="search"
                placeholder="请输入流程名称进行搜索"
                prefix-icon="el-icon-search"
                v-model="searchInput"
                clearable>
              </el-input>
            </div>
          </div>
          <!-- <i class="tip" v-show="isSetting">可通过点击面板，点亮收藏图标，将快捷流程添加至快速入口，反之取消收藏，将流程从快速入口中移除</i> -->
          <div class="menu">
            <el-breadcrumb>
              <el-breadcrumb-item v-for="item in breadCrumbList" :key="item.name" @click.native="changeBread(item)" :class="{active: breadActive === item.name}">{{item.name}}</el-breadcrumb-item>
            </el-breadcrumb>
          </div>
          <div class="panel-content all-content" v-loading="iconLoading">
            <div class="panel-div" v-for="item in iconList" :key="item.id">
              <!-- <el-tooltip class="item" :disabled="!isSetting" effect="dark" :content="`点击可${item.saved ? '从快速入口移除' : '加入快速入口'}`" placement="top"> -->
                <div class="panel" :style="{'cursor': isSetting && item.saved ? 'default' : 'pointer'}" @click="panelOnclick(item)">
                  <el-image :src="baseFilePath + item.image">
                    <!-- <div slot="error" class="image-slot">
                      <i class="el-icon-picture-outline"></i>
                    </div> -->
                    <img slot="error" class="image-slot" src="@/assets/icons/default_application.png">
                  </el-image>
                  <span>{{item.name}}</span>
                  <i v-show="isSetting" :class="item.saved ? 'el-icon-success' : 'el-icon-circle'"></i>
                </div>
              <!-- </el-tooltip> -->
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {listCommonLink,selectByUserList,saveByUser} from "@/api/home/commonLink";
import VabDraggable from 'vuedraggable'
import navbar from '@/views/home/component/navbar'
export default {
  name: 'commomLink',
  components: {
    VabDraggable,
    navbar
  },
  data() {
    return {
      baseFilePath: undefined,
      loading: false,
      iconLoading: false,
      draggableDisabled: true, // 是否禁用拖拽功能
      isSetting: false, // 是否启用设置功能
      searchInput: '',
      myiconList:[], // 快速入口数组
      iconList: [], // 快捷流程数组
      originquickList: [], // 源快速入口列表
      originList: [], // 源快捷流程列表
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
    // 请求数据字典，获取流程类型
    this.queryDict()
    this.getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
      this.queryselectByUserList()
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
          this.iconList = this.originList.filter(v => v.name.includes(val))
          if (!this.iconList.length) {
            this.msgError('未搜索到内容')
          }
        } else {
          this.iconList = this.originList
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
    getWindowTitle() {
      return "流程中心"
    },
    onMove (e) {
      console.log(e);
      //不允许停靠
      if (!e.relatedContext.element) return false;
      //false表示阻止拖拽
      return true;
    },
    // 返回首页
    goBackIndex () {
      this.$router.push({ path: "/home/index" });
    },
    // 请求数据字典，获取流程类型
    queryDict () {
      let obj = {};
      this.getDicts('info_commin_link_types').then(resp => {
        if (resp.code === 200) {
            resp.data.map((e) => {
              this.breadCrumbList.push({
                ...e,
                name: e.dictLabel
              })
              obj[e.dictValue] = e.dictLabel;
            })
          this.ITEM_LINKTYPE = obj
        }
      })
    },
    // 获取当前用户的常用快捷应用
    queryselectByUserList () {
      this.loading = true
      selectByUserList().then(response => {
        this.myiconList = response.map((model) => {
          // this.myiconImageUrlList.push(model.url+model.name);
          return {
            id:model.id,
            image:model.image,
            url:model.url,
            name:model.name,
            order:model.order
            // status: this.ITEM_STATUS.QUICK
          }
        })
        // this.myiconList.push({
        //   id: 'fff',
        //   url: 'ffff',
        //   name: '撒大发送到发送到付所多发所多付付付付付付付付付付付付付付付付付'
        // })
        this.originquickList = this.deepClone(this.myiconList)
        // 请求所有快捷流程列表
        this.loadAllData()
      }).catch(err => {
        this.loading = false
      })
    },
    // 获取所有流程应用
    loadAllData(item){
      let data={};
      data.pageNum = 1;
      data.pageSize = 1000;
      if (item) {
        data.typeId = item.dictValue
      }
      listCommonLink(data).then(response => {
        this.iconList = response.rows.map((model) => {
          return {
            image:model.image,
            url:model.url,
            name:model.name,
            id:model.id,
            order:model.order,
            saved: this.myiconList.some(v => v.name === model.name && v.url === model.url)
          }
        })
        // this.iconList.push({
        //   id: 'fff',
        //   url: 'ffff',
        //   name: '撒大发送到发送到付所多发所多付付付付付付付付付付付付付付付付付'
        // })
        this.originList = this.deepClone(this.iconList)

        this.loading = false
        this.iconLoading = false
      }).catch(err => {
        this.loading = false
        this.iconLoading = false
      })
    },
    // 根据当前收藏状态分发添加或移除快捷入口操作，由于页面上有保存按钮，此步做暂存操作
    quickStarClick (item) {
      // if (item.status === this.ITEM_STATUS.QUICK) {
      //   item.status = this.ITEM_STATUS.DELETE
      // } else if (item.status === this.ITEM_STATUS.ADD) {
      //   item.status = this.ITEM_STATUS.UNQUICK
      // } else if (item.status === this.ITEM_STATUS.DELETE) {
      //   item.status = this.ITEM_STATUS.QUICK
      // }
      if (item.saved) {
        return
      }
      if (!item.saved && this.myiconList.length >= 12) {
        this.msgError('常用流程最多增加至12个')
        return
      }
      item.saved = true
      if (item.saved) {
        this.myiconList.push(item)
      } else {
        // this.myiconList.splice(this.myiconList.findIndex(m => m.id === item.id), 1)
      }
    },
    // 快捷流程点击事件
    panelOnclick (item) {
      if (this.isSetting) {
        this.quickStarClick(item)
      } else {
        console.warn('item', item)
        window.open(item.url, '_blank')
      }

    },
    // 快速入口快捷流程点击事件
    quickOnclick (item) {
      if (!this.isSetting) {
        window.open(item.url, '_blank')
      }
    },
    // 保存操作
    async saveSetting () {
      console.warn(this.myiconList)
      if (JSON.stringify(this.myiconList) === JSON.stringify(this.originquickList)) {
        this.isSetting = false
        this.draggableDisabled = true
        return
      }
      try {
        const data = this.myiconList.map((m, i) => {
          return {
            linkId: m.id,
            order: i + 1
          }
        })
        await this.saveInterface(data)
        // console.warn(resp)
        this.msgSuccess("保存成功")
        this.isSetting = false
        this.loading = false
        this.draggableDisabled = true
        this.originquickList = this.deepClone(this.myiconList)
      } catch (err) {
        this.msgError("保存失败")
        this.loading = false
      }
    },
    // 从快速入口移除
    removeQuickLan (item) {
      this.myiconList.splice(this.myiconList.findIndex(m => m.id === item.id), 1)
      const iconIndex = this.iconList.findIndex(k => k.name === item.name && k.url === item.url)
      if (iconIndex >= 0) {
        this.iconList[iconIndex].saved = false
      }
      console.warn('originquickList', this.originquickList)
    },
    // 保存接口
    saveInterface (data) {
      this.loading = true
      return saveByUser(data).then((resp) => {
        if (resp.code === 200) {
          return Promise.resolve(resp)
        } else {
          return Promise.reject(resp)
        }
      }).catch(err => {
        return Promise.reject(err)
      })
    },

    // 开启快捷入口设置
    setting () {
      this.isSetting = true
      this.draggableDisabled = false
    },
    // 取消编辑
    cancelSetting () {
      console.warn('originquickList', this.originquickList)
      console.warn('originList', this.originList)
      this.isSetting = false
      this.draggableDisabled = true
      this.myiconList = this.deepClone(this.originquickList)
      this.iconList = this.deepClone(this.originList)
    },
    // 切换面包屑
    changeBread (item) {
      if (this.iconLoading || item.name === this.breadActive) {
        return
      } else {
        this.searchInput = ''
        this.breadActive = item.name
        this.iconList = []
        this.iconLoading = true
        this.loadAllData(item)
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
    .el-image{
      width: 32px;
      height: 32px;
      border-radius: 50%;
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
      // text-align: justify;
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
      box-shadow: none;
      border: 1px dashed #ccc;
      cursor: default;
      background-color: #F5F6FA;
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
