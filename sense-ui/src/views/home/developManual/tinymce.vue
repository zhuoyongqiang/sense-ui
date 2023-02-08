<template>
  <div class="tinymce-box">
    <editor v-model="myValue"
            :init="init"
            :disabled="disabled"
            @onClick="onClick">
    </editor>
    <el-upload
      style="position: absolute; top: 0;left: 10px; z-index: 10; opacity: 0; width: 40px; height: 40px;overflow: hidden"
      :action="uploadSetting.url"
      :headers="uploadSetting.headers"
      :data="{isSave:true,type:'file'}"
      :on-success="handleAttachmentSuccess"
      :before-upload="beforeAttachmentUpload"
      :on-remove="handleAttachmentRemove"
      :file-list="fileList">
      <el-button size="small" type="primary">附件上传</el-button>
    </el-upload>
    <editor-image @editImageCallback="editImageCallback" :editorImageDialog.sync="editorImageDialogObj" :close-on-click-modal="false"></editor-image>
  </div>
</template>

<script>
import tinymce from "tinymce/tinymce";
import Editor from "@tinymce/tinymce-vue";
import "tinymce/themes/silver";
import "tinymce/icons/default";
import "tinymce/plugins/image";// 插入上传图片插件
import "tinymce/plugins/media";// 插入视频插件
import "tinymce/plugins/table";// 插入表格插件
import "tinymce/plugins/lists";// 列表插件
import "tinymce/plugins/advlist";// 列表插件
import "tinymce/plugins/code";//代码
import "tinymce/plugins/codesample";//代码
import "tinymce/plugins/hr";
import "tinymce/plugins/wordcount";
import "tinymce/plugins/fullscreen";
import "tinymce/plugins/pagebreak";
import "tinymce/plugins/link";
import "tinymce/plugins/charmap";
// import "tinymce/plugins/emoticons";
import "tinymce/plugins/insertdatetime";
import "tinymce/plugins/nonbreaking";
import "tinymce/plugins/preview";
import "tinymce/plugins/searchreplace";
import EditorImage from "@/views/console/info/news/editorImage";
import {addImg} from "@/api/console/info/mediaImg";
import {uploadFile} from "@/api/common";
import {getToken} from "@/utils/auth";

