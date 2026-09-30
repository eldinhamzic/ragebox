import * as Phaser from 'phaser';

export type PlayerVisualState = 'idle' | 'run' | 'jump' | 'fall' | 'land' | 'dead';
type Motion = { x: number; y: number };

/** Lightweight presentation-only stick figure. It owns no physics bodies. */
export class PlayerVisual {
  private readonly root: Phaser.GameObjects.Container;
  private readonly clothes: Phaser.GameObjects.Graphics;
  private readonly skeleton: Phaser.GameObjects.Graphics;
  private readonly face: Phaser.GameObjects.Graphics;
  private state: PlayerVisualState = 'idle';
  private previousGrounded = true;
  private landingUntil = 0;
  private phase = 0;

  constructor(scene: Phaser.Scene) {
    this.root = scene.add.container(0, 0);
    this.clothes = scene.add.graphics();
    this.skeleton = scene.add.graphics();
    this.face = scene.add.graphics();
    this.root.add([this.clothes, this.skeleton, this.face]);
    this.root.setDepth(5);
  }

  setState(state: PlayerVisualState) { this.state = state; }
  setPosition(x: number, y: number) { this.root.setPosition(x, y); }
  setFlipX(flip: boolean) { this.root.setScale(flip ? -1 : 1, 1); }
  destroy() { this.root.destroy(); }

  update(time: number, delta: number, motion: Motion, grounded: boolean) {
    const moving = Math.abs(motion.x) > 12;
    if (grounded && !this.previousGrounded && motion.y > 0) this.landingUntil = time + 110;
    this.previousGrounded = grounded;
    if (this.state !== 'dead') {
      if (time < this.landingUntil) this.state = 'land';
      else if (!grounded) this.state = motion.y < 0 ? 'jump' : 'fall';
      else this.state = moving ? 'run' : 'idle';
    }
    if (moving && grounded) this.phase += delta * 0.012 * Math.min(1.5, Math.abs(motion.x) / 150);
    this.draw(time);
  }

  private draw(time: number) {
    const run = this.state === 'run' ? Math.sin(this.phase) : 0;
    const runOpposite = this.state === 'run' ? Math.sin(this.phase + Math.PI) : 0;
    const falling = this.state === 'fall';
    const jumping = this.state === 'jump';
    const landing = this.state === 'land';
    const dead = this.state === 'dead';
    const bob = this.state === 'idle' ? Math.sin(time * 0.003) * 1.2 : 0;
    const crouch = landing ? 7 : jumping ? -3 : 0;
    const lean = this.state === 'run' ? 4 : 0;
    const shoulderY = -30 + crouch + bob;
    const hipY = 3 + crouch + bob;
    const headY = -54 + crouch + bob;
    const armSwing = this.state === 'run' ? 15 * run : jumping ? -10 : falling ? -3 : 0;
    const legSwing = this.state === 'run' ? 16 * run : jumping ? 5 : falling ? -2 : 0;

    this.skeleton.clear();
    this.skeleton.lineStyle(3, 0x171923, 1);
    this.skeleton.lineBetween(0, shoulderY, lean, hipY);
    this.lineJoint(-3, shoulderY, -15 - armSwing * 0.45, shoulderY + 14, -22 - armSwing, shoulderY + 29);
    this.lineJoint(3, shoulderY, 15 + armSwing * 0.45, shoulderY + 14, 22 + armSwing, shoulderY + 29);
    this.lineJoint(-3 + lean, hipY, -10 - legSwing * 0.35, 27 + crouch * 0.3, -14 - legSwing, 51 + crouch);
    this.lineJoint(3 + lean, hipY, 10 + legSwing * 0.35, 27 + crouch * 0.3, 14 + legSwing, 51 + crouch);
    this.skeleton.fillStyle(0x171923, 1);
    [[-22 - armSwing, shoulderY + 29], [22 + armSwing, shoulderY + 29], [-14 - legSwing, 51 + crouch], [14 + legSwing, 51 + crouch]].forEach(([x, y]) => this.skeleton.fillCircle(x, y, 3));

    this.clothes.clear();
    this.clothes.fillStyle(0xd92f45, 1);
    this.clothes.lineStyle(2, 0x8d1d32, 1);
    this.clothes.beginPath();
    this.clothes.moveTo(-15, shoulderY - 1);
    this.clothes.lineTo(15, shoulderY - 1);
    this.clothes.lineTo(13 + lean, hipY + 17);
    this.clothes.lineTo(-13 + lean, hipY + 17);
    this.clothes.closePath();
    this.clothes.fillPath(); this.clothes.strokePath();
    this.clothes.fillStyle(0x272b38, 1);
    this.clothes.fillRect(-15 + lean, hipY + 12, 30, 12);
    this.clothes.lineStyle(3, 0xd92f45, 1);
    this.clothes.lineBetween(-10, shoulderY + 2, -14 - armSwing * 0.45, shoulderY + 14);
    this.clothes.lineBetween(10, shoulderY + 2, 14 + armSwing * 0.45, shoulderY + 14);
    this.shoe(-14 - legSwing, 51 + crouch); this.shoe(14 + legSwing, 51 + crouch);

    this.face.clear();
    this.face.fillStyle(0xf3eadb, 1); this.face.lineStyle(2, 0x171923, 1);
    this.face.fillCircle(0, headY, 14); this.face.strokeCircle(0, headY, 14);
    this.face.fillStyle(0x171923, 1);
    this.face.fillCircle(-5, headY - 1, 2); this.face.fillCircle(5, headY - 1, 2);
    this.face.lineStyle(2, 0x171923, 1); this.face.lineBetween(-8, headY - 6, -3, headY - 8); this.face.lineBetween(3, headY - 8, 8, headY - 6);
    this.face.fillStyle(0xd92f45, 1); this.face.fillRoundedRect(-16, headY - 15, 27, 5, 3); this.face.fillTriangle(5, headY - 12, 16, headY - 10, 7, headY - 8);
    if (dead) { this.face.clear(); this.face.lineStyle(3, 0xe44b69, 1); this.face.lineBetween(-9, headY - 5, -2, headY + 2); this.face.lineBetween(-2, headY - 5, -9, headY + 2); this.face.lineBetween(3, headY - 5, 10, headY + 2); this.face.lineBetween(10, headY - 5, 3, headY + 2); }
  }

  private lineJoint(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number) {
    this.skeleton.lineBetween(x1, y1, x2, y2); this.skeleton.lineBetween(x2, y2, x3, y3); this.skeleton.fillCircle(x2, y2, 2.5);
  }

  private shoe(x: number, y: number) { this.clothes.fillStyle(0xf4f1e8, 1); this.clothes.fillRoundedRect(x - 7, y - 2, 16, 7, 3); this.clothes.fillStyle(0x2ec4d6, 1); this.clothes.fillRect(x - 4, y, 7, 2); }
}
