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
          v-hasPermi="['system:app:add']"
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
          v-hasPermi="['system:app:edit']"
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
          v-hasPermi="['system:app:remove']"
        >删除
        </el-button>
      </el-col>

      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="appList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="应用标识" align="center" prop="sn"/>
      <el-table-column label="应用名称" align="center" prop="name"/>
      <el-table-column label="是否显示" align="center" prop="isView" :formatter="statusFormat"/>
      <el-table-column label="是否默认开通" align="center" prop="isDefaultOpen" :formatter="defaultOpenFormat"/>
      <el-table-column label="门店管理员授权" align="center" prop="isShopManage" :formatter="isShopManageFormat"/>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <!-- <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleDistributionUser(scope.row)"
            v-hasPermi="['system:role:remove']"
          >分配用户
          </el-button> -->
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:app:edit']"
          >修改
          </el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:app:remove']"
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

    <!-- 添加或修改应用对话框 -->
    <el-dialog :title="title" :visible.sync="open" @close="handleClose" width="600" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="120px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="封面" style="width:50%;" prop="profileUrl">
              <el-tooltip class="item" effect="dark" offset="170" content="图片大小（45*45）" placement="top-end">
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
          <el-col :span="12">
            <el-form-item label="应用标识" prop="sn">
              <el-input v-model="form.sn" placeholder="请输入应用标识" :disabled="form.id!=null"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="应用名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入应用名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="列表是否显示" prop="isView">
              <el-radio-group v-model="form.isView">
                <el-radio 
                  v-for="item in commonNormalDisableOptions"  
                  :label="item.dictValue" 
                  :key="item.dictValue">
                  {{item.dictLabel}}
                </el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="链接拼接门店" prop="isDeptSn">
              <el-radio-group v-model="form.isDeptSn">
                <el-radio 
                  v-for="item in commonNormalDisableOptions"  
                  :label="item.dictValue" 
                  :key="item.dictValue">
                  {{item.dictLabel}}
                </el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="是否默认开通" prop="isDefaultOpen">
              <el-radio-group v-model="form.isDefaultOpen">
                <el-radio 
                  v-for="item in commonNormalDisableOptions"  
                  :label="item.dictValue" 
                  :key="item.dictValue">
                  {{item.dictLabel}}
                </el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="门店管理员授权" prop="isShopManage">
              <el-radio-group v-model="form.isShopManage">
                <el-radio 
                  v-for="item in commonNormalDisableOptions"  
                  :label="item.dictValue" 
                  :key="item.dictValue">
                  {{item.dictLabel}}
                </el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="MOBILE类型" prop="isMobileType">
              <el-radio  v-model="form.isMobileType" :label="1">H5</el-radio>
              <el-radio  v-model="form.isMobileType" :label="2">APP</el-radio>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="PC链接" prop="defaultUrl">
              <el-input
                type="textarea"
                :rows="2"
                placeholder="请输入链接"
                v-model="form.defaultUrl">
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row v-if="form.isMobileType==1">
          <el-col :span="24">
            <el-form-item label="MOBILE链接" prop="mobileDefaultUrl">
              <el-input
                type="textarea"
                :rows="2"
                placeholder="请输入链接"
                v-model="form.mobileDefaultUrl">
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="24" v-if="form.isMobileType==2">
            <el-form-item label="安卓链接" prop="andriodUrl">
              <el-input
                type="textarea"
                :rows="2"
                placeholder="请输入链接"
                v-model="form.andriodUrl">
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="24" v-if="form.isMobileType==2">
            <el-form-item label="IPHONE链接" prop="iosUrl">
              <el-input
                type="textarea"
                :rows="2"
                placeholder="请输入链接"
                v-model="form.iosUrl">
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
           <el-col :span="24">
            <el-form-item label="排序号" prop="sortNum">
              <el-input-number v-model="form.sortNum" style="width:100%" :min="1"  label="排序号"></el-input-number>
            </el-form-item>
          </el-col>
        </el-row>
         <el-row>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input
                type="textarea"
                :rows="3"
                placeholder="请输入备注"
                v-model="form.remark">
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
    <!--分配用户窗口-->
    <distributionUserInfo ref="distributionUserInfo"  ></distributionUserInfo>
  </div>
</template>

