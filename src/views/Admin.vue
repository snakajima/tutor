<template>
  <div>admin2</div>
  <div v-for="word in words" :key="word">
    {{ word }}
  </div>
</template>
<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import "firebase/firestore";
import { collection, doc, getDoc, onSnapshot } from "firebase/firestore";
import "@material-design-icons/font/filled.css";

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  setup() {
    const words = ref<Array<string>>([]);
    const refWords = collection(db, "words");
    const openBook = async (bookId: string) => {
      const refDoc = doc(db, `/books/${bookId}`);
      const docBook = await getDoc(refDoc);
      const data = docBook.data();
      if (data) {
        words.value = data.words;
      }
    };
    openBook("book1");

    return {
      words
    };
  },
});
</script>
