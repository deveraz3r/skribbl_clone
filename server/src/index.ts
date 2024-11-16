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

    //change turn
    socket.on("change-turn", async ({ roomName }) => {
        try {
            let room = await RoomModel.findOne({ roomName });
    
            if (!room) {
                console.log("Room not found");
                return;
            }
    
            // Check if the current round can continue
            if (room.currentRound <= room.maxRounds) {
                // Update turn index and round
                if (room.turnIndex === room.players.length - 1) {
                    // Last player's turn, move to the next round
                    room.currentRound += 1;
                    room.turnIndex = 0; // Reset turn index to 0
                } else {
                    // Move to the next player's turn
                    room.turnIndex += 1;
                }
    
                // Set a new word and update the current turn
                room.word = getWord();
                room.turn = room.players[room.turnIndex];
    
                await room.save();
    
                // Emit the updated room state to the room
                io.to(roomName).emit("change-turn", room);
            } else {
                // Emit final state or leaderboard if max rounds are reached
                io.to(roomName).emit("change-turn", room);
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

    //strokeWidth change
    socket.on("strokeWidth-change", ({width, roomName})=>{
        io.to(roomName).emit('strokeWidth-change', width);
    });

    //clear drawing
    socket.on("clear-canvas", ({roomName})=>{
        io.to(roomName).emit('clear-canvas', null);
    });

    //message
    socket.on("message", async ({ message, playerName, roomName, roundTime, timeTaken }) => {
        try {
            let room = await RoomModel.findOne({roomName});
    
            if (!room) {
                console.log("Room not found");
                return;
            }
    
            //TODO: add timer functionality on server side
            //TODO: add check on users to only guess word one time
            if (message === room.word) {
                let userPlayer = room.players.find((player) => player.playerName === playerName);
    
                if (userPlayer && timeTaken !== 0) {
                    userPlayer.points += Math.round(200 / timeTaken) * 10;
                }
    
                room = await room.save();
    
                io.to(roomName).emit("message", {
                    playerName: playerName,
                    message: "Guessed it!",
                    isCorrectWord: true,
                });
            } else {
                io.to(roomName).emit("message", {
                    playerName: playerName,
                    message: message,
                    isCorrectWord: false,
                });
            }
        } catch (err) {
            console.error(err);
        }
    });
});

// Set server listen port
const port = process.env.PORT || 3000;
server.listen(port, () => {
    console.log("Server started at http://localhost:" + port);
});
//TODO: change code to mvvm architecture