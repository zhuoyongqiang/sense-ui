import request from '@/utils/request'
export const oauthParams = {
    url:"https://stage.identity.bosch.com.cn/ids/connect/authorize?response_type=code&scope=openid%20email%20profile%20phone%20offline_access&client_id=ciamids_1A28E6CC-B6EB-435B-9D3B-A214410A765A&redirect_uri=https://sso.rbtssws.com.cn/oauth&nonce=0815",

}

// oauth认证登录
export function oauthLogin(params) {
    return request({
        url: '/authModule/authIAM',
        method: 'post',
        params
    })
}


// oauth认证登录
export function exit(data) {
    return request({
        url: '/authModule/exit',
        method: 'post',
        data
    })
}




