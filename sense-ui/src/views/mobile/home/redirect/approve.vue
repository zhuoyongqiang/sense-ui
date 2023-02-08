<template>
  <div class="wrapper"></div>
</template>
<script>
  import closeWindow from '@/mixins/closeWindow'
  import {getMobileBuildssolink} from "@/api/console/bpm/workflow";
  import {getToken} from "@/utils/auth";
  export default {
    name: "mobileapproveredirect",
    mixins: [closeWindow],
    data() {
      return {
        taskId: undefined,
        openMethods: ''
      }
    },
    created() {
      if (this.isUserLogin) {
        this.taskId = this.$route.params.taskId
        if(this.taskId){
          getMobileBuildssolink(1, this.taskId).then(response => {
            if(response.code===200){
              //location.href = response.msg;
              location.replace(response.msg)
            }else{
              this.msgWarning(response.msg)
              const timer = setTimeout(() => {
                clearTimeout(timer)
                this.closeWindow()
              }, 1000);
            }
          })
        }else {
          this.msgWarning("参数缺失");
          const timer = setTimeout(() => {
            clearTimeout(timer)
            this.closeWindow()
          }, 1000);
        }
      } else {
        this.msgWarning("未经授权，禁止访问");
        const timer = setTimeout(() => {
          clearTimeout(timer)
          this.closeWindow()
        }, 1000);
      }
    },
    computed: {
      isUserLogin() {
        if (getToken()) {
          return true;
        }
        return false;
      }
    },
    methods: {
    }
  }
</script>
