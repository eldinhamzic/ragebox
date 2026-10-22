import { Body, Controller, Post } from '@nestjs/common';
import { IsIn, IsInt, IsNumber, IsString, Max, Min } from 'class-validator';
import { ScoresService } from './scores.service';

class SubmitScoreDto {
  @IsString() playerId!: string;
  @IsIn(['troll-run', 'stop-at-100']) gameId!: 'troll-run' | 'stop-at-100';
  @IsNumber() @Min(0) @Max(100000) score!: number;
  @IsInt() @Min(0) @Max(100000) durationMs!: number;
  @IsString() sessionToken!: string;
}

@Controller('scores')
export class ScoresController {
  constructor(private readonly scores: ScoresService) {}
  @Post()
  submit(@Body() body: SubmitScoreDto) { return this.scores.validateAndStore(body); }
}
