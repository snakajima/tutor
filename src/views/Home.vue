<template>
  <div class="flex flex-row">
    <div class="basis-1/4 bg-indigo-500 text-white text-lg">
      <div v-for="word in words" @click="handleOnWord(word)">
        {{ word }}
      </div>
    </div>
    <div class="basis-3/4">
      contents
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import "firebase/firestore";
import { collection, doc, setDoc, getDocs, onSnapshot } from "firebase/firestore"; 

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  name: "HomePage",
  components: {},
  setup() {
    const words = ref<Array<string>>([])
    const refWords = collection(db, "words");
    const unsub = onSnapshot(refWords, (snapshot) => {
      const ids:Array<string> = [];
      snapshot.forEach((doc:any) => {
        // doc.data() is never undefined for query doc snapshots
        ids.push(doc.id);
      });
      words.value = ids;
      console.log(ids);
    });
    onUnmounted(() => {
      unsub();
    });
    const handleOnWord = (word:string) => {
      console.log(word);
    };
    return {
      words, handleOnWord
    }
  }
});
</script>
