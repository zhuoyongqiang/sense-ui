<template>
  <div class="welcome">
    <div class="welcomeTop">
      <div class="welcomeTips publicFlexStart">
        <div class="userImg">
          <img :src="avatar" style="border-radius: 50%" width="60" height="60" alt="" @error="defaultAvatar()">
        </div>
        <div class="userInfo">
          <h3>{{ nowTime }}，{{ nickName }}</h3>
          <p>{{ deptName }}</p>
        </div>
      </div>
      <div class="loginDays">
        <h3>感谢您为厦门国际银行服务了</h3>
        <p>{{ year }} <span>年</span> {{ day }} <span>天</span></p>
      </div>
    </div>
    <div class="welcomeCare">
      <div class="welcomeCareTitle publicFlex">
        <div class="careTitle">
          <span>员工关怀</span>
        </div>
        <div class="publicTitleMore">
          <!--<router-link to='#'>
            <span>更多</span>
            <i class="el-icon-arrow-right"></i>
          </router-link>-->
        </div>
      </div>
      <div class="careMain">
        <ul>
          <li v-for="item in careDate" :key="item.id">
            <div class="publicFlexStart">
              <div class="sedName"><img src="@/assets/images/img_head.png" alt="#" height="33" width="32"></div>
              <div class="careWord">
                <h3 class="publicHidden">{{ item.title }}
                  <img src="@/assets/images/home/icon_love.png" width="14" height="14" alt="">
                </h3>
                <p class="publicHidden">{{ item.main }}</p>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
import {mapGetters} from "vuex";
import {getTodayBirthdayUserList} from "@/api/console/system/user";

export default {
  name: "InfoWelcome",
  props: ['baseFilePath'],
  data() {
    return {
      nowTime: '早上好',
      careDate: [],
      year: 0,
      day: 0,
      defaultAvatarImg: require("@/assets/images/img_head.png")
    }
  },
  created() {
    getTodayBirthdayUserList().then(res => {
      if (res.code == 200) {
        let list = res.data;
        for (let i = 0; i < 2; i++) {
          let obj = {};
          obj.avatar = list[i].avatar;
          obj.title = '祝 ' + list[i].nickName + ' 生日快乐';
          obj.main = '幸福快乐，梦想成真～生日快乐！';
          this.careDate.push(obj);
        }
      }
    });
    this.computeEntryDays();
  },
  computed: {
    ...mapGetters([
      'nickName',
      'avatar',
      'deptName',
      'entryDate'
    ])
  },
  methods: {
    defaultAvatar() {
      let img = event.srcElement;
      img.src = this.defaultAvatarImg;
      img.onerror = null; //防止闪图
    },
    computeEntryDays() {
      let date = this.entryDate;
      if (date != '' && date != undefined && date != null) {
        let userEntryDate = this.stringToDate(date, '-');
        let nowDate = new Date();
        let nowTimes = nowDate.getTime() - userEntryDate.getTime();
        this.year = parseInt(nowTimes / (24 * 60 * 60 * 1000 * 365));
        this.day = parseInt(nowTimes / (24 * 60 * 60 * 1000) - this.year * 365);
      }
    },
    stringToDate: function (dateStr, separator) {
      if (!separator) {
        separator = "-";
      }
      var dateArr = dateStr.split(separator);
      var year = parseInt(dateArr[0]);
      var month;
      //处理月份为04这样的情况
      if (dateArr[1].indexOf("0") == 0) {
        month = parseInt(dateArr[1].substring(1));
      } else {
        month = parseInt(dateArr[1]);
      }
      var day = parseInt(dateArr[2]);
      var date = new Date(year, month - 1, day);
      return date;
    }
  }
}
</script>

<style scoped>
.welcome {
  height: 360px;
  background: #FFFFFF;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 20px;
}

.welcomeTop {
  background: #FFFFFF;
  margin-bottom: 10px;
}

.userImg {
  margin-right: 16px;
  margin-bottom: 10px;
}

.userInfo > h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333333;
  margin-bottom: 8px;
}

.userInfo > p {
  font-size: 14px;
  font-weight: 500;
  color: #797979;
}

.welcomeCare {
  height: 165px;
  background: #FFFFFF;
  box-shadow: 0px -4px 4px 0px rgba(0, 0, 0, 0.04);
  border-radius: 10px 10px 4px 4px;
  padding: 11px 20px 16px 20px;
}

.careTitle {
  font-size: 16px;
  font-weight: 500;
  color: #333333;
}

.welcomeCareTitle {
  margin-bottom: 16px;
}

.careWord {
  margin-left: 16px;
  margin-bottom: 16px;
  width: calc(100% - 60px);
}

.careWord > h3 {
  font-size: 14px;
  font-weight: 500;
  color: #797979;
}

.careWord > h3 > img {
  margin-top: -3px;
}
</style>
