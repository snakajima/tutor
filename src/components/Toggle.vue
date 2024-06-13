<template>
  <span @click="$emit('toggle')">
    <span v-if="flag" class="material-icons">keyboard_arrow_up</span>
    <span v-else class="material-icons">keyboard_arrow_down</span>
  </span>
</template>

<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import '@material-design-icons/font/filled.css';

export default defineComponent({
  name: "HomePage",
  components: {},
  props: ['flag'],
  emits: ['toggle'],
  setup(props) {
    return {}
  }
});
</script>

    

