import RoomModel, { IRoom } from "../models/room";
import { IPlayer } from "../models/player";
import getWord from "../apis/generate_word";

export class RoomController {

    // Create a new room with the given parameters
    static async createRoom(playerName: string, roomName: string, occupancy: number, maxRounds: number, socketId: string): Promise<IRoom> {
        
        //check if room already exsists
        const existingRoom = await RoomModel.findOne({ roomName });
        if (existingRoom) throw new Error("Room with that name already exists!");

        const word = getWord(); //get random word

        //create player object
        const player: IPlayer = {
            playerName,
            socketId,
            isPartyLeader: true,    //player making room is the leader
            points: 0,
        };

        //create new room
        const room = new RoomModel({
            word,
            roomName,
            occupancy,
            maxRounds,
            players: [player],
        });

        return await room.save();
    }

    // Handle a player joining an existing room
    static async joinRoom(playerName: string, roomName: string, socketId: string): Promise<IRoom> {
        const room = await RoomModel.findOne({ roomName }); //find room by name

        // Emit 'incorrect-name' if room doesn't exist
        if (!room) throw new Error("Room name invalid!");  
        
        // Emit 'Room is full!' when occupancy is reached
        if (!room.isJoin) throw new Error("Room is full!");   
        
        //create new player object
        const player: IPlayer = {
            playerName: playerName,
            socketId: socketId,
            isPartyLeader: false,   //joining player is not room leader
            points: 0,
        };
        room.players.push(player);

        if (room.players.length === room.occupancy) {
            room.isJoin = false;    //if room is full, set isJoin to false
            room.turn = room.players[room.turnIndex];   //set player turn, once room is full
        }

        return await room.save();
    }

    // Change the turn to the next player or start a new round if all players have had their turn
    static async changeTurn(roomName: string): Promise<IRoom> {
        const room = await RoomModel.findOne({ roomName }); //find room by name
        
        if (!room) throw new Error("Room not found!");  // Emit error if room does not exist

        // Check if the current round can continue, if not, start the next round
        if (room.turnIndex === room.players.length - 1) {  // Last player's turn
            room.currentRound++;  // Move to the next round
            room.turnIndex = 0;   // Reset turn index to 0 for the first player
        } else {
            room.turnIndex++;  // Move to the next player's turn
        }

        room.word = getWord();  //get new word for next round
        room.turn = room.players[room.turnIndex];   //Set next player as the turn holder

        return await room.save();
    }

    // Handle the message sent by a player (guessing the word)
    static async handleMessage(roomName: string, playerName: string, message: string, timeTaken: number): Promise<{ room: IRoom; isCorrectWord: boolean }> {
        //find room by name
        const room = await RoomModel.findOne({ roomName });
        if (!room) throw new Error("Room not found!");  // Emit error if room does not exist

        let isCorrectWord = false;

        //If the message matches the word, award points to the player
        if (message === room.word) {
            const player = room.players.find((player) => player.playerName === playerName);
            if (player && timeTaken > 0) {
                player.points += Math.round(200 / timeTaken) * 10;
            }
            isCorrectWord = true;
        }

        return { room: await room.save(), isCorrectWord };
    }
}
