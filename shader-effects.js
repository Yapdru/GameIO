// Advanced Shader Effects System
// Custom shaders and post-processing effects for Three.js

class ShaderEffectsManager {
  constructor(scene, renderer) {
    this.scene = scene;
    this.renderer = renderer;
    this.shaders = new Map();
    this.effects = new Map();
    this.renderTargets = [];
  }

  // Register custom shader
  registerShader(name, config = {}) {
    const {
      vertexShader = this._getDefaultVertexShader(),
      fragmentShader = this._getDefaultFragmentShader(),
      uniforms = {},
      transparent = false,
      side = THREE.FrontSide
    } = config;

    const material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        ...uniforms,
        iTime: { value: 0 },
        iResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) }
      },
      transparent,
      side
    });

    this.shaders.set(name, {
      name,
      material,
      vertexShader,
      fragmentShader,
      uniforms
    });

    return material;
  }

  // Get shader by name
  getShader(name) {
    return this.shaders.get(name);
  }

  // Update shader uniform
  updateUniform(shaderName, uniformName, value) {
    const shader = this.shaders.get(shaderName);
    if (shader && shader.material.uniforms[uniformName]) {
      shader.material.uniforms[uniformName].value = value;
    }
  }

  // Create glow effect shader
  createGlowShader() {
    const glowShader = {
      vertexShader: `
        varying vec3 vNormal;
        varying vec3 vPosition;

        void main() {
          vNormal = normalize(normalMatrix * normal);
          vPosition = position;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform float uGlowStrength;
        varying vec3 vNormal;
        varying vec3 vPosition;

        void main() {
          vec3 normal = normalize(vNormal);
          vec3 viewDir = normalize(cameraPosition - vPosition);
          float fresnel = pow(1.0 - dot(normal, viewDir), 3.0);
          gl_FragColor = vec4(vec3(1.0) * fresnel * uGlowStrength, fresnel);
        }
      `,
      uniforms: {
        uGlowStrength: { value: 2.0 }
      }
    };

    return this.registerShader('glow', glowShader);
  }

  // Create hologram shader
  createHologramShader() {
    const hologramShader = {
      vertexShader: `
        varying vec3 vPosition;
        varying vec3 vNormal;

        void main() {
          vPosition = position;
          vNormal = normalize(normalMatrix * normal);
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform float iTime;
        varying vec3 vPosition;
        varying vec3 vNormal;

        void main() {
          float scan = sin(vPosition.y * 10.0 + iTime * 5.0) * 0.5 + 0.5;
          vec3 color = vec3(0.0, 1.0, 0.8);
          float alpha = scan * 0.7;
          gl_FragColor = vec4(color, alpha);
        }
      `,
      uniforms: {}
    };

    return this.registerShader('hologram', hologramShader);
  }

  // Create wave distortion shader
  createWaveShader() {
    const waveShader = {
      vertexShader: `
        uniform float iTime;
        varying vec2 vUv;

        void main() {
          vUv = uv;
          vec3 pos = position;
          pos.y += sin(pos.x * 3.0 + iTime) * 0.1;
          pos.z += cos(pos.x * 3.0 + iTime) * 0.1;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
        }
      `,
      fragmentShader: `
        varying vec2 vUv;

        void main() {
          vec3 color = vec3(vUv, 0.5);
          gl_FragColor = vec4(color, 1.0);
        }
      `,
      uniforms: {}
    };

    return this.registerShader('wave', waveShader);
  }

  // Create thermal vision shader
  createThermalVisionShader() {
    const thermalShader = {
      vertexShader: `
        varying vec3 vPosition;
        void main() {
          vPosition = position;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform sampler2D tDiffuse;
        varying vec3 vPosition;

        void main() {
          // Thermal vision: red hot, blue cold
          float temp = (vPosition.y + 1.0) / 2.0;
          vec3 color;

          if (temp < 0.5) {
            color = mix(vec3(0.0, 0.0, 1.0), vec3(1.0, 1.0, 0.0), temp * 2.0);
          } else {
            color = mix(vec3(1.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), (temp - 0.5) * 2.0);
          }

          gl_FragColor = vec4(color, 1.0);
        }
      `,
      uniforms: {}
    };

    return this.registerShader('thermal', thermalShader);
  }

  // Create chromatic aberration shader
  createChromaticAberrationShader() {
    const chromaticShader = {
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform sampler2D tDiffuse;
        uniform float uAmount;
        varying vec2 vUv;

        void main() {
          vec2 offset = uAmount * vec2(cos(vUv.y * 100.0), sin(vUv.x * 100.0));

          float r = texture2D(tDiffuse, vUv + offset).r;
          float g = texture2D(tDiffuse, vUv).g;
          float b = texture2D(tDiffuse, vUv - offset).b;

          gl_FragColor = vec4(r, g, b, 1.0);
        }
      `,
      uniforms: {
        uAmount: { value: 0.005 }
      }
    };

    return this.registerShader('chromatic', chromaticShader);
  }

  // Create ink/toon shader
  createToonShader() {
    const toonShader = {
      vertexShader: `
        varying vec3 vNormal;
        varying vec3 vPosition;

        void main() {
          vNormal = normalize(normalMatrix * normal);
          vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform vec3 uColor;
        varying vec3 vNormal;
        varying vec3 vPosition;

        void main() {
          vec3 normal = normalize(vNormal);
          vec3 light = normalize(vec3(1.0, 1.0, 1.0));

          float diff = dot(normal, light);
          diff = step(0.3, diff);

          vec3 viewDir = normalize(-vPosition);
          vec3 halfDir = normalize(light + viewDir);
          float spec = dot(normal, halfDir);
          spec = step(0.7, spec);

          vec3 color = uColor * (0.5 + diff * 0.5) + vec3(1.0) * spec * 0.5;
          gl_FragColor = vec4(color, 1.0);
        }
      `,
      uniforms: {
        uColor: { value: new THREE.Color(0x00ff00) }
      }
    };

    return this.registerShader('toon', toonShader);
  }

  // Create scanline shader
  createScanlineShader() {
    const scanlineShader = {
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform float iTime;
        uniform sampler2D tDiffuse;
        varying vec2 vUv;

        void main() {
          vec4 color = texture2D(tDiffuse, vUv);

          float scanline = sin(vUv.y * 100.0 + iTime * 10.0) * 0.1 + 0.9;
          float flicker = sin(iTime * 5.0) * 0.05 + 0.95;

          gl_FragColor = color * vec4(vec3(scanline * flicker), 1.0);
        }
      `,
      uniforms: {}
    };

    return this.registerShader('scanline', scanlineShader);
  }

  // Update time uniforms for all shaders
  updateTime(time) {
    this.shaders.forEach(shader => {
      if (shader.material.uniforms.iTime) {
        shader.material.uniforms.iTime.value = time;
      }
    });
  }

  // Private helper methods

  _getDefaultVertexShader() {
    return `
      varying vec3 vNormal;
      varying vec3 vPosition;

      void main() {
        vNormal = normalize(normalMatrix * normal);
        vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `;
  }

  _getDefaultFragmentShader() {
    return `
      varying vec3 vNormal;
      varying vec3 vPosition;

      void main() {
        vec3 normal = normalize(vNormal);
        vec3 light = normalize(vec3(1.0, 1.0, 1.0));
        float diff = max(dot(normal, light), 0.0);
        vec3 color = vec3(0.5) * (0.5 + diff * 0.5);
        gl_FragColor = vec4(color, 1.0);
      }
    `;
  }
}

export { ShaderEffectsManager };
