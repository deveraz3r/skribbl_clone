import mongoose, { Schema, Document } from "mongoose";
import { IPlayer, PlayerSchema } from "./player";

export interface IRoom extends Document {
    word: string;
    roomName: string;
    occupancy: number;
    maxRounds: number;
    currentRound: number;
    turnIndex: number;
    gussedPlayers: string[];
    players: IPlayer[];
    turn: IPlayer | null;
    isJoin: boolean;
}

const RoomSchema = new Schema<IRoom>({
    word: { type: String, required: true },
    roomName: { type: String, required: true, unique: true },
    occupancy: { type: Number, required: true },
    maxRounds: { type: Number, required: true },
    currentRound: { type: Number, default: 1 },
    turnIndex: { type: Number, default: 0 },
    gussedPlayers: {type: [String], default: []},
    players: { type: [PlayerSchema], required: true },
    turn: { type: PlayerSchema, default: null },
    isJoin: { type: Boolean, default: true },
});

const RoomModel = mongoose.model<IRoom>("Room", RoomSchema);

export default RoomModel;
