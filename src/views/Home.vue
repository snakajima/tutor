<template>
  <div class="flex flex-row">
    <div class="basis-1/4 bg-indigo-500 text-white text-lg">
      <div v-for="word in words" @click="selectWord(word)">
        {{ word }}
      </div>
    </div>
    <div class="basis-3/4 text-left">
      <div v-if="selectedWord" class="m-1 ml-2">
        <div class="text-3xl">{{ selectedWord.word }}</div>
        <div class="mt-2 font-bold">意味：英語<Toggle :flag="flags.meaning" @toggle="toggle('meaning')"/></div>
        <div class="ml-2" v-if="flags.meaning" v-html="md.render(selectedWord.result.meaning)" />
        <div class="mt-2 font-bold">意味：日本語<Toggle :flag="flags.meaning_jp" @toggle="toggle('meaning_jp')"/></div>
        <div class="ml-2" v-if="flags.meaning_jp" v-html="md.render(selectedWord.result.meaning_jp)" />
        <div class="mt-2 font-bold">語源<Toggle :flag="flags.root" @toggle="toggle('root')"/></div>
        <div class="ml-2" v-if="flags.root" v-html="md.render(selectedWord.result.root)" />
        <div class="mt-2 font-bold">類義語</div>
        <div class="ml-2">
          <div v-for="item in selectedWord.result.similar">
            <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
          </div>
        </div>
        <div class="mt-2 font-bold">例文</div>
        <div class="ml-2">
          <div v-for="item in selectedWord.result.samples">
            <div>{{ item.en }}</div>
            <div class="ml-2">{{ item.jp }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import "firebase/firestore";
import { collection, doc, setDoc, getDoc, onSnapshot } from "firebase/firestore"; 
import markdownit from 'markdown-it';
import '@material-design-icons/font/filled.css';
import Toggle from '../components/Toggle.vue';
const md = markdownit()

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  name: "HomePage",
  components: {
    Toggle,
  },
  setup() {
    const words = ref<Array<string>>([]);
    const flags = ref<Record<string, boolean>>({});
    const selectedWord = ref<Record<string, any> | undefined>(undefined);
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
    const selectWord = async (word:string) => {
      const docRef = doc(refWords, word)
      const docSnap = await getDoc(docRef);
      const data = docSnap.data();
      selectedWord.value = data;
      flags.value = {};
    };
    const toggle = (key:string) => {
      console.log(key);
      const value = flags.value;
      value[key] = !value[key]; 
      flags.value = value;
    };
    return {
      words, selectWord, selectedWord, md, toggle, flags
    }
  }
});
</script>
