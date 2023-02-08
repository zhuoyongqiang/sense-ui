<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="68px">
      <el-form-item label="标识" prop="sn">
        <el-input
          v-model.trim="queryParams.sn"
          placeholder="标识"
          clearable
          size="mini"
          class="search__input"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="名称" prop="name">
        <el-input
          v-model.trim="queryParams.name"
          placeholder="请输入名称"
          clearable
          size="mini"
          class="search__input"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-select v-model.trim="queryParams.type" placeholder="请选择组件类型" clearable size="mini" class="search__input">
          <el-option
            v-for="dict in typeOptions"
            :key="dict.dictValue"
            :label="dict.dictLabel"
            :value="dict.dictValue"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">刷新</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['sdsp:component:add']"
        >新增
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['system:component:edit']"
        >修改
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['system:component:remove']"
        >删除
        </el-button>
      </el-col>
    </el-row>
    <el-table v-loading="loading" :data="componentList" @selection-change="handleSelectionChange" :height="tableHeight">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="ID" align="center" prop="id"/>
      <el-table-column label="组件标识" align="center" prop="sn"/>
      <el-table-column label="名称" align="center" prop="name"/>
      <el-table-column label="描述" align="center" prop="desc"/>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{m}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d} {h}:{m}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="组件类型" align="center" prop="type" :formatter="typeFormat" sortable/>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:component:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:component:remove']"
          >删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
    <!-- 添加或修改组件对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body
               :close-on-press-escape="false" :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="组件标识" prop="sn">
          <el-input v-model.trim="form.sn" placeholder="请输入组件标识" :disabled="snAble"/>
        </el-form-item>
        <el-form-item label="名称" prop="name">
          <el-input v-model.trim="form.name" placeholder="请输入名称"/>
        </el-form-item>
        <el-form-item label="组件:" prop="file">
          <el-upload
            ref="uploadFile"
            action="#"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            multiple
            :limit="1"
            :on-exceed="handleExceed"
            :http-request="uploadSectionFile"
          >
            <el-button size="small" type="primary">点击上传</el-button>
            <div slot="tip" class="el-upload__tip">只能上传jar文件</div>
          </el-upload>
        </el-form-item>
        <el-form-item label="组件类型" prop="type">
          <el-select v-model.trim="form.type" style="width:100%" placeholder="请选择组件类型">
            <el-option
              v-for="dict in typeOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="parseInt(dict.dictValue)"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="desc">
          <el-input v-model.trim="form.desc" type="textarea" placeholder="请输入内容"/>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import {
  listComponent,
  getComponent,
  delComponent
} from "@/api/console/system/component";

import axios from 'axios'
import {getToken} from '@/utils/auth'
import {debounce} from "../../../../utils";

