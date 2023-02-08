
export default {
  props:{
    data:{
      type:Array,
      default:() => []
    },
    isCollapse:{
      type: Boolean,
      default: false
    },
    activeMenu: {
      type: String,
      default: null
    }
  },
  watch: {
    data: {
      handler(val) {
        // console.log(val)
      },
      deep: true
    },
    activeMenu (val) {
      // console.warn('当前激活的菜单', val)
    }
  },
  computed: {
    openeds () {
      return this.data.map(v => v.id)
    }
  },
  methods: {
    handleOpen(key, keyPath) {
      // console.log(key, keyPath);
    },
    handleClose(key, keyPath) {
      // console.log(key, keyPath);
    },
    handleSelect(key, keyPath) {
      // console.log(key, keyPath);
      this.$emit('handleSelect', key, keyPath)
    }
  },
  render() {
    let renderChildren = (data) => {
      return data.map(child=>{
          return (child.children && child.children.length) ?
          <elSubmenu index={child.id} key={Math.random()}>
              <div slot="title"><i class={child.icon}></i>{child.catalogName}</div>
              {renderChildren(child.children)}
          </elSubmenu> :
          <elMenuItem ref="item" index={child.id} key={Math.random()}>
              <i class={child.icon}></i>{child.catalogName}
          </elMenuItem>
      })
    }
  return <elMenu onOpen={this.handleOpen} onSelect={this.handleSelect} onClose={this.handleClose} default-active={this.activeMenu} default-openeds={this.openeds} isCollapse={this.isCollapse}>
    {renderChildren(this.data)}
  </elMenu>
  }
}