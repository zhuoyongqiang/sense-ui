<template>
  <div>
    <el-table
      :data="taskData"
      :span-method="objectSpanMethod"
      style="width: 100%">
      <el-table-column label="序号" align="center" width="50" :formatter="indexFormat"></el-table-column>
      <el-table-column label="任务名称" align="center" prop="taskName"></el-table-column>
      <el-table-column label="姓名" align="center" prop="nickName" width="80" :formatter="nickNameFormat"></el-table-column>
      <el-table-column label="结果" align="center" prop="status" width="60" :formatter="bpmProcessStatusFormat"></el-table-column>
      <el-table-column label="意见" align="center" prop="remark" :formatter="remarkFormat"></el-table-column>
      <el-table-column label="到达时间" align="center" prop="createTime" width="140"></el-table-column>
      <el-table-column label="完成时间" align="center" prop="endTime" width="140"></el-table-column>
      <el-table-column label="历时" align="center" prop="duration" :formatter="durationFormat"></el-table-column>
    </el-table>
  </div>
</template>

<script>
export default {
  name: "statusProcess",
  props: ['taskData'],
  data() {
    return {
      bpmProcessStatusOptions: [],
      spanArr: {}
    }
  },
  watch: {
    'taskData': function () {
      let nodeData = {};
      for (let i in this.taskData) {
        let modelNode = this.taskData[i].modelNode;
        if (!nodeData[modelNode]) {
          nodeData[modelNode] = 1;
        } else {
          nodeData[modelNode] = nodeData[modelNode] + 1;
        }
      }
      let rowIndex = 0;
      for (let key in nodeData) {
        let len = nodeData[key];
        if (len > 1) {
          this.spanArr[key] = {};
          this.spanArr[key].startRowIndex = rowIndex;
          this.spanArr[key].rowNum = len;
        }
        rowIndex += len;
      }
      console.log(this.spanArr)
    }
  },
  created() {
    this.getDicts("bpm_process_status").then(response => {
      this.bpmProcessStatusOptions = response.data;
    });
  },
  methods: {
    // 岗位状态字典翻译
    bpmProcessStatusFormat(row, column) {
      if (row.status == '' || row.status == undefined || row.status == null) {
        return '—';
      }else if(row.status == 2){
        return '通过';
      }

      else {
        return this.selectDictLabel(this.bpmProcessStatusOptions, row.status);
      }
    },
    //姓名翻译
    nickNameFormat(row, column) {
      if (row.nickName == '' || !row.nickName) {
        return '—';
      }
      return row.nickName;
    },
    //意见翻译
    remarkFormat(row, column) {
      if (row.remark == '' || !row.remark) {
        return '—';
      }
      return row.remark;
    },
    //历史翻译
    durationFormat(row, column) {
      if (row.duration == '' || !row.duration) {
        return '—';
      }
      return row.duration;
    },
    //索引翻译
    indexFormat(row, column) {
      if (row.modelNode == 'DIVIDING') {
        return '以下是新的一轮审批';
      } else {
        return row.rowIndex;
      }
    },
    //单元格合并
    objectSpanMethod({row, column, rowIndex, columnIndex}) {
      if (row.modelNode == 'DIVIDING') {
        return {
          rowspan: 1,
          colspan: 8
        }
      } else {
        if ((columnIndex === 0 || columnIndex === 1)) {
          for (let key in this.spanArr) {
            if (rowIndex === this.spanArr[key].startRowIndex) {
              return {
                rowspan: this.spanArr[key].rowNum,
                colspan: 1
              }
            } else if (rowIndex > this.spanArr[key].startRowIndex && rowIndex < (this.spanArr[key].startRowIndex + this.spanArr[key].rowNum)) {
              return {
                rowspan: 0,
                colspan: 0
              }
            }
          }
        }
      }
    }
  }
}
</script>

<style scoped>

</style>
