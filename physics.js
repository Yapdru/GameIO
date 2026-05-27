export function makeVehicle(){
  return { x:160, y:280, angle:0, speed:0, lap:1, score:0, pearls:0, evolution:0, finished:false };
}

export function worldGrip(world){
  if(world === 'ice') return 0.50;
  if(world === 'rally') return 0.55;
  if(world === 'desert') return 0.58;
  if(world === 'road') return 0.82;
  if(world === 'gt') return 0.88;
  if(world === 'kart') return 0.76;
  if(world === 'ocean') return 0.66;
  if(world === 'moon') return 0.42;
  return 0.70;
}

export function updateVehicle(v,input,world){
  const grip = worldGrip(world);
  if(input.throttle) v.speed += 0.24;
  if(input.brake) v.speed -= 0.36;
  if(!input.throttle && !input.brake) v.speed *= 0.985;
  if(input.boost) v.speed += 0.45;
  v.speed = Math.max(-3.5, Math.min(9.5, v.speed));
  const steer = 0.048 * Math.min(1, Math.abs(v.speed)/4 + 0.25);
  if(input.left) v.angle -= steer;
  if(input.right) v.angle += steer;
  const drift = (1 - grip) * v.speed * 0.32 * (input.left ? -1 : input.right ? 1 : 0);
  v.x += Math.cos(v.angle) * v.speed + Math.cos(v.angle + Math.PI/2) * drift;
  v.y += Math.sin(v.angle) * v.speed + Math.sin(v.angle + Math.PI/2) * drift;
  if(v.x > 980){ v.x = 80; v.lap += 1; v.score += 100; }
  if(v.x < 35) v.x = 35;
  if(v.y < 55) v.y = 55;
  if(v.y > 560) v.y = 560;
  if(v.lap > 3) v.finished = true;
}

export function hit(a,b,r=35){
  return Math.hypot(a.x-b.x, a.y-b.y) < r;
}
