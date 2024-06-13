import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";
import { graph_tutor } from "../graphs/tutor";

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

export const onWordCreate = async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext<{
  word: string;
}>) => {
  const { word } = context.params;
  console.log("onCreate", snapshot.data(), word);
  const doc = db.doc(`/words/${word}`);

  const graph_data:GraphData = {
    version: 0.3,
    nodes: {
      tutor: {
        agent: "nestedAgent",
        inputs: {
          apiKey: process.env.OPENAI_API_KEY,
          word,
        },
        isResult: true,
        graph: graph_tutor
      },
    }
  };
  const graph = new GraphAI(graph_data, agents);
  const result = await graph.run();
  await doc.update({
    result: result.tutor
  })
};

export const register = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  const doc = db.doc(`/words/${word}`);
  await doc.create({
    word,
  });
  res.json({ success:true, word });
};