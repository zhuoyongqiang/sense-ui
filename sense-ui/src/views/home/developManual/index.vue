<template>
  <div class="wrapper">
    <div class="menu-wrapper">
      <div class="menu-title">
        <div class="title" :title="listParent && listParent.catalogName">{{listParent && listParent.catalogName}}</div>
        <div v-show="isAdmin"><i title="设置" class="el-icon-setting" @click="listSettingBtn"></i></div>
      </div>
      <!-- 菜单树 -->
      <menu-list :data="list" :isCollapse="isCollapse" :activeMenu="activeMenu" @handleSelect="handleSelect"></menu-list>      
    </div>

    <div class="container-wrapper">
      <div class="header-wrapper">
        <el-breadcrumb separator-class="el-icon-arrow-right">
          <el-breadcrumb-item>{{listParent && listParent.catalogName}}</el-breadcrumb-item>
          <el-breadcrumb-item v-for="item in menus" :key="item.id">{{item.catalogName}}</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <Editor
        v-loading="editorLoding"
        v-show="editMode"
        ref="editor"
        :height="400"
        v-model="content"
        :plugins="plugins"
        :toolbar="toolbar"
        :imagesUploadHandler="imagesUploadHandler"
      />
      <div class="preview-panel" v-show="!editMode" v-loading="iframeLoading">
          <iframe id="frame" v-show="content" ref="frame" name="frame" style="width:100%;" frameborder="no"></iframe>
      </div>
    </div>

    <div class="control-wrapper" v-show="isAdmin && activeMenu">
      <el-button type="primary" plain v-show="!editMode" @click="editMode = true"><i class="el-icon-edit"></i></el-button>
      <el-button type="danger" plain v-show="editMode" @click="back">返回</el-button>
      <el-button type="primary" plain v-show="editMode" @click="saveContent">保存</el-button>
    </div>

    <!-- 目录树 -->
    <el-dialog title="目录" :visible.sync="treedialogShow" :before-close="handleClosetree" class="tree-dialog" :close-on-click-modal="false" :close-on-press-escape="false">
      <div class="title-wrapper">
        <div class="title">{{treeTitle && treeTitle.catalogName}}</div>
        <div class="edit" v-show="listParent" @click="edit(treeTitle)">修改</div>
        <div class="add" v-show="listParent" @click="addrootNode">新增目录</div>
        <div class="add" v-show="!listParent" @click="addRoot">新增文档</div>
        <!-- <div class="add" @click="removeRoot(listParent)">删除根文档</div> -->
      </div>

      <!-- @node-drag-start="handleDragStart"
        @node-drag-enter="handleDragEnter"
        @node-drag-leave="handleDragLeave"
        @node-drag-over="handleDragOver"
        @node-drag-end="handleDragEnd" -->
      <el-tree
        v-loading="treeLoading"
        ref="tree"
        :data="treeData"
        node-key="id"
        :props="treeProps"
        default-expand-all
        @node-drop="handleDrop"
        draggable
        :allow-drop="allowDrop"
        :allow-drag="allowDrag"
        empty-text="暂无目录"
         :expand-on-click-node="false">
        <span class="custom-tree-node" slot-scope="{ node, data }">
        <span>{{ node.label }}</span>
        <span>
          <el-button
            type="text"
            size="mini"
            @click="() => append(data)">
            新增子目录
          </el-button>
          <el-button
            type="text"
            size="mini"
            @click="() => edit(data)">
            修改
          </el-button>
          <el-button
            type="text"
            size="mini"
            @click="() => remove(node, data)">
            删除
          </el-button>
        </span>
      </span>
      </el-tree>

      <div slot="footer" class="dialog-footer">
        <el-button @click="handleClosetree">取 消</el-button>
        <el-button type="primary" @click="saveTree">保存</el-button>
      </div>

      <!-- 新增、修改目录弹框 -->
      <el-dialog :title="dialogForm.title" ref="dialogForm" :visible.sync="dialogForm.show" width="50%" :before-close="treeinnerCanel" append-to-body>
        <el-form :model="dialogForm.form" ref="form">
          <el-form-item label="编号" labelWidth="80px" prop="id" v-show="dialogForm.form.id">
            <el-input v-model="dialogForm.form.id" readonly></el-input>
          </el-form-item>
          <el-form-item label="标题" labelWidth="80px" prop="name" :rules="[
              { required: true, message: '目录标题不得为空'},
            ]">
            <el-input v-model="dialogForm.form.name" autocomplete="off"></el-input>
          </el-form-item>
          <el-form-item label="图标" labelWidth="80px" prop="icon" v-show="dialogForm.iconShow">
            <el-select v-model="dialogForm.form.icon" clearable @click.native="iconsShow = true" placeholder="请使用内置的图标字符" autocomplete="off"></el-select>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="treeinnerCanel">取 消</el-button>
          <el-button type="primary" @click="treeinnerDialog">确 定</el-button>
        </div>
        <!-- 图标库 -->
        <el-dialog title="图标库" ref="iconDialog" :visible.sync="iconsShow" width="50%" append-to-body>
          <iconUi @confrimIcon="confrimIcon"></iconUi>
        </el-dialog>
      </el-dialog>
    </el-dialog>
  </div>
