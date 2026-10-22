'use client';
import { useEffect, useRef } from 'react';
type GodotEmbedProps = { game: 'troll-run' | 'precision-challenge'; title: string; onResult?: (result: unknown) => void };
export function GodotEmbed({ game, title, onResult }: GodotEmbedProps) {
  const frame = useRef<HTMLIFrameElement>(null);
  useEffect(() => { if (!onResult) return; const receive = (event: MessageEvent) => { if (event.source === frame.current?.contentWindow && event.data?.type === 'ragebox-result') onResult(event.data.result); }; window.addEventListener('message', receive); return () => window.removeEventListener('message', receive); }, [onResult]);
  return <div className="overflow-hidden rounded-2xl border border-white/10 bg-black shadow-2xl shadow-black/40"><iframe ref={frame} title={title} src={`/games/${game}/index.html`} className="aspect-video w-full border-0" allow="fullscreen" /></div>;
}
