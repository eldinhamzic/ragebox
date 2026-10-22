'use client';
import { useState } from 'react';
import Link from 'next/link';
import { AppShell } from '@/components/AppShell';
import { GodotEmbed } from '@/components/GodotEmbed';
export default function PrecisionPage() { const [selected, setSelected] = useState(false); return <AppShell><section className="mx-auto max-w-3xl px-1 pb-10 pt-14 sm:py-16"><p className="text-[10px] font-bold tracking-[.3em] text-cyan-300 sm:text-xs">PRECISION</p><h1 className="mt-3 text-4xl font-black leading-tight sm:text-5xl">Stop at 100%</h1>{selected ? <GodotEmbed game="precision-challenge" title="100% Challenge" /> : <button onClick={() => setSelected(true)} className="mt-8 flex min-h-[82px] w-full items-center justify-between rounded-2xl border border-white/10 bg-white/[.04] p-5 text-left"><span><span className="block font-black">STOP AT 100</span><span className="mt-1 block text-sm text-white/45">Hold to charge, release at exactly 100%.</span></span><span className="text-sm font-bold text-cyan-300">PLAY →</span></button>}<Link href="/" className="mt-8 inline-block min-h-11 py-3 text-sm text-white/50">← Home</Link></section></AppShell>; }
