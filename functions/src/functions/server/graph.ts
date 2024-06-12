import * as functions from "firebase-functions";
// import { initializeApp } from "firebase/app";
// import { getFirestore } from "firebase/firestore";
import * as admin from "firebase-admin";
// import { doc, setDoc } from "firebase/firestore"; 
import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const query = async (req: express.Request, res: express.Response) => {
  const { word } = req.params;
  const doc = db.doc(`/words/${word}`);
  await doc.create({
    message: "Hello",
    word: word,
  });

  const graphdata: GraphData = {
    version: 0.5,
    nodes: {
      query: {
        agent: "openAIAgent",
        params: {
          model: "gpt-4o",
          apiKey: functions.config().openai_api.key,
          // baseURL: "https://api.openai.com/v1/chat/completions",
        },
        isResult: true,
        inputs: { prompt: "Hello" },
      },
    }
  }
  const graph = new GraphAI(graphdata, agents);
  const result = await graph.run();  
  res.json(result);
};

export const test = async (req: express.Request, res: express.Response) => {
    const graphdata: GraphData = {
      version: 0.5,
      nodes: {
        source: {
          value: "Hello World"
        },
        result: {
          agent: "copyAgent",
          inputs: [":source"],
          isResult: true,
        }
      }
    }
    const graph = new GraphAI(graphdata, agents);
    const result = await graph.run();  
    res.json(result);
  };
  