<template>
  <div class="flex flex-row">
    <div class="basis-1/4 bg-indigo-500 text-white text-lg h-screen overflow-y-auto">
      <div v-for="word in words" @click="selectWord(word)" :key="word">
        <div class="font-bold" v-if="word === selectedWord">
          {{ word }}
        </div>
        <div v-else>
          {{ word }}
        </div>
      </div>
    </div>
    <div class="basis-3/4 text-left h-screen overflow-y-auto">
      <div v-if="wordData" class="m-1 ml-2">
        <div>
          <span class="text-3xl">{{ wordData.word }}</span>
          <span class="material-icons ml-2 cursor-pointer" v-if="wordData.voice" @click="playSound(wordData.voice)">volume_up</span>
          <span class="material-icons ml-2 cursor-pointer" v-else @click="generateWordVoice(wordData.word)">volume_down</span>
        </div>
        <div v-if="wordData.result">
          <div class="mt-2 font-bold"><Toggle :flag="flags.samples" @toggle="toggle('samples')">例文</Toggle></div>
          <div class="ml-2" v-if="flags.samples">
            <div v-for="(item, index) in wordData.result.samples" :key="item.en">
              <div>
                <Toggle :flag="sampleFlags[index]" @toggle="toggleSample(index)">{{ item.en }}</Toggle>
                <span class="material-icons ml-2 cursor-pointer" v-if="item.voice" @click="playSound(item.voice)">volume_up</span>
                <span class="material-icons ml-2 cursor-pointer" v-else @click="generateSampleVoice(wordData.word, index)">volume_down</span>
              </div>
              <div class="ml-2" v-if="sampleFlags[index]">{{ item.jp }}</div>
            </div>
          </div>
          <div class="mt-2 font-bold"><Toggle :flag="flags.meaning" @toggle="toggle('meaning')">意味：英語</Toggle></div>
          <div class="ml-2" v-if="flags.meaning" v-html="md.render(wordData.result.meaning)" />
          <div class="mt-2 font-bold"><Toggle :flag="flags.meaning_jp" @toggle="toggle('meaning_jp')">意味：日本語</Toggle></div>
          <div class="ml-2" v-if="flags.meaning_jp" v-html="md.render(wordData.result.meaning_jp)" />
          <div class="mt-2 font-bold"><Toggle :flag="flags.similar" @toggle="toggle('similar')">類義語</Toggle></div>
          <div class="ml-2" v-if="flags.similar">
            <div v-for="item in wordData.result.similar" :key="item.word">
              <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
            </div>
          </div>
          <div class="mt-2 font-bold" v-if="wordData.result.antonym"><Toggle :flag="flags.similar" @toggle="toggle('antonym')">反対語</Toggle></div>
          <div class="ml-2" v-if="flags.antonym">
            <div v-for="item in wordData.result.antonym" :key="item.word">
              <span class="font-bold">{{ item.word }}</span> : {{ item.jp }}
            </div>
          </div>
          <div class="mt-2 font-bold"><Toggle :flag="flags.root" @toggle="toggle('root')">語源</Toggle></div>
          <div class="ml-2" v-if="flags.root" v-html="md.render(wordData.result.root)" />
          <div class="mt-2 font-bold" v-if="wordData.result.story"><Toggle :flag="flags.samples" @toggle="toggle('story')">読み物</Toggle></div>
          <div v-if="flags.story">
            <div class="ml-2" v-html="md.render(wordData.result.story)" />
            <div class="mt-2 font-bold"><Toggle :flag="flags.vocab" @toggle="toggle('vocab')">読み物中の単語</Toggle></div>
            <div class="mt-2" v-if="flags.vocab">
              <div class="ml-2" v-for="item in wordData.result.vocab" :key="item.en">
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
    const unsubs = {} as Record<string, any>;
    const words = ref<Array<string>>([]);
    const flags = ref<Record<string, boolean>>({});
    const sampleFlags = ref<Array<boolean>>([]);
    const selectedWord = ref<string | undefined>(undefined);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const wordData = ref<Record<string, any> | undefined>(undefined);
    const refWords = collection(db, "words");
    const cleanup = () => {
      Object.keys(unsubs).forEach((key) => {
        const unsub = unsubs[key];
        if (unsub) {
          unsub();
        }
        delete unsubs[key];
      });
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
        console.log(words.value.length);
      }
    };
    openBook("book1");

    const selectWord = async (word: string) => {
      const unsub = unsubs.word;
      if (unsub) {
        unsub();
        delete unsubs.word;
      }
      selectedWord.value = word;
      flags.value = {};
      sampleFlags.value = [];

      const docRef = doc(refWords, word);
      const docSnap = await getDoc(docRef);
      const data = docSnap.data();
      if (data) {
        wordData.value = data;
      } else {
        const url = `https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/register/book1/${word}`;
        const res = await fetch(url);
        console.log(res.status);
      }
      unsubs.word = onSnapshot(docRef, (snapshot) => {
        console.log(`got update on word ${word}`);
        wordData.value = snapshot.data();
      });
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
    const playSound = (url: string) => {
      const audio = new Audio(url);
      audio.play()
    };
    const generateWordVoice = async (word: string) => {
      console.log("generateWordVoice", word);
      const url = `https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/sound/${word}`;
      const res = await fetch(url);
      const result = await res.json()
      console.log(result);
      playSound(result.url);
    };
    const generateSampleVoice = async(word: string, index: number) => {
      console.log("generateSampleVoice", word, index);
      const url = `https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/sample/${word}/${index}`;
      const res = await fetch(url);
      const result = await res.json()
      console.log(result);
      playSound(result.url);
    };
    return {
      words,
      selectWord,
      selectedWord,
      wordData,
      md,
      toggle,
      flags,
      sampleFlags,
      toggleSample,
      playSound,
      generateWordVoice,
      generateSampleVoice,
    };
  },
});
</script>
