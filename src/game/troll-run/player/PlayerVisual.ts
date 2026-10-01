import * as Phaser from 'phaser';

export type PlayerVisualState = 'idle' | 'run' | 'jump' | 'fall' | 'land' | 'dead';
type Motion = { x: number; y: number };
type Point = { x: number; y: number };
type Limb = { start: Point; joint: Point; end: Point };
type Pose = {
  pelvis: Point;
  chest: Point;
  neck: Point;
  head: Point;
  leftLeg: Limb;
  rightLeg: Limb;
  leftArm: Limb;
  rightArm: Limb;
};
type DeathPiece = {
  graphic: Phaser.GameObjects.Graphics;
  vx: number;
  vy: number;
  rotationSpeed: number;
  age: number;
};

const PLAYER_VISUAL_SCALE = 0.70;
const RUN_CYCLE_DISTANCE = 54;
const LANDING_DURATION_MS = 130;
const RUN_BOB_AMOUNT = 1.4;
const SHIRT_LAG_MAX = 3;
const DEATH_GRAVITY = 950;
const DEATH_FADE_START_MS = 360;

/** Presentation-only procedural stickman. It never owns or changes a physics body. */
export class PlayerVisual {
  private readonly scene: Phaser.Scene;
  private readonly root: Phaser.GameObjects.Container;
  private readonly bodyLayer: Phaser.GameObjects.Graphics;
  private readonly clothesLayer: Phaser.GameObjects.Graphics;
  private readonly armsLayer: Phaser.GameObjects.Graphics;
  private readonly faceLayer: Phaser.GameObjects.Graphics;
  private readonly deathLayer: Phaser.GameObjects.Container;
  private readonly deathPieces: DeathPiece[] = [];

  private state: PlayerVisualState = 'idle';
  private previousGrounded = true;
  private landingUntil = 0;
  private phase = 0;
  private facing = 1;
  private lastMotion: Motion = { x: 0, y: 0 };

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.root = scene.add.container(0, 0);
    this.bodyLayer = scene.add.graphics();
    this.clothesLayer = scene.add.graphics();
    this.armsLayer = scene.add.graphics();
    this.faceLayer = scene.add.graphics();
    this.deathLayer = scene.add.container(0, 0);

