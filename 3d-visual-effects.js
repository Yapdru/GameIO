// Advanced 3D Visual Effects System
// Post-processing, particle effects, and advanced lighting for Three.js

class VisualEffectsManager {
  constructor(renderer, scene) {
    this.renderer = renderer;
    this.scene = scene;
    this.effects = new Map();
    this.particles = [];
    this.lights = [];
    this.postProcessors = [];
  }

  // Create advanced material with multiple textures
  createAdvancedMaterial(config = {}) {
    const THREE = window.THREE;
    const {
      color = 0xffffff,
      roughness = 0.5,
      metalness = 0.5,
      emissive = 0x000000,
      emissiveIntensity = 0,
      normalScale = 1,
      envMapIntensity = 1
    } = config;

    return new THREE.MeshStandardMaterial({
      color,
      roughness,
      metalness,
      emissive,
      emissiveIntensity,
      envMapIntensity,
      side: THREE.DoubleSide
    });
  }

  // Create reflective water material
  createWaterMaterial() {
    const THREE = window.THREE;
    return new THREE.MeshPhysicalMaterial({
      color: 0x8eeaff,
      roughness: 0.1,
      metalness: 0.9,
      transmission: 0.5,
      clearcoat: 0.8,
      clearcoatRoughness: 0.2,
      transparent: true,
      opacity: 0.85
    });
  }

  // Create glass material with refraction
  createGlassMaterial(color = 0x8eeaff) {
    const THREE = window.THREE;
    return new THREE.MeshPhysicalMaterial({
      color,
      roughness: 0.05,
      metalness: 0.1,
      transmission: 0.95,
      clearcoat: 0.9,
      clearcoatRoughness: 0.1,
      transparent: true,
      opacity: 0.9,
      side: THREE.DoubleSide
    });
  }

  // Create neon glowing material
  createNeonMaterial(color = 0xff00ff) {
    const THREE = window.THREE;
    return new THREE.MeshStandardMaterial({
      color,
      emissive: color,
      emissiveIntensity: 2.5,
      roughness: 0.2,
      metalness: 0.8,
      toneMapped: false
    });
  }

  // Create gradient material
  createGradientMaterial(color1 = 0xff0000, color2 = 0x0000ff) {
    const THREE = window.THREE;
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');

    const gradient = ctx.createLinearGradient(0, 0, 256, 256);
    gradient.addColorStop(0, '#' + color1.toString(16).padStart(6, '0'));
    gradient.addColorStop(1, '#' + color2.toString(16).padStart(6, '0'));
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 256, 256);

