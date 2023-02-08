import {login, qywxlogin, logout, getInfo,ssoTgc} from '@/api/login'
import {getToken, setToken, removeToken,getTGC,setTGC} from '@/utils/auth'
import {getConfigKey} from "@/api/home/config";
import Cookies from "js-cookie";
import {Message} from 'element-ui'
const user = {
  state: {
    token: getToken(),
    name: '',
    nickName: '',
    avatar: '',
    roles: [],
    permissions: [],
    deptName: '',
    entryDate: '',
    email: '',
    deptSn:''
  },

  mutations: {
    SET_TOKEN: (state, token) => {
      state.token = token
    },
    SET_NAME: (state, name) => {
      state.name = name
    },
    SET_AVATAR: (state, avatar) => {
      state.avatar = avatar
    },
    SET_ROLES: (state, roles) => {
      console.log(roles);
      state.roles = roles
    },
    SET_PERMISSIONS: (state, permissions) => {
      console.log(permissions);

      state.permissions = permissions
    },
    SET_NICK_NAME: (state, nickName) => {
      state.nickName = nickName;
    },
    SET_DEPT_NAME: (state, deptName) => {
      state.deptName = deptName;
    },
    SET_ENTRY_DATE: (state, entryDate) => {
      state.entryDate = entryDate;
    },
    SET_EMAIL: (state, email) => {
      state.email = email
    },
    SET_DEPT_SN: (state, deptSn) => {
      state.deptSn = deptSn
    },
  },

  actions: {
    // 登录
    Login({commit}, userInfo) {
      const username = userInfo.username.trim()
      const password = userInfo.password
      const code = userInfo.code
      const uuid = userInfo.uuid
      return new Promise((resolve, reject) => {
        login(username, password, code, uuid).then(res => {
          if (res.code == 200) {
            setToken(res.data.token)
            setTGC(res.data.uiap_tgc)
            commit('SET_TOKEN',res.data.token)
            resolve(res)           
          } else {
            Message({
              message: res.msg,
              type: 'error'
            })
            reject()
          }
        })
      })
    },
    // 企业微信登录
    ssoTgc({commit}, tgc) {
      return new Promise((resolve, reject) => {
        ssoTgc(tgc).then(res => {
          if (res.code == 200) {
            setToken(res.data.token)
            commit('SET_TOKEN', res.data.token)
            resolve(res)
          }
        })
      })
    },

    // 企业微信登录
    QyxwLogin({commit}, code) {
      //清空旧登录
      commit('SET_TOKEN', '')
      commit('SET_ROLES', [])
      commit('SET_PERMISSIONS', [])
      removeToken()

      return new Promise((resolve, reject) => {
        qywxlogin(code).then(res => {
          if (res.code == 200) {
            setToken(res.data.token)
            setTGC(res.data.uiap_tgc)
            commit('SET_TOKEN', res.data.token)
            resolve(res)
          } else {
            // Message({
            //   message: res.msg,
            //   type: 'error'
            // })
            reject(res)
          }
        }).catch((err) => {
          reject(err)
        })
      })
    },

    // 获取用户信息
    GetInfo({commit, state}) {
      return new Promise((resolve, reject) => {
        getInfo(state.token).then(res => {
          const user = res.user
          const avatar = user.avatar ? user.avatar : require("@/assets/images/profile.jpg");
          if (user && user.email) commit('SET_EMAIL', user.email)
          if (res.roles && res.roles.length > 0) { // 验证返回的roles是否是一个非空数组
            commit('SET_ROLES', res.roles)
            commit('SET_PERMISSIONS', res.permissions)
          } else {
            commit('SET_ROLES', ['ROLE_DEFAULT'])
          }
          commit('SET_NAME', user.userName)
          commit('SET_NICK_NAME', user.nickName);
          if(user.departmentDept!=null){
            commit('SET_DEPT_NAME',  user.departmentDept.deptName);
            commit('SET_DEPT_SN',  user.departmentDept.sn);
          }else{
            commit('SET_DEPT_NAME', '');
            commit('SET_DEPT_SN', '');
          }
          commit('SET_ENTRY_DATE', user.entryDate);
          const ImgObj = new Image()
          ImgObj.src = avatar
          ImgObj.onload = () => {
            commit('SET_AVATAR', avatar)
          }
          ImgObj.onerror = function() {
            commit('SET_AVATAR', require("@/assets/images/img_head.png"))
          }
          resolve(res)
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 退出系统
    LogOut({commit, state}) {
      return new Promise((resolve, reject) => {
        logout(state.token).then(() => {
          commit('SET_TOKEN', '')
          commit('SET_ROLES', [])
          commit('SET_PERMISSIONS', [])
          removeToken()
          Cookies.remove("subportal_templeteId");
          Cookies.remove("publicRoutes");
          localStorage.removeItem('fontActive')
          resolve()
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 前端 登出
    FedLogOut({commit}) {
      return new Promise(resolve => {
        commit('SET_TOKEN', '')
        removeToken()
        resolve()
      })
    }
  }
}

export default user
