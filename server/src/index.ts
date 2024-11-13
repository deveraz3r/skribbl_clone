import express from "express";
import mongoose from "mongoose";
import * as http from "http";
import { Server as SocketIOServer, Socket } from 'socket.io';
import RoomModel from "./models/room";
import getWord from "./apis/generate_word";
import { PlayerModel } from "./models/player";


const app = express();  // create express app
app.use(express.json());  // requests send/receive in JSON format
const server = http.createServer(app);  // create HTTP server

// Attach Socket.IO to the HTTP server
const io = new SocketIOServer(server);

// Connect to database
const MONGO_URL = "mongodb://localhost:27017/";
mongoose.connect(MONGO_URL, {
    dbName: "skribbl_clone"  // name of the database where collections will be stored
}).then(() => {
    console.log("Database connected");
}).catch((error) => {
    console.log(`Error: ${error}`);
});

// Initialize Socket.IO
io.on('connection', (socket: Socket) => {
    console.log("connected");

    // Create room callback
    socket.on("create-room", async ({ playerName, roomName, occupancy, maxRounds }) => {
        try {
            console.log("reached create room");
            // Check if the room already exists
            const existingRoom = await RoomModel.findOne({ roomName });
            if (existingRoom) {
                socket.emit('notCorrectGame', 'Room with that name already exists!');
                return;
            }

            // Create room and generate a word
            const word: string = getWord(); // Generates a random word
            let room = new RoomModel({
                word,
                roomName,
                occupancy,
                maxRounds,
                players: [],
            });

            // Create player model and add it to room's players
            const player = new PlayerModel({
                playerName: playerName,
                socketId: socket.id,
                isPartyLeader: true,
                points: 0,
            });
            room.players.push(player);

            // Save room
            room = await room.save();

            // Join the room and emit updated data
            socket.join(room.roomName);
            io.to(room.roomName).emit('updateRoom', room);
        } catch (err) {
            console.log(err);
        }
    });

    // Join game callback
    socket.on("join-room", async ({ playerName, roomName }) => {
        try {
            console.log("Reached room");
            let room = await RoomModel.findOne({ roomName });

            if (!room) {
                console.log("room does not exist");
                socket.emit('incorrect-name', 'Room name invalid!');
                return;
            }

            if (room.isJoin) {
                // Create player model and add it to room's players
                const player = new PlayerModel({
                    playerName: playerName,
                    socketId: socket.id,
                });
                room.players.push(player);

                // Update join status if room occupancy is reached
                if (room.players.length === room.occupancy) {
                    room.isJoin = false;
                }

                // Set the current turn
                room.turn = room.players[room.turnIndex];

                // Save updates to the room
                room = await room.save();

                // Join the room and emit updated data
                socket.join(room.roomName);
                io.to(roomName).emit('updateRoom', room);
            }
            
        } catch (err) {
            console.log(err);
        }
    });

    //whitebord socket
    socket.on('paint', ({details, roomName})=>{
        io.to(roomName).emit('points', {details: details});
    });

    //color socket
    socket.on("color-change", ({color, roomName})=>{
        io.to(roomName).emit('color-change', color);
    });
});

// Set server listen port
const port = process.env.PORT || 3000;
server.listen(port, () => {
    console.log("Server started at http://localhost:" + port);
});
