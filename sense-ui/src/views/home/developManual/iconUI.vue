<template>
  <div>
    <ul class="icon-list">
      <li @click="confirm(item)" v-for="item in list" :key="item.iconClass"><span><i :class="item.iconClass"></i><span class="icon-name">{{item.iconClass}}</span></span></li>
    </ul>
  </div>
</template>
<script>
export default {
  data () {
    return {
      list: [
        // {
        //   iconClass: 'el-icon-platform-eleme',
        //   iconName: 'el-icon-platform-eleme'
        // },
        // {
        //   iconClass: 'el-icon-eleme',
        //   iconName: 'el-icon-eleme'
        // },
        {
          iconClass: 'el-icon-delete-solid',
          iconName: 'el-icon-delete-solid'
        },
        {
          iconClass: 'el-icon-delete',
          iconName: 'el-icon-delete'
        },
        {
          iconClass: 'el-icon-s-tools',
          iconName: 'el-icon-s-tools'
        },
        {
          iconClass: 'el-icon-setting',
          iconName: 'el-icon-setting'
        },
        {
          iconClass: 'el-icon-user-solid',
          iconName: 'el-icon-user-solid'
        },
        {
          iconClass: 'el-icon-user',
          iconName: 'el-icon-user'
        },
        {
          iconClass: 'el-icon-phone',
          iconName: 'el-icon-phone'
        },
        {
          iconClass: 'el-icon-phone-outline',
          iconName: 'el-icon-phone-outline'
        },
        {
          iconClass: 'el-icon-more',
          iconName: 'el-icon-more'
        },
        {
          iconClass: 'el-icon-more-outline',
          iconName: 'el-icon-more-outline'
        },
        {
          iconClass: 'el-icon-star-on',
          iconName: 'el-icon-star-on'
        },
        {
          iconClass: 'el-icon-star-off',
          iconName: 'el-icon-star-off'
        },
        {
          iconClass: 'el-icon-s-goods',
          iconName: 'el-icon-s-goods'
        },
        {
          iconClass: 'el-icon-goods',
          iconName: 'el-icon-goods'
        },
        {
          iconClass: 'el-icon-warning',
          iconName: 'el-icon-warning'
        },
        {
          iconClass: 'el-icon-warning-outline',
          iconName: 'el-icon-warning-outline'
        },
        {
          iconClass: 'el-icon-question',
          iconName: 'el-icon-question'
        },
        {
          iconClass: 'el-icon-info',
          iconName: 'el-icon-info'
        },
        {
          iconClass: 'el-icon-remove',
          iconName: 'el-icon-remove'
        },
        {
          iconClass: 'el-icon-circle-plus',
          iconName: 'el-icon-circle-plus'
        },
        {
          iconClass: 'el-icon-success',
          iconName: 'el-icon-success'
        },
        {
          iconClass: 'el-icon-error',
          iconName: 'el-icon-error'
        },
        {
          iconClass: 'el-icon-zoom-in',
          iconName: 'el-icon-zoom-in'
        },
        {
          iconClass: 'el-icon-zoom-out',
          iconName: 'el-icon-zoom-out'
        },
        {
          iconClass: 'el-icon-remove-outline',
          iconName: 'el-icon-remove-outline'
        },
        {
          iconClass: 'el-icon-circle-plus-outline',
          iconName: 'el-icon-circle-plus-outline'
        },
        {
          iconClass: 'el-icon-circle-check',
          iconName: 'el-icon-circle-check'
        },
        {
          iconClass: 'el-icon-circle-close',
          iconName: 'el-icon-circle-close'
        },
        {
          iconClass: 'el-icon-s-help',
          iconName: 'el-icon-s-help'
        },
        {
          iconClass: 'el-icon-help',
          iconName: 'el-icon-help'
        },
        {
          iconClass: 'el-icon-minus',
          iconName: 'el-icon-minus'
        },
        {
          iconClass: 'el-icon-plus',
          iconName: 'el-icon-plus'
        },
        {
          iconClass: 'el-icon-check',
          iconName: 'el-icon-check'
        },
        {
          iconClass: 'el-icon-close',
          iconName: 'el-icon-close'
        },
        {
          iconClass: 'el-icon-picture',
          iconName: 'el-icon-picture'
        },
        {
          iconClass: 'el-icon-picture-outline',
          iconName: 'el-icon-picture-outline'
        },
        {
          iconClass: 'el-icon-picture-outline-round',
          iconName: 'el-icon-picture-outline-round'
        },
        {
          iconClass: 'el-icon-upload',
          iconName: 'el-icon-upload'
        },
        {
          iconClass: 'el-icon-upload2',
          iconName: 'el-icon-upload2'
        },
        {
          iconClass: 'el-icon-download',
          iconName: 'el-icon-download'
        },
        {
          iconClass: 'el-icon-camera-solid',
          iconName: 'el-icon-camera-solid'
        },
        {
          iconClass: 'el-icon-camera',
          iconName: 'el-icon-camera'
        },
        {
          iconClass: 'el-icon-video-camera-solid',
          iconName: 'el-icon-video-camera-solid'
        },
        {
          iconClass: 'el-icon-video-camera',
          iconName: 'el-icon-video-camera'
        },
        {
          iconClass: 'el-icon-message-solid',
          iconName: 'el-icon-message-solid'
        },
        {
          iconClass: 'el-icon-bell',
          iconName: 'el-icon-bell'
        },
        {
          iconClass: 'el-icon-s-cooperation',
          iconName: 'el-icon-s-cooperation'
        },
        {
          iconClass: 'el-icon-s-order',
          iconName: 'el-icon-s-order'
        },
        {
          iconClass: 'el-icon-s-platform',
          iconName: 'el-icon-s-platform'
        },
        {
          iconClass: 'el-icon-s-fold',
          iconName: 'el-icon-s-fold'
        },
        {
          iconClass: 'el-icon-s-unfold',
          iconName: 'el-icon-s-unfold'
        },
        {
          iconClass: 'el-icon-s-operation',
          iconName: 'el-icon-s-operation'
        },
        {
          iconClass: 'el-icon-s-promotion',
          iconName: 'el-icon-s-promotion'
        },
        {
          iconClass: 'el-icon-s-home',
          iconName: 'el-icon-s-home'
        },
        {
          iconClass: 'el-icon-s-release',
          iconName: 'el-icon-s-release'
        },
        {
          iconClass: 'el-icon-s-ticket',
          iconName: 'el-icon-s-ticket'
        },
        {
          iconClass: 'el-icon-s-management',
          iconName: 'el-icon-s-management'
        },
        {
          iconClass: 'el-icon-s-open',
          iconName: 'el-icon-s-open'
        },
        {
          iconClass: 'el-icon-s-shop',
          iconName: 'el-icon-s-shop'
        },
        {
          iconClass: 'el-icon-s-marketing',
          iconName: 'el-icon-s-marketing'
        },
        {
          iconClass: 'el-icon-s-flag',
          iconName: 'el-icon-s-flag'
        },
        {
          iconClass: 'el-icon-s-comment',
          iconName: 'el-icon-s-comment'
        },
        {
          iconClass: 'el-icon-s-finance',
          iconName: 'el-icon-s-finance'
        },
        {
          iconClass: 'el-icon-s-claim',
          iconName: 'el-icon-s-claim'
        },
        {
          iconClass: 'el-icon-s-custom',
          iconName: 'el-icon-s-custom'
        },
        {
          iconClass: 'el-icon-s-opportunity',
          iconName: 'el-icon-s-opportunity'
        },
        {
          iconClass: 'el-icon-s-data',
          iconName: 'el-icon-s-data'
        },
        {
          iconClass: 'el-icon-s-check',
          iconName: 'el-icon-s-check'
        },
        {
          iconClass: 'el-icon-s-grid',
          iconName: 'el-icon-s-grid'
        },
        {
          iconClass: 'el-icon-menu',
          iconName: 'el-icon-menu'
        },
        {
          iconClass: 'el-icon-share',
          iconName: 'el-icon-share'
        },
        {
          iconClass: 'el-icon-d-caret',
          iconName: 'el-icon-d-caret'
        },
        {
          iconClass: 'el-icon-caret-left',
          iconName: 'el-icon-caret-left'
        },
        {
          iconClass: 'el-icon-caret-right',
          iconName: 'el-icon-caret-right'
        },
        {
          iconClass: 'el-icon-caret-bottom',
          iconName: 'el-icon-caret-bottom'
        },
        {
          iconClass: 'el-icon-top',
          iconName: 'el-icon-top'
        },
        {
          iconClass: 'el-icon-top-left',
          iconName: 'el-icon-top-left'
        },
        {
          iconClass: 'el-icon-top-right',
          iconName: 'el-icon-top-right'
        },
        {
          iconClass: 'el-icon-arrow-left',
          iconName: 'el-icon-arrow-left'
        },
        {
          iconClass: 'el-icon-arrow-right',
          iconName: 'el-icon-arrow-right'
        },
        {
          iconClass: 'el-icon-arrow-down',
          iconName: 'el-icon-arrow-down'
        },
        {
          iconClass: 'el-icon-arrow-up',
          iconName: 'el-icon-arrow-up'
        },
        {
          iconClass: 'el-icon-d-arrow-left',
          iconName: 'el-icon-d-arrow-left'
        },
        {
          iconClass: 'el-icon-d-arrow-right',
          iconName: 'el-icon-d-arrow-right'
        },
        {
          iconClass: 'el-icon-video-pause',
          iconName: 'el-icon-video-pause'
        },
        {
          iconClass: 'el-icon-video-play',
          iconName: 'el-icon-video-play'
        },
        {
          iconClass: 'el-icon-refresh',
          iconName: 'el-icon-refresh'
        },
        {
          iconClass: 'el-icon-refresh-right',
          iconName: 'el-icon-refresh-right'
        },
        {
          iconClass: 'el-icon-refresh-left',
          iconName: 'el-icon-refresh-left'
        },
        {
          iconClass: 'el-icon-finished',
          iconName: 'el-icon-finished'
        },
        {
          iconClass: 'el-icon-sort',
          iconName: 'el-icon-sort'
        },
        {
          iconClass: 'el-icon-sort-up',
          iconName: 'el-icon-sort-up'
        },
        {
          iconClass: 'el-icon-sort-down',
          iconName: 'el-icon-sort-down'
        },
        {
          iconClass: 'el-icon-rank',
          iconName: 'el-icon-rank'
        },
        {
          iconClass: 'el-icon-loading',
          iconName: 'el-icon-loading'
        },
        {
          iconClass: 'el-icon-view',
          iconName: 'el-icon-view'
        },
        {
          iconClass: 'el-icon-c-scale-to-original',
          iconName: 'el-icon-c-scale-to-original'
        },
        {
          iconClass: 'el-icon-date',
          iconName: 'el-icon-date'
        },
        {
          iconClass: 'el-icon-edit',
          iconName: 'el-icon-edit'
        },
        {
          iconClass: 'el-icon-edit-outline',
          iconName: 'el-icon-edit-outline'
        },
        {
          iconClass: 'el-icon-folder',
          iconName: 'el-icon-folder'
        },
        {
          iconClass: 'el-icon-folder-opened',
          iconName: 'el-icon-folder-opened'
        },
        {
          iconClass: 'el-icon-folder-add',
          iconName: 'el-icon-folder-add'
        },
        {
          iconClass: 'el-icon-folder-remove',
          iconName: 'el-icon-folder-remove'
        },
        {
          iconClass: 'el-icon-folder-delete',
          iconName: 'el-icon-folder-delete'
        },
        {
          iconClass: 'el-icon-folder-checked',
          iconName: 'el-icon-folder-checked'
        },
        {
          iconClass: 'el-icon-tickets',
          iconName: 'el-icon-tickets'
        },
        {
          iconClass: 'el-icon-document-remove',
          iconName: 'el-icon-document-remove'
        },
        {
          iconClass: 'el-icon-document-delete',
          iconName: 'el-icon-document-delete'
        },
        {
          iconClass: 'el-icon-document-checked',
          iconName: 'el-icon-document-checked'
        },
        {
          iconClass: 'el-icon-document',
          iconName: 'el-icon-document'
        },
        {
          iconClass: 'el-icon-document-add',
          iconName: 'el-icon-document-add'
        },
        {
          iconClass: 'el-icon-printer',
          iconName: 'el-icon-printer'
        },
        {
          iconClass: 'el-icon-paperclip',
          iconName: 'el-icon-paperclip'
        },
        {
          iconClass: 'el-icon-takeaway-box',
          iconName: 'el-icon-takeaway-box'
        },
        {
          iconClass: 'el-icon-search',
          iconName: 'el-icon-search'
        },
        {
          iconClass: 'el-icon-monitor',
          iconName: 'el-icon-monitor'
        },
        {
          iconClass: 'el-icon-attract',
          iconName: 'el-icon-attract'
        },
        {
          iconClass: 'el-icon-mobile',
          iconName: 'el-icon-mobile'
        },
        {
          iconClass: 'el-icon-scissors',
          iconName: 'el-icon-scissors'
        },
        {
          iconClass: 'el-icon-umbrella',
          iconName: 'el-icon-umbrella'
        },
        {
          iconClass: 'el-icon-headset',
          iconName: 'el-icon-headset'
        },
        {
          iconClass: 'el-icon-brush',
          iconName: 'el-icon-brush'
        },
        {
          iconClass: 'el-icon-mouse',
          iconName: 'el-icon-mouse'
        },
        {
          iconClass: 'el-icon-coordinate',
          iconName: 'el-icon-coordinate'
        },
        {
          iconClass: 'el-icon-magic-stick',
          iconName: 'el-icon-magic-stick'
        },
        {
          iconClass: 'el-icon-reading',
          iconName: 'el-icon-reading'
        },
        {
          iconClass: 'el-icon-data-line',
          iconName: 'el-icon-data-line'
        },
        {
          iconClass: 'el-icon-data-board',
          iconName: 'el-icon-data-board'
        },
        {
          iconClass: 'el-icon-pie-chart',
          iconName: 'el-icon-pie-chart'
        },
        {
          iconClass: 'el-icon-data-analysis',
          iconName: 'el-icon-data-analysis'
        },
        {
          iconClass: 'el-icon-collection-tag',
          iconName: 'el-icon-collection-tag'
        },
        {
          iconClass: 'el-icon-film',
          iconName: 'el-icon-film'
        },
        {
          iconClass: 'el-icon-suitcase',
          iconName: 'el-icon-suitcase'
        },
        {
          iconClass: 'el-icon-suitcase-1',
          iconName: 'el-icon-suitcase-1'
        },
        {
          iconClass: 'el-icon-receiving',
          iconName: 'el-icon-receiving'
        },
        {
          iconClass: 'el-icon-collection',
          iconName: 'el-icon-collection'
        },
        {
          iconClass: 'el-icon-files',
          iconName: 'el-icon-files'
        },
        {
          iconClass: 'el-icon-notebook-1',
          iconName: 'el-icon-notebook-1'
        },
        {
          iconClass: 'el-icon-notebook-2',
          iconName: 'el-icon-notebook-2'
        },
        {
          iconClass: 'el-icon-toilet-paper',
          iconName: 'el-icon-toilet-paper'
        },
        {
          iconClass: 'el-icon-office-building',
          iconName: 'el-icon-office-building'
        },
        {
          iconClass: 'el-icon-school',
          iconName: 'el-icon-school'
        },
        {
          iconClass: 'el-icon-table-lamp',
          iconName: 'el-icon-table-lamp'
        },
        {
          iconClass: 'el-icon-house',
          iconName: 'el-icon-house'
        },
        {
          iconClass: 'el-icon-no-smoking',
          iconName: 'el-icon-no-smoking'
        },
        {
          iconClass: 'el-icon-smoking',
          iconName: 'el-icon-smoking'
        },
        {
          iconClass: 'el-icon-shopping-cart-full',
          iconName: 'el-icon-shopping-cart-full'
        },
        {
          iconClass: 'el-icon-shopping-cart-1',
          iconName: 'el-icon-shopping-cart-1'
        },
        {
          iconClass: 'el-icon-shopping-cart-2',
          iconName: 'el-icon-shopping-cart-2'
        },
        {
          iconClass: 'el-icon-shopping-bag-1',
          iconName: 'el-icon-shopping-bag-1'
        },
        {
          iconClass: 'el-icon-shopping-bag-2',
          iconName: 'el-icon-shopping-bag-2'
        },
        {
          iconClass: 'el-icon-sold-out',
          iconName: 'el-icon-sold-out'
        },
        {
          iconClass: 'el-icon-sell',
          iconName: 'el-icon-sell'
        },
        {
          iconClass: 'el-icon-present',
          iconName: 'el-icon-present'
        },
        {
          iconClass: 'el-icon-box',
          iconName: 'el-icon-box'
        },
        {
          iconClass: 'el-icon-bank-card',
          iconName: 'el-icon-bank-card'
        },
        {
          iconClass: 'el-icon-money',
          iconName: 'el-icon-money'
        },
        {
          iconClass: 'el-icon-coin',
          iconName: 'el-icon-coin'
        },
        {
          iconClass: 'el-icon-wallet',
          iconName: 'el-icon-wallet'
        },
        {
          iconClass: 'el-icon-discount',
          iconName: 'el-icon-discount'
        },
        {
          iconClass: 'el-icon-price-tag',
          iconName: 'el-icon-price-tag'
        },
        {
          iconClass: 'el-icon-news',
          iconName: 'el-icon-news'
        },
        {
          iconClass: 'el-icon-guide',
          iconName: 'el-icon-guide'
        },
        {
          iconClass: 'el-icon-male',
          iconName: 'el-icon-male'
        },
        {
          iconClass: 'el-icon-female',
          iconName: 'el-icon-female'
        },
        {
          iconClass: 'el-icon-thumb',
          iconName: 'el-icon-thumb'
        },
        {
          iconClass: 'el-icon-cpu',
          iconName: 'el-icon-cpu'
        },
        {
          iconClass: 'el-icon-link',
          iconName: 'el-icon-link'
        },
        {
          iconClass: 'el-icon-connection',
          iconName: 'el-icon-connection'
        },
        {
          iconClass: 'el-icon-open',
          iconName: 'el-icon-open'
        },
        {
          iconClass: 'el-icon-turn-off',
          iconName: 'el-icon-turn-off'
        },
        {
          iconClass: 'el-icon-set-up',
          iconName: 'el-icon-set-up'
        },
        {
          iconClass: 'el-icon-chat-round',
          iconName: 'el-icon-chat-round'
        },
        {
          iconClass: 'el-icon-chat-line-round',
          iconName: 'el-icon-chat-line-round'
        },
        {
          iconClass: 'el-icon-chat-square',
          iconName: 'el-icon-chat-square'
        },
        {
          iconClass: 'el-icon-chat-dot-round',
          iconName: 'el-icon-chat-dot-round'
        },
        {
          iconClass: 'el-icon-chat-dot-square',
          iconName: 'el-icon-chat-dot-square'
        },
        {
          iconClass: 'el-icon-chat-line-square',
          iconName: 'el-icon-chat-line-square'
        },
        {
          iconClass: 'el-icon-message',
          iconName: 'el-icon-message'
        },
        {
          iconClass: 'el-icon-postcard',
          iconName: 'el-icon-postcard'
        },
        {
          iconClass: 'el-icon-position',
          iconName: 'el-icon-position'
        },
        {
          iconClass: 'el-icon-turn-off-microphone',
          iconName: 'el-icon-turn-off-microphone'
        },
        {
          iconClass: 'el-icon-microphone',
          iconName: 'el-icon-microphone'
        },
        {
          iconClass: 'el-icon-close-notification',
          iconName: 'el-icon-close-notification'
        },
        {
          iconClass: 'el-icon-bangzhu',
          iconName: 'el-icon-bangzhu'
        },
        {
          iconClass: 'el-icon-time',
          iconName: 'el-icon-time'
        },
        {
          iconClass: 'el-icon-odometer',
          iconName: 'el-icon-odometer'
        },
        {
          iconClass: 'el-icon-crop',
          iconName: 'el-icon-crop'
        },
        {
          iconClass: 'el-icon-aim',
          iconName: 'el-icon-aim'
        },
        {
          iconClass: 'el-icon-switch-button',
          iconName: 'el-icon-switch-button'
        },
        {
          iconClass: 'el-icon-full-screen',
          iconName: 'el-icon-full-screen'
        },
        {
          iconClass: 'el-icon-copy-document',
          iconName: 'el-icon-copy-document'
        },
        {
          iconClass: 'el-icon-mic',
          iconName: 'el-icon-mic'
        },
        {
          iconClass: 'el-icon-stopwatch',
          iconName: 'el-icon-stopwatch'
        },
        {
          iconClass: 'el-icon-medal-1',
          iconName: 'el-icon-medal-1'
        },
        {
          iconClass: 'el-icon-medal',
          iconName: 'el-icon-medal'
        },
        {
          iconClass: 'el-icon-trophy',
          iconName: 'el-icon-trophy'
        },
        {
          iconClass: 'el-icon-trophy-1',
          iconName: 'el-icon-trophy-1'
        },
        {
          iconClass: 'el-icon-first-aid-kit',
          iconName: 'el-icon-first-aid-kit'
        },
        {
          iconClass: 'el-icon-discover',
          iconName: 'el-icon-discover'
        },
        {
          iconClass: 'el-icon-place',
          iconName: 'el-icon-place'
        },
        {
          iconClass: 'el-icon-location',
          iconName: 'el-icon-location'
        },
        {
          iconClass: 'el-icon-location-outline',
          iconName: 'el-icon-location-outline'
        },
        {
          iconClass: 'el-icon-location-information',
          iconName: 'el-icon-location-information'
        },
        {
          iconClass: 'el-icon-add-location',
          iconName: 'el-icon-add-location'
        },
        {
          iconClass: 'el-icon-delete-location',
          iconName: 'el-icon-delete-location'
        },
        {
          iconClass: 'el-icon-map-location',
          iconName: 'el-icon-map-location'
        },
        {
          iconClass: 'el-icon-alarm-clock',
          iconName: 'el-icon-alarm-clock'
        },
        {
          iconClass: 'el-icon-timer',
          iconName: 'el-icon-timer'
        },
        {
          iconClass: 'el-icon-watch-1',
          iconName: 'el-icon-watch-1'
        },
        {
          iconClass: 'el-icon-watch',
          iconName: 'el-icon-watch'
        },
        {
          iconClass: 'el-icon-lock',
          iconName: 'el-icon-lock'
        },
        {
          iconClass: 'el-icon-unlock',
          iconName: 'el-icon-unlock'
        },
        {
          iconClass: 'el-icon-key',
          iconName: 'el-icon-key'
        },
        {
          iconClass: 'el-icon-service',
          iconName: 'el-icon-service'
        },
        {
          iconClass: 'el-icon-mobile-phone',
          iconName: 'el-icon-mobile-phone'
        },
        {
          iconClass: 'el-icon-bicycle',
          iconName: 'el-icon-bicycle'
        },
        {
          iconClass: 'el-icon-truck',
          iconName: 'el-icon-truck'
        },
        {
          iconClass: 'el-icon-ship',
          iconName: 'el-icon-ship'
        },
        {
          iconClass: 'el-icon-basketball',
          iconName: 'el-icon-basketball'
        },
        {
          iconClass: 'el-icon-football',
          iconName: 'el-icon-football'
        },
        {
          iconClass: 'el-icon-soccer',
          iconName: 'el-icon-soccer'
        },
        {
          iconClass: 'el-icon-baseball',
          iconName: 'el-icon-baseball'
        },
        {
          iconClass: 'el-icon-wind-power',
          iconName: 'el-icon-wind-power'
        },
        {
          iconClass: 'el-icon-light-rain',
          iconName: 'el-icon-light-rain'
        },
        {
          iconClass: 'el-icon-lightning',
          iconName: 'el-icon-lightning'
        },
        {
          iconClass: 'el-icon-heavy-rain',
          iconName: 'el-icon-heavy-rain'
        },
        {
          iconClass: 'el-icon-sunrise',
          iconName: 'el-icon-sunrise'
        },
        {
          iconClass: 'el-icon-sunrise-1',
          iconName: 'el-icon-sunrise-1'
        },
        {
          iconClass: 'el-icon-sunset',
          iconName: 'el-icon-sunset'
        },
        {
          iconClass: 'el-icon-sunny',
          iconName: 'el-icon-sunny'
        },
        {
          iconClass: 'el-icon-cloudy',
          iconName: 'el-icon-cloudy'
        },
        {
          iconClass: 'el-icon-partly-cloudy',
          iconName: 'el-icon-partly-cloudy'
        },
        {
          iconClass: 'el-icon-cloudy-and-sunny',
          iconName: 'el-icon-cloudy-and-sunny'
        },
        {
          iconClass: 'el-icon-moon',
          iconName: 'el-icon-moon'
        },
        {
          iconClass: 'el-icon-moon-night',
          iconName: 'el-icon-moon-night'
        },
        {
          iconClass: 'el-icon-dish',
          iconName: 'el-icon-dish'
        },
        {
          iconClass: 'el-icon-dish-1',
          iconName: 'el-icon-dish-1'
        },
        {
          iconClass: 'el-icon-food',
          iconName: 'el-icon-food'
        },
        {
          iconClass: 'el-icon-chicken',
          iconName: 'el-icon-chicken'
        },
        {
          iconClass: 'el-icon-fork-spoon',
          iconName: 'el-icon-fork-spoon'
        },
        {
          iconClass: 'el-icon-knife-fork',
          iconName: 'el-icon-knife-fork'
        },
        {
          iconClass: 'el-icon-burger',
          iconName: 'el-icon-burger'
        },
        {
          iconClass: 'el-icon-tableware',
          iconName: 'el-icon-tableware'
        },
        {
          iconClass: 'el-icon-sugar',
          iconName: 'el-icon-sugar'
        },
        {
          iconClass: 'el-icon-dessert',
          iconName: 'el-icon-dessert'
        },
        {
          iconClass: 'el-icon-ice-cream',
          iconName: 'el-icon-ice-cream'
        },
        {
          iconClass: 'el-icon-hot-water',
          iconName: 'el-icon-hot-water'
        },
        {
          iconClass: 'el-icon-water-cup',
          iconName: 'el-icon-water-cup'
        },
        {
          iconClass: 'el-icon-coffee-cup',
          iconName: 'el-icon-coffee-cup'
        },
        {
          iconClass: 'el-icon-cold-drink',
          iconName: 'el-icon-cold-drink'
        },
        {
          iconClass: 'el-icon-goblet',
          iconName: 'el-icon-goblet'
        },
        {
          iconClass: 'el-icon-goblet-full',
          iconName: 'el-icon-goblet-full'
        },
        {
          iconClass: 'el-icon-goblet-square',
          iconName: 'el-icon-goblet-square'
        },
        {
          iconClass: 'el-icon-goblet-square-full',
          iconName: 'el-icon-goblet-square-full'
        },
        {
          iconClass: 'el-icon-refrigerator',
          iconName: 'el-icon-refrigerator'
        },
        {
          iconClass: 'el-icon-grape',
          iconName: 'el-icon-grape'
        },
        {
          iconClass: 'el-icon-watermelon',
          iconName: 'el-icon-watermelon'
        },
        {
          iconClass: 'el-icon-cherry',
          iconName: 'el-icon-cherry'
        },
        {
          iconClass: 'el-icon-apple',
          iconName: 'el-icon-apple'
        },
        {
          iconClass: 'el-icon-pear',
          iconName: 'el-icon-pear'
        },
        {
          iconClass: 'el-icon-orange',
          iconName: 'el-icon-orange'
        },
        {
          iconClass: 'el-icon-coffee',
          iconName: 'el-icon-coffee'
        },
        {
          iconClass: 'el-icon-ice-tea',
          iconName: 'el-icon-ice-tea'
        },
        {
          iconClass: 'el-icon-ice-drink',
          iconName: 'el-icon-ice-drink'
        },
        {
          iconClass: 'el-icon-milk-tea',
          iconName: 'el-icon-milk-tea'
        },
        {
          iconClass: 'el-icon-potato-strips',
          iconName: 'el-icon-potato-strips'
        },
        {
          iconClass: 'el-icon-lollipop',
          iconName: 'el-icon-lollipop'
        },
        {
          iconClass: 'el-icon-ice-cream-square',
          iconName: 'el-icon-ice-cream-square'
        },
        {
          iconClass: 'el-icon-ice-cream-round',
          iconName: 'el-icon-ice-cream-round'
        }

      ]
    }
  },
  methods: {
    confirm (item) {
      this.$emit('confrimIcon', item)
    }
  }
}
</script>
<style scoped lang="scss">
  .icon-list{
    background-color: #fff;
    overflow: hidden;
    list-style: none;
    list-style-position: initial;
    list-style-image: initial;
    list-style-type: none;
    padding: 0!important;
    border: 1px solid #eaeefb;
    border-right: none;
    border-radius: 4px;
  }
  .icon-list li {
    float: left;
    width: 16.66%;
    text-align: center;
    height: 120px;
    line-height: 120px;
    color: #666;
    font-size: 13px;
    border-right: 1px solid #eee;
    border-bottom: 1px solid #eee;
    // margin-right: -1px;
    // margin-bottom: -1px;
    cursor: pointer;
  }
  .icon-list li:after, .icon-list li span {
    display: inline-block;
    vertical-align: middle;
  }
  .icon-list li i {
    display: block;
    font-size: 32px;
    margin-bottom: 15px;
    color: #606266;
    transition: color .15s linear;
  }
  .icon-list li span {
    line-height: normal;
    font-family: Helvetica Neue,Helvetica,PingFang SC,Hiragino Sans GB,Microsoft YaHei,SimSun,sans-serif;
    color: #99a9bf;
    transition: color .15s linear;
  }
  .icon-list li .icon-name {
    display: inline-block;
    padding: 0 3px;
    height: 1em;
  }
  .icon-list li:hover i, .icon-list li:hover span {
    color: #5cb6ff;
  }
</style>