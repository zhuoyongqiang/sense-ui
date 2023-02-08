<template>
  <el-dialog append-to-body :title="title" :visible.sync="showInfo" width="850px !important" :close-on-click-modal="false">
    <el-row style="height: 430px;">
      <el-col :span="12" class="maxHeig">
      <el-tabs v-model="activeName" type="border-card" @tab-click="handleClick">
        <el-tab-pane label="最近" name="recentTree">
        </el-tab-pane>
        <el-tab-pane label="组织管理" name="orgTree">
        </el-tab-pane>
        <el-tab-pane label="常用组" name="commonTree">
        </el-tab-pane>
        <!-- 历史树 -->
        <div class="content-panel" :style="{opacity: activeName === 'recentTree' ? 1 : 0, zIndex: activeName === 'recentTree' ? 10 : -1}">
          <div class="search"><el-input
              :disabled="recentTreeLoading"
              placeholder="根据关键字快速搜索"
              clearable
              v-model="selectRecentText">
            </el-input><el-button type="primary" icon="el-icon-search" @click="selectRecent">搜索</el-button></div>
          <div class="tree-panel" v-loading="recentTreeLoading">
            <el-tree
              class="filter-tree treemaxHeightDiv"
              :data="recentTree"
              show-checkbox
              node-key="id"
              :props="defaultProps"
              :check-on-click-node="false"
              :empty-text="recentTreeLoading || recentErr ? '' : '暂无记录'"
              :render-content="recentRenderContent"
              :filter-node-method="filterNode"
              @node-click="recentTreenodeClick"
              ref="recentTree">
            </el-tree>
            <div v-show="!recentTreeLoading && recentErr" class="error">
              <span>加载失败，<span class="reload" @click="reload('recent')">重新加载</span></span>
            </div>
          </div>
        </div>
        <!-- 组织树 -->
        <div class="content-panel" :style="{opacity: activeName === 'orgTree' ? 1 : 0, zIndex: activeName === 'orgTree' ? 10 : -1}">
          <div class="search"><el-input
              :disabled="treeLoading"
              placeholder="根据关键字快速搜索"
              clearable
              v-model="selectOrgText">
            </el-input><el-button type="primary" icon="el-icon-search" @click="selectUser">搜索</el-button></div>
          <div class="tree-panel" v-loading="treeLoading">
            <!-- 使用isLazy来控制懒加载树和全量树的展示，优化IE下的机构树渲染问题 -->
            <el-tree v-show="isLazy"
              class="filter-tree treemaxHeightDiv"
              :data="orgTree"
              show-checkbox
              node-key="id"
              :props="defaultPropsOrg"
              :check-on-click-node="false"
              :empty-text="treeLoading || orgErr ? '' : '暂无记录'"
              :render-content="orgRenderContent"
              :filter-node-method="filterNode"
              @node-click="orgTreenodeClick"
              @check="orgTreeCheck"
              :load="loadNode"
              lazy
              ref="orgTree">
            </el-tree>
            <!-- 搜索功能时使用全量树进行前端检索 -->
            <el-tree v-show="!isLazy && searchEnd"
              class="filter-tree treemaxHeightDiv"
              :data="orgTreeData"
              :props="defaultProps"
              show-checkbox
              node-key="id"
              empty-text="暂无记录"
              :filter-node-method="filterOrgNode"
              :render-content="orgRenderContent"
              @node-click="orgTreenodeClick"
              @check="orgTreeCheck"
              ref="orgTreeAll">
            </el-tree>
            <div v-show="!treeLoading && orgErr" class="error">
              <span>加载失败，<span class="reload" @click="reload('org')">重新加载</span></span>
            </div>
          </div>
        </div>
        <!-- 常用组 -->
        <div class="content-panel" :style="{opacity: activeName === 'commonTree' ? 1 : 0, zIndex: activeName === 'commonTree' ? 10 : -1}">
          <div class="search"><el-input
              :disabled="groupLoading"
              placeholder="根据关键字快速搜索"
              v-model="selectCommonText"
              clearable
            ></el-input><el-button type="primary" icon="el-icon-search" @click="selectCommon">搜索</el-button>
          </div>
          <div class="tree-panel" v-loading="groupLoading">
            <el-tree
              :data="commonTree"
              show-checkbox
              node-key="id"
              :props="defaultProps"
              :check-on-click-node="false"
              :empty-text="groupLoading || commonGroupError ? '' : '暂无常用组'"
              :render-content="groupRenderContent"
              @node-click="nodeCommonClick"
              ref="commonTree">
            </el-tree>
            <div v-show="!groupLoading && commonGroupError" class="error">
              <span>加载失败，<span class="reload" @click="reload('common')">重新加载</span></span>
            </div>
          </div>
          
        </div>
      </el-tabs>
      </el-col>
      <el-col :span="1" class="maxHeightDivLeft">
        <!-- <el-button
          size="mini"
          style="margin: 0;margin-bottom: 10px;padding: 7px"
          @click="nodePush"
        >选择<i class="el-icon-arrow-right el-icon--right"></i></el-button>
        <el-button
          icon="el-icon-arrow-left"
          size="mini"
          style="margin: 0;padding: 7px"
          @click="cleanCheackNode"
        >移除</el-button> -->
      </el-col>
      <el-col :span="11" class="maxHeig">
        <div class="el-input el-input--mini">
          <div style="float: left;margin-top: 8px;color: #333;">已选择人员：</div>
          <div style="float: right;"><el-button icon="el-icon-delete" size="mini" @click="cleanAll">清空</el-button>
          </div>
        </div>
        <div class="tree-panel">
          <el-tree
            class="filter-tree treemaxHeightDiv"
            :data="showncheckList"
            node-key="email"
            :props="defaultProps"
            empty-text="暂无被选择人员"
            :check-on-click-node="true"
            :render-content="cheackRenderContent"
            ref="checkTree"
          >
          </el-tree>
        </div>
      </el-col>
    </el-row>
    <div slot="footer" class="dialog-footer">
      <el-button @click="cancel">取 消</el-button>
     <el-button type="primary" @click="submit">确定</el-button>
    </div>
  </el-dialog>
