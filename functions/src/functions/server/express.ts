import * as express from "express";
import { register } from "./graph";

export const app = express();
app.use(express.json());
app.get("/api/register/:word", register);

