<template>
  <div class="home">
    <div class="flex items-center justify-center space-x-8">
      Hello
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { getFunctions, httpsCallable } from "firebase/functions";

const functions = getFunctions(undefined, "");
const testFunction = httpsCallable(functions, 'test');

export default defineComponent({
  name: "HomePage",
  components: {},
  setup() {
    const test = async () => {
      const result = await testFunction();
      console.log(result);
    }
    test();
    return {}
  }
});
</script>
