// Fishana World - Ocean environment with pearls and boss fish

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export function buildFishanaWorld(scene) {
  // Ocean floor
  const floorGeom = new THREE.PlaneGeometry(100, 100);
  const floorMat = new THREE.MeshStandardMaterial({
    color: 0x1a6a7a,
    roughness: 0.8,
    metalness: 0
  });
  const floor = new THREE.Mesh(floorGeom, floorMat);
  floor.rotation.x = -Math.PI / 2;
  floor.receiveShadow = true;
  floor.position.y = -2;
  scene.add(floor);

  // Ocean fog
  scene.fog = new THREE.Fog(0x0a3a4a, 40, 120);

  // Water caustic overlay (animated)
  const causticsGeom = new THREE.PlaneGeometry(100, 100);
  const causticsMat = new THREE.MeshStandardMaterial({
    color: 0x1a7a8a,
    emissive: 0x0a4a5a,
    transparent: true,
    opacity: 0.3,
    roughness: 0.6
  });
  const caustics = new THREE.Mesh(causticsGeom, causticsMat);
  caustics.rotation.x = -Math.PI / 2;
  caustics.position.y = -1.8;
  scene.add(caustics);

  // Pearls scattered around (collectibles)
  const pearlPositions = [];
  for (let i = 0; i < 15; i++) {
    pearlPositions.push({
      x: (Math.random() - 0.5) * 50,
      y: (Math.random() - 0.5) * 10 - 5,
      z: (Math.random() - 0.5) * 50,
      angle: 0
    });
  }

  pearlPositions.forEach((pos, idx) => {
    const pearlGeom = new THREE.SphereGeometry(0.4, 16, 16);
    const pearlMat = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      emissive: 0xffff99,
      metalness: 0.9,
      roughness: 0.1
    });
    const pearl = new THREE.Mesh(pearlGeom, pearlMat);
    pearl.position.set(pos.x, pos.y, pos.z);
    pearl.castShadow = true;
    pearl.receiveShadow = true;
    pearl.idx = idx;
    pearl.bobTime = Math.random() * Math.PI * 2;
    scene.add(pearl);
  });

  // Boss fish (larger procedural fish)
  const bossGroup = new THREE.Group();
  const bodyGeom = new THREE.SphereGeometry(2, 16, 16);
  const bodyMat = new THREE.MeshStandardMaterial({
    color: 0xff6b9d,
    metalness: 0.6,
    roughness: 0.4
  });
  const body = new THREE.Mesh(bodyGeom, bodyMat);
  body.scale.set(1, 0.6, 0.4);
  body.castShadow = true;
  bossGroup.add(body);

  // Fins
  const finGeom = new THREE.ConeGeometry(0.8, 2, 8);
  const finMat = new THREE.MeshStandardMaterial({ color: 0xff4466 });
  const dorsal = new THREE.Mesh(finGeom, finMat);
  dorsal.position.y = 1.5;
  dorsal.scale.set(1, 0.5, 0.3);
  dorsal.castShadow = true;
  bossGroup.add(dorsal);

  // Tail
  const tailGeom = new THREE.SphereGeometry(0.5, 8, 8);
  const tail = new THREE.Mesh(tailGeom, bodyMat);
  tail.position.z = -2;
  tail.scale.set(1.5, 1, 0.3);
  tail.castShadow = true;
  bossGroup.add(tail);

  bossGroup.position.set(0, 0, 0);
  scene.add(bossGroup);

  // Bubbles (particle system)
  const bubblePositions = [];
  for (let i = 0; i < 20; i++) {
    bubblePositions.push({
      x: (Math.random() - 0.5) * 60,
      y: -20,
      z: (Math.random() - 0.5) * 60,
      speed: Math.random() * 2 + 1
    });
  }

  const bubbleGeom = new THREE.SphereGeometry(0.15, 8, 8);
  const bubbleMat = new THREE.MeshStandardMaterial({
    color: 0x99ccff,
    transparent: true,
    opacity: 0.4,
    metalness: 0.8
  });

  bubblePositions.forEach(pos => {
    const bubble = new THREE.Mesh(bubbleGeom, bubbleMat);
    bubble.position.set(pos.x, pos.y, pos.z);
    bubble.bubbleData = pos;
    scene.add(bubble);
  });

  return {
    pearls: pearlPositions,
    boss: bossGroup,
    bubbles: bubblePositions,
    onUpdate: (dt) => {
      // Animate pearls
      scene.children.forEach(child => {
        if (child.bobTime !== undefined) {
          child.position.y += Math.sin(child.bobTime) * 0.3 * dt;
          child.bobTime += dt * 2;
        }
        if (child.bubbleData) {
          child.position.y += child.bubbleData.speed * dt;
          if (child.position.y > 30) {
            child.position.y = -20;
            child.position.x = (Math.random() - 0.5) * 60;
            child.position.z = (Math.random() - 0.5) * 60;
          }
        }
      });

      // Animate boss fish
      bossGroup.rotation.y += dt * 0.5;
      bossGroup.position.y = Math.sin(bossGroup.rotation.y) * 2;
    }
  };
}
