import * as express from "express";
import { test, query } from "./graph";

export const hello_response = async (req: express.Request, res: express.Response) => {
  res.json({ message: "hello" });
};

export const app = express();
app.use(express.json());
app.get("/api/hello", hello_response);
app.get("/api/test", test);
app.get("/api/word/:word", query);

