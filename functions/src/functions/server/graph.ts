import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import { GraphAI, GraphData } from "graphai";
import * as agents from "@graphai/agents";
import * as tutor_gemini from "../graphs/tutor_g";
import * as tutor_openai from "../graphs/tutor";
// import { wordle } from "./wordle";
import { toeic500, toeic600, toeic700, toeic800 } from "./toeic";

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

export const onWordCreate = async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext<{
  word: string;
}>) => {
  const { word } = context.params;
  console.log("onCreate", snapshot.data(), word);
  const doc = db.doc(`/words/${word}`);

  const graph_data_gemini:GraphData = {
    version: 0.3,
    nodes: {
      tutor: {
        agent: "nestedAgent",
        inputs: {
          apiKey: process.env.GOOGLE_GENAI_API_KEY,
          word,
        },
        isResult: true,
        graph: tutor_gemini.graph_tutor
      },
    }
  };
  const graph_data_openai:GraphData = {
    version: 0.3,
    nodes: {
      tutor: {
        agent: "nestedAgent",
        inputs: {
          apiKey: process.env.OPENAI_API_KEY,
          word,
        },
        isResult: true,
        graph: tutor_openai.graph_tutor
      },
    }
  };
  const update = async (graph_data: GraphData, model: string) => {
    const graph = new GraphAI(graph_data, agents);
    const result = await graph.run();
    await doc.update({
      result: result.tutor,
      nograph: false,
      model,
    })
  }

  try {
    await update(graph_data_gemini, "gemini-1.5-flash");
  } catch(e) {
    console.warn("first catch", e);
    try {
      await update(graph_data_openai, "gpt-4o");
    } catch(e2) {
      console.warn("second catch", e2);
      await update(graph_data_openai, "gpt-4o");
    }
  }
};

export const register = async (req: express.Request, res: express.Response) => {
  const word = req.params.word.toLowerCase();
  const bookid = req.params.bookid;
  const docBook = await db.doc(`/books/${bookid}`).get();
  if (!docBook) {
    res.json({success:false, reason:`no book: ${bookid}` });
    return;
  }
  const data = docBook.data();
  if (!data) {
    res.json({ success:false, reason:`no book data: ${bookid}` });
    return;
  }
  const words:Array<string> = data.words;
  if (words.indexOf(word) < 0) {
    res.json({ success:false, reason:`no word in book: ${word} in ${bookid}` });
    return;
  }

  const doc = db.doc(`/words/${word}`);
  await doc.create({
    word,
    nograph: true,
    version: 1,
  });
  res.json({ success:true, word });
};

