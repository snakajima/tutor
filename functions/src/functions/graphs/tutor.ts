import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";
import "dotenv/config";

export const graph_tutor = {
  version: 0.3,
  nodes: {
    meaning_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system: "You are a dictionary writer. Write the meaning of the given word.\n" +
          "[Sample]" +
          "**hinder** (verb)\n" +
          "\n" +
          "1. To create difficulties for someone or something, resulting in delay or obstruction in progress.\n" +
          "   - Example: The heavy snowfall hindered the rescue efforts.\n" +
          "\n" +
          "2. To prevent or impede the accomplishment, progress, or success of something.\n" +
          "   - Example: Poor health can hinder a person's ability to work.\n" +
          "\n" +
          "**hinder** (adjective) [archaic]\n" +
          "\n" +
          "1. Situated at the back or rear.\n" +
          "   - Example: The horse's hinder legs were caught in the fence.",
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
          "与えられた英単語と類似する意味の英単語をいくつか並べて、日本語で違いを説明して。フォーマットはJSONで、以下のフォーマットで。\n" +
          "```json\n[{word:'Awesome.', jp:'本当に素晴らしいことを強調したい時に使います。']\n```",
      },
      inputs: { prompt: ":word" },
    },
    similar: {
      agent: "jsonParserAgent",
      isResult: true,
      inputs: [":similar_llm.choices.$0.message.content"],
    },
    antonym_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system:
          "与えられた英単語と反対の意味を持つ英単語をいくつか並べて、日本語で違いを説明して。フォーマットはJSONで、以下のフォーマットで。\n" +
          "```json\n[{word:'Awesome.', jp:'本当に素晴らしいことを強調したい時に使います。']\n```",
      },
      inputs: { prompt: ":word" },
    },
    antomym: {
      agent: "jsonParserAgent",
      isResult: true,
      inputs: [":antonym_llm.choices.$0.message.content"],
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
    story_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system: "Write a short story using the given word multiple times within 200 words.",
      },
      inputs: { prompt: ":word" },
    },
    story: {
      agent: "copyAgent",
      isResult: true,
      inputs: [":story_llm.choices.$0.message.content"],
    },
    vocab_llm: {
      agent: "openAIAgent",
      params: {
        model: "gpt-4o",
        apiKey: ":apiKey",
        system:
          "あなたは英語の教師です。与えられた文章から、比較的難しい英単語を１０個選び、過去形・複数形のものは現在形・単数形に戻した上で、文章中での日本語に訳して。フォーマットはJSONで、以下のフォーマットで。\n" +
          "```json\n[{en:'Hello.', jp:'こんにちは。']\n```",
      },
      inputs: { prompt: ":story" },
    },
    vocab: {
      agent: "jsonParserAgent",
      isResult: true,
      inputs: [":vocab_llm.choices.$0.message.content"],
    },
  },
};

const main = async () => {
  const graph_data:GraphData = {
    version: 0.3,
    nodes: {
      word: {
        agent: "textInputAgent",
        params: {
          message: "勉強したい英語の単語を入力してください:",
        },
      },
      tutor: {
        agent: "nestedAgent",
        inputs: {
          apiKey: process.env.OPENAI_API_KEY,
          word: ":word",
        },
        graph: graph_tutor
      },
      result: {
        agent: "copyAgent",
        inputs: [":tutor"],
        isResult: true,
      }
    }
  };
  const graph = new GraphAI(graph_data, agents);
  const result = await graph.run();
  console.log("%o", result);
}

if (require.main === module) {
  main();
}