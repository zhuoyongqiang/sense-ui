<template>
  <div class="windowTemplate">
    <el-row>
      <navbar :currentPage="currentPage"></navbar>
    </el-row>
    <el-row>
      <div class="search">
        <div class="search_type">
          <el-input placeholder="请输入内容" size="small" v-model="search" class="input-with-select">
            <el-select  v-model="searchSelect" slot="prepend" >
              <el-option label="搜索名称" value="1"></el-option>
              <el-option label="搜索作者" value="2"></el-option>
              <el-option label="搜索正文" value="3"></el-option>
            </el-select>
            <el-button slot="append" icon="el-icon-search" @click="handleQuery"></el-button>
          </el-input>
        </div>
      </div>
    </el-row>
    <el-row>
      <div class="search_two">
          <el-select v-model="queryParams.type" size="small" style="width:150px" placeholder="" @change="handleQuery" >
          <el-option
            v-for="item in meterialTypes"
            :key="item.id"
            :label="item.name"
            :value="item.id">
          </el-option>
        </el-select>
        <el-select v-model="queryParams.orderSql" size="small" style="width:150px" placeholder="" @change="handleQuery" >
          <el-option
            v-for="item in searchOrder"
            :key="item.key"
            :label="item.value"
            :value="item.key">
          </el-option>
        </el-select>
         <el-date-picker
          style="width:150px"
          v-model="queryParams.releaseStartTime"
          align="right"
          type="date"
          value-format="yyyy-MM-dd"
          placeholder="发布开始时间"
          @change="handleQuery"
          :picker-options="pickerOptions">
        </el-date-picker>
      </div>
    </el-row>
    <el-row>
       <el-tabs  class="window_tabs" v-model="queryParams.belongingType" lazy="true" @tab-click="tabClick">
        <el-tab-pane v-for="item in downLoadTypeList" v-if="checkPermi([item.viewRoleKey]) || item.viewRoleKey=='all'" :key="item.sn" :label="item.name" :name="item.sn">
        <div class="window_tabsMain">
          <ul class="publicFlexBetwee" style="height:100%;"  v-loading="loading">
            <li class="downloadList"  v-for="item in downloadList" :key="item.id" @click="handleDetail(item)">
              <div class="newsImg" @click="checkImage(item)">
                  <img v-if="item.isTop=='1'" src="../../../assets/download/top.png" class="newsImg-top" >
                  <div class="downImage" >
                    <el-image   :src="baseFilePath+item.thumbnil" fit="fit" style="width: 100%; height: 140px;vertical-align: middle;">
                      <img slot="error" style="width: 100%; height: 140px;" src="@/assets/images/thumbnail.png">
                    </el-image>
                  </div>
                  <div class="newsMain" >
                    <el-tooltip class="item" effect="dark" transition="el-fade-in-linear" :content="item.name" placement="top">
                      <h3 class="publicHidden">{{ item.name }}</h3>
                    </el-tooltip>
                  </div>
                  <div class="newsBottom">
                      <span><i class="el-icon-view"></i>&nbsp;
                        <span v-if="item.browseNum<1000" v-text="item.browseNum"></span>
                        <span v-else v-text="(item.browseNum/1000).toFixed(1)+'K'"></span>
                      </span>
                      <span><i class="el-icon-download"></i>&nbsp;
                        <span v-if="item.downloadNum<1000" v-text="item.downloadNum"></span>
                        <span v-else v-text="(item.downloadNum/1000).toFixed(1)+'K'"></span>
                      </span>
                  </div>
              </div>
            </li>
            <div v-show="!loading && !total" class="emptyMain" >
              <img src="@/assets/images/empty.png" alt=""  >
              <p style="
                  color: #9e9e9e;
                  font-size: 14px;
              ">暂无相关内容</p>
            </div>
          </ul>
        </div>
         <div class="page"  v-show="!loading">
          <pagination
          v-show="total>0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          @pagination="list">
          </pagination>
        </div>
       </el-tab-pane>
      </el-tabs>
    </el-row>
  </div>
</template>

