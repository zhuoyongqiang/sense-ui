<template>
  <div class="windowTemplate">
    <el-row>
      <navbar currentPage="待办委托"></navbar>
    </el-row>
    <el-row>
      <div class="todoMain">
        <el-row>
          <el-col :span="12">
            <el-button
              type="primary"
              icon="el-icon-plus"
              @click="handleUpdate({ id: 0 })"
              >新建委托
            </el-button>
            <el-button
              type="primary"
              icon="el-icon-message"
              @click="openEmail"
              >发送邮件
            </el-button>
            <el-button
              icon="el-icon-chat-line-round"
              size="mini"
              @click="autoReplyInfo"
              >邮件自动回复</el-button
            >
          </el-col>
          <el-col :span="12" style="text-align: right">
            <el-form
              :model="queryParams"
              ref="queryForm"
              :inline="true"
              v-show="showSearch"
              label-width="100px"
            >
              <el-form-item label="被委托人" prop="entrustUserNickname">
                <el-input
                  v-model="queryParams.entrustUserNickname"
                  placeholder="请输入委托人"
                  clearable
                  size="small"
                  @keyup.enter.native="handleQuery"
                />
              </el-form-item>
              <el-form-item>
                <el-button
                  type="primary"
                  icon="el-icon-search"
                  size="mini"
                  @click="handleQuery"
                  >查询</el-button
                >
                <el-button
                  icon="el-icon-refresh"
                  size="mini"
                  @click="resetQuery"
                  >重置</el-button
                >
              </el-form-item>
            </el-form>
          </el-col>
        </el-row>

        <el-table
          v-loading="loading"
          :data="dataList"
          @selection-change="handleSelectionChange"
          empty-text="暂无委托记录"
        >
          <el-table-column
            label="委托人"
            align="center"
            prop="nickName"
            :show-overflow-tooltip="true"
          />
          <el-table-column
            label="被委托人"
            align="center"
            prop="entrustUserNickname"
            :show-overflow-tooltip="true"
          />
          <el-table-column
            label="开始时间"
            align="center"
            :show-overflow-tooltip="true"
          >
            <template slot-scope="scope">
              <span>{{
                parseTime(scope.row.startDate, "{y}-{m}-{d} {h}:{i}:{s}")
              }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="结束时间"
            align="center"
            :show-overflow-tooltip="true"
          >
            <template slot-scope="scope">
              <span>{{
                parseTime(scope.row.endDate, "{y}-{m}-{d} {h}:{i}:{s}")
              }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="创建时间"
            align="center"
            :show-overflow-tooltip="true"
          >
            <template slot-scope="scope">
              <span>{{
                parseTime(scope.row.createTime, "{y}-{m}-{d} {h}:{i}:{s}")
              }}</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" align="center">
            <template slot-scope="scope">
              <span v-if="scope.row.status == 1">正在委托</span>
              <span v-else-if="scope.row.status == 2">已撤销</span>
              <span v-else-if="scope.row.status == 3">已过期</span>
              <span v-else>未知</span>
            </template>
          </el-table-column>
          <el-table-column
            label="操作"
            align="center"
            class-name="small-padding fixed-width"
          >
            <template slot-scope="scope">
              <el-button
                size="mini"
                type="text"
                @click="handleUpdate(scope.row)"
                >查看
              </el-button>
              &nbsp;&nbsp;
              <span v-if="scope.row.status == 1">
                <el-button
                  size="mini"
                  type="text"
                  @click="handleRevoke(scope.row)"
                  >撤销
                </el-button></span
              >
              <span v-else-if="scope.row.status == 2">
                <el-button
                  size="mini"
                  type="text"
                  @click="handleDelete(scope.row)"
                  >删除
                </el-button>
              </span>
              <span v-else-if="scope.row.status == 3">
                <el-button
                  size="mini"
                  type="text"
                  @click="handleDelete(scope.row)"
                  >删除
                </el-button></span
              >
            </template>
          </el-table-column>
        </el-table>
        <pagination
          v-show="total > 0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
        <!--修改窗口-->
        <edit
          ref="editInfo"
          :visible.sync="editInfovisible"
          @callback="handleQuery"
        ></edit>
        <!--打开自动回复窗口-->
        <autoReply
          ref="autoReplyInfo"
          :visible.sync="autoReplyInfovisible"
        ></autoReply>
      </div>
    </el-row>
    <!-- 发送邮件弹框 -->
    <email :data="emailData"></email>
  </div>
</template>

<script>
import store from '@/store'
import Edit from "@/views/home/profile/edit";
import autoReply from "@/views/home/profile/autoReply";
import email from '@/views/home/profile/email'
import { allApp } from "@/api/console/system/app";
import {
  list,
  findById,
  remove,
  revoke,
} from "@/api/console/layout/workentrust/index";
import navbar from "@/views/home/component/navbar";
export default {
  name: "moreTodoTemplate",
  components: { Edit, autoReply, navbar, email },
  data() {
    return {
      appList: [],
      autoReplyInfovisible: false,
      editInfovisible: false,
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 表格数据
      dataList: [],
      /**工单类型字典*/
      workOrderStatusOptions: [],
      /**是否准入*/
      workOrderAccessOptions: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        appsName: undefined,
        entrustUserNickname: undefined,
      },
      dateRange: [],
      orgTreeData: null,
      // 邮件弹框
      emailData: {
        show: false
      }
    };
  },
  created() {
    this.getList();
    this.loadtDicts();
    this.queryOrgtree();
    this.queryCommontree();
    console.log('creatae')
  },
  destroyed() {
    // this.queryCommontree()
  },
  methods: {
    /**********
     * @desc 请求全机构人员树
     * @function treeselectNewPro
     */
    queryOrgtree() {
      console.log('queryOrgtree')
      store.dispatch('orgTree/TreeselectNewPro').then(res => {
        // 获取机构树
      }).catch(err => {
      })
    },
    /**********
     * @desc 请求常用机构人员树
     * @function treeselectNewPro
     */
    queryCommontree() {
      store.dispatch('orgTree/GetGroup').then(res => {
        // 获取机构树
      }).catch(err => {
      })
    },
     // 深拷贝算法
    deepClone (obj) {
      let objClone = Array.isArray(obj) ? [] : {};
      if (obj && typeof obj === 'object') {
        for(let key in obj) {
          if (obj[key] && typeof obj[key] === 'object'){
            objClone[key] = this.deepClone(obj[key]);
          } else {
            objClone[key] = obj[key]
          }
        }
      }
  　　return objClone;
    },
    /*************
     * @desc 格式化机构树
     * @function initTree
     */
    initTree(data) {
      console.log('init', data)
      for (let i = 0; i < data.length; i++) {
        let node = data[i];
        // 递归结束条件
        if ((node.children && node.children.length) || (node.users && node.users.length)) {
          let user = (node.users || []).map((v) => {
            return { ...v, label: v.nickName };
          });
          if(node.children){
            this.initTree(node.children)
            console.log("node", node);
          }
          node.children = [...(node.children || []), ...user ];
        }
      }
      return data;
    },
    concatUsers(data) {
      // console.log(data)
        const newData = data.map((item) => {
          const newUsers = item.users.map((user) => {
            user.label = item.label;
            return user;
          });
          if(item.children){
            const newChildren = this.concatUsers(this.deepClone(item.children)); 
            item.children = [...newChildren, ...newUsers]
          }else{
            item.children = newUsers
          }
          return item;
        });
        return newData;
    },
    /**************
     * @desc 显示发送邮件弹框
     * @function openEmail
     */
    openEmail () {
      this.emailData.show = true
    },
    loadtDicts() {
      this.getDicts("bpm_process_status").then((response) => {
        this.workOrderStatusOptions = response.data;
      });
      this.getDicts("work_order_access").then((response) => {
        this.workOrderAccessOptions = response.data;
      });
      allApp({}).then((response) => {
        if (response.length > 0) {
          for (let i in response) {
            if (response[i].status == 0) continue;
            if (response[i].isEntrust == 0) continue;
            let obj = {
              lable: response[i].sn,
              value: response[i].name,
            };
            this.appList.push(obj);
          }
        }
      });
    },
    workOrderStatusFormat(row, column) {
      let val = this.selectDictLabel(this.workOrderStatusOptions, row.status);
      if (val) {
        return val;
      } else {
        return "未知";
      }
    },
    workOrderAccessOFormat(row, column) {
      let val = this.selectDictLabel(this.workOrderAccessOptions, row.access);
      if (val) {
        return val;
      } else {
        return "未知";
      }
    },
    /** 查询列表 */
    getList() {
      this.loading = true;
      let search = this.queryParams;
      search.params = {};

      list(search).then((response) => {
        this.dataList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.dateRange = [];
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map((item) => item.id);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      const id = row.id || this.ids;
      this.editInfovisible = true;
      this.$nextTick(function () {
        this.$refs.editInfo.load(id);
      });
    },
    autoReplyInfo() {
      this.autoReplyInfovisible = true;
      this.$nextTick(function () {
        this.$refs.autoReplyInfo.load();
      });
    },
    handleRevoke(row) {
      const id = row.id;
      if (id == undefined || id === "") {
        this.msgWarning("请选择需要撤销项");
        return;
      }
      this.$confirm("确认是否撤销选择项?", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(function () {
          return revoke(id);
        })
        .then((response) => {
          if (response.code == 200) {
            this.getList();
            this.msgSuccess(
              "您的撤销申请已处理，稍后在列表中点击委托记录查看撤销结果。"
            );
          } else {
            this.msgError(response.msg);
          }
        });
    },

    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      if (ids && ids.length == 0) {
        this.msgWarning("请选择需要删除项");
        return;
      }
      this.$confirm("确认是否删除选择项?", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(function () {
          return remove(ids);
        })
        .then((response) => {
          if (response.code == 200) {
            this.getList();
            this.msgSuccess("删除成功");
          } else {
            this.msgError(response.msg);
          }
        });
    },
  },
};
</script>


<style lang="scss" scoped>
::v-deep .navbar-wrapper {
  width: 1200px;
  margin: 0 auto;
}
.windowTitle2 {
  margin: 0 auto;
  height: 60px;
  line-height: 60px;
  color: #666666;
  font-size: 12px;
  text-align: right;
}

.windowTitle2,
.todoMain {
  width: 1200px;
  margin: 0 auto;
  position: relative;
  top: 0;
}

.windowTemplate {
  background: #ffffff;
}

.windowTitle {
  margin: 0 auto;
  height: 60px;
  line-height: 60px;
  color: #666666;
  font-size: 12px;
  text-align: right;
}

.windowTitle,
.todoMain {
  width: 1200px;
  margin: 0 auto;
  position: relative;
  top: 0;
}

.todoMain {
  margin-top: 0px;
  margin-bottom: 40px;
  position: relative;
  top: 0;
}

.search {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 111111;
}

.search .el-input__icon {
  line-height: 32px;
}

.page {
  margin-top: 12px;
  margin-bottom: 15px;
}

.el-breadcrumb {
  line-height: 60px;
}
</style>
