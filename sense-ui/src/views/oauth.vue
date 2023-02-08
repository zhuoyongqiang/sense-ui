<template>
  <div class="wrapper">

    
  </div>
</template>

<script>
import {oauthLogin} from '@/utils/oauth'
import {setToken,setCiamToken} from '@/utils/auth'
export default {
  name: "oauthLogin",
  data() {
    return {
      code :undefined,
    };
  },
  created(){
    if(this.$route.query.code==undefined){
      //CIAM测试服
      // window.location.href="https://stage.identity.bosch.com.cn/ids/connect/authorize?response_type=code&scope=openid%20email%20profile%20phone%20offline_access&client_id=ciamids_1A28E6CC-B6EB-435B-9D3B-A214410A765A&redirect_uri=https://sso.rbtssws.com.cn/oauth&nonce=0815";
      //CIAM正式服
      window.location.href="https://identity.bosch.com.cn/ids/connect/authorize?response_type=code&scope=openid%20email%20profile%20phone%20offline_access&client_id=ciamids_8F62EF2E-4C24-4684-B9E4-F045C4823BD6&redirect_uri=https://sso.rbtssws.com.cn/oauth&nonce=0815";
    }else{
        this.code=this.$route.query.code;
        oauthLogin({code:this.code}).then((resp) => {
          if (this.isIE){
            document.getElementById('input').click()
          }
          if(resp.code==200){
            setToken(resp.data.ssoResult.token);
            setCiamToken(resp.data.ciamToken.id_token);
            window.location.href="/home/index";
          } else {
            if (resp.msg == 'userFound') { 
              window.location.href = "/oautherror";
              setCiamToken(resp.data.ciamToken);
            }
          }
        }).catch((resp) => {
          console.log(resp);
            // this.$router.push({path:'/mobile/home/errPage'}).catch(() =>{});
        });
    }
  },
  methods: {
    
  }
};
</script>

