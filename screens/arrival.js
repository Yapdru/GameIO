// First-person arrival cinematic intro
// Optional visual sequence when entering multiplayer lobby

import { Screen, screenManager } from '../screens.js';
import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';
import { audioSystem } from '../audio-system.js';

export class ArrivalScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.element.style.display = 'flex';
    this.element.style.flexDirection = 'column';
    this.element.style.background = '#000';
    this.element.style.alignItems = 'center';
    this.element.style.justifyContent = 'center';
    this.element.style.overflow = 'hidden';

    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.isRunning = false;
    this.animationId = null;
    this.clock = new THREE.Clock();
    this.duration = 3.5; // seconds
    this.elapsed = 0;

    this.build();
  }

  build() {
    // Canvas for 3D
    const canvas = document.createElement('canvas');
    canvas.style.width = '100%';
    canvas.style.height = '100%';

    // Skip button
    const skipBtn = document.createElement('button');
    skipBtn.textContent = 'Skip (Press SPACE)';
    skipBtn.style.position = 'fixed';
    skipBtn.style.bottom = '20px';
    skipBtn.style.right = '20px';
    skipBtn.style.padding = '10px 20px';
    skipBtn.style.background = 'rgba(255,255,255,0.2)';
    skipBtn.style.color = 'white';
    skipBtn.style.border = 'none';
    skipBtn.style.borderRadius = '5px';
    skipBtn.style.cursor = 'pointer';
    skipBtn.style.zIndex = '10';
    skipBtn.onclick = () => this.skipIntro();

    this.element.appendChild(canvas);
    this.element.appendChild(skipBtn);

    // Setup Three.js
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x000000);

    this.camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
    this.camera.position.set(0, 1.5, -10);

    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(window.devicePixelRatio || 1);

    // Lighting
    const light = new THREE.DirectionalLight(0xffffff, 0.8);
    light.position.set(5, 10, 5);
    this.scene.add(light);

    const ambientLight = new THREE.AmbientLight(0x4488ff, 0.5);
    this.scene.add(ambientLight);

    // Create arrival corridor (simple tunnel effect)
    const geometry = new THREE.BoxGeometry(15, 8, 2);
    const material = new THREE.MeshStandardMaterial({
      color: 0x1a5f7a,
      metalness: 0.3,
      roughness: 0.7
    });

    for (let i = 0; i < 20; i++) {
      const corridor = new THREE.Mesh(geometry, material);
      corridor.position.z = -i * 2;
      corridor.userData.initialZ = corridor.position.z;
      this.scene.add(corridor);
    }

    // Floating particles
    const particleGeometry = new THREE.BufferGeometry();
    const particleCount = 100;
    const positions = new Float32Array(particleCount * 3);

    for (let i = 0; i < particleCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 20;
      positions[i + 1] = (Math.random() - 0.5) * 10;
      positions[i + 2] = (Math.random() - 0.5) * 30;
    }

    particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const particleMaterial = new THREE.PointsMaterial({
      color: 0xffd700,
      size: 0.2,
      sizeAttenuation: true
    });

    this.particles = new THREE.Points(particleGeometry, particleMaterial);
    this.scene.add(this.particles);

    // Arrival lights
    const light1 = new THREE.PointLight(0x00d4ff, 1, 50);
    light1.position.set(-5, 3, 0);
    this.scene.add(light1);

    const light2 = new THREE.PointLight(0xffd84d, 1, 50);
    light2.position.set(5, 3, 0);
    this.scene.add(light2);

    // Handle skip
    document.addEventListener('keydown', (e) => {
      if (e.code === 'Space') {
        this.skipIntro();
      }
    });

    window.addEventListener('resize', () => this.handleResize());
  }

  skipIntro() {
    this.isRunning = false;
    if (this.animationId) cancelAnimationFrame(this.animationId);
    audioSystem.stopSound('arrival');
    screenManager.show('lobby-3d');
  }

  onShow() {
    audioSystem.initialize();
    this.isRunning = true;
    this.elapsed = 0;
    this.animate();
  }

  onHide() {
    this.isRunning = false;
    if (this.animationId) cancelAnimationFrame(this.animationId);
  }

  animate = () => {
    if (!this.isRunning) return;

    const dt = this.clock.getDelta();
    this.elapsed += dt;

    // Camera flies forward through corridor
    const progress = Math.min(this.elapsed / this.duration, 1);
    const eased = progress < 0.5
      ? 2 * progress * progress
      : -1 + (4 - 2 * progress) * progress;

    this.camera.position.z = -10 + eased * 15;
    this.camera.position.x = Math.sin(eased * Math.PI * 2) * 2;

    // Update corridor positions
    this.scene.children.forEach((obj) => {
      if (obj.userData.initialZ !== undefined) {
        obj.position.z = obj.userData.initialZ + eased * 40;

        // Fade out when behind camera
        if (obj.position.z > 5) {
          obj.material.opacity = Math.max(0, 1 - (obj.position.z - 5) / 5);
          obj.material.transparent = true;
        }
      }
    });

    // Animate particles
    if (this.particles) {
      this.particles.rotation.x += 0.0005;
      this.particles.rotation.y += 0.001;
      this.particles.position.z = -eased * 15;
    }

    // Fade intensity
    if (progress > 0.8) {
      const fadeProgress = (progress - 0.8) / 0.2;
      this.renderer.domElement.style.opacity = 1 - fadeProgress;
    }

    this.renderer.render(this.scene, this.camera);

    // Auto-skip when done
    if (progress >= 1) {
      this.skipIntro();
      return;
    }

    this.animationId = requestAnimationFrame(this.animate);
  };

  handleResize() {
    const width = this.renderer.domElement.clientWidth;
    const height = this.renderer.domElement.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }
}
