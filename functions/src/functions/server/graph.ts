import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

export const graph_template = {
  version: 0.3,
  nodes: {
    apiKey: {
      value: functions.config().openai_api.key
    },
    meaning_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system: "You are a dictionary writer. Write the meaning of the given word.",
      },
      inputs: { prompt: ":word" },
    },
    meaning: {
      agent: "copyAgent",
      isResult: true,
      inputs: [":meaning_llm.choices.$0.message.content"],
    },
    meaning_jp_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system: "あなたは英語の教師です。与えられた単語の意味を日本語で説明してください。",
      },
      inputs: { prompt: ":word" },
    },
    meaning_jp: {
      agent: "copyAgent",
      isResult: true,
      inputs: [":meaning_jp_llm.choices.$0.message.content"],
    },
    samples_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system:
          "与えられた単語を含む、英語の文章を10個作って、日本語に訳して。あまり難しい単語は使わずに。フォーマットはJSONで、以下のフォーマットで。\n" +
          "```json\n[{en:'Hello.', jp:'こんにちは。']\n```",
      },
      inputs: { prompt: ":word" },
    },
    samples: {
      agent: "jsonParserAgent",
      isResult: true,
      inputs: [":samples_llm.choices.$0.message.content"],
    },
    similar_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system:
          "与えられた英単語をと類似するいくつか英単語を並べて、日本語で違いを説明して。フォーマットはJSONで、以下のフォーマットで。\n" +
          "```json\n[{word:'Awesome.', jp:'本当に素晴らしいことを強調したい時に使います。']\n```",
      },
      inputs: { prompt: ":word" },
    },
    similar: {
      agent: "jsonParserAgent",
      isResult: true,
      inputs: [":similar_llm.choices.$0.message.content"],
    },
    root_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system: "あなたは英語の教師です。与えられた単語の語源を日本語で解説して。",
      },
      inputs: { prompt: ":word" },
    },
    root: {
      agent: "copyAgent",
      isResult: true,
      inputs: [":root_llm.choices.$0.message.content"],
    },
  },
};

export const onWordCreate = async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext<{
  word: string;
}>) => {
  const { word } = context.params;
  console.log("onCreate", snapshot.data(), word);
  const doc = db.doc(`/words/${word}`);

  const graph_data:GraphData = Object.assign({}, graph_template);
  graph_data.nodes.word = { value: word };
  const graph = new GraphAI(graph_data, agents);
  const result = await graph.run();
  await doc.update({
    result
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