export type PlatformKind = 'wood';
export type PlatformDefinition = { x: number; y: number; width: number; height: number; kind?: PlatformKind; disappearing?: { delayMs: number } };
export type TrapDefinition = { type: 'disappearing-platform' | 'hidden-spikes'; x: number; y: number; width: number; height: number; delayMs?: number; activationDelayMs?: number };
export type LevelDefinition = { id: string; name: string; world: string; width: number; height: number; playerStart: { x: number; y: number }; finish: { x: number; y: number }; platforms: PlatformDefinition[]; traps: TrapDefinition[] };
