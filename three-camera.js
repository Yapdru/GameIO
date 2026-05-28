// Camera System - Context-aware smooth camera with multiple modes

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export class CameraManager {
  constructor(camera) {
    this.camera = camera;
    this.mode = 'chase'; // chase, firstPerson, drone
    this.targetPos = new THREE.Vector3();
    this.targetLookAt = new THREE.Vector3();
    this.currentPos = camera.position.clone();
    this.currentLookAt = new THREE.Vector3(0, 0, 0);

    // Smoothing
    this.easeConstant = 0.25; // exponential decay time constant
    this.swayTime = 0;
  }

  update(dt, playerPos, playerVelocity, lookTarget = null) {
    this.swayTime += dt;

    switch (this.mode) {
      case 'chase':
        this.updateChaseView(dt, playerPos, playerVelocity);
        break;
      case 'firstPerson':
        this.updateFirstPerson(dt, playerPos);
        break;
      case 'drone':
        this.updateDroneView(dt, playerPos);
        break;
    }

    // Apply smoothing (exponential decay)
    const k = Math.exp(-dt / this.easeConstant);
    this.camera.position.lerp(this.targetPos, 1 - k);
    this.currentLookAt.lerp(this.targetLookAt, 1 - k);
    this.camera.lookAt(this.currentLookAt);
  }

  updateChaseView(dt, playerPos, playerVelocity) {
    // Calculate look-ahead based on velocity
    const lookAheadDist = 3;
    const lookAhead = new THREE.Vector3();
    if (playerVelocity.length() > 0.1) {
      lookAhead.copy(playerVelocity).normalize().multiplyScalar(lookAheadDist);
    }

    // Target look-at point (slightly ahead of player)
    this.targetLookAt.copy(playerPos).add(lookAhead);
    this.targetLookAt.y = playerPos.y + 1.5;

    // Camera position - behind and above player
    const chaseDist = 8;
    const chaseHeight = 3;
    const chaseDir = new THREE.Vector3(0, 0, 1);

    if (playerVelocity.length() > 0.1) {
      chaseDir.copy(playerVelocity).normalize();
    }

    // Add subtle sway for cinematic feel
    const sway = Math.sin(this.swayTime * 1.5) * 0.5;
    this.targetPos.copy(playerPos);
    this.targetPos.addScaledVector(chaseDir, -chaseDist);
    this.targetPos.y = playerPos.y + chaseHeight;
    this.targetPos.x += sway;
  }

  updateFirstPerson(dt, playerPos) {
    // Camera at avatar head level
    this.targetPos.copy(playerPos);
    this.targetPos.y += 0.6;

    // Look slightly downward
    this.targetLookAt.copy(playerPos);
    this.targetLookAt.y += 0.4;
    this.targetLookAt.z += 5;
  }

  updateDroneView(dt, playerPos) {
    // Bird's-eye view for multiplayer clarity
    this.targetPos.copy(playerPos);
    this.targetPos.y = 20;
    this.targetPos.z -= 8;

    this.targetLookAt.copy(playerPos);
    this.targetLookAt.y = 5;
  }

  setMode(mode) {
    if (['chase', 'firstPerson', 'drone'].includes(mode)) {
      this.mode = mode;
    }
  }

  cycleMode() {
    const modes = ['chase', 'firstPerson', 'drone'];
    const currentIdx = modes.indexOf(this.mode);
    this.mode = modes[(currentIdx + 1) % modes.length];
  }
}
