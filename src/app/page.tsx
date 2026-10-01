import Link from 'next/link';
import { AppShell } from '@/components/AppShell';

const games = [
  { href: '/precision', title: 'IZAZOVI', subtitle: 'Preciznost pod pritiskom.', color: 'from-cyan-400/20 to-blue-900/20' },
  { href: '/troll-run', title: 'TROLL RUN', subtitle: 'Trust nothing.', color: 'from-fuchsia-400/20 to-red-900/20' },
];

export default function Home() {
  return <AppShell>
    <section className="mx-auto max-w-5xl px-1 pb-10 pt-14 sm:py-24">
      <div className="mb-8 flex flex-wrap items-end justify-between gap-5 sm:mb-12">
        <div>
          <p className="mb-3 text-[10px] font-bold tracking-[.28em] text-fuchsia-300 sm:text-xs">THE SMALL GAME COLLECTION</p>
          <h1 className="text-[clamp(3.2rem,13vw,5rem)] font-black leading-[.9] tracking-tight">RAGEBOX</h1>
        </div>
        <div className="rounded-2xl border border-yellow-300/20 bg-yellow-300/10 px-5 py-3 text-right">
          <p className="text-[10px] font-bold tracking-[.22em] text-yellow-200/70">RAGE COINS</p>
          <p className="mt-1 text-2xl font-black text-yellow-100">0</p>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        {games.map((game, index) => <Link key={game.href} href={game.href} className={`group flex min-h-[230px] flex-col justify-between rounded-[1.75rem] border border-white/10 bg-gradient-to-br ${game.color} p-5 shadow-2xl shadow-black/20 transition active:scale-[.99] hover:-translate-y-1 hover:border-cyan-300/50 sm:min-h-[280px] sm:rounded-3xl sm:p-7`}>
          <div className="flex justify-between text-[10px] font-bold tracking-widest text-white/40 sm:text-xs"><span>MODE 0{index + 1}</span><span>● LIVE</span></div>
          <div><h2 className="text-3xl font-black sm:text-4xl">{game.title}</h2><p className="mt-2 text-sm text-white/60 sm:text-base">{game.subtitle}</p><span className="mt-6 inline-flex min-h-12 items-center rounded-xl bg-white px-8 py-3 text-sm font-black text-black">OPEN</span></div>
        </Link>)}
      </div>

      <div className="mt-5 flex items-center justify-center gap-3 sm:justify-end">
        <span className="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold text-white/60">SHOP</span>
        <span className="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold text-white/60">PROFILE · PLAYER</span>
      </div>
    </section>
  </AppShell>;
}
