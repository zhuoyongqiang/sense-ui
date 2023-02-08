<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="标识" prop="sn">
        <el-input
          v-model="queryParams.sn"
          placeholder="请输入标识"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入标题"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable size="small">
          <el-option
            v-for="dict in statusOptions"
            :key="dict.dictValue"
            :label="dict.dictLabel"
            :value="dict.dictValue"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
        >新增
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
        >修改
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
        >删除
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="tableData" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>

      <el-table-column label="标识" align="center" prop="sn"/>
      <el-table-column label="标题" align="center" prop="title"/>
      <el-table-column prop="status" label="状态" :formatter="statusFormat" width="80"></el-table-column>
      <el-table-column label="创建日期" align="center" width="140">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleLayout(scope.row)"
          >布局设计
          </el-button>

          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
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
    <!-- 添加或修改 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="标识" prop="sn">
          <el-input v-model="form.sn" :disabled="form.id!==null" placeholder="请输入标识"/>
        </el-form-item>
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入标题"/>
        </el-form-item>
        <!--
        <el-form-item label="logo" prop="logo">
          <el-upload
            ref="uploadFile"
            :show-file-list="false"
            action="#"
            :on-success="handleSuccess"
            :http-request="uploadSectionFile"
          >
            <img v-if="imageUrl" :src="imageUrl" width="40px" height="40px" class="avatar">
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
          <p style="font-size: 12px;color:#666">LOGO宽高，建议为250*35</p>
        </el-form-item>
        -->

        <el-form-item label="主题" prop="theme">
          <el-select v-model="form.theme" filterable placeholder="请选择主题" style="width: 100%">
            <el-option label="默认" value="default"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态" clearable style="width: 100%">
            <el-option
              v-for="dict in statusOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="dict.dictValue"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="访问权限" prop="scope">
            <treeselect v-model="form.scope" :options="deptOptions" :show-count="true" placeholder="请选择访问权限"/>
        </el-form-item>

      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!--设计窗口-->
    <design ref="designInfo" :visible.sync="editInfovisible"></design>

  </div>

</template>

