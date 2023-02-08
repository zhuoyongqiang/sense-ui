import { treeselectNewPro } from "@/api/console/system/user";
import {getGroup} from "@/api/console/system/group";

const orgTree = {
  state: {
    orgData: '',
    sorgData: '',
    groupData: ''
  },

  mutations: {
    SET_ORGDATA: (state, orgdata) => {
      state.orgData = orgdata
    },
    SET_SINGLEORGDATA: (state, treeObj) => {
      state.sorgData = treeObj
    },
    SET_GROUPDATA: (state, groupData) => {
      state.groupData = groupData
    }
  },

  actions: {
    // 获取机构树
    TreeselectNewPro({commit, state}) {
      return new Promise((resolve, reject) => {
        treeselectNewPro().then(res => {
          if (res.code === 200) {
            const org = initTree(res.data)
            console.log('res',  { [ res.data.id]:  res.data.label })
            commit('SET_ORGDATA', org)
            commit('SET_SINGLEORGDATA', treeObj)
            console.log('treeObj', treeObj)
            // localStorage.setItem('orgTree', JSON.stringify(res.data))
            resolve(res)
          } else {
            commit('SET_ORGDATA', 'Error')
            reject(res)
          }
        }).catch(err => {
          console.warn('err', err)
          commit('SET_ORGDATA', 'Error')
          reject(err)
        })
      })
    },
    // 获取常用组
    GetGroup({commit}, tag) {
      return new Promise((resolve, reject) => {
        if (tag && tag === 'clear') {
          commit('SET_GROUPDATA', '')
          resolve()
        } else {
          getGroup().then(res => {
            if (res.code === 200) {
              commit('SET_GROUPDATA', res.data.map(v => {return {...v, label: v.name, qunzu: true}}))
              resolve()
            } else {
              commit('SET_GROUPDATA', 'Error')
              reject()
            }
          }).catch(err => {
            commit('SET_GROUPDATA', 'Error')
            reject(err)
          })
        }
      })
    }
  }
}

  /*************
   * @desc 格式化机构树
   * @function initTree
   */
  let treeObj = {}
  function initTree(data, prevNode, type) {
    if(!prevNode){
      prevNode = {}
        data.map((item)=>{
          treeObj = {...treeObj, [`${item.id}_parent`]: [{...item, children: []}] }
          return item
        })
      
    }
    for (let i = 0; i < data.length; i++) {
      let node = data[i];
      // 递归结束条件
      // node.leaf = !(node.children && node.children.length && node.users && node.users.length) //是否是末级节点
      if ((node.children && node.children.length) || (node.users && node.users.length)) {
        let users = (node.users || []).map((v) => {
          return {
            ...v,
            label: v.nickName,
            prevNode: { ...prevNode, [node.id]: node.label } ,
            pid: node.id,
            group: false
          };
        });
        node.users = users
        node.prevNode = prevNode
        if (node.children) {
          initTree(node.children, { ...prevNode, [node.id]: node.label } )
        }
        node.children = [...(node.children || []), ...users ];
        treeObj = {...treeObj, [node.id]: node.children.map(item=>({...item, leaf: !(item.children && item.children.length)})) }
      }
    }
    return data;
  }
  /******************
       * @desc 格式化常用组织
       * @function initCommonTree
       */
  function initCommonTree (data) {
    const groupData = [];
    let respData = data
    for(var i in respData) {
      let children=[];
      for (var j in respData[i].children) {
        let id=respData[i].children[j].email;
        let group=respData[i].children[j].group;
        let username=respData[i].children[j].name;
        children.push({
          ...respData[i].children[j],
          id: respData[i].id + respData[i].children[j].email,
          label: username,
          group:group,
          nickName: username,
          email: id,
        })
      }
      const node={
        id: respData[i].id,
        label:respData[i].name,
        group:true,
        children:children
      };
      groupData.push(node);
    }
    return groupData;
  }

export default {
  namespaced: true,
  ...orgTree
}