<script>
import $ from 'jquery';
import navbar from '@/views/home/component/navbar'
import {listMeterial,editBrowseNum} from "@/api/console/download/meterial";
import {allMeterialType} from "@/api/console/download/meterialType";
import {allMeterialCategory} from "@/api/console/download/meterialCategory";
import {checkPermi } from "@/utils/permission";
export default {
  name: "downLoadTemplate",
  components: {navbar},
  data() {
    return {
      windowTitle: undefined,
      currentNewsTypeId: undefined,
      downLoadTypeList: [],
      downloadList: [],
      currentPage: ['下载中心'],
      loading: false,
      total: 0,
      meterialType:undefined,
      //类型
      meterialTypes:[],
      // 查询参数
      queryParams: {
        isLikeQuery:true,
        pageNum: 1,
        pageSize: 20,
        status:'1',
        type:null,
        name: null,
        uploadUserName:null,
        releaseType:null,
        orderSql:null,
        belongingType:'all',
        roleKeys:[],
        releaseStartTime:null
      },
      //文件显示前缀
      baseFilePath:undefined,
      //查询条件
      searchSelect:'1',
      search:undefined,
      searchTimes:[
        {key:null,value:'全部时间'},
        {key:'day',value:'今天'},
        {key:'week',value:'最近一周'},
        {key:'month',value:'最近一个月'},
      ],
      searchOrder:[
        {key:null,value:'综合排序'},
        {key:'meterial.create_time asc',value:'时间升序'},
        {key:'meterial.create_time desc',value:'时间降序'},
      ],
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() > Date.now();
        },
        shortcuts: [{
          text: '今天',
          onClick(picker) {
            picker.$emit('pick', new Date());
          }
        }, {
          text: '昨天',
          onClick(picker) {
            const date = new Date();
            date.setTime(date.getTime() - 3600 * 1000 * 24);
            picker.$emit('pick', date);
          }
        }, {
          text: '一周前',
          onClick(picker) {
            const date = new Date();
            date.setTime(date.getTime() - 3600 * 1000 * 24 * 7);
            picker.$emit('pick', date);
          }
        },{
          text: '一月前',
          onClick(picker) {
            const date = new Date();
            date.setTime(date.getTime() - 3600 * 1000 * 24 * 7 * 30);
            picker.$emit('pick', date);
          }
        }]
      },
    }
  },
  mounted: function () {
    this.menuHide();//需要触发的函数
  },
  created() {
    this.queryParams.belongingType = this.$route.params && this.$route.params.type;
     //下载中心类型
    allMeterialCategory({status:1}).then(response=>{
      //确认权限类型
      this.downLoadTypeList = response;
      this.downLoadTypeList.forEach(element => {
        if(checkPermi([element.viewRoleKey])){
          this.queryParams.roleKeys.push(element.sn);
        }
      });
      if(this.queryParams.roleKeys.length<=0){
        this.$message.error("您没有权限访问");
        this.$router.push("/home/index");
        return;
      }
      this.downLoadTypeList.unshift({
        viewRoleKey:'all',
        name:'全部',
        sn:'all'
      });
      this.list();
    })
    //素材中心类型
    allMeterialType({status:'1',belongingType:this.queryParams.belongingType}).then(resp=>{
      this.meterialTypes = resp;
      this.meterialTypes.unshift({
        id:null,
        name:'全部类型'
      })
    });
    //图片前缀
    this.getConfigKey('file_download_url').then(response => {
      this.baseFilePath = response.msg;
    });
  },
  methods: {
    //权限
    checkPermi,
    list() {
      if (this.$parent && this.$parent.$refs && this.$parent.$refs.routerView) this.$parent.$refs.routerView.scrollTop = 0;
      this.loading = true
      this.downloadList = [];
      listMeterial(this.queryParams).then(response => {
        this.downloadList = response.rows;
        this.total = response.total;
        this.loading = false
      }).catch(err => {
        this.loading = false
      })
    },
    raest(){
      this.queryParams.pageNum=1;
      this.queryParams.type=null;
      this.queryParams.name=null;
      this.queryParams.uploadUserName=null;
      this.queryParams.releaseType=null;
      this.queryParams.orderSql=null;
      this.queryParams.releaseStartTime=null;
    },
    //文件下载
    handleFileDownload(item){
      let link = document.createElement('a');
      link.href= this.baseFilePath+item.p;
      link.download=item.fileName;
      link.click();
      window.URL.revokeObjectURL(item.fileUrl);
      //更新下载量
      updateMeterialDownloadNum({id:item.id}).then(resp=>{
        if(resp.code==200){
          item.downloadNum=item.downloadNum+1;
        }
      })
    },
    //搜索
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.queryParams.name=null;
      this.queryParams.uploadUserName=null;
      if(this.searchSelect=='1'){
        this.queryParams.name=this.search;
      }else if(this.searchSelect=='2'){
        this.queryParams.uploadUserName=this.search;
      }else if(this.searchSelect=='3'){
        this.queryParams.content=this.search;
      }
      this.list();
    },
    //这个事件要绑定el-image父级盒子上
    checkImage(item){
      let dom=document.querySelector('.el-image-viewer__actions__inner');
      $(dom).append(`<a href=`+item.fileUrl+` download=`+item.fileName+`><i class="el-icon-download" ></i></a>`);
    },
    handleSizeChange(val) {
      this.list();
    },
    handleCurrentChange(val) {
      this.list();
    },
    tabClick(tab, event) {
      this.raest();
      this.queryParams.belongingType=tab.name;
      //素材中心类型
      allMeterialType({status:'1',belongingType: tab.name}).then(resp=>{
        this.meterialTypes = resp;
        this.meterialTypes.unshift({
          id:null,
          name:'全部类型'
        });
      });
      this.handleQuery();
    },
    menuHide() {
      this.menu == false;
    },
    handleDetail(item) {
      editBrowseNum(item).then(resp=>{
        if (resp.code==200) {
          item.browseNum++;
        }
      })
      window.open('/home/meterialDetail/' + item.id);
    }
  }
}
</script>

