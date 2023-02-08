<template>
  <div>
    <el-dialog
      :title="title"
      :visible.sync="showInfo"
      width="1114px"
      :close-on-click-modal="false"
      append-to-body
      :class="{'distabnone': !form.id}"
    >
      <el-tabs v-model="activeName" class="elTabs" :class="{'distabnone': !form.id}">
        <el-tab-pane label="基础表单" name="first" class="baseform">
          <el-alert
            v-if="form.next"
            title="温馨提示：当前委托与其他委托，时间区间上存在冲突！"
            type="warning"
            show-icon
            style="margin-bottom: 10px">
          </el-alert>
          <el-form ref="form" :disabled="!!form.id" :model="form" :rules="rules" label-width="120px">
            <el-row>
              <el-col :span="12">
                <el-form-item label="委托人">
                  <el-input v-model="nickName" :disabled="true"  />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-form-item style="margin-bottom: 0" label="所属系统" prop="checkAppList" class="system-panel">
                <el-checkbox :indeterminate="isIndeterminate" v-model="checkAll" @change="handleCheckAllChange">全部</el-checkbox>
                <el-checkbox-group v-model="checkedList" @change="handleCheckedCitiesChange">
                  <div class="checkbox" v-for="item in appList" :key="item.name" >
                    <el-checkbox :label="item.lable">{{item.name}}</el-checkbox>
                    <div v-show="item.lable === 'APP013' && checkedList.includes('APP013')" class="workOrderbtn" @click="workOderSettingShow = !workOderSettingShow" :key="item.name + 'div'">协同工单设置</div>
                  </div>
                </el-checkbox-group>
              </el-form-item>
              <el-form-item class="workOrderTip" :class="{'shown' : checkedList && checkedList.includes('APP013')}">
                <div class="tip">
                  <div class="title"><i class="el-icon-warning"></i><span>温馨提示</span>勾选后默认委托全部类型工单。如需委托协同部分类型工单请点击“协同工单设置“进行设置。</div>
                </div>
              </el-form-item>
            </el-row>
            <!-- <el-row v-show="checkedList.length > 0 && fiterworkTypeList.length > 0"> -->
            <el-row v-show="checkedList.includes('APP013') && workOderSettingShow">
              <el-col :span="24">
                <el-form-item class="workOderSetting" label-width="0">
                  <div class="transfer-panel">
                    <div class="transfer-title">工单类型设置</div>
                    <el-transfer
                      filterable
                      v-model="form.taskTypeList"
                      :data="fiterworkTypeList"
                      :titles="['全部类型', '已选类型']"
                      style="width: 100%"
                      :render-content="renderFunc">
                    </el-transfer>
                  </div>
                  <div class="tip">
                    <div class="title"><i class="el-icon-warning"></i><span>温馨提示</span>如果委托系统不选择工单类型，委托默认为所有工单类型</div>
                    <!-- <div class="text">例如：如果同时发起委托A和B两个系统的工单委托，A系统没有选工单类型，B选择工单类型，则发起委托A和B系统委托请求，A系统的工单类型为所有，B系统的工单类型为选择的工单类型</div> -->
                  </div>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="12">
                <el-form-item label="委托已有的待办">
                  <el-switch
                    :active-text="form.entrustWork ? '已开启' : '已关闭'"
                    v-model="form.entrustWork"
                    active-color="#13ce66"
                    inactive-color="#ddd">
                  </el-switch>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="12">
                <el-form-item label="开始时间" prop="startDate">
                  <el-date-picker clearable
                                  style="width:100%"
                                  v-model="form.startDate"
                                  format="yyyy-MM-dd HH:mm:ss"
                                  value-format="yyyy-MM-dd HH:mm:ss"
                                  type="datetime"
                                  placeholder="选择开始时间">
                  </el-date-picker>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="12">
                <el-form-item label="结束时间" prop="endDate">
                  <el-date-picker clearable
                                  style="width:100%"
                                  v-model="form.endDate"
                                  format="yyyy-MM-dd HH:mm:ss"
                                  value-format="yyyy-MM-dd HH:mm:ss"
                                  type="datetime"
                                  placeholder="选择结束时间">
                  </el-date-picker>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="12">
                <el-form-item label="被委托人" class="consignee-panel">
                  <div>
                    <el-tag class="checked" :closable="!form.id" :disable-transitions="false" @close="closetag" v-show="form.entrustUserNickname">{{form.entrustUserNickname}}</el-tag>
                    <el-button class="button-new-tag" size="small" @click="openFindUser" v-show="!form.id && !form.entrustUserNickname">添加</el-button>
                  </div>
                  <!-- <el-input v-model="form.entrustUserNickname">
                    <el-button slot="append" icon="el-icon-arrow-right" @click="openFindUser" v-if="form.id==undefined"></el-button>
                  </el-input> -->
                  <el-tag v-if="form.id===undefined" @click="cheackEntrusUser(item)" type="info" v-for="item in contactsUserListData" :title=item.title :key="item.id" style="margin-right: 10px;cursor: pointer;">{{item.label}}</el-tag>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row v-if="false">
              <el-col :span="24">
                <el-form-item label="邮件通知" class="email-panel">
                  <div class="emails">
                    <el-form-item label-width="0" :style="{'margin-bottom': form.emailEnable ? '18px' : 0}">
                      <el-switch
                        v-model="form.emailEnable"
                        active-color="#13ce66"
                        inactive-color="#ddd">
                      </el-switch>
                    </el-form-item>

                    <el-form-item label="发件人邮箱账号" prop="email_send_username" label-width="120px" v-show="form.emailEnable" :required="form.emailEnable">
                      <el-input v-model="form.email_send_username" :placeholder="!!form.id ? '' : '请选择'"></el-input>
                    </el-form-item>
                    <el-form-item label="邮箱密码" prop="email_send_password" label-width="120px" v-show="form.emailEnable && !form.id" :required="form.emailEnable">
                      <el-input type="password" v-model="form.email_send_password" placeholder="请输入" autocomplete="new-password"></el-input>
                    </el-form-item>
                    <el-form-item label="收件人" prop="sendEmailText" label-width="120px" v-show="form.emailEnable" :required="form.emailEnable">
                      <el-input type="textarea" autosize v-model="form.sendEmailText" :placeholder="!!form.id ? '' : '请选择'" readonly unselectable="on" @click.native="openFindGroup(1)"> <i
                        class="el-icon-search"
                        slot="suffix"
                        @click="openFindGroup(1)">
                      </i></el-input>
                    </el-form-item>
                    <el-form-item label="抄送人" label-width="120px" v-show="form.emailEnable">
                      <el-input type="textarea" autosize v-model="form.sendCCEmailText" :placeholder="!!form.id ? '' : '请选择'" readonly unselectable="on" @click.native="openFindGroup(2)"> <i
                        class="el-icon-search"
                        slot="suffix"
                        @click="openFindGroup(2)">
                      </i></el-input>
                    </el-form-item>
                    <el-form-item label="邮件主题" prop="emailTheme" label-width="120px" v-show="form.emailEnable" :required="form.emailEnable">
                      <el-input v-model="form.emailTheme"/>
                    </el-form-item>
                    <el-form-item label="邮件内容" prop="emailContent" label-width="120px" v-show="form.emailEnable" :required="form.emailEnable">
                      <el-input type="textarea" :rows="3" v-model="form.emailContent"></el-input>
                    </el-form-item>
                    <el-form-item label="发送状态" v-if="form.id!==undefined" v-show="form.emailEnable">
                      <el-switch
                        v-model="form.emailSendStatus===1"
                        active-color="#13ce66"
                        inactive-color="#ff4949">
                      </el-switch>
                    </el-form-item>
                  </div>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row>
              <el-col :span="24">
                <el-form-item label="委托说明">
                  <el-input type="textarea" :placeholder="!!form.id ? '' : '请输入'" :rows="3" v-model="form.remark"></el-input>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row v-show="id==0">
              <el-form-item style="text-align: center" class="button-panel">
                <el-button type="primary" @click="submit">确认</el-button>
                <el-button @click="cancel" :disabled="false">返回</el-button>
              </el-form-item>
            </el-row>
          </el-form>
          <div class="backbtn" v-show="!!form.id">
            <el-button @click="cancel">返回</el-button>
          </div>
        </el-tab-pane>
        <el-tab-pane label="请求结果" name="second" v-if="form.id != undefined">
          <el-form :model="queryParams" ref="queryForm" :inline="true">
            <el-form-item label="类型" prop="type">
              <el-input
                v-model="queryParams.type"
                placeholder="请输入类型"
                clearable
                size="small"
                @keyup.enter.native="listByEntrustIdData"
              />
            </el-form-item>
            <el-form-item label="系统标识" prop="clientId">
              <el-input
                v-model="queryParams.clientId"
                placeholder="请输入系统标识"
                clearable
                size="small"
                @keyup.enter.native="listByEntrustIdData"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="el-icon-search" size="mini" @click="listByEntrustIdData">查询</el-button>
              <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>

          <el-row v-if="form.id!=undefined">
            <el-table
              :data="respData"
              empty-text="暂无记录"
              v-loading="respDataLoading"
              style="width: 100%"
            >
              <el-table-column
                prop="type"
                label="类型">
              </el-table-column>
              <el-table-column
                prop="clientId"
                label="系统标识">
              </el-table-column>
              <el-table-column
                prop="clientName"
                label="系统名称">
              </el-table-column>
              <el-table-column
                prop="callMsg"
                label="请求结果">
              </el-table-column>

              <el-table-column label="创建时间" align="center" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
                </template>
              </el-table-column>
              <el-table-column label="执行时间" align="center" :show-overflow-tooltip="true">
                <template slot-scope="scope">
                  <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="150">
                <template slot-scope="scope">
                <span v-if="scope.row.status !== 100000001">
                  <el-button
                    size="mini"
                    type="text"
                    @click="againAction(scope.row)"
                  >重新执行
                </el-button>
                </span>
                </template>
              </el-table-column>
            </el-table>
            <pagination
              v-show="respDataTotal>0"
              :total="respDataTotal"
              :page.sync="queryParams.pageNum"
              :limit.sync="queryParams.pageSize"
              @pagination="listByEntrustIdData"
            />
          </el-row>
        </el-tab-pane>
      </el-tabs>
      <!--查询被委托用户-->

      <!--收件人和抄送人-->
      <findGroup ref="findGroup" v-if="false" @emailcallback="emailcallback" :visible.sync="findGroupvisible"></findGroup>
    </el-dialog>
    <findUser ref="findUser"  @callback="callback" :visible.sync="findUservisible"></findUser>
  </div>
