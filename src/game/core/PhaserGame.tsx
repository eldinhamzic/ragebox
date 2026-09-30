'use client';
import { useEffect, useRef } from 'react';
import * as Phaser from 'phaser';

export function PhaserGame({ config, onReady }: { config: Phaser.Types.Core.GameConfig; onReady?: (game: Phaser.Game) => void }) {
  const hostRef = useRef<HTMLDivElement>(null);
  const gameRef = useRef<Phaser.Game>();
  useEffect(() => {
    if (!hostRef.current || gameRef.current) return;
    const game = new Phaser.Game({ ...config, parent: hostRef.current });
    gameRef.current = game; onReady?.(game);
    return () => { game.destroy(true); gameRef.current = undefined; };
  }, [config, onReady]);
  return <div ref={hostRef} className="game-canvas overflow-hidden rounded-2xl border border-white/10 bg-black shadow-2xl shadow-black/40 [&_canvas]:mx-auto [&_canvas]:block [&_canvas]:max-w-full" />;
}
