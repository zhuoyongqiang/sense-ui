<template>
  <div>
    <el-dialog class="cropper-image-dg" title="上传图片" :visible.sync="editorImageDialog.open" width="91%" @closed="modalclosed" append-to-body>
      <header class="header">
        <div class="bottom-border">
          <el-radio v-model="activeName" label="local" border>本地上传</el-radio>
          <el-radio v-model="activeName" label="outer" border>外部链接</el-radio>
          <el-radio v-model="activeName" label="media" border>媒体库</el-radio> 
        </div>
      </header>
      <!-- 媒体库 -->
      <div class="media-wrapper" v-show="activeName === 'media'">
        <el-form ref="form" :model="queryParams" label-width="80px" class="form-wrapper">
          <el-form-item label="创建时间">
            <el-date-picker v-model="queryParams.createTime" type="date" placeholder="请选择日期" value-format="timestamp" :editable="false"></el-date-picker>
          </el-form-item>
          <el-form-item label="图片名称">
            <el-input v-model="queryParams.imgName" placeholder="请输入内容" clearable></el-input>
          </el-form-item>
          <el-form-item label-width="20px">
            <el-button type="primary" @click="queryMedias(true)">搜索</el-button>
            <el-button @click="resetSeaech()">重置</el-button>
          </el-form-item>
        </el-form>

        <div class="media-container" ref="mediaContainer" v-loading="loading" :class="{'empty': !mediaArr.length}">
          <div class="panel" v-for="(item) in mediaArr" :key="item.url" @click="isClick && radioMedia(item.url)">
            <el-image :src="item.url" fit="contain" lazy></el-image>
            <div class="footer">
              <div class="text" :title="item.imgName">{{item.imgName}}</div>
              <el-button type="danger" plain @click="deleteImg(item)">删除</el-button>
            </div>
          </div>
          
          <div class="no-data" v-show="!loading && !mediaArr.length">
            <img src="@/assets/images/empty.png">
            <div>暂无图片</div>
          </div>
        </div>
        <el-pagination
          background
          layout="prev, pager, next"
          :total="mediasTotal"
          :page-size="queryParams.pageSize"
          @prev-click="prevClick"
          @next-click="nextClick"
          @current-change="currentChange"
          :current-page.sync="currentPage">
        </el-pagination>
      </div>
      <div v-show="activeName !== 'media' || mediaGet " v-loading="imgsubmitLoading">
        <el-upload v-if="activeName === 'local'" action="#" :http-request="requestUpload" :show-file-list="false"
          :before-upload="beforeUpload">
          <el-button size="small">
            选择
            <i class="el-icon-upload el-icon--right"></i>
          </el-button>
        </el-upload>
        <div class="linkAddr" v-else>
          <span>链接地址：</span><el-input v-model="outerUrl" @input="input"></el-input>
        </div>
        <!-- 裁剪框 -->
        <el-row style="margin: 10px 0; overflow: auto;min-height: 450px; max-height: 60vh;" ref="rowCropper">
          <el-col :span="24" :style="{height: Math.max(originImgHeight, 450) + 'px', width: originImgWidth + 'px', minWidth: '100%'}">
            <vue-cropper
              :canScale="false"
              :outputSize="0.9"
              :info="true"
              :full="true"
              :high="false"
              :autoCrop="true"
              :original="true"
              :autoCropWidth="options.CropWidth"
              :autoCropHeight="options.CropHeight"
              :fixed="false"
              :maxImgSize="Math.max(originImgWidth || 0, originImgHeight || 0, 2000)"
              ref="cropper"
              :img="imgUrl"
              @imgLoad="imgLoad"
              @change-crop-size="changeCrop"></vue-cropper>
          </el-col>
        </el-row>
        <el-row class="operation">
          <el-select v-show="options.originWidth" @change="selectSize" v-model="options.selectType">
            <el-option  :label="`原图${options.originWidth} * ${options.originHeight}`" value="origin"></el-option>
            <el-option  :label="`大${options.bigWidth} * ${options.bigHeight}`" value="big"></el-option>
            <el-option  :label="`中${options.normalWidth} * ${options.normalHeight}`" value="normal"></el-option>
            <el-option  :label="`缩略图${options.smallWidth} * ${options.smallHeight}`" value="small"></el-option>
            <el-option  label="自定义裁剪尺寸" value="custom"></el-option>
          </el-select>
          <!-- 裁剪框按钮组 -->
          <template v-if="options.selectType === 'custom'">
            <span style="display: inline-block; margin: 0 10px">宽: </span><el-input-number ref="CropWidth" v-model="CropWidth" @focus="isInput = true" @keydown.enter.native="changeInput('CropWidth', $event)" @blur="changeInput('CropWidth')" controls-position="right" :min="0" :max="options.maxCropWidth"></el-input-number>
            <span style="display: inline-block; margin: 0 10px">高: </span><el-input-number ref="CropHeight" v-model="CropHeight" @focus="isInput = true" @keydown.enter.native="changeInput('CropHeight', $event)" @blur="changeInput('CropHeight')" controls-position="right" :min="0" :max="options.maxCropHeight"></el-input-number>
          </template>
          <template v-if="options.selectType">
            <el-button style="margin-left:10px" icon="el-icon-plus" title="放大" size="small" @click="changeScale(1)"></el-button>
            <el-button icon="el-icon-minus" size="small" title="缩小" @click="changeScale(-1)"></el-button>
            <el-button icon="el-icon-refresh-left" size="small" title="左旋转" @click="rotateLeft"></el-button>
            <el-button icon="el-icon-refresh-right" size="small" title="右旋转" @click="rotateRight"></el-button>
            <el-checkbox style="margin-left:10px" v-model="checked">同步媒体库</el-checkbox>
            <span v-if="checked" style="margin-left:10px; display: inline-block" class="imgName-wrapper">
              <el-form ref="imgNameForm"  label-width="100px" :model="imgNameform">
                <el-form-item label="图片名称：" prop="imgName" :rules="[
                    { required: true, message: '请输入图片名称', trigger: 'blur' },
                  ]">
                  <el-input v-model.trim="imgNameform.imgName" placeholder="请输入图片名称" size="mini" style="width: 200px"></el-input>
                </el-form-item>
              </el-form>
            </span>
          </template>
        </el-row>
        <el-button type="primary" size="small" @click="uploadImg">提 交</el-button>
      </div>
    </el-dialog>

  </div>
