<template>
  <div class="wrapper">
    
  </div>
</template>

<script>
export default {
  name: "logout",
  data() {
    return {
      code :undefined,
    };
  },
  created(){
    this.$store.dispatch('LogOut').then(() => {
      window.location.href="/oauth";
    });
  },
};
</script>