</template>

<script>
  import {getInfo} from "@/api/login";
  import {add,findById,workTypeAll,listByEntrustId,againAction} from "@/api/console/layout/workentrust/index";
  import {allApp} from "@/api/console/system/app";
  import findUser from "@/views/home/profile/profile/findUser";
  import findGroup from "@/views/home/profile/profile/findGroup";
  import {listContactsUserList} from "@/api/console/system/user";
  import {mapGetters} from "vuex";
  const cityOptions = [];
  export default {
    name: "workOrderEdit",
    components: {findUser,findGroup},
    data() {
      // 自定义验证规则
      var createTimeCheck = (rule, value, callback) => {
        if (value === '') {
          callback()    // 回调函数
        } else {
          if (this.form.startDate && this.form.endDate) {
            let createTimeStart = this.form.startDate    // 从数组中取出开始时间   取出结果：'2020-10-28 16:01:15'
            let createTimeEnd = this.form.endDate     // 取出结束时间
            let sTime = (((createTimeStart.split(' '))[1]).split(':')).join('')    // 从 '2020-10-28 16:01:15' 取出时间 结果：‘160115’
            let sDate = (((createTimeStart.split(' '))[0]).split('-')).join('')    // 取出开始日期 结果：‘20201028’
            let endTime = (((createTimeEnd.split(' '))[1]).split(':')).join('')    // 取出结束时间
            let endDate = (((createTimeEnd.split(' '))[0]).split('-')).join('')    // 取出结束日期
             if (parseInt(endDate) > parseInt(sDate)) {    // 如果结束日期大于开始日期  不用判断时间
              callback()
            } else {
              if (parseInt(endTime) <= parseInt(sTime)) {    // 如果结束日期不大于开始日期  判断结束时间是否大于开始时间
                callback(new Error('结束时间必须大于开始时间'))
              } else {
                callback()
              }
            }
          } else {
            callback()
          }
        }
      }
      const emptyCheck = (rule, value, callback) => {
        console.log('234', rule, value)
        if (this.form.emailEnable && !value) {
          console.log('2222')
          switch (rule.field) {
            case 'email_send_username':
              callback(new Error('发送人不能为空'))
              break
            case 'email_send_password':
              callback(new Error('邮箱密码不能为空'))
              break
            case 'sendEmailText':
              callback(new Error('收件人不能为空'))
              break
            case 'emailTheme':
              callback(new Error('邮件主题不能为空'))
              break
            case 'emailContent':
              callback(new Error('邮件内容不能为空'))
              break
            default:
              break
          }
        } else {
          console.log('3333')
          callback()
        }
      }
      return {
        workOderSettingShow: false, // 工单设置模块显示、隐藏
        activeName: 'first',
        checkAll: false,
        checkedList: [],
        isIndeterminate: undefined,
        id:0,
        // 查询参数
        queryParams: {
          pageNum: 1,
          pageSize: 10,
          clientId:undefined,
          type:undefined,
          entrustId:undefined
        },
        allLableList:[],
        workTypeList:[],
        fiterworkTypeList:[],
        respData:[],
        respDataTotal:0,
        respDataLoading:true,
        findUservisible:false,
        findGroupvisible:false,
        form:{
          email_send_username: '',
          email_send_password: '',
          entrustUserNickname:'',
          entrustUserName:'',
          checkAppList:[],
          sendEmailText:'',
          sendCCEmailText:'',
          sendEmailAddressList:[],
          sendCCEmailAddressList:[],
          taskTypeList: [],
          entrustWork:undefined,
          next: false
        },
        title:'',
        showInfo:false,
        /**工单类型字典*/
        workOrderStatusOptions: [],
        /**是否准入*/
        workOrderAccessOptions: [],
        /**工单审批类型*/
        workOrderTerminalTypeOptions: [],
        appList: [],
        allappList: [],
        contactsUserListData:[],
        // 表单校验
        rules: {
          startDate: [
            { required: true, message: "开始时间不能为空", trigger: "blur" },
            { validator:createTimeCheck, trigger: "blur" }
          ],
          endDate: [
            { required: true, message: "结束时间不能为空", trigger: "blur" },
            { validator:createTimeCheck, trigger: "blur" }
          ],
          entrusUserName :[
            { required: true, message: "请选择被委托人", trigger: "blur" }
          ],
          email_send_username: [
            { validator:emptyCheck, trigger: "blur" }
          ],
          email_send_password: [
            { validator:emptyCheck, trigger: "blur" }
          ],
          sendEmailText: [
            { validator:emptyCheck }
          ],
          emailTheme: [
            { validator:emptyCheck, trigger: "blur" }
          ],
          emailContent: [
            { validator:emptyCheck, trigger: "blur" }
          ]
        }
      };
    },created() {
      this.loadtDicts();
      this.findAllapps();
    },
    computed: {
      ...mapGetters([
        'nickName'
      ])
    },
    methods: {
      /***********************
     * @function getInfo
     * @desc 获取当前用户信息
     */
    getUserInfo () {
      getInfo().then(resp => {
        if (resp.code === 200) {
          this.$set(this.form, 'email_send_username', resp.user.email)
        }
      })
    },
      renderFunc(h, option) {
        return <span title={option.label}>{option.label}</span>;
      },
      closetag () {
        this.form = {...this.form, entrustUserNickname: null}
        this.form.entrustUserName = '';
      },
      handleCheckAllChange(val) {
        this.checkedList = val ? cityOptions : [];
        if(this.checkAll){
          this.checkedList=this.allLableList;
        }else{
          this.checkedList=[];
        }
        this.isIndeterminate = false;
        this.fiterOrderType();
      },
      handleCheckedCitiesChange(value) {
        let checkedCount = value.length;
        this.checkAll = checkedCount === this.appList.length;
        this.isIndeterminate = checkedCount > 0 && checkedCount < this.appList.length;
        this.fiterOrderType();
        // 隐藏工单设置功能
        this.workOderSettingShow = false
      },
      fiterOrderType(){
        this.fiterworkTypeList=[];
        if(this.workTypeList.length===0){
          this.fiterworkTypeList=[];
          return;
        }
        if(this.checkedList.length === 0){
          this.fiterworkTypeList = [];
          this.fiterworkTypeList = this.workTypeList;
          return;
        }
        for (var i in this.workTypeList) {
            if(this.checkedList.indexOf(this.workTypeList[i].appId) !== -1){
              this.fiterworkTypeList.push(this.workTypeList[i]);
            }
        }
      },

      /** 修改按钮操作 */
      openFindUser() {
        this.findUservisible=true;
        this.$nextTick(function () {
          //1待办收件人 2代表抄送人
          this.$refs.findUser.show(3)
        } )
      },

      openFindGroup(type){
        if (this.form.id) {
          return
        }
        this.findGroupvisible = true;
        this.$nextTick(function () {
          //1待办收件人 2代表抄送人
          this.$refs.findGroup.show(type)
        })
      },
      loadtDicts(){
        this.getDicts('bpm_process_status').then(response => {
          this.workOrderStatusOptions = response.data;
        })

        this.getDicts('work_order_access').then(response => {
          this.workOrderAccessOptions = response.data;
        })
        this.getDicts('work_order_terminal_type').then(response => {
          this.workOrderTerminalTypeOptions = response.data;
        })
      },
      againAction(row){
        //row.clientId="更新"
        //重新发起更新
        this.respDataLoading = true

        setTimeout(() => {
          againAction(row.id).then(response => {
            this.respDataLoading = false
            this.msgWarning("已执行您的请求，稍后刷新列表查看请求结果");
          });
        }, 500);
      },
      load(id){
        this.activeName='first';
        this.id = id;
        if( this.$refs['form']!== undefined){
          this.$refs['form'].resetFields();
        }
        this.form = {
          entrustWork: true,
          next: false
        };
        if(this.id != 0) {
          this.title="查看委托"
          findById(id).then(response => {
            this.form = response.data;
            this.checkedList=this.form.appsList;
            this.showInfo = true
          });
        }else{
          this.title="新建委托"
          getInfo().then(resp => {
            if (resp.code === 200) {
              this.$set(this.form, 'email_send_username', resp.user.email)
            }
          })
          this.showInfo = true
        }
        this.workTypeList=[]
        this.form.sendEmailAddressList = []
        // this.form.sendEmailText = ''
        this.$set(this.form, 'sendEmailText', '')
        this.$set(this.form, 'sendEmailAddressList', [])
        this.$set(this.form, 'sendCCEmailText', '')
        this.$set(this.form, 'sendCCEmailAddressList', [])

        //初始化
        this.appList=[];
        this.allLableList=[];
        this.form.checkAppList=[];
        this.checkAll=false
        this.checkedList= []
        this.isIndeterminate= undefined
        this.selectlistContactsUserLists();
        this.findAllapps();
        this.getWorkType();
        this.listByEntrustIdData();

      },
      listByEntrustIdData(){
        let search =  this.queryParams
        search.entrustId = this.id;
        this.respDataLoading = true;
        setTimeout(() => {
          listByEntrustId(search).then(response => {
            this.respData = response.rows;
            this.respDataTotal = response.total;
            this.respDataLoading = false;
          });
        }, 200);


      },
      /** 重置按钮操作 */
      resetQuery() {
        this.resetForm("queryForm");
        this.listByEntrustIdData();
      },

      getWorkType(){
        workTypeAll().then(response => {
          if(response.length>0){
            for(var i in response){
              let app = this.getApp(response[i].appId);
              let appName='';
              if(app != null){
                appName = app.name
              }
              let obj = {
                key: response[i].appId + "_" + response[i].sn,
                value: response[i].appId + "_" + response[i].sn,
                label: appName+" / "+response[i].type+" / "+response[i].name,
                type: response[i].type,
                appId:response[i].appId,
                appName:appName
              }
              this.workTypeList.push(obj)
            }
          }
          setTimeout(() =>{
            this.fiterOrderType();
          },300)

        })
      },
      getApp(sn){
        if(this.allappList.length > 0){
          for(let i in this.allappList){
            if(this.allappList[i].sn === sn){
              return this.allappList[i];
            }
          }
          return null;
        }else{
          return null;
        }
      },
      findAllapps(){
        allApp({}).then(response => {
          if(response.length>0){
            this.allLableList = []
            this.appList = []
            for(let i in response){
              this.allappList.push(response[i])
              if(response[i].status==0)continue;
              if(response[i].isEntrust==0)continue;
              let obj={
                lable:response[i].sn,
                name:response[i].name
              }
              this.allLableList.push(response[i].sn)
              this.appList.push(obj)
            }
          }
        })
      },
      cancel() {
        this.showInfo=false
        this.form={};
      },
      callback(obj) {
        this.findUservisible = false;
        if(obj.length>=1){
          this.form.entrustUserNickname = obj[0].label;
          this.form.entrustUserName = obj[0].staffAccount;
        }
        this.selectlistContactsUserLists()
      },

      emailcallback(text,list,type, checkeds){
        console.log('checkeds', checkeds)
        //1代表收件人
        //2代表抄送人
        if(type===1){
          // this.form.sendEmailText=text;
          this.$set(this.form, 'sendEmailText', text)
          this.form.sendEmailAddressList= checkeds[type].map(v => v.email)
          this.$refs.form.validateField('sendEmailText');
        }
        else if(type===2){
          this.form.sendCCEmailText=text;
          this.form.sendCCEmailAddressList=checkeds[type].map(v => v.email)
        }
        this.$refs.findGroup.checkeds = {
          ...this.$refs.findGroup.checkeds,
          ...checkeds
        }
        this.$forceUpdate()
      },
      cheackEntrusUser(item){
        this.form.entrustUserNickname = item.label;
        this.form.entrustUserName = item.id;
        this.$forceUpdate()
      },
      selectlistContactsUserLists(){
        //查询常用联系人
        listContactsUserList().then(response => {
          var row=response.data;
          this.contactsUserListData = [];
          if(row.length>0) {
            for (var i in row) {
              var userName = row[i].userName;
              var nickName = row[i].nickName;

              let userTips="";
              if(row[i].orgDept!=null){
                userTips = "所属机构："+row[i].orgDept.deptName+"\n";
              }
              if(row[i].orgDept!=null){
                userTips += "所属部门："+row[i].departmentDept.deptName+"\n";
              }
              if(row[i].officeDept!=null){
                userTips += "所属处室："+row[i].officeDept.deptName+"\n";
              }
              userTips += "姓       名："+row[i].nickName+"\n";
              userTips += "登录账号："+row[i].userName+"\n";

              const newChild = {id: userName, label: nickName,title:userTips};

              this.contactsUserListData.push(newChild);
            }
          }
        });
      },
      submit() {
        this.form.checkAppList=this.checkedList;
        if(this.form.checkAppList==undefined || this.form.checkAppList.length==0){
          this.msgWarning("请选择委托应用");
          return;
        }
        if(this.form.entrustUserName===undefined || this.form.entrustUserName===''){
          this.msgWarning("请选择被委托人");
          return;
        }
        this.form.appsName='';
        for(let i in this.form.checkAppList){
          let appsn= this.form.checkAppList[i];
          for(let j in this.appList){
            let allappsn= this.appList[j].lable;
            if(appsn===allappsn){
              if(this.form.appsName===''){
                this.form.appsName=this.appList[j].name;
              }else{
                this.form.appsName+=","+this.appList[j].name
              }
              continue;
            }
          }
        }
        this.form.appsList = this.form.checkAppList;

        if(this.form.taskTypeList !== null && this.form.taskTypeList !== undefined  && this.form.taskTypeList.length > 0){
          let fiterTaskType=[];
          for (let i in this.checkedList) {
            for (let j in this.form.taskTypeList) {
              if(this.form.taskTypeList[j].indexOf(this.checkedList[i]) > -1){
                fiterTaskType.push(this.form.taskTypeList[j]);
              }
            }
          }
          this.form.taskTypeList = fiterTaskType;
        }
        this.$refs["form"].validate(valid => {
          if (valid) {
            const param = this.form
            add(param).then(response => {
              if(response.code===200) {
                // this.msgSuccess("您的申请已处理，稍后在列表中点击委托记录查看委托结果。");
                // this.$emit('callback');
                // // this.$refs.findGroup.reset()
                // this.cancel();
                 this.$confirm('您的申请已处理，稍后在列表中点击委托记录查看委托结果, 是否需要发送邮件?', '提示', {
                  confirmButtonText: '是',
                  cancelButtonText: '不，谢谢',
                  type: 'success'
                }).then(() => {
                  this.$parent.$parent.emailData.show = true
                  this.$emit('callback');
                  this.cancel();
                // this.$refs.findGroup.reset()
                }).catch(() => {
                  this.$emit('callback');
                  this.cancel();
                });
              }else if(response.code === 1000003) {
                //存在冲突继续委托
                this.$confirm(response.msg, '温馨提示', {
                  confirmButtonText: '继续执行',
                  cancelButtonText: '取消执行',
                  type: 'warning'
                }).then(() => {
                  this.form.next = true;
                  this.submit();
                }).catch(() => {
                  this.form.next = false;
                });
              }else{
                this.msgWarning(response.msg)
              }
            });
          }
        });
      }
    }
  };
