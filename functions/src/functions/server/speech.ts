import OpenAI from "openai";
import { v4 as uuidv4 } from "uuid";
import * as admin from "firebase-admin";
import * as express from "express";
const { getStorage, getDownloadURL } = require("firebase-admin/storage");

// import { Storage } from "@google-cloud/storage";
// const storage = new Storage();

if (!admin.apps.length) {
  admin.initializeApp();
}
const storage = getStorage();
const db = admin.firestore();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const sound = async (fileName: string, input: string) => {
  const audio = await openai.audio.speech.create({
    model: "tts-1",
    voice: "shimmer",
    // response_format: "aac",
    input,
  });
  const buffer = Buffer.from(await audio.arrayBuffer());
  console.log(`sound generated: ${input}, ${buffer.length}`);

  const bucket = storage.bucket("ai-tango.appspot.com");
  const file = bucket.file(fileName);  
  await file.save(buffer);
  return await getDownloadURL(file);
}

export const generate = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  const docRef = db.doc(`/words/${word}`);
  const doc = await docRef.get();
  const data = doc.data();
  if (!data) {
    res.json({ success:false, reason:`invalid word: ${word}` });
    return;
  }
  if (data.voice) {
    res.json({ success:false, reason:`already have: ${data.voice}` });
    return;
  }

  const uniqueId = uuidv4();
  const url = await sound(`words/${uniqueId}.mp3`, word + ". "); // ". " (to improve the quality)
  await docRef.update({
    voice: url,    
  })

  res.json({ success:true, word, url });
}

export const generateSample = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  const index = parseInt(req.params.index);
  const docRef = db.doc(`/words/${word}`);
  const doc = await docRef.get();
  const data = doc.data();
  if (!data) {
    res.json({ success:false, reason:`invalid word: ${word}` });
    return;
  }
  const result = data.result;
  const sample = result.samples[index];
  if (!sample) {
    res.json({ success:false, reason:`no sample (something is wrong): ${word}` });
    return;
  }
  if (sample.voice) {
    res.json({ success:false, reason:`already have: ${sample.voice}` });
    return;
  }

  const uniqueId = uuidv4();
  const url = await sound(`sample/${uniqueId}.mp3`, sample.en);
  result.samples[index] = { ...sample, voice:url };
  await docRef.update({
    result,    
  })

  res.json({ success:true, word, url });
}