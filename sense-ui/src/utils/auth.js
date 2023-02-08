import Cookies from 'js-cookie'

const TokenKey = 'Admin-Token'
const QrKey = 'Qr-Code'
const uiap_tgc = 'UIAP-TGC'
const CiamToken = 'Ciam-Token'


export function getTGC() {
  return Cookies.get(uiap_tgc)
}

export function setTGC(tgc) {

  var domain, host;
  var host = location.hostname;
  var ip = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
  //如果是IP则直接设置cookie
  if (ip.test(host) === true || host === 'localhost'){
    return Cookies.set(uiap_tgc,tgc)
  }
  var regex = /([^]*).*!/;
  var match = host.match(regex);
  if (typeof match !== "undefined" && null !== match) host = match[1];
  if (typeof host !== "undefined" && null !== host) {
    var strAry = host.split(".");
    if(strAry.length >= 4){
      host = strAry[strAry.length - 3] + "." + strAry[strAry.length - 2] + "." + strAry[strAry.length - 1];
      domain = '.' + host;
    }
    else if (strAry.length == 3) {
      host = strAry[strAry.length - 2] + "." + strAry[strAry.length - 1];
      domain = '.' + host;
    }else{
      domain = host;
    }
  }
  return  Cookies.set(uiap_tgc, tgc, {  path: '/', domain:domain});

}


export function getToken() {
  return Cookies.get(TokenKey)
}

export function setToken(token) {
  return Cookies.set(TokenKey, token)
}


export function getCiamToken() {
  return Cookies.get(CiamToken)
}

export function setCiamToken(token) {
  return Cookies.set(CiamToken, token)
}

export function removeToken() {
  Cookies.remove(TokenKey)
  var domain, host;
  var host = location.hostname;
  var ip = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
  //如果是IP则直接remove cookie
  if (ip.test(host) === true || host === 'localhost'){
    Cookies.remove(uiap_tgc)
    return  true;
  }
  var regex = /([^]*).*!/;
  var match = host.match(regex);
  if (typeof match !== "undefined" && null !== match) host = match[1];
  if (typeof host !== "undefined" && null !== host) {
    var strAry = host.split(".");
    if(strAry.length >= 4){
      host = strAry[strAry.length - 3] + "." + strAry[strAry.length - 2] + "." + strAry[strAry.length - 1];
      domain = '.' + host;
    }
    else if (strAry.length == 3) {
      host = strAry[strAry.length - 2] + "." + strAry[strAry.length - 1];
      domain = '.' + host;
    }else{
      domain = host;
    }
  }

  Cookies.remove(uiap_tgc, {path: '/', domain:domain})
  Cookies.remove("subportal_templeteId")
  return true
}

export function setCode(Code) {
  return Cookies.set(QrKey, Code)
}

export function getCode() {
  return Cookies.get(QrKey)
}