</script>

<style lang="scss" scoped>
  .workOrderTip{
    // height: 0;
    margin-bottom: 0;
    // transition: all 1s;
    .title{
      height: 0;
      overflow: hidden;
      transition: all .5s;
    }
    &.shown{
      .title{
        height: 28px;
        transition: all .5s;
      }
      margin-bottom: 8px;
      height: auto;
    }
  }
  .tip{
    font-size: 14px;
    font-weight: 400;
    color:#909399;
    .title{
      color: #FFB426;
      span{
        font-weight: 600;
        display: inline-block;
        margin: 0 12px 0 4px;
      }
    }
    .text{
      line-height: 1.5;
    }
  }
  .emails{
    // background-color: rgb(247, 247, 247);
    // padding: 10px 5px;
    // border-radius: 4px;
    // border: 1px solid #ddd;
  }
  .emails>div>label{
    font-weight: 500 !important;
    width: 80px !important;
  }
  .emails>div>div{
    margin-left: 85px !important;
  }
  .member_input {
    overflow-y: auto;
    width: 90%;
    min-height: 28px;
    float: left;
    background: #fff;
    border: 1px solid #dcdfe6;
    margin-top: 1px;
    padding: 0 5px;
    font-size: 12px;
  }
  >>>.el-transfer-panel{
    width: 40% !important;
  }

  ::v-deep .el-form-item__label{
    font-weight: 500;
    line-height: 36px!important;
  }
  ::v-deep .el-dialog{
    .el-dialog__header{
      padding: 13px 24px;
      .el-dialog__title{
        font-weight: 600;
        color: #303133;
        font-size: 16px;
      }
      .el-dialog__headerbtn{
        top: 16px;
      }
    }
    .el-dialog__body{
      padding: 0 26px;
    }
  }
  .distabnone{
    ::v-deep .el-dialog{
      .el-dialog__header{
        border-bottom: 1px solid #E4E7ED;
      }
    }
    .el-dialog__body{
      padding: 30px 64px;
    }
  }

  .elTabs{
    &.distabnone{
      ::v-deep .el-tabs__header{
        display: none;
      }
    }
    ::v-deep .el-form-item{
      .el-input{
        font-size: 14px;
        font-weight: 400;
        input{
          height: 36px!important;
          line-height: 36px!important;
          border-radius: 4px!important;
          border-color: #DCDFE6;
        }
        .el-input__suffix{
          right: 10px;
        }
        .el-input__suffix-inner{
          line-height: 36px;
        }
      }
      &.system-panel{
        .el-form-item__content{
          display: flex;
          align-items: center;
          flex-wrap: wrap;
          .el-form-item__label{
            line-height: auto;
          }
          .el-checkbox{
            height: 36px;
            line-height: 36px;
            margin-right: 24px;
            .el-checkbox__label{
              font-weight: 400;
            }
          }
          .el-checkbox-group{
            display: flex;
            align-items: center;
            .checkbox{
              display: flex;
              align-items: center;
              &:last-child{
                .el-checkbox{
                  margin-right: 0;
                }
              }
              .workOrderbtn{
                cursor: pointer;
                margin-left: 4px;
              }
            }
          }
        }
        .workOrderbtn{
          font-size: 12px;
          background-color: rgba($color: #2272DE, $alpha: .1);
          font-weight: 400;
          color: #2272DE;
          padding: 5px 8px;
          line-height: 1;
          border-radius: 2px;
        }
      }
      &.workOderSetting{
        padding: 0 0 0 54px;
        .transfer-panel{
          background-color: #F5F7FA;
          padding: 10px 16px;
          .transfer-title{
            font-weight: 500;
            color: #303133;
            font-size: 12px;
          }
          .el-transfer{
            display: flex;
            align-items: center;
            margin: 8px 0 16px;
            .el-transfer__buttons{
              .el-button{
                display: block;
                margin: 10px 0;
              }
            }
          }
          .el-transfer-panel{
            flex: 1;
          }
        }
        .tip{
          font-size: 14px;
          font-weight: 400;
          color:#909399;
          .title{
            color: #FFB426;
            span{
              font-weight: 600;
              display: inline-block;
              margin: 0 12px 0 4px;
            }
          }
          .text{
            line-height: 1.5;
          }
        }
      }
      &.consignee-panel{
        .button-new-tag{
          background-color: #E8F0FB;
          border-radius: 4px;
          border: 1px solid #A7C7F2;
          font-weight: 400;
          color: #2272DE;
          font-size: 14px;
          background: #E8F0FB url('../../../assets/images/home/add.png') no-repeat 10px center;
          background-size: 16px 16px;
          padding-left: 31px;
        }
        .el-tag{
          &.checked{
            background: url('../../../assets/images/home/user.png') no-repeat 8px center;
            background-size: 16px 16px;
            display: inline-flex;
            align-items: center;
            background-color: rgba($color: #2272DE, $alpha: .07);
            height: 28px;
            line-height: 28px;
            // width: 94px;
            min-width: 94px;
            padding-left: 28px;
            padding-right: 10px;
            font-weight: 400;
            color: #606266;
            font-size: 14px;
            justify-content: space-between;
            i{
              color:#909399;
              &:hover{
                color:#fff;
                background-color:#FF5555;
              }
            }
          }
        }
      }
      &.button-panel{
        .el-button{
          width: 96px;
          height: 40px;
          font-size: 14px;
          font-weight: 400;
          margin: 0 12px;
          &.el-button--default{
            background-color: #F5F7FA;
            color: #909399;
            &:hover{
              border-color: #DCDFE6;
              opacity: .8;
            }
          }
        }
      }
    }
    .backbtn {
      text-align: center;
      .el-button{
        width: 96px;
        height: 40px;
        font-size: 14px;
        font-weight: 400;
        margin: 0 12px;
        &.el-button--default{
          background-color: #F5F7FA;
          color: #909399;
          &:hover{
            border-color: #DCDFE6;
            opacity: .8;
          }
        }
      }
    }
    ::v-deep .el-switch__label{
      font-weight: 400;
      color:#606266;
    }
    ::v-deep .el-switch.is-checked .el-switch__core{
      border-color:#2272DE!important;
      background-color:#2272DE!important;
    }

  }
  ::v-deep .el-tabs__content{
    >.baseform{
      >form:first-child{
        margin-top: 30px;
      }
    }
  }
</style>
