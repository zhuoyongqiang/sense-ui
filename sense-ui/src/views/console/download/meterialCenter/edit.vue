<template>
  <div class="app-container">
    <!-- 添加或修改公告对话框 -->
    <el-dialog :title="dialogObj.title" :visible.sync="dialogObj.open" @open="openEvent" @close="handleClose"
               width="1350px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="6">
            <el-row>
              <el-col :span="24">
                <el-form-item label="是否置顶" prop="isTop">
                  <el-radio-group v-model="form.isTop">
                    <el-radio :label="'1'">是</el-radio>
                    <el-radio :label="'0'">否</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="是否下载" prop="isDownload">
                  <el-radio-group v-model="form.isDownload">
                    <el-radio :label="'1'">是</el-radio>
                    <el-radio :label="'0'">否</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="是否预览" prop="isPriview">
                  <el-radio-group v-model="form.isPriview">
                    <el-radio :label="'1'">是</el-radio>
                    <el-radio :label="'0'">否</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="状态" prop="status">
                  <el-radio-group v-model="form.status">
                    <el-radio :label="item.dictValue" v-for="item in commonStatus" :key="item.id">{{ item.dictLabel }}
                    </el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="排序号" prop="sort">
                  <el-input-number v-model="form.sort" style="width:100%" controls-position="right" :min="1"
                                   :precision="0" label="排序号"></el-input-number>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="类型" prop="type">
                  <el-select v-model="form.type" clearable placeholder="请选择">
                    <el-option
                      v-for="item in meterialTypes"
                      :key="item.id"
                      :label="item.name"
                      :value="item.id">
                    </el-option>
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="缩略图" prop="thumbnil">
                  <el-tooltip class="item" effect="dark" content="图片大小（170*140）" placement="top">
                    <i class="el-icon-question" style="font-size:18px"></i>
                  </el-tooltip>
                  <el-upload
                    class="avatar-uploader"
                    :action="upload.url"
                    :headers="upload.headers"
                    :show-file-list="false"
                    :before-upload="beforePhotoUpload"
                    :on-success="handleThumbnalSuccess">
                    <img v-if="form.thumbnil" :src="baseFilePath+form.thumbnil" class="avatar">
                    <i v-else class="el-icon-plus avatar-uploader-icon"></i>
                  </el-upload>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-form-item label="权限" prop="roles">
                  <treeselect v-model="roles" multiple :options="deptOptions" :flat="true" placeholder="请选择权限"/>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24">
                <el-upload
                  class="image-upload"
                  :action="upload.url"
                  :headers="upload.headers"
                  multiple
                  ref="uploadFile"
                  :file-list="fileList"
                  :on-change="handleUploadChange"
                  :on-preview="handeleProview"
                  :on-remove="handleRemove"
                  :on-success="handleSuccess"
                  :on-error="handleError">
                  <el-button size="small" type="primary">附件上传</el-button>
                </el-upload>
              </el-col>
            </el-row>
          </el-col>
          <el-col :span="18">
            <el-row>
              <el-col :span="24">
                <el-form-item label="标题" prop="name">
                  <el-input v-model="form.name" placeholder="请输入标题"/>
                </el-form-item>
              </el-col>
            </el-row>
            <!-- <el-row>
              <el-col :span="24">
                <el-form-item label="作者" prop="author">
                  <el-input v-model="form.author" placeholder="请输入作者" />
                </el-form-item>
              </el-col>
            </el-row> -->
            <el-row>
              <el-col :span="24">
                <el-form-item label="正文" prop="content">
                  <vue-ueditor-wrap ref="noticeContent" v-model="form.content" :config="myConfig"></vue-ueditor-wrap>
                </el-form-item>
              </el-col>
            </el-row>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="()=>{this.dialogObj.open=false}">取 消</el-button>
        <el-button type="primary" @click="submitForm()">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import VueUeditorWrap from 'vue-ueditor-wrap'
