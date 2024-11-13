import mongoose, { Schema, Document } from 'mongoose';

export interface Player extends Document {
  playerName: string;
  socketId: string;
  isPartyLeader: boolean;
  points: number;
}

export const playerSchema = new Schema<Player>({
  playerName: {
    type: String,
    trim: true,
  },
  socketId: {
    type: String,
  },
  isPartyLeader: {
    type: Boolean,
    default: false,
  },
  points: {
    type: Number,
    default: 0,
  },
});

const PlayerModel = mongoose.model<Player>('Player', playerSchema);

export { PlayerModel };
