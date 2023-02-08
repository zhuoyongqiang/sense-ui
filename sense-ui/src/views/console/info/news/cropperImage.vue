<template>
  <div>
    <el-dialog class="cropper-image-dg" title="裁剪图片" :visible.sync="cropperImageDialog.open" width="90%"
               @opened="modalOpened" append-to-body>
      <el-row>
        <el-col :xs="24" :md="24" :style="{height: '500px'}">
          <vue-cropper
            ref="cropper"
            :img="options.img"
            :info="true"
            :outputSize="1"
            :canScale="true"
            :full="true"
            :original="true"
            :autoCrop="options.autoCrop"
            :autoCropWidth="pixelWidth"
            :autoCropHeight="pixelHeight"
            :fixedBox="options.fixedBox"
            v-if="visible"
          />
        </el-col>
      </el-row>
      <el-row style="margin-top:8px;">
        <div style="display: inline-block;margin-right:20px;">
          <el-input v-model="pixelWidth" style="width:80px"/>
          <span> * </span>
          <el-input v-model="pixelHeight" style="width:80px"/>
        </div>
        <div style="display: inline-block;margin-right:20px;">
          <el-button icon="el-icon-plus" size="small" @click="changeScale(1)"></el-button>
        </div>
        <div style="display: inline-block;margin-right:20px;">
          <el-button icon="el-icon-minus" size="small" @click="changeScale(-1)"></el-button>
        </div>
        <div style="display: inline-block;margin-right:20px;">
          <el-button icon="el-icon-refresh-left" size="small" @click="rotateLeft()"></el-button>
        </div>
        <div style="display: inline-block;margin-right:20px;">
          <el-button icon="el-icon-refresh-right" size="small" @click="rotateRight()"></el-button>
        </div>
      </el-row>
      <br/>
      <div>

        <div style="display: inline-block;margin-right:20px;">

            <input type="file" ref="uploads" id="uploads" accept="image/png, image/jpeg, image/gif, image/jpg" @change="setImage($event, 1)" value="选择图片" />
        </div>
        <div style="display: inline-block;margin-right:20px;">
          <el-button type="primary" size="small" @click="uploadImg()">提 交</el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>

import {VueCropper} from "vue-cropper";
import axios from "axios";
import {getToken} from "@/utils/auth";

