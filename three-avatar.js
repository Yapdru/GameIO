// Enhanced Avatar System - Roblox/Nintendo style 3D avatars

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export class Avatar {
  constructor(face = '😎', body = '🧥', accessory = '⚡') {
    this.group = new THREE.Group();
    this.face = face;
    this.body = body;
    this.accessory = accessory;

    // Animation state
    this.animState = 'idle';
    this.animTime = 0;
    this.animBlend = 0;
    this.targetAnimState = 'idle';

    // Emoji color mapping
    this.faceColor = this.emojiToColor(face);
    this.bodyColor = this.emojiToColor(body);
    this.accColor = this.emojiToColor(accessory);

    this.buildGeometry();
    this.setupAnimations();

    // Physics
    this.velocity = new THREE.Vector3(0, 0, 0);
    this.position = new THREE.Vector3(0, 0, 0);
    this.direction = new THREE.Vector3(0, 0, 1);
  }

  emojiToColor(emoji) {
    // Map emojis to colors for avatar parts
    const colorMap = {
      '😎': 0xffdbac, '🐟': 0xff6b6b, '🏎️': 0xff8c00,
      '🚙': 0x4287f5, '🤖': 0x888888, '🧑‍🚀': 0xffffcc,
      '🦖': 0x90ee90, '🦸': 0xff1493, '🐱': 0xffb347, '🐼': 0x000000,
      '🧊': 0x87ceeb, '🧥': 0x4287f5, '🦺': 0xffaa00, '🛡️': 0xc0c0c0,
      '🎽': 0xff6b9d, '🚀': 0xff6b6b, '🏁': 0xffffff, '🧍': 0xffdbac,
      '⚡': 0xffff00, '👑': 0xffd700, '🎧': 0x333333, '💎': 0x00ffff,
      '🔥': 0xff4444, '⭐': 0xffd84d, '🏆': 0xffd700, '🪽': 0x4287f5
    };
    return colorMap[emoji] || 0x4287f5;
  }

  buildGeometry() {
    // Head
    const headGeom = new THREE.SphereGeometry(0.35, 16, 16);
    const headMat = new THREE.MeshStandardMaterial({
      color: this.faceColor,
      roughness: 0.4,
      metalness: 0.1
    });
    this.head = new THREE.Mesh(headGeom, headMat);
    this.head.position.y = 0.7;
    this.head.castShadow = true;
    this.head.receiveShadow = true;
    this.group.add(this.head);

    // Eyes
    const eyeGeom = new THREE.SphereGeometry(0.08, 8, 8);
    const eyeMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
    this.leftEye = new THREE.Mesh(eyeGeom, eyeMat);
    this.leftEye.position.set(-0.1, 0.75, 0.3);
    this.group.add(this.leftEye);

    this.rightEye = new THREE.Mesh(eyeGeom, eyeMat);
    this.rightEye.position.set(0.1, 0.75, 0.3);
    this.group.add(this.rightEye);

    // Torso (capsule)
    const torsoGeom = new THREE.CapsuleGeometry(0.22, 0.7, 8, 8);
    const torsoMat = new THREE.MeshStandardMaterial({
      color: this.bodyColor,
      roughness: 0.3,
      metalness: 0.1
    });
    this.torso = new THREE.Mesh(torsoGeom, torsoMat);
    this.torso.position.y = 0.2;
    this.torso.castShadow = true;
    this.torso.receiveShadow = true;
    this.group.add(this.torso);

    // Arms
    const armGeom = new THREE.CapsuleGeometry(0.1, 0.6, 8, 8);
    const armMat = new THREE.MeshStandardMaterial({
      color: this.faceColor,
      roughness: 0.4
    });

    this.leftArm = new THREE.Mesh(armGeom, armMat);
    this.leftArm.position.set(-0.35, 0.35, 0);
    this.leftArm.castShadow = true;
    this.group.add(this.leftArm);

    this.rightArm = new THREE.Mesh(armGeom, armMat);
    this.rightArm.position.set(0.35, 0.35, 0);
    this.rightArm.castShadow = true;
    this.group.add(this.rightArm);

    // Legs
    const legGeom = new THREE.CapsuleGeometry(0.12, 0.6, 8, 8);
    const legMat = new THREE.MeshStandardMaterial({
      color: 0x333333,
      roughness: 0.5
    });

    this.leftLeg = new THREE.Mesh(legGeom, legMat);
    this.leftLeg.position.set(-0.15, -0.35, 0);
    this.leftLeg.castShadow = true;
    this.group.add(this.leftLeg);

    this.rightLeg = new THREE.Mesh(legGeom, legMat);
    this.rightLeg.position.set(0.15, -0.35, 0);
    this.rightLeg.castShadow = true;
    this.group.add(this.rightLeg);

    // Shoes
    const shoeGeom = new THREE.BoxGeometry(0.15, 0.15, 0.25);
    const shoeMat = new THREE.MeshStandardMaterial({ color: 0x1a1a1a });

    this.leftShoe = new THREE.Mesh(shoeGeom, shoeMat);
    this.leftShoe.position.set(-0.15, -0.68, 0);
    this.leftShoe.castShadow = true;
    this.group.add(this.leftShoe);

    this.rightShoe = new THREE.Mesh(shoeGeom, shoeMat);
    this.rightShoe.position.set(0.15, -0.68, 0);
    this.rightShoe.castShadow = true;
    this.group.add(this.rightShoe);

    // Shadow
    const shadowGeom = new THREE.PlaneGeometry(0.6, 0.3);
    const shadowMat = new THREE.MeshStandardMaterial({
      color: 0x000000,
      transparent: true,
      opacity: 0.3
    });
    const shadow = new THREE.Mesh(shadowGeom, shadowMat);
    shadow.rotation.x = -Math.PI / 2;
    shadow.position.y = 0.01;
    this.group.add(shadow);
  }

  setupAnimations() {
    this.animations = {
      idle: {
        headBob: (t) => Math.sin(t * 2) * 0.08,
        sway: (t) => Math.sin(t * 1.5) * 0.1,
        eyeBlink: (t) => Math.sin(t * 3) > 0.9 ? 0 : 1
      },
      walk: {
        legSwing: (t) => Math.sin(t * 4) * 0.4,
        armSwing: (t) => Math.sin(t * 4 + Math.PI) * 0.4,
        headBob: (t) => Math.sin(t * 4) * 0.1 + 0.7,
        torsoRotate: (t) => Math.sin(t * 4) * 0.15
      },
      jump: {
        yOffset: (t) => {
          const progress = t / 0.6;
          if (progress > 1) return 0;
          return Math.sin(progress * Math.PI) * 1.2;
        }
      },
      dance: {
        rotate: (t) => Math.sin(t * 3) * 0.3,
        bounce: (t) => Math.sin(t * 5) * 0.2,
        armRotate: (t) => Math.sin(t * 4 + Math.PI / 2) * 0.6
      }
    };
  }

  setAnimationState(state) {
    this.targetAnimState = state;
    this.animTime = 0;
  }

  update(dt) {
    this.animTime += dt;

    // Blend between animations
    if (this.animState !== this.targetAnimState) {
      this.animBlend += dt * 2;
      if (this.animBlend >= 1) {
        this.animState = this.targetAnimState;
        this.animBlend = 0;
        this.animTime = 0;
      }
    }

    const anims = this.animations;
    const t = this.animTime;

    // Apply idle animation
    if (this.animState === 'idle' || this.animBlend > 0) {
      const headBob = anims.idle.headBob(t);
      this.head.position.y = 0.7 + headBob;
      this.group.rotation.z = anims.idle.sway(t) * this.animBlend;
    }

    // Apply walk animation
    if (this.animState === 'walk') {
      const legSwing = anims.walk.legSwing(t);
      const armSwing = anims.walk.armSwing(t);

      this.leftLeg.rotation.x = legSwing;
      this.rightLeg.rotation.x = -legSwing;
      this.leftArm.rotation.x = armSwing;
      this.rightArm.rotation.x = -armSwing;

      this.head.position.y = 0.7 + anims.walk.headBob(t);
      this.torso.rotation.z = anims.walk.torsoRotate(t);
    }

    // Apply jump animation
    if (this.animState === 'jump') {
      const yOffset = anims.jump.yOffset(t);
      this.group.position.y = this.position.y + yOffset;

      if (t > 0.6) {
        this.animState = 'idle';
        this.animTime = 0;
      }
    }

    // Apply dance animation
    if (this.animState === 'dance') {
      this.group.rotation.y = anims.dance.rotate(t);
      this.group.position.y = this.position.y + anims.dance.bounce(t);
      this.leftArm.rotation.z = anims.dance.armRotate(t);
      this.rightArm.rotation.z = -anims.dance.armRotate(t);
    }
  }

  emote(type) {
    switch (type) {
      case 'jump':
        this.setAnimationState('jump');
        break;
      case 'dance':
        this.setAnimationState('dance');
        break;
      case 'wave':
        this.rightArm.rotation.z = Math.PI / 2;
        setTimeout(() => {
          this.rightArm.rotation.z = 0;
        }, 600);
        break;
    }
  }

  setVelocity(vx, vz) {
    const speed = Math.sqrt(vx * vx + vz * vz);
    if (speed > 0.1) {
      this.setAnimationState('walk');
      this.direction.set(vx, 0, vz).normalize();
      this.group.rotation.y = Math.atan2(vx, vz);
    } else {
      this.setAnimationState('idle');
    }
  }

  setPosition(x, y, z) {
    this.position.set(x, y, z);
    this.group.position.copy(this.position);
  }
}