    const texture = new THREE.CanvasTexture(canvas);
    return new THREE.MeshStandardMaterial({ map: texture });
  }

  // Create particle system
  createParticleSystem(config = {}) {
    const THREE = window.THREE;
    const {
      particleCount = 1000,
      particleSize = 0.1,
      color = 0xffffff,
      velocity = { x: 0, y: 1, z: 0 },
      lifespan = 3000,
      position = { x: 0, y: 0, z: 0 }
    } = config;

    const geometry = new THREE.BufferGeometry();
    const positions = [];
    const velocities = [];
    const lifespans = [];

    for (let i = 0; i < particleCount; i++) {
      positions.push(
        position.x + (Math.random() - 0.5) * 2,
        position.y + (Math.random() - 0.5) * 2,
        position.z + (Math.random() - 0.5) * 2
      );

      velocities.push(
        velocity.x + (Math.random() - 0.5) * 0.1,
        velocity.y + (Math.random() - 0.5) * 0.1,
        velocity.z + (Math.random() - 0.5) * 0.1
      );

      lifespans.push(lifespan);
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(positions), 3));
    geometry.setAttribute('velocity', new THREE.BufferAttribute(new Float32Array(velocities), 3));
    geometry.setAttribute('lifespan', new THREE.BufferAttribute(new Float32Array(lifespans), 1));

    const material = new THREE.PointsMaterial({
      color,
      size: particleSize,
      sizeAttenuation: true,
      transparent: true,
      opacity: 0.8
    });

    const particles = new THREE.Points(geometry, material);
    this.particles.push(particles);
    this.scene.add(particles);

    return particles;
  }

  // Add bloom effect to object
  addBloom(object, intensity = 2) {
    object.layers.enable(1);
    const material = object.material.clone();
    material.emissiveIntensity = intensity;
    object.material = material;
  }

  // Create point light with effects
  createEffectLight(config = {}) {
    const THREE = window.THREE;
    const {
      color = 0xffffff,
      intensity = 1,
      distance = 100,
      position = { x: 0, y: 0, z: 0 },
      castShadow = true,
      flicker = false,
      flickerIntensity = 0.2
    } = config;

    const light = new THREE.PointLight(color, intensity, distance);
    light.position.set(position.x, position.y, position.z);
    light.castShadow = castShadow;

    if (flicker) {
      light.userData = {
        baseIntensity: intensity,
        flickerIntensity,
        time: Math.random() * Math.PI * 2
      };
    }

    this.lights.push(light);
    this.scene.add(light);
    return light;
  }

  // Update flickering lights
  updateFlickeringLights(deltaTime) {
    this.lights.forEach(light => {
      if (light.userData && light.userData.flickerIntensity) {
        light.userData.time += deltaTime * 5;
        const flicker = Math.sin(light.userData.time) * light.userData.flickerIntensity;
        light.intensity = light.userData.baseIntensity + flicker;
      }
    });
  }

  // Create lens flare effect
  createLensFlare(position = { x: 0, y: 0, z: 0 }) {
    const THREE = window.THREE;
    const flareGeometry = new THREE.BufferGeometry();
    const flarePositions = [
      position.x, position.y, position.z,
      position.x + 0.5, position.y, position.z,
      position.x - 0.5, position.y, position.z
    ];

    flareGeometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(flarePositions), 3));
    const flareMaterial = new THREE.PointsMaterial({
      color: 0xffffff,
      size: 2,
      sizeAttenuation: true,
      transparent: true,
      opacity: 0.6
    });

    const flare = new THREE.Points(flareGeometry, flareMaterial);
    this.scene.add(flare);
    return flare;
  }

  // Create motion blur effect
  createMotionBlur(object, velocity = { x: 0, y: 0, z: 0 }, intensity = 0.1) {
    object.userData = {
      ...object.userData,
      motionBlur: true,
      velocity,
      blurIntensity: intensity,
      trail: []
    };
  }

  // Update motion blur trails
  updateMotionBlur(deltaTime) {
    this.scene.children.forEach(obj => {
      if (obj.userData && obj.userData.motionBlur) {
        const velocity = obj.userData.velocity;
        obj.position.x += velocity.x * deltaTime;
        obj.position.y += velocity.y * deltaTime;
        obj.position.z += velocity.z * deltaTime;

        if (obj.userData.trail.length === 0) {
          obj.userData.trail = [];
        }
        obj.userData.trail.push({
          position: obj.position.clone(),
          time: Date.now()
        });

        // Remove old trail points
        const now = Date.now();
        obj.userData.trail = obj.userData.trail.filter(point => now - point.time < 200);
      }
    });
  }

  // Create depth of field effect (mock)
  createDepthOfField(nearPlane = 1, farPlane = 100) {
    this.renderer.camera.near = nearPlane;
    this.renderer.camera.far = farPlane;
    this.renderer.camera.updateProjectionMatrix();
  }

  // Create fog effect with animation
  createAnimatedFog(color = 0xcccccc, nearDistance = 1, farDistance = 100) {
    const fog = new window.THREE.Fog(color, farDistance, nearDistance);
    fog.userData = {
      baseNear: nearDistance,
      baseFar: farDistance,
      animate: true,
      time: 0
    };
    this.scene.fog = fog;
    return fog;
  }

  // Update animated fog
  updateAnimatedFog(deltaTime) {
    if (this.scene.fog && this.scene.fog.userData && this.scene.fog.userData.animate) {
      this.scene.fog.userData.time += deltaTime;
      const wave = Math.sin(this.scene.fog.userData.time * 0.5) * 10;
      this.scene.fog.near = this.scene.fog.userData.baseNear + wave;
      this.scene.fog.far = this.scene.fog.userData.baseFar + wave;
    }
  }

  // Create environment map from canvas
  createEnvironmentLighting(canvas) {
    const THREE = window.THREE;
    const texture = new THREE.CanvasTexture(canvas);
    return new THREE.Light();
  }

  // Add chromatic aberration effect
  addChromaticAberration(strength = 0.01) {
    this.postProcessors.push({
      type: 'chromatic',
      strength
    });
  }

  // Add vignette effect
  addVignette(darkness = 1.2) {
    this.postProcessors.push({
      type: 'vignette',
      darkness
    });
  }

  // Screen shake effect
  screenShake(camera, intensity = 0.1, duration = 200) {
    const startTime = Date.now();
    const originalPos = camera.position.clone();

    const shakeInterval = setInterval(() => {
      const elapsed = Date.now() - startTime;
      if (elapsed > duration) {
        camera.position.copy(originalPos);
        clearInterval(shakeInterval);
        return;
      }

      const progress = elapsed / duration;
      const shakeAmount = intensity * (1 - progress);

      camera.position.x = originalPos.x + (Math.random() - 0.5) * shakeAmount;
      camera.position.y = originalPos.y + (Math.random() - 0.5) * shakeAmount;
      camera.position.z = originalPos.z + (Math.random() - 0.5) * shakeAmount;
    }, 16);
  }

  // Create trail effect for moving objects
  createTrailEffect(object, trailMaterial, segments = 20) {
    const THREE = window.THREE;
    const points = [];
    for (let i = 0; i < segments; i++) {
      points.push(object.position.clone());
    }

    const geometry = new THREE.TubeGeometry(
      new THREE.CatmullRomCurve3(points),
      20, 0.3, 8, false
    );

    const trail = new THREE.Mesh(geometry, trailMaterial);
    object.userData.trail = {
      mesh: trail,
      points,
      geometry,
      segments
    };

    return trail;
  }

  // Update all visual effects
  update(deltaTime) {
    this.updateFlickeringLights(deltaTime);
    this.updateMotionBlur(deltaTime);
    this.updateAnimatedFog(deltaTime);

    // Update particles
    this.particles.forEach(particleSystem => {
      const positions = particleSystem.geometry.attributes.position.array;
      const velocities = particleSystem.geometry.attributes.velocity.array;

      for (let i = 0; i < positions.length; i += 3) {
        positions[i] += velocities[i] * deltaTime;
        positions[i + 1] += velocities[i + 1] * deltaTime;
        positions[i + 2] += velocities[i + 2] * deltaTime;
      }

      particleSystem.geometry.attributes.position.needsUpdate = true;
    });
  }

  // Cleanup
  dispose() {
    this.particles.forEach(p => {
      p.geometry.dispose();
      p.material.dispose();
      this.scene.remove(p);
    });

    this.lights.forEach(light => this.scene.remove(light));
    this.particles = [];
    this.lights = [];
  }
}

export { VisualEffectsManager };
