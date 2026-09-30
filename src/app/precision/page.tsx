'use client';
import { useState } from 'react';
import Link from 'next/link';
import { AppShell } from '@/components/AppShell';
import { precisionChallenges } from '@/game/precision/challenges/registry';
import { StopAt100 } from '@/game/precision/scenes/StopAt100';

export default function PrecisionPage() { const [selected, setSelected] = useState<string | null>(null); const active = selected === 'stop-at-100';
  return <AppShell>{active ? <StopAt100 onBack={() => setSelected(null)} /> : <section className="mx-auto max-w-3xl px-1 pb-10 pt-14 sm:py-16"><p className="text-[10px] font-bold tracking-[.3em] text-cyan-300 sm:text-xs">PRECISION</p><h1 className="mt-3 text-4xl font-black leading-tight sm:text-5xl">Choose your challenge</h1><div className="mt-8 grid gap-3">{precisionChallenges.map(c => <button key={c.id} disabled={!c.available} onClick={() => setSelected(c.id)} className="flex min-h-[82px] items-center justify-between rounded-2xl border border-white/10 bg-white/[.04] p-4 text-left transition active:scale-[.99] enabled:hover:border-cyan-300/60 disabled:opacity-45 sm:p-5"><span><span className="block text-sm font-black sm:text-base">{c.name}</span><span className="mt-1 block text-xs text-white/45 sm:text-sm">{c.available ? 'Ready to play' : 'Coming soon'}</span></span><span className="text-xs font-bold text-cyan-300 sm:text-sm">{c.available ? 'PLAY →' : 'LOCKED'}</span></button>)}</div><Link href="/" className="mt-8 inline-block min-h-11 py-3 text-sm text-white/50">← Home</Link></section>}</AppShell>;
}
