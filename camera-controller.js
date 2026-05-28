// Advanced Camera Control System
// Smooth camera movements, cinematic effects, and multiple camera modes

class CameraController {
  constructor(camera) {
    this.camera = camera;
    this.target = { x: 0, y: 0, z: 0 };
    this.position = { x: 0, y: 0, z: 0 };
    this.velocity = { x: 0, y: 0, z: 0 };
    this.modes = new Map();
    this.currentMode = 'default';
    this.isTransitioning = false;
    this.transitionDuration = 1000;
    this.transitionStart = 0;
    this.smoothness = 0.1;
    this.damping = 0.85;
    this.constraints = {
      minDistance: 1,
      maxDistance: 100,
      minPitch: -Math.PI / 2,
      maxPitch: Math.PI / 2
    };
    this.shake = { intensity: 0, duration: 0, startTime: 0 };
  }

  // Create camera mode
  createMode(name, config = {}) {
    const {
      position = { x: 0, y: 0, z: 0 },
      target = { x: 0, y: 0, z: 0 },
      fov = 60,
      followObject = null,
      followDistance = 5,
      followHeight = 2,
      rotationSpeed = 0.01,
      zoomSpeed = 1,
      type = 'free'
    } = config;

    this.modes.set(name, {
      name,
      position: { ...position },
      target: { ...target },
      fov,
      followObject,
      followDistance,
      followHeight,
      rotationSpeed,
      zoomSpeed,
      type,
      state: {}
    });

    return name;
  }

  // Switch to camera mode
  switchToMode(modeName, transitionDuration = 1000) {
    const mode = this.modes.get(modeName);

    if (!mode) {
      console.warn(`Camera mode "${modeName}" not found`);
      return false;
    }

    this.currentMode = modeName;
    this.isTransitioning = true;
    this.transitionStart = Date.now();
    this.transitionDuration = transitionDuration;

    // Store target position for transition
    this.transitionStart = {
      position: { ...this.position },
      target: { ...this.target },
      fov: this.camera.fov
    };

    this.transitionTarget = {
      position: { ...mode.position },
      target: { ...mode.target },
      fov: mode.fov
    };

    return true;
  }

  // Smooth follow target
  followObject(object, distance = 5, height = 2) {
    const mode = this.modes.get(this.currentMode);
    if (mode) {
      mode.followObject = object;
      mode.followDistance = distance;
      mode.followHeight = height;
    }
  }

  // Look at target
  lookAt(target, duration = 300) {
    this.target = { ...target };

    if (this.camera.lookAt) {
      if (duration > 0) {
        this._animateLookAt(target, duration);
      } else {
        this.camera.lookAt(target.x, target.y, target.z);
      }
    }
  }

  // Pan camera
  pan(dx, dy, duration = 500) {
    const newTarget = {
      x: this.target.x + dx,
      y: this.target.y + dy,
      z: this.target.z
    };

    this._smoothTransition(
      this.target,
      newTarget,
      duration
    );
  }

  // Zoom camera
  zoom(amount, duration = 300) {
    const direction = {
      x: this.target.x - this.position.x,
      y: this.target.y - this.position.y,
      z: this.target.z - this.position.z
    };

    const distance = Math.sqrt(
      direction.x * direction.x +
      direction.y * direction.y +
      direction.z * direction.z
    );

    const normalizedDir = {
      x: direction.x / distance,
      y: direction.y / distance,
      z: direction.z / distance
    };

    const newPosition = {
      x: this.position.x + normalizedDir.x * amount,
      y: this.position.y + normalizedDir.y * amount,
      z: this.position.z + normalizedDir.z * amount
    };

    this._smoothTransition(
      this.position,
      newPosition,
      duration
    );
  }

