// World Manager - Dynamically loads and manages game-specific 3D worlds

import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

const WORLD_MODULES = {
  fishana: () => import('./worlds/fishana-world.js').then(m => m.buildFishanaWorld),
  cars: () => import('./worlds/cars-world.js').then(m => m.buildCarsWorld),
  space: () => import('./worlds/space-world.js').then(m => m.buildSpaceWorld),
  obby: () => import('./worlds/obby-world.js').then(m => m.buildObbyWorld)
};

export class WorldManager {
  constructor(scene) {
    this.scene = scene;
    this.currentWorld = null;
    this.currentGameKey = null;
    this.worldData = null;
  }

  async loadWorld(gameKey) {
    if (!WORLD_MODULES[gameKey]) {
      console.warn(`No world module for game: ${gameKey}`);
      return false;
    }

    try {
      // Clear previous world (except lighting)
      this.clearWorld();

      // Load world builder
      const builder = await WORLD_MODULES[gameKey]();
      this.worldData = builder(this.scene);
      this.currentGameKey = gameKey;
      this.currentWorld = this.worldData;

      return true;
    } catch (e) {
      console.error(`Failed to load world for ${gameKey}:`, e);
      return false;
    }
  }

  clearWorld() {
    // Keep only lights and camera
    const keepTypes = [THREE.Light, THREE.Camera];
    const toRemove = [];

    this.scene.children.forEach(child => {
      const isKeep = keepTypes.some(type => child instanceof type);
      if (!isKeep) {
        toRemove.push(child);
      }
    });

    toRemove.forEach(child => {
      // Dispose geometries and materials
      if (child.geometry) child.geometry.dispose();
      if (child.material) {
        if (Array.isArray(child.material)) {
          child.material.forEach(m => m.dispose());
        } else {
          child.material.dispose();
        }
      }
      this.scene.remove(child);
    });
  }

  update(dt) {
    if (this.worldData && this.worldData.onUpdate) {
      this.worldData.onUpdate(dt);
    }
  }

  dispose() {
    this.clearWorld();
    this.worldData = null;
    this.currentWorld = null;
  }
}

// LOD System for performance optimization
export class LODManager {
  constructor() {
    this.lodObjects = [];
  }

  addLOD(mesh, distances, lodMeshes) {
    const lod = new THREE.LOD();
    lod.addLevel(mesh, 0);

    lodMeshes.forEach((lodMesh, idx) => {
      lod.addLevel(lodMesh, distances[idx]);
    });

    this.lodObjects.push(lod);
    return lod;
  }

  update(camera) {
    this.lodObjects.forEach(lod => {
      lod.update(camera);
    });
  }
}

// Instancing utility for performance
export class InstancedMesh {
  static createInstances(geometry, material, positions, count) {
    const instancedMesh = new THREE.InstancedMesh(geometry, material, count);

    positions.forEach((pos, idx) => {
      const matrix = new THREE.Matrix4();
      matrix.setPosition(pos.x, pos.y, pos.z);
      if (pos.rotation) {
        const quaternion = new THREE.Quaternion();
        quaternion.setFromEuler(pos.rotation);
        matrix.makeRotationFromQuaternion(quaternion);
      }
      if (pos.scale) {
        matrix.scale(new THREE.Vector3(pos.scale, pos.scale, pos.scale));
      }
      instancedMesh.setMatrixAt(idx, matrix);
    });

    instancedMesh.instanceMatrix.needsUpdate = true;
    return instancedMesh;
  }
}
