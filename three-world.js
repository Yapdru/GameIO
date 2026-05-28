// ThreeWorld - Parallel 3D rendering engine for GameIO
// Implements same interface as 2D engine, supports both lobby and game worlds

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';
import { gameState } from './state.js';
import { Avatar } from './three-avatar.js';
import { CameraManager } from './three-camera.js';
import { WorldManager } from './three-worlds.js';
import { PerformanceMonitor } from './three-performance.js';

// Use the enhanced Avatar class from three-avatar.js
export { Avatar as ThreeAvatar };

export class ThreeWorld {
  constructor(canvas, gameData = null) {
    this.canvas = canvas;
    this.gameData = gameData;
    this.width = canvas.clientWidth;
    this.height = canvas.clientHeight;

    // Scene setup
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0a0e27);
    this.scene.fog = new THREE.Fog(0x0a0e27, 40, 100);

    // Camera with chase view
    this.camera = new THREE.PerspectiveCamera(75, this.width / this.height, 0.1, 1000);
    this.camera.position.set(0, 3, 8);
    this.cameraManager = new CameraManager(this.camera);

    // Renderer
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setSize(this.width, this.height);
    this.renderer.setPixelRatio(window.devicePixelRatio || 1);
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFShadowShadowMap;

    // Lighting
    this.setupLighting();

    // World objects
    this.playerAvatar = null;
    this.remoteAvatars = {};
    this.portals = [];
    this.worldManager = new WorldManager(this.scene);

    // Performance monitoring
    this.perfMonitor = new PerformanceMonitor(this.renderer);

    // Input state
    this.keys = {};
    this.setupInput();

    // Game state
    this.isRunning = false;
    this.gameScore = 0;
    this.players = [];
    this.clock = new THREE.Clock();
    this.frameCount = 0;

