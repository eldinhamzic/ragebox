import Link from 'next/link';
import { AppShell } from '@/components/AppShell';

const games = [
  { href: '/precision', title: 'PRECISION', subtitle: 'How precise are you?', color: 'from-cyan-400/20 to-blue-900/20' },
  { href: '/troll-run', title: 'TROLL RUN', subtitle: 'Trust nothing.', color: 'from-fuchsia-400/20 to-red-900/20' },
];

export default function Home() {
  return <AppShell><section className="mx-auto max-w-5xl px-1 pb-10 pt-16 sm:py-28">
    <div className="mb-10 max-w-xl sm:mb-12"><p className="mb-4 text-[10px] font-bold tracking-[.28em] text-fuchsia-300 sm:text-xs">THE SMALL GAME COLLECTION</p><h1 className="text-[clamp(2.8rem,13vw,4.5rem)] font-black leading-[.92] tracking-tight">PICK YOUR<br /><span className="text-cyan-300">RAGE.</span></h1><p className="mt-5 max-w-xs text-sm leading-6 text-white/55 sm:text-base">Fast challenges. Big mistakes. Instant retries.</p></div>
    <div className="grid gap-4 md:grid-cols-2">{games.map((game, i) => <Link key={game.href} href={game.href} className={`group min-h-[255px] rounded-[1.75rem] border border-white/10 bg-gradient-to-br ${game.color} p-5 shadow-2xl shadow-black/20 transition active:scale-[.99] hover:-translate-y-1 hover:border-cyan-300/50 sm:min-h-[310px] sm:rounded-3xl sm:p-7`}><div className="mb-14 flex justify-between text-[10px] font-bold tracking-widest text-white/40 sm:mb-16 sm:text-xs"><span>MODE 0{i + 1}</span><span>● LIVE</span></div><h2 className="text-2xl font-black sm:text-3xl">{game.title}</h2><p className="mt-2 text-sm text-white/60 sm:text-base">{game.subtitle}</p><span className="mt-7 inline-flex min-h-12 items-center rounded-xl bg-white px-8 py-3 text-sm font-black text-black">PLAY</span></Link>)}</div>
  </section></AppShell>;
}
