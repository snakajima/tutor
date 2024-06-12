import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";

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
