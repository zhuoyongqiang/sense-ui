<template>
  <div class="step">
    <div :style="{height: flowImageHeight,marginTop:'15px'}">
      <el-steps direction="vertical" :active="currentNodeIndex">
        <el-step v-for="(item, index) in modelNodeList" :key="index" :title="item.taskName"
                 :description="nickNameList[item.node]"></el-step>
      </el-steps>
    </div>
  </div>
</template>

<script>
import {resolveNodeUser} from '@/api/console/bpm/model'

export default {
  name: "stepProcess",
  props: ['flowImageHeight', 'currentNodeIndex', 'modelNodeList', 'instanceId', 'bpmNewsInstance'],
  data() {
    return {
      nickNameList: {}
    }
  },
  watch: {
    'modelNodeList': function () {
      for (let i in this.modelNodeList) {
        let node = this.modelNodeList[i].node;
        if (node == 'START') {
          this.$set(this.nickNameList, node, this.bpmNewsInstance.startNickName);
        } else {
          resolveNodeUser(node, this.instanceId).then(res => {
            if (res.code == 200) {
              let str = '';
              for (let i = 0; i < res.data.length; i++) {
                str += res.data[i];
                if (i != res.data.length - 1) {
                  str += ' / ';
                }
              }
              this.$set(this.nickNameList, node, str);
            }
          });
        }
      }
    }
  }
}
</script>

<style scoped>
/*流程图*/
.step ::v-deep .el-step.is-vertical .el-step__main {
  max-width: 220px;
  margin-left: 10px;
  width: 220px;
  height: 60px;
  border-radius: 4px;
  border: 1px solid #D9D9D9;
  padding: 0;
  text-align: center;
  margin-bottom: 40px;
  margin-top: -15px;
}

.step ::v-deep .el-step.is-vertical .is-finish ~ .el-step__main {
  border: 1px solid #00BE84;
}

.step ::v-deep .el-step.is-vertical .el-step__title {
  background: #D9D9D9;
  padding: 0;
  height: 30px;
  line-height: 30px;
  font-size: 14px;
  font-weight: 500;
  color: #333333;
}

.step ::v-deep .el-step.is-vertical .is-finish ~ .el-step__main .el-step__title {
  background: rgba(0, 190, 132, 0.1);
}

.step ::v-deep .el-step.is-vertical .is-process ~ .el-step__main {
  border: 1px solid #2272DE;
}

.step ::v-deep .el-step.is-vertical .is-process ~ .el-step__main .el-step__title {
  color: #ffffff;
  background: #2272DE;
}

.step ::v-deep .el-step__description {
  font-size: 14px;
  font-weight: 500;
  color: #333333;
  height: 28px;
  line-height: 28px;
  margin: 0;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  padding: 0 6px;
}

.step ::v-deep .el-step__head.is-finish {
  color: #01be84;
}

.step ::v-deep .el-step__head.is-finish {
  color: #01be84;
  border-color: #01be84;
}

.step ::v-deep .el-step__head.is-process {
  color: #2372de;
  border-color: #2372de;
}
</style>
