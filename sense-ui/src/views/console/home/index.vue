<template>
<div class="app-container">
    <div class="welcome">
    </div>
</div>
</template>

<script>
export default {
    name:'welcome',
    data(){
        return{

        }
    }
}
</script>

<style lang="scss" scoped>
.welcome{
    position: fixed;
    top:50px;
    right:0;
    bottom:0;
    left:200px;
    background-image: url("../../../assets/images/img_welcome.png");
    background-size:100% 100%;
    text-align: center;
    padding-top:20px ;
    font-size: 50px;
    color:#0bbcf1;
    letter-spacing: 2px;
}

</style>


