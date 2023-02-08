<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm"  :inline="true" v-show="showSearch" label-width="68px">
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
       <el-form-item label="素材类型" prop="type">
        <el-select v-model="queryParams.type" clearable placeholder="请选择">
          <el-option
            v-for="item in meterialTypes"
            :key="item.id"
            :label="item.name"
            :value="item.id">
          </el-option>
        </el-select>
      </el-form-item><br>
       <el-form-item label="下载量" prop="num">
        <el-input-number v-model="queryParams.minNum"  controls-position="right"  :precision="0" :min="0"  ></el-input-number>～
        <el-input-number v-model="queryParams.maxNum"   controls-position="right" :precision="0" :min="0"  ></el-input-number>
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
          v-hasPermi="['download:meterial:add']"
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
          v-hasPermi="['download:meterial:edit']"
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
          v-hasPermi="['download:meterial:delete']"
        >删除
        </el-button>
      </el-col>
    </el-row>

    <el-tabs style="min-height: 300px;" v-model="queryParams.belongingType"  @tab-click="handleTbaClick">
      <el-tab-pane :label="item.name" :name="item.sn" v-if="checkPermi([item.roleKey])"   v-for="item in downloadTypes" :key="item.sn">
        <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="55" align="center"/>
          <el-table-column label="素材名" align="center" prop="name"/>
          <el-table-column label="状态" align="center" prop="status" :formatter="statusFormat"  width="80"/>
          <el-table-column label="类型" align="center" prop="typeName" width="180"  show-overflow-tooltip />
          <!-- <el-table-column label="浏览量" align="center" prop="browseNum" width="70"/> -->
          <el-table-column label="下载量" align="center" prop="downloadNum" width="70"/>
          <el-table-column label="浏览量" align="center" prop="browseNum" width="70"/>
          <el-table-column label="排序号" align="center" prop="sort" width="70"/>
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
                v-hasPermi="['download:meterial:edit']"
              >修改
              </el-button>
              <el-button
                size="mini"
                type="text"
                icon="el-icon-delete"
                @click="handleDelete(scope.row)"
                v-hasPermi="['download:meterial:delete']"
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
      </el-tab-pane>
    </el-tabs>
    <edit-dialog  :dialogObj="dialogObj" @success="dialogSuccess"></edit-dialog>
  </div>
</template>

<script>
import { listMeterial ,delMeterial} from "@/api/console/download/meterial";
import {allMeterialType} from "@/api/console/download/meterialType";
import {allMeterialCategory} from "@/api/console/download/meterialCategory";
import {checkPermi } from "@/utils/permission";
import editDialog from "./edit";
export default {
  name: "meterialCenter",
  components: {editDialog},
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
        type:null,
        minNum:undefined,
        maxNum:undefined,
        belongingType:undefined
      },
      //选中的ID
      checkId:null,
      //弹出层对象
      dialogObj:{
        //对象ID
        id:undefined,
        // 弹出层标题
        title: "",
        // 是否显示弹出层
        open: false,
        //打开操作
        event:undefined
      },
      //字典
      commonStatus:[],
      //类型
      meterialTypes:[],
      //文件显示前缀
      baseFilePath:undefined,
      //下载类型
      downloadTypes: [],
      //默认类型
      defaultbelongingType:'meterial',

    };
  },
  created() {
    //字典
    this.getDicts('common_status').then(response => {
      this.commonStatus = response.data;
    });
    allMeterialCategory({status:1}).then(response=>{
      this.downloadTypes = response;
      for (let index = 0; index < this.downloadTypes.length; index++) {
        const element = this.downloadTypes[index];
        if (this.checkPermi([element.roleKey])) {
          this.queryParams.belongingType = element.sn;
          this.defaultbelongingType = element.sn;

          this.getList();
          break;
        }
      }
    })
    //查询类型
    allMeterialType({status:'1',belongingType:this.queryParams.belongingType}).then(resp=>{
      this.meterialTypes = resp;
    });
    //参数列表
    this.getConfigKey('file_download_url').then(response => {
      this.baseFilePath = response.msg;
    });
  },
  methods: {
    //权限方法
    checkPermi,
    //tab点击
    handleTbaClick(tab, event) {
      console.log(tab);
      //查询类型
      allMeterialType({status:'1',belongingType:tab.name}).then(resp=>{
        if(resp.length==0){
          this.$message.error(tab.label+"模块缺少下载类型");
          this.queryParams.belongingType=this.defaultbelongingType;
        }else{
          this.meterialTypes = resp;
        }
        this.resetForm("queryForm");
        this.queryParams.mixNum=undefined;
        this.queryParams.maxNum=undefined;
        this.handleQuery();
      });
    },
    /** 查询素材列表 */
    getList() {
      this.loading = true;
      listMeterial(this.queryParams).then(response => {
        this.list = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    //管理窗口
    handleClose(){
      this.form={};
      this.fileList=[];
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.queryParams.mixNum=undefined;
      this.queryParams.maxNum=undefined;
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
      this.dialogObj.open=true;
      this.dialogObj.title="添加素材";
      this.dialogObj.event="add";
      this.dialogObj.belongingType=this.queryParams.belongingType;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      const id = row.id || this.ids
      this.dialogObj.open=true;
      this.dialogObj.title="修改素材";
      this.dialogObj.id=id;
      this.dialogObj.event="edit";
      this.dialogObj.belongingType=this.queryParams.belongingType;
    },
    //新增修改成功后的回调
    dialogSuccess(belongingType){
      this.dialogObj.open=false;
      // 查询参数
      this.queryParams={
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        name: null,
        status:null,
        type:null,
        minNum:undefined,
        maxNum:undefined,
        belongingType:belongingType
      },
      this.getList();
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
        width: 158px;
        height: 158px;
        line-height: 158px;
        text-align: center;
      }
   }
  }
  .avatar {
    width: 158PX;
    height: 158px;
    display: block;
  }
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
</style>
