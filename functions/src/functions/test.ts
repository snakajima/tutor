import * as functions from "firebase-functions";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";

export const test = async (data: {}, context: functions.https.CallableContext) => {
  const uid = context?.auth?.uid;
  console.log(uid, data);
  const graphdata: GraphData = {
    nodes: {
      source: {
        value: "Hello World"
      },
      result: {
        agent: "sleeperAgent",
        inputs: [":source"],
        isResult: true,
      }
    }
  }
  const graph = new GraphAI(graphdata, agents);
  const result = await graph.run();  
  return result;
};
