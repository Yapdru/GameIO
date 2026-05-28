// Space World - Zero-gravity asteroid field

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export function buildSpaceWorld(scene) {
  // Dark space background
  scene.background = new THREE.Color(0x000814);
  scene.fog = new THREE.Fog(0x000814, 100, 300);

  // Star field background
  const starsGeom = new THREE.BufferGeometry();
  const starCount = 100;
  const positions = new Float32Array(starCount * 3);

  for (let i = 0; i < starCount; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 200;
    positions[i * 3 + 1] = (Math.random() - 0.5) * 200;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 200;
  }

  starsGeom.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  const starsMat = new THREE.PointsMaterial({ color: 0xffffff, size: 0.2 });
  const stars = new THREE.Points(starsGeom, starsMat);
  scene.add(stars);

  // Asteroids (procedurally generated)
  const asteroids = [];
  for (let i = 0; i < 8; i++) {
    const asteroidGroup = new THREE.Group();

    // Main body
    const bodyGeom = new THREE.DodecahedronGeometry(2, 0);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: 0x8b7355,
      roughness: 0.8,
      metalness: 0.2
    });
    const body = new THREE.Mesh(bodyGeom, bodyMat);
    body.castShadow = true;
    body.receiveShadow = true;
    asteroidGroup.add(body);

    // Random position
    const angle = (i / 8) * Math.PI * 2;
    const distance = 30 + Math.random() * 20;
    asteroidGroup.position.set(
      Math.cos(angle) * distance,
      (Math.random() - 0.5) * 20,
      Math.sin(angle) * distance
    );

    // Random rotation
    asteroidGroup.rotation.x = Math.random() * Math.PI * 2;
    asteroidGroup.rotation.y = Math.random() * Math.PI * 2;
    asteroidGroup.rotation.z = Math.random() * Math.PI * 2;

    asteroidGroup.rotationSpeed = {
      x: (Math.random() - 0.5) * 0.5,
      y: (Math.random() - 0.5) * 0.5,
      z: (Math.random() - 0.5) * 0.5
    };

    scene.add(asteroidGroup);
    asteroids.push(asteroidGroup);
  }

  // Collectible stars (glowing spheres)
  const collectibles = [];
  for (let i = 0; i < 6; i++) {
    const starGeom = new THREE.SphereGeometry(0.8, 16, 16);
    const starMat = new THREE.MeshStandardMaterial({
      color: 0xffff00,
      emissive: 0xffff00,
      metalness: 0.9,
      roughness: 0.1
    });
    const star = new THREE.Mesh(starGeom, starMat);
    star.position.set(
      (Math.random() - 0.5) * 50,
      (Math.random() - 0.5) * 50,
      (Math.random() - 0.5) * 50
    );
    star.castShadow = true;
    scene.add(star);
    collectibles.push(star);
  }

  // Danger asteroids (red)
  const dangers = [];
  for (let i = 0; i < 12; i++) {
    const dangerGeom = new THREE.IcosahedronGeometry(1.5, 0);
    const dangerMat = new THREE.MeshStandardMaterial({
      color: 0xff4444,
      emissive: 0xff0000,
      metalness: 0.7,
      roughness: 0.3
    });
    const danger = new THREE.Mesh(dangerGeom, dangerMat);
    danger.position.set(
      (Math.random() - 0.5) * 60,
      (Math.random() - 0.5) * 40,
      (Math.random() - 0.5) * 60
    );
    danger.castShadow = true;
    danger.rotationSpeed = {
      x: (Math.random() - 0.5) * 1,
      y: (Math.random() - 0.5) * 1,
      z: (Math.random() - 0.5) * 1
    };
    scene.add(danger);
    dangers.push(danger);
  }

  return {
    asteroids,
    collectibles,
    dangers,
    onUpdate: (dt) => {
      // Rotate asteroids
      asteroids.forEach(ast => {
        ast.rotation.x += ast.rotationSpeed.x * dt;
        ast.rotation.y += ast.rotationSpeed.y * dt;
        ast.rotation.z += ast.rotationSpeed.z * dt;
      });

      // Pulse collectibles
      collectibles.forEach(star => {
        const scale = 1 + Math.sin(performance.now() * 0.003) * 0.2;
        star.scale.set(scale, scale, scale);
      });

      // Rotate danger asteroids
      dangers.forEach(danger => {
        danger.rotation.x += danger.rotationSpeed.x * dt;
        danger.rotation.y += danger.rotationSpeed.y * dt;
        danger.rotation.z += danger.rotationSpeed.z * dt;
      });
    }
  };
}
