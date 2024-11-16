import express from "express";
import mongoose from "mongoose";
import * as http from "http";
import { Server as SocketIOServer } from "socket.io";
import { initSocketHandlers } from "./views/socket_handlers";

const app = express();  //creates express app
app.use(express.json());    //send/receive requests in JSON format

const server = http.createServer(app);  //create HTTP server
const io = new SocketIOServer(server);  //Attach Socket.IO to the HTTP server

//connect to database
const MONGO_URL = "mongodb://localhost:27017/";
mongoose.connect(MONGO_URL, { dbName: "skribbl_clone" })    //dbName is the name of the database where all to connections will be stored
    .then(() => console.log("Database connected"))
    .catch((err) => console.error("DB Connection Error:", err));

initSocketHandlers(io); //initlize sockets

const PORT = process.env.PORT || 3000;  //set server listening port
server.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