    this.root.add([
      this.bodyLayer,
      this.clothesLayer,
      this.armsLayer,
      this.faceLayer,
      this.deathLayer,
    ]);
    this.root.setDepth(5);
    this.applyScale();
  }

  setPosition(x: number, footY: number) {
    this.root.setPosition(x, footY);
  }

  setFlipX(flip: boolean) {
    this.facing = flip ? -1 : 1;
    this.applyScale();
  }

  playDeath() {
    if (this.state === 'dead') return;
    this.state = 'dead';
    this.bodyLayer.setVisible(false);
    this.clothesLayer.setVisible(false);
    this.armsLayer.setVisible(false);
    this.faceLayer.setVisible(false);
    this.createDeathPieces();
  }

  reset() {
    this.clearDeathPieces();
    this.state = 'idle';
    this.previousGrounded = false;
    this.landingUntil = 0;
    this.bodyLayer.setVisible(true);
    this.clothesLayer.setVisible(true);
    this.armsLayer.setVisible(true);
    this.faceLayer.setVisible(true);
  }

  destroy() {
    this.clearDeathPieces();
    this.root.destroy(true);
  }

  update(time: number, delta: number, motion: Motion, grounded: boolean) {
    this.lastMotion = motion;

    if (this.state === 'dead') {
      this.updateDeath(delta);
      return;
    }

    const moving = Math.abs(motion.x) > 8;

    if (grounded && !this.previousGrounded) {
      this.landingUntil = time + LANDING_DURATION_MS;
    }
    this.previousGrounded = grounded;

    if (time < this.landingUntil) this.state = 'land';
    else if (!grounded) {
      if (motion.y < -95) this.state = 'jump';
      else if (motion.y > 115) this.state = 'fall';
      else this.state = 'jump';
    } else this.state = moving ? 'run' : 'idle';

    if (moving && grounded) {
      const travelled = Math.abs(motion.x) * (delta / 1000);
      this.phase += (travelled / RUN_CYCLE_DISTANCE) * Math.PI * 2;
    }

    this.draw(time);
  }

  private applyScale() {
    this.root.setScale(this.facing * PLAYER_VISUAL_SCALE, PLAYER_VISUAL_SCALE);
  }

  private draw(time: number) {
    const pose = this.calculatePose(time);
    this.drawBody(pose);
    this.drawClothes(pose);
    this.drawArms(pose);
    this.drawFace(pose);
  }

  private calculatePose(time: number): Pose {
    const landing = this.state === 'land';
    const running = this.state === 'run';
    const jumping = this.state === 'jump';
    const falling = this.state === 'fall';

    let crouch = 0;
    let bob = 0;
    let lean = 0;

    if (running) {
      bob = Math.abs(Math.sin(this.phase * 2)) * RUN_BOB_AMOUNT;
      lean = 3.5;
    } else if (this.state === 'idle') {
      bob = Math.sin(time * 0.0025) * 0.8;
    }

    if (landing) {
      const remaining = Math.max(0, this.landingUntil - time);
      const progress = 1 - remaining / LANDING_DURATION_MS;
      crouch = Math.sin(Phaser.Math.Clamp(progress, 0, 1) * Math.PI) * 10;
      lean = 2;
    }

    const pelvis = { x: 0, y: -45 + crouch + bob };
    const chest = { x: lean, y: -73 + crouch + bob };
    const neck = { x: lean, y: -85 + crouch + bob };
    const head = { x: lean + 1, y: -99 + crouch + bob };

    let leftFoot = { x: -7, y: 0 };
    let rightFoot = { x: 7, y: 0 };

    if (running) {
      leftFoot = this.runFoot(this.phase, -3);
      rightFoot = this.runFoot(this.phase + Math.PI, 3);
    } else if (jumping && this.lastMotion.y < -95) {
      leftFoot = { x: -15, y: -15 };
      rightFoot = { x: 17, y: -8 };
    } else if (jumping) {
      leftFoot = { x: -13, y: -18 };
      rightFoot = { x: 14, y: -16 };
    } else if (falling) {
      leftFoot = { x: -11, y: -5 };
      rightFoot = { x: 12, y: -3 };
    } else if (landing) {
      leftFoot = { x: -15, y: 0 };
      rightFoot = { x: 15, y: 0 };
    }

    const leftLeg = this.solveLeg({ x: -5, y: pelvis.y }, leftFoot, 27, 30);
    const rightLeg = this.solveLeg({ x: 5, y: pelvis.y }, rightFoot, 27, 30);

    const leftShoulder = { x: chest.x - 7, y: chest.y - 3 };
    const rightShoulder = { x: chest.x + 7, y: chest.y - 3 };
    let leftHand = { x: -17, y: chest.y + 31 };
    let rightHand = { x: 17, y: chest.y + 31 };

    if (running) {
      const swing = Math.sin(this.phase) * 20;
      leftHand = { x: -14 - swing, y: chest.y + 28 };
      rightHand = { x: 14 + swing, y: chest.y + 28 };
    } else if (jumping && this.lastMotion.y < -95) {
      leftHand = { x: -15, y: head.y - 24 };
      rightHand = { x: 17, y: head.y - 27 };
    } else if (jumping) {
      leftHand = { x: -24, y: head.y - 8 };
      rightHand = { x: 25, y: head.y - 10 };
    } else if (falling) {
      leftHand = { x: -28, y: chest.y + 6 };
      rightHand = { x: 29, y: chest.y + 6 };
    } else if (landing) {
      leftHand = { x: -24, y: chest.y + 27 };
      rightHand = { x: 24, y: chest.y + 27 };
    }

    return {
      pelvis,
      chest,
      neck,
      head,
      leftLeg,
      rightLeg,
      leftArm: this.makeArm(leftShoulder, leftHand, -3),
      rightArm: this.makeArm(rightShoulder, rightHand, 3),
    };
  }

  private runFoot(phase: number, offsetX: number) {
    const stride = 24;
    const forward = Math.sin(phase) * stride;
    const lift = Math.max(0, Math.sin(phase)) * 12;
    return { x: forward + offsetX, y: -lift };
  }

  private solveLeg(hip: Point, foot: Point, upperLength: number, lowerLength: number): Limb {
    const dx = foot.x - hip.x;
    const dy = foot.y - hip.y;
    const rawDistance = Math.sqrt(dx * dx + dy * dy);
    const minDistance = Math.abs(upperLength - lowerLength) + 0.01;
    const maxDistance = upperLength + lowerLength - 0.01;
    const distance = Phaser.Math.Clamp(rawDistance, minDistance, maxDistance);
    const angle = Math.atan2(dy, dx);
    const cosValue = Phaser.Math.Clamp(
      (upperLength * upperLength + distance * distance - lowerLength * lowerLength) /
        (2 * upperLength * distance),
      -1,
      1,
    );
    const offset = Math.acos(cosValue);
    const a = angle - offset;
    const b = angle + offset;
    const kneeA = { x: hip.x + Math.cos(a) * upperLength, y: hip.y + Math.sin(a) * upperLength };
    const kneeB = { x: hip.x + Math.cos(b) * upperLength, y: hip.y + Math.sin(b) * upperLength };
    const joint = kneeA.x > kneeB.x ? kneeA : kneeB;
    return { start: hip, joint, end: foot };
  }

  private makeArm(shoulder: Point, hand: Point, bend: number): Limb {
    return {
      start: shoulder,
      joint: {
        x: Phaser.Math.Linear(shoulder.x, hand.x, 0.52) + bend,
        y: Phaser.Math.Linear(shoulder.y, hand.y, 0.52) + 2,
      },
      end: hand,
    };
  }

  private drawBody(pose: Pose) {
    this.bodyLayer.clear();
    this.drawLimb(this.bodyLayer, pose.rightLeg, 3.5, 0.72);
    this.drawLimb(this.bodyLayer, pose.leftLeg, 3.5, 1);
    this.bodyLayer.lineStyle(3.5, 0x171923, 1);
    this.bodyLayer.lineBetween(pose.neck.x, pose.neck.y, pose.pelvis.x, pose.pelvis.y);
  }

  private drawClothes(pose: Pose) {
    this.clothesLayer.clear();

    const shirtLag = Phaser.Math.Clamp(-this.lastMotion.x * 0.012, -SHIRT_LAG_MAX, SHIRT_LAG_MAX);
    const lift = this.state === 'jump' || this.state === 'fall' ? -1.5 : 0;
    const shoulderY = pose.chest.y - 8;
    const hemY = pose.pelvis.y - 5 + lift;

    this.clothesLayer.fillStyle(0xdf4052, 1);
    this.clothesLayer.lineStyle(1.8, 0x7e2432, 1);
    this.clothesLayer.beginPath();
    this.clothesLayer.moveTo(pose.chest.x - 14, shoulderY);
    this.clothesLayer.lineTo(pose.chest.x + 14, shoulderY);
    this.clothesLayer.lineTo(11 + shirtLag, hemY);
    this.clothesLayer.lineTo(-11 + shirtLag, hemY);
    this.clothesLayer.closePath();
    this.clothesLayer.fillPath();
    this.clothesLayer.strokePath();

    this.clothesLayer.fillStyle(0x12151f, 1);
    this.clothesLayer.fillCircle(pose.neck.x, shoulderY + 1, 4);

    this.drawSleeve(pose.leftArm.start, pose.leftArm.joint);
    this.drawSleeve(pose.rightArm.start, pose.rightArm.joint);

    const hipY = pose.pelvis.y;
    this.clothesLayer.fillStyle(0x252a37, 1);
    this.clothesLayer.lineStyle(1.6, 0x171923, 1);
    this.clothesLayer.fillRoundedRect(-12, hipY - 5, 24, 11, 3);
    this.clothesLayer.strokeRoundedRect(-12, hipY - 5, 24, 11, 3);
    this.drawShortLeg(-5, hipY + 3, pose.leftLeg);
    this.drawShortLeg(5, hipY + 3, pose.rightLeg);

    this.drawShoe(pose.rightLeg.end, 0.72);
    this.drawShoe(pose.leftLeg.end, 1);
  }

  private drawSleeve(shoulder: Point, elbow: Point) {
    const dx = elbow.x - shoulder.x;
    const dy = elbow.y - shoulder.y;
    const length = Math.sqrt(dx * dx + dy * dy) || 1;
    const nx = -dy / length;
    const ny = dx / length;
    const sleeveEnd = { x: shoulder.x + dx * 0.27, y: shoulder.y + dy * 0.27 };

    this.clothesLayer.fillStyle(0xdf4052, 1);
    this.clothesLayer.lineStyle(1.5, 0x7e2432, 1);
    this.clothesLayer.beginPath();
    this.clothesLayer.moveTo(shoulder.x + nx * 5, shoulder.y + ny * 5);
    this.clothesLayer.lineTo(shoulder.x - nx * 5, shoulder.y - ny * 5);
    this.clothesLayer.lineTo(sleeveEnd.x - nx * 4, sleeveEnd.y - ny * 4);
    this.clothesLayer.lineTo(sleeveEnd.x + nx * 4, sleeveEnd.y + ny * 4);
    this.clothesLayer.closePath();
    this.clothesLayer.fillPath();
    this.clothesLayer.strokePath();
  }

  private drawShortLeg(x: number, y: number, leg: Limb) {
    const dx = leg.joint.x - leg.start.x;
    const dy = leg.joint.y - leg.start.y;
    const length = Math.sqrt(dx * dx + dy * dy) || 1;
    const ux = dx / length;
    const uy = dy / length;
    const nx = -uy;
    const ny = ux;
    const halfWidth = 5;
    const lengthPx = 12;

    this.clothesLayer.fillStyle(0x252a37, 1);
    this.clothesLayer.beginPath();
    this.clothesLayer.moveTo(x + nx * halfWidth, y + ny * halfWidth);
    this.clothesLayer.lineTo(x - nx * halfWidth, y - ny * halfWidth);
    this.clothesLayer.lineTo(x + ux * lengthPx - nx * 4, y + uy * lengthPx - ny * 4);
    this.clothesLayer.lineTo(x + ux * lengthPx + nx * 4, y + uy * lengthPx + ny * 4);
    this.clothesLayer.closePath();
    this.clothesLayer.fillPath();
  }

  private drawShoe(foot: Point, alpha: number) {
    this.clothesLayer.fillStyle(0xf5f1e8, alpha);
    this.clothesLayer.lineStyle(1.2, 0x171923, alpha);
    this.clothesLayer.fillRoundedRect(foot.x - 6, foot.y - 3, 15, 6, 3);
    this.clothesLayer.strokeRoundedRect(foot.x - 6, foot.y - 3, 15, 6, 3);
  }

  private drawArms(pose: Pose) {
    this.armsLayer.clear();
    this.drawLimb(this.armsLayer, pose.rightArm, 3.5, 0.78);
    this.drawLimb(this.armsLayer, pose.leftArm, 3.5, 1);
    this.armsLayer.fillStyle(0x171923, 0.78);
    this.armsLayer.fillCircle(pose.rightArm.end.x, pose.rightArm.end.y, 2.8);
    this.armsLayer.fillStyle(0x171923, 1);
    this.armsLayer.fillCircle(pose.leftArm.end.x, pose.leftArm.end.y, 2.8);
  }

  private drawFace(pose: Pose) {
    this.faceLayer.clear();
    this.faceLayer.fillStyle(0xf5e9d7, 1);
    this.faceLayer.lineStyle(2.5, 0x171923, 1);
    this.faceLayer.fillCircle(pose.head.x, pose.head.y, 12);
    this.faceLayer.strokeCircle(pose.head.x, pose.head.y, 12);

    this.faceLayer.fillStyle(0x171923, 1);
    this.faceLayer.fillCircle(pose.head.x + 4, pose.head.y - 1, 1.5);

    this.faceLayer.fillStyle(0xdf4052, 1);
    this.faceLayer.beginPath();
    this.faceLayer.arc(pose.head.x, pose.head.y - 5, 10, Math.PI, Math.PI * 2);
    this.faceLayer.fillPath();
    this.faceLayer.fillRect(pose.head.x + 2, pose.head.y - 7, 12, 3);
  }

  private drawLimb(graphics: Phaser.GameObjects.Graphics, limb: Limb, width: number, alpha: number) {
    graphics.lineStyle(width, 0x171923, alpha);
    graphics.lineBetween(limb.start.x, limb.start.y, limb.joint.x, limb.joint.y);
    graphics.lineBetween(limb.joint.x, limb.joint.y, limb.end.x, limb.end.y);
    graphics.fillStyle(0x171923, alpha);
    graphics.fillCircle(limb.joint.x, limb.joint.y, 2.5);
  }

  private createDeathPieces() {
    this.clearDeathPieces();

    this.addDeathPiece('head', 0, -99, 1.05);
    this.addDeathPiece('shirt', 0, -65, 0.85);
    this.addDeathPiece('shorts', 0, -43, 0.9);
    this.addDeathPiece('arm', -12, -68, 1);
    this.addDeathPiece('arm', 12, -68, 1);
    this.addDeathPiece('leg', -7, -31, 1);
    this.addDeathPiece('leg', 7, -31, 1);
    this.addDeathPiece('leg', -10, -13, 1);
    this.addDeathPiece('leg', 10, -13, 1);
    this.addDeathPiece('shoe', -10, -2, 1);
    this.addDeathPiece('shoe', 10, -2, 1);
  }

  private addDeathPiece(type: 'head' | 'shirt' | 'shorts' | 'arm' | 'leg' | 'shoe', x: number, y: number, speed: number) {
    const graphic = this.scene.add.graphics();
    this.drawDeathPieceGraphic(graphic, type);
    graphic.setPosition(x, y);
    this.deathLayer.add(graphic);

    const horizontal = Phaser.Math.FloatBetween(-250, 250) + 55;
    this.deathPieces.push({
      graphic,
      vx: horizontal * speed,
      vy: Phaser.Math.FloatBetween(-430, -220) * speed,
      rotationSpeed: Phaser.Math.FloatBetween(-9, 9),
      age: 0,
    });
  }

  private drawDeathPieceGraphic(graphic: Phaser.GameObjects.Graphics, type: 'head' | 'shirt' | 'shorts' | 'arm' | 'leg' | 'shoe') {
    if (type === 'head') {
      graphic.fillStyle(0xf5e9d7, 1);
      graphic.lineStyle(2, 0x171923, 1);
      graphic.fillCircle(0, 0, 12);
      graphic.strokeCircle(0, 0, 12);
      graphic.fillStyle(0xdf4052, 1);
      graphic.fillRect(-9, -11, 18, 4);
      return;
    }

    if (type === 'shirt') {
      graphic.fillStyle(0xdf4052, 1);
      graphic.lineStyle(1.5, 0x7e2432, 1);
      graphic.fillRoundedRect(-12, -12, 24, 24, 4);
      graphic.strokeRoundedRect(-12, -12, 24, 24, 4);
      return;
    }

    if (type === 'shorts') {
      graphic.fillStyle(0x252a37, 1);
      graphic.fillRoundedRect(-11, -6, 22, 12, 3);
      return;
    }

    if (type === 'shoe') {
      graphic.fillStyle(0xf5f1e8, 1);
      graphic.lineStyle(1.2, 0x171923, 1);
      graphic.fillRoundedRect(-7, -3, 15, 6, 3);
      graphic.strokeRoundedRect(-7, -3, 15, 6, 3);
      return;
    }

    graphic.lineStyle(type === 'arm' ? 4 : 4.5, 0x171923, 1);
    graphic.lineBetween(0, -13, 0, 13);
    graphic.fillStyle(0x171923, 1);
    graphic.fillCircle(0, -13, 2.2);
    graphic.fillCircle(0, 13, 2.2);
  }

  private updateDeath(delta: number) {
    const dt = delta / 1000;
    for (const piece of this.deathPieces) {
      piece.age += delta;
      piece.vy += DEATH_GRAVITY * dt;
      piece.graphic.x += piece.vx * dt;
      piece.graphic.y += piece.vy * dt;
      piece.graphic.rotation += piece.rotationSpeed * dt;
      if (piece.age > DEATH_FADE_START_MS) {
        piece.graphic.alpha = Phaser.Math.Clamp(1 - (piece.age - DEATH_FADE_START_MS) / 260, 0, 1);
      }
    }
  }

  private clearDeathPieces() {
    for (const piece of this.deathPieces) piece.graphic.destroy();
    this.deathPieces.length = 0;
    this.deathLayer.removeAll(false);
  }
}
