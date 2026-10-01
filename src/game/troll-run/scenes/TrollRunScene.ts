import * as Phaser from 'phaser';
import { firstSteps } from '../levels/first-steps';
import type { PlatformDefinition } from '../levels/types';
import { createTrap, type TrapInstance } from '../traps/Trap';
import { PlayerVisual } from '../player/PlayerVisual';

const MAX_RUN_SPEED = 140;
const GROUND_ACCELERATION = 1500;
const GROUND_BRAKE_ACCELERATION = 2300;
const GROUND_FRICTION = 520;
const AIR_ACCELERATION = 950;
const AIR_BRAKE_ACCELERATION = 1300;
const JUMP_VELOCITY = 720;
const PLAYER_GRAVITY_BOOST = 850;
const DEATH_RETRY_MS = 560;

export class TrollRunScene extends Phaser.Scene {
  private player!: Phaser.Physics.Arcade.Sprite;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private keys!: { left: Phaser.Input.Keyboard.Key; right: Phaser.Input.Keyboard.Key; jump: Phaser.Input.Keyboard.Key };
  private platforms!: Phaser.Physics.Arcade.StaticGroup;
  private startTime = 0;
  private deaths = 0;
  private traps: TrapInstance[] = [];
  private dead = false;
  private visual!: PlayerVisual;
  private touch = { left: false, right: false, jump: false };
  private jumpWasDown = false;
  private facingLeft = false;

  constructor() { super('troll-run'); }

  create() {
    const level = firstSteps;
    this.startTime = Date.now();
    this.physics.world.setBounds(0, 0, level.width, level.height);
    this.physics.world.setBoundsCollision(true, true, true, false);
    this.createLivingRoom(level.width, level.height);

    this.add.graphics().fillStyle(0xffffff).fillRoundedRect(0, 0, 30, 42, 8).generateTexture('player', 30, 42);
    this.platforms = this.physics.add.staticGroup();
    level.platforms
      .filter(p => !level.traps.some(t => t.type === 'disappearing-platform' && t.x === p.x))
      .forEach(p => this.addPlatform(p));

    this.player = this.physics.add.sprite(level.playerStart.x, level.playerStart.y, 'player');
    this.player
      .setAlpha(0)
      .setCollideWorldBounds(true)
      .setBodySize(24, 72, true)
      .setGravityY(PLAYER_GRAVITY_BOOST);

    this.visual = new PlayerVisual(this);
    this.data.set('player', this.player);
    this.physics.add.collider(this.player, this.platforms);

    this.cursors = this.input.keyboard!.createCursorKeys();
    this.keys = {
      left: this.input.keyboard!.addKey('A'),
      right: this.input.keyboard!.addKey('D'),
      jump: this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE),
    };

    this.traps = level.traps.map(t => createTrap(this, t, () => this.die()));

    this.add.rectangle(level.finish.x, level.finish.y, 12, 130, 0xf5f7ff);
    this.add.triangle(level.finish.x + 35, level.finish.y - 55, 0, 0, 70, 20, 0, 40, 0xf05ab2);
    this.add.text(level.finish.x - 25, level.finish.y + 35, 'FINISH', { fontSize: '14px', color: '#f05ab2' });
    this.add.text(18, 16, '', { fontSize: '16px', color: '#eafaff', fontStyle: 'bold', lineSpacing: 5 }).setName('hud');

