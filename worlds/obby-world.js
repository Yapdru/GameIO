// Obby World - Parkour obstacle course

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export function buildObbyWorld(scene) {
  // Sky background
  scene.background = new THREE.Color(0x87ceeb);
  scene.fog = new THREE.Fog(0x87ceeb, 100, 300);

  // Starting platform
  const platformGeom = new THREE.BoxGeometry(20, 1, 20);
  const platformMat = new THREE.MeshStandardMaterial({
    color: 0x90ee90,
    roughness: 0.5
  });
  const startPlatform = new THREE.Mesh(platformGeom, platformMat);
  startPlatform.position.y = 0;
  startPlatform.castShadow = true;
  startPlatform.receiveShadow = true;
  scene.add(startPlatform);

  // Series of progressively harder platforms
  const platforms = [];
  let x = 15;
  let y = 5;

  for (let i = 0; i < 15; i++) {
    const width = Math.max(3, 8 - i * 0.5);
    const gap = 3 + i * 0.5;

    const pGeom = new THREE.BoxGeometry(width, 1, 5);
    const pMat = new THREE.MeshStandardMaterial({
      color: i % 2 === 0 ? 0x87ceeb : 0x4287f5,
      roughness: 0.4
    });
    const platform = new THREE.Mesh(pGeom, pMat);
    platform.position.set(x, y, 0);
    platform.castShadow = true;
    platform.receiveShadow = true;
    scene.add(platform);
    platforms.push(platform);

    x += width + gap;
    y += 3 + i * 0.3;
  }

  // Final platform (finish line)
  const finishGeom = new THREE.BoxGeometry(15, 1, 15);
  const finishMat = new THREE.MeshStandardMaterial({
    color: 0xffd84d,
    emissive: 0xffa500,
    metalness: 0.7
  });
  const finishPlatform = new THREE.Mesh(finishGeom, finishMat);
  finishPlatform.position.set(x, y, 0);
  finishPlatform.castShadow = true;
  finishPlatform.receiveShadow = true;
  scene.add(finishPlatform);

  // Moving obstacles
  const obstacles = [];
  const obstacleGeom = new THREE.BoxGeometry(2, 2, 2);
  const obstacleMat = new THREE.MeshStandardMaterial({
    color: 0xff6b6b,
    emissive: 0xff0000,
    metalness: 0.5
  });

  for (let i = 0; i < 4; i++) {
    const obstacle = new THREE.Mesh(obstacleGeom, obstacleMat);
    obstacle.position.set(20 + i * 15, 10 + i * 3, 0);
    obstacle.castShadow = true;
    obstacle.minY = obstacle.position.y - 3;
    obstacle.maxY = obstacle.position.y + 3;
    obstacle.vx = (i % 2 === 0 ? 1 : -1) * (2 + i * 0.5);
    obstacle.minX = obstacle.position.x - 5;
    obstacle.maxX = obstacle.position.x + 5;
    scene.add(obstacle);
    obstacles.push(obstacle);
  }

  // Checkpoints (golden rings)
  const checkpoints = [];
  for (let i = 0; i < 4; i++) {
    const cpGeom = new THREE.TorusGeometry(3, 0.4, 16, 32);
    const cpMat = new THREE.MeshStandardMaterial({
      color: 0xffd84d,
      emissive: 0xffa500,
      metalness: 0.9
    });
    const checkpoint = new THREE.Mesh(cpGeom, cpMat);
    checkpoint.rotation.x = -Math.PI / 2;
    checkpoint.position.set(10 + i * 20, 5 + i * 5, 0);
    scene.add(checkpoint);
    checkpoints.push(checkpoint);
  }

  // Side walls for safety
  const wallGeom = new THREE.BoxGeometry(2, 50, 200);
  const wallMat = new THREE.MeshStandardMaterial({ color: 0x888888 });
  const leftWall = new THREE.Mesh(wallGeom, wallMat);
  leftWall.position.set(-30, 25, 0);
  scene.add(leftWall);

  const rightWall = new THREE.Mesh(wallGeom, wallMat);
  rightWall.position.set(x + 30, 25, 0);
  scene.add(rightWall);

  return {
    platforms,
    obstacles,
    checkpoints,
    onUpdate: (dt) => {
      // Move obstacles
      obstacles.forEach(obs => {
        obs.position.x += obs.vx * dt;
        if (obs.position.x < obs.minX) obs.vx = -obs.vx;
        if (obs.position.x > obs.maxX) obs.vx = -obs.vx;
      });

      // Pulse checkpoints
      checkpoints.forEach((cp, idx) => {
        const pulse = Math.sin(idx + performance.now() * 0.002) * 0.2 + 1;
        cp.scale.set(pulse, 1, pulse);
      });
    }
  };
}
