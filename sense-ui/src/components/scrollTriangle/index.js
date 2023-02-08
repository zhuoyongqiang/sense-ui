import Vue from 'vue'
import scrollTriangleEl from './index.vue'

let instance

const initInstance = (element, scrollEl, id) => {
  instance = new (Vue.extend(scrollTriangleEl))({
    el: document.createElement('div'),
    propsData: {
      data: {
        id,
        parentEl: element,
        scrollEl
      }
    }
  })
  if (element === scrollEl) {
    document.body.appendChild(instance.$el)
  } else {
    element.appendChild(instance.$el)
  }
}
const getScrollEventTarget = (element, rootParent = window) => {
  let currentNode = element
  // bugfix, see http://w3help.org/zh-cn/causes/SD9013 and http://stackoverflow.com/questions/17016740/onscroll-function-is-not-working-for-chrome
  while (currentNode && currentNode.tagName !== 'HTML' && currentNode.tagName !== 'BODY' && currentNode.nodeType === 1 && currentNode !== rootParent) {
    const overflowY = scrollTriangle.getComputedStyle(currentNode).overflowY
    if (overflowY === 'scroll' || overflowY === 'auto') {
      return currentNode
    }
    currentNode = currentNode.parentNode
  }
  return rootParent
}

// const scrollTriangle = (ele) => {
//   const {el, scrollEl = el} = ele || {}
//   if (el !== scrollEl) {
//     el.style.position = 'relative'
//   }
//   initInstance(getScrollEventTarget(el), scrollEl)
// }
const scrollTriangle = {
  install: (ele) => {
    if (document.getElementById(ele.id)) {
      instance.init()
    } else {
      const {id, el, scrollEl = el} = ele || {}
      if (el !== scrollEl) {
        el.style.position = 'relative'
      }
      initInstance(getScrollEventTarget(el), scrollEl, id)
    }
  },
  unstall: () => instance.$destroy()
}

scrollTriangle.getComputedStyle = document.defaultView.getComputedStyle.bind(document.defaultView)

export default scrollTriangle
