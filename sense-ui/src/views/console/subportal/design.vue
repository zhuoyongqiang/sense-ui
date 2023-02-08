<template>
  <el-dialog
    :title="designTitle"
    :visible.sync="showInfo"
    width="90% !important"
    :close-on-click-modal="false"
  >
  <div style="padding: 10px;min-height: 400px">
    <el-row class="header-row" style="margin-bottom: 10px">
      <!-- <span>列宽</span> -->
      <!-- <el-input-number v-model="colsNumer"  :min="1" :max="24"></el-input-number> -->
      <el-button type="primary" icon="el-icon-plus" @click="addCols">
        添加模块
      </el-button>
      <span>首页布局遵循左宽右窄的规则</span>
      <el-button style="float: right;" type="primary" @click="save()">保存设计</el-button>
    </el-row>
    <el-row :gutter="20" class="layoutRows">
      <el-row style="margin-bottom: 10px;padding: 50px;text-align: center" v-if="layoutList.length===0">未设计布局</el-row>
      <vab-draggable v-bind="dragOptions" :list="layoutList">
        <el-col v-for="(item) in layoutList" :key="item.id" :span="item.span">
          <div class="grid-content bg-purple alr" :style="{'max-height':item.maxHeight}">
            <el-card class="box-card">
              <div slot="header" class="layouttitle">
                <img :src="item.icon" width="20px" height="20px">
                <span>
                  {{item.title}}
                </span>
                <el-button style="float: right; padding: 3px 0;margin: 0 5px;" type="text" @click="klong(item)"><i class="el-icon-document-copy">克隆</i></el-button>
                <el-button style="float: right; padding: 3px 0;margin: 0 5px;" type="text" @click="editConfig(item)"><i class="el-icon-edit-outline">配置</i></el-button>
                <el-button style="float: right; padding: 3px 0;margin: 0 5px;" type="text" @click="deleteConfig(item)"><i class="el-icon-delete">移除</i></el-button>
              </div>
              <div class="text item">
                设计模式下不显示内容
              </div>
            </el-card>
         </div>
        </el-col>
      </vab-draggable>
    </el-row>

    <!-- 修改配置 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form"  label-width="80px">
        <el-form-item label="模块图标">
          <el-input type="textarea" :rows="2"  v-model="form.icon" placeholder="请输入模块图标"/>
          <p>请输入长宽为20*20的base64图片数据</p>
        </el-form-item>
        <el-form-item label="模块标题">
          <el-input v-model="form.title" placeholder="请输入模块标题"/>
        </el-form-item>
        <!-- <el-form-item label="模块列宽">
          <el-input-number v-model="form.span"  :min="1" :max="24"></el-input-number>
        </el-form-item> -->
        <el-form-item label="模板高度">
          <el-input v-model="form.maxHeight" placeholder="请输入模板高度"/>
        </el-form-item>
        <el-form-item label="模板宽度">
          <el-input v-model="form.span" placeholder="请输入宽度 0-20"/>
        </el-form-item>
        <el-form-item label="内部资源">
          <el-switch
            v-model="form.bindType"
            active-color="#13ce66"
            inactive-color="#d4d4d4">
          </el-switch>
        </el-form-item>
        <el-form-item label="模板选择" v-if="form.bindType">
          <el-select
            v-model="form.sounceType"
            filterable placeholder="请选择">
            <el-option
              v-for="dict in sounceOptions"
              :key="dict.dictValue"
              :label="dict.dictLabel"
              :value="dict.dictValue"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="模板预览" v-if="form.bindType && ['2', '3', '4'].includes(form.sounceType)">
          <!-- 带图片的左右布局 -->
          <el-row v-show="form.sounceType === '3'" style="margin-bottom: 0">
            <el-col :span="8"><div class="grid-img bg-purple"><i class="el-icon-picture-outline"></i></div></el-col>
            <el-col :span="15" :offset="1">
              <div class="grid-content bg-purple"></div>
              <div class="grid-content bg-purple"></div>
              <div class="grid-content bg-purple"></div>
              <div class="grid-content bg-purple"></div>
              <div class="grid-content bg-purple"></div>
            </el-col>
          </el-row>

          <!-- 纯文字布局 -->
          <el-row v-show="form.sounceType === '2'" style="margin-bottom: 0">
            <el-col :span="13"><div class="grid-content bg-purple"></div></el-col><el-col :span="2" :offset="1"><div class="grid-content bg-purple"></div></el-col>
            <el-col :span="13"><div class="grid-content bg-purple"></div></el-col><el-col :span="2" :offset="1"><div class="grid-content bg-purple"></div></el-col>
            <el-col :span="13"><div class="grid-content bg-purple"></div></el-col><el-col :span="2" :offset="1"><div class="grid-content bg-purple"></div></el-col>
            <el-col :span="13"><div class="grid-content bg-purple"></div></el-col><el-col :span="2" :offset="1"><div class="grid-content bg-purple"></div></el-col>
            <el-col :span="13"><div class="grid-content bg-purple"></div></el-col><el-col :span="2" :offset="1"><div class="grid-content bg-purple"></div></el-col>
          </el-row>

          <!-- 小型幻灯片布局 -->
          <el-row v-show="form.sounceType === '4'" style="margin-bottom: 0">
            <el-col :span="16"><div class="grid-img bg-purple"><i class="el-icon-picture-outline"></i></div></el-col>
            <el-col :span="16" class="gridPoint-wrapper">
              <el-row type="flex" class="row-bg" justify="center">
                <el-col :span="1"><div class="grid-point bg-purple"></div></el-col>
                <el-col :span="1"><div class="grid-point bg-purple"></div></el-col>
                <el-col :span="1"><div class="grid-point bg-purple"></div></el-col>
                <el-col :span="1"><div class="grid-point bg-purple"></div></el-col>
              </el-row>
            </el-col>
          </el-row>

        </el-form-item>
        <el-form-item label="过滤条件" v-if="form.bindType && ['5', '6', '7', '10'].every(v => form.sounceType != v)">
          <el-row style="margin-bottom: 0">
            <el-col :span="12">
              <el-input v-model="form.bindParam" :disabled="bindParam !== 'custom'"></el-input>
            </el-col>
            <el-col :span="11" :offset="1">
              <el-select v-model="bindParam" placeholder="请选择">
                <el-option
                  v-for="b in bindParmoptions"
                  :key="b.id"
                  :label="b.name"
                  :value="b.id">
                </el-option>
              </el-select>
            </el-col>
          </el-row>
          <div style="font-size: 12px;color:#E54141" v-if="form.bindType && (['5', '6', '7'].includes(form.sounceType) || bindParam == '1009')">该模板仅在用户登录后才展示</div>
        </el-form-item>
        <el-form-item label="显示数量" v-if="form.bindType">
          <el-input v-model="form.bindNumber"></el-input>
        </el-form-item>
        <el-form-item label="外部类型" v-if="form.bindType===undefined || form.bindType===false">
          <el-select v-model="form.externalType" filterable placeholder="请选择外部类型">
            <el-option label="iframe" value="1"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="外部地址" v-if="form.bindType===undefined || form.bindType===false">
          <el-input v-model="form.intenetlink" placeholder="请输入外部地址"/>
        </el-form-item>

        <el-form-item label="更多连接">
          <el-switch
            v-model="form.isMore"
            active-color="#13ce66"
            inactive-color="#d4d4d4">
          </el-switch>
        </el-form-item>
        <el-form-item label="跳转方式" v-if="form.isMore">
          <el-select v-model="form.linkType" filterable placeholder="请选择跳转方式" style="width: 100%">
            <el-option label="当前窗口" value="1"></el-option>
            <el-option label="新窗口" value="2"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="更多名称" v-if="form.isMore">
          <el-input v-model="form.moreName" placeholder="请输入更多名称"/>
        </el-form-item>
        <el-form-item label="更多地址" v-if="form.isMore">
          <el-input v-model="form.morelink" placeholder="请输入更多地址"/>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="cancel">关 闭</el-button>
        <el-button type="primary" @click="saveItem">保 存</el-button>
      </div>
    </el-dialog>
    </div>
  </el-dialog>
