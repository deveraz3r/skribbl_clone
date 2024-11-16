import mongoose, { Schema } from "mongoose";

export interface IPlayer {
    playerName: string;
    socketId: string;
    isPartyLeader: boolean;
    points: number;
}

const PlayerSchema = new Schema<IPlayer>({
    playerName: { type: String, required: true },
    socketId: { type: String, required: true },
    isPartyLeader: { type: Boolean, default: false },
    points: { type: Number, default: 0 },
});

const PlayerModel = mongoose.model<IPlayer>("Player", PlayerSchema);

export { PlayerSchema, PlayerModel };