</template>

<script>


import {VueCropper} from "vue-cropper";
import { on, off } from '@/utils/event';
import {listImgs,delImg} from "@/api/console/info/mediaImg";

export default {
  name: "editorImage",
  components: {VueCropper},
  props: {
    editorImageDialog: {
      type: Object
    }
  },
  data() {
    return {
      imgsubmitLoading: false,
      loading: false,
      activeName: 'local',
      imgUrl: null, // 图片地址
      outerUrl: '',
      originImgWidth: null, // 图片原始宽度
      originImgHeight: null, // 图片原始高度
      isInput: false,
      mediaGet: false,
      checked: false, // 是否同步媒体库
      mediasTotal: 0,
      // 裁剪框参数
      options: {
        CropWidth: 0, // 裁剪框宽度
        CropHeight: 0, // 裁剪框高度
        maxCropWidth: 1000, // 裁剪框最大宽度
        maxCropHeight: 600, // 裁剪框最大高度
        selectType: null, // 裁剪框尺寸快捷选项
        smallWidth: 150, // 缩略图尺寸(宽)
        smallHeight: 150, // 缩略图尺寸(高)
        normalWidth: 400, // 中图尺寸(宽)
        normalHeight: 0, // 中图尺寸(高)
        bigWidth: 600, // 大图尺寸(宽)
        bigHeight: 0, // 大图尺寸(高)
        originWidth: 0, // 原图尺寸(宽)
        originHeight: 0 // 原图尺寸(高)
      },
      mediaArr: [
        
      ],// 查询参数
      queryParams: {
        isLikeQuery: true,
        pageNum: 1,
        pageSize: 10,
        createTime: null,
        imgName: null
      },
      imgNameform: {
        imgName: null
      },
      isClick: true,
      currentPage : 1,
      wMaxh: true
    };
  },
  computed: {
    // 由于组件自身的监听裁剪框事件存在问题，改用计算属性做裁剪框大小和输入框的双向绑定
    // 通过isInput判断输入框的变动来源是否是手动输入，是的话，改变裁剪组件的默认裁剪框大小属性
    // 不是的话，即是通过拖拽裁剪框用于反显在输入框上，不需要二次设置裁剪框大小，不然会改变裁剪框中心点位置
    CropWidth: {
      set (val) {
        if (this.isInput) {
          this.options.CropWidth = val
        }
      },
      get () {
        return this.$refs.cropper.cropW
      }
    },
    CropHeight: {
      set (val) {
        if (this.isInput) {
          this.options.CropHeight = val
        }
      },
      get () {
        return this.$refs.cropper.cropH
      }
    }
  },
  watch: {
    activeName (val, oldVal) {
      // 切换至媒体库时，
      // 判断当前媒体库是否有数据，没有的话加载媒体库
      if (val === 'media' && !this.mediaArr.length) {
        this.queryMedias(false)
      }
      // 切换至媒体库或者由媒体库切换来的，不做重置
      if (val === 'media' || (val !== 'media' && oldVal === 'media')) {
      //
      } else {
        this.reset()
      }
    },
    'editorImageDialog.open' (val) {
      // 设置裁剪输入框可输入的最大值
      if (val) {
        this.$nextTick(() => {
          // console.warn('开启监听')
          // this.setMax()
          // this.handler(true)
        })
      } else {
        this.imgsubmitLoading = false
        // this.handler(false)
      }
    }
  },
  // mounted () {
  //   on(window, 'resize', this.setMax, true)
  // },
  methods: {
    handler (bind) {
      if (bind) {
        on(window, 'resize', this.setMax, true)
      } else {
        off(window, 'resize', this.setMax, true)
      }
    },
    // 动态限制输入框可输入的最大裁剪宽度及高度
    setMax () {
      // console.warn('11')
    },
    // 外部链接输入事件
    // 由于base64直接对裁剪框赋值在IE11下有兼容问题，判断是否为base64，是的话转blob
    async input (dataurl) {
      this.imgUrl = ''
      let img = dataurl
      try {
        if (img.startsWith('data:image')) {
          img = window.URL.createObjectURL(this.dataURLtoBlob(dataurl))
        }
        console.warn(img)
        this.imgUrl = await this.checkImgExists(img)
      } catch (err) {
        console.warn(err)
        this.msgError("文件格式错误，请上传图片类型,如：JPG，PNG后缀的文件。");
      }
    },
    // base64转blob
    dataURLtoBlob(dataurl) {
      let arr = dataurl.split(',');
      let mime = arr[0].match(/:(.*?);/)[1];
      let bstr = atob(arr[1]);
      let n = bstr.length;
      let u8arr = new Uint8Array(n);
      while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
      }
      return new Blob([u8arr], { type: mime });
    },
    // 通过输入框改变动态改变裁剪框
    changeInput (el, e) {
      if (e) {
        const keyCode = window.event? e.keyCode:e.which
        if (keyCode && keyCode === 13) {
          if (this.$refs[el].displayValue === this.$refs.cropper[el.includes('Width') ? 'cropW' : 'cropH']) return
          this.options[el] = this.$refs[el].displayValue
          this.options[el.includes('Width') ? 'CropHeight': 'CropWidth'] = this.$refs.cropper[el.includes('Width') ? 'cropH' : 'cropW']
          return
        }
      } else {
        if (this.$refs[el].displayValue === this.$refs.cropper[el.includes('Width') ? 'cropW' : 'cropH']) return
        this.options[el] = this.$refs[el].displayValue
        this.options[el.includes('Width') ? 'CropHeight': 'CropWidth'] = this.$refs.cropper[el.includes('Width') ? 'cropH' : 'cropW']
      }
    },
    // 重置裁剪框
    reset () {
      this.$refs.imgNameForm && this.$refs.imgNameForm.resetFields()
      this.checked=false
      this.imgUrl = ''
      this.outerUrl = ''
      this.mediaArr = []
      this.checked = false
      this.$refs.cropper.clearCrop()
      this.queryParams.pageNum = 1
      this.queryParams.createTime = null
      this.originImgWidth = 0
      this.originImgHeight = 0
      Object.keys(this.options).forEach(k => {
        switch (k) {
          case 'CropWidth': case 'CropHeight': case 'normalHeight': case 'bigHeight': case 'originWidth': case 'originHeight':
            this.options[k] = 0
            break
          case 'selectType':
            this.options[k] = null
            break
          default:
            break
        }
      })
    },
    // 读取图片
    checkImgExists(imgurl) {
      return new Promise((resolve, reject) => {
        const ImgObj = new Image()
        ImgObj.src = imgurl
        ImgObj.onload = (res) => {
          this.originImgWidth = ImgObj.width
          this.originImgHeight = ImgObj.height
          this.options.maxCropHeight = Math.max(ImgObj.height, 450)
          resolve(imgurl)
        }
        ImgObj.onerror = function(err) {
          console.warn('图片载入出现异常', err)
          reject(err)
        }
      })
    },
    // 打开弹出层结束时的回调
    modalclosed() {
      this.activeName = 'local';
      this.reset()
    },
    // 覆盖默认的上传行为
    requestUpload() {
    },
    // 上传预处理
    // 由于base64直接对裁剪框赋值在IE11下有兼容问题，统一将图片转blob
    beforeUpload(file) {
      if (file.type.indexOf("image/") == -1) {
        this.msgError("文件格式错误，请上传图片类型,如：JPG，PNG后缀的文件。");
      } else {
        const reader = new FileReader();
        // reader.readAsDataURL(file);
        reader.readAsArrayBuffer(file);
        reader.onload =async (e) => { // 让页面中的img标签的src指向读取的路径
        let data;
        if (typeof e.target.result === "object") {
          // 把Array Buffer转化为blob 如果是base64不需要
          data = window.URL.createObjectURL(new Blob([e.target.result]));
        } else {
          data = e.target.result;
        }
          this.imgUrl = await this.checkImgExists(data)
        }
      }
    },
    // 裁剪框读取图片后回调事件
    imgLoad () {
      console.warn(this.$refs.cropper.scale)
      this.options.CropWidth =  Math.round(this.$refs.cropper.scale * this.originImgWidth)
      this.options.CropHeight = Math.round(this.$refs.cropper.scale * this.originImgHeight)
      console.warn( this.originImgWidth,  this.originImgHeight)
      this.options.originWidth = this.options.CropWidth
      this.options.originHeight = this.options.CropHeight
      this.wMaxh = (this.originImgWidth - this.originImgHeight) > 0
      //中
      const normalRatio = parseFloat(this.options.originWidth / this.options.normalWidth);
      this.options.normalHeight = Math.min(parseInt(this.options.originHeight / normalRatio), Math.max(this.originImgHeight, 450))
      //大
      const bigRatio = parseFloat(this.options.originWidth / this.options.bigWidth);
      this.options.bigHeight = Math.min(parseInt(this.options.originHeight / bigRatio), Math.max(this.originImgHeight, 450))
      console.warn('normalRatio', normalRatio)
      console.warn('bigRatio', bigRatio)
      //默认选择
      this.options.selectType = 'origin';
    },
    // 向左旋转
    rotateLeft() {
      this.$refs.cropper.rotateLeft();
    },
    // 向右旋转
    rotateRight() {
      this.$refs.cropper.rotateRight();
    },
    // 图片缩放
    changeScale(num) {
      num = num || 1;
      this.$refs.cropper.changeScale(num);
    },
    // 这里原本应该裁剪框改变触发事件，存在bug，目前为点击裁剪框事件
     changeCrop (w, h) {
       console.log('w', w, 'h:', h)
      this.isInput = false
      this.options.selectType = 'custom'
    },
    // 上传图片
    uploadImg() {
      if (this.checked) {
        this.$refs['imgNameForm'].validate((valid) => {
          if (valid) {
            this.$refs.cropper.getCropBlob(async (data) => {
              this.imgsubmitLoading = true
              this.$emit('editImageCallback', data, 'local', +this.$refs.cropper.cropInfo.width, +this.$refs.cropper.cropInfo.height, this.imgNameform.imgName,this.checked);
            })
          } else {
            console.log('error submit!!');
            return false;
          }
        });
      } else {
        this.$refs.cropper.getCropBlob(async (data) => {
          this.imgsubmitLoading = true
          // console.warn(data)
          this.$emit('editImageCallback', data, 'local', +this.$refs.cropper.cropInfo.width, +this.$refs.cropper.cropInfo.height, this.imgNameform.imgName,this.checked);
        })        
      }
    },
    //选择尺寸
    selectSize(type, el) {
      this.isInput = true
      this.options.selectType = type;
      let nowImgLen
      if (this.wMaxh) {
        nowImgLen = this.$refs.cropper.scale * this.originImgWidth
      } else {
       nowImgLen = this.$refs.cropper.scale * this.originImgHeight
      }
      const coe = this.$refs.cropper.coe * 100
      this.$refs.rowCropper.$el.scrollLeft = parseInt((Math.max(this.$refs.rowCropper.$el.scrollWidth, this.$refs.rowCropper.$el.clientWidth)) / 2 - this.$refs.rowCropper.$el.clientWidth / 2)
      // this.$refs.cropper.refesh()
      switch (type) {
        case 'origin':
          this.$refs.cropper.clearCrop()
          this.options.CropWidth = this.options.originWidth
          this.options.CropHeight = this.options.originHeight
          this.$refs.cropper.goAutoCrop()
          this.$refs.rowCropper.$el.scrollTop = 0
          this.$refs.rowCropper.$el.scrollLeft = 0
          const originScale = (this.options[this.wMaxh ? 'originWidth' : 'originHeight'] - nowImgLen) / coe
          if (originScale) this.$refs.cropper.changeScale(originScale)
          break
        case 'big':
          this.$refs.cropper.clearCrop()
          this.options.CropWidth = this.options.bigWidth 
          this.options.CropHeight = this.options.bigHeight
          this.$refs.cropper.goAutoCrop()
          this.$refs.rowCropper.$el.scrollTop = parseInt((Math.max(this.originImgHeight, 450) - this.options.bigHeight) / 2 - 20)
          const bigScale = (this.options[this.wMaxh ? 'bigWidth' : 'bigHeight'] - nowImgLen) / coe
          if (bigScale) this.$refs.cropper.changeScale(bigScale)
          break
        case 'normal':
          this.$refs.cropper.clearCrop()
          this.options.CropWidth = this.options.normalWidth
          this.options.CropHeight = this.options.normalHeight
          this.$refs.cropper.goAutoCrop()
          this.$refs.rowCropper.$el.scrollTop = parseInt((Math.max(this.originImgHeight, 450) - this.options.normalHeight) / 2 - 20)
          const normalScale = (this.options[this.wMaxh ? 'normalWidth' : 'normalHeight'] - nowImgLen) / coe
          if (normalScale) this.$refs.cropper.changeScale(normalScale)
          break
        case 'small':
          this.$refs.cropper.clearCrop()
          this.options.CropWidth = this.options.smallWidth
          this.options.CropHeight = this.options.smallHeight
          this.$refs.cropper.goAutoCrop()
          this.$refs.rowCropper.$el.scrollTop = parseInt((Math.max(this.originImgHeight, 450) - this.options.smallHeight) / 2 - 20)
          const smallScale = (this.options[this.wMaxh ? 'smallWidth' : 'smallHeight'] - nowImgLen) / coe
          if (smallScale) this.$refs.cropper.changeScale(smallScale)
          break
        case 'default':
          break
      }
    },
    queryMedias (flag) {
      if(flag){
        this.queryParams.pageNum = 1
      }
      this.loading = true
      if (this.queryParams.pageNum === 1) {
        this.$nextTick(() => {
          const mediaContainerWidth = this.$refs.mediaContainer.clientWidth
          const mediaContainerHeight = this.$refs.mediaContainer.clientHeight
          const mediaContainerVolume = mediaContainerWidth * mediaContainerHeight
          this.queryParams.pageSize = parseInt(mediaContainerVolume / (180 * 180))
          listImgs(this.queryParams).then(res => {
            this.loading = false
            this.mediaArr = res.rows
            this.mediasTotal = res.total
            this.currentPage = this.queryParams.pageNum
          }).catch(err => {
            console.warn(err)
            this.loading = false
            this.$message.error('接口请求异常');
          })
        })
      } else {
        listImgs(this.queryParams).then(res => {
          this.loading = false
          this.mediaArr = res.rows
          this.mediasTotal = res.total
          this.currentPage = this.queryParams.pageNum
        }).catch(err => {
          console.warn(err)
          this.loading = false
          this.$message.error('接口请求异常');
        })
      }
    },
    prevClick (val) {
      this.queryParams.pageNum = val;
      this.currentPage = val;
      this.queryMedias(false)
    },
    nextClick (val) {
      this.queryParams.pageNum = val;
      this.currentPage = val;
      this.queryMedias(false)
    },
    currentChange(page) {
      this.queryParams.pageNum = page;
      this.currentPage = page;
      this.queryMedias(false)
    },
    resetSeaech(){
      this.queryParams.createTime = null;
      this.queryParams.imgName = null;
      this.queryMedias(true)
    },
    // 选择媒体库图片事件
    radioMedia (val) {
      this.input(val)
      this.outerUrl = val
      this.activeName = 'outer'
    },
    // 同步到媒体库
    deleteImg(item) {
      this.isClick = false
      console.log(item.id)
      this.$confirm('即将删除“'+item.imgName+'”, 此操作将永久删除该图片, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
        center: true
      }).then(() => {
        delImg(item.id).then(res => {
          console.log(res);
          if(200 === res.code){
            this.$message({
              type: 'success',
              message: '删除成功!'
            });
            this.queryMedias()
          }else{
            this.$message({
            type: 'error',
            message: '删除失败!'
          });
          }
        });
        this.isClick = true
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除'
        });
         this.isClick = true
      });
     
    }
  }
};
</script>
<style lang="scss" scoped>
.media-wrapper{
  height: 542px;
  display: flex;
  flex-direction: column;
}
.media-container{
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  padding: 0 50px;
  overflow-y: auto;
  .panel{
    margin: 40px 10px 0;
    border: 1px solid #ccc;
    border-radius: 4px;
    width: 180px;
    height: 180px;
    text-align: center;
    cursor: pointer;
    .el-image{
      height: 130px;
      width: 130px;
      // padding: 0 10px;
      // box-sizing: border-box;
    }
    .footer{
      padding: 6px 10px;
      border-top: 1px solid #ccc;
      box-sizing: border-box;
      display: flex;
      align-items: center;
      justify-content: space-between;
      .text{
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        text-align: left;
        font-size: 13px;
      }
      .el-button{
        margin-left: 10px;
      }
    }
  }
  +div{
    text-align: right;
  }
  .no-data{
    text-align: center;
  }
  &.empty{
    justify-content: center;
    align-content: center;
    align-items: center;
  }
}
.cropper-image-dg ::v-deep .el-dialog{
  min-width: 800px;
}
.operation{
  margin: 6px 0 8px;
}
.cropper-image-dg .el-dialog__body {
  padding: 0px 20px 20px 20px !important;
}
.header{
  border-bottom: 1px solid #e4e7ed;
  margin-bottom: 10px;
}
.bottom-border{
  overflow: hidden;
  margin-bottom: -1px;
  position: relative;
}
.cropper-image-dg ::v-deep .el-radio{
  margin: 0!important;
  border-radius: 3px 3px 0 0;
  border-color: #e4e7ed;
  &.is-checked{
    border-bottom: 1px solid #fff;
  }
  .el-radio__label{
    font-size: 14px;
  }
}
.linkAddr{
  display: flex;
  align-items: center;
  padding: 2px 0;
  >span{
    +div{
      flex: 1;
    }
  }
}
.imgNameShow{
  margin-top: 15px;
  // text-align: center;
  width:130px;
  white-space: nowrap;
  text-overflow:ellipsis;
   overflow:hidden;
   float: left;
}

.form-wrapper{
  display: flex;
}

.imgName-wrapper ::v-deep .el-form-item{
  margin-bottom: 0!important;
}

</style>
