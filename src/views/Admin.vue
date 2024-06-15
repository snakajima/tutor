<template>
  <div v-for="word in words" :key="word">
    {{ word.word }}
  </div>
</template>
<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import "firebase/firestore";
import { collection, query, where, onSnapshot } from "firebase/firestore";
import "@material-design-icons/font/filled.css";

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  setup() {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const words = ref<Array<any>>([]);
    const refWords = collection(db, "words");
    const q = query(refWords, where("nograph", "==", true));
    const unsub = onSnapshot(q, (collection) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const array: Array<any> = [];
      collection.forEach((doc) => {
        array.push(doc.data());
      });
      words.value = array;
      console.log(array.length);
    });
    onUnmounted(() => {
      unsub();
    });

    return {
      words,
    };
  },
});
</script>
