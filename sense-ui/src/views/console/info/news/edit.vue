<template>
  <!-- 添加或修改内容对话框 -->
  <el-dialog :title="dialogObj.title" @open="openEvent" @close="cancel()" :visible.sync="dialogObj.open" width="98%"
             :close-on-click-modal="false"
             :close-on-press-escape="true" :modal-append-to-body="false">
    <el-row :gutter="20">
      <el-form ref="form" :model="form" label-width="80px">
        <!--分类数据-->
        <el-col :span="4" :xs="24">
          <el-form-item label="所属分类" prop="newsTypeId"
                        :rules="[{ required: true, message: '所属分类不能为空', trigger: 'change' }]">
            <el-select v-model="form.newsTypeId"
                       placeholder="所属分类"
                       size="small"
                       style="width: 100%"
                       clearable
                       v-if="!dialogObj.isApprove">
              <el-option
                v-for="dict in newsTypeOptions"
                :key="dict.id"
                :label="dict.name"
                :value="dict.id"
              />
            </el-select>
            <el-input v-else v-model="form.newsTypeName" disabled/>
          </el-form-item>
          <el-form-item label="作者" prop="issuer" :rules="[{ required: true, message: '作者不能为空', trigger: 'blur' }]">
            <el-input v-model="form.issuer" type="textarea" resize="none" :autosize="{ minRows: 1, maxRows: 4}" placeholder="请输入作者"/>
          </el-form-item>
          <el-form-item label="首页轮播" prop="isCarousel">
            <el-radio-group v-model="form.isCarousel">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="封面" prop="photo">
            <div style="" @click="openCropperImage()">
              <img v-if="photoUrl" width="100%" :src="photoUrl" class="avatar">
              <i v-else class="el-icon-plus avatar-uploader-icon"></i>
            </div>
          </el-form-item>
          <el-form-item v-show="dialogObj.id || defaultPhase.showPhase" label="当前期数" prop="currentPhase">
            <el-input-number v-model="form.currentPhase" :min="0"></el-input-number>
          </el-form-item>
          <el-form-item v-show="dialogObj.id || defaultPhase.showPhase" label="总期数" prop="totalPhase">
            <el-input-number v-model="form.totalPhase" :min="0"></el-input-number>
          </el-form-item>
          <el-form-item label="特殊置顶" prop="isSpecial">
            <el-radio-group v-model="form.isSpecial">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="是否置顶" prop="isFirst">
            <el-radio-group v-model="form.isFirst">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="是否评论" prop="isComment">
            <el-radio-group v-model="form.isComment">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="支持转载" prop="isSupportTransport"
                        v-if="form.id==undefined || (form.id!=null && form.transportNewsId==null)">
            <el-radio-group v-model="form.isSupportTransport">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="推送企业微信" prop="isSendMsg">
            <el-radio-group v-model="form.isSendMsg">
              <el-radio
                v-for="dict in commonYesNoOptions"
                :key="Number(dict.dictValue)"
                :label="Number(dict.dictValue)"
              >{{ dict.dictLabel }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="发布时间" prop="effectTime"
                        :rules="[{ required: true, message: '发布时间不能为空', trigger: 'blur' }]">
            <el-date-picker clearable
                            style="width:100%"
                            v-model="form.effectTime"
                            format="yyyy-MM-dd HH:mm"
                            value-format="yyyy-MM-dd HH:mm"
                            :default-value="new Date()"
                            type="datetime"
                            placeholder="选择发布时间">
            </el-date-picker>
          </el-form-item>
          <el-form-item style="display:none" label="失效时间" prop="expireTime">
            <el-date-picker clearable
                            style="width:100%"
                            v-model="form.expireTime"
                            format="yyyy-MM-dd HH:mm"
                            value-format="yyyy-MM-dd HH:mm"
                            type="datetime"
                            placeholder="选择失效时间">
            </el-date-picker>
          </el-form-item>
          <el-form-item label="可见机构" prop="isScope" v-if="isShow" :rules="[{ required: true, message: '可见机构不能为空', trigger: 'change' }]">
            <el-radio-group v-model="form.isScope">
              <el-radio :label="0" @click.native.stop="showallOrgRange">全行</el-radio>
              <el-radio :label="1" @click.native.stop="showOrgRange">部分</el-radio>
            </el-radio-group>
            <!-- <el-switch v-model="form.isScope" inactive-text="全行可见" active-text="部分可见" :inactive-value="0" :active-value="1" @change="resetValidate()"></el-switch> -->
            <!-- <el-switch v-model="form.isScope" :inactive-value="0" :active-value="1" @change="resetValidate()"></el-switch> -->
          </el-form-item>
          <el-form-item prop="visibleDept" :rules="[{ required: form.isScope == 1, message: this.isShow?'可见机构不能为空':'您没有权限操作该新闻内容，请联系管理员赋予权限', trigger: 'change' }]">
            <!-- <el-cascader
              :options="deptOptions"
              :props="props"
              v-model="form.visibleDept"
              clearable
              collapse-tags
              :show-all-levels="false" v-if="form.isScope == 1 && isShow"></el-cascader> -->
          </el-form-item>
        </el-col>
        <el-col :span="20" :xs="24">
          <el-form-item label="标题" prop="title" :rules="[{ required: true, message: '内容标题不能为空', trigger: 'blur' }]">
            <el-input v-model="form.title" placeholder="请输入内容标题"/>
          </el-form-item>
          <el-form-item label="摘要" prop="abtract">
            <el-input v-model="form.abtract" placeholder="请输入摘要"/>
          </el-form-item>
          <el-form-item label="正文" prop="content">
            <Editor
              ref="editor"
              :height="400"
              v-model="form.content"
              :imagesUploadHandler="imagesUploadHandler"
            />
          </el-form-item>
          <!--附件数据-->
          <el-form-item>
            <el-upload
              :action="uploadSetting.url"
              :headers="uploadSetting.headers"
              :data="{isSave:true,type:'file'}"
              :on-success="handleAttachmentSuccess"
              :before-upload="beforeAttachmentUpload"
              :on-remove="handleAttachmentRemove"
              :file-list="fileList">
              <el-button size="small" type="primary">附件上传</el-button>
            </el-upload>
          </el-form-item>

        </el-col>

      </el-form>
    </el-row>
    <div slot="footer" class="dialog-footer">
      <el-button type="primary" @click="submitForm">确 定</el-button>
      <el-button @click="cancel">取 消</el-button>
    </div>

    <cropper-image @cropperImageCallback="cropperImageCallback" :baseFilePath="baseFilePath"
                   :cropperImageDialog.sync="cropperImageDialog"></cropper-image>

    <el-dialog title="选择可见机构范围" @close="resetorgRange" :visible.sync="orgRangeVisible" width="300"
             :close-on-click-modal="true"
             :close-on-press-escape="true" :modal-append-to-body="true" append-to-body>
      <div class="orgRangeContainer">
        <el-tree
          ref="tree"
          :data="deptOptions"
          show-checkbox
          node-key="id"
					:check-strictly="false"
          :default-expanded-keys="['0001']"
          :props="props">
        </el-tree>
      </div>
      <div class="orgRange-buttons">
        <el-button type="primary" plain @click.stop="orgRangeVisible = false">取消</el-button>
        <el-button type="primary" @click.stop="marksureorgRange">确认</el-button>
      </div>
    </el-dialog>
  </el-dialog>
</template>

<script>
  import {getToken} from "@/utils/auth";
  import {uploadFile} from "@/api/common";
  import {addNews, getNews, updateNews} from "@/api/console/info/news";
  import axios from "axios";
  import {listNewsType} from "@/api/console/info/newsType";
  import CropperImage from "@/views/console/info/news/cropperImage";
  import Editor from "@/components/TinymceEditor/index";
  import {parseTime} from "@/utils/sense";
  import {treeselect} from "@/api/console/system/dept";
  import {getInfo} from "@/api/login";
  export default {
    name: "edit",
    components: {CropperImage, Editor},
    props: {
      dialogObj: Object,
      callback: Function
    },
    watch: {
      'form.newsTypeId': {
        handler(newData, oldData) {
          console.warn('newsTypeId')
          // console.log('newData', newData)
          if (!this.dialogObj.id) {
            listNewsType({}).then(response => {
              this.newsTypeOptions = response.data;
              let list = this.newsTypeOptions;
              for (let i in list) {
                if (list[i].id == newData) {
                  this.cropperImageDialog.photoWidth = list[i].photoWidth;
                  this.cropperImageDialog.photoHeight = list[i].photoHeight;
                  this.typeImage.photoWidth = list[i].photoWidth;
                  this.typeImage.photoHeight = list[i].photoHeight;
                  this.defaultPhase.showPhase = list[i].showPhase
                  this.defaultPhase.currentPhase = list[i].currentPhase
                  this.defaultPhase.totalPhase = list[i].totalPhase
                  // 判断当前新闻是新建的还是已有的
                  if (!this.dialogObj.id) {
                    this.defaultPhase.showPhase = list[i].showPhase
                    if (this.defaultPhase.showPhase) {
                      this.form.currentPhase = this.defaultPhase.currentPhase
                      this.form.totalPhase = this.defaultPhase.totalPhase
                    } else {
                      this.form.currentPhase = undefined
                      this.form.totalPhase = undefined
                    }
                  }
                }
                if (newData === '1007') {
                  this.form.isSupportTransport = 1
                } else {
                  this.form.isSupportTransport = 0
                }
              }
            });
          } else {
            let list = this.newsTypeOptions;
            for (let i in list) {
              if (list[i].id == newData) {
                this.cropperImageDialog.photoWidth = list[i].photoWidth;
                this.cropperImageDialog.photoHeight = list[i].photoHeight;
                this.typeImage.photoWidth = list[i].photoWidth;
                this.typeImage.photoHeight = list[i].photoHeight;
                this.defaultPhase.showPhase = list[i].showPhase
                this.defaultPhase.currentPhase = list[i].currentPhase
                this.defaultPhase.totalPhase = list[i].totalPhase
                // 判断当前新闻是新建的还是已有的
                if (!this.dialogObj.id) {
                  this.defaultPhase.showPhase = list[i].showPhase
                  if (this.defaultPhase.showPhase) {
                    this.form.currentPhase = this.defaultPhase.currentPhase
                    this.form.totalPhase = this.defaultPhase.totalPhase
                  } else {
                    this.form.currentPhase = undefined
                    this.form.totalPhase = undefined
                  }
                }
              }
              if (newData === '1007') {
                this.form.isSupportTransport = 1
              } else {
                this.form.isSupportTransport = 0
              }
            }
          }          
        }
      },
      'dialogObj.open'(val) {
        if (!val && !this.dialogObj.id) {
          console.log('leaveform', this.form)
          console.log('leavefileList', this.fileList)
          this.dialogObj.old = JSON.parse(JSON.stringify(this.form))
          if (this.fileList && this.fileList.length) this.dialogObj.fileList = this.fileList
        }
      }
    },
    data() {
      return {
        defaultPhase: {
          showPhase: false,
          currentPhase: 0,
          totalPhase: 0
        },
        orgRangeVisible: false,
        // 表单参数
        form: {
          id: null,
          newsTypeId: null,
          title: null,
          content: null,
          photo: null,
          issuer: null,
          abtract: null,
          isFirst: 0,
          isSpecial: 0,
          isScope:0,
          isComment: 0,
          isCarousel:0,
          isSupportTransport: 1,
          isSendMsg: 1,
          contentImagePath: null,
          effectTime: null,
          expireTime: null,
          status: null,
          visibleDept:[]
        },
        // 上传参数
        uploadSetting: {
          // 设置上传的请求头部
          headers: {Authorization: "Bearer " + getToken()},
          // 上传的地址
          url: process.env.VUE_APP_BASE_API + "/common/upload"
        },
        //文件列表
        fileList: [],
        /**封面路径*/
        photoUrl: undefined,
        /**文件基本路径*/
        baseFilePath: undefined,
        /**通用是否*/
        commonYesNoOptions: [],
        //分类集合
        newsTypeOptions: [],
        //裁剪图片弹出框
        cropperImageDialog: {
          open: false,
          photoWidth: undefined,
          photoHeight: undefined,
          img: undefined
        },
        typeImage: {
          photoWidth: undefined,
          photoHeight: undefined,
        },
        props: { multiple: true,emitPath:false,value:"id" },
        deptOptions: [],
        formRules: {
           visibleDept: [{ required: true, message: '可见机构不能为空', trigger: 'change' }]
        },
        isShow: false
      }
    },
    created() {
      console.log('新建')
      listNewsType({}).then(response => {
        this.newsTypeOptions = response.data;
      });
      this.getConfigKey('base_file_path').then(response => {
        this.baseFilePath = response.msg;
      });
      this.getDicts('common_yes_no').then(response => {
        this.commonYesNoOptions = response.data;
      });
      this.getTreeselect();
    },
    methods: {
      /**打开的回调*/
      openEvent() {
        //重置
        this.reset();
        console.warn('112', this.newsTypeId)
        this.fileList = [];
        //判断是新增还是修改
        if (this.dialogObj.id) {
          getNews(this.dialogObj.id).then(response => {
            this.form = response.data;
            this.isShow = response.data.isShow;
            this.open = true;
            this.title = "修改内容";
            if (response.data.photo) this.photoUrl = this.baseFilePath + response.data.photo;
            let attachmentList = response.data.attachmentList;
            for (let i in attachmentList) {
              let obj = {};
              obj.id = attachmentList[i].id;
              obj.name = attachmentList[i].attachmentTitle;
              obj.url = this.baseFilePath + attachmentList[i].attachmentUrl;
              this.fileList.push(obj);
            }
            let list = this.newsTypeOptions;
            for (let i in list) {
              if (list[i].id == response.data.newsTypeId) {
                this.cropperImageDialog.photoWidth = list[i].photoWidth;
                this.cropperImageDialog.photoHeight = list[i].photoHeight;
              }
            }
            if (this.dialogObj.bpmNewsTask && this.dialogObj.bpmNewsTask.type === 2) {
              if (this.form.effectTime < parseTime(new Date(), '{y}-{m}-{d} {h}:{i}')) {
                this.form.effectTime = parseTime(new Date(), '{y}-{m}-{d} {h}:{i}')
              }
            }
          });
        } else {
          getInfo().then(response => {
            if(response.code===200) {
              console.log(response)
              if(response.user){
                let issuer;
                if(response.user.orgDept){
                  issuer = response.user.orgDept.deptName
                }
                if(response.user.departmentDept){
                  issuer += response.user.departmentDept.deptName
                }
                // issuer += " 责任编辑：XXX"
                issuer += " 责任编辑：" + response.user.nickName;
                if(!response.isShow){

                  this.form.isScope = 1;
                  this.form.visibleDept = [response.user.orgCodeId];
                  console.log('form', this.form);
                }
                this.form.issuer = issuer
                this.isShow = response.isShow;
                this.defaultPhase.currentPhase && (this.form.currentPhase = this.defaultPhase.currentPhase)
                this.defaultPhase.totalPhase && (this.form.totalPhase = this.defaultPhase.totalPhase)
              }
            }
          })
          this.cropperImageDialog.photoWidth = this.dialogObj.photoWidth;
          this.cropperImageDialog.photoHeight = this.dialogObj.photoHeight;
          this.$nextTick(() => {
            console.log('initform', this.dialogObj.old)
            console.log('initfile', this.dialogObj.fileList)
            if (this.dialogObj.old) {
              this.form = this.dialogObj.old;
              if (this.dialogObj.old.photo) this.photoUrl = this.baseFilePath + this.dialogObj.old.photo;
            }
            if (this.dialogObj.fileList && this.dialogObj.fileList.length) this.fileList = this.dialogObj.fileList;
            this.form.effectTime = parseTime(new Date(), '{y}-{m}-{d} {h}:{i}');
            if (this.dialogObj.newsTypeId) this.form.newsTypeId = this.dialogObj.newsTypeId;
          })
        }

      },
      // 选择机构确定事件
      marksureorgRange () {
        this.form.visibleDept = this.$refs.tree.getCheckedKeys()
        this.orgRangeVisible = false
      },
      // 表单重置
      reset() {
        this.defaultPhase.showPhase = false
        this.defaultPhase.currentPhase = 0
        this.defaultPhase.totalPhase = 0
        this.form = {
          id: null,
          newsTypeId: null,
          title: null,
          content: null,
          photo: null,
          issuer: null,
          abtract: null,
          isFirst: 0,
          isSpecial: 0,
          isComment:0,
          isCarousel:0,
          isSupportTransport: 1,
          isSendMsg: 1,
          contentImagePath: null,
          effectTime: null,
          expireTime: null,
          status: null,
          visibleDept:[],
          currentPhase: 0,
          totalPhase: 0,
        };
        this.fileList = [];
        this.photoUrl = undefined;
        this.$nextTick(function () {
          if (this.$refs.editor) {
            this.$refs.editor.clear()
          }
        })
        this.resetForm("form");
      },
      /**附件上传成功的回调函数*/
      handleAttachmentSuccess(res, file, fileList) {
        if (res.code == 200) {
          let obj = {};
          obj.id = res.data.id;
          obj.name = res.data.attachmentTitle;
          obj.url = this.baseFilePath + res.data.attachmentUrl;
          this.fileList.push(obj);
        }else{
          let _tmp = this.fileList;
          _tmp.splice(_tmp.length, 1);
          this.fileList = _tmp;
          this.msgError(res.msg)
        }
      },
      /**附件上传前的回调函数*/
      beforeAttachmentUpload(file) {
        return true;
      },
      /**附件移除成功的回调函数*/
      handleAttachmentRemove(file, fileList) {
        let _tmp = this.fileList;
        for (let i = 0, len = _tmp.length; i < len; i++) {
          if (_tmp[i].id == file.id) {
            _tmp.splice(i, 1);
            break;
          }
        }
        this.fileList = _tmp;
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
      /** 提交按钮 */
      submitForm() {
        let data = this.getTinyMcePicture();
        this.form.contentImagePath = data.join(',');
        this.form.attachmentList = this.fileList;
        this.$refs["form"].validate(valid => {
          if (valid) {
            if (this.form.id != null) {
              updateNews(this.form).then(response => {
                if (response.code == 200) {
                  this.msgSuccess("修改成功");
                  this.dialogObj.open = false;
                  this.reset();
                  this.$emit('callback');
                } else {
                  this.msgError(response.msg);
                }
              });
            } else {
              addNews(this.form).then(response => {
                if (response.code == 200) {

                  this.msgSuccess("新增成功");
                  this.dialogObj.old = null
                  this.dialogObj.fileList = []
                  this.dialogObj.open = false;
                  this.reset();
                  this.$emit('callback');
                } else {
                  this.msgError(response.msg);
                }
              });
            }
          }
        });
      },
      //打开裁剪图片
      openCropperImage() {
        //如果选中首页轮播，则固定裁剪长宽，如果不是则根据封面获取
        if(this.form.isCarousel === 1){
          this.cropperImageDialog.photoWidth = 780;
          this.cropperImageDialog.photoHeight = 360;
        }else{
          this.cropperImageDialog.photoWidth = this.typeImage.photoWidth
          this.cropperImageDialog.photoHeight = this.typeImage.photoHeight
        }
        this.cropperImageDialog.open = true;
      },
      //裁剪图片回调
      cropperImageCallback(data) {
        let formData = new FormData();
        formData.append('file', data);
        formData.append('isSave', false);
        formData.append('type', 'profile');
        axios.post(process.env.VUE_APP_BASE_API + "/common/upload", formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
            Authorization: "Bearer " + getToken(),
          }
        }).then(result => {
          if (result.data.code == 200) {
            this.form.photo = result.data.data.attachmentUrl;
            //this.photoUrl = URL.createObjectURL(data);
            this.photoUrl = this.baseFilePath + result.data.data.attachmentUrl;
            this.cropperImageDialog.open = false;
          } else {
            this.$message.error(result.msg);
          }
        }).catch(response => {
          console.log(response);
        })
      },
      /**获取富文本框的图片*/
      getTinyMcePicture() {
        let activeEditor = this.$refs['editor'].getActiveEditor();
        let editBody = activeEditor.getBody();
        let data = this.loopTinyMicPictrue(editBody);
        return data;
      },
      loopTinyMicPictrue(nodes) {
        let data = [];
        for (let i = 0; i < nodes.childNodes.length; i++) {
          let obj = nodes.childNodes[i];
          let tag = obj.tagName == undefined ? '' : obj.tagName.toUpperCase();
          if (tag == 'IMG') {
            let src = obj.currentSrc;
            data.push(src);
          }
          let subData = this.loopTinyMicPictrue(obj);
          for (let j in subData) {
            data.push(subData[j]);
          }
        }
        return data;
      },
      // 取消按钮
      cancel() {
        this.dialogObj.open = false;
        this.isShow = false;
        // this.reset();
      },
      /** 查询部门下拉树结构 */
      getTreeselect() {
        treeselect().then(response => {
          this.deptOptions = response.data;
        });
      },

      // 选择可见机构-全行|清空form的visibleDept
      showallOrgRange () {
        this.$refs.form.clearValidate('visibleDept');
        this.form.visibleDept = []
      },
      // 选择可见机构-部分|机构树选择器
      showOrgRange () {
        this.orgRangeVisible = true
        this.$nextTick(() => {
          // 机构树初始化选中渲染
          this.$refs.tree.setCheckedKeys(this.form.visibleDept ? this.form.visibleDept : [])
        })
      },
      // 关闭机构选择树，并进行清空操作
      resetorgRange () {
        this.$refs.tree.setCheckedKeys([]);
        this.orgRangeVisible = false
      }
    }
  }
</script>

<style lang="scss" scoped>
  .orgRangeContainer{
    height: 500px;
    overflow-y: auto;
  }
  .orgRange-buttons{
    margin: 20px 0 10px;
    text-align: right;
  }
  ::v-deep .el-tree-node__content{
    position: relative;
    margin-bottom: 10px;
  }
  ::v-deep .el-tree-node__label{
    &::before{
      display: inline-block;
      content: url('../../../../assets/images/window/icon_organization.png');
      width: 24px;
      height: 24px;
      vertical-align: middle;
      margin: 0 8px 0 0;
    }
  }
  ::v-deep .el-tree-node__content .el-checkbox{
    position: absolute;
    right: 0;
  }
  .avatar{
    cursor: pointer;
    &:hover{
      transform: scale(3);
      transform-origin: left center;
      position: relative;
      z-index: 10;
    }
  }
</style>
