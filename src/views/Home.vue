<template>
  <div class="flex flex-row">
    <div class="basis-1/4 bg-indigo-500 text-white text-lg">
      <div>word</div>
    </div>
    <div class="basis-3/4">
      contents
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onUnmounted } from "vue";
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
    const words = collection(db, "words");
    const unsub = onSnapshot(words, (snapshot) => {
      snapshot.forEach((doc:any) => {
        // doc.data() is never undefined for query doc snapshots
        console.log(doc.id);
      });
    });
    onUnmounted(() => {
      unsub();
    });
    return {}
  }
});
</script>