import {getToken} from "@/utils/auth";
import {allMeterialType} from "@/api/console/download/meterialType";
import {getMeterial, addMeterial, updateMeterial} from "@/api/console/download/meterial";
import {treeselect} from "@/api/console/system/dept";
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
import Sortable from 'sortablejs';

export default {
  name: "meterialCenterEdit",
  props: ["dialogObj"],
  components: {VueUeditorWrap, Treeselect},
  data() {
    return {
      msg: '',
      myConfig: {
        // 编辑器不自动被内容撑高
        autoHeightEnabled: false,
        // 初始容器高度
        initialFrameHeight: 400,
        // 初始容器宽度
        initialFrameWidth: '100%',
        // 上传文件接口
        serverUrl: process.env.VUE_APP_BASE_API + '/ueditor/server',
        // UEditor 资源文件的存放路径，如果你使用的是 vue-cli 生成的项目，通常不需要设置该选项，vue-ueditor-wrap 会自动处理常见的情况，如果需要特殊配置，参考下方的常见问题2
        UEDITOR_HOME_URL: '/static/ueditor/'
      },
      //上传对象
      upload: {
        //上传头
        headers: {
          'Authorization': "Bearer " + getToken(),
        },
        //上传地址
        url: process.env.VUE_APP_BASE_API + "/common/file/upload"
      },
      // 表单参数
      form: {},
      //文件集合
      fileList: [],
      //预览附件
      priviewFileList: [],
      // 表单校验
      rules: {
        name: [
          {required: true, message: "名称不能为空", trigger: "blur"}
        ],
        status: [
          {required: true, message: "状态不能为空", trigger: "blur"}
        ],
        meterialUrl: [
          {required: true, message: "素材不能为空", trigger: "blur"},
        ],
        type: [
          {required: true, message: "素材类型不能为空", trigger: "blur"},
        ],
        thumbnil: [
          {required: true, message: "缩略图不能为空", trigger: "blur"},
        ],
        sort: [
          {required: true, message: "排序号不能为空", trigger: "blur"}
        ],
        // content :[
        //   { required: true, message: "内容不能为空", trigger: "blur" },
        // ],
        // author :[
        //   { required: true, message: "作者不能为空", trigger: "blur" },
        // ],
      },
      //发布时间
      startOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now() - 24 * 60 * 60 * 1000;
        }
      },
      //文件显示前缀
      baseFilePath: undefined,
      //状态集合
      commonStatus: [],
      //是否禁用文件上传
      fileDisabled: false,
      //类型
      meterialTypes: [],
      // 部门树选项
      deptOptions: [],
      //选中部门集合
      roles: [],
      //更新文件集合
      uploadFileList: []
    }
  },
  created() {
    this.getDicts('common_status').then(response => {
      this.commonStatus = response.data;
    });
    this.getTreeselect()
  },
  methods: {
    initDragSort() {
      // 支持拖拽排序
      const el = this.$refs.uploadFile.$el.querySelectorAll('.el-upload-list')[0];
      Sortable.create(el, {
        onEnd: ({oldIndex, newIndex}) => {
          // 交换位置
          const arr = this.uploadFileList;
          const page = arr[oldIndex];
          arr.splice(oldIndex, 1);
          arr.splice(newIndex, 0, page);
        }
      });
    },
    /** 查询部门下拉树结构 */
    getTreeselect() {
      treeselect().then(response => {
        this.deptOptions = response.data;
      });
    },
    //打开回调
    openEvent() {
      if (this.dialogObj.event == "edit") {
        getMeterial(this.dialogObj.id).then(response => {
          this.form = response.data;
          //赋值文件
          this.form.fileList.forEach(element => {
            this.fileList.push({
              url: element.url,
              name: element.name
            });
            this.uploadFileList.push({
              url: element.url,
              name: element.name
            });
          });
          //赋值权限
          this.form.roleList.forEach(element => {
            this.roles.push(element.orgSn);
          });
        });
      } else {
        this.roles.push("0001");
        this.reset();
      }
      this.$nextTick(() => {
        this.initDragSort();
      })
      //查询字典上传地址前缀
      this.getConfigKey('file_download_url').then(response => {
        this.baseFilePath = response.msg;
      });
      //查询类型
      allMeterialType({status: '1', belongingType: this.dialogObj.belongingType}).then(resp => {
        this.meterialTypes = resp;
      });
    },

    //缩略图上传前的回调方法
    beforePhotoUpload(file) {
      var testmsg = file.name.substring(file.name.lastIndexOf(".") + 1);
      const isJPG = file.type === 'image/jpeg';
      const isPNG = testmsg === 'png';
      const isLt2M = file.size / 1024 / 1024 < 2;
      if (!isPNG && !isJPG) {
        this.$message.error('上传图片只能是 JPG或PNG或JPEG 格式!');
      } else if (!isLt2M) {
        this.$message.error('上传图片大小不能超过 2MB!');
      }
      return (isJPG || isPNG) && isLt2M;
    },
    //缩略图上传
    handleThumbnalSuccess(file) {
      if (file.code == 200) {
        this.$set(this.form, "thumbnil", file.msg);
      }
    },
    //上传改变
    handleUploadChange(file, fileList) {
      // console.log(file);
    },
    //上传成功回调
    handleSuccess(resp, file, fileList) {
      this.fileList = fileList;
      this.uploadFileList = [];
      fileList.forEach(element => {
        if (element.response) {
          this.uploadFileList.push({
            name: element.name,
            url: this.baseFilePath + element.response.msg
          })
        } else {
          this.uploadFileList.push({
            name: element.name,
            url: element.url
          })
        }
      });
    },
    //点击上传功能
    handeleProview(file) {
      this.fileDisabled = true;
    },
    //上传失败回调
    handleError(file) {
      this.$message.error(file.msg)
    },
    //删除回调
    handleRemove(file, fileList) {
      this.fileList = fileList;
      for (let index = 0; index < this.uploadFileList.length; index++) {
        const element = this.uploadFileList[index];
        if (element.name == file.name) {
          this.uploadFileList.splice(index, 1);
        }
      }
    },
    //初始化表单
    reset() {
      this.resetForm("form");
      this.form = {
        isTop: '0',
        status: '1',
        thumbnil: 'defalut/defalut.png',
        belongingType: this.dialogObj.belongingType,
        sort: 1,
        isDownload: '1',
        isPriview: '1'
      };
    },
    /** 提交按钮 */
    submitForm() {
      if (this.roles.length == 0) {
        this.$message.error("权限不能为空");
        return;
      }
      //格式化集合
      var roleList = [];
      this.roles.forEach(element => {
        roleList.push({
          orgSn: element,
        })
      });
      this.$set(this.form, 'roleList', roleList);
      this.$set(this.form, 'fileList', this.uploadFileList);
      let names = this.uploadFileList.map(item => item["name"]);
      let nameSet = new Set(names);
      if (nameSet.size != names.length) {
        this.$message.error("有重复名的附件")
        return;
      }
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.thumbnil == undefined || this.form.thumbnil == null) {
            this.$message.error("请上传缩略图");
            return;
          }
          if (this.dialogObj.event == 'edit') {
            updateMeterial(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("修改成功");
                this.$emit("success", this.dialogObj.belongingType)
              } else {
                this.msgError(response.msg);
              }
            });
          } else {
            addMeterial(this.form).then(response => {
              if (response.code == 200) {
                this.msgSuccess("新增成功");
                this.$emit("success", this.dialogObj.belongingType)
              } else {
                this.msgError(response.msg);
              }
            });
          }
        }
      });
    },
    //关闭回调
    handleClose() {
      this.form = {};
      this.$refs.uploadFile.clearFiles();
      this.fileList = [];
      this.roles = [];
      this.uploadFileList = [];

    },
  }
}
</script>

<style lang="scss" scoped>
.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.avatar-uploader .el-upload:hover {
  border-color: #409EFF;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  line-height: 178px;
  text-align: center;
}

.avatar {
  width: 178px;
  height: 178px;
  display: block;
}


</style>
