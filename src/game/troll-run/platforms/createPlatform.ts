import * as Phaser from 'phaser';

export type PlatformConfig = {
  x: number;
  y: number;
  width: number;
  height?: number;
};

const LAMINATE = 0xc89b6d;
const LAMINATE_LIGHT = 0xd8b38a;
const LAMINATE_ALT = 0xc29468;
const LAMINATE_JOINT = 0x9b6f49;

/** Creates the visual and static Arcade collision for one reusable wood platform. */
export function createPlatform(
  scene: Phaser.Scene,
  group: Phaser.Physics.Arcade.StaticGroup,
  config: PlatformConfig,
) {
  const height = config.height ?? 60;
  const centerY = config.y + height / 2;

  const collision = scene.add.rectangle(config.x + config.width / 2, centerY, config.width, height).setVisible(false);
  group.add(collision);

  const visual = scene.add.graphics();
  visual.fillStyle(LAMINATE, 1).fillRect(config.x, config.y, config.width, height);

  const boardWidth = 144;
  for (let boardX = config.x, board = 0; boardX < config.x + config.width; boardX += boardWidth, board++) {
    const currentWidth = Math.min(boardWidth, config.x + config.width - boardX);
    visual.fillStyle(board % 2 === 0 ? LAMINATE : LAMINATE_ALT, 1);
    visual.fillRect(boardX, config.y + 10, currentWidth, Math.max(0, height - 17));
    if (boardX > config.x) {
      visual.lineStyle(1, LAMINATE_JOINT, 0.55).lineBetween(boardX, config.y + 10, boardX, config.y + height - 7);
    }
    visual.lineStyle(1, 0xb58258, 0.28).lineBetween(boardX + 12, config.y + 22, boardX + currentWidth - 12, config.y + 22);
  }

  visual.fillStyle(LAMINATE_LIGHT, 1).fillRect(config.x, config.y, config.width, 10);
  visual.fillStyle(LAMINATE_JOINT, 1).fillRect(config.x, config.y + height - 7, config.width, 7);
  visual.lineStyle(1, 0xe7c49e, 0.65).lineBetween(config.x, config.y + 1, config.x + config.width, config.y + 1);

  return { collision, visual };
}
