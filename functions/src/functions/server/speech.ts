import OpenAI from "openai";
import * as admin from "firebase-admin";
import * as express from "express";

import { Storage } from "@google-cloud/storage";
const storage = new Storage();

if (!admin.apps.length) {
  admin.initializeApp();
}

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const sound = async (input: string, bucketName: string, fileName: string) => {
  const mp3 = await openai.audio.speech.create({
    model: "tts-1",
    voice: "shimmer",
    input,
  });
  const buffer = Buffer.from(await mp3.arrayBuffer());

  const bucket = storage.bucket(bucketName);
  const file = bucket.file(fileName);  
  await file.save(buffer);
}

export const generate = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  await sound(word, "words", word);
  res.json({ success:true, word });
}
