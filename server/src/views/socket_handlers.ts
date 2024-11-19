import { Server as SocketIOServer, Socket } from "socket.io";
import { RoomController } from "../controllers/room_controller";

export function initSocketHandlers(io: SocketIOServer) {
    io.on("connection", (socket: Socket) => {
        console.log("Socket connected:", socket.id);

        //create room socket
        socket.on("create-room", async ({ playerName, roomName, occupancy, maxRounds }) => {
            try {
                const room = await RoomController.createRoom(playerName, roomName, occupancy, maxRounds, socket.id);
                socket.join(roomName);
                io.to(roomName).emit("updateRoom", room);
            } catch (err) {
                socket.emit("notCorrectGame", err);
            }
        });

        //join room socket
        socket.on("join-room", async ({ playerName, roomName }) => {
            try {
                const room = await RoomController.joinRoom(playerName, roomName, socket.id);
                socket.join(roomName);
                io.to(roomName).emit("updateRoom", room);
            } catch (err) {
                socket.emit("incorrect-name", err);
            }
        });

        //change turn socket
        socket.on("change-turn", async ({ roomName }) => {
            try {
                const room = await RoomController.changeTurn(roomName);
                io.to(roomName).emit("change-turn", room);
            } catch (err) {
                console.error(err);
            }
        });

        //messages socket
        socket.on("message", async ({ roomName, playerName, message, timeTaken }) => {
            try {
                const { room, isCorrectWord, alreadyGussed } = await RoomController.handleMessage(roomName, playerName, message, timeTaken);
                io.to(roomName).emit("message", {
                    playerName,
                    message: isCorrectWord ? "Guessed it!" : message,
                    isCorrectWord: isCorrectWord,
                    alreadyGussed: alreadyGussed,
                });
            } catch (err) {
                console.error(err);
            }
        });

        // **Paint Event**
        socket.on("paint", ({ details, roomName }) => {
            try {
                io.to(roomName).emit("points", { details });
            } catch (err) {
                console.error("Paint event error:", err);
            }
        });

        // **Color Change Event**
        socket.on("color-change", ({ color, roomName }) => {
            try {
                io.to(roomName).emit("color-change", color);
            } catch (err) {
                console.error("Color change event error:", err);
            }
        });

        // **Stroke Width Change Event**
        socket.on("strokeWidth-change", ({ width, roomName }) => {
            try {
                io.to(roomName).emit("strokeWidth-change", width);
            } catch (err) {
                console.error("Stroke width change event error:", err);
            }
        });

        // **Clear Canvas Event**
        socket.on("clear-canvas", ({ roomName }) => {
            try {
                io.to(roomName).emit("clear-canvas", null);
            } catch (err) {
                console.error("Clear canvas event error:", err);
            }
        });

        // **Disconnection Handling**
        // socket.on("disconnect", async () => {
        //     try {
        //         const updatedRoom = await RoomController.handleDisconnection(socket.id);
        //         if (updatedRoom) {
        //             io.to(updatedRoom.roomName).emit("updateRoom", updatedRoom);
        //         }
        //     } catch (err) {
        //         console.error("Disconnect handling error:", err);
        //     }
        // });
    });
}