</template>

<script>
import {save,get} from "@/api/subportal/index";
import {allNewsType} from "@/api/home/newsType";
import {getToken} from "@/utils/auth";
import '@/assets/styles/home/home.css'
import VabDraggable from 'vuedraggable'
export default {
  name: 'subportalIndex',
  components: {
    VabDraggable,
  },
  computed: {
    dragOptions() {
      return {
        templeteId: '',
        animation: 600,
        group: 'description',
      }
    },
  },
  data() {
    return {
      designTitle: '',
      showInfo: false,
      title:"配置",
      open: false,
      form: {},
      colsNumer: 12,
      layoutList: [],
      sounceOptions: [],
      bindParmoptions: [], // 过滤条件
      bindParam: ''
    }
  },
  created () {
    allNewsType({isMore: 1}).then(response => {
      if (response.code == 200) {
        this.bindParmoptions = response.data;
        this.bindParmoptions.unshift({id: 'isCarousel', name: '首页幻灯片'})
        this.bindParmoptions.push({id: 'custom', name: '自定义'});
      }
    })
  },
  watch: {
    bindParam (val) {
      if (val === 'isCarousel') {
        this.form.bindParam = '{"isCarousel": 1}'
      } else if (+val) {
        this.form.bindParam = `{"newsTypeId": ${+val}}`
      }
    },
    'form.sounceType' (val) {
      if (['5', '6', '7', '10'].includes(val)) {
        this.bindParam = 'custom'
        this.form.bindParam = ''
      }
    }
  },
  methods: {
    showDesign(row){
      this.templeteId=row.sn;
      this.designTitle="布局设计【"+row.title+"】"
      this.showInfo=true
      this.get()
      this.sounceOptions = [];
      this.getDicts("subportal_resources").then(response => {
        this.sounceOptions = response.data;
      });
    },
    get(){
      this.layoutList = []
      get(this.templeteId).then(response => {
        if(response.code===200) {

          if(response.data!==undefined) {
            if (response.data.subLayout !== null) {
              if (response.data.subLayout.layout !== null) {
                this.layoutList = response.data.subLayout.layout;
                for (let i in this.layoutList) {
                  if (this.layoutList[i].sounceType !== undefined) {
                    this.layoutList[i].sounceType = this.layoutList[i].sounceType + '';
                  }
                  if (this.layoutList[i].linkType !== undefined) {
                    this.layoutList[i].linkType = this.layoutList[i].linkType + '';
                  }
                  if (this.layoutList[i].externalType !== undefined) {
                    this.layoutList[i].externalType = this.layoutList[i].externalType + '';
                  }
                }
              }
            }
          }
        }
      });
    },
    klong(item){
      this.$confirm('克隆【'+item.title+'】, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const id = this.uuid();
        let layoutRow= {
          id:id,
          icon:item.icon,
          title:item.title,
          span:item.span,
          maxHeight:item.maxHeight,
          isMore:item.isMore,
          linkType:item.linkType,
          moreName:item.moreName,
          morelink:item.morelink,
          bindType:item.bindType,
          sounceType:item.sounceType,
          content: '设计方式不显示',
          bindParam:item.bindParam,
          bindNumber:item.bindNumber,
          externalType:item.externalType,
          intenetlink:item.intenetlink,

        }
        layoutRow.title=item.title+"-新克隆"
        this.layoutList.push(layoutRow)
      }).catch(() => {});
    },
    addCols(){
      const  id = this.uuid();
      let layoutRow= {
        id:id,
        icon:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABhSURBVEhLY/hPZzAwFn7c1Pg/PikNL45Laf4//wVYDxyQow9s4Y0pyVgVo+Pq82A9cECOvlELUfCohbjwCLSQ7hmfnmDUQqqDgUk0wz8fjloIw6MW4sIDb+FobUE98P8/AMA2WYh7YWeiAAAAAElFTkSuQmCC",
        title:"自定义标题",
        span: 24,
        maxHeight:'340px',
        isMore:false,
        linkType:"1",
        moreName:"更多",
        bindType:false,
        sounceType:"1",
        content: '设计方式不显示',
        bindParam:"",
        bindNumber:5,
        externalType:"1",
        intenetlink:"",
        morelink:''
      }
      this.layoutList.push(layoutRow)
    },
    editConfig(item){
      this.open = true;
      this.form = {
        id:item.id,
        icon:item.icon,
        title:item.title,
        span:item.span,
        maxHeight:item.maxHeight,
        isMore:item.isMore,
        linkType:item.linkType,
        moreName:item.moreName,
        bindType:item.bindType,
        sounceType:item.sounceType,
        content: '设计方式不显示',
        bindParam:item.bindParam,
        bindNumber:item.bindNumber,
        externalType:item.externalType,
        intenetlink:item.intenetlink,
        morelink:item.morelink,
      }
      
      if (item.bindParam && item.bindParam.includes('newsTypeId') && JSON.parse(item.bindParam)) {
        this.bindParam = '' + JSON.parse(item.bindParam).newsTypeId
      } else if (item.sounceType == '1') {
        this.bindParam = 'isCarousel'
      } else {
        this.bindParam = 'custom'
      }
      this.title='编辑【'+item.title+"】"
    },
    deleteConfig(item){
      this.$confirm('此操作将移除【'+item.title+'】, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        for(let i in this.layoutList){
          if(this.layoutList[i].id===item.id){
            this.layoutList.splice(i,1);
            this.$message({
              type: 'success',
              message: '移除成功!'
            });
            return;
          }
        }
      }).catch(() => {});
    },
    uuid() {
      var s = [];
      var hexDigits = "0123456789abcdef";
      for (var i = 0; i < 36; i++) {
        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
      }
      s[14] = "4"; // bits 12-15 of the time_hi_and_version field to 0010
      s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1); // bits 6-7 of the clock_seq_hi_and_reserved to 01
      s[8] = s[13] = s[18] = s[23] = "-";
      var uuid = s.join("");
      return uuid;
    },
    cancel(){
      this.open=false;
      this.form={}
    },
    saveItem(){
      let item=this.form;
      for(let i in this.layoutList){
        if(this.layoutList[i].id===item.id){
          this.layoutList[i].icon=item.icon
          this.layoutList[i].title=item.title
          this.layoutList[i].span=item.span
          this.layoutList[i].maxHeight=item.maxHeight
          this.layoutList[i].isMore=item.isMore
          this.layoutList[i].linkType=item.linkType
          this.layoutList[i].moreName=item.moreName
          this.layoutList[i].bindType=item.bindType
          this.layoutList[i].sounceType=item.sounceType
          this.layoutList[i].content='设计方式不显示'
          this.layoutList[i].bindParam=item.bindParam
          this.layoutList[i].bindNumber=item.bindNumber
          this.layoutList[i].externalType=item.externalType
          this.layoutList[i].intenetlink=item.intenetlink
          this.layoutList[i].morelink=item.morelink
          this.msgSuccess("保存成功")
          this.cancel();
          return;
        }
      }
    },
    save(){
      let data = {
        templateId:this.templeteId,
        layout:this.layoutList
      }
      save(data).then(response => {
        if(response.code === 200){
          this.msgSuccess("保存成功")
          this.showInfo = false
        }else{
          this.msgError(response.msg)
        }
      });
    }
  }
}
</script>
<style lang="scss" scoped>
  .header-row{
    >div{
      margin-right: 10px;
    }
    >span{
      margin: 0 10px
    }
  }
  .alr{
    min-height: 100px;
    background: #ddd;
    margin-bottom: 20px;
  }
  .layouttitle img{
    vertical-align: sub;
  }
  .layouttitle span{
    font-size: 18px;
    font-weight: 600;
    color: #333333;
  }

  .el-row {
    margin-bottom: 20px;
    &:last-child {
      margin-bottom: 0;
    }
  }
  .el-col {
    border-radius: 4px;
  }
  .bg-purple-dark {
    background: #99a9bf;
  }
  .bg-purple {
    background: #d3dce6;
  }
  .bg-purple-light {
    background: #e5e9f2;
  }
  .grid-img{
    height: 80px;
    line-height: 80px;
    text-align: center;
    i{
      font-size: 32px;
      vertical-align: middle;
    }
  }
  .grid-content {
    border-radius: 4px;
    height: 8px;
    margin-bottom: 10px;
  }
  .grid-point{
    width: 6px;
    height: 2px;
    border-radius: 4px;
  }
  .row-bg {
    padding: 10px 0;
    background-color: #f9fafc;
  }
</style>