export default {
  components: {
    Editor, EditorImage
  },
  name: 'tinymce',
  props: {
    height: {
      type: Number,
      default: 300
    },
    value: {
      type: String,
      default: ''
    },
    disabled: {
      type: Boolean,
      default: false
    },
    imagesUploadHandler: {
      type: Function,
      default: function (data, success) {
      }
    },
    plugins: {
      type: [String, Array],
      default: 'code searchreplace preview nonbreaking insertdatetime media table wordcount editorImage  charmap hr fullscreen pagebreak lists advlist indent2em'
    },
    toolbar: {
      type: [String, Array],
      default: 'code undo redo |  formatselect  | fontselect | fontsizeselect | bold italic forecolor backcolor underline strikethrough subscript superscript | searchreplace preview nonbreaking insertdatetime | indent2em blockquote | alignleft aligncenter alignright alignjustify bullist numlist | editorImage  media link unlink  table  | hr pagebreak | charmap lineheight fullscreen '
    }
  },
  data() {
    return {
      baseFilePath: undefined,
      fileList: [],
      init: {
        language_url: '/tinymce/langs/zh_CN.js',
        language: 'zh_CN',
        skin_url: '/tinymce/skins/ui/oxide',
        content_css: '/tinymce/skins/content/default/content.css',
        height: this.height,
        plugins: this.plugins,
        toolbar1: this.toolbar,
        branding: false,
        menubar: false,
        convert_urls: false,//不转换路径
        // emoticons_database_url: '/tinymce/emojis.js',
        font_formats: `
          微软雅黑=微软雅黑;
          宋体=宋体;
          黑体=黑体;
          仿宋=仿宋;
          楷体=楷体;
          隶书=隶书;
          幼圆=幼圆;
          Andale Mono=andale mono,times;
          Arial=arial, helvetica,
          sans-serif;
          Arial Black=arial black, avant garde;
          Book Antiqua=book antiqua,palatino;
          Comic Sans MS=comic sans ms,sans-serif;
          Courier New=courier new,courier;
          Georgia=georgia,palatino;
          Helvetica=helvetica;
          Impact=impact,chicago;
          Symbol=symbol;
          Tahoma=tahoma,arial,helvetica,sans-serif;
          Terminal=terminal,monaco;
          Times New Roman=times new roman,times;
          Trebuchet MS=trebuchet ms,geneva;
          Verdana=verdana,geneva;
          Webdings=webdings;
          Wingdings=wingdings,zapf dingbats`,
          codesample_languages: [
            {text: 'HTML/XML', value: 'markup line-numbers'},
            {text: 'JavaScript', value: 'javascript line-numbers'},
            {text: 'CSS', value: 'css line-numbers'},
            {text: 'PHP', value: 'php line-numbers'},
          ],
          codesample_content_css: '/tinyprism.css',
          setup: function (editor) {
            editor.on('init', function (e) {
                this.getBody().style.fontSize = '14pt';
                this.getBody().style.fontFamily = '微软雅黑';
            })
          }
      },
      
      myValue: this.value,
      editorImageDialogObj: {
        open: false,
        photoWidth: 100,
        photoHeight: 100
      },
      // 上传参数
      uploadSetting: {
        // 设置上传的请求头部
        headers: {Authorization: "Bearer " + getToken()},
        // 上传的地址
        url: process.env.VUE_APP_BASE_API + "/common/upload"
      },
      fileList: []
    }
  },
  created() {
    let self = this;
    this.getConfigKey('base_file_path').then(response => {
      this.baseFilePath = response.msg;
    });
    tinymce.PluginManager.add('editorImage', function (editor, url) {
      // 注册一个工具栏按钮名称
      editor.ui.registry.addButton('editorImage', {
        icon: 'image',
        onAction: function () {
          self.editorImageDialogObj.open = true;
        }
      });
    });

    tinymce.PluginManager.add('uploadFile', function (editor, url) {
      // 注册一个工具栏按钮名称
      editor.ui.registry.addButton('uploadFile', {
        icon: 'upload',
        onAction: function () {
          // self.editorImageDialogObj.open = true;
          console.log('11')
        }
      });
    });

    tinymce.PluginManager.add('indent2em', function (editor, url) {
      var pluginName = '首行缩进';
      var global$1 = tinymce.util.Tools.resolve('tinymce.util.Tools');
      var indent2em_val = editor.getParam('indent2em_val', '2em');
      var doAct = function () {
        var dom = editor.dom;
        var blocks = editor.selection.getSelectedBlocks();
        var act = '';
        global$1.each(blocks, function (block) {
          if (act == '') {
            act = dom.getStyle(block, 'text-indent') == indent2em_val ? 'remove' : 'add';
          }
          if (act == 'add') {
            dom.setStyle(block, 'text-indent', indent2em_val);
          } else {
            var style = dom.getAttrib(block, 'style');
            var reg = new RegExp('text-indent:[\\s]*' + indent2em_val + ';', 'ig');
            style = style.replace(reg, '');
            dom.setAttrib(block, 'style', style);
          }

        });
      };

      editor.ui.registry.getAll().icons.indent2em || editor.ui.registry.addIcon('indent2em', '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" width="24" height="24"><path d="M170.666667 563.2v-102.4H887.466667v102.4zM170.666667 836.266667v-102.4H887.466667v102.4zM512 290.133333v-102.4H887.466667v102.4zM238.933333 341.333333V136.533333l204.8 102.4z" fill="#2c2c2c" p-id="5210"></path></svg>');

      var stateSelectorAdapter = function (editor, selector) {
        return function (buttonApi) {
          return editor.selection.selectorChangedWithUnbind(selector.join(','), buttonApi.setActive).unbind;
        };
      };

      editor.ui.registry.addToggleButton('indent2em', {
        icon: 'indent2em',
        tooltip: pluginName,
        onAction: function () {
          doAct();
        },
        onSetup: stateSelectorAdapter(editor, [
          '*[style*="text-indent"]',
          '*[data-mce-style*="text-indent"]',
        ])
      });

      editor.ui.registry.addMenuItem('indent2em', {
        text: pluginName,
        onAction: function () {
          doAct();
        }
      });

      editor.addCommand('indent2em', doAct);

      return {
        getMetadata: function () {
          return {
            name: pluginName,
            url: "http://tinymce.ax-z.cn/more-plugins/indent2em.php",
          };
        }
      };
    });
  },
  mounted() {
    tinymce.init({})
  },
  methods: {
    // 添加相关的事件，可用的事件参照文档=> https://github.com/tinymce/tinymce-vue => All available events
    // 需要什么事件可以自己增加
    onClick(e) {
      this.$emit('onClick', e, tinymce)
    },
    /**获取对象*/
    getActiveEditor() {
      return tinymce.activeEditor;
    },
    // 可以添加一些自己的自定义事件，如清空内容
    clear() {
      this.myValue = ''
    },
    editImageCallback(data, type, width, height, imgName,isSync) {
      console.log(data, type, width, height,imgName)
      let self = this;
      if (type == 'local') {
        this.imagesUploadHandler(data, function (url) {
          let imageStr = '<img src="' + url + '" width="' + width + '" height="' + height + '"/>';
          self.getActiveEditor().insertContent(imageStr);
          self.editorImageDialogObj.open = false;
          if(isSync){
            let obj = {"imgName":imgName,"url":url,"size":data.size,"height":height,"width":width};
            addImg(obj)
          }
        })
      } else if (type == 'outer') {
        let imageStr = '<img src="' + data + '" width="' + width + '" height="' + height + '"/>';
        this.getActiveEditor().insertContent(imageStr);
        self.editorImageDialogObj.open = false;
      }
      else if (type == 'upload') {
        let imageStr = '<img src="' + this.baseFilePath+data + '"/>';
        this.getActiveEditor().insertContent(imageStr);
        self.editorImageDialogObj.open = false;
      }
    },
    /**附件上传成功的回调函数*/
    handleAttachmentSuccess(res, file, fileList) {
      if (res.code == 200) {
        let obj = {};
        obj.id = res.data.id;
        obj.name = res.data.attachmentTitle;
        obj.url = this.baseFilePath + res.data.attachmentUrl;
        this.fileList.push(obj);
        let file = '<a href="' + this.baseFilePath+data + 'download">' + obj.name + '</a>';
        this.getActiveEditor().insertContent(file);
      }else{
        let _tmp = this.fileList;
        _tmp.splice(_tmp.length, 1);
        this.fileList = _tmp;
        this.msgError(res.msg)
      }
    },
    /**附件上传前的回调函数*/
    beforeAttachmentUpload(file) {
      console.log('file', file)
      let obj = '<a href="https://www.swiper.com.cn/download/swiper-6.7.5.zip" download>' + file.name + '</a>';
      this.getActiveEditor().insertContent(obj);
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
    }
  },
  watch: {
    value(newValue) {
      this.myValue = newValue
    }
    ,
    myValue(newValue) {
      this.$emit('input', newValue)
    }
  }
}

</script>
<style scoped>
  .tinymce-box{
    position: relative;
  }
</style>
