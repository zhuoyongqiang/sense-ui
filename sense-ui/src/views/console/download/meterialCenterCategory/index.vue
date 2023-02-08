<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm"  :inline="true" v-show="showSearch" label-width="68px">
       <el-form-item label="编码" prop="sn">
        <el-input
          v-model="queryParams.sn"
          placeholder="请输入编码"
          clearable
          size="small"
        />
      </el-form-item>
      <el-form-item label="名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入名称"
          clearable
          size="small"
        />
      </el-form-item>
      <el-form-item label="状态"  prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="请选择">
          <el-option
            v-for="item in commonStatus"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['download:meterialCategory:add']"
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
          v-hasPermi="['download:meterialCategory:edit']"
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
          v-hasPermi="['download:meterialCategory:delete']"
        >删除
        </el-button>
      </el-col>
    </el-row>
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange" >
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="素材名" align="center" prop="name"/>
      <el-table-column label="编码" align="center" prop="sn"/>
      <el-table-column label="颜色" align="center" prop="color"/>
      <el-table-column label="权限标识" align="center" prop="roleKey"/>
      <el-table-column label="首页权限标识" align="center" prop="viewRoleKey"/>
      <el-table-column label="状态" align="center" prop="status" :formatter="statusFormat"  />
      <el-table-column label="排序" align="center" prop="sort"   />
      <!-- <el-table-column label="浏览量" align="center" prop="browseNum" width="70"/> -->
      <el-table-column label="创建时间" align="center" prop="createTime" >
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['download:meterialCategory:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['download:meterialCategory:delete']"
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

    <!-- 添加或修改素材对话框 -->
    <el-dialog :title="title" :visible.sync="open" @close="handleClose" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="封面" prop="cover">
              <el-tooltip class="item" effect="dark" content="图片大小（165*75）" placement="top">
                <i class="el-icon-question" style="font-size:18px" ></i>
              </el-tooltip>
              <el-upload
                class="avatar-uploader"
                :action="upload.url"
                :headers="upload.headers"
                :show-file-list="false"
                :before-upload="beforePhotoUpload"
                :on-success="handleThumbnalSuccess">
                <img v-if="form.cover" :src="baseFilePath+form.cover" class="avatar">
                <i v-else class="el-icon-plus avatar-uploader-icon"></i>
              </el-upload>
            </el-form-item>
          </el-col>
        </el-row>
          <el-row>
          <el-col :span="24">
            <el-form-item label="编码" prop="sn">
              <el-input v-model="form.sn" :disabled="form.id!=null" placeholder="请输入名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="颜色" prop="color">
              <el-input v-model="form.color" placeholder="请输入颜色,可点击右侧选择颜色" >
                <template slot="append"><colorPicker style="z-index:100" v-model="form.color" defaultColor="#000000"  /></template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="24">
            <el-form-item label="权限标识" prop="roleKey">
              <el-input v-model="form.roleKey" placeholder="请输入权限标识" />
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="24">
            <el-form-item label="首页权限标识" prop="viewRoleKey">
              <el-input v-model="form.viewRoleKey" placeholder="请输入首页权限标识" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="排序号" prop="sort">
              <el-input-number v-model="form.sort" style="width:100%" :min="1"  label="排序号"></el-input-number>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
                <el-radio :label="item.dictValue" v-for="item in commonStatus" :key="item.id">{{item.dictLabel}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import {getToken} from "@/utils/auth";
import { listMeterialCategory, getMeterialCategory, addMeterialCategory, updateMeterialCategory,delMeterial} from "@/api/console/download/meterialCategory";
export default {
  name: "meterialCenterCategory",
  components: {},
  data() {
    return {
    
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
      // 素材表格数据
      list: [],
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
        status:null,
        sn:null
      },
      // 表单参数
      form: {},
      //选中的ID
      checkId:null,
      //上传对象
      upload:{
        //上传头
        headers:{
          'Authorization': "Bearer " + getToken(),
        },
        //上传地址
        url:process.env.VUE_APP_BASE_API+"/common/file/upload"
      },
      // 表单校验
      rules: {
        sn:[
          { required: true, message: "编码不能为空", trigger: "blur" }
        ],
        color: [
          { required: true, message: "颜色不能为空", trigger: "blur" }
        ],
        name: [
          { required: true, message: "名称不能为空", trigger: "blur" }
        ],
        status: [
          { required: true, message: "状态不能为空", trigger: "blur" }
        ],
        sort :[
          { required: true, message: "排序号不能为空", trigger: "blur" },
        ],
        roleKey: [
          { required: true, message: "权限标识不能为空", trigger: "blur" }
        ],
        cover:[
          { required: true, message: "封面不能为空", trigger: "blur" },
        ],
        viewRoleKey:[
          { required: true, message: "首页权限标识不能为空", trigger: "blur" },
        ],
      },
      //字典
      commonStatus:[],
      //文件显示前缀
      baseFilePath:undefined,
    
    };
  },
  created() {
    //字典
    this.getDicts('common_status').then(response => {
      this.commonStatus = response.data;
    });
    //参数列表
    this.getConfigKey('file_download_url').then(response => {
      this.baseFilePath = response.msg;
    });
    this.getList();
  },
  methods: {
    //封面上传前的回调方法
    beforePhotoUpload(file){
      var testmsg = file.name.substring(file.name.lastIndexOf(".") + 1);
      const isJPG = file.type === 'image/jpeg';
      const isPNG = testmsg === 'png';
      const isLt2M = file.size / 1024 / 1024 < 2;
      if(!isPNG && !isJPG){
        this.$message.error('上传图片只能是 JPG或PNG或JPEG 格式!');
      }else if(!isLt2M){
        this.$message.error('上传图片大小不能超过 2MB!');
      }
      return (isJPG || isPNG)  && isLt2M;
    },
    //封面上传
    handleThumbnalSuccess(file){
      if(file.code==200){
        this.$set(this.form,"cover",file.msg);
      }
    },
    /** 查询素材列表 */
    getList() {
      this.loading = true;
      listMeterialCategory(this.queryParams).then(response => {
        this.list = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    //管理窗口
    handleClose(){
      this.form={};
    },
    // 表单重置
    reset() {
      this.resetForm("form");
      this.form = {
        status:'1',
        color:'#000000',
      };
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
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.commonStatus, row.status);
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
      this.title = "添加";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getMeterialCategory(id).then(response => {
        this.form=response.data;
        this.title = "修改";
        this.open = true;
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if(this.form.cover==undefined || this.form.cover==null){
            this.$message.error("请上传封面");
            return;
          }
          if (this.form.id != null) {
            updateMeterialCategory(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addMeterialCategory(this.form).then(response => {
              if (response.code == 200) {
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
      this.$confirm('是否确认删除选中数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return delMeterial(ids);
      }).then((response) => {
        if (response.code == 200) {
          this.getList();
          this.msgSuccess("删除成功");
        } else {
          this.msgError(response.msg);
        }
      })
    },
  }
};
</script>
<style lang="scss" scoped>
 
  .avatar-uploader{
   ::v-deep {
      .el-upload {
        border: 1px dashed #d9d9d9;
        border-radius: 6px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
      }
      .el-upload:hover {
        border-color: #409EFF;
      }
      .avatar-uploader-icon {
        font-size: 28px;
        color: #8c939d;
        width: 180px;
        height: 80px;
        line-height: 80px;
        text-align: center;
      }
   }
  }
  .avatar {
    width: 180px;
    height: 80px;
    display: block;
  }
</style>