  // Orbit around target
  orbit(deltaX, deltaY) {
    const mode = this.modes.get(this.currentMode);
    if (!mode) return;

    let pitch = Math.atan2(
      this.position.y - this.target.y,
      Math.sqrt(
        (this.position.x - this.target.x) ** 2 +
        (this.position.z - this.target.z) ** 2
      )
    );

    let yaw = Math.atan2(
      this.position.z - this.target.z,
      this.position.x - this.target.x
    );

    pitch += deltaY * mode.rotationSpeed;
    yaw += deltaX * mode.rotationSpeed;

    pitch = Math.max(
      this.constraints.minPitch,
      Math.min(this.constraints.maxPitch, pitch)
    );

    const distance = Math.sqrt(
      (this.position.x - this.target.x) ** 2 +
      (this.position.y - this.target.y) ** 2 +
      (this.position.z - this.target.z) ** 2
    );

    this.position.x = this.target.x + distance * Math.cos(pitch) * Math.cos(yaw);
    this.position.y = this.target.y + distance * Math.sin(pitch);
    this.position.z = this.target.z + distance * Math.cos(pitch) * Math.sin(yaw);
  }

  // Apply screen shake
  shake(intensity = 1, duration = 500) {
    this.shake = {
      intensity,
      duration,
      startTime: Date.now()
    };
  }

  // Cinematic dolly
  dollyShot(startPos, endPos, duration = 3000, callback) {
    const startTime = Date.now();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);

      // Ease in/out
      const eased = progress < 0.5
        ? 2 * progress * progress
        : -1 + (4 - 2 * progress) * progress;

      this.position.x = startPos.x + (endPos.x - startPos.x) * eased;
      this.position.y = startPos.y + (endPos.y - startPos.y) * eased;
      this.position.z = startPos.z + (endPos.z - startPos.z) * eased;

      this._updateCamera();

