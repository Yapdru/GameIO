// Performance monitoring and optimization utilities

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

export class PerformanceMonitor {
  constructor(renderer) {
    this.renderer = renderer;
    this.frameCount = 0;
    this.fps = 60;
    this.frameTime = 0;
    this.samples = [];
    this.maxSamples = 60;
    this.startTime = performance.now();
    this.lastTime = this.startTime;
  }

  update() {
    const now = performance.now();
    this.frameTime = now - this.lastTime;
    this.lastTime = now;

    this.samples.push(this.frameTime);
    if (this.samples.length > this.maxSamples) {
      this.samples.shift();
    }

    this.frameCount++;
    const elapsed = (now - this.startTime) / 1000;

    if (elapsed >= 1) {
      this.fps = this.frameCount / elapsed;
      this.startTime = now;
      this.frameCount = 0;
    }
  }

  getStats() {
    const info = this.renderer.info.render;
    const memory = this.renderer.info.memory;
    const avgFrameTime = this.samples.reduce((a, b) => a + b, 0) / this.samples.length;

    return {
      fps: Math.round(this.fps),
      frameTime: Math.round(this.frameTime * 100) / 100,
      avgFrameTime: Math.round(avgFrameTime * 100) / 100,
      drawCalls: info.calls || 0,
      triangles: info.triangles || 0,
      geometries: memory.geometries || 0,
      textures: memory.textures || 0
    };
  }

  isPerformanceGood() {
    return this.frameTime < 16; // 60 FPS target
  }

  log() {
    const stats = this.getStats();
    console.log(`FPS: ${stats.fps} | Frame: ${stats.frameTime}ms | Draw: ${stats.drawCalls} | Tri: ${stats.triangles}`);
  }
}

// Automatic quality adjustment based on performance
export class AdaptiveQuality {
  constructor(renderer) {
    this.renderer = renderer;
    this.quality = 'high'; // high, medium, low
    this.checkInterval = 120; // frames between checks
    this.frameCount = 0;
    this.lowFrameCount = 0;
    this.threshold = 14; // 60 FPS target
  }

  update(frameTime) {
    this.frameCount++;

    if (frameTime > this.threshold) {
      this.lowFrameCount++;
    } else {
      this.lowFrameCount = 0;
    }

    if (this.frameCount >= this.checkInterval) {
      const lowFrameRatio = this.lowFrameCount / this.checkInterval;

      if (lowFrameRatio > 0.5 && this.quality !== 'low') {
        // Too many slow frames, reduce quality
        this.setQuality(this.quality === 'high' ? 'medium' : 'low');
      } else if (lowFrameRatio < 0.1 && this.quality !== 'high') {
        // Good performance, increase quality
        this.setQuality(this.quality === 'low' ? 'medium' : 'high');
      }

      this.frameCount = 0;
      this.lowFrameCount = 0;
    }
  }

  setQuality(quality) {
    this.quality = quality;

    switch (quality) {
      case 'high':
        this.renderer.shadowMap.type = THREE.PCFShadowShadowMap;
        break;
      case 'medium':
        this.renderer.shadowMap.type = THREE.PCFShadowShadowMap;
        break;
      case 'low':
        this.renderer.shadowMap.type = THREE.BasicShadowMap;
        break;
    }

    console.log(`Quality adjusted to: ${quality}`);
  }
}

// Culling optimization
export class FrustumCuller {
  constructor(camera) {
    this.camera = camera;
    this.frustum = new THREE.Frustum();
    this.culledObjects = [];
  }

  update() {
    const projScreenMatrix = new THREE.Matrix4();
    projScreenMatrix.multiplyMatrices(
      this.camera.projectionMatrix,
      this.camera.matrixWorldInverse
    );
    this.frustum.setFromProjectionMatrix(projScreenMatrix);
  }

  isVisible(object) {
    if (object.geometry) {
      object.geometry.computeBoundingSphere();
      return this.frustum.intersectsSphere(object.geometry.boundingSphere);
    }
    return true;
  }

  cullScene(scene) {
    this.culledObjects = [];
    scene.traverse(object => {
      if (object.isMesh && !this.isVisible(object)) {
        object.visible = false;
        this.culledObjects.push(object);
      } else if (object.isMesh) {
        object.visible = true;
      }
    });
    return this.culledObjects.length;
  }
}

// Batch rendering for static geometry
export class GeometryBatcher {
  static mergeGeometries(meshes) {
    const geometries = [];
    const materials = [];

    meshes.forEach(mesh => {
      if (mesh.isMesh) {
        geometries.push(mesh.geometry);
        materials.push(mesh.material);
      }
    });

    const mergedGeom = THREE.BufferGeometryUtils.mergeGeometries(geometries);
    const mergedMesh = new THREE.Mesh(mergedGeom, materials[0]);

    return mergedMesh;
  }
}