    // Build lobby by default
    if (!gameData || gameData.type !== 'game') {
      this.buildLobby();
    }
  }

  setupLighting() {
    // Hemisphere light (sky blue + ground)
    const hemiLight = new THREE.HemisphereLight(0x87ceeb, 0x1a3a52, 0.8);
    this.scene.add(hemiLight);

    // Directional sun light
    const sunLight = new THREE.DirectionalLight(0xffd700, 0.9);
    sunLight.position.set(30, 40, 20);
    sunLight.castShadow = true;
    sunLight.shadow.mapSize.width = 1024;
    sunLight.shadow.mapSize.height = 1024;
    sunLight.shadow.camera.far = 100;
    sunLight.shadow.camera.left = -50;
    sunLight.shadow.camera.right = 50;
    sunLight.shadow.camera.top = 50;
    sunLight.shadow.camera.bottom = -50;
    this.scene.add(sunLight);

    // Ambient light for fill
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.3);
    this.scene.add(ambientLight);
  }

  buildLobby() {
    // Ground plane
    const groundGeom = new THREE.PlaneGeometry(60, 60);
    const groundMat = new THREE.MeshStandardMaterial({
      color: 0x2a4a6a,
      roughness: 0.7,
      metalness: 0
    });
    const ground = new THREE.Mesh(groundGeom, groundMat);
    ground.rotation.x = -Math.PI / 2;
    ground.receiveShadow = true;
    this.scene.add(ground);

    // Skyline boxes (background)
    const skylineColors = [0xff6b6b, 0xff8e8e, 0xffa5a5, 0xffc0c0];
    for (let i = 0; i < 8; i++) {
      const boxGeom = new THREE.BoxGeometry(8, 15, 4);
      const mat = new THREE.MeshStandardMaterial({ color: skylineColors[i % 4] });
      const box = new THREE.Mesh(boxGeom, mat);
      box.position.set(
        Math.cos(i / 8 * Math.PI * 2) * 35,
        7,
        Math.sin(i / 8 * Math.PI * 2) * 35
      );
      box.castShadow = true;
      box.receiveShadow = true;
      this.scene.add(box);
    }

    // Portal arches (6 games arranged radially)
    const games = ['fishana', 'cars', 'space', 'obby', 'badaam', 'quiz'];
    const portalRadius = 15;
    for (let i = 0; i < games.length; i++) {
      const angle = (i / games.length) * Math.PI * 2;
      const x = Math.cos(angle) * portalRadius;
      const z = Math.sin(angle) * portalRadius;

      this.buildPortal(x, 0, z, games[i]);
    }

    // Central elevator platform
    const centerGeom = new THREE.CylinderGeometry(3, 3, 0.5, 16);
    const centerMat = new THREE.MeshStandardMaterial({
      color: 0xffd84d,
      emissive: 0xffa500,
      metalness: 0.7,
      roughness: 0.3
    });
    const center = new THREE.Mesh(centerGeom, centerMat);
    center.position.y = 0.25;
    center.castShadow = true;
    center.receiveShadow = true;
    this.scene.add(center);
  }

  buildPortal(x, y, z, gameKey) {
    // Portal arch (torus + rings)
    const archGeom = new THREE.TorusGeometry(2, 0.3, 16, 32);
    const archMat = new THREE.MeshStandardMaterial({
      color: 0x00d4ff,
      emissive: 0x0080ff,
      metalness: 0.8,
      roughness: 0.2
    });
    const arch = new THREE.Mesh(archGeom, archMat);
    arch.rotation.x = Math.PI / 2;
    arch.position.set(x, y + 3, z);
    arch.castShadow = true;
    this.scene.add(arch);

    // Portal sphere (center glowing)
    const sphereGeom = new THREE.SphereGeometry(1.5, 16, 16);
    const sphereMat = new THREE.MeshStandardMaterial({
      color: 0x00ffff,
      emissive: 0x0080ff,
      metalness: 0.6,
      roughness: 0.3,
      transparent: true,
      opacity: 0.7
    });
    const sphere = new THREE.Mesh(sphereGeom, sphereMat);
    sphere.position.set(x, y + 3, z);
    this.scene.add(sphere);

    // Portal label (canvas texture)
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, 256, 256);
    ctx.fillStyle = '#fff';
    ctx.font = '32px bold Arial';
    ctx.textAlign = 'center';
    ctx.fillText(gameKey.toUpperCase(), 128, 128);

    const texture = new THREE.CanvasTexture(canvas);
    const labelGeom = new THREE.PlaneGeometry(4, 2);
    const labelMat = new THREE.MeshBasicMaterial({ map: texture });
    const label = new THREE.Mesh(labelGeom, labelMat);
    label.position.set(x, y + 1, z - 2.5);
    label.rotation.y = Math.atan2(-z, -x);
    this.scene.add(label);

    // Store portal for collision detection
    this.portals.push({
      position: new THREE.Vector3(x, y + 3, z),
      radius: 2,
      gameKey: gameKey
    });
  }

  setupInput() {
    document.addEventListener('keydown', (e) => {
      this.keys[e.key.toLowerCase()] = true;
    });
    document.addEventListener('keyup', (e) => {
      this.keys[e.key.toLowerCase()] = false;
    });
  }

  setPlayers(players) {
    this.players = players;

    // Update remote avatars
    players.forEach(p => {
      if (p.id !== gameState.playerId) {
        if (!this.remoteAvatars[p.id]) {
          const avatar = new Avatar(p.avatar?.face || '😎', p.avatar?.body || '🧥', p.avatar?.acc || '⚡');
          this.scene.add(avatar.group);
          this.remoteAvatars[p.id] = avatar;
        }
        // Update position (with dead reckoning)
        const avatar = this.remoteAvatars[p.id];
        avatar.setPosition(p.x || 0, p.y || 0, p.z || 0);
        if (p.vx !== undefined && p.vz !== undefined) {
          avatar.setVelocity(p.vx, p.vz);
        }
      }
    });

    // Remove avatars for players who left
    Object.keys(this.remoteAvatars).forEach(id => {
      if (!players.find(p => p.id === id)) {
        this.scene.remove(this.remoteAvatars[id].group);
        delete this.remoteAvatars[id];
      }
    });
  }

  start(gameData = null) {
    this.isRunning = true;
    this.gameData = gameData;
    this.clock.start();

    // Create player avatar
    const avatar = gameState.playerAvatar;
    this.playerAvatar = new Avatar(avatar?.face || '😎', avatar?.body || '🧥', avatar?.acc || '⚡');
    this.scene.add(this.playerAvatar.group);
    this.playerAvatar.setPosition(0, 0, 0);

    // Start frame loop
    this.frameLoop();
  }

  async loadGameWorld(gameKey) {
    return await this.worldManager.loadWorld(gameKey);
  }

  stop() {
    this.isRunning = false;
    this.worldManager.dispose();
    if (this.renderer) {
      this.renderer.dispose();
    }
  }

  handleResize() {
    this.width = this.canvas.clientWidth;
    this.height = this.canvas.clientHeight;
    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(this.width, this.height);
  }

  update(dt) {
    if (!this.playerAvatar) return;

    // Player movement (WASD / Arrow keys)
    const moveSpeed = 5;
    let dx = 0, dz = 0;

    if (this.keys['w'] || this.keys['arrowup']) dz -= moveSpeed;
    if (this.keys['s'] || this.keys['arrowdown']) dz += moveSpeed;
    if (this.keys['a'] || this.keys['arrowleft']) dx -= moveSpeed;
    if (this.keys['d'] || this.keys['arrowright']) dx += moveSpeed;

    // Update velocity for animation
    this.playerAvatar.velocity.set(dx, 0, dz);
    this.playerAvatar.setVelocity(dx, dz);

    // Update position
    this.playerAvatar.group.position.x += dx * dt;
    this.playerAvatar.group.position.z += dz * dt;

    // Boundary clamping
    const boundary = 25;
    this.playerAvatar.group.position.x = Math.max(-boundary, Math.min(boundary, this.playerAvatar.group.position.x));
    this.playerAvatar.group.position.z = Math.max(-boundary, Math.min(boundary, this.playerAvatar.group.position.z));

    // Update avatars
    this.playerAvatar.update(dt);
    Object.values(this.remoteAvatars).forEach(avatar => avatar.update(dt));

    // Check portal collisions
    if (this.gameData === null) { // Only in lobby
      const playerPos = this.playerAvatar.group.position;
      this.portals.forEach(portal => {
        const dist = playerPos.distanceTo(portal.position);
        if (dist < portal.radius + 1) {
          // Portal collision detected
          if (this.onPortalCollide) {
            this.onPortalCollide(portal.gameKey);
          }
        }
      });
    }
  }

  updateCamera(dt) {
    if (!this.playerAvatar) return;

    const playerPos = this.playerAvatar.group.position;
    const playerVel = this.playerAvatar.velocity;

    this.cameraManager.update(dt, playerPos, playerVel);
  }

  frameLoop = () => {
    if (!this.isRunning) return;

    const dt = Math.min(this.clock.getDelta(), 0.016); // Cap at 60 FPS

    this.update(dt);
    this.updateCamera(dt);
    this.worldManager.update(dt);

    this.renderer.render(this.scene, this.camera);

    // Performance monitoring
    this.perfMonitor.update();

    // Periodic logging
    if (this.frameCount % 300 === 0) {
      this.perfMonitor.log();
    }

    this.frameCount++;
    requestAnimationFrame(this.frameLoop);
  };

  getScore() {
    return Math.floor(this.gameScore);
  }
}