export default {
  name: "cropperImage",
  components: {VueCropper},
  props: {
    cropperImageDialog: {
      type: Object
    },
    baseFilePath: {
      type: String
    }
  },
  data() {
    return {
      activeName: 'first',
      // 是否显示cropper
      visible: false,
      options: {
        img: null, //裁剪图片的地址
        autoCrop: true, // 是否默认生成截图框
        fixedBox: true // 固定截图框大小 不允许改变
      },
      //像素宽
      pixelWidth: 0,
      //像素高
      pixelHeight: 0
    };
  },
  methods: {
    setImage(e, num) {
      var file = e.target.files[0]
      this.fileUpload = file
      if(e.target.value===''){
        return ;
      }
      if (!/\.(gif|jpg|jpeg|png|bmp|GIF|JPG|PNG)$/.test(e.target.value)) {
        this.options.img = ''
        this.$message.warning("只允许选择gif|jpg|jpeg|png|bmp|GIF|JPG|PNG格式")
        return false
      }
      var reader = new FileReader();
      reader.onload = (e) => {
        let data;
        if (typeof e.target.result === 'object') {
          // 把Array Buffer转化为blob 如果是base64不需要
          data = window.URL.createObjectURL(new Blob([e.target.result]))
        } else {
          data = e.target.result
        }
        if (num === 1) {
          this.options.img = data
        }
        this.$refs['uploads'].value = ''
      }
      // 转化为base64
      // reader.readAsDataURL(file)
      // 转化为blob
      reader.readAsArrayBuffer(file)
    },

    // 打开弹出层结束时的回调
    modalOpened() {
      this.options.img = null;
      if (this.cropperImageDialog.img) {
        this.options.img = this.cropperImageDialog.img;
      }
      this.visible = true;
      console.log(this.cropperImageDialog)
      if(this.cropperImageDialog){
         if(this.cropperImageDialog.photoWidth){
           this.pixelWidth = this.cropperImageDialog.photoWidth;
         }else{
           this.pixelWidth = 640;
         }
         if(this.cropperImageDialog.photoHeight){
            this.pixelHeight = this.cropperImageDialog.photoHeight;
         }else{
            this.pixelHeight = 320;
         }
      }else{
        this.pixelWidth = 640;
        this.pixelHeight = 320;
      }
      // 不清楚之前的逻辑如何，这里强行将所有封面裁剪的尺寸修改为符合微信合适尺寸640 X 320
      this.pixelWidth = 640;
      this.pixelHeight = 320;
    },
    // 覆盖默认的上传行为
    requestUpload() {
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
    isIE() {
      var userAgent = navigator.userAgent; //取得浏览器的userAgent字符串
      const isIE = !!window.ActiveXObject || 'ActiveXObject' in window; //判断是否IE浏览器
      return isIE;
    },
    // 上传预处理
    beforeUpload(file) {
      if (file.type.indexOf("image/") == -1) {
        this.msgError("文件格式错误，请上传图片类型,如：JPG，PNG后缀的文件。");
      } else {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = (e) => {
          this.$nextTick(function () {
            let data;
            if (typeof e.target.result === 'object') {
              // 把Array Buffer转化为blob 如果是base64不需要
              data = window.URL.createObjectURL(new Blob([e.target.result]))
            } else {
              data = e.target.result
            }
            this.options.img = data
            if (this.pixelWidth == 0 || this.pixelHeight == 0) {
              let img = new Image();
              img.src = data;
              if (img.complete) { // 如果存在浏览器缓存中
                this.pixelWidth = img.width;
                this.pixelHeight = img.height;
              } else {
                img.onload = () => {
                  this.pixelWidth = img.width;
                  this.pixelHeight = img.height;
                }
              }
            }
          })
        };
      }
    },
    // 上传图片
    uploadImg() {
      let self = this;
      if (self.options.img) {
        this.$refs.cropper.getCropBlob(data => {
          self.$emit('cropperImageCallback', data, this.pixelWidth, this.pixelHeight);
        });
      } else {
        this.msgInfo("未选择任何图片");
      }
    }
  }
};
</script>
<style lang="scss">
.user-info-head {
  position: relative;
  display: inline-block;
  height: 120px;
}

.user-info-head:hover:after {
  content: '+';
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  color: #eee;
  background: rgba(0, 0, 0, 0.5);
  font-size: 24px;
  font-style: normal;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  cursor: pointer;
  line-height: 110px;
  border-radius: 50%;
}

.upload-preview {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  overflow: hidden;
}

.cropper-image-dg .el-dialog__body {
  padding: 0px 20px 20px 20px !important;
}

.ratio-cropper {
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  user-select: none;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  direction: ltr;
  touch-action: none;
  text-align: center;
  background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAAA3NCSVQICAjb4U/gAAAABlBMVEXMzMz////TjRV2AAAACXBIWXMAAArrAAAK6wGCiw1aAAAAHHRFWHRTb2Z0d2FyZQBBZG9iZSBGaXJld29ya3MgQ1M26LyyjAAAABFJREFUCJlj+M/AgBVhF/0PAH6/D/HkDxOGAAAAAElFTkSuQmCC");
}

.ratio-cropper-box {
  overflow: hidden;
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  user-select: none;
}

.ratio-cropper-box img {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.ratio-preview {
  width: 100%;
  height: 100%;
}

.ratio-preview img {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.el-tabs__nav-scroll {
  padding: 0px;
}
</style>
