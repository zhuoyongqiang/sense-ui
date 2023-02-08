<template>
  <div class="detail-container">
    <div class="container">
      <div v-show="loading" class="well loading">正在加载中，请耐心等待...</div>
      <div v-show="!loading" class="well" ref="output" @contextmenu="handleMouse" ></div>
    </div>
  </div>

</template>
<script>
  import {getFilePath} from "@/api/common";
  import { getExtend, readBuffer, render } from "./components/util";
  export default {
    name: "previewDrawer",
    props: ["form", "popTitle"],
    data() {
      return {
      // 加载状态跟踪
      loading: false,
      }
    },
    watch: {
    form: {
      handler() {
        this.refreshItems();
      },
      deep: true,
    },
  },
    mounted() {

    },
   async created() {
    await this.refreshItems();
  },
    methods: {
    handleMouse(e) {
      e.preventDefault();
    },
      async refreshItems() {
        this.loading = true;
        // console.log('form:',this.form)
        let res = await getFilePath({filePath:this.form.url,fileName:this.form.name})
        // console.log('res:',res)
        // console.log('res.type:',res.type)
        // const [file] = e.target.files;
        // console.log('file:',file)
        var file = new File([res], this.form.name,{type:res.ty});
        // console.log('file:',file)
        const arrayBuffer = await readBuffer(file);
        this.loading = false;
        this.last = await this.displayResult(arrayBuffer, file);
        // console.log('this.last:',this.last)
      },
      displayResult(buffer, file) {
      // 取得文件名
      const { name } = file;
      // console.log('name:',name)
      // 取得扩展名
      const extend = getExtend(name).toLowerCase();
      // console.log('extend:',extend)
      // 输出目的地
      const { output } = this.$refs;
      // 生成新的dom
      const node = document.createElement("div");
      node.style="display: flex;justify-content: center;align-items: center;"
      // 添加孩子，防止vue实例替换dom元素
      if (this.last) {
        output.removeChild(this.last.$el);
        this.last.$destroy();
      }
      const child = output.appendChild(node);
      // 调用渲染方法进行渲染
      return new Promise((resolve, reject) =>
        render(buffer, extend, child).then(resolve).catch(reject)
      );
    },
    }
  }
</script>
<style scoped>
.detail-container{
  margin: 0px;
  padding: 0px;
}
.well {
  display: block;
  background-color: #f2f2f2;
  border: 1px solid #ccc;
  margin: 5px;
  width: calc(100% - 12px);
  height: calc(100vh - 73px);
  overflow: auto;
}

.loading {
  text-align: center;
  padding-top: 50px;
}

.messages .warning {
  color: #cc6600;
}
</style>

<style>
.pptx-wrapper {
  max-width: 1000px;
  margin: 0 auto;
}
</style>
