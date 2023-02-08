<script>
export default {
  created() {
    const {query} = this.$route
    let code= query.code;
    let redirect= query.redirect;
    let state= query.state;
    this.$store.dispatch("QyxwLogin", code).then(() => {
			if (redirect != null) {
				redirect = decodeURIComponent(redirect);
				location.href = redirect;
				return;
			}
      this.$router.replace({ path: redirect , query })
    }).catch(() => {});
  },
  render: function(h) {
    return h() // avoid warning message
  }
}
</script>
