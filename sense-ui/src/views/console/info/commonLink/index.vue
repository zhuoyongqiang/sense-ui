<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入名称"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
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
          v-hasPermi="['info:commonLink:add']"
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
          v-hasPermi="['info:commonLink:edit']"
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
          v-hasPermi="['info:commonLink:remove']"
        >删除
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="commonLinkList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="图片" align="center" prop="image">
        <template slot-scope="scope">
          <el-image :src="baseFilePath +scope.row.image">
            <img slot="error" class="image-slot" src="@/assets/icons/default_application.png">
          </el-image>
        </template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="typeId" :formatter="typeIdIdFormat" />
      <el-table-column label="名称" align="center" prop="name"/>

      <el-table-column label="排序" align="center" prop="order"/>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="140">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['info:commonLink:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['info:commonLink:remove']"
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

    <!-- 添加或修改公共快捷方式对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">

        <el-form-item label="分类" prop="typeId">
          <el-select v-model="form.typeId"
                     placeholder="请选择分类"
                     size="small"
                     style="width: 100%"
                     clearable
                     filterable
          >
            <el-option
              v-for="dict in typeOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="dict.dictValue"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入名称"/>
        </el-form-item>
        <el-form-item label="链接" prop="url">
          <el-input v-model="form.url" placeholder="请输入链接"/>
        </el-form-item>
        <el-form-item label="图片:" prop="file">
          <el-upload
            ref="uploadFile"
            :show-file-list="false"
            action="#"
            :on-remove="handleRemove"
            :on-success="handleSuccess"
            :http-request="uploadSectionFile"
          >
            <el-image :src="imageUrl" v-if="imageUrl">
              <img slot="error" class="image-slot" src="@/assets/icons/default_application.png">
            </el-image>
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
        </el-form-item>

        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入内容"/>
        </el-form-item>

        <el-form-item label="排序" prop="order">
          <el-input-number v-model="form.order"  :min="1" :max="99999" label="请输入排序"></el-input-number>
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
    addCommonLink,
    delCommonLink,
    exportCommonLink,
    getCommonLink,
    listCommonLink,
    updateCommonLink
  } from "@/api/console/info/commonLink";

  export default {
    name: "CommonLink",
    components: {},
    data() {
      return {
        baseFilePath: undefined,
        // 遮罩层
        loading: true,
        // 选中数组
        ids: [],
        typeOptions: [],
        // 非单个禁用
        single: true,
        // 非多个禁用
        multiple: true,
        // 显示搜索条件
        showSearch: true,
        // 总条数
        total: 0,
        // 公共快捷方式表格数据
        commonLinkList: [],
        // 弹出层标题
        title: "",
        // 是否显示弹出层
        open: false,
        // 查询参数
        queryParams: {
          isLikeQuery: true,
          pageNum: 1,
          pageSize: 10,
          name: null,
          url: null
        },
        // 表单参数
        form: {
          id: null,
          name: null,
          image: null,
          url: null,
          remark: null,
          order: null,
          createTime: null,
          updateTime: null,
          typeId:null,
        },
        // 表单校验
        rules: {},
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
      this.getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
      this.getDicts('info_commin_link_types').then(response => {
        this.typeOptions = response.data;
      });
    },
    methods: {
      //类型名称格式化
     typeIdIdFormat(row, column) {
        let list = this.typeOptions;
        for (let i in list) {
          if (list[i].dictValue === row.typeId) {
            return list[i].dictLabel;
          }
        }
        return "未知";
      },
      /** 查询公共快捷方式列表 */
      getList() {
        this.loading = true;
        listCommonLink(this.queryParams).then(response => {
          this.commonLinkList = response.rows;
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
          name: null,
          image: null,
          url: null,
          remark: null,
          order: null,
          createTime: null,
          updateTime: null,
          typeId:null
        };
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
        this.title = "添加公共快捷方式";
      },
      /** 修改按钮操作 */
      handleUpdate(row) {
        this.reset();
        const id = row.id || this.ids
        getCommonLink(id).then(response => {
          let data = response.data;
          for (let key in this.form) {
            if (data[key]) {
              this.form[key] = data[key];
            }
          }
          this.form.typeId = data.typeId
          this.imageUrl = this.baseFilePath + this.form.image;
          this.open = true;
          this.title = "修改公共快捷方式";
          console.log(this.form.typeId)
        });
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
              updateCommonLink(fileFormData).then(response => {
                console.log(response)
                if (response.data.code == 200) {
                  this.msgSuccess("修改成功");
                  this.open = false;
                  this.getList();
                } else {
                  this.msgError(response.msg);
                }
              });
            } else {
              addCommonLink(fileFormData).then(response => {
                if (response.data.code == 200) {
                  this.msgSuccess("新增成功");
                  this.open = false;
                  this.getList();
                } else {
                  this.msgError(response.msg);
                }
              });
            }
          }
        });
      },
      /** 删除按钮操作 */
      handleDelete(row) {
        const ids = row.id || this.ids;
        this.$confirm('是否确认删除公共快捷方式编号为"' + ids + '"的数据项?', "警告", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function () {
          return delCommonLink(ids);
        }).then((response) => {
          if (response.code == 200) {
            this.getList();
            this.msgSuccess("删除成功");
          } else {
            this.msgError(response.msg);
          }
        })
      },
      /** 导出按钮操作 */
      handleExport() {
        const queryParams = this.queryParams;
        this.$confirm('是否确认导出所有公共快捷方式数据项?', "警告", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning"
        }).then(function () {
          return exportCommonLink(queryParams);
        }).then(response => {
          this.download(response.msg);
        })
      },
      handleRemove(file, fileList) {
      },
      handleSuccess(res, file) {
        this.imageUrl = URL.createObjectURL(file);
      },
      uploadSectionFile: function (param) {
        let file = param.file;
        this.files = file;
        this.fileName = file.name;
        this.handleSuccess({}, file);
      }
    }
  };
</script>

<style lang="scss" scoped>
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

</style>