<style lang="scss" scoped>
  ::v-deep .navbar-wrapper{
    width: 1200px;
    margin: 0 auto;
  }
  .search_time{
    position: absolute;
    top: 105px;
    right: 10%;
    z-index: 100;
    .el-dropdown-link{
      font-size: 14px;
      font-weight: 500;

    }
  }
  .search{
    width: 1200px;
    height: 70px;
    margin: 0px auto;
    .search_type{
      width:40%;
      height: 40px;
      margin:0px auto;
      ::v-deep .el-select  .el-input {
        width: 110px;
      }
      .input-with-select .el-input-group__prepend {
        background-color: #fff;

      }
    }
  }
  .search_two{
    width: 1200px;
    height: 40px;
    margin: 0px auto;
    ::v-deep
    .el-input__inner{
      border: none;
      font-size: 14px;
      font-weight: bold;
    }
    .select__caret{
      font-size: 15px;
    }
    ::v-deep .el-icon-arrow-up:before {
      content: "\e790";
    }
    ::v-deepinput::-webkit-input-placeholder{
      color:#606266;
    }

    ::v-deep input::-moz-placeholder {
      color: #606266;
    }

    ::v-deepinput:-moz-placeholder {
      color: #606266;
    }
  }
 .el-dropdown-link{
   position: relative;
 }
.windowTemplate {
  // min-width: 1280px;
  background: #ffffff;
  padding-bottom:30px ;
}

.windowTitle {
  margin: 0 auto;
  height: 60px;
  line-height: 60px;
  font-size: 12px;
  text-align: right;
}

.windowTitle, .window_tabsMain {
  width: 100%;
  padding: 0 calc((100% - 1200px)/2);
  top: 0;
  background-color: #f6f6f6;
  margin-bottom:20px ;
  height: 990px;
}
.window_tabs{
  height: auto;
  width: 100%;
  margin: 0px auto;
  padding: 0 calc((100% - 1200px)/2);

}

.pagination-container {
  height: 32px;
  padding: 0 !important;
}

.el-breadcrumb {
  line-height: 60px;
}

::v-deep .publicHidden{
  border-bottom: none!important;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

::v-deep .el-button--goon {
  background: url('../../../assets/download/download.png') center no-repeat;
  height: 28px;
  color: #414441;
  background-color: #d9d9d9;
  border-color: #d9d9d9;
}

.el-button--goon:hover {
  background: url('../../../assets/download/download_white.png') center no-repeat;
  color: rgb(246, 241, 248);
  background-color: #7c8181;
  border-color: #7c8181;
}

::v-deep .el-button--goon {
  background: url('../../../assets/download/download.png') center no-repeat;
  height: 28px;
  color: #414441;
  background-color: #d9d9d9;
  border-color: #d9d9d9;
}

.downloadList {
  margin-top: 20px;
  width: 25%;
  height: 200px;
  display: inline-block;
  .newsImg{
    position: relative;
    box-shadow: 4px 4px 4px 1px   rgba(0, 0, 0, 0.12);
    margin: 0px auto;
    height: 205px;
    text-align: center;
    width: 90%;
    background-color: #fff;
    display: block;
    align-items: center;
    padding: 10px;
    cursor: pointer;
    .downImage{
      height: 140px;
      width: 140px;
      margin:0px auto;
      text-align: center;
    }
    .newsImg-top{
      position: absolute;
      top:0;
      left: 0;
      z-index:100;
      color:black;
    }
  }
}
.emptyMain{
  width: 100%;
  color: #a5a5a5;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  position: absolute;
  text-align: center;
}
.newsMain{
  height: 30px;
  line-height: 30px;
}
.newsMain > h3 {
  font-size: 13px;
  color: #3C3C3C;
  overflow: hidden;
}
.newsBottom{
  color: #3C3C3C;
  font-weight:bold;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: space-around;
  height: 20px;
}
.newsdown{
  width: 100%;
  height: 48px;
  line-height: 38px;
}
</style>
