import type { LevelDefinition } from './types';

export const firstSteps: LevelDefinition = {
  id: '1-01', name: 'FIRST STEPS', world: 'LIVING ROOM', width: 960, height: 540,
  playerStart: { x: 100, y: 400 }, finish: { x: 875, y: 385 },
  platforms: [
    { x: 0, y: 470, width: 540, height: 70, kind: 'wood' },
    { x: 650, y: 470, width: 310, height: 70, kind: 'wood' },
  ],
  traps: [],
};
