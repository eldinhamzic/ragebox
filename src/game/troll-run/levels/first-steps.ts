import type { LevelDefinition } from './types';
export const firstSteps: LevelDefinition = { id: '1-01', name: 'FIRST STEPS', world: 'LIVING ROOM', width: 3000, height: 760, playerStart: { x: 160, y: 520 }, finish: { x: 2740, y: 360 },
  platforms: [
    { x: 180, y: 620, width: 380, height: 50, kind: 'book' }, { x: 650, y: 555, width: 190, height: 35, kind: 'generic' },
    { x: 950, y: 475, width: 190, height: 35, kind: 'lego' }, { x: 1240, y: 580, width: 210, height: 45, kind: 'book', disappearing: { delayMs: 350 } },
    { x: 1600, y: 500, width: 300, height: 45, kind: 'table' }, { x: 2010, y: 400, width: 210, height: 35, kind: 'lego' },
    { x: 2320, y: 510, width: 250, height: 45, kind: 'table' }, { x: 2630, y: 420, width: 300, height: 50, kind: 'book' },
  ], traps: [{ type: 'disappearing-platform', x: 1240, y: 580, width: 210, height: 45, delayMs: 350 }, { type: 'hidden-spikes', x: 2150, y: 365, width: 90, height: 35, activationDelayMs: 250 }],
};
