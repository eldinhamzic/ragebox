export type ProgressData = { version: 1; precision: { bestScore: number }; trollRun: { completed: boolean; bestTime?: number; lowestDeaths?: number } };
const KEY = 'ragebox-progress-v1';
const initial: ProgressData = { version: 1, precision: { bestScore: 0 }, trollRun: { completed: false } };
export function loadProgress(): ProgressData { if (typeof window === 'undefined') return initial; try { return { ...initial, ...JSON.parse(localStorage.getItem(KEY) || '{}') }; } catch { return initial; } }
export function saveProgress(patch: Partial<ProgressData>) { if (typeof window === 'undefined') return; localStorage.setItem(KEY, JSON.stringify({ ...loadProgress(), ...patch, version: 1 })); }
