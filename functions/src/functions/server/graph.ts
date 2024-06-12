import * as functions from "firebase-functions";
import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";

export const query = async (req: express.Request, res: express.Response) => {
  const graphdata: GraphData = {
    version: 0.5,
    nodes: {
      query: {
        agent: "openAIAgent",
        params: {
          model: "gpt-4o",
          apiKey: functions.config().openai_api.key,
          baseURL: "https://api.openai.com/v1/chat/completions",
        },
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
  