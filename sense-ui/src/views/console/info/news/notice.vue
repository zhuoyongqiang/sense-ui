<template>
  <el-dialog
    top="4vh!important"
    :title="'消息推送' + (data.newsTitle && (' | ' + data.newsTitle))"
    :visible.sync="data.show"
    width="80%">
    <el-form :inline="true" :model="formInline" class="demo-form-inline">
      <el-form-item label="消息id">
        <el-input v-model="formInline.msgId" placeholder="请输入" clearable></el-input>
      </el-form-item>
      <el-form-item label="任务id">
        <el-input v-model="formInline.jobId" placeholder="请输入" clearable></el-input>
      </el-form-item>
      <el-form-item label="用户对象">
        <el-input v-model="formInline.userName" placeholder="请输入" clearable></el-input>
      </el-form-item>
      <el-form-item label="状态">
        <el-select ref="select" v-model="formInline.status" placeholder="请选择" clearable @keydown.native="$refs.select.blur()">
          <el-option label="已发送" value="1"></el-option>
          <el-option label="无效" value="2"></el-option>
          <el-option label="已撤回" value="3"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSearch">查询</el-button>
      </el-form-item>
    </el-form>
    <el-row class="operation" v-show="noticeData && noticeData.length">
      <el-button type="primary" :disabled="!multipleSelection.length" @click="handleRevoke">撤回</el-button>
      <el-button type="danger" :disabled="!multipleSelection.length" @click="handleDelete">删除</el-button>
      <el-button type="warning" @click="remokeAll">全量撤回</el-button>
    </el-row>
    <el-table v-loading="loading" :data="noticeData" @selection-change="handleSelectionChange" :cell-class-name="cellClass" @cell-click="cellClick">
      <el-table-column
        type="selection"
        width="55">
      </el-table-column>
      <!-- <el-table-column prop="newsTitle" show-overflow-tooltip label="标题"></el-table-column> -->
      <el-table-column prop="msgId" show-overflow-tooltip label="消息id"></el-table-column>
      <el-table-column prop="jobId" show-overflow-tooltip label="任务id"></el-table-column>
      <el-table-column prop="userName" show-overflow-tooltip label="用户对象"></el-table-column>
      <el-table-column prop="createTime" label="记录时间" :formatter="formatterDate" width="140"></el-table-column>
      <el-table-column prop="revokeTime" label="撤销时间" :formatter="formatterDate" width="140"></el-table-column>
      <el-table-column prop="status" label="状态" :formatter="formatterStatus" width="80"></el-table-column>
        <el-table-column label="操作" width="150">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="primary"
            @click="handleRevoke(scope.row)"
            :disabled="scope.row.status !== 1">撤回</el-button>
          <el-button
            size="mini"
            type="danger"
            @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="onLoad"
    />
  </el-dialog>
</template>
<script>
import {
  noticeOfnews, // 消息列表
  revokeMsgByIds, // 批量撤回
  revokeMsgByNewsId, // 全量撤回
  deleteMsg, // 删除消息
  } from "@/api/console/info/news";
