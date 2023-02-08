<template>
  <div class="navbar-wrapper">
    <el-breadcrumb separator-class="el-icon-arrow-right">
      <el-breadcrumb-item v-for="(name, index) in pageList" :key="name">
        <img class="icon" :src="name | icon" v-if="index === 0"><span>{{name}}</span>
      </el-breadcrumb-item>
    </el-breadcrumb>
    <div class="back" v-show="hasBack" @click="goBackIndex">返回</div>
  </div>
</template>
<script>
export default {
  props: {
    hasBack: {
      type: Boolean,
      default: true
    },
    currentPage: {
      default: []
    }
  },
  computed: {
    pageList () {
      console.log(this.currentPage)
      if (!this.currentPage) return []
      if (!Array.isArray(this.currentPage)) {
        return [this.currentPage]
      } else {
        return this.currentPage
      }
    }
  },
  filters: {
    icon (name) {
      switch (name) {
        case '待办中心':
          return require("@/assets/images/home/navbarIcon/todo.png");
        case '新闻中心':
          return require("@/assets/images/home/navbarIcon/news.png");
        case '流程中心':
          // return '../../../assets/images/home/navbarIcon/process.png'
          return require("@/assets/images/home/navbarIcon/process.png");
        case '应用中心':
          return require("@/assets/images/home/navbarIcon/app.png");
        case '设置密码': case '修改密码':
          return require("@/assets/images/home/navbarIcon/pwd.png");
        case '密保设置':
          return require("@/assets/images/home/navbarIcon/setPwdques.png");
        case '待办委托':
          return require("@/assets/images/home/navbarIcon/task.png");
        default:
          return require("@/assets/images/home/navbarIcon/default.png");
      }
    }
  },
  methods: {
    // 返回首页
    goBackIndex () {
      this.$router.push({ path: "/home/index" });
    }
  },
}
</script>
<style lang="scss" scoped>
  .navbar-wrapper{
    height: 60px;
    min-height: 60px;
    font-size: 14px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    .navbarlist{
      display: flex;
      align-items: center;
      font-size: 14px;
      font-weight: 600;
      color: #303133;
      .icon{
        width: 16px;
        height: 16px;
        margin-right: 6px;
      }
    }
    ::v-deep .el-breadcrumb{
      font-size: 14px;
      height: 20px;
      line-height: 20px;
      .el-breadcrumb__item{
        .el-breadcrumb__inner.is-link, .el-breadcrumb__inner a{
          color: #606266!important;
        }
        &:first-child{
          .el-breadcrumb__inner, .el-breadcrumb__inner a{
            font-weight: 600!important;
            color: #303133!important;
          }
        }
        .el-breadcrumb__inner{
        }
      }
      .icon{
        font-size: 0;
        width: 16px;
        height: 16px;
        margin-right: 6px;
        vertical-align: -3px;
      }
    }
    .back{
      width: 64px;
      text-align: center;
      // line-height: auto;
      border: 1px solid #DCDFE6;
      color:#333;
      background-color: #fff;
      cursor: pointer;
      padding:6px 6px;
      border-radius: 4px;
      font-size: 14px;
      &:active{
        opacity: .5;
      }
    }
  }
</style>