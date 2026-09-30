import Link from 'next/link';

export function AppShell({ children, back = '/' }: { children: React.ReactNode; back?: string }) {
  return <main className="arcade-grid safe-bottom min-h-[100svh] px-4 pt-5 sm:px-10 sm:py-6">
    <header className="mx-auto flex max-w-5xl items-center justify-between">
      <Link href="/" className="text-lg font-black tracking-[.25em] text-cyan-300 sm:text-xl">RAGEBOX</Link>
      {back !== '/' && <Link href={back} className="min-h-11 rounded-full border border-white/20 px-4 py-2.5 text-sm text-white/70 hover:bg-white/10">BACK</Link>}
    </header>{children}
  </main>;
}