export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      formInline: {
        msgId: '', // 消息ID
        jobId: '', // 任务ID
        status: '', // 状态
        userName: '' // 用户对象
      },
      loading: false,
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10
      },
      noticeData: [],
      multipleSelection: []
    }
  },

  watch: {
    'data.id' () {
      this.refresh()
    },
    'data.show' (isShow) {
      if (isShow) {
        document.onkeydown = (e) => {
          const key = window.event.keyCode;
          if (key == 13) {
            this.refresh();
          }
        }
      } else {
        document.onkeydown = null
      }
    }
  },
  mounted() {
  },
  computed: {
  },
  beforeDestroy() {
  },
  methods: {
    // 刷新
    refresh () {
      this.queryParams.pageNum = 1
      this.onLoad ()
    },
    // 加载事件
    onLoad () {
      this.loading = true;
      noticeOfnews({
        newsId: this.data.id,
        pageNum: this.queryParams.pageNum,
        pageSize: this.queryParams.pageSize,
        msgId: this.formInline.msgId || null,
        jobId: this.formInline.jobId || null,
        userName: this.formInline.userName || null,
        status: +this.formInline.status || null}).then((resp) => {
          this.noticeData = resp.rows;
          this.total = resp.total;
          this.loading = false;
      }).catch((err) => {
        this.loading = false
        this.msgError('查询失败')
      })
    },
    /*********************
     * @desc 查询
     * @function onSearch
     */
    onSearch () {
      this.refresh()
    },
    /*********************
     * @desc 给列表增加动态class
     */
    cellClass ({row, column, rowIndex, columnIndex}) {
      if (column.property === 'msgId' || column.property === 'jobId' || column.property === 'userName') {
        return 'copy'
      }
    },
    /*********************
     * @desc 格式时间
     * @function formatterDate
     */
    formatterDate(row, column, cellValue, index) {
      // console.log(row, column.property, cellValue)
      if (cellValue) {
        return cellValue.split('.')[0].replace('T', ' ')
      } else {
        return ''
      }
    },
    /*********************
     * @desc 格式状态
     * @function formatterStatus
     */
    formatterStatus (row, column, cellValue, index) {
      switch (true) {
        case cellValue === 1:
          return '已发送'
        case cellValue === 2:
          return '无效'
        case cellValue === 3:
        return '已撤回'
        default:
          return '未知'
      }
    },
    /*********************
     * @desc 批量选择按钮
     * @function handleSelectionChange
     */
    handleSelectionChange (val) {
      this.multipleSelection = val
    },
     copyText (text) {
      const oInput = document.createElement('input');
      oInput.value = text;
      oInput.style.position = 'fixed';
      oInput.style.zIndex = '-1000';
      oInput.style.top = '-1000px';
      document.body.appendChild(oInput);
      oInput.select();
      document.execCommand('copy');
      oInput.remove()
      this.$message.info('内容已复制到剪切板')
    },
    /*********************
     * @desc 单元格点击事件
     * @function cellClick
     */
    cellClick (row, column, cell, event) {
      if (column.property === 'msgId' || column.property === 'jobId' || column.property === 'userName') {
        // 单元格为消息id或任务id或用户对象支持复制操作
        this.copyText(row[column.property])
      }
    },
    // 撤回
    // batch - 批量标识
    handleRevoke (row) {
      let idss = []
      if (this.multipleSelection && this.multipleSelection.length) {
        const arr = this.multipleSelection.filter(v => {
          return this.noticeData.find(m => m.id === v.id).status === 1
        })
        idss = arr.map(v => v.id)
      }
      const ids = row && row.id ? [row.id] : idss;
      if (Array.isArray(ids) && ids.length <= 0) {
        this.msgError('只能撤回已发送的消息');
        return
      }
       this.loading = true;
      revokeMsgByIds({ids}).then((resp) => {
        this.loading = false;
        if (resp.code === 200) {
          this.msgSuccess('撤回成功')
          this.refresh()
        } else {
          this.msgError('撤回失败')
        }
      }).catch(err => {
        this.loading = false;
        this.msgError('撤回失败')
        console.log('撤回失败，', err)
      })
    },
    // 删除
    // batch - 批量标识
    handleDelete (row) {
      this.loading = true;
      let ids = []
      if (row && row.id) {
        ids = [row.id]
      } else {
        ids = this.multipleSelection.map(v => v.id)
      }
      deleteMsg(ids).then(resp => {
        this.loading = false;
        if (resp.code === 200) {
          this.msgSuccess('删除成功')
          this.refresh()
        } else {
          this.msgError('删除失败')
        }
      }).catch(err => {
        this.loading = false;
        this.msgError('删除失败')
        console.log('删除失败，', err)
      })
    },
    // 全量撤回
    remokeAll () {
      this.$confirm('此操作将执行全量撤回操作, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.loading = true;
        revokeMsgByNewsId({
          newsId: this.data.id
        }).then(resp => {
          this.loading = false;
          if (resp.code === 200) {
            this.msgSuccess('开始执行全量撤回操作')
            this.refresh()
          } else {
            this.msgError('执行全量撤回操作失败')
          }
        }).catch(err => {
          this.loading = false;
          this.msgError('执行全量撤回操作失败')
          console.log('执行全量撤回操作失败', err)
        })
      }).catch(() => {
      });
    }
  }
}
</script>

<style lang="scss" scoped>
  // .newsTitle{
  //   font-size: 20px;
  //   color: #2272DE;
  // }
  .operation{
    margin-bottom: 18px;
  }
  ::v-deep .copy{
    div{
      cursor: pointer;
    }
  }
</style>
