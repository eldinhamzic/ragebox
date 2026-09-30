export type PrecisionResult = { challengeId: string; value: number; accuracy: number; score: number; passed: boolean; metadata?: Record<string, unknown> };
export type ChallengeMeta = { id: string; name: string; available: boolean };
