// 3D Lobby using Three.js
// Players can walk around and see each other before playing games

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';
import { gameState } from './state.js';

export class ThreeLobby {
  constructor(canvas) {
    this.canvas = canvas;
    this.width = canvas.clientWidth;
    this.height = canvas.clientHeight;

    // Scene setup
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0xb3d9ff);
    this.scene.fog = new THREE.Fog(0xb3d9ff, 40, 100);

    // Camera
    this.camera = new THREE.PerspectiveCamera(70, this.width / this.height, 0.1, 1000);
    this.camera.position.set(0, 2, 5);

    // Renderer
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setSize(this.width, this.height);
    this.renderer.setPixelRatio(window.devicePixelRatio || 1);
    this.renderer.shadowMap.enabled = true;

    // Lighting
    const hemisLight = new THREE.HemisphereLight(0x87ceeb, 0x1a5f7a, 0.7);
    this.scene.add(hemisLight);

    const sunLight = new THREE.DirectionalLight(0xffd700, 0.8);
    sunLight.position.set(20, 20, 20);
    sunLight.castShadow = true;
    sunLight.shadow.mapSize.width = 512;
    sunLight.shadow.mapSize.height = 512;
    this.scene.add(sunLight);

    // Build lobby scene
    this.buildScene();

    // Game state
    this.playerAvatar = null;
    this.remoteAvatars = {};
    this.input = { left: false, right: false, forward: false, backward: false };
    this.playerPos = new THREE.Vector3(0, 0, 0);
    this.playerAngle = 0;

    // Animation
    this.clock = new THREE.Clock();
    this.isRunning = false;
    this.animationId = null;

    // Input
    this.setupInput();

