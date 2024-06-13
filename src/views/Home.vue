<template>
  <div class="flex flex-row">
    <div class="basis-1/4 bg-indigo-500 text-white text-lg">
      <div v-for="word in words" @click="selectWord(word)" :key="word">
        {{ word }}
      </div>
    </div>
    <div class="basis-3/4 text-left">
      <div v-if="selectedWord" class="m-1 ml-2">
        <div class="text-3xl">{{ selectedWord.word }}</div>
        <div class="mt-2 font-bold">例文<Toggle :flag="flags.samples" @toggle="toggle('samples')"/></div>
        <div class="ml-2" v-if="flags.samples">
          <div v-for="(item, index) in selectedWord.result.samples" :key="item.en">
            <div>{{ item.en }}<Toggle :flag="sampleFlags[index]" @toggle="toggleSample(index)"/></div>
            <div class="ml-2" v-if="sampleFlags[index]">{{ item.jp }}</div>
          </div>
        </div>
        <div class="mt-2 font-bold">意味：英語<Toggle :flag="flags.meaning" @toggle="toggle('meaning')"/></div>
        <div class="ml-2" v-if="flags.meaning" v-html="md.render(selectedWord.result.meaning)" />
        <div class="mt-2 font-bold">意味：日本語<Toggle :flag="flags.meaning_jp" @toggle="toggle('meaning_jp')"/></div>
        <div class="ml-2" v-if="flags.meaning_jp" v-html="md.render(selectedWord.result.meaning_jp)" />
        <div class="mt-2 font-bold">類義語<Toggle :flag="flags.similar" @toggle="toggle('similar')"/></div>
        <div class="ml-2" v-if="flags.similar">
          <div v-for="item in selectedWord.result.similar" :key="item.word">
            <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
          </div>
        </div>
        <div class="mt-2 font-bold">語源<Toggle :flag="flags.root" @toggle="toggle('root')"/></div>
        <div class="ml-2" v-if="flags.root" v-html="md.render(selectedWord.result.root)" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onUnmounted, ref } from "vue";
import { firebaseConfig } from "../config/project";
import { initializeApp } from "firebase/app";
import { getFirestore, QueryDocumentSnapshot, DocumentData } from "firebase/firestore";
import "firebase/firestore";
import { collection, doc, getDoc, onSnapshot } from "firebase/firestore"; 
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
    const sampleFlags = ref<Array<boolean>>([]);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const selectedWord = ref<Record<string, any> | undefined>(undefined);
    const refWords = collection(db, "words");
    const unsub = onSnapshot(refWords, (snapshot) => {
      const ids:Array<string> = [];
      snapshot.forEach((doc:QueryDocumentSnapshot<DocumentData, DocumentData>) => {
        // doc.data() is never undefined for query doc snapshots
        ids.push(doc.id);
      });
      words.value = ids;
      // console.log(ids);
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
      sampleFlags.value = [];
    };
    const toggle = (key:string) => {
      const value = flags.value;
      value[key] = !value[key]; 
      flags.value = value;
      if (key === "samples") {
        sampleFlags.value = [];
      }
    };
    const toggleSample = (index:number) => {
      const value = sampleFlags.value;
      value[index] = !value[index]; 
      sampleFlags.value = value;
    };
    return {
      words, selectWord, selectedWord, md, toggle, flags, sampleFlags, toggleSample
    }
  }
});
</script>