</template>


<script>
  import store from '@/store'
  import {getContactsHistory, contactsHistory, removeContactsHistory, listByOrgdept} from "@/api/console/system/user";
  import {getGroup} from "@/api/console/system/group";
  import Treeselect from "@riophae/vue-treeselect";
  import "@riophae/vue-treeselect/dist/vue-treeselect.css";
  import scrollUtils from '@/utils/scroll'
  import { on, off } from '@/utils/event'
  export default {
    name: "findGroup",
    components: {Treeselect,listByOrgdept},
    data() {
      return {
        offset: 50, // 距离底部高度，触发加载
        grouptype: null, // 标识当前人员选择器所属， 1：收件人， 2：抄送人
        activeName: '', // 初始展示的tab树，当前初始默认展示历史树
        form:{},
        title:'', // 选择器的标题
        showInfo: false, // 选择器的显示开关
        defaultProps: {
          children: 'children',
          label: 'label'
        },
        defaultPropsOrg: {
          children: 'children',
          label: 'label',
          isLeaf: 'leaf'
        },
        // <------组织机构树相关参数 start
        isLazy: true, // 机构树是否开启懒加载
        searchEnd: true, // 机构树搜索查询结束
        orgTree: [], // 组织树懒加载数据
        orgErr: false, // 组织机构树加载失败标识
        treeLoading: true, // 组织机构树加载动画
        selectOrgText: '', // 组织机构树搜索关键词
        searchorgTimer: null, // 组织机构树搜索框定时器
        // 组织机构树相关参数 end ----->
        // <------历史树相关参数 start
        recentTree: [], // 最近历史树展示树
        recentTreeData: [], // 最近历史树全量树形结构
        recentTreeFilters: [], // 最近历史树搜索过滤数据
        recentErr: false, // 最近历史树加载失败标识
        recentTreeLoading: false, // 最近历史树加载动画
        selectRecentText: '', // 最近历史树搜素关键词
        searchrecentTimer: null, // 最近历史树搜索框定时器
        scrollerRecent: null, // 历史树的dom元素，用于滚动加载，解决树过大问题
        // 历史树相关参数 end ----->
        // <------常用树相关参数 start
        commonTree: [], // 常用树数据
        commonGroupError: false, // 常用组织树加载失败标识
        groupLoading: false, // 常用组织树加载动画
        selectCommonText:'', // 常用组搜索关键词
        searchcommonTimer: null, // 常用组织树搜索框定时器
        scrollerCommon: null, // 常用树的dom元素，用于滚动加载，解决树过大问题
        // 常用树相关参数 end ----->
        // <------选中树相关参数 start
        checkList:[], // 选中项的值合集
        showncheckList: [], // 展示的选中项
        checkeds: {}, // 默认选中项
        checkloading: false, // 选中树加载动画
        scrollerCheckeds: null, // 选中树的dom元素，用于滚动加载，解决树过大问题
        // 选中树相关参数 end ----->
        groups: [], // 选中的群组 - 用于提交历史记录
        users: [] // 选中的人员 - 用于提交历史记录
      };
    },
    beforeDestroy() {
      // 清空定时器
      clearTimeout(this.searchrecentTimer)
      clearTimeout(this.searchorgTimer)
      clearTimeout(this.searchcommonTimer)
      // 移除页面监听事件
      this.handler(false)
    },
    watch: {
      checkeds: {
        handler(val) {
          console.log('this.$refs.findGroup.show(type)', val)
        },
        deep: true
      },
      // 监听历史树搜索框
      selectRecentText (val) {
        clearTimeout(this.searchrecentTimer)
        this.searchrecentTimer = setTimeout(() => {
          clearTimeout(this.searchrecentTimer)
          if (val) {
          } else {
            // 重置历史树
            this.recentTreeFilters = this.deepClone(this.recentTreeData)
            this.recentTree = []            
            this.$nextTick(() => {
              scrollUtils.setScrollTop(this.scrollerRecent, 0);
              this.scrollRecentfunc()
            })
          }
        }, 1500);
      },
      // 监听组织树搜索框，当搜索框内容为空时，重置机构树
      selectOrgText (val) {
        clearTimeout(this.searchorgTimer)
        this.searchorgTimer = setTimeout(() => {
          clearTimeout(this.searchorgTimer)
          if (val) {
          } else {
            this.treeLoading = true
            this.queryOrg()
          }
        }, 1500);
      },
      // 监听常用组搜索框，当搜索框内容为空时，重置常用机组树
      selectCommonText (val) {
        clearTimeout(this.searchcommonTimer)
        this.searchcommonTimer = setTimeout(() => {
          clearTimeout(this.searchcommonTimer)
          if (val) {
          } else {
            this.groupLoading = true
            const timer = setTimeout(() => {
              clearTimeout(timer)
              this.commonTree = []
              this.loadCommon()
            }, 100);
            // this.$nextTick(() => {
            //   scrollUtils.setScrollTop(this.scrollerCommon, 0);
            // })
          }
        }, 1500);
      },
      // 当前选择器变动事件，即局部刷新
      grouptype (type) {
        // 重置页面，默认tab为最近历史树
        this.activeName = 'recentTree'
      },
      // 组件显示隐藏属性
      /**********
       * @param show | boolean, true => 显示，开启回车按键监听，搜索框使用 || false => 隐藏，关闭回车按键监听，搜索框使用
       * @desc 回填已选中人员
       */
      showInfo (show) {
        if (show) {
          // 开启回车监听
          const _this = this
          document.onkeydown = function(e) {
            const key = window.event.keyCode;
            if (key == 13) {
              if (_this.activeName === 'orgTree') {
                _this.selectUser();
              } else if (_this.activeName === 'commonTree') {
                _this.selectCommon()
              } else if (_this.activeName === 'recentTree') {
                _this.selectRecent()
              }
            }
          }
          // 由于选中树始终出现在页面上，因此最先对选中树dom元素做存储操作，便于后续对选中树的dom元素做操作
          if (!this.scrollerCheckeds) {
            // 获取选中树的dom元素
            this.$nextTick(() => {
              this.scrollerCheckeds = scrollUtils.getScrollEventTarget(this.$refs.checkTree.$el)
            })
          }
          // 防止历史树未成功渲染，在每次组件显示时判断是否加载完成，调用一次历史树渲染
          if (!this.recentTree.length) {
            this.queryRecent()
          }
          // 回填已选中人员
          console.log('this.che', this.checkeds)
          if (this.checkeds[this.grouptype] && Array.isArray(this.checkeds[this.grouptype]) && this.checkeds[this.grouptype].length) {
            this.$nextTick(() => {
              this.checkeds[this.grouptype].forEach(v => {
                if (v.id && this.checkList.every(m => m.email !== v.email)) {
                  this.checkList.push(v)
                }
              })
              this.showncheckList = this.showncheckList.concat(this.checkList.slice(this.showncheckList.length, this.showncheckList.length + 20))
            })
          }
          // 加载选中树
          if (this.checkList.length) {
            this.$nextTick(() => {
              this.handler(true, 'checkTree')
              this.$nextTick(this.checkTreeFun)
            })
          }
        } else {
          this.reset()
          document.onkeydown = null
        }
      }
    },
    computed: {
       noMore () {
        return this.commonTree.length >= this.commonTreeData.length
      },
      noMoreCheck () {
        return this.showncheckList.length >= this.checkList.length
      },
      noMoreRecent () {
        return this.recentTree.length >= this.recentTreeData.length
      },
      orgTreeData () {
        if (Array.isArray(this.$store.state.orgTree.orgData)) {
          this.treeLoading = false
          return this.$store.state.orgTree.orgData
        } else {
          this.orgErr = true
          return []
        }
      },
      commonTreeData () {
        if (Array.isArray(this.$store.state.orgTree.groupData)) {
          // this.groupLoading = false
          return this.$store.state.orgTree.groupData
        } else {
          this.commonGroupError = true
          return []
        }
      },
    },
    methods: {
      /**************************************组织机构树**************************** */
      // 节点渲染
      orgRenderContent(h, { node, data, store }) {
        let renderNode;
        if(data.group===false || data.group!==undefined){
          let userTips="";
          if(data.prevNode && data.orgCodeId){
            userTips = "所属机构："+data.prevNode[data.orgCodeId]+"\n";
          }
          if(data.prevNode && data.departmentCodeId){
            userTips += "所属部门："+data.prevNode[data.departmentCodeId]+"\n";
          }
          if(data.prevNode && data.officeCodeId){
            userTips += "所属处室："+data.prevNode[data.officeCodeId]+"\n";
          }
          userTips += "姓       名："+data.nickName+"\n";
          userTips += "邮件地址："+data.email+"\n";
           renderNode= (
             <span class="org-tree-node"  title={userTips}>
               <i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label} </span>
            )
        }else{
            renderNode= (
              <span class="org-tree-node">
              <i class="el-icon-folder" style="margin-right: 3px;"></i>{node.label}</span>
            )
        }
        return renderNode
      },
      // 获取
      queryOrg () {
        this.orgTree = this.deepClone(
          this.orgTreeData.map(v => {
            return {
              ...v,
              leaf: !(v.children && v.children.length),
              children: []
            }
          })
        )
        this.orgErr = false
        this.treeLoading = false
      },
      // 懒加载
      loadNode(node, resolve) {
        // console.log(node)
        if (node.level === 0) {
          return
        }
        if (!this.isLazy) {
          return
        }
        // if (node.level > 1) return resolve([]);
        console.log('steta', this.$store.state.orgTree.sorgData)
        const data  = this.$store.state.orgTree.sorgData[node.data.id] || []
        console.warn(data)
        if (data.length > 0) {
          resolve(
            data.map(v => {
              return {
                ...v,
                leaf: v.leaf,
                children: []
              }
            })
          );
        } else {
          return
        }
      },
      /*****************
       * @desc 组织机构树搜索事件
       * @function selectUser
       */
      selectUser(){
        if (this.selectOrgText && this.selectOrgText.length > 1) {
          this.isLazy = false
          this.searchEnd = false
          this.$refs.orgTreeAll.filter(this.selectOrgText);
        } else if (!this.selectOrgText) {
          this.treeLoading = true
          this.orgTree = this.deepClone(
            this.orgTreeData.map(v => {
              return {
                ...v,
                leaf: !(v.children && v.children.length),
                children: []
              }
            })
          )
          this.orgErr = false
          this.treeLoading = false
          this.isLazy = true
        } else {
          this.$message.warning('请输入两个字符以上的内容进行搜索')
        }
        
      },
      // 机构树节点被点击时的回调
      orgTreenodeClick (data, node, self) {
        console.log('机构树节点被点击时的回调', data, node, self)
        if (!node.childNodes.length && !node.expanded) {
          node.checked =! node.checked
        }
        if (data.group !== undefined) {
          const m = data
          let reset = false
          if (node.checked) {
            if (m.email) {
              if (this.checkList.every(c => c.email !== m.email)) {
                this.users.push(data)
                this.checkList.push(data)
                reset = true
              }
              this.$refs.orgTreeAll.setChecked(data.id, true, true)
              this.$refs.orgTree.setChecked(data.id, true, true)
            } else {
              this.msgWarning(`${data.label}的邮箱地址无效`)
              node.checked = false
            }
          } else {
            this.$refs.orgTreeAll.setChecked(data.id, false, true)
            this.$refs.orgTree.setChecked(data.id, false, true)
            const index = this.checkList.findIndex(v => v.email === m.email)
            if (index >= 0) {
              this.checkList.splice(index, 1)
              reset = true
            }
          }
          if (reset) {
            this.showncheckList = []
            scrollUtils.setScrollTop(this.scrollerCheckeds, 0);
            this.$nextTick(() => {
              this.checkTreeFun()
            })
          }
        }
      },
      // 机构树复选框被点击时触发
      orgTreeCheck (data, check) {
        console.log('机构树复选框被点击时触发', data, check)
        let reset = false
        if (check.checkedKeys.includes(data.id)) { // 当前节点为被选中状态
          this.$refs.orgTreeAll.setChecked(data.id, true, true)
          this.$refs.orgTree.setChecked(data.id, true, true)
          const orgTreeCheckeds = this.$refs.orgTreeAll.getCheckedNodes()
          // 组织树勾选
          for (let k = 0; k < orgTreeCheckeds.length; k++) {
            const v = orgTreeCheckeds[k]
            if (v.group === undefined) {
              // 当前选中为机构项，跳过
              continue
            }
            if (v.email) {
              if (v.prevNode && this.checkList.every(m => m.email !== v.email)) {
                this.checkList.push(v)
                this.users.push(v)
                reset = true
              }
            } else {
              this.msgWarning(`${v.label}的邮箱地址无效`)
              this.$refs.orgTree.setChecked(v.id, false, true)
              this.$refs.orgTreeAll.setChecked(v.id, false, true)
              continue
            }
          }
        } else {
          // 该节点为不选中状态
          this.$refs.orgTreeAll.setChecked(data.id, false, true)
          // this.$refs.orgTreeAll.getCheckedNodes
          // 获取该节点的后代子节点,若无后代子节点，则当前节点为末级节点
          const childNodes = this.findChildNodes(this.$store.state.orgTree.sorgData[data.id], [])
          if (childNodes.length) {
            // 在右边选中树中做剔除
            for (let i = 0; i < childNodes.length; i++) {
              if (childNodes[i].email) {
                const index = this.checkList.findIndex(v => v.email === childNodes[i].email)
                if (index >= 0) {
                  this.checkList.splice(index, 1)
                  reset = true
                }
              }
            }
          } else {
            const index = this.checkList.findIndex(v => v.email === data.email)
            if (index >= 0) {
              this.checkList.splice(index, 1)
              reset = true
            }
          }
        }
        if (reset) {
          this.showncheckList = []
          scrollUtils.setScrollTop(this.scrollerCheckeds, 0);
          this.$nextTick(() => {
            this.checkTreeFun()
          })
        }
      },
      findChildNodes (data, nodes) {
        if (data) {
          data.forEach(item => {
            if (!item.children) {
              nodes.push(item)
            } else {
              this.findChildNodes(item.children, nodes)
            }
          })
          return nodes
        } else {
          return []
        }
      },
      /*************
       * @desc 过滤节点方法，查找组织下的人员
       * @function filterNode
       */
      filterOrgNode(value,data,node) {
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
        this.searchEnd = true
        return result;
      },
      /*******************************选中树********************************** */
      // 节点内容渲染
      cheackRenderContent(h, { node, data, store }) {
        let renderNode
        let userTips="";
        if (data.prevNode) {
          if(data.prevNode && data.orgCodeId){
            userTips = "所属机构："+data.prevNode[data.orgCodeId]+"\n";
          }
          if(data.prevNode && data.departmentCodeId){
            userTips += "所属部门："+data.prevNode[data.departmentCodeId]+"\n";
          }
          if(data.prevNode && data.officeCodeId){
            userTips += "所属处室："+data.prevNode[data.officeCodeId]+"\n";
          }
          userTips += "姓       名："+data.nickName+"\n";
          userTips += "邮件地址："+data.email+"\n";
        } else if (data.type && data.type === 1) {
          if (data.user.orgDept) userTips = "所属机构："+data.user.orgDept.deptName+"\n";
          if (data.user.departmentDept) userTips += "所属部门："+data.user.departmentDept.deptName+"\n";
          if (data.user.officeDept) userTips += "所属处室："+data.user.officeDept.deptName+"\n";
          userTips += "姓       名："+data.user.nickName+"\n";
          userTips += "邮件地址："+data.user.email+"\n";
        } else {
          userTips += "姓       名："+data.nickName+"\n";
          userTips += "邮件地址："+data.email+"\n";
        }

        if (data.qunzu) {
          renderNode = (
            <span class="org-tree-node">
            <i class="el-icon-folder" style="margin-right: 3px;"></i>{node.label}</span>
          )
        } else {
          renderNode = <span class="org-tree-node"  title={userTips}>
            <i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label}
          </span>
        }
        return renderNode
      },
      // 重置选中树
      resetCheckTree () {
        this.showncheckList = []
        this.checkloading = false
        this.$refs.checkTree.$el.scrollTo(0, 10)
      },
      /******************
       * @desc 选中树的滚动事件
       */
      checkTreeFun () {
        if (this.checkloading || this.noMoreCheck) {
          return
        }
        const el = this.$refs.checkTree.$el
        const { scrollerCheckeds } = this
        const scrollerHeight = scrollUtils.getVisibleHeight(scrollerCheckeds)
        /* istanbul ignore next */
        if (!scrollerHeight || scrollUtils.getComputedStyle(el).display === 'none' || el.offsetParent === null) {
          return
        }
        
        const scrollTop = scrollUtils.getScrollTop(scrollerCheckeds)
        const targetBottom = scrollTop + scrollerHeight
        let reachBottom = false
        /* istanbul ignore next */
        if (el === scrollerCheckeds) {
          reachBottom = scrollerCheckeds.scrollHeight - targetBottom < this.offset
        } else {
          const elBottom =
            scrollUtils.getElementTop(el) -
            scrollUtils.getElementTop(scrollerCheckeds) +
            scrollUtils.getVisibleHeight(el)
          reachBottom = elBottom - scrollerHeight < this.offset
        }
        /* istanbul ignore else */
        console.log(scrollTop)
        console.log(scrollerHeight)
        console.log(targetBottom)
        if (reachBottom) {
          this.loadCheckeds()
        }
      },
      /****************
       * @desc 选中树的触底事件
       */
      loadCheckeds () {
        this.checkloading = true
        console.log('选中树的触底事件')
        if (Array.isArray(this.checkList)) {
          this.showncheckList = this.showncheckList.concat(this.checkList.slice(this.showncheckList.length, this.showncheckList.length + 20))
          this.checkloading = false
        }
      },
      /***********************************常用组织树—*********************************** */
      // 节点渲染
      groupRenderContent(h, { node, data, store }) {
        let renderNode= (
            <span class="org-tree-node">
           <i class="el-icon-folder" style="margin-right: 3px;color:#4b91ff;"></i>{node.label}
          </span>
        )
        return renderNode
      },
      // 滚动事件
       scrollCommonfunc () {
        if (this.groupLoading || this.noMore) {
          return
        }
        const el = this.$refs.commonTree.$el
        const { scrollerCommon } = this
        const scrollerHeight = scrollUtils.getVisibleHeight(scrollerCommon)
        /* istanbul ignore next */
        if (!scrollerHeight || scrollUtils.getComputedStyle(el).display === 'none' || el.offsetParent === null) {
          return
        }
        
        const scrollTop = scrollUtils.getScrollTop(scrollerCommon)
        const targetBottom = scrollTop + scrollerHeight
        let reachBottom = false
        /* istanbul ignore next */
        if (el === scrollerCommon) {
          reachBottom = scrollerCommon.scrollHeight - targetBottom < this.offset
        } else {
          const elBottom =
            scrollUtils.getElementTop(el) -
            scrollUtils.getElementTop(scrollerCommon) +
            scrollUtils.getVisibleHeight(el)
          reachBottom = elBottom - scrollerHeight < this.offset
        }
        /* istanbul ignore else */
        if (reachBottom) {
          this.loadCommon()
        }
      },
      /**************
       * @desc 常用组织查询触发方法
       * @function selectCommon
       */
      selectCommon () {
        if (this.selectCommonText && this.selectCommonText.length > 1) {
          this.searchCommon()
        } else if (!this.selectCommonText) {
          this.groupLoading = true
          this.commonTree = []
          scrollUtils.setScrollTop(this.scrollerCommon, 0);
          this.$nextTick(() => {
            this.checkTreeFun()
          })
        } else {
          this.$message.warning('请输入两个字符以上的内容进行搜索')
        }
      },
       /***************
       * @desc 常用组织机构请求后端进行搜索查询
       * @function searchCommon
       */
      searchCommon() {
        this.groupLoading = true
        getGroup({
          name: this.selectCommonText
        }).then((resp) => {
          this.commonGroupError = false
          this.groupLoading = false
          this.commonTree =  resp.data.map(v => {return {...v, label: v.name, qunzu: true}})
        }).catch(err => {
          this.groupLoading = true
          this.commonGroupError = true
        })
      },
       /***************
       * @desc 常用组织node节点点击事件
       * @function nodeCommonClick
       */
      nodeCommonClick (data, node, event) {
        if (!node.childNodes.length && !node.expanded) {
          node.checked =! node.checked
        }
        const m = data
        let reset = false
        if (node.checked) {
          if (m.email) {
            // 群组
            if (this.checkList.every(c => c.email !== m.email)) {
              this.groups.push(m)
              this.checkList.push(data)
              reset = true
            }
          } else {
            this.msgWarning(`${data.label}的邮箱地址无效`)
            node.checked = false
          }
        } else {
          const index = this.checkList.findIndex(v => v.email === m.email)
          if (index >= 0) {
            this.checkList.splice(index, 1)
            reset = true
          }
        }
        if (reset) {
          this.showncheckList = []
          scrollUtils.setScrollTop(this.scrollerCheckeds, 0);
          this.$nextTick(() => {
            this.checkTreeFun()
          })
        }
      },
      /******************
       * @desc 常用组织树触底事件
       * @function loadCommon
       */
      loadCommon () {
        this.groupLoading = true
        console.log('触底')
        console.warn(this.commonTreeData)
        if (Array.isArray(this.commonTreeData)) {
          this.commonTree = this.commonTree.concat(this.commonTreeData.slice(this.commonTree.length, this.commonTree.length + 20))
          this.groupLoading = false
          this.commonGroupError = false
        }
      },
      /****************************整体组件事件***************************** */
      // 组件显示触发事件
      show(type){
        this.grouptype = type;
        if(this.$refs['form']!== undefined){
          this.$refs['form'].resetFields();
        }
        if(this.grouptype === '1'){
          this.title = "添加收件人"
        }else if (this.grouptype === '2') {
          this.title = "添加抄送人"
        }
        this.form = {};
        this.showInfo = true
      },
      /**************
       * @desc tab点击事件
       * 当tab切换至常用组时，再进行常用组的渲染，防止常用组的渲染阻塞弹框的渲染
       * @function handleClick
       */
      handleClick (tab, event) {
        if (tab.name === 'commonTree') {
          if (!this.scrollerCommon) {
            this.scrollerCommon = scrollUtils.getScrollEventTarget(this.$refs.commonTree.$el)
            console.log(this.scrollerCommon)
            this.handler(true, 'commonTree')
            this.$nextTick(this.scrollCommonfunc)
          }
          // if (!this.commonTree.length && Array.isArray(this.commonTreeData)) {
          //   this.load()
          // }
        } else if (tab.name === 'orgTree') {
          if (!this.orgTree.length) {
            this.treeLoading = true
            const timer = setTimeout(() => {
              clearTimeout(timer)
              // this.orgTree = this.deepClone(this.orgTreeData)
              this.orgTree = this.deepClone(
                this.orgTreeData.map(v => {
                  return {
                    ...v,
                    leaf: !(v.children && v.children.length),
                    children: []
                  }
                })
              )
              this.orgErr = false
              this.treeLoading = false
            }, 100);
          } else {
            this.treeLoading = false
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
      },
      // 监听滚动绑定和解绑
      handler (bind, scroller) {
        /* istanbul ignore else */
        if (this.binded !== bind) {
          this.binded = bind
          if (bind) {
            if (scroller === 'checkTree') {
              on(this.scrollerCheckeds, 'scroll', this.checkTreeFun)
            } else if (scroller === 'commonTree') {
              on(this.scrollerCommon, 'scroll', this.scrollCommonfunc)
            } else if (scroller === 'recentTree') {
              on(this.scrollerRecent, 'scroll', this.scrollRecentfunc)
            }
          } else {
            off(this.scrollerCommon, 'scroll', this.scrollCommonfunc)
            off(this.scrollerCheckeds, 'scroll', this.checkTreeFun)
            off(this.scrollerRecent, 'scroll', this.scrollRecentfunc)
          }
          // (bind ? on : off)(this.scroller, 'scroll', this.scrollCommonfunc)
        }
      },
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
      /*************
       * @desc 重新加载
       * @function reload
       * @param type | org: 机构树 | common: 常用组织
       */
      reload (type) {
        if (type === 'org') {
          if (typeof(this.$store.state.orgTree.orgData) === 'string') {
            this.treeLoading = true
            store.dispatch('orgTree/TreeselectNewPro').then(res => {
              // 获取机构树，存入vuex
              this.orgErr = false
              this.handleClick({name: 'orgTree'})
            }).catch(err => {
              this.treeLoading = false
              this.orgErr = true
            })
          } else {
            this.groupLoading = true
          }
        } else if (type === 'common') {
          if (typeof(this.$store.state.orgTree.groupData) === 'string') {
            this.groupLoading = true
            store.dispatch('orgTree/GetGroup').then(res => {
              // 获取常用组织，存入vuex
              this.commonGroupError = false
              this.handleClick({name: 'commonTree'})
            }).catch(err => {
              this.groupLoading = false
              this.commonGroupError = true
            })
          }
        } else if (type === 'recent') {
          this.queryRecent()
        }
      },
      cancel() {
        this.showInfo=false
        this.form={};
      },
      /*************
       * @desc 清空操作
       * @function reset
       */
      reset() {
        this.selectCommonText='';
        this.selectOrgText='';
        this.selectRecentText=''
        this.groups = []
        this.users = []
        // 清空选中项
        this.checkList = []
        this.showncheckList = []
        this.$nextTick(() => {
          this.$refs.recentTree.setCheckedKeys([])
          this.$refs.orgTree.setCheckedKeys([])
          this.$refs.orgTreeAll.setCheckedKeys([])
          this.$refs.commonTree.setCheckedKeys([])
        })
      },
      /****************
       * @desc 选择人员
       * @function nodePush
       * @param this.$refs.recentTree.getCheckedNodes() | 历史记录下选中的人员
       * @param this.$refs.orgTree.getCheckedNodes() | 组织机构下选中的人员
       * @param this.$refs.commonTree.getCheckedNodes() | 常用机构下选中的人员
       * @param checkList | 选中的人员全属性
       * @tip 以人员的eamil做去重
       */
      nodePush(){
        const recentTreeCheckeds = this.$refs.recentTree.getCheckedNodes()
        const orgTreeCheckeds = this.$refs.orgTree.getCheckedNodes()
        const commonTreeCheckeds = this.$refs.commonTree.getCheckedNodes()
        console.log('recentTreeCheckeds', recentTreeCheckeds)
        console.log('orgTreeCheckeds', orgTreeCheckeds)
        console.log('commonTreeCheckeds', commonTreeCheckeds)
        // 历史树勾选
        for (let i = 0; i < recentTreeCheckeds.length; i++) {
          const v = recentTreeCheckeds[i]
          if ((v.group && v.group.email) || (v.user && v.user.email)) {
            // 群组
            if (v.type === 2 && this.checkList.every(m => m.email !== v.group.email)) {
              this.checkList.push({
                ...v.group,
                ...v
              })
            }
            // 个人
            if (v.type === 1 && this.checkList.every(m => m.email !== v.user.email)) {
              this.checkList.push({
                ...v.user,
                ...v
              })
            }
          } else {
            this.msgWarning(`${v.label}的邮箱地址无效`)
            continue
          }
        }
        // 常用组织勾选
        for (let j = 0; j < commonTreeCheckeds.length; j++) {
          const v = commonTreeCheckeds[j]
          if (v.email) {
            if (this.checkList.every(m => m.email !== v.email)) {
              this.groups.push(v)
              this.checkList.push({
                ...v,
              })
            }
          } else {
            this.msgWarning(`${v.label}的邮箱地址无效`)
            continue
          }
        }
        // 组织树勾选
        for (let k = 0; k < orgTreeCheckeds.length; k++) {
          const v = orgTreeCheckeds[k]
          if (v.group === undefined) {
            // 当前选中为机构项，跳过
            continue
          }
          if (v.email) {
            if (v.prevNode && this.checkList.every(m => m.email !== v.email)) {
              this.checkList.push(v)
              this.users.push(v)
              this.$nextTick(() => {
                this.$refs.cheackTree.setChecked(v.id, true)
              })
            }
          } else {
            this.msgWarning(`${v.label}的邮箱地址无效`)
            continue
          }
        }
        // 手动唤起选中树触底事件
        this.$nextTick(() => {
          this.checkTreeFun()
        })
      },
      /**********************
       * @desc 移除选中项
       * @function cleanCheackNode
       */
      cleanCheackNode(){
        const checkeds = this.$refs.cheackTree.getCheckedNodes();
        if (checkeds && checkeds.length) {
          checkeds.forEach((v) => {
            const index = this.checkList.findIndex(m => m.id === v.id)
            const groupIndex = this.groups.findIndex(n => n.id === v.id)
            console.log(this.groups)
            console.log('this.checkList', this.checkList)
            console.log(groupIndex)
            if (index >=0 ) {
              groupIndex >=0 && this.groups.splice(groupIndex, 1)
              this.checkList.splice(index, 1)
              this.$refs.recentTree.setChecked(v.id, false, true)
              this.$refs.orgTree.setChecked(v.id, false, true)
              this.$refs.commonTree.setChecked(v.id, false, true)
              console.log(this.groups)
            }
          })
        }
      },
      cleanAll(){
        this.checkList=[];
        this.showncheckList = []
        this.groups = []
        this.$refs.recentTree.setCheckedKeys([])
        this.$refs.orgTree.setCheckedKeys([])
        this.$refs.orgTreeAll.setCheckedKeys([])
        this.$refs.commonTree.setCheckedKeys([])
      },
      recentRenderContent(h, { node, data, store }) {
        let renderNode;
        if(data.type === 2){
          renderNode= (
              <span class="org-tree-node recentRender">
                <span><i class="el-icon-folder" style="margin-right: 3px;"></i>{node.label}</span>
              <i on-click={ () => this.removeRecent(data, event) } class="el-icon-delete"></i>
              </span>
            )
        }else{
          let userTips="";
          if (!data.type) {
            userTips += "姓       名："+data.name+"\n";
            userTips += "邮件地址："+data.email+"\n";
          } else {
            if (data.user.orgDept) userTips = "所属机构："+data.user.orgDept.deptName+"\n";
            if (data.user.departmentDept) userTips += "所属部门："+data.user.departmentDept.deptName+"\n";
            if (data.user.officeDept) userTips += "所属处室："+data.user.officeDept.deptName+"\n";
            
            userTips += "姓       名："+data.user.nickName+"\n";
            userTips += "邮件地址："+data.user.email+"\n";
          }
          renderNode= (
          <span class="org-tree-node recentRender">
            <span title={userTips}><i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label} </span>
            {data.type === 1 && <i on-click={ () => this.removeRecent(data, event) } class="el-icon-delete"></i>}
            </span>
          )
        }
        return renderNode
      },
      submit() {
        if (this.checkList.length) {
          // 当存在从常用群组中选取的群组或从组织结构选取的人员，调用新增历史接口
          if (this.groups.length || this.users.length) {
            this.addRecent()
          } 
          this.$set(this.checkeds, this.grouptype, this.checkList)
          this.$emit('confirm' ,this.grouptype, {
            [this.grouptype]: this.checkList
          });
          this.showInfo=false;
        } else {
          this.$confirm('未选择人员，是否确定继续关闭？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }).then(() => {
            this.showInfo=false;
          }).catch(() => {
            // 不做任何操作         
          });
        }
      },
      /************************************ 历史树 ******************************************** */
      /*******************
       * @desc node节点点击事件
       * @function nodeClick
       */
      recentTreenodeClick(data, node, event) {
        if (!node.childNodes.length && !node.expanded) {
          node.checked =! node.checked
        }
        const m = data.type === 2 ? data.group : data.user
        let reset = false
        if (node.checked) {
          if (m.email) {
            // 群组
            if (data.type === 2 && this.checkList.every(c => c.email !== m.email)) {
              this.checkList.push({
                ...data.group,
                ...data
              })
              reset = true
            }
            // 个人
            if (data.type === 1 && this.checkList.every(c => c.email !== m.email)) {
              this.checkList.push({
                ...data.user,
                ...data
              })
              reset = true
            }
          } else {
            this.msgWarning(`${data.label}的邮箱地址无效`)
            node.checked = false
          }
        } else {
          const index = this.checkList.findIndex(v => v.email === m.email)
          if (index >= 0) {
            this.checkList.splice(index, 1)
            reset = true
          }
        }
        if (reset) {
          this.showncheckList = []
          scrollUtils.setScrollTop(this.scrollerCheckeds, 0);
          this.$nextTick(() => {
            this.checkTreeFun()
          })
        }
      },
      // 滚动事件
      scrollRecentfunc () {
        if (this.recentTreeLoading || this.noMoreRecent) {
          return
        }
        const el = this.$refs.recentTree.$el
        const { scrollerRecent } = this
        const scrollerHeight = scrollUtils.getVisibleHeight(scrollerRecent)
        /* istanbul ignore next */
        if (!scrollerHeight || scrollUtils.getComputedStyle(el).display === 'none' || el.offsetParent === null) {
          return
        }
        
        const scrollTop = scrollUtils.getScrollTop(scrollerRecent)
        const targetBottom = scrollTop + scrollerHeight
        let reachBottom = false
        /* istanbul ignore next */
        if (el === scrollerRecent) {
          reachBottom = scrollerRecent.scrollHeight - targetBottom < this.offset
        } else {
          const elBottom =
            scrollUtils.getElementTop(el) -
            scrollUtils.getElementTop(scrollerRecent) +
            scrollUtils.getVisibleHeight(el)
          reachBottom = elBottom - scrollerHeight < this.offset
        }
        /* istanbul ignore else */
        if (reachBottom) {
          this.loadRecent()
        }
      },
      /******************
       * @desc 历史树触底事件
       * @function loadRecent
       */
      loadRecent () {
        this.recentTreeLoading = true
        console.log('历史树触底')
        if (Array.isArray(this.recentTreeFilters)) {
          this.recentTree = this.recentTree.concat(this.recentTreeFilters.slice(this.recentTree.length, this.recentTree.length + 20))
          this.recentTreeLoading = false
          this.recentErr = false
        }
      },
      /********************
       * @desc 新增历史记录
       * @function addRecent
       * @param groupList | 群组id
       * @param userList | 个人id
       */
      addRecent () {
        const param = {
          groupList: this.groups.map(v => v.id),
          userList: this.users.map(v => v.id)
        }
        contactsHistory(param).then((resp) => {
          if (resp.code === 200) {
            this.queryRecent()
          }
        })
      },
      /******************
       * @desc 移除历史记录
       * @function removeRecent
       * @param groupList | 群组id
       * @param userList | 个人id
       */
      removeRecent (data, e) {
        console.log('1', e)
        e.stopPropagation();
        let param = {}
        if (data.type === 2) {
          param.groupList = [data.id]
        } else if (data.type === 1) {
          param.userList = [data.id]
        }
        removeContactsHistory(param).then((resp) => {
          if (resp.code === 200) {
            this.msgSuccess("移除成功");
            this.queryRecent()
          }
        })
      },
      /******************
       * @desc 历史树组装数据机构
       * @function initRencentTree
       */
      initRecentTree (data) {
        let recentTree = []
        for (let i = 0; i < data.length; i++) {
          if (data[i].type === 2) {
            recentTree.push({
              ...data[i],
              label: data[i].group.name,
              qunzu: true
            })
          } else {
            recentTree.push({
              ...data[i],
              label: data[i].user.nickName
            })
          }
        }
        return recentTree
      },
      /*****************
       * @desc 历史树搜索事件
       * @function selectRecent
       */
      selectRecent () {
        this.recentTreeFilters = this.deepClone(this.recentTreeData.filter(v => v.label.includes(this.selectRecentText)))
        this.recentTree = []
        this.$nextTick(() => {
          scrollUtils.setScrollTop(this.scrollerRecent, 0);
          this.scrollRecentfunc()
        })
      },
      /***********
       * @desc 查询最近列表
       * @abstract 获取全量列表，开启历史树滚动监听，初始默认触发滚动事件，分页加载
       */
      queryRecent () {
        this.recentTree = []
        this.recentTreeLoading = true
        getContactsHistory().then((resp) => {
          this.recentTreeData = this.deepClone(this.initRecentTree(resp.data))
          this.recentTreeFilters = this.deepClone(this.recentTreeData)
          this.recentTreeLoading = false
          if (!this.scrollerRecent) {
            this.$nextTick(() => {
              this.scrollerRecent = scrollUtils.getScrollEventTarget(this.$refs.recentTree.$el)
              console.warn(this.scrollerRecent)
              this.handler(true, 'recentTree')
              this.scrollRecentfunc()
            })
          } else {
            // 重置加载列表
            this.$nextTick(() => {
              scrollUtils.setScrollTop(this.scrollerRecent, 0);
              this.scrollRecentfunc()
            })
          }
        }).catch((err) => {
          console.log(err)
          this.recentTreeLoading = false
          this.recentErr = true
        })
      }
    }
  };

