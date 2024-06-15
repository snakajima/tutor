import OpenAI from "openai";
import * as admin from "firebase-admin";
import * as express from "express";
const { getStorage, getDownloadURL } = require("firebase-admin/storage");

// import { Storage } from "@google-cloud/storage";
// const storage = new Storage();

if (!admin.apps.length) {
  admin.initializeApp();
}
const storage = getStorage();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const sound = async (fileName: string, input: string) => {
  const mp3 = await openai.audio.speech.create({
    model: "tts-1",
    voice: "shimmer",
    input,
  });
  const buffer = Buffer.from(await mp3.arrayBuffer());
  console.log(`sound generated: ${input}, ${buffer.length}`);

  const bucket = storage.bucket("ai-tango.appspot.com");
  const file = bucket.file(fileName);  
  await file.save(buffer);
  return await getDownloadURL(file);
}

export const generate = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  const url = await sound(`words/${word}.mp3`, word);
  res.json({ success:true, word, url });
}
