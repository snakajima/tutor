<template>
  <span class="cursor-pointer" @click="$emit('toggle')">
    <slot></slot>
    <span v-if="flag" class="material-icons translate-y-2">keyboard_arrow_up</span>
    <span v-else class="material-icons translate-y-2">keyboard_arrow_down</span>
  </span>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import "@material-design-icons/font/filled.css";

export default defineComponent({
  name: "HomePage",
  components: {},
  props: {
    flag: {
      type: Boolean,
    },
  },
  emits: ["toggle"],
  setup() {
    return {};
  },
});
</script>
