<template>
  <span @click="$emit('toggle')">
    <span v-if="flag" class="material-icons">keyboard_arrow_up</span>
    <span v-else class="material-icons">keyboard_arrow_down</span>
  </span>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import '@material-design-icons/font/filled.css';

export default defineComponent({
  name: "HomePage",
  components: {},
  props: {
    flag: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['toggle'],
  setup() {
    return {}
  }
});
</script>

    