      if (progress < 1) {
        requestAnimationFrame(animate);
      } else {
        callback?.();
      }
    };

    requestAnimationFrame(animate);
  }

  // Cinematic push in
  pushIn(distance = 5, duration = 2000) {
    const startPos = { ...this.position };
    const direction = {
      x: this.target.x - this.position.x,
      y: this.target.y - this.position.y,
      z: this.target.z - this.position.z
    };

    const len = Math.sqrt(
      direction.x * direction.x +
      direction.y * direction.y +
      direction.z * direction.z
    );

    const endPos = {
      x: startPos.x + (direction.x / len) * distance,
      y: startPos.y + (direction.y / len) * distance,
      z: startPos.z + (direction.z / len) * distance
    };

    this.dollyShot(startPos, endPos, duration);
  }

  // Cinematic pull back
  pullBack(distance = 5, duration = 2000) {
    const startPos = { ...this.position };
    const direction = {
      x: this.target.x - this.position.x,
      y: this.target.y - this.position.y,
      z: this.target.z - this.position.z
    };

    const len = Math.sqrt(
      direction.x * direction.x +
      direction.y * direction.y +
      direction.z * direction.z
    );

    const endPos = {
      x: startPos.x - (direction.x / len) * distance,
      y: startPos.y - (direction.y / len) * distance,
      z: startPos.z - (direction.z / len) * distance
    };

    this.dollyShot(startPos, endPos, duration);
  }

  // Rotate around target
  rotateAroundTarget(angle, duration = 2000) {
    const distance = Math.sqrt(
      (this.position.x - this.target.x) ** 2 +
      (this.position.y - this.target.y) ** 2 +
      (this.position.z - this.target.z) ** 2
    );

    const startAngle = Math.atan2(
      this.position.z - this.target.z,
      this.position.x - this.target.x
    );

    const endAngle = startAngle + angle;
    const startTime = Date.now();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const currentAngle = startAngle + (endAngle - startAngle) * progress;

      this.position.x = this.target.x + distance * Math.cos(currentAngle);
      this.position.z = this.target.z + distance * Math.sin(currentAngle);

      this._updateCamera();

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  }

  // Get camera info
  getInfo() {
    return {
      position: { ...this.position },
      target: { ...this.target },
      mode: this.currentMode,
      isTransitioning: this.isTransitioning,
      fov: this.camera.fov
    };
  }

  // Update camera
  update(deltaTime) {
    const mode = this.modes.get(this.currentMode);

    if (!mode) return;

    // Handle transition
    if (this.isTransitioning) {
      this._updateTransition();
    }

    // Follow object
    if (mode.followObject) {
      const obj = mode.followObject;
      this.target = { x: obj.x, y: obj.y, z: obj.z };

      const angle = (Date.now() % 10000) / 10000 * Math.PI * 2;
      this.position.x = obj.x + Math.cos(angle) * mode.followDistance;
      this.position.y = obj.y + mode.followHeight;
      this.position.z = obj.z + Math.sin(angle) * mode.followDistance;
    }

    // Apply shake
    if (this.shake.intensity > 0) {
      this._updateShake();
    }

    // Smooth movement
    this.position.x += this.velocity.x;
    this.position.y += this.velocity.y;
    this.position.z += this.velocity.z;

    this.velocity.x *= this.damping;
    this.velocity.y *= this.damping;
    this.velocity.z *= this.damping;

    this._updateCamera();
  }

  // Private: Update camera position and rotation
  _updateCamera() {
    if (this.camera.position) {
      this.camera.position.set(
        this.position.x,
        this.position.y,
        this.position.z
      );
    }

    if (this.camera.lookAt) {
      this.camera.lookAt(
        this.target.x,
        this.target.y,
        this.target.z
      );
    }
  }

  // Private: Update transition
  _updateTransition() {
    const elapsed = Date.now() - this.transitionStart;
    const progress = Math.min(elapsed / this.transitionDuration, 1);

    if (progress < 1) {
      // Interpolate position
      this.position.x = this.transitionStart.position.x +
        (this.transitionTarget.position.x - this.transitionStart.position.x) * progress;
      this.position.y = this.transitionStart.position.y +
        (this.transitionTarget.position.y - this.transitionStart.position.y) * progress;
      this.position.z = this.transitionStart.position.z +
        (this.transitionTarget.position.z - this.transitionStart.position.z) * progress;

      // Interpolate target
      this.target.x = this.transitionStart.target.x +
        (this.transitionTarget.target.x - this.transitionStart.target.x) * progress;
      this.target.y = this.transitionStart.target.y +
        (this.transitionTarget.target.y - this.transitionStart.target.y) * progress;
      this.target.z = this.transitionStart.target.z +
        (this.transitionTarget.target.z - this.transitionStart.target.z) * progress;

      // Interpolate FOV
      if (this.camera.fov) {
        this.camera.fov = this.transitionStart.fov +
          (this.transitionTarget.fov - this.transitionStart.fov) * progress;
        this.camera.updateProjectionMatrix?.();
      }
    } else {
      this.isTransitioning = false;
      this.position = { ...this.transitionTarget.position };
      this.target = { ...this.transitionTarget.target };
    }
  }

  // Private: Animate look at
  _animateLookAt(target, duration) {
    const startTime = Date.now();
    const startTarget = { ...this.target };

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);

      this.target.x = startTarget.x + (target.x - startTarget.x) * progress;
      this.target.y = startTarget.y + (target.y - startTarget.y) * progress;
      this.target.z = startTarget.z + (target.z - startTarget.z) * progress;

      this._updateCamera();

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  }

  // Private: Smooth transition between positions
  _smoothTransition(from, to, duration) {
    const startTime = Date.now();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);

      from.x += (to.x - from.x) * progress;
      from.y += (to.y - from.y) * progress;
      from.z += (to.z - from.z) * progress;

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  }

  // Private: Update shake effect
  _updateShake() {
    const elapsed = Date.now() - this.shake.startTime;

    if (elapsed < this.shake.duration) {
      const progress = 1 - (elapsed / this.shake.duration);
      const intensity = this.shake.intensity * progress;

      const shakeOffset = {
        x: (Math.random() - 0.5) * intensity,
        y: (Math.random() - 0.5) * intensity,
        z: (Math.random() - 0.5) * intensity
      };

      if (this.camera.position) {
        this.camera.position.x += shakeOffset.x;
        this.camera.position.y += shakeOffset.y;
        this.camera.position.z += shakeOffset.z;
      }
    } else {
      this.shake.intensity = 0;
    }
  }
}

export { CameraController };
