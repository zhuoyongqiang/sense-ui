<template>
  <div class="userPicker-wrapper" :class="{'hidden' : !show}" v-show="data.show" @click.self="clickTarget">
    <transition name="slide-bottom">
      <div class="main" v-show="show">
        <div class="header-panel">
          <div class="title">{{data.title}}</div>
          <i class="el-icon-close" @click="close"></i>
        </div>
        <div class="search-panel">
          <el-input
            :disabled="treeLoading"
            placeholder="根据关键字快速搜索"
            v-model.trim="selectUserText"
            suffix-icon="el-icon-search"
            @change="selectUser"
          ></el-input>
          <!-- <div class="cancel" v-show="selectUserText.length" @click="selectUserText = ''">取消</div> -->
          <div class="cancel search" v-show="selectUserText.length" @click="onSearch">搜索</div>
        </div>
        <div class="scroll-view"  ref="scrollView" v-loading="treeLoading" :style="{'overflow-y': treeLoading ? 'hidden' : 'auto'}">
          <el-tree
            class="filter-tree treemaxHeightDiv"
            :data="orgTree"
            :props="defaultProps"
            :check-on-click-node="false"
            :empty-text="orgErr ? '' : '暂无记录'"
            :render-content="orgRenderContent"
            :filter-node-method="filterNode"
            ref="orgTree">
          </el-tree>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import {
  listPro,
  listByOrgdept,
  listContactsUserList,
  deleteContactsUserList,
  insertContactsUserList,
} from "@/api/console/system/user";
import { getGroup } from "@/api/console/system/group";
import { treeselectPro } from "@/api/console/system/dept";
import scrollUtils from "@/utils/scroll";

