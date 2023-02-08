<template>
  <el-dialog
    :append-to-body="true"
    :title="title"
    :visible.sync="showInfo"
    width="850px !important"
    :close-on-click-modal="false"
  >
    <el-row>
      <el-col :span="11" class="maxHeig">
      <el-tabs v-model="activeName" type="border-card" @tab-click="handleClick">
        <el-tab-pane label="常用联系人" name="first">
          <div class="tree-panel" v-loading="topContactsLoading">
            <el-tree
              class="filter-tree treemaxHeightDiv"
              :data="contactsUserListData"
              :props="defaultProps"
              :render-content="contactsUserRenderContent"
              @node-click="contactNodeClick"
              :empty-text="topContactsLoading ? '' : '暂无常用联系人'"
              ref="tree0">
            </el-tree>
          </div>
        </el-tab-pane>
        <el-tab-pane label="组织管理" name="second">
          <div class="searchBar">
            <el-input
              placeholder="根据关键字快速搜索"
              v-model="selectUserText"
              prefix-icon="el-icon-search"
              clearable>
            </el-input><el-button type="primary" icon="el-icon-search" @click="selectUser">搜索</el-button>
          </div>
          <div class="tree-panel" v-loading="treeLoading">
            <el-tree v-show="isLazy"
              class="filter-tree treemaxHeightDiv"
              :data="orgTree"
              :props="defaultProps"
              empty-text="暂无记录"
              :render-content="orgRenderContent"
              @node-click="orgNodeClick"
              :load="loadNode"
              lazy
              ref="orgTree">
            </el-tree>
            <el-tree v-show="!isLazy && searchEnd"
              class="filter-tree treemaxHeightDiv"
              :data="orgTreeData"
              :props="defaultProps"
              empty-text="暂无记录"
              @node-click="orgNodeClick"
              :filter-node-method="filterOrgNode"
              :render-content="orgRenderContent"
              ref="orgTree">
            </el-tree>
          </div>
        </el-tab-pane>
      </el-tabs>
      </el-col>
      <el-col :span="2" class="maxHeightDivLeft">
        <el-button
          icon="el-icon-arrow-right"
          size="mini"
          style="margin: 0;margin-bottom: 10px"
          @click="nodePush"
        >
        </el-button>
        <el-button
          icon="el-icon-arrow-left"
          size="mini"
          style="margin: 0;"
          @click="cleanAll"
        >
        </el-button>
      </el-col>
      <el-col :span="11" class="maxHeig">
        <div class="el-input el-input--mini">
          <div style="float: left;margin-top: 8px;color: #a2a2a2;">已选：</div>
          <div style="float: right;">
            <!-- <el-button
              icon="el-icon-circle-plus-outline"
              style="margin-left: 10px;"
              size="mini"
              @click="addContactsUser"
            >添加为常用联系人
            </el-button> -->
            <el-button
              icon="el-icon-delete"
              size="mini"
              @click="cleanAll"
            >清空
            </el-button>
          </div>
        </div>
        <div class="tree-panel">
          <el-tree
            class="filter-tree treemaxHeightDiv"
            :data="checkList"
            :props="defaultProps"
            empty-text="暂无被委托人"
            default-expand-all
            :render-content="cheackRenderContent"
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
  import {listPro,listByOrgdept,listContactsUserList,deleteContactsUserList,insertContactsUserList} from "@/api/console/system/user";
  import {treeselectPro} from "@/api/console/system/dept";
  import Treeselect from "@riophae/vue-treeselect";
  import "@riophae/vue-treeselect/dist/vue-treeselect.css";
  export default {
    name: "findUser",
    components: {Treeselect,listByOrgdept},
    data() {
      return {
        keys: [],
        isLazy: true,
        searchEnd: true,
        loadData: [],
        loadNodeData: [],
        topContacts:true,
        orgsUser:false,
        group:false,
        activeName:'first',
        checkList:[],
        contactsUserListData:[],
        form:{},
        title:'',
        showInfo:false,
        selectUserText: '',
        userList:[],
        data: [],
        cheackNode:undefined,
        cheackNodeObj: null,
        defaultProps: {
          children: 'children',
          label: 'label',
          isLeaf: 'leaf'
        },
        topContactsLoading: false, // 常用联系人加载动画
        treeLoading: true,
        orgErr: false,
        resetTree: 1,
        orgTree: []
      };
    },
    computed: {
      orgTreeData () {
        if (Array.isArray(this.$store.state.orgTree.orgData)) {
          this.treeLoading = false
          return this.$store.state.orgTree.orgData
        } else {
          return []
        }
      },
    },
    watch: {
      // orgTreeData (val) {
      //   if (Array.isArray(val) && !this.orgTree.length && this.activeName === 'second') {
      //     this.handleClick({name: this.activeName})
      //   }
      // },
      cheackNode (val) {
        console.log('cheackNode', val)
        // if (val) {
        //   this.nodePush()
        // }
      },
      showInfo (show) {
        if (show) {
          // this.hackConfirmPassword = true;
          const _this = this
          document.onkeydown = function(e) {
            console.log('onkeydown')
            var key = window.event.keyCode;
            if (key == 13) {
              _this.selectUser();
            }
          }
        } else {
          document.onkeydown = null
        }
      }
    },
    methods: {
      contactNodeClick (data) {
        if (this.cheackNodeObj && this.cheackNodeObj.email) {
          this.cheackNode = this.cheackNodeObj.email
        }
        const timer = setTimeout(() => {
          clearTimeout(timer)
          if (this.cheackNode && data.user.email === this.cheackNode) {
            this.cheackNodeObj = data
            this.nodePush()
          }
        }, 100);
      },
      orgNodeClick (data, node, event) {
        if (data.group === false) {
          this.cheackNode = data.email
        } else {
          if (this.cheackNodeObj && this.cheackNodeObj.email) {
            this.cheackNode = this.cheackNodeObj.email
          }
        }
        const timer = setTimeout(() => {
          clearTimeout(timer)
          console.log(this.cheackNode)
          if (this.cheackNode && data.email === this.cheackNode) {
            this.cheackNodeObj = data
            this.nodePush()
          }
        }, 100);
      },
      loadNode(node, resolve) {
        console.log('node')
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
      /**************
       * @desc tab点击事件
       * 当tab切换至常用组时，再进行常用组的渲染，防止常用组的渲染阻塞弹框的渲染
       * @function handleClick
       */
      handleClick (tab, event) {
        console.log(tab, event)
        if (tab.name === 'second') {
          if (!this.orgTree.length) {
            const timer = setTimeout(() => {
              clearTimeout(timer)
              // this.orgTree = this.deepClone(this.orgTreeData)
              this.orgTree = this.deepClone(
                this.orgTreeData.map(v => {
                  console.log(v)
                  return {
                    ...v,
                    leaf: !(v.children && v.children.length),
                    children: []
                  }
                })
              )
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
      show(type){
        this.activeName='first';
        if( this.$refs['form']!== undefined){
          this.$refs['form'].resetFields();
        }
        this.title = "添加被委托人"
        this.selectUserText='';
        this.checkList=[];
        this.userList=[];
        this.selectlistContactsUserLists();
        this.form = {};
        this.showInfo = true
        this.resetTree++
      },
      /******************
       * @desc 获取常用联系人
       */
      selectlistContactsUserLists(){
        this.cheackNode = null
        this.cheackNodeObj = null
        this.topContactsLoading = true
        //查询常用联系人
        listContactsUserList().then(response => {
          this.topContactsLoading = false
          if (response.code === 200) {
            var row=response.data;
            this.contactsUserListData = [];
            if(row.length>0) {
              for (var i in row) {
                var userName = row[i].userName;
                var nickName = row[i].nickName;
                const newChild = {id: userName, label: nickName, staffAccount: userName, user:row[i]};
                this.contactsUserListData.push(newChild);
              }
            }
          }
        }).catch(() => {
          this.topContactsLoading = false
        })
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
      cancel() {
        this.showInfo=false
        this.form={};
      },
      nodePush(){
        if(!this.cheackNode)return;
        if(this.checkList.length >= 1){
          // this.msgWarning("被委托人只能选择一个,当前选择发生变更。")
          this.checkList=[];
        }
        this.checkList.push(this.cheackNodeObj)
      },
      cleanAll(){
        this.checkList=[];
        this.cheackNode = null
        this.cheackNodeObj = null
      },
      cheackRenderContent(h, { node, data, store }) {
        console.log('node',node)
        console.log('data',data)
        console.log('store',store)
        let userTips="";
        // 由于选中的人员数据来源不同，变量也不统一，各自分开处理
        if (data.prevNode) {
          // 从组织机构过来的数据
          if(data.prevNode && data.orgCodeId){
            userTips = "所属机构："+data.prevNode[data.orgCodeId]+"\n";
          }
          if(data.prevNode && data.departmentCodeId){
            userTips += "所属部门："+data.prevNode[data.departmentCodeId]+"\n";
          }
          if(data.prevNode && data.officeCodeId){
            userTips += "所属处室："+data.prevNode[data.officeCodeId]+"\n";
          }
          userTips += "姓    名："+data.nickName+"\n";
          userTips += "登录账号："+data.staffAccount+"\n";
          userTips += "邮件地址："+data.email+"\n";
        } else if (data.user) {
          data.user.orgDept && data.user.orgDept.deptName && (userTips = "所属机构：" + data.user.orgDept.deptName+"\n")
          data.user.departmentDept && data.user.departmentDept.deptName && (userTips += "所属部门：" + data.user.departmentDept.deptName+"\n")
          data.user.officeDept && data.user.officeDept.deptName && (userTips += "所属处室：" + data.user.officeDept.deptName+"\n")
          userTips += "姓       名："+data.user.nickName+"\n";
          userTips += "登录账号："+data.user.userName+"\n";
          userTips += "邮件地址："+data.user.email+"\n";
        }

        return  (
          <span class="org-tree-node"  title={userTips}>
          <i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label}
        </span>
       )
      },
      contactsUserRenderContent(h, { node, data, store }) {
        let userTips="";
        if(data.user.orgDept!=null){
          userTips = "所属机构："+data.user.orgDept.deptName+"\n";
        }
        if(data.user.orgDept!=null){
          userTips += "所属部门："+data.user.departmentDept.deptName+"\n";
        }
        if(data.user.officeDept!=null){
          userTips += "所属处室："+data.user.officeDept.deptName+"\n";
        }
        userTips += "姓    名："+data.user.nickName+"\n";
        userTips += "登录账号："+data.user.userName+"\n";
        if(data.user.email!=null){
          userTips += "邮件地址："+data.user.email+"\n";
        }
        return (
          <span class="org-tree-node" style="justify-content: space-between;">
            <span style="flex: 1; user-select:none" title={userTips}><el-radio style="width: 100%" label={data.user.email} v-model={ this.cheackNode }><i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label}</el-radio></span>
            <el-button size="mini" type="text" on-click={ () => this.removeContacts(data) }>移除</el-button>
          </span>
        )
      },
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
          userTips += "姓    名："+data.nickName+"\n";
          userTips += "登录账号："+data.staffAccount+"\n";
          userTips += "邮件地址："+data.email+"\n";
           renderNode= (
             <span class="org-tree-node"  title={userTips}>
               <el-radio label={data.email} v-model={ this.cheackNode }><i class="el-icon-user-solid" style="margin-right: 3px;color:#4b91ff;"></i>{node.label}</el-radio>
               </span>
            )
        }else{
            renderNode= (
              <span class="org-tree-node">
              <i class="el-icon-folder" style="margin-right: 3px;"></i>{node.label}</span>
            )
        }
        return renderNode
      },
      hadleNodeClick(data,obj,node) {

        if(node.expanded){
          node.expanded=false
          node.node.expanded=false
        }else{
          node.expanded=true
          node.node.expanded=true
        }

         if(data.user){
            return;
         }
         if (!data.children) {
            this.$set(data, 'children', []);
         }
         let queryParams={
           searchBaseCode : data.id,
           pageNum: 1,
           pageSize: 1000
          };
          listByOrgdept(queryParams).then(response => {
              var row = response.rows;
              if(row.length > 0){
                let childrenData =  data.children;
                let newchildrenData=[];
                for(var i in row){
                  var userName=row[i].userName;
                  const id = data.id+ "_"+ userName
                  if(this.loadData.indexOf(id) !== -1) {
                    continue;
                  }
                  this.loadData.push(id)
                  var nickName = row[i].nickName;
                  var sex=row[i].sex;
                  if(!this.userList.includes(userName)){
                    const newChild = { id: userName, label: nickName,user:true, sex:sex,children: [],user:row[i]};
                    newchildrenData.push(newChild);
                  }
                }
                newchildrenData = newchildrenData.concat(childrenData);
                data.children = newchildrenData;
              }
            }
          );
      },
       parentTree(arr, id) {   //arr 所有的树数据 id 某个子节点的id 
        var temp = [];
        var callback = function (nowArr, id) {     //先定义个函数寻找子节点位置 找到后 再找改节点父元素位置 以此类推
          for (var i = 0; i < nowArr.length; i++) {
            var item = nowArr[i];
            if (item.id === id) {
              temp.push(item);
              callback(arr, item.pid);     //pid 父级ID
              break;
            } else {
              if (item.children) {
                callback(item.children, id); //menus 子节点字段名称
              }
            }
          }
        };
        callback(arr, id);
        return temp;  //最后返回
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
      getReturnNode(node,_array,value){
        let isPass = node.data &&  node.data.label && node.data.label.indexOf(value) !== -1;
        isPass?_array.push(isPass):'';
        if(!isPass && node.level!=1 && node.parent){
          this.getReturnNode(node.parent,_array,value);
        }
      },
      searchOrg () {
        console.log('搜索')
        this.$set(this, 'orgTree', [])
        const sorgData = this.deepClone(this.$store.state.orgTree.sorgData)
        let arr = []
        let tree = []
        Object.values(sorgData).map(item=>{
          arr = [...arr, ...item]
          return item
        })
        
        const initArr = arr.filter(v=> v.label.includes(this.selectUserText)) || []
        console.log('newArr:', newArr)
        
        const newArr = initArr.map((item)=>{
          if(initArr.filter(v=> item.id.includes(v.id)).length>1){
            item.isRemove = true
          }
          return item
        }).filter((v)=> !v.isRemove)
        console.log('arr:', arr, newArr)

        window.newArr = newArr
        if(newArr.length){
          newArr.map(item=> {
            if(item.prevNode){
              const prevNode = Object.keys(item.prevNode)
              console.log(item)
              let baseTree = {}
              let arrjg = []
              prevNode.map((id, index)=>{
                if(index < prevNode.length - 1){
                  const jg = sorgData[id].filter(item => item.id === prevNode[index + 1] )
                  arrjg = [...arrjg, jg[0]] 
                }
              })
              console.log('arrjg:', arrjg)
              // console.log('item:', item)
              const index = arrjg.length - 1
              for(let i = 0;i<=index;i++){
                if(arrjg[i].label.includes(this.selectUserText)){
                  break;
                }else{
                  if(arrjg[index-i].label.includes(this.selectUserText)){
                    continue
                  }else{
                    if(index - i === index){
                     arrjg[index-i].children = [item]
                    }else{
                      arrjg[index-i].children = [arrjg[index-i+1]]
                    }
                  }
                }
              }
              baseTree = sorgData[`${Object.keys(arrjg[0].prevNode)[0]}_parent`][0]
              console.log('parent:', baseTree)
              const arrFilter = tree.filter(v=>v.id===baseTree.id)[0]
              if(arrFilter){
                arrFilter.children = [...arrFilter.children, arrjg[0]]
              }else{
                baseTree.children = [arrjg[0]]
                tree = [...tree, baseTree]
              }
            }else{
              tree = [...tree, item]
            }
          })

        }
        this.orgTree = this.deepClone(tree)
        this.$nextTick(() => {
          this.keys = newArr.map(v => v.id)
        })
        // for (let i = 0; i <= arr.length; i++) {
        //   if (arr[i].some(v => v.label === this.selectUserText)) {
        //     console.log(arr[i])
        //   } else {
        //     continue
        //   }
        // }
      },
      selectUser(){
        if (this.selectUserText && this.selectUserText.length > 1) {
          this.isLazy = false
          this.searchEnd = false
          this.$refs.orgTree.filter(this.selectUserText);
          console.log(this.cheackNode)
          // this.searchOrg()
        } else if (!this.selectUserText) {
           this.isLazy = true
          this.orgTree = this.deepClone(
            this.orgTreeData.map(v => {
              console.log(v)
              return {
                ...v,
                leaf: !(v.children && v.children.length),
                children: []
              }
            })
          )
        } else {
          this.$message.warning('请输入两个字符以上的内容进行搜索')
        }
      },
      /******************
       * @desc 增加常用联系人
       * @function addContactsUser
       */
      addContactsUser(){
        if(this.checkList.length==0){
          this.msgWarning("请先选择被委托人")
          return;
        }
        let nodes=this.checkList[0];
        let addData={
          contactsUserName:nodes.staffAccount
        }
        insertContactsUserList(addData).then(response => {
          // this.msgSuccess("添加成功");
          // this.selectlistContactsUserLists()
        });
      },
      removeContacts(data){
        let removeData={
          contactsUserName:data.id
        }
        deleteContactsUserList(removeData).then(response => {
          this.msgSuccess("移除成功");
          this.selectlistContactsUserLists()
        });
      },
      submit() {
        if (this.checkList.length) {
          // 自动将选中对象调整为常用联系人
          this.addContactsUser()
          this.$emit('callback',this.checkList);
          this.showInfo=false;
        } else {
          this.$confirm('未选择被委托人员，是否确定继续关闭？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }).then(() => {
            this.showInfo=false;
          }).catch(() => {
            // 不做任何操作         
          });
        }
        
      }
    }
  };

</script>
<style lang="scss" scoped>
  ::v-deep .el-tabs{
    height: 100%;
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
  }
  .searchBar{
    display: flex;
    width: 100%;
    .el-input{
      flex: 1;
    }
    .el-button{
      margin-left: 12px;
    }
  }
  ::v-deep .el-tree-node__content{
    span.org-tree-node{
      width: 100%;
      display: flex;
      align-items: center;
    }
  }
  ::v-deep .el-dialog__body{
    padding: 10px 20px;
  }
  ::v-deep .maxHeightDivLeft{
    margin-top: 0!important;
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    flex-direction: column;
  }
  .treemaxHeightDiv {
    height: 340px;
    padding: 5px;
    overflow: auto;
    // margin-bottom: -20px;
    box-sizing: border-box;
  }

  .maxHeightDivLeft {
    height: 450px;
    padding: 5px;
    margin-top: 180px;
    text-align: center;
  }
  .maxHeig{
    border: 1px solid rgb(221, 221, 221);
    padding: 10px;
    height: 450px;
  }
  ::v-deep .el-dialog__body{
    padding: 0 20px!important;
  }
</style>
