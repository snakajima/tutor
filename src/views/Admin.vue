<template>
  <div v-for="word in words" :key="word">
    {{ word.word }}
  </div>
</template>
<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getDocs, getFirestore } from "firebase/firestore";
import "firebase/firestore";
import { collection, doc, getDoc, onSnapshot } from "firebase/firestore";
import "@material-design-icons/font/filled.css";

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  setup() {
    const words = ref<Array<any>>([]);
    const refWords = collection(db, "words");
    const unsub = onSnapshot(refWords, (collection) => {
      const array:Array<any> = [];
        collection.forEach((doc) => {
        array.push(doc.data());
      });
      words.value = array;
    });
    onUnmounted(() => {
      unsub();
    });

    return {
      words
    };
  },
});
</script>
