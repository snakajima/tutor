import * as express from "express";
import { register, initialize } from "./graph";

export const app = express();

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*"); // Allow all origins for testing purposes
  res.header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
  res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
  next();
});

app.use(express.json());
app.get("/api/register/:bookid/:word", register);
app.get("/api/init", initialize);

