import express from "express";
import multer from "multer";
import cors from "cors";
import { execFile } from "child_process";
import fs from "fs";
import { 
    WebSocketServer,
    WebSocket as WsWebSocket
} from "ws";


const app = express();
app.use(cors({
  origin: "http://localhost:5173",
  methods: ["GET", "POST"],
}));

const upload = multer({dest: "uploads/"})

const wss = new WebSocketServer({port:3010});

let wsClient: WsWebSocket | null = null;

let currentChild: ReturnType<typeof execFile> | null = null;

wss.on("connection", (ws: WsWebSocket) => {
    wsClient = ws;
    ws.on("close", () => {
        wsClient = null;
        if (currentChild && !currentChild.killed) {
            currentChild.kill("SIGKILL");
        }
    });
});

app.post("/upload", upload.single("image"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({error:"No file"});
    }
    const inputPath = req.file.path;
    const outputPath = `../tmp/tmp.png`;

    const child = execFile("../cpp/build/main", [inputPath, outputPath]);
    currentChild = child;
    
    req.on("close", () => {
        if (child && !child.killed) child.kill("SIGKILL");
    });

    child.stdout?.on("data", (data) => {
        const text = data.toString();
        if (wsClient && wsClient.readyState === WsWebSocket.OPEN) {
            wsClient.send(text.trim());
        }
    });

    child.on("exit", () => {
        currentChild = null;
        const img = fs.readFileSync(outputPath);
        const base64 = img.toString("base64");
        res.json({status:"ok", image:base64});
    });

    child.on("error", (err) => {
        res.status(500).json({error:"failed"});
    });
});

app.listen(3000);
