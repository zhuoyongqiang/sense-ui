<template>
  <div class="flag" :style="{'overflow': 'hidden','max-height':maxHeight,'height':maxHeight}">
    <div class="publicFlex publicBorder">
      <div class="publicTitle">
        <img :src="icon" width="20" height="20" alt="">
        <span>{{ title }}</span>
      </div>
      <div class="publicTitleMore" v-if="isMore">
        <a :href="morelink" :target="linkType === 1 ?'_self':'_blank'">
          <span>
         {{moreName}}<i class="el-icon-arrow-right"></i>
          </span>
        </a>
      </div>
    </div>
    <div class="flagContent publicContent publicFlex">
      <iframe :src="url"  frameborder="no" border="0" marginwidth="0" marginheight="0" scrolling="no" :style="{'width': '100%','height':maxHeight}"></iframe>
    </div>
  </div>
</template>

<script>
  export default {
    name: "infoIframe",
    props: ['maxHeight','icon', 'title', 'url', 'params',"moreName",'morelink','linkType','isMore'],
    data() {
    },
    methods: {
      showMore() {
        //判断是本窗口打开还是新窗口打开连接
       if(this.linkType===1){
          location.href=this.morelink;
        }else{
          window.open(this.morelink)
        }
      }
    }
  }
</script>

<style scoped>


  .flag {
    height: 300px;
  }

  .flagContent > ul > li {
    width: 100%;
    margin-bottom: 16px;
    cursor: pointer;
  }

  .flagImg {
    width: 150px;
  }

  .flagNews {
    width: calc(100% - 150px);
  }

  .flagContent > ul > li:hover .flagNews > h3 {
    color: #0B86F1 !important;
  }

  .flagNews > h3 {
    font-size: 14px;
    font-weight: 600;
    color: #333333;
    margin-bottom: 40px;
  }

  .flagNews > p {
    font-size: 14px;
    font-weight: 500;
    color: #797979;
  }

  .flagContent ul li + li > div:first-child {
    display: none;
  }

  .flagContent ul li:not(:first-child) .flagNews > h3 {
    font-size: 14px;
    font-weight: 500;
    color: #333333;
    float: left;
    margin-bottom: 0;
    width: 72%;
  }

  .flagContent ul li:not(:first-child) .flagNews {
    width: 100%;
  }

  .flagContent ul li:not(:first-child) .flagNews > p {
    color: #999999;
    float: right;
    width: 24%;
    text-align: right;
  }

  .newsImg {
    margin-right: 20px;
    width: 350px;
  }

  .newsImg > img {
    width: 100%;
  }

  .windowList {
    width: 370px;
  }

  .windowTime {
    text-align: right !important;
  }

  .windowList li:first-child span:first-child {
    font-size: 16px;
    font-weight: 600;
    color: #333333;
    display: -webkit-box;
    white-space: normal;
    -webkit-line-clamp: 1;
    line-clamp: 1;
    -webkit-box-orient: vertical;
  }

  .windowTitle {
    font-size: 14px;
    font-weight: 500;
    color: #333333;
    width: 355px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    box-sizing: border-box;
    margin-right: 10px;
    display: inline-block;
    max-height: 44px;
  }

  .windowTime {
    font-size: 14px;
    font-weight: 500;
    color: #999999;
    width: 45px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    box-sizing: border-box
  }

  .news-icon {
    background-image: url("~@/../src/assets/images/mobile/window/new.png");
    display: inline-block;
    background-size: 100% 100%;
    width: 28px;
    height: 14px;
    vertical-align: middle;
    margin-right: 3px;
    margin-bottom: 2px;
  }

</style>
