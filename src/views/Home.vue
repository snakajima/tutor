<template>
  <div class="flex flex-row">
    <div class="h-screen basis-1/4 bg-indigo-500 text-white text-lg overflow-y-auto">
      <div v-for="word in words" @click="selectWord(word)" :key="word">
        {{ word }}
      </div>
    </div>
    <div class="basis-3/4 text-left">
      <div v-if="selectedWord" class="m-1 ml-2">
        <div class="text-3xl">{{ selectedWord.word }}</div>
        <div v-if="selectedWord.result">
          <div class="mt-2 font-bold">例文<Toggle :flag="flags.samples" @toggle="toggle('samples')" /></div>
          <div class="ml-2" v-if="flags.samples">
            <div v-for="(item, index) in selectedWord.result.samples" :key="item.en">
              <div>{{ item.en }}<Toggle :flag="sampleFlags[index]" @toggle="toggleSample(index)" /></div>
              <div class="ml-2" v-if="sampleFlags[index]">{{ item.jp }}</div>
            </div>
          </div>
          <div class="mt-2 font-bold">意味：英語<Toggle :flag="flags.meaning" @toggle="toggle('meaning')" /></div>
          <div class="ml-2" v-if="flags.meaning" v-html="md.render(selectedWord.result.meaning)" />
          <div class="mt-2 font-bold">意味：日本語<Toggle :flag="flags.meaning_jp" @toggle="toggle('meaning_jp')" /></div>
          <div class="ml-2" v-if="flags.meaning_jp" v-html="md.render(selectedWord.result.meaning_jp)" />
          <div class="mt-2 font-bold">類義語<Toggle :flag="flags.similar" @toggle="toggle('similar')" /></div>
          <div class="ml-2" v-if="flags.similar">
            <div v-for="item in selectedWord.result.similar" :key="item.word">
              <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
            </div>
          </div>
          <div class="mt-2 font-bold" v-if="selectedWord.result.antonym">反対語<Toggle :flag="flags.similar" @toggle="toggle('antonym')" /></div>
          <div class="ml-2" v-if="flags.antonym">
            <div v-for="item in selectedWord.result.antonym" :key="item.word">
              <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
            </div>
          </div>
          <div class="mt-2 font-bold">語源<Toggle :flag="flags.root" @toggle="toggle('root')" /></div>
          <div class="ml-2" v-if="flags.root" v-html="md.render(selectedWord.result.root)" />
          <div class="mt-2 font-bold" v-if="selectedWord.result.story">読み物<Toggle :flag="flags.samples" @toggle="toggle('story')" /></div>
          <div v-if="flags.story">
            <div class="ml-2" v-html="md.render(selectedWord.result.story)" />
            <div class="mt-2 font-bold">読み物中の単語<Toggle :flag="flags.vocab" @toggle="toggle('vocab')" /></div>
            <div class="mt-2" v-if="flags.vocab">
              <div class="ml-2" v-for="item in selectedWord.result.vocab" :key="item.en">
                <span class="font-bold">{{ item.en }}</span> : {{ item.jp }}
              </div>
            </div>
          </div>
        </div>
        <div v-else class="mt-2">Please wait. AI is generating...</div>
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
import { collection, doc, getDoc, onSnapshot } from "firebase/firestore";
import markdownit from "markdown-it";
import "@material-design-icons/font/filled.css";
import Toggle from "../components/Toggle.vue";
const md = markdownit();

initializeApp(firebaseConfig);
const db = getFirestore();

export default defineComponent({
  name: "HomePage",
  components: {
    Toggle,
  },
  setup() {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const unsubs = [] as Array<any>;
    const words = ref<Array<string>>([]);
    const flags = ref<Record<string, boolean>>({});
    const sampleFlags = ref<Array<boolean>>([]);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const selectedWord = ref<Record<string, any> | undefined>(undefined);
    const refWords = collection(db, "words");
    const cleanup = () => {
      unsubs.forEach((unsub) => unsub());
      unsubs.length = 0;
    };
    onUnmounted(() => {
      cleanup();
    });
    const openBook = async (bookId: string) => {
      const refDoc = doc(db, `/books/${bookId}`);
      const docBook = await getDoc(refDoc);
      const data = docBook.data();
      if (data) {
        words.value = data.words;
      }
    };
    openBook("book1");

    const selectWord = async (word: string) => {
      cleanup();
      const docRef = doc(refWords, word);
      const docSnap = await getDoc(docRef);
      const data = docSnap.data();
      if (data) {
        selectedWord.value = data;
        flags.value = {};
        sampleFlags.value = [];
      } else {
        // console.log("no data yet");
        const url = `https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/register/book1/${word}`;
        try {
          const res = await fetch(url);
          console.log(res.status);
          const unsub = onSnapshot(docRef, (snapshot) => {
            // console.log("updated");
            selectedWord.value = snapshot.data();
            flags.value = {};
            sampleFlags.value = [];
          });
          unsubs.push(unsub);
        } catch (e) {
          console.error(e);
        }
      }
    };
    const toggle = (key: string) => {
      const value = flags.value;
      value[key] = !value[key];
      flags.value = value;
      if (key === "samples") {
        sampleFlags.value = [];
      }
    };
    const toggleSample = (index: number) => {
      const value = sampleFlags.value;
      value[index] = !value[index];
      sampleFlags.value = value;
    };
    return {
      words,
      selectWord,
      selectedWord,
      md,
      toggle,
      flags,
      sampleFlags,
      toggleSample,
    };
  },
});
</script>