<script>
  import {treeselect} from "@/api/console/system/dept";
  import Treeselect from "@riophae/vue-treeselect";
  import "@riophae/vue-treeselect/dist/vue-treeselect.css";
  import {
    add,
    del,
    get,
    list,
    update
  } from "@/api/console/subportal/index";
  import design from "@/views/console/subportal/design";
  export default {
    name: "subportal",
    components: {
      design,
      Treeselect
    },
    data() {
      return {
        // 部门树选项
        deptOptions: undefined,

        editInfovisible: false,
        // 菜单状态数据字典
        statusOptions: [],
        // 遮罩层
        loading: true,
        // 选中数组
        ids: [],
        // 非单个禁用
        single: true,
        // 非多个禁用
        multiple: true,
        // 显示搜索条件
        showSearch: true,
        // 总条数
        total: 0,
        //表格数据
        tableData: [],
        // 弹出层标题
        title: "",
        // 是否显示弹出层
        open: false,
        // 查询参数
        queryParams: {
          isLikeQuery: true,
          pageNum: 1,
          pageSize: 10,
          sn: undefined,
          title: undefined,
          status: undefined
        },
        // 表单参数
        form: {
          id: null,
          sn: null,
          title: null,
          logo: null,
          theme: 'default',
          status: '0',
          scope:'0'
        },
        // 表单校验
        rules: {
          sn: [
            {required: true, message: "标识不能为空", trigger: "blur"}
          ],
          title: [
            {required: true, message: "标题不能为空", trigger: "blur"}
          ],
          status: [
            {required: true, message: "请选择状态", trigger: "blur"}
          ],
          theme: [
            {required: true, message: "请选择主题", trigger: "blur"}
          ],
          scope: [
            {required: true, message: "请选择权限范围", trigger: "blur"}
          ]
        },
        //文件名
        fileName: '',
        //文件对象
        files: '',
        //图片地址
        imageUrl: undefined
      };
    },
    created() {
      this.getList();
      this.getTreeselect();
      this.getDicts("sys_normal_disable").then(response => {
        this.statusOptions = response.data;
      });
    },
    methods: {
      // 菜单状态字典翻译
      statusFormat(row, column) {
        if (row.menuType == "F") {
          return "";
        }
        return this.selectDictLabel(this.statusOptions, row.status);
      },
      /** 查询部门下拉树结构 */
      getTreeselect() {
        treeselect().then(response => {
          this.deptOptions = response.data;
        });
      },
      /** 查询公共快捷方式列表 */
      getList() {
        this.loading = true;
        list(this.queryParams).then(response => {
          this.tableData = response.rows;
          this.total = response.total;
          this.loading = false;
        });
      },
      // 取消按钮
      cancel() {
        this.open = false;
        this.reset();
      },
      // 表单重置
      reset() {
        this.form = {
          id: null,
          sn: null,
          title: null,
          logo: null,
          theme: 'default',
          status: '0',
          scope:'0'
        }
        this.files = undefined
        this.fileName = undefined
        this.imageUrl = null;
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
        this.single = selection.length !== 1
        this.multiple = !selection.length
      },
      /** 新增按钮操作 */
      handleAdd() {
        this.reset();
        this.open = true;
        this.title = "新增";
      },
      /** 修改按钮操作 */
      handleUpdate(row) {
        this.reset();

        const id = row.id || this.ids
        get(id).then(response => {
          let data = response.data;
          for (let key in this.form) {
            if (data[key]) {
              this.form[key] = data[key];
            }
          }
          if (this.form.logo !== null) {
            this.imageUrl = 'data:image/png;base64,' + this.form.logo;
          }
          this.form.scope=this.form.scope+''
          this.form.status=this.form.status+''
          this.form.scope=this.form.scope+''
          this.open = true;
          this.title = "修改";
        });
      },

      handleLayout(row){
        this.editInfovisible = true
        this.$nextTick(function () {
          this.$refs.designInfo.showDesign(row)
        })
      },
      /** 提交按钮 */
      submitForm() {
        this.$refs["form"].validate(valid => {
          if (valid) {
            let fileFormData = new FormData();
            if (this.files) {
              fileFormData.append('file', this.files, this.fileName);
            }
            for (let key in this.form) {
              if (this.form[key]) {
                fileFormData.append(key, this.form[key]);
              }
            }
            if (this.form.id != null) {
              update(fileFormData).then(response => {
                if (response.data.code == 200) {
                  this.msgSuccess("修改成功");
                  this.open = false;
                  this.getList();
                  this.reset()
                } else {
                  this.msgError(response.data.msg);
                }
              });
            } else {
              add(fileFormData).then(response => {
                if (response.data.code == 200) {
                  this.msgSuccess("新增成功");
                  this.open = false;
                  this.getList();
                  this.reset()
                } else {
                  this.msgError(response.data.msg);
                }
              });
            }
          }
        });
      },
      /** 删除按钮操作 */
      handleDelete(row) {
        const ids = row.id || this.ids;
        this.$confirm('是否确认选中数据项?', "警告", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function () {
          return del(ids);
        }).then((response) => {
          if (response.code == 200) {
            this.getList();
            this.msgSuccess("删除成功");
          } else {
            this.msgError(response.msg);
          }
        })
      },
      handleSuccess(res, file) {
        this.imageUrl = URL.createObjectURL(file);
      },
      uploadSectionFile: function (param) {
        let file = param.file;
        if(file&& file.size > (2*1024*1024) ){
          this.msgWarning("LOGO不能超过2M")
          return;
        }
        this.files = file;
        this.fileName = file.name;
        this.handleSuccess({}, file);
      }
    }
  };
</script>
