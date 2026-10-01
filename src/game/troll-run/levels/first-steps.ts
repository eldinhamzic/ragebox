import type { LevelDefinition } from './types';
export const firstSteps: LevelDefinition = { id: '1-01', name: 'FIRST STEPS', world: 'LIVING ROOM', width: 960, height: 540, playerStart: { x: 90, y: 390 }, finish: { x: 875, y: 375 },
  platforms: [
    { x: 0, y: 490, width: 290, height: 50, kind: 'book' }, { x: 340, y: 455, width: 160, height: 30, kind: 'generic' },
    { x: 550, y: 490, width: 410, height: 50, kind: 'book' },
  ], traps: [{ type: 'disappearing-platform', x: 340, y: 455, width: 160, height: 30, delayMs: 350 }],
};