    this.addTouchButton(60, 505, 'LEFT', 'left');
    this.addTouchButton(125, 505, 'RIGHT', 'right');
    this.addTouchButton(840, 505, 'JUMP', 'jump');
  }

  private createLivingRoom(width: number, height: number) {
    const g = this.add.graphics();
    g.fillStyle(0x1a2233, 1).fillRect(0, 0, width, height);
    g.fillStyle(0x202b3e, 1).fillRect(0, 80, width, 430);
    g.fillStyle(0x111722, 1).fillRect(0, 510, width, 250);
    g.lineStyle(5, 0x334258, 1).lineBetween(0, 510, width, 510);
    g.fillStyle(0x27354a, 1).fillRoundedRect(260, 250, 600, 170, 32);
    g.fillStyle(0x34445b, 1).fillRoundedRect(300, 215, 520, 85, 28);
    g.fillStyle(0x151b29, 1).fillRect(290, 395, 45, 90);
    g.fillRect(780, 395, 45, 90);
  }

  private addTouchButton(x: number, y: number, label: string, key: keyof typeof this.touch) {
    const b = this.add.circle(x, y, 27, 0x0b111b, 0.62).setScrollFactor(0).setStrokeStyle(2, 0xbdefff, 0.62).setInteractive();
    this.add.text(x, y, label, { fontSize: '24px', color: '#dffaff', fontStyle: 'bold' }).setOrigin(0.5).setScrollFactor(0);
    b.on('pointerdown', () => { this.touch[key] = true; });
    b.on('pointerup', () => { this.touch[key] = false; });
    b.on('pointerout', () => { this.touch[key] = false; });
    b.on('pointerupoutside', () => { this.touch[key] = false; });
  }

  private addPlatform(p: PlatformDefinition) {
    const colors = { book: 0x356da8, lego: 0xd94a52, table: 0x8e5a3c, generic: 0x69748f };
    const r = this.add.rectangle(p.x + p.width / 2, p.y, p.width, p.height, colors[p.kind]);
    this.platforms.add(r);
    const g = this.add.graphics();
    if (p.kind === 'book') {
      g.fillStyle(0x1f4778, 1).fillRect(p.x, p.y + 12, p.width, 9);
      g.lineStyle(2, 0x79b8db, 0.75).lineBetween(p.x + 8, p.y - 10, p.x + p.width - 8, p.y - 10);
    } else if (p.kind === 'lego') {
      g.fillStyle(0xf5c84b, 1);
      for (let x = p.x + 22; x < p.x + p.width - 10; x += 38) g.fillCircle(x, p.y - 18, 7);
    } else if (p.kind === 'table') {
      g.fillStyle(0x5d3829, 1).fillRect(p.x + 18, p.y + 20, 20, 90).fillRect(p.x + p.width - 38, p.y + 20, 20, 90);
    } else {
      g.lineStyle(2, 0x9aa8bb, 0.65).strokeRect(p.x, p.y - 8, p.width, p.height + 8);
    }
  }

  private die() {
    if (this.dead) return;
    this.dead = true;
    this.deaths++;

    const body = this.player.body as Phaser.Physics.Arcade.Body;
    this.player.setVelocity(0, 0);
    body.enable = false;
    this.visual.playDeath();

    this.time.delayedCall(DEATH_RETRY_MS, () => {
      body.enable = true;
      this.player.setPosition(firstSteps.playerStart.x, firstSteps.playerStart.y);
      this.player.setVelocity(0, 0);
      this.traps.forEach(t => t.reset());
      this.visual.reset();
      this.jumpWasDown = false;
      this.dead = false;
    });
  }

  update(time: number, delta: number) {
    if (!this.player) return;

    if (this.dead) {
      this.visual.update(time, delta, { x: 0, y: 0 }, false);
      return;
    }

    const body = this.player.body as Phaser.Physics.Arcade.Body;
    const grounded = body.blocked.down || body.touching.down;
    const left = this.cursors.left.isDown || this.keys.left.isDown || this.touch.left;
    const right = this.cursors.right.isDown || this.keys.right.isDown || this.touch.right;
    const direction = left === right ? 0 : left ? -1 : 1;

    this.updateHorizontalMovement(direction, grounded, delta);

    if (direction < 0) this.facingLeft = true;
    else if (direction > 0) this.facingLeft = false;

    const jumpDown = this.cursors.up.isDown || this.keys.jump.isDown || this.touch.jump;
    if (jumpDown && !this.jumpWasDown && grounded) this.player.setVelocityY(-JUMP_VELOCITY);
    this.jumpWasDown = jumpDown;

    const currentGrounded = body.blocked.down || body.touching.down;
    this.visual.setPosition(this.player.x, body.bottom);
    this.visual.setFlipX(this.facingLeft);
    this.visual.update(time, delta, { x: body.velocity.x, y: body.velocity.y }, currentGrounded);

    if (this.player.y > firstSteps.height + 18) {
      this.die();
      return;
    }

    const elapsed = (Date.now() - this.startTime) / 1000;
    const minutes = Math.floor(elapsed / 60).toString().padStart(2, '0');
    const seconds = (elapsed % 60).toFixed(2).padStart(5, '0');
    const hud = this.children.getByName('hud') as Phaser.GameObjects.Text;
    hud.setText(`LEVEL ${firstSteps.id}\nDEATHS ${this.deaths}\nTIME ${minutes}:${seconds}`);

    if (this.player.x > firstSteps.finish.x - 40 && this.player.y < firstSteps.finish.y + 100) {
      this.scene.pause();
      this.events.emit('complete', { time: elapsed, deaths: this.deaths });
    }
  }

  private updateHorizontalMovement(direction: number, grounded: boolean, delta: number) {
    const body = this.player.body as Phaser.Physics.Arcade.Body;
    const dt = delta / 1000;
    let velocity = body.velocity.x;

    if (direction === 0) {
      if (grounded) velocity = this.approach(velocity, 0, GROUND_FRICTION * dt);
    } else {
      const reversing = Math.abs(velocity) > 1 && Math.sign(velocity) !== direction;
      const acceleration = grounded
        ? reversing ? GROUND_BRAKE_ACCELERATION : GROUND_ACCELERATION
        : reversing ? AIR_BRAKE_ACCELERATION : AIR_ACCELERATION;
      velocity = this.approach(velocity, direction * MAX_RUN_SPEED, acceleration * dt);
    }

    this.player.setVelocityX(Phaser.Math.Clamp(velocity, -MAX_RUN_SPEED, MAX_RUN_SPEED));
  }

  private approach(value: number, target: number, amount: number) {
    if (value < target) return Math.min(value + amount, target);
    if (value > target) return Math.max(value - amount, target);
    return target;
  }
}