export default {
  name: "Component",
  data() {
    let findSN = (rule, value, callback) => {
      if (value == "" || value == null) {
        return callback(new Error('组件标识不能为空'));
      }
      let obj = {};
      obj.sn = value;
      listComponent(obj).then(response => {
        if (this.snAble) {
          return callback()
        }
        if (response.total === 0) {
          return callback();
        } else {
          return callback(new Error('组件标识：' + value + ' 已存在'));
        }
      });
    }
    return {
      //表格高度
      tableHeight: undefined,
      fileName: '',
      files: '',
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 总条数
      total: 0,
      // 组件表格数据
      componentList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // ID字典
      idOptions: [],
      // 组件标识字典
      snOptions: [],
      // 名称字典
      nameOptions: [],
      // 描述字典
      descOptions: [],
      // 内容字典
      contentOptions: [],
      // 创建时间字典
      createTimeOptions: [],
      // 更新时间字典
      updateTimeOptions: [],
      // 组件类型字典
      typeOptions: [],
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        sn: undefined,
        name: undefined,
        desc: undefined,
        type: undefined
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        sn: [
          {required: true, validator: findSN, trigger: "blur"}
        ],
        name: [
          {required: true, message: "名称不能为空", trigger: "blur"}
        ],
        type: [
          {required: true, message: "组件类型不能为空", trigger: "change"}
        ],
      },
      //判断标识输入框是否可用
      snAble: false
    };
  },
  mounted() {
    //初始化高度
    this.initTableHeight();
  },
  created() {
    this.getList();
    this.getDicts("component_type").then(response => {
      this.typeOptions = response.data;
    });
  },
  methods: {
    //获取浏览器高度并计算得到表格所用高度。
    initTableHeight() {
      this.tableHeight = document.documentElement.clientHeight - 260;
    },
    handleRemove(file, fileList) {
      console.log(file, fileList);
    },
    handlePreview(file) {
      console.log(file);
    },
    handleExceed(files, fileList) {
      this.$message.warning(`当前限制选择 1 个文件，本次选择了 ${files.length} 个文件，共选择了 ${files.length + fileList.length} 个文件`);
    },
    beforeRemove(file, fileList) {
      return this.$confirm(`确定移除 ${file.name}？`);
    },
    /** 查询组件列表 */
    getList() {
      this.loading = true;
      listComponent(this.queryParams).then(response => {
        this.componentList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 组件类型字典翻译
    typeFormat(row, column) {
      return this.selectDictLabel(this.typeOptions, row.type);
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: undefined,
        sn: undefined,
        name: undefined,
        desc: undefined,
        createTime: undefined,
        updateTime: undefined,
        type: undefined
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length != 1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      let self = this;
      if (self.$refs['uploadFile']) {
        self.$refs['uploadFile'].clearFiles();
        self.fileName = '';
        self.files = '';
      }
      this.reset();
      this.open = true;
      this.title = "添加组件";
      this.snAble = false;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      this.snAble = true;
      const id = row.id || this.ids
      getComponent(id).then(response => {
        this.form = response.data;
        let self = this;
        if (self.$refs['uploadFile']) {
          self.$refs['uploadFile'].clearFiles();
          self.files = "";
          self.fileName = "";
        }
        this.open = true;
        this.title = "修改组件";
      });
    },
    /** 提交按钮 */
    submitForm: debounce(function () {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != undefined) {
            let self = this;
            let fileFormData = new FormData();
            if (this.files) {
              fileFormData.append('file', this.files, this.fileName);
            }
            fileFormData.append('type', this.form.type);
            fileFormData.append('sn', this.form.sn);
            fileFormData.append('name', this.form.name);
            if (this.form.desc != null) {
              fileFormData.append('desc', this.form.desc);
            }
            fileFormData.append('id', this.form.id);
            //修改
            axios.post(process.env.VUE_APP_BASE_API + '/console/system/component/edit', fileFormData, {
              headers: {
                'Content-Type': 'multipart/form-data',
                Authorization: "Bearer " + getToken(),
              }
            }).then(result => {
              console.log(result)
              if (result.data.code == "200") {
                self.msgSuccess("修改成功");
                self.open = false;
                self.getList();
              } else {
                self.$alert(result.data.msg, '提示', {
                  confirmButtonText: '确定', callback: action => {
                  }
                });
              }
              console.log(result);
            }).catch(response => {
            })
          } else {
            let self = this;
            let fileFormData = new FormData();
            if (this.files) {
              fileFormData.append('file', this.files, this.fileName);
            } else {
              this.$message.warning('请上传组件');
              return false;
            }
            fileFormData.append('type', this.form.type);
            fileFormData.append('sn', this.form.sn);
            fileFormData.append('name', this.form.name);
            if (this.form.desc != null) {
              fileFormData.append('desc', this.form.desc);
            }            //新增
            axios.post(process.env.VUE_APP_BASE_API + '/console/system/component/add', fileFormData, {
              headers: {
                'Content-Type': 'multipart/form-data',
                Authorization: "Bearer " + getToken(),
              }
            }).then(result => {
              if (result.data.code == "200") {
                self.msgSuccess("新增成功");
                self.open = false;
                self.getList();
              } else {
                self.$alert(result.data.msg, '提示', {
                  confirmButtonText: '确定', callback: action => {
                  }
                });
              }
            }).catch(response => {
            })
          }
        }
      });
    }, 1000, {'leading': true, 'trailing': false}),
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$confirm('是否确认删除已选中的组件的数据项,及其已被使用的其他服务?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delComponent(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      }).catch(function () {
      });
    },
    uploadSectionFile: function (param) {
      let file = param.file;
      let extension = file.name.split('.')[file.name.split(".").length - 1] === 'jar';
      if (!extension) {
        this.$message.warning('上传组件只能是 jar格式!');
        this.$refs['uploadFile'].clearFiles();
        this.fileName = '';
        this.files = '';
        return;
      }
      this.files = file;
      this.fileName = file.name;
      return false;
    },
  }
};

</script>
