<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入标题"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="是否轮播" prop="isRotation">
        <el-select v-model="queryParams.isRotation" clearable placeholder="请选择">
          <el-option
            v-for="item in commonNormalDisableOptions"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
       <el-form-item label="是否正常" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="请选择">
          <el-option
            v-for="item in commonNormalDisableOptions"
            :key="item.dictValue"
            :label="item.dictLabel"
            :value="item.dictValue">
          </el-option>
        </el-select>
      </el-form-item>
       <el-form-item label="点击量" prop="num">
        <el-input-number v-model="queryParams.minNum"  controls-position="right"  :precision="0" :min="0"  ></el-input-number>～
        <el-input-number v-model="queryParams.maxNum"   controls-position="right" :precision="0" :min="0"  ></el-input-number>
      </el-form-item>
      <el-form-item label="日期范围" prop="dateRange">
        <el-date-picker
          v-model="queryParams.dateRange"
          type="daterange"
          value-format="yyyy-MM-dd"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期">
        </el-date-picker>
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
          v-hasPermi="['info:banner:add']"
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
          v-hasPermi="['info:banner:edit']"
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
          v-hasPermi="['info:banner:remove']"
        >删除
        </el-button>
      </el-col>
      
    </el-row>

    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="标题" align="center" prop="title"/>
      <el-table-column label="是否轮播" align="center" prop="isRotation" :formatter="rotationFormat"/>
      <el-table-column label="是否正常" align="center" prop="status" :formatter="statusFormat"/>
      <el-table-column label="链接" align="center" prop="bannerUrl" width="180" show-overflow-tooltip />
      <el-table-column label="点击量" align="center" prop="hits" width="70"/>
      <el-table-column label="排序" align="center" prop="sort" width="70"/>
      <el-table-column label="开始日期" align="center" prop="startTime" >
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.startTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
        <el-table-column label="结束日期" align="center" prop="endTime" >
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.endTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
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
            v-hasPermi="['info:banner:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['info:banner:remove']"
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

    <!-- 添加或修改banner对话框 -->
    <el-dialog :title="title" :visible.sync="open" @close="handleClose" width="600" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="封面" >
               <el-tooltip class="item" effect="dark" offset="80" content="图片大小（1200*300）" placement="top-start">
                <el-upload
                  class="image-upload"
                  :action="upload.url"
                  :headers="upload.headers"
                  list-type="picture"
                  ref="uploadFile"
                  :file-list="fileList"
                  :on-change="handleUploadChange"
                  :on-remove="handleRemove"
                  :on-success="handleSuccess"
                  :on-error="handleError"
                  :limit="1"
                  :before-upload="beforePhotoUpload">
                  <el-button size="small" type="primary">点击上传</el-button>
                </el-upload>
                </el-tooltip>
              </el-form-item>
            </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="手机封面" >
               <el-tooltip class="item" effect="dark" offset="80" content="图片大小（380*200）" placement="top-start">
                <el-upload
                  class="image-mobile-upload"
                  :action="upload.url"
                  :headers="upload.headers"
                  list-type="picture"
                  ref="uploadMobileFile"
                  :file-list="mobileFileList"
                  :on-change="handleMobileUploadChange"
                  :on-remove="handleMobileRemove"
                  :on-success="handleMobileSuccess"
                  :on-error="handleError"
                  :limit="1"
                  :before-upload="beforePhotoUpload">
                  <el-button size="small" type="primary">点击上传</el-button>
                </el-upload>
                </el-tooltip>
              </el-form-item>
            </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="标题" prop="title">
              <el-input v-model="form.title" placeholder="请输入标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序号" prop="sort">
              <el-input-number v-model="form.sort" style="width:100%"  :precision="0" controls-position="right" :min="1"  label="排序号"></el-input-number>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="12">
            <el-form-item label="开始时间" prop="startTime">
               <el-date-picker
                  style="width:100%"
                  v-model="form.startTime"
                  type="date"
                  value-format="yyyy-MM-dd"
                  placeholder="选择日期">
                </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束时间" prop="endTime">
              <el-date-picker
                  style="width:100%"
                  v-model="form.endTime"
                  type="date"
                  value-format="yyyy-MM-dd"
                  :picker-options="endOptions"
                  placeholder="选择日期">
                </el-date-picker>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="是否轮播" prop="isRotation">
             <el-radio-group v-model="form.isRotation">
                <el-radio :label="'1'">是</el-radio>
                <el-radio :label="'0'">否</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio :label="'1'">是</el-radio>
                <el-radio :label="'0'">否</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="链接" prop="bannerUrl">
              <el-input
                type="textarea"
                :rows="2"
                placeholder="请输入链接"
                v-model="form.bannerUrl">
              </el-input>
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
import {listBanner, getBanner, addBanner, updateBanner,delBanner} from "@/api/console/info/banner";
export default {
  name: "banner",
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
      // banner表格数据
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
        title: null,
        isRotation:null,
        status:null,
        dateRange:null,
        minNum:undefined,
        maxNum:undefined
      },
      // 表单参数
      form: {},
      //上传对象
      upload:{
        //上传头
        headers:{
          'Authorization': "Bearer " + getToken(),
        },
        //上传地址
        url:process.env.VUE_APP_BASE_API+"/common/file/upload"
      },
      //文件集合
      fileList: [],
      //手机文件集合
      mobileFileList:[],
      // 表单校验
      rules: {
        title: [
          { required: true, message: "banner标题不能为空", trigger: "blur" }
        ],
        sort: [
          { required: true, message: "排序号不能为空", trigger: "blur" }
        ],
        startTime: [
          { required: true, message: "开始日期不能为空", trigger: "blur" }
        ],
        endTime :[
          { required: true, message: "结束日期不能为空", trigger: "blur" },
        ],
      },
      //字典
      commonNormalDisableOptions:[],
      //开始时间
      startOptions:{
        disabledDate (time) {
          return time.getTime() < Date.now()- 24*60*60*1000;
        }
      },
      endOptions:{
        disabledDate (time) {
          return time.getTime() < Date.now()- 24*60*60*1000;
        }
      }
    };
  },
  created() {
    this.getList();
    this.getDicts('common_yes_no').then(response => {
      this.commonNormalDisableOptions = response.data;
      this.commonNormalDisableOptions.forEach(element => {
        element.dictValue=element.dictValue
      });
    });
  },
  methods: {
     handleUploadChange(file,fileList){
      if(file.code==200){
        this.$set(this.form,"cover",file.data.relativeUrl);
      }
    },
    //上传成功回调
    handleSuccess(file){
      if(file.code==200){
        this.$set(this.form,"cover",file.data.relativeUrl);
      }
    },
    //上传失败回调
    handleError(file){
      this.$message.error(file.msg)
    },
    //移除
    handleMobileRemove(file){
      this.mobileFileList = [];
      this.$set(this.form,"mobileCover",null);
    },
    handleMobileUploadChange(file,fileList){
      if(file.code==200){
        this.$set(this.form,"mobileCover",file.data.relativeUrl);
      }
    },
    //上传成功回调
    handleMobileSuccess(file){
      if(file.code==200){
        this.$set(this.form,"mobileCover",file.data.relativeUrl);
      }
    },
    //移除
    handleRemove(file){
      this.fileList = [];
      this.$set(this.form,"cover",null);
    },
    //图片上传前的回调方法
    beforePhotoUpload(file){
      var testmsg = file.name.substring(file.name.lastIndexOf(".") + 1);
      const isJPEG = testmsg === 'jpeg';
      const isPNG = testmsg=== 'png';
      const isJPG = testmsg === 'jpg';
      const isLt2M = file.size / 1024 / 1024 < 2;
      if(!isJPEG && !isPNG && !isJPG){
        this.$message.error('上传图片只能是 JPG或PNG或PNG 格式!');
      }else if(!isLt2M){
        this.$message.error('上传图片大小不能超过 2MB!');
      }
    },
    /** 查询banner列表 */
    getList() {
      this.loading = true;
      listBanner(this.queryParams).then(response => {
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
      this.fileList = [];
      this.mobileFileList = [];
      this.$refs.uploadMobileFile.clearFiles();
      this.$refs.uploadFile.clearFiles();
    },
    // 表单重置
    reset() {
      this.form = {
        status:'1',
        isRotation:'1',
        sort:1
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
      this.queryParams.maxNum=undefined;
      this.queryParams.minNum=undefined;
      this.handleQuery();
    },
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.status);
    },
     //是否轮播格式化
    rotationFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isRotation);
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
      getBanner(id).then(response => {
        this.form=response.data;
        if(response.data.cover!=undefined && response.data.cover!=null){
          var name=response.data.cover.substring(response.data.cover.lastIndexOf("/")+1);
          this.fileList.push({
            url:response.data.cover,
            name:name
          });
        }
        if(response.data.mobileCover!=undefined && response.data.mobileCover!=null){
          var name=response.data.mobileCover.substring(response.data.mobileCover.lastIndexOf("/")+1);
          this.mobileFileList.push({
            url:response.data.mobileCover,
            name:name
          });
        }
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
          if(this.form.mobileCover==undefined || this.form.mobileCover==null){
            this.$message.error("请上传手机封面");
            return;
          }
          if (this.form.id != null) {
            updateBanner(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addBanner(this.form).then(response => {
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
        return delBanner(ids);
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
  .image-upload{
    ::v-deep {
      .el-upload-list__item-thumbnail{
        width: 100%;
        height: 200px;
        position: absolute;
        top: 0;
        bottom: 0;
        right: 0;
      }
      .el-upload-list--picture .el-upload-list__item{
        width: 100%;
        height: 200px;
        z-index: 100;
      }
      .el-upload-list__item-name{
          width: 0px;
          display: none;

      }
      .el-icon-close-tip{
        display: none;
        width: 0;
      }
      .el-icon-close{
        z-index: 1000;
      }
    } 
  }
  .image-mobile-upload{
    ::v-deep {
      .el-upload-list__item-thumbnail{
        width: 380px;
        height: 200px;
        position: absolute;
        top: 0;
        bottom: 0;
        right: 0;
      }
      .el-upload-list--picture .el-upload-list__item{
        width: 380px;
        height: 200px;
        z-index: 100;
      }
      .el-upload-list__item-name{
          width: 0px;
          display: none;

      }
      .el-icon-close-tip{
        display: none;
        width: 0;
      }
      .el-icon-close{
        z-index: 1000;
      }
    } 
  }
</style>