</script>

<style lang="scss" scoped>
  ::v-deep .el-tabs{
    height: 100%;
    display: flex;
    flex-direction: column;
    > .el-tabs__header {
      background-color: #ffffff;
      border-bottom: 1px solid #dfe4ed;
      margin: 0;
    }
    > .el-tabs__header .el-tabs__item.is-active {
      color: #ffffff !important;
      background-color: #4b91ff;
      border-right-color: #4b91ff;
      border-left-color: #4b91ff;
    }
    .el-tabs__item {
      padding: 0 20px;
      height: 35px;
      line-height: 35px;
    }
    .el-tabs__content{
      position: relative;
      flex: 1;
      padding: 0;
      .content-panel{
        padding: 15px;
        box-sizing: border-box;
        position: absolute;
        left:0;
        top:0;
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        .search{
          display: flex;
          width: 100%;
          .el-input{
            flex: 1;
          }
          .el-button{
            margin-left: 10px;
          }
        }
        .tree-panel{
          margin-top: 10px;
          flex: 1;
          position: relative;
          overflow-y: auto;
          .error{
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            .reload{
              color:#2272DE;
              text-decoration: underline;
              cursor: pointer;
            }
          }
        }
      }
    }
  }
  .treemaxHeightDiv {
    height: 100%;
    padding: 5px;
    overflow: auto;
    box-sizing: border-box;
  }

  .maxHeightDivLeft {
    height: 430px;
    padding: 5px;
    margin-top: 180px;
    text-align: center;
    box-sizing: border-box;
  }
  .maxHeig{
    border: 1px solid rgb(221, 221, 221);
    padding: 10px;
    height: 430px;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    .tree-panel{
      flex: 1;
      overflow-y: auto;
    }
  }
  ::v-deep .recentRender{
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    .el-icon-delete{
      &:hover{
        color: #ff0000;
      }
    }
  }
  ::v-deep .el-dialog__body{
    padding: 0 20px!important;
  }
  
</style>
