// Cars World - Racing track environment

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export function buildCarsWorld(scene) {
  // Ground/terrain
  const groundGeom = new THREE.PlaneGeometry(100, 100);
  const groundMat = new THREE.MeshStandardMaterial({
    color: 0x3a7a3a,
    roughness: 0.7
  });
  const ground = new THREE.Mesh(groundGeom, groundMat);
  ground.rotation.x = -Math.PI / 2;
  ground.position.y = 0;
  ground.receiveShadow = true;
  scene.add(ground);

  // Race track (asphalt oval)
  const trackOuter = new THREE.TorusGeometry(25, 10, 2, 64);
  const trackMat = new THREE.MeshStandardMaterial({
    color: 0x1a1a1a,
    roughness: 0.8,
    metalness: 0.1
  });
  const track = new THREE.Mesh(trackOuter, trackMat);
  track.rotation.x = -Math.PI / 2;
  track.position.y = 0.1;
  track.receiveShadow = true;
  scene.add(track);

  // Track markings (white lines - center)
  const lineGeom = new THREE.TorusGeometry(20, 0.3, 2, 128);
  const lineMat = new THREE.MeshStandardMaterial({
    color: 0xffffff,
    emissive: 0xffff99
  });
  const centerLine = new THREE.Mesh(lineGeom, lineMat);
  centerLine.rotation.x = -Math.PI / 2;
  centerLine.position.y = 0.2;
  scene.add(centerLine);

  // Guard rails
  const railGeom = new THREE.BoxGeometry(2, 1, 70);
  const railMat = new THREE.MeshStandardMaterial({
    color: 0xff6b6b,
    metalness: 0.6,
    roughness: 0.3
  });

  // Right rail
  const rightRail = new THREE.Mesh(railGeom, railMat);
  rightRail.position.set(37, 0.5, 0);
  rightRail.castShadow = true;
  rightRail.receiveShadow = true;
  scene.add(rightRail);

  // Left rail
  const leftRail = new THREE.Mesh(railGeom, railMat);
  leftRail.position.set(-37, 0.5, 0);
  leftRail.castShadow = true;
  leftRail.receiveShadow = true;
  scene.add(leftRail);

  // Checkpoints (glowing rings)
  const checkpoints = [];
  for (let i = 0; i < 4; i++) {
    const angle = (i / 4) * Math.PI * 2;
    const cpGeom = new THREE.TorusGeometry(3, 0.3, 16, 32);
    const cpMat = new THREE.MeshStandardMaterial({
      color: 0xffd84d,
      emissive: 0xffa500,
      metalness: 0.9
    });
    const checkpoint = new THREE.Mesh(cpGeom, cpMat);
    checkpoint.rotation.x = -Math.PI / 2;
    checkpoint.position.set(
      Math.cos(angle) * 22,
      0.2,
      Math.sin(angle) * 22
    );
    scene.add(checkpoint);
    checkpoints.push(checkpoint);
  }

  // Skyline (buildings)
  const skylineColors = [0x4287f5, 0x0f8fe8, 0x3dd5f3];
  for (let i = 0; i < 12; i++) {
    const angle = (i / 12) * Math.PI * 2;
    const x = Math.cos(angle) * 45;
    const z = Math.sin(angle) * 45;

    const buildingGeom = new THREE.BoxGeometry(6, 12, 4);
    const buildingMat = new THREE.MeshStandardMaterial({
      color: skylineColors[i % 3],
      roughness: 0.6
    });
    const building = new THREE.Mesh(buildingGeom, buildingMat);
    building.position.set(x, 6, z);
    building.castShadow = true;
    building.receiveShadow = true;
    scene.add(building);
  }

  return {
    checkpoints: checkpoints,
    onUpdate: (dt) => {
      // Pulse checkpoint glow
      checkpoints.forEach((cp, idx) => {
        const pulse = Math.sin(idx + performance.now() * 0.002) * 0.3 + 1;
        cp.children.forEach(child => {
          if (child.material) {
            child.material.emissiveIntensity = pulse;
          }
        });
      });
    }
  };
}
