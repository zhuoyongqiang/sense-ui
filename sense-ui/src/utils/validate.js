import store from '@/store'
/**
 * @param {string} path
 * @returns {Boolean}
 */
export function isExternal(path) {
  return /^(https?:|mailto:|tel:)/.test(path)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validUsername(str) {
  const valid_map = ['admin', 'editor']
  return valid_map.indexOf(str.trim()) >= 0
}

/**
 * @param {string} url
 * @returns {Boolean}
 */
export function validURL(url) {
  const reg = /^(https?|ftp):\/\/([a-zA-Z0-9.-]+(:[a-zA-Z0-9.&%$-]+)*@)*((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|([a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(:[0-9]+)*(\/($|[a-zA-Z0-9.,?'\\+&%$#=~_-]+))*$/
  return reg.test(url)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validLowerCase(str) {
  const reg = /^[a-z]+$/
  return reg.test(str)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validUpperCase(str) {
  const reg = /^[A-Z]+$/
  return reg.test(str)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validAlphabets(str) {
  const reg = /^[A-Za-z]+$/
  return reg.test(str)
}

/**
 * @param {string} email
 * @returns {Boolean}
 */
export function validEmail(email) {
  const reg = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return reg.test(email)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function isString(str) {
  if (typeof str === 'string' || str instanceof String) {
    return true
  }
  return false
}

/**
 * @param {Array} arg
 * @returns {Boolean}
 */
export function isArray(arg) {
  if (typeof Array.isArray === 'undefined') {
    return Object.prototype.toString.call(arg) === '[object Array]'
  }
  return Array.isArray(arg)
}

/**
 * @desc 限制内容长度
 * @param minLength 最小长度
 * @param maxLength 最大长度
 * @param value 值
*/
export function limitLength(minLength, maxLength, value) {
  if (value.length >= minLength && value.length <= maxLength) {
    return true
  } else {
    return false
  }
}

/**
 * @desc limitContent 限制内容
 * @param minLength 最小长度
 * @param maxLength 最大长度
 * @param value 值
 * @param limitType [内容限制规则，REG_NUMBER：数字、REG_UPPERCASE：小写字母、REG_LOWERCASE：大写字母、REG_SYMBOL：特殊符号]
 * @param limitNums 满足限制条件种类
*/

export function limitContent(value, limitType, limitNums) {
  const REG_NUMBER = /\d/
  const REG_UPPERCASE = /[A-Z]/
  const REG_LOWERCASE = /[a-z]/
  const REG_SYMBOL = /[~!@#$%^&*()_+|<>,.?/:;'\[\]\{\}]/
  const result = limitType.reduce((pre, cur) => {
    if (eval(cur).test(value)) {
      pre++
    }
    return pre
  }, 0)
  if (result >= limitNums) {
    return true
  } else {
    return false
  }
}

/**
 * @desc 禁止包含账号名或账户名中超过两个正向连续字符的部分
 * @param value 值
*/
export function containsUserName(value, accountNo) {
  const passwdChars = value.toLowerCase()
  const userChars = (accountNo && accountNo.toLowerCase()) || store.state.user.name.toLowerCase()
  if (!accountNo) {
    return true
  }
  if (passwdChars.length) {
    if (passwdChars.includes(userChars)) {
      return false
    } else {
      const passwdCharsArr = [...value.toLowerCase()]
      for (let i = 0; i < passwdCharsArr.length - 2; i++) {
        if (userChars.includes(passwdCharsArr[i] + passwdCharsArr[i + 1] + passwdCharsArr[i + 2] + '')) {
          return false
        }
      }
      return true
    }
  } else {
    return false
  }
}

/**
* 是否包含3个以上键盘连续字符
* @param str
* @return
*/
export function _isKeyBoardContinuousChar(value) {
  const c1 = [
    ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '{', '}', '|'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ':', '"'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', '<', '>', '?']
  ];
  const c2 = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\''],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/']
  ];
  const str = [...value.toLowerCase()];
  //获取坐标位置
  let yPos = [];
  let xPos = [];
  for (let c = 0; c < str.length; c++) {
    yPos[c] = -1;
    for (let i = 0; i < c1.length; i++) {
      for (let j = 0; j < c1[i].length; j++) {
        if (str[c] == c1[i][j]) {
          // console.log(str[c], ':', c1[i][j])
          // console.log(i)
          // console.log(j)
          xPos[c] = i;
          yPos[c] = j;
        }
      }
    }
    // 在表1中没找到，到表二中去找，找到则continue
    if (yPos[c] != -1) continue;
    for (let i = 0; i < c2.length; i++) {
      for (let j = 0; j < c2[i].length; j++) {
        if (str[c] == c2[i][j]) {
          // console.log(str[c], ':', c2[i][j])
          // console.log(i)
          // console.log(j)
          xPos[c] = i;
          yPos[c] = j;
        }
      }
    }
  }
  //匹配坐标连线
  for (let j = 1; j <= str.length - 3; j++) {
    //同一行
    // console.log('同一行', xPos[j - 1] == xPos[j] && xPos[j] == xPos[j + 1] && xPos[j + 1] == xPos[j + 2], str[j], xPos[j - 1], xPos[j], xPos[j + 1], xPos[j + 2])
    if (xPos[j - 1] == xPos[j] && xPos[j] == xPos[j + 1] && xPos[j + 1] == xPos[j + 2]) {
       // 键盘行正向连续（asdf）或者键盘行反向连续（fdsa）
      if ((yPos[j - 1] + 1 == yPos[j] && yPos[j] + 1 == yPos[j + 1] && yPos[j + 1] + 1 == yPos[j + 2])
          || (yPos[j - 1] - 1 == yPos[j] && yPos[j] - 1 == yPos[j + 1] && yPos[j + 1] - 1 == yPos[j + 2])) {
        return true;
      }
    }
     //同一列
    //  console.log('同一列', yPos[j - 1] == yPos[j] && yPos[j] == yPos[j + 1] && yPos[j + 1] == yPos[j + 2] )
     if (yPos[j - 1] == yPos[j] && yPos[j] == yPos[j + 1] && yPos[j + 1] == yPos[j + 2] ) {
        //键盘列连续（1qaz）或者键盘列反向连续（zaq1）
        if ((xPos[j - 1] + 1 == xPos[j] && xPos[j] + 1 == xPos[j + 1] && xPos[j + 1] + 1 == xPos[j + 2]) 
            || (xPos[j - 1] - 1 == xPos[j] && xPos[j] - 1 == xPos[j + 1] && xPos[j + 1] - 1 == xPos[j + 2])) {
          return true;
        }
    }
  }
  return false;
}

/**
 * @desc 是否包含3个以上相同或字典连续字符
 */
export function isContinuousChar(value) {
  const chars = [...value];
  for (let i = 0; i < chars.length - 3; i++) {
    let n1 = chars[i].charCodeAt();
    let n2 = chars[i + 1].charCodeAt();
    let n3 = chars[i + 2].charCodeAt();
    let n4 = chars[i + 3].charCodeAt();
    // 判断重复字符
    if (n1 == n2 && n1 == n3 && n1 == n4) {
      console.log('相同了', n1, n2, n3, n4)
      return true;
    }
    // 判断连续字符： 正序 + 倒序
    if ((n1 + 1 == n2 && n1 + 2 == n3 && n1 + 3 == n4) || (n1 - 1 == n2 && n1 - 2 == n3 && n1 - 3 == n4)) {
      console.log('连续字符： 正序 + 倒序', n1, n2, n3, n4)
      return true;
    }
        
  }
  return false;
}