<script>
import {listApp, getApp, delApp, addApp, updateApp, exportApp,uploadFile} from "@/api/console/system/app";
import {getToken} from "@/utils/auth";
import distributionUserInfo from "@/views/console/system/user/distributionUser/index";
export default {
  name: "App",
  components: {distributionUserInfo},
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      checkList:[],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 应用表格数据
      appList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        sn: null,
        name: null
      },
      // 表单参数
      form: {},
      //文件集合
      fileList:[],
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
        sn: [
          { required: true, message: "应用标识不能为空", trigger: "blur" }
        ],
        name: [
          { required: true, message: "应用名称不能为空", trigger: "blur" }
        ],
        sortNum: [
          { required: true, message: "排序号不能为空", trigger: "blur" }
        ],
        defaultUrl :[
          { required: true, message: "链接不能为空", trigger: "blur" },
        ],
        isMobileType :[
          { required: true, message: "手机端类型不能为空", trigger: "blur" },
        ],
        mobileDefaultUrl :[
          { required: true, message: "MOBILE链接不能为空", trigger: "blur" },
        ],
        andriodUrl :[
          { required: true, message: "安卓链接不能为空", trigger: "blur" },
        ],
        iosUrl :[
          { required: true, message: "IPHONE链接不能为空", trigger: "blur" },
        ],
      },
      //是否显示集合
      commonNormalDisableOptions: [],
    };
  },
  created() {
    this.getList();
    this.getDicts('app_is_view').then(response => {
      this.commonNormalDisableOptions = response.data;
      this.commonNormalDisableOptions.forEach(element => {
        element.dictValue=parseInt(element.dictValue)
      });
    });
  },
  methods: {
    //分配用户
    handleDistributionUser(row){
      const id = row.roleId
      this.$nextTick(function () {
        this.$refs.distributionUserInfo.showUser(id);
      })
    },
    handleUploadChange(file,fileList){
      if(file.code==200){
        this.$set(this.form,"profileUrl",file.msg);
      }
    },
    //上传成功回调
    handleSuccess(file){
      if(file.code==200){
        this.$set(this.form,"profileUrl",file.msg);
      }
    },
    //上传失败回调
    handleError(file){
      this.$message.error(file.msg)
    },
    //移除
    handleRemove(file){
      console.log(file);
    },
    //图片上传前的回调方法
    beforePhotoUpload(file){
      var testmsg = file.name.substring(file.name.lastIndexOf(".") + 1);
      const isJPEG = testmsg === 'jpeg';
      const isPNG = testmsg=== 'png';
      const isJPG = testmsg === 'jpg';
      const isLt2M = file.size / 1024 / 1024 < 2;
      if(!isJPEG && !isPNG && !isJPG){
        this.$message.error('上传头像图片只能是 JPG或PNG 格式!');
      }else if(!isLt2M){
        this.$message.error('上传头像图片大小不能超过 2MB!');
      }
    },
    /** 查询应用列表 */
    getList() {
      this.loading = true;
      listApp(this.queryParams).then(response => {
        this.appList = response.rows;
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
      this.fileList=[];
      this.form={};
      this.$refs.uploadFile.clearFiles();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        sn: null,
        name: null,
        status: null,
        createTime: null,
        sort:1,
        isView:1,
        isDeptSn:2,
        jwtexpiresTime:30,
        isDefaultOpen: 2,
        isMobileType: 1,
        updateTime: null,
        isShopManage:2
      };
      this.checkList=[],
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
    //状态格式化
    statusFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isView);
    },
    //默认开通格式化
    defaultOpenFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isDefaultOpen);
    },
    //默认门店管理员授权
    isShopManageFormat(row, column) {
      return this.selectDictLabel(this.commonNormalDisableOptions, row.isShopManage);
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
      this.title = "添加应用";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getApp(id).then(response => {
        this.form=response.data;
        if(response.data.profileUrl!=null && response.data.profileUrl!=undefined){
          var name=response.data.profileUrl.substring(response.data.profileUrl.lastIndexOf("/")+1);
          this.fileList.push({url:this.form.profileUrl,name:name})
          this.form.profileUrl=name;
        }
        this.title = "修改应用";
        this.open = true;
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if(this.form.profileUrl==undefined || this.form.profileUrl==null){
            this.$message.error("请上传封面");
            return;
          }
          if (this.form.id != null) {
            updateApp(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.open = false;
                this.getList();
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addApp(this.form).then(response => {
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
        return delApp(ids);
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
      this.$confirm('是否确认导出所有应用数据项?', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function () {
        return exportApp(queryParams);
      }).then(response => {
        this.download(response.msg);
      })
    }
  }
};
</script>
<style lang="scss" scoped>
  .image-upload{
    ::v-deep {
      .el-upload-list__item-thumbnail{
        width: 200px;
        height: 180px;
      }
      .el-upload-list--picture .el-upload-list__item{
        width: 230px;
        height: 200px;
        z-index: 100;
      }
      .el-upload-list__item-name{
          width: 0px;

      }
      .el-icon-close-tip{
        display: none;
      }
    } 
  }
</style>