export const initialize = async (req: express.Request, res: express.Response) => {
  /*
  const words = ["accommodate", "acquire", "adapt", "adequate", "advocate", "affect", "aggregate", "alternative", 
    "amend", "anticipate", "approximate", "assess", "assist", "attribute", "award", "benchmark", "bias", 
    "blend", "boost", "brief", "budget", "canonical", "capacity", "challenge", "circulate", "clarify", "coherent", 
    "collaborate", "commence", "commission", "compensate", "complement", "compliant", "conceive", "concur", "condense", 
    "confer", "consensus", "consolidate", "contrast", "convert", "correlate", "correspond", "couple", "critique", "deduce", 
    "defer", "define", "delegate", "deliver", "denote", "depict", "derive", "devise", "diminish", "disclose", "disseminate", 
    "diversify", "document", "dwell", "elaborate", "eliminate", "emphasize", "enact", "enhance", "envisage", "evolve", "exceed", 
    "execute", "expand", "exploit", "extract", "facilitate", "foster", "function", "generate", "govern", "hierarchy", 
    "hypothesis", "identify", "implement", "incorporate", "infer", "initiate", "integrate", "interact", "interpret", 
    "justify", "orient", "outline", "oversee", "parallel", "persuade", "prioritize", "procedure", "promote", "propose", 
    "provoke", "qualify", "quantify", "rationalize", "reconcile", "refute", "render", "reorganize", "resemble", "restrict", 
    "simplify", "specify", "strategize", "substantiate", "summarize", "synthesize", "transmit", "utilize", "verify"];

  const words2 = ["abundance", "acquisition", "adversary", "affluent", "alleviate", "ambiguity", "amendment", "analogous", "annotate", "antagonism", 
    "antecedent", "anticipate", "apprehensive", "arrogance", "articulate", "assimilate", "assumption", "asymmetrical", "atrophy", "authentic", 
    "autonomous", "avarice", "banal", "benevolent", "bias", "bureaucracy", "candid", "censorship", "chronological", "coerce", 
    "cognizant", "collaborate", "commemorate", "compensate", "complacent", "comprehensive", "conceal", "condescending", "confidentiality", "congestion", 
    "conscientious", "consolidate", "contemplate", "contradict", "conversely", "corroborate", "counterfeit", "credibility", "cumbersome", "deceive", 
    "deduction", "defamation", "deference", "delegate", "deliberate", "delineate", "demolish", "denounce", "deplete", "deposition", 
    "deprivation", "derivative", "desolate", "deterrent", "detrimental", "deviate", "devotion", "dexterity", "diplomatic", "discrepancy", 
    "discretion", "disillusioned", "disparage", "disseminate", "diversify", "divulge", "dominant", "drastic", "duplicate", "eccentric", 
    "eclipse", "elaborate", "elicit", "eloquence", "embezzle", "emulate", "encompass", "endorse", "enigmatic", "enlighten", 
    "entail", "entrepreneur", "enumerate", "erroneous", "ethics", "euphoria", "evade", "exacerbate", "exalt", "exemplify", 
    "exhaustive", "exhilarating", "exorbitant", "expedite", "explicit", "exploit", "exquisite", "extol", "extravagant", "facilitate", 
    "fallacious", "fastidious", "feasible", "fluctuate", "formulate", "forthcoming", "frivolous", "futile", "gargantuan", "gloat", 
    "gluttony", "gracious", "gregarious", "heed", "hierarchy", "hinder", "hypothesis", "idealistic", "idiosyncrasy", "illicit", 
    "immutable", "impair", "impartial", "imperative", "impetus", "implement", "implicate", "impose", "improvise", "inadvertent", 
    "incentive", "incite", "inclusive", "incongruous", "indigenous", "indispensable", "induce", "indulge", "inertia", "infer", 
    "inferior", "influx", "infrastructure", "ingenious", "inherent", "innovation", "insatiable", "insightful", "insinuate", "insipid", 
    "insolvent", "instigate", "integrity", "intermittent", "intricate", "intuitive", "inundate", "invoke", "irrefutable", "irrelevant", 
    "irresolute", "jubilant", "lament", "lavish", "legitimate", "lenient", "leverage", "liberal", "limbo", "lofty", 
    "malicious", "malleable", "manifest", "manipulate", "marginal", "meander", "mediocre", "menace", "meticulous", "mimic", 
    "minimalist", "misconception", "mitigate", "mobilize", "mold", "monetary", "monopolize", "moratorium", "mundane", "myriad", 
    "narcissistic", "negligible", "nefarious", "negotiate", "nonchalant", "notorious", "novice", "nuance", "nurture", "oblivious", 
    "obscure", "obsolete", "obstruct", "ominous", "opulent", "ornate", "ostensible", "outlandish", "overhaul", "oversee",
    "overt", "overwhelm", "palpable", "paradox", "paragon", "parochial", "patronize", "perception", "perpetuate", "perplex", 
    "pervasive", "pessimistic", "phenomenon", "pinnacle", "plausible", "plethora", "ponder", "portray", "precarious", "precedent", 
    "precipitate", "preclude", "predicament", "premise", "presumptuous", "prevalent", "pristine", "procrastinate", "prodigious", "proficient", 
    "profound", "prolific", "prominent", "propensity", "prosperity", "protocol", "provoke", "prudent", "pundit", "qualms", 
    "quandary", "quintessential", "radical", "reconcile", "redundant", "refute", "reinforce", "relinquish", "reminisce", "renounce", 
    "repercussion", "replenish", "replicate", "requisite", "resilient", "resolute", "restraint", "reverence", "rhetoric", "rife", 
    "rudimentary", "sanction", "satiate", "saturate", "scorn", "scrutinize", "seclude", "secrete", "sedentary", "sequester", 
    "shrewd", "skeptical", "solicitous", "somber", "sovereign", "sporadic", "stagnant", "staunch", "stereotype", "stimulate", 
    "stipulate", "strident", "sublime", "subordinate", "subsequent", "subtle", "succumb", "suffice", "surreptitious", "symmetry", 
    "synonymous", "tangible", "tantalize", "tedious", "tenacious", "tentative", "terse", "thriving", "timid", "totalitarian", 
    "trivial", "truncate", "tyranny", "ultimate", "unanimous", "undermine", "underscore", "unfettered", "unilateral", "unprecedented", 
    "unscrupulous", "unwarranted", "uphold", "utilitarian", "vacillate", "vague", "validate", "vanquish", "venerate", "veracity", 
    "verbose", "versatile", "vex", "viable", "vicarious", "vigilant", "vindicate", "virtuoso", "volatile", "wane",
    "wary", "widespread", "wistful", "zealot"];

  await db.doc("/books/book1").create({
    title: "Intermediate 1",
    words,
  });
  await db.doc("/books/book2").create({
    title: "Intermediate 2",
    words: words2,
  });
  */
  await db.doc("/books/toeic500").create({
    title: "Toeic 500",
    words: toeic500,
  });
  await db.doc("/books/toeic600").create({
    title: "Toeic 600",
    words: toeic600,
  });
  await db.doc("/books/toeic700").create({
    title: "Toeic 700",
    words: toeic700,
  });
  await db.doc("/books/toeic800").create({
    title: "Toeic 800",
    words: toeic800,
  });

  res.json({ success:true });
};
