import { BadRequestException, Injectable } from '@nestjs/common';
import { createHash } from 'node:crypto';

type ScoreInput = { playerId: string; gameId: 'troll-run' | 'stop-at-100'; score: number; durationMs: number; sessionToken: string };
@Injectable()
export class ScoresService {
  validateAndStore(input: ScoreInput) {
    const expected = createHash('sha256').update(`${input.playerId}:${input.gameId}:${process.env.SCORE_SIGNING_SECRET ?? 'development-only'}`).digest('hex');
    if (input.sessionToken !== expected) throw new BadRequestException('Invalid game session');
    if (input.gameId === 'stop-at-100' && input.score > 1000) throw new BadRequestException('Invalid precision score');
    return { accepted: true, playerId: input.playerId, gameId: input.gameId, score: input.score, durationMs: input.durationMs };
  }
}
