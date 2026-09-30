'use client';
import { useCallback, useMemo, useState } from 'react';
import Link from 'next/link';
import { AppShell } from '@/components/AppShell';
import { PhaserGame } from '@/game/core/PhaserGame';
import { createTrollConfig } from '@/game/troll-run/scenes/createTrollConfig';
import { firstSteps } from '@/game/troll-run/levels/first-steps';
import { loadProgress, saveProgress } from '@/services/progress/progress';

export default function TrollRunClient() {
  const [playing, setPlaying] = useState(false);
  const [complete, setComplete] = useState<{ time: number; deaths: number } | null>(null);
  const [progress] = useState(loadProgress);
  const done = useCallback((r: { time: number; deaths: number }) => { setComplete(r); const old = loadProgress().trollRun; saveProgress({ trollRun: { completed: true, bestTime: old.bestTime ? Math.min(old.bestTime, r.time) : r.time, lowestDeaths: old.lowestDeaths !== undefined ? Math.min(old.lowestDeaths, r.deaths) : r.deaths } }); }, []);
  const trollConfig = useMemo(() => createTrollConfig(done), [done]);
  const start = () => { setComplete(null); setPlaying(true); };
  if (playing) return <AppShell><section className="mx-auto min-w-0 max-w-5xl px-0 pb-2 pt-3 sm:py-5"><div className="mb-2 flex min-w-0 items-center justify-between gap-3"><div className="min-w-0"><p className="truncate text-[10px] tracking-[.25em] text-fuchsia-300 sm:text-xs">TROLL RUN // {firstSteps.world}</p><h1 className="truncate text-xl font-black sm:mt-2 sm:text-3xl">{firstSteps.id} {firstSteps.name}</h1></div><button onClick={() => setPlaying(false)} className="min-h-11 shrink-0 rounded-full border border-white/20 px-4 py-2 text-sm">EXIT</button></div><p className="mb-2 text-xs text-white/55 md:hidden">Rotate your phone for the best experience.</p><PhaserGame config={trollConfig} /></section></AppShell>;
  return <AppShell><section className="mx-auto max-w-3xl py-16"><p className="text-xs font-bold tracking-[.3em] text-fuchsia-300">TROLL RUN</p><h1 className="mt-3 text-5xl font-black">LIVING ROOM</h1><p className="mt-3 text-white/55">Trust nothing. Everything is too big.</p><div className="mt-10 rounded-3xl border border-white/10 bg-white/[.04] p-7"><div className="flex items-start justify-between"><div><p className="text-cyan-300">LEVEL {firstSteps.id}</p><h2 className="mt-2 text-3xl font-black">{firstSteps.name}</h2><p className="mt-2 text-white/50">A short first run through the living room.</p></div>{progress.trollRun.completed && <span className="rounded-full bg-emerald-300/15 px-3 py-1 text-xs text-emerald-300">CLEARED</span>}</div><button onClick={start} className="mt-8 rounded-xl bg-white px-8 py-3 font-black text-black">PLAY</button></div><Link href="/" className="mt-8 inline-block text-sm text-white/50">← Home</Link>{complete && <div className="fixed inset-0 z-10 grid place-items-center bg-black/75 p-5"><div className="w-full max-w-sm rounded-3xl border border-cyan-300/30 bg-[#121725] p-8 text-center"><p className="text-xs tracking-[.3em] text-cyan-300">LEVEL COMPLETE</p><h2 className="mt-3 text-3xl font-black">NICE ESCAPE.</h2><p className="mt-5 text-white/65">Time: {complete.time.toFixed(2)}s<br />Deaths: {complete.deaths}</p><button onClick={start} className="mt-7 rounded-xl bg-white px-6 py-3 font-black text-black">RETRY</button><button onClick={() => setComplete(null)} className="mt-4 block w-full text-sm text-white/50">CONTINUE</button></div></div>}</section></AppShell>;
}