export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      treeLoading: false,
      show: false,
      baseNode: null,
      scroller: null,
      baseTreeList: [],
      treeList: [],
      orgOnlyTree: [],
      defaultProps: {
        children: "children",
        label: "label",
      },
      userList: [],
      loadData: [],
      cheackNode: undefined,
      checkList: [],
      selectUserText: "",
      searchTimer: null,
      orgErr: false,
      resetTree: 1,
    };
  },
  beforeDestroy() {
    clearTimeout(this.searchTimer)
  },
  watch: {
    selectUserText (val) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        clearTimeout(this.searchTimer)
        if (val) {
        } else {
          this.resetTree++
          // this.$nextTick(() => {
          //   scrollUtils.setScrollTop(this.scroller, 0);
          // })
        }
      }, 1500);
    },
    orgTree: {
      handler () {
        scrollUtils.setScrollTop(this.scroller, 0);
      },
      deep: true
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
    cheackNode (val) {
      if (this.data.show && val) {
        this.$emit('onConfirm', val)
        this.close()
      }
    }
  },
  mounted() {
    // this.getData();
    this.$nextTick(() => {
      this.scroller = scrollUtils.getScrollEventTarget(this.$refs.scrollView);
    })
  },
  computed: {
    orgTree: {
      get () {
          const org = this.deepClone(this.$store.state.orgTree.orgData)
          console.log('1', org)
          if (typeof(org) !== 'string' || org.length > 0) {
            this.treeLoading = false
          } 
          if (org === 'Error') {
            this.orgErr = true
          } else {
            if (Array.isArray(org) && this.resetTree) {
              console.log('????', org)
              const newData = org
              console.log('newData:', newData)
              return newData
            } else {
              return []
            }
          }
      },
      set (val) {
        console.log('set', val)
      }
    }
  },
  methods: {
     /*************
     * @desc 格式化机构树
     * @function initTree
     */
    initTree(data, prevNode) {
      for (let i = 0; i < data.length; i++) {
        let node = data[i];
        // 递归结束条件
        if ((node.children && node.children.length) || (node.users && node.users.length)) {
          let user = (node.users || []).map((v) => {
            return {
              ...v,
              label: v.nickName,
              prevNode: { ...prevNode, [node.id]: node.label } ,
              group: false
            };
          });
          if (node.children) {
            this.initTree(node.children, { ...prevNode, [node.id]: node.label } )
          }
          node.children = [...(node.children || []), ...user ];
        }
      }
      return data;
    },
    reset () {
      console.warn('reset')
      this.selectUserText = ''
      this.cheackNode = ''
      this.loadData = []
      this.orgTree = this.deepClone(this.orgOnlyTree)
    },
    /***********
     * @desc 搜索
     * @function onSearch
     */
    onSearch () {
      if (this.selectUserText && this.selectUserText.length > 1) {
        this.$refs.orgTree.filter(this.selectUserText);
      } else if (!this.selectUserText) {
        // this.orgTree = this.deepClone(this.originTree)
        this.resetTree++
      } else {
        this.$message.warning('请输入两个字符以上的内容进行搜索')
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
    selectUser() {},
    /*************
     * @desc 过滤节点方法，查找组织下的人员
     * @function filterNode
     */
    filterNode(value,data,node) {
      if(!value){
        return true;
      }
      let level = node.level;
      let _array = [];//这里使用数组存储 只是为了存储值。
      this.getReturnNode(node,_array,value);
      let result = false;
      _array.forEach((item)=>{
        result = result || item;
      });
      return result;
    },
    getReturnNode(node,_array,value){
      let isPass = node.data &&  node.data.label && node.data.label.indexOf(value) !== -1;
      isPass?_array.push(isPass):'';
      if(!isPass && node.level!=1 && node.parent){
        this.getReturnNode(node.parent,_array,value);
      }
    },
    nodePush() {
      console.log('xxx')
      if (this.cheackNode === undefined) return;
      if (this.checkList.length >= 1) {
        this.msgWarning("被委托人只能选择一个,当前选择发生变更。");
        this.checkList = [];
      }
      this.checkList.push(this.cheackNode);
    },
    // getData() {
    //   this.treeLoading = true;
    //   /** 查询部门下拉树结构 */
    //   treeselectPro().then((response) => {
    //     this.orgTree = response.data[0].children;
    //     this.orgOnlyTree = response.data[0].children;
    //     this.treeLoading = false;
    //   });
    // },
    orgRenderContent(h, { node, data, store }) {
      let renderNode;
      if(data.group===false || data.group!==undefined){
        let userTips="";
        userTips += "姓       名："+data.nickName+"\n";
        userTips += "登录账号："+data.userName+"\n";
        userTips += "邮件地址："+data.email+"\n";
          renderNode= (
            <span class="org-tree-node" style="width: 100%; height:100%;line-height: 1.17rem" on-click={() => this.tickItem(data)}>
              <i
                class="el-icon-user-solid"
                style="margin-right: 3px;color:#4b91ff;"
              ></i>
                {node.label}
            </span>
          )
      }else{
          renderNode= (
            <span class="org-tree-node">
              <span>{node.label}</span>
            </span>
          )
      }
      return renderNode
    },
    /**********
     * @desc 机构树人员点击事件
     * @function tickItem
     */
    tickItem (data) {
      console.log(data)
      this.cheackNode = data
    },
    // orgRenderContent(h, { node, data, store }) {
    //   let renderNode;

    //   if (data.user) {
    //     renderNode = (
    //       <span class="org-tree-node" style="width: 100%">
    //         <el-radio label={data} v-model={this.cheackNode} style="width: 100%; line-height: 1.17rem; display:inline-block">
    //           <i
    //             class="el-icon-user-solid"
    //             style="margin-right: 3px;color:#4b91ff;"
    //           ></i>
    //           {node.label}
    //         </el-radio>
    //       </span>
    //     );
    //   } else {
    //     renderNode = (
    //       <span class="org-tree-node">
    //         <span>{node.label}</span>
    //       </span>
    //     );
    //   }
    //   return renderNode;
    // },
    hadleNodeClick(data, obj, node) {
      console.log('data', data)
      console.log('node', node)
      if (node.expanded) {
        node.expanded = false;
        node.node.expanded = false;
      } else {
        node.expanded = true;
        node.node.expanded = true;
      }
      if (data.group === false) {
        return;
      }
      if (!data.children) {
        this.$set(data, "children", []);
      }
      let queryParams = {
        searchBaseCode: data.id,
        pageNum: 1,
        pageSize: 1000,
      };
      listByOrgdept(queryParams).then((response) => {
        var row = response.rows;
        if (row.length > 0) {
          let childrenData = data.children;
          let newchildrenData = [];
          for (var i in row) {
            // const id = data.id + "_" + userName;
            if (childrenData.some(v => v.id === row[i].userName)) {
              continue;
            }
            // this.loadData.push(id);
            var nickName = row[i].nickName + "<" + row[i].email + ">";
            var sex = row[i].sex;
            const newChild = {
              id: row[i].userName,
              label: nickName,
              group: false,
              sex: sex,
              children: [],
              user: row[i],
            };
            newchildrenData.push(newChild);
          }
          newchildrenData = newchildrenData.concat(childrenData);
          data.children = newchildrenData;
        }
      });
    }
  },
};
</script>
<style lang="scss" scoped>
.userPicker-wrapper {
  opacity: 1;
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  height: 100%;
  width: 100%;
  overflow: hidden;
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
        .el-input__suffix{
          color: #2272DE;
        }
        .el-input__icon{
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
      .cancel{
        font-weight: 400;
        color: #2272DE;
        margin-left: .21rem;
      }
    }
    .scroll-view {
      flex: 1;
      overflow-y: auto;
      .baseTree-panel {
        padding: 0 0.43rem;
        box-sizing: border-box;
        .cell {
          height: 1.17rem;
          font-size: 0.43rem;
          font-weight: 600;
          color: #606266;
          display: flex;
          justify-content: space-between;
          align-items: center;
          position: relative;
          &::after {
            position: absolute;
            background-color: #ebedf0;
            height: 1px;
            transform: scaleY(0.5);
            width: 100%;
            content: "";
            bottom: 0;
            left: 0;
          }
        }
      }
      ::v-deep .el-tree {
        font-size: 0.43rem;
        font-weight: 400;
        color: #606266;
        padding: 0 0.43rem;
        box-sizing: border-box;
        .el-tree-node__content {
          height: 1.17rem;
          width: 100%;
          display: flex;
          flex-direction: row-reverse;
          justify-content: space-between;
          align-items: center;
          position: relative;
          &:hover{
            // background-color: red;
          }
          &::after {
            position: absolute;
            background-color: #ebedf0;
            height: 1px;
            transform: scaleY(0.5);
            width: 100%;
            content: "";
            bottom: 0;
            left: 0;
          }
          .el-tree-node__expand-icon {
            &::before {
              content: "\e6df";
            }
            &.expanded {
              transform: rotate(-180deg);
            }
          }
        }
      }
    }
  }
}
::v-deep .el-loading-mask{
  top: calc(10% + 1.28rem + 1.01rem + .43rem);
}
.slide-bottom {
  &-enter-active {
    animation: slide-bottom-enter .3s both ease;
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