    // Handle resize
    window.addEventListener('resize', () => this.handleResize());
  }

  buildScene() {
    // Ground
    const groundGeom = new THREE.PlaneGeometry(30, 30);
    const groundMat = new THREE.MeshStandardMaterial({
      color: 0x90ee90,
      metalness: 0,
      roughness: 0.9
    });
    const ground = new THREE.Mesh(groundGeom, groundMat);
    ground.rotation.x = -Math.PI / 2;
    ground.receiveShadow = true;
    this.scene.add(ground);

    // Skyline
    const skyMat = new THREE.MeshStandardMaterial({
      color: 0x4287f5,
      metalness: 0,
      roughness: 0.6
    });
    for (let i = 0; i < 16; i++) {
      const angle = (i / 16) * Math.PI * 2;
      const x = Math.cos(angle) * 20;
      const z = Math.sin(angle) * 20;
      const height = 8 + Math.sin(i * 0.7) * 3;
      const box = new THREE.Mesh(
        new THREE.BoxGeometry(2, height, 1),
        skyMat
      );
      box.position.set(x, height / 2, z);
      box.castShadow = true;
      this.scene.add(box);
    }

    // Central platform
    const platformMat = new THREE.MeshStandardMaterial({
      color: 0xff9800,
      metalness: 0.3,
      roughness: 0.5
    });
    const platform = new THREE.Mesh(
      new THREE.CylinderGeometry(3, 3, 0.2, 32),
      platformMat
    );
    platform.position.y = 0.1;
    platform.castShadow = true;
    platform.receiveShadow = true;
    this.scene.add(platform);

    // Game portals
    this.portals = [];
    const gameNames = ['Fishana', 'Cars', 'Badaam'];
    const colors = [0x00d4ff, 0xff6b6b, 0xffd84d];

    for (let i = 0; i < gameNames.length; i++) {
      const angle = (i / gameNames.length) * Math.PI * 2 + Math.PI / 2;
      const x = Math.cos(angle) * 10;
      const z = Math.sin(angle) * 10;

      const portalGroup = new THREE.Group();
      portalGroup.position.set(x, 0, z);

      // Portal arch
      const archMat = new THREE.MeshStandardMaterial({
        color: colors[i],
        emissive: colors[i],
        emissiveIntensity: 0.3,
        metalness: 0.6,
        roughness: 0.3
      });
      const arch = new THREE.Mesh(
        new THREE.TorusGeometry(1.5, 0.15, 16, 32, 0, Math.PI),
        archMat
      );
      arch.rotation.z = Math.PI / 2;
      arch.position.y = 1.5;
      arch.castShadow = true;
      portalGroup.add(arch);

      // Portal label (text rendered to canvas)
      const canvas = document.createElement('canvas');
      canvas.width = 256;
      canvas.height = 128;
      const ctx = canvas.getContext('2d');
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 32px system-ui';
      ctx.textAlign = 'center';
      ctx.fillText(gameNames[i], 128, 64);

      const texture = new THREE.CanvasTexture(canvas);
      const labelMat = new THREE.MeshBasicMaterial({ map: texture });
      const label = new THREE.Mesh(
        new THREE.PlaneGeometry(2, 1),
        labelMat
      );
      label.position.y = 0.5;
      portalGroup.add(label);

      this.portals.push({
        group: portalGroup,
        name: gameNames[i],
        position: new THREE.Vector3(x, 0, z)
      });

      this.scene.add(portalGroup);
    }
  }

  createAvatar(face, body, acc) {
    const group = new THREE.Group();

    // Head
    const headMat = new THREE.MeshStandardMaterial({ color: 0xffcaa7 });
    const head = new THREE.Mesh(new THREE.SphereGeometry(0.3, 16, 16), headMat);
    head.position.y = 0.6;
    head.castShadow = true;
    group.add(head);

    // Body
    const bodyMat = new THREE.MeshStandardMaterial({ color: 0x0f8fe8 });
    const body_mesh = new THREE.Mesh(new THREE.CapsuleGeometry(0.2, 0.4, 8, 16), bodyMat);
    body_mesh.position.y = 0.25;
    body_mesh.castShadow = true;
    group.add(body_mesh);

    // Legs
    const legMat = new THREE.MeshStandardMaterial({ color: 0x2c2c2c });
    for (let i = 0; i < 2; i++) {
      const leg = new THREE.Mesh(new THREE.CapsuleGeometry(0.1, 0.35, 6, 12), legMat);
      leg.position.set(i === 0 ? -0.15 : 0.15, 0, 0);
      leg.castShadow = true;
      group.add(leg);
    }

    // Shadow
    const shadowMat = new THREE.MeshBasicMaterial({
      color: 0x000000,
      transparent: true,
      opacity: 0.3
    });
    const shadow = new THREE.Mesh(new THREE.PlaneGeometry(0.5, 0.35), shadowMat);
    shadow.rotation.x = -Math.PI / 2;
    shadow.position.y = 0.01;
    group.add(shadow);

    group.castShadow = true;
    group.receiveShadow = true;

    return group;
  }

  setupInput() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'w' || e.key === 'ArrowUp') this.input.forward = true;
      if (e.key === 's' || e.key === 'ArrowDown') this.input.backward = true;
      if (e.key === 'a' || e.key === 'ArrowLeft') this.input.left = true;
      if (e.key === 'd' || e.key === 'ArrowRight') this.input.right = true;
    });

    document.addEventListener('keyup', (e) => {
      if (e.key === 'w' || e.key === 'ArrowUp') this.input.forward = false;
      if (e.key === 's' || e.key === 'ArrowDown') this.input.backward = false;
      if (e.key === 'a' || e.key === 'ArrowLeft') this.input.left = false;
      if (e.key === 'd' || e.key === 'ArrowRight') this.input.right = false;
    });
  }

  start() {
    this.isRunning = true;

    // Create player avatar
    const avatar = gameState.playerAvatar;
    this.playerAvatar = this.createAvatar(avatar.face, avatar.body, avatar.acc);
    this.playerAvatar.position.copy(this.playerPos);
    this.scene.add(this.playerAvatar);

    this.loop();
  }

  stop() {
    this.isRunning = false;
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
    if (this.playerAvatar) {
      this.scene.remove(this.playerAvatar);
    }
  }

  update(dt) {
    // Player movement
    const moveSpeed = 0.05;
    if (this.input.forward) this.playerPos.z -= moveSpeed;
    if (this.input.backward) this.playerPos.z += moveSpeed;
    if (this.input.left) this.playerPos.x -= moveSpeed;
    if (this.input.right) this.playerPos.x += moveSpeed;

    // Clamp to lobby bounds
    const maxDist = 15;
    const dist = Math.hypot(this.playerPos.x, this.playerPos.z);
    if (dist > maxDist) {
      const scale = maxDist / dist;
      this.playerPos.x *= scale;
      this.playerPos.z *= scale;
    }

    // Update avatar position
    if (this.playerAvatar) {
      this.playerAvatar.position.copy(this.playerPos);
    }

    // Update camera
    this.camera.position.x = this.playerPos.x - Math.sin(this.playerAngle) * 5;
    this.camera.position.z = this.playerPos.z - Math.cos(this.playerAngle) * 5;
    this.camera.position.y = 2;
    this.camera.lookAt(
      this.playerPos.x,
      this.playerPos.y + 0.5,
      this.playerPos.z
    );

    // Animate portals
    const time = this.clock.getElapsedTime();
    this.portals.forEach(portal => {
      portal.group.children[0].rotation.z += 0.01;
      portal.group.children[0].scale.x = 1 + Math.sin(time * 2) * 0.1;
    });
  }

  draw() {
    this.renderer.render(this.scene, this.camera);
  }

  loop = () => {
    if (!this.isRunning) return;

    const dt = this.clock.getDelta();
    this.update(dt);
    this.draw();

    this.animationId = requestAnimationFrame(this.loop);
  };

  handleResize() {
    const width = this.canvas.clientWidth;
    const height = this.canvas.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  getPortalAtPosition(maxDist = 2) {
    for (const portal of this.portals) {
      const dist = this.playerPos.distanceTo(portal.position);
      if (dist < maxDist) {
        return portal.name;
      }
    }
    return null;
  }
}