</template>
<script>
import Editor from "@/views/home/developManual/tinymce.vue";
import Prism from "@/views/home/developManual/prim.js"; 
import {uploadFile} from "@/api/common";
import {getToken} from "@/utils/auth";
import menuList from '@/views/home/developManual/menuList.js'
import iconUi from  '@/views/home/developManual/iconUI'
import {addCatalog, updateCatalog, listCatalog, delCatalog, addContent, updateContent, delContent, getContentByCatalog} from '@/api/home/developManual'
import { on, off } from '@/utils/event';
export default {
  name: 'developManual',
  components: {
    Editor,
    menuList,
    iconUi
  },
  data () {
    return {
      editorLoding: false, // 富文本框加载动画， 用于请求文档接口时触发加载效果
      iframeLoading: false, // 挂载iframe元素的父容器加载动画，用于等待iframe渲染时触发的加载效果
      treeLoading: false, // 目录树加载动画，用于变更目录请求相关接口时触发的加载效果
      menus: [], // 横向菜单
      editMode: false, // 是否为编辑模式
      loading: false, // 是否在加载
      isCollapse: false, // 是否收起
      treedialogShow: false, // 目录树显示、隐藏
      dialogFormVisible: false, // 新增、修改目录弹框显示、隐藏
      iconsShow: false, // 图标库弹框显示、隐藏
      activeMenu: null, // 当前激活的菜单id
      plugins: 'uploadFile code searchreplace link codesample preview nonbreaking insertdatetime media table wordcount editorImage  charmap hr fullscreen pagebreak lists advlist indent2em',
      toolbar: 'uploadFile code undo redo | codesample formatselect  | fontselect | fontsizeselect | bold italic forecolor backcolor underline strikethrough subscript superscript | searchreplace preview nonbreaking insertdatetime | indent2em blockquote | alignleft aligncenter alignright alignjustify bullist numlist | editorImage  media link unlink  table  | hr pagebreak | charmap lineheight removeformat',
      content: null, // 富文本内容
      // 上传参数
      uploadSetting: {
        // 设置上传的请求头部
        headers: {Authorization: "Bearer " + getToken()},
        // 上传的地址
        url: process.env.VUE_APP_BASE_API + "/common/upload"
      },
      list: [], // 菜单目录数据
      listParent: null, // 树结构头结点即文档标题
      treeTitle: null, // 目录树弹框标题
      treeData: [], // 目录树数据
      treeProps: { // 变更默认目录树展示的字段名
        label: 'catalogName',
        children: 'children'
      },
      orignList: [], // 目录原始数据
      parentNode: null, // 目录树父节点
      addnodeArr: [], // 新增目录数组
      deletenodeArr: [], // 删除目录数组
      updatenodeArr: [], // 更新目录数组
      dialogForm: { // 新增、修改目录form表单
        type: null, // 表单类型, add | 新增，edit
        title: null, // 表单标题
        show: false, // 表单弹框显示、隐藏
        iconShow: true, // 图标选择框显示、隐藏
        form: { // 表单字段
          id: '', // 目录id
          name: '', // 目录名称
          icon: '' // 目录图标
        }
      },
      contentId: null, // 文章id
      baseFilePath: undefined,
      iframeHeights: [],
      iframeMaxHeight: 0,
      iframeMaxHeightNum: 0
    }
  },
  computed: {
    isAdmin () {
      return this.$store.state.user.roles.includes('admin')
    }
  },
  updated () {
    this.$nextTick(() => {
      Prism.highlightAll()
    })
  },
  watch: {
    activeMenu (val) {
      // this.content = ''
      this.$refs.editor.clear()
      this.content = null
      // 根据目录id获取内容
      if (!val) {
        return
      }
      this.$nextTick(() => {
        if (this.isShow(document.querySelector('.el-menu-item.is-active'))) {
          //
        }
      })
      // console.warn((document.querySelector('.el-menu-item')))
      // listContent({
      //   pageSize: 100
      // }).then(res => {
      //   console.log('文章列表', res)
      // })
      if (this.editMode) {
        this.editorLoding = true
      } else {
        this.iframeLoading = true
      }
      this.queryContent()
    },
    content (val) {
      if (val && !this.editMode) {
        // 当文档存在内容时并且当前模式为非编辑模式，设置iframe填充文档内容
        this.setContentHTML(val)
      }
    }
  },
  created () {
    this.getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
    });
  },
  mounted () {
    // 初始化请求文档目录
    this.queryList()
  },
  methods: {
    // 菜单选择事件
    handleSelect (id, path) {
      this.activeMenu = id
      this.menus = []
      path.forEach(p => {
        this.menus.push(this.orignList.find(v => v.id === p))
      })
    },
    // 新增一级文档
    addRoot () {
      this.dialogForm.type = 'addRoot'
      this.dialogForm.title = '新增文档'
      this.dialogForm.iconShow = false
      this.dialogForm.show = true
    },
    // 删除一级文档，测试用
    removeRoot (m) {
      delCatalog(m.id).then((res) => {
        if (res.code == 200) {
          this.listParent = null
        } else {
          this.msgError('删除失败')
        }
      }).catch((err) => {
        this.msgError('删除失败')
      })
    },
    // 新增一级目录
    addrootNode () {
      this.dialogForm.type = 'add'
      this.dialogForm.title = '新增目录'
      this.dialogForm.iconShow = true
      this.parentNode = this.listParent
      this.dialogForm.show = true
    },
    // 设置富文本展示内容
    setContentHTML (content) {
      if (!content) {
        return
      }
      const timer = setTimeout(() =>{
        clearTimeout(timer)
        const iframe = window.frames['frame'];
        this.$refs.frame.height = 0
        iframe.document.open();
        let str = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
        str += '<html xmlns="http://www.w3.org/1999/xhtml">'
        str += '<head>'
        str += '<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />'
        str += '<style>'
        str += 'html, body{margin:0;padding:0;} *{max-width: 100%; height:auto} body{overflow: hidden}'
        str += '</style>'
        str += '</head>'
        str += '<body>'
        str += content
        str += '</body>'
        str += '</html>'
        // iframe.document.write('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
        // iframe.document.write('<html xmlns="http://www.w3.org/1999/xhtml">');
        // iframe.document.write('<head>');
        // iframe.document.write('<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />');
        // iframe.document.write('<style>');
        // iframe.document.write('*{margin:0;padding:0; max-width: 100%; height:auto} body{overflow: hidden}');
        // iframe.document.write('</style>');
        // iframe.document.write('</head>');
        // iframe.document.write('<body>');
        // iframe.document.write(content);
        // iframe.document.write('</body>');
        // iframe.document.write('</html>');
        iframe.document.write(str)
        iframe.document.close();
        // this.resizeIframe()
        // $(iframe.document).ready(function(){
        //   self.resizeIframe()
        // })
        this.iframeHeights = []
        this.resizeIframe()
      },0);
    },
    // 设置iframe自适应高度
    resizeIframe () {
      let timer
      if (this.$refs.frame) {
        const max = Math.max(this.$refs.frame.contentWindow.document.body.scrollHeight, this.$refs.frame.contentWindow.document.documentElement.scrollHeight)
        if(+this.$refs.frame.height !== max){
          this.$refs.frame.height = max
          this.iframeMaxHeightNum = 0
          // this.iframeHeights.push(max + 20)
        }else{
          this.iframeMaxHeightNum += 1
        }
        if(this.iframeMaxHeightNum >= 5){
          this.iframeLoading = false
          // 给a标签绑定事件
          this.bindAelement()
          clearTimeout(timer)
        }else{
          timer = setTimeout(()=>{
            clearTimeout(timer)
            this.resizeIframe()
          }, 100)
        }
      }
    },
    // 新增、编辑目录弹框确定事件
    treeinnerDialog () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          const data = this.parentNode
          switch (this.dialogForm.type) {
            case 'addRoot':
              addCatalog({
                catalogName: this.dialogForm.form.name
              }).then((res) => {
                if (res.code == 200) {
                  this.listParent
                  this.$nextTick(()=>{
                    this.$refs.form.resetFields()
                    this.dialogForm.show = false
                    this.treedialogShow = false
                    this.queryList()
                  })
                } else {
                  this.msgError('新增文档失败')
                }
              }).catch((err) => {
                this.msgError('新增文档失败')
              })
              break
            case 'add':
              const newChild = {
                id: new Date().getTime() + '',
                catalogName: this.dialogForm.form.name,
                icon: this.dialogForm.form.icon,
                parentId: data.id,
                children: []
              };
              if (!data.children) {
                this.$set(data, 'children', []);
              }
              if (!data.parentId) {
                this.treeData.push(newChild)
                this.addnodeArr.push({
                  ...newChild, orderNum: this.treeData.length - 1
                })
              } else {
                data.children.push(newChild);
                this.addnodeArr.push({
                  ...newChild, orderNum: data.children.findIndex(c => c.id === newChild.id)
                })
              }
              this.$nextTick(()=>{
                this.$refs.form.resetFields()
                this.dialogForm.show = false
              })
              break
            case 'edit':
              data.catalogName = this.dialogForm.form.name
              data.icon = this.dialogForm.form.icon
              this.updatenodeArr.push(data)
              this.$nextTick(()=>{
                this.$refs.form.resetFields()
                this.dialogForm.show = false
              })
              break
            default:
              break
          }
        } else {
          return false;
        }
      });      
    },
    // 新增、编辑目录弹框取消事件
    treeinnerCanel (){
      this.$nextTick(()=>{
        this.$refs.form.resetFields()
        this.dialogForm.show = false
      })
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
    // 请求菜单列表
    queryList () {
      this.addnodeArr = []
      this.updatenodeArr = []
      this.deletenodeArr = []
      listCatalog().then((res) => {
        if (res.code === 200) {
          if (res.rows.length) {
            this.listParent = res.rows[res.rows.findIndex(v => !v.parentId)]
            this.orignList = res.rows.filter(m => !!m.parentId)
            this.list = this.setTreeData(res.rows.filter(m => !!m.parentId))
            // 请求文档内容列表
            this.menus = []
            this.getDefaultmenu(this.list)
            // this.activeMenu = this.list[0].id
            // this.saveTree(this.list)
          }
        }
      }).catch((err) => {
        console.warn('listCatolog：', err)
      })
    },
    // 设置初始激活菜单
    getDefaultmenu(data) {
      if (data.length) {
        if (data[0].children && data[0].children.length) {
          this.menus.push(data[0])
          this.getDefaultmenu(data[0].children)
        } else {
          this.menus.push(data[0])
          this.activeMenu = data[0].id
        }
      }
    },
    // 菜单设置按钮
    listSettingBtn () {
      this.treeTitle = this.listParent
      this.treeData = this.deepClone(this.list)
      this.addnodeArr = []
      this.updatenodeArr = []
      this.deletenodeArr = []
      this.treedialogShow = true
    },
    /**富文本框图片上传*/
    imagesUploadHandler(data, success) {
      let formData = new FormData();
      formData.append('file', data);
      formData.append('isSave', 'true');
      formData.append('type', 'profile');
      uploadFile(formData).then(response => {
        if (response.code == 200) {
          success(this.baseFilePath + response.data.attachmentUrl);
        }
      })
    },
    // 新增目录
    append(data) {
      this.dialogForm.type = 'add'
      this.dialogForm.title = '新增目录'
      this.dialogForm.iconsShow = false
      this.parentNode = data
      this.dialogForm.show = true
    },
    // 修改目录
    edit(data) {
      this.dialogForm.type = 'edit'
      this.dialogForm.title = '修改目录'
      this.dialogForm.iconsShow = false
      this.parentNode = data
      this.dialogForm.show = true
      if (data.id === this.listParent.id) {
        this.dialogForm.iconShow = false
      } else {
        this.dialogForm.iconShow = true
      }
      this.$nextTick(() => {
        this.dialogForm.form.id = data.id
        this.dialogForm.form.name = data.catalogName
        this.dialogForm.form.icon = data.icon
      })
    },
    // 删除目录
    remove(node, data) {
      if (node) {
        const parent = node.parent;
        const children = parent.data.children || parent.data;
        const index = children.findIndex(d => d.id === data.id);
        children.splice(index, 1);
      }
      if (this.addnodeArr.some(m => m.id === data.id)) {
        // 删除的目录是否存在于新增目录数组中，存在则直接从新增组里剔除，不加入需要调用接口删除的删除数组
        this.addnodeArr.splice(this.addnodeArr.findIndex(m => m.id === data.id), 1)
      } else if (this.updatenodeArr.some(n => n.id === data.id)) {
        // 删除的目录是否存在于更新目录数组中，存在则直接从更新组里剔除，不加入需要调用接口删除的更新数组
        this.updatenodeArr.splice(this.updatenodeArr.findIndex(n => n.id === data.id), 1)
        this.deletenodeArr.push(data)
      } else {
        this.deletenodeArr.push(data)
      }
    },
    // handleDragStart(node, ev) {
    //   console.log('drag start', node);
    // },
    // handleDragEnter(draggingNode, dropNode, ev) {
    //   console.log('tree drag enter: ', dropNode.label);
    // },
    // handleDragLeave(draggingNode, dropNode, ev) {
    //   console.log('tree drag leave: ', dropNode.label);
    // },
    // handleDragOver(draggingNode, dropNode, ev) {
    //   console.log('tree drag over: ', dropNode.label);
    // },
    // handleDragEnd(draggingNode, dropNode, dropType, ev) {
    //   console.log('tree drag end: ', dropNode && dropNode.label, dropType);
    // },
    // 拖拽结束事件
    handleDrop(draggingNode, dropNode, dropType, ev) {
      let currentNode = draggingNode.data
      let paramData = [];
		  // 当拖拽类型不为inner,说明只是同级或者跨级排序，只需要寻找目标节点的父ID，获取其对象以及所有的子节点，并为子节点设置当前对象的ID为父ID即可
		  // 当拖拽类型为inner，说明拖拽节点成为了目标节点的子节点，只需要获取目标节点对象即可
      let data = dropType != "inner" ? dropNode.parent.data : dropNode.data;
      let nodeData = dropNode.level == 1 && dropType != "inner" ? data : data.children;
		  // 设置父ID,当level为1说明在第一级，pid为文档标题的id
		  nodeData.forEach(element => {
		    element.pid = dropNode.level == 1 && dropType != 'inner' ? this.listParent.id : data.id;
		  });
      
      nodeData.forEach((element, i) => {
          var dept = {
            deptId: element.id,
            parentDeptId: element.pid,
            order: i
          };
          paramData.push(dept);

          // 判断是否存在于新增数组里
          const addIndex = this.addnodeArr.findIndex(a => a.id === element.id)
          if (addIndex >= 0) {
            this.addnodeArr[addIndex] = {
              parentId: element.pid,
              orderNum: i,
              catalogName: element.catalogName
            }
          } else {
            // 判断是否存在于更新数组里
            const updateIndex = this.updatenodeArr.findIndex(u => u.id === element.id)
            if (updateIndex >= 0) {
              this.updatenodeArr[updateIndex] = {
                id: element.id,
                parentId: element.pid,
                orderNum: i,
                catalogName: element.catalogName
              }
            } else {
              const orginData = this.orignList.find(m => m.id === element.id)
              if (orginData.orderNum === i && orginData.parentId === element.pid) {
                // 在原始数组中查找排序号，排序号相同的情况下不做处理
              } else {
                // 在原始数组中查找排序号，排序号不同的情况下插入新增数组中
                this.updatenodeArr.push({
                  id: element.id,
                  parentId: element.pid,
                  orderNum: i,
                  catalogName: element.catalogName
                })
              }
            }
          }
        })
      // currentNode = {
      //   ...currentNode,
      //   parentId: nodeData[0].pid,
      //   orderNum: nodeData.findIndex(v => v.id === currentNode.id)
      // }
      
    },
    // 所有位置均允许被放置
    allowDrop(draggingNode, dropNode, type) {
      return true;
    },
    // 所有节点均允许拖拽
    allowDrag(draggingNode) {
      return true;
      // return draggingNode.data.label.indexOf('三级 3-2-2') === -1;
    },
    // 关闭目录树编辑器前的回调
    handleClosetree (done) {
      if (this.addnodeArr.length || this.updatenodeArr.length || this.deletenodeArr.length) {
        this.$confirm('存在编辑操作，是否确认不保存直接关闭？')
        .then(_ => {
          done && typeof done === 'function' ? done() : this.treedialogShow = false
        })
        .catch(_ => {});
      } else {
        done && typeof done === 'function' ? done() : this.treedialogShow = false
      }
    },
    // 保存目录树
    saveTree () {
      if (!this.addnodeArr.length && !this.updatenodeArr.length && !this.deletenodeArr.length) {
        this.treedialogShow = false
        return
      }
      this.treeLoading = true
      let promiseArr = []
      // 构建新增节点的promise对象
      this.addnodeArr.forEach((m) => {
        promiseArr.push(
          new Promise((resolve, reject) => {
            addCatalog(m).then((res) => {
              if (res.code == 200) {
                resolve(res)
              } else {
                reject(res)
              }
            }).catch((err) => {
              reject(err)
            })
          })
        )
      })
      // 构建更新节点的promise对象
      this.updatenodeArr.forEach((m) => {
        promiseArr.push(
          new Promise((resolve, reject) => {
            updateCatalog(m).then((res) => {
              if (res.code == 200) {
                resolve(res)
              } else {
                reject(res)
              }
            }).catch((err) => {
              reject(err)
            })
          })
        )
      })
      // 构建删除节点的promise对象
      this.deletenodeArr.forEach((m) => {
        promiseArr.push(
          new Promise((resolve, reject) => {
            delCatalog(m.id).then((res) => {
              if (res.code == 200) {
                resolve(res)
                // this.deleteContent(m.id)
              } else {
                reject(res)
              }
            }).catch((err) => {
              reject(err)
            })
          })
        )
      })
      Promise.all(promiseArr).then(res => {
        console.warn('Promise.all:RESULT：', res)
        this.$message({
          message: '保存成功',
          type: 'success'
        })
        this.treeLoading = false
        this.treedialogShow = false
        this.queryList()
      }).catch(err => {
        if (err.length === promiseArr.length) {
          this.$message({
            message: '保存失败',
            type: 'error'
          })
          this.treeLoading = false
        } else {
          this.$message({
            message: '部分目录保存存在异常',
            type: 'error'
          })
          this.treeLoading = false
          this.treedialogShow = false
          this.queryList()
        }
        console.warn('Promise.all:ERROR：', err)
      })
    },
    setTreeData (data, parentId = this.listParent.id) {
      let arr = [];
        for(var i=0; i< data.length; i++){ 
          if(data[i].parentId == parentId ){ 
              let newNode = {...data[i], children: this.setTreeData(data, data[i].id)};
              arr.push(newNode);              
          }
        }
      if (arr.length) {
        arr.sort((a, b) => a.orderNum - b.orderNum)
      }
      return arr
    },
    // 文档编辑返回按钮
    back() {
      this.editMode = false
      this.queryContent()
    },
    // 删除文档内容
    deleteContent (id) {
      getContentByCatalog(id).then((res) => {
        delContent(res.id).then(() => {
        }).catch((err) => {
          console.warn('delContent接口异常：', err)
        })
      })
    },
    // 查询文档内容
    queryContent () {
      if (this.editMode) {
        this.editorLoding = true
      } else {
        this.iframeLoading = true
      }
      this.content = null
      // 根据目录id获取内容
      getContentByCatalog(this.activeMenu).then(res => {
        this.contentId = (res.data && res.data.id) ||  null
        this.content = (res.data && res.data.content) || ''
        if (this.editMode) {
          this.editorLoding = false
        } else {
          this.iframeLoading = false
        }
      }).catch(err => {
        if (this.editMode) {
          this.editorLoding = false
        } else {
          this.iframeLoading = false
        }
        console.warn('getContentByCatalog接口异常，', err)
      })
      // getContentByCatalog(this.activeMenu).then(res => {
      //   this.content = (res.data && res.data.content) || ''
      //   if (this.editMode) {
      //     this.loading = false
      //     this.setContentHTML(this.content)
      //     this.editMode = false
      //   }
      // }).catch(err => {
      //   this.loading = false
      //   this.content = ''
      //   console.warn('getContentByCatalog接口异常，', err)
      // })
    },
    // 保存富文本内容
    saveContent () {
      this.editorLoding = true
      if (this.contentId) {
        const data = {
          id: this.contentId,
          // catalogId: this.activeMenu,
          content: this.content
        }
        updateContent(data).then(res => {
          this.editorLoding = false
          this.editMode = false
          this.queryContent()
        }).catch(err => {
          this.editorLoding = false
          console.warn('updateContent接口异常：', err)
        })
      } else {
        const data = {
          catalogId: this.activeMenu,
          content: this.content
        }
        addContent(data).then((res) => {
          this.editorLoding = false
          this.editMode = false
          // 根据目录id获取内容
          this.queryContent()
        }).catch(err => {
          this.editorLoding = false
          console.warn('addContent接口异常：', err)
        })
      }
    },
    // 图标选择确定事件
    confrimIcon (item) {
      this.dialogForm.form.icon = item.iconClass
      this.iconsShow = false
    },
    bindAelement () {
      const aDivs = this.ConvertToArray(this.$refs.frame.contentWindow.document.querySelectorAll('a')).filter(m => m.hash.startsWith('#'))
      console.log('aDvis', this.$refs.frame.contentWindow.document.querySelectorAll('a'))
      console.log('aDvis', aDivs)
      // for (let i = 0; i < this.$refs.frame.contentWindow.document.querySelectorAll('a').length; i++) {
      //   if (this.$refs.frame.contentWindow.document.querySelectorAll('a')[i].hash.startsWith('#')) {
      //     this.$refs.frame.contentWindow.document.querySelectorAll('a')[i].onclick = () => {

      //     }
      //   }
      // }
      if (aDivs.length) {
        aDivs.forEach(m => {
          console.log(m)
          m.onclick = (e) => {
            this.activeMenu = m.hash.slice(1)
          }
        })
      }
    },
    handler (bind, dom, event, func) {
      if (bind) {
        on(dom, event, this[func], true)
      } else {
        off(dom, event, this[func], true)
      }
    },
    ConvertToArray (nodes) {
    let array = null
      try{
        array=Array.prototype.slice.call(nodes, 0);//非ie浏览器  ie8-将NodeList实现为COM对象，不能用这种方式检测
      } catch(ex){//ie8-
        array=new Array();
        for(var i=0;i< nodes.length; i++){
          array.push(nodes[0]);
        }
      }
    return array;
    },
    jumpMenu (event) {
      console.log(event)
    },
    // 判断dom元素是否在视野内，不在视野内则自动滚动到视野内
    isShow(el){
      var rect = el.getBoundingClientRect();
      if (
          rect.top >= 0 &&
          rect.left >= 0 &&
          rect.bottom <=
          (window.innerHeight || document.documentElement.clientHeight) &&
          rect.right <=
          (window.innerWidth || document.documentElement.clientWidth)
      ) {
        return true
      } else {
        el.scrollIntoView()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import './prism.scss';
  .wrapper{
    display: flex;
    height: calc(100vh - 64px);
  }
  .menu-wrapper{
    height: 100%;
    display: flex;
    flex-direction: column;
    .menu-title{
      display: flex;
      justify-content: space-between;
      align-items: center;
      width: 240px;
      text-align: justify;
      padding: 6px 10px;
      box-sizing: border-box;
      background-color: #333;
      color:#fff;
      .title{
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        cursor: default;
      }
      i{
        margin-left: 10px;
        cursor: pointer;
      }
    }
    .el-menu{
      flex: 1;
      overflow-y: auto;
      &:not(.el-menu--collapse) {
        width: 240px;
      }
      ::v-deep *{
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
  }
  .container-wrapper{
    flex: 1;
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: #fff;
    ::v-deep .tox-tinymce{
      height: 100%!important;
    }
    .header-wrapper{
      padding: 20px 16px;
      +div{
        flex: 1;
      overflow-y: auto;
      }
    }
  }
  .preview-panel{
    // height: 100%;
    flex: 1;
    background-color: #fff;
    overflow-y: auto;
    padding: 20px 16px;
    box-sizing: border-box;
  }
  .control-wrapper{
    padding-top: 16px;
    width: 80px;
    text-align: center;
    >.el-button{
      margin-bottom: 10px;
      margin-left: 0;
    }
  }

  .tree-dialog {
    .title-wrapper{
      display: flex;
      align-items: center;
      .title{
        font-weight: bold;
        font-size: 20px;
        margin-bottom: 12px;
        flex: 1;
      }
      .edit{
        color:#1890ff;
        font-size: 12px;
        white-space: nowrap;
        margin-left: 12px;
        margin-right: 2px;
        cursor: pointer;
      }
      .add{
        color:#1890ff;
        font-size: 12px;
        white-space: nowrap;
        margin-left: 12px;
        margin-right: 2px;
        cursor: pointer;
      }
    }
    ::v-deep .el-dialog__body{
      width: 100%;
      box-sizing: border-box;
      .el-tree{
        width: 100%;
        .el-tree-node{
          width: 100%;
        }
        .el-tree-node__content{
          width: 100%;
        }
      }
      .custom-tree-node{
        flex: 1;
        display: flex;
        justify-content: space-between;
      }
    }
  }

  .el-select{
    width: 100%;
  }
  .el-breadcrumb{
    line-height: 1.5;
  }
  
</style>