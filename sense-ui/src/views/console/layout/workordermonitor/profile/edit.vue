<template>
 <el-dialog
       title="修改"
       :visible.sync="showInfo"
       width="1000px !important"
       :close-on-click-modal="false"
      >
    <el-form ref="form" :model="form" :rules="rules" label-width="160px">
      <el-row>
      <el-col :span="6">
         <el-form-item label="工单标识" prop="requestId">
            <el-input v-model="form.requestId"/>
          </el-form-item>
      </el-col>
        <el-col :span="6">
          <el-form-item label="节点状态" prop="status">
            <el-select v-model="form.status"
                       size="small"
                       style="width: 100%;"
                       clearable>
              <el-option
                v-for="dict in workOrderStatusOptions"
                :key="dict.dictValue"
                :label="dict.dictLabel"
                :value="dict.dictValue"
              />
            </el-select>
          </el-form-item>
        </el-col>
      <el-col :span="6">
         <el-form-item label="工单状态" prop="status">
            <el-select v-model="form.taskType"
                       size="small"
                       style="width: 100%;"
                       clearable>
              <el-option
                v-for="dict in workOrderStatusOptions"
                :key="dict.dictValue"
                :label="dict.dictLabel"
                :value="dict.dictValue"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="审批节点">
            <el-input v-model="form.nodeName"/>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="8">
          <el-form-item label="流程编号" prop="workflowCode">
            <el-input v-model="form.workflowCode"/>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="批量审批" prop="isBatchApproval">
            <el-select v-model="form.isBatchApproval"
                       size="small"
                       style="width: 100%;"
                       clearable>
              <el-option
                v-for="item in approvalOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value">
              </el-option>
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="紧急程度">
            <el-select v-model="form.requestLevel"
                       size="small"
                       style="width: 100%;"
                       clearable>
              <el-option
                v-for="item in levelOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value">
              </el-option>
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
            <el-form-item label="工单名称" prop="requestName">
              <el-input v-model="form.requestName"/>
            </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
            <el-form-item label="流程名称" prop="workflowName">
              <el-input v-model="form.workflowName"/>
            </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="待办连接(PC)" prop="intranetUrl">
              <el-input v-model="form.intranetUrl"/>
           </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="已办连接(PC)">
            <el-input v-model="form.completedUrl"/>
          </el-form-item>
        </el-col>
      </el-row>


      <el-row>
        <el-col :span="24">
          <el-form-item label="工单连接(移动端)" prop="extranetUrl">
              <el-input v-model="form.extranetUrl"/>
           </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="已办连接(移动端)">
            <el-input v-model="form.extCompletedUrl"/>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="我的申请连接(PC)">
            <el-input v-model="form.applyUrlByPC"/>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="我的申请连接(移动端)">
            <el-input v-model="form.applyUrlByMobile"/>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="8">
          <el-form-item label="系统标识" prop="clientId">
             <el-input v-model="form.clientId"/>
           </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="系统密钥" prop="clientSecret">
            <el-input v-model="form.clientSecret"/>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="所属系统" prop="clientName">
             <el-input v-model="form.clientName"/>
           </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="8">
           <el-form-item label="工单开始时间" prop="startDate">
             <el-date-picker clearable
               style="width:100%"
               v-model="form.startDate"
               format="yyyy-MM-dd HH:mm:ss"
               value-format="yyyy-MM-dd HH:mm:ss"
               type="datetime"
               placeholder="选择工单开始时间">
             </el-date-picker>
           </el-form-item>
        </el-col>
        <el-col :span="8">
           <el-form-item label="工单结束时间" prop="endDate">
             <el-date-picker clearable
                style="width:100%"
                v-model="form.endDate"
                format="yyyy-MM-dd HH:mm:ss"
                value-format="yyyy-MM-dd HH:mm:ss"
                type="datetime"
                placeholder="选择工单结束时间">
              </el-date-picker>
           </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="数据发送时间">
            <el-input v-model="form.operateDate" :disabled="true"/>
          </el-form-item>
        </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="发起人" prop="creator">
              <el-input v-model="form.creator"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="办理人" prop="receivers">
              <el-input v-model="form.receivers"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
              <el-form-item label="是否准入" prop="access">
                 <el-select v-model="form.access"
                            size="small"
                            style="width: 100%;"
                            clearable>
                   <el-option
                     v-for="dict in workOrderAccessOptions"
                     :key="dict.dictValue"
                     :label="dict.dictLabel"
                     :value="dict.dictValue"
                   />
                 </el-select>
               </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="终端类型" prop="terminalType">
                 <el-select v-model="form.terminalType"
                            size="small"
                            style="width: 100%;"
                            clearable>
                   <el-option
                     v-for="dict in workOrderTerminalTypeOptions"
                     :key="dict.dictValue"
                     :label="dict.dictLabel"
                     :value="dict.dictValue"
                   />
                 </el-select>
               </el-form-item>
            </el-col>
        </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="自定义数据" prop="errorMsg">
            <el-input type="textarea" :rows="2" v-model="form.customData"></el-input>
          </el-form-item>
        </el-col>
      </el-row>
        <el-row>
           <el-col :span="24">
             <el-form-item label="准入消息" prop="errorMsg">
                <el-input type="textarea" :rows="2" v-model="form.errorMsg"></el-input>
              </el-form-item>
           </el-col>
        </el-row>
        <el-row>
           <el-col :span="24">
             <el-form-item label="源数据" prop="sourceData">
                <el-input type="textarea" :rows="5" v-model="form.sourceData"></el-input>
              </el-form-item>
           </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submit">保存</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
  </el-dialog>
