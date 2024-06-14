import * as express from "express";
import { register, initialize } from "./graph";

export const app = express();
app.use(express.json());
app.get("/api/register/:word", register);
app.get("/api/init", initialize);

