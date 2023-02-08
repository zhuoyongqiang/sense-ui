<template>
  <div>
    <svg-icon icon-class="question" @click="goto"/>
  </div>
</template>

<script>
export default {
  name: 'senseDoc',
  data() {
    return {
      url: 'http://doc.sense.vip/sense-vue'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>