</template>

<script>
import {findById,update} from "@/api/console/layout/workordermonitor/index";
export default {
  name: "workOrderEdit",
  data() {
    return {
      form:{},
      showInfo:false,
      approvalOptions:[{
        value: '0',
        label: '不支持'
      },{
        value: '1',
        label: '支持'
      }, {
        value: '2',
        label: '不支持'
      }],
      levelOptions:[{
        label:"正常",
        value:0
      },{
        label:"重要",
        value:1
      },{
        label:"紧急",
        value:2
      }],
      /**工单类型字典*/
      workOrderStatusOptions: [],
      /**是否准入*/
      workOrderAccessOptions: [],
      /**工单审批类型*/
      workOrderTerminalTypeOptions: [],
      // 表单校验
      rules: {
        requestName: [
          { required: true, message: "工单名称不能为空", trigger: "blur" }
        ],
        requestId: [
          { required: true, message: "工单标识不能为空", trigger: "blur" }
        ],
        clientId :[
          { required: true, message: "系统标识不能为空", trigger: "blur" }
        ],
        clientName :[
          { required: true, message: "所属系统不能为空", trigger: "blur" }
        ],
        receivers :[
          { required: true, message: "办理人不能为空", trigger: "blur" }
        ],
        creator :[
          { required: true, message: "创建人不能为空", trigger: "blur" }
        ],
        startDate :[
          { required: true, message: "工单开始时间不能为空", trigger: "blur" }
        ],
        clientSecret :[
          { required: true, message: "系统密钥不能为空", trigger: "blur" }
        ]
      }
    };
  },created() {
    this.loadtDicts();
  },
  methods: {
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
   load(id){
      if( this.$refs['form']!== undefined){
          this.$refs['form'].resetFields();
      }
      findById(id).then(response => {
        this.form = {};
        this.form = response.data;
        if(this.form.access){
          this.form.access = response.data.access + "";
        }
        if(this.form.terminalType){
          this.form.terminalType = response.data.terminalType + "";
        }
        if(this.form.isBatchApproval){
          this.form.isBatchApproval = response.data.isBatchApproval + "";
        }else{
          this.form.isBatchApproval = "0"
        }

        this.showInfo=true
      });
   },
   cancel() {
      this.showInfo=false
      this.form={};
   },
   submit() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          update(this.form).then(response => {
            this.msgSuccess("操作成功");
            this.$emit('callback');
            this.cancel();
          });
        }
      });
    }
  }
};
</script>
