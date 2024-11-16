import mongoose, { Schema, Document } from 'mongoose';
import { playerSchema, Player } from './player';

interface Room extends Document {
    word: string;
    roomName: string;
    occupancy: number;
    maxRounds: number;
    currentRound: number;
    players: Player[];
    isJoin: boolean;
    turn: Player | null;
    turnIndex: number;
}

const roomSchema = new Schema<Room>({
    word: {
        type: String,
        required: true
    },
    roomName: { 
        type: String, 
        required: true, 
        unique: true, 
        trim: true 
    },
    occupancy: { 
        type: Number, 
        default: 4, 
        required: true 
    },
    maxRounds: { 
        type: Number, 
        required: true 
    },
    currentRound: { 
        type: Number, 
        default: 1 
    },
    players: [playerSchema],
    isJoin: { 
        type: Boolean, 
        default: true 
    },
    turn: { 
        type: playerSchema, 
        default: null 
    },
    turnIndex: { 
        type: Number, 
        default: 0 
    },
});

const RoomModel = mongoose.model<Room>('Room', roomSchema);
export default RoomModel;
