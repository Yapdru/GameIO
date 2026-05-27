import * as THREE from 'https://unpkg.com/three@0.160.0/build/three.module.js';

let scene,camera,renderer,car,fishana,avatar,elevator,clock,mode='lobby',raf;
const mats={};
function mat(name,color,rough=.55){return mats[name]||(mats[name]=new THREE.MeshStandardMaterial({color,roughness:rough,metalness:.15}));}
function cube(w,h,d,m){const mesh=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),m);mesh.castShadow=true;mesh.receiveShadow=true;return mesh;}
function sphere(r,m){const mesh=new THREE.Mesh(new THREE.SphereGeometry(r,32,18),m);mesh.castShadow=true;mesh.receiveShadow=true;return mesh;}
function cyl(r,h,m){const mesh=new THREE.Mesh(new THREE.CylinderGeometry(r,r,h,32),m);mesh.castShadow=true;mesh.receiveShadow=true;return mesh;}
function group(...items){const g=new THREE.Group();items.forEach(x=>g.add(x));return g;}

function makeCar(){
  const body=cube(2.8,.55,1.25,mat('blue',0x0f8fe8));body.position.y=.45;
  const cabin=cube(1.15,.55,.95,mat('glass',0x9eeaff,.2));cabin.position.set(.25,.95,0);
  const nose=cube(1.0,.35,1.05,mat('blue2',0x19b7ff));nose.position.set(1.35,.38,0);
  const wheels=[];
  for(const x of[-.95,.95])for(const z of[-.72,.72]){const w=cyl(.28,.22,mat('black',0x111111));w.rotation.z=Math.PI/2;w.position.set(x,.2,z);wheels.push(w)}
  const g=group(body,cabin,nose,...wheels);g.userData.wheels=wheels;return g;
}
function makeAvatar(){
  const head=sphere(.34,mat('skin',0xffd6b5));head.position.y=1.75;
  const torso=cube(.75,1.0,.38,mat('shirt',0x18aee9));torso.position.y=1.05;
  const armL=cube(.22,.85,.22,mat('shirt',0x18aee9));armL.position.set(-.58,1.05,0);
  const armR=armL.clone();armR.position.x=.58;
  const legL=cube(.25,.85,.25,mat('pants',0x113a68));legL.position.set(-.22,.32,0);
  const legR=legL.clone();legR.position.x=.22;
  const g=group(head,torso,armL,armR,legL,legR);return g;
}
function makeFishana(){
  const body=sphere(.62,mat('fish',0x23d3ff));body.scale.set(1.55,.72,.82);
  const tail=new THREE.Mesh(new THREE.ConeGeometry(.45,.85,3),mat('fish'));tail.rotation.z=Math.PI/2;tail.position.x=-1.05;tail.castShadow=true;
  const eye=sphere(.08,mat('white',0xffffff));eye.position.set(.55,.15,.48);
  const pupil=sphere(.035,mat('black'));pupil.position.set(.6,.15,.54);
  return group(body,tail,eye,pupil);
}
function makeElevator(){
  const g=new THREE.Group();
  const floor=cube(2.8,.15,2.8,mat('liftFloor',0x5bdfff));floor.position.y=.08;
  const back=cube(2.8,2.7,.12,mat('liftWall',0xe9fbff));back.position.set(0,1.4,-1.35);
  const left=cube(.12,2.7,2.8,mat('liftWall'));left.position.set(-1.35,1.4,0);
  const right=left.clone();right.position.x=1.35;
  const doorL=cube(1.25,2.5,.1,mat('door',0x0f8fe8));doorL.position.set(-.65,1.35,1.35);
  const doorR=doorL.clone();doorR.position.x=.65;
  g.add(floor,back,left,right,doorL,doorR);g.userData={doorL,doorR};return g;
}
function makePortal(name,x,z,color){
  const ring=new THREE.Mesh(new THREE.TorusGeometry(.75,.07,16,64),mat('portal'+name,color));ring.position.set(x,1.1,z);ring.rotation.x=Math.PI/2;
  const base=cube(1.8,.12,1.8,mat('base'+name,color));base.position.set(x,.06,z);
  const label=document.createElement('div');
  return group(ring,base);
}
function clearDynamic(){[car,fishana,avatar,elevator].forEach(o=>{if(o)scene.remove(o)});car=fishana=avatar=elevator=null;}
function buildLobby(){clearDynamic();mode='lobby';avatar=makeAvatar();avatar.position.set(0,0,1.8);scene.add(avatar);elevator=makeElevator();elevator.position.set(0,0,-2.2);scene.add(elevator);scene.add(makePortal('fish',-3,-.8,0x23d3ff));scene.add(makePortal('cars',3,-.8,0x0f8fe8));scene.add(makePortal('cards',0,3,0xffd166));camera.position.set(0,4.2,7.2);camera.lookAt(0,1,0);}
function buildCars(){clearDynamic();mode='cars';car=makeCar();car.position.set(0,.15,0);scene.add(car);camera.position.set(0,3.2,6);camera.lookAt(car.position);}
function buildFishana(){clearDynamic();mode='fishana';fishana=makeFishana();fishana.position.set(0,1,0);scene.add(fishana);camera.position.set(0,3,6);camera.lookAt(fishana.position);}
function buildElevator(target='cars'){
  clearDynamic();mode='elevator';elevator=makeElevator();scene.add(elevator);avatar=makeAvatar();avatar.position.set(0,0,.35);scene.add(avatar);camera.position.set(0,2.3,5.2);camera.lookAt(0,1.2,0);let start=performance.now();
  const timer=setInterval(()=>{const t=(performance.now()-start)/1600; elevator.position.y=Math.min(4,t*4); if(elevator.userData.doorL){elevator.userData.doorL.position.x=-.65-Math.max(0,t-0.75)*2;elevator.userData.doorR.position.x=.65+Math.max(0,t-0.75)*2;} if(t>1.25){clearInterval(timer); target==='fishana'?buildFishana():buildCars();}},40);
}
function makeWorld(){
  scene=new THREE.Scene();scene.background=new THREE.Color(0xdffaff);clock=new THREE.Clock();
  camera=new THREE.PerspectiveCamera(60,innerWidth/innerHeight,.1,1000);
  renderer=new THREE.WebGLRenderer({antialias:true,alpha:false});renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,2));renderer.shadowMap.enabled=true;
  const hemi=new THREE.HemisphereLight(0xffffff,0x6fbad2,1.6);scene.add(hemi);
  const sun=new THREE.DirectionalLight(0xffffff,2);sun.position.set(4,8,5);sun.castShadow=true;scene.add(sun);
  const ground=new THREE.Mesh(new THREE.PlaneGeometry(60,60),new THREE.MeshStandardMaterial({color:0xbff4ff,roughness:.8}));ground.rotation.x=-Math.PI/2;ground.receiveShadow=true;scene.add(ground);
  const grid=new THREE.GridHelper(60,60,0x0f8fe8,0x7bdcff);grid.position.y=.01;scene.add(grid);
  window.addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);});
}
function animate(){raf=requestAnimationFrame(animate);const dt=clock.getDelta();if(car){car.rotation.y+=dt*.65;car.userData.wheels?.forEach(w=>w.rotation.x+=dt*8)}if(fishana){fishana.rotation.y+=dt*.9;fishana.position.y=1+Math.sin(performance.now()/280)*.15}if(avatar){avatar.rotation.y=Math.sin(performance.now()/900)*.25}renderer.render(scene,camera);}
export function startV8(container){if(!container)return;container.innerHTML='';makeWorld();container.appendChild(renderer.domElement);buildLobby();animate();return api;}
export const api={lobby:buildLobby,cars:()=>buildElevator('cars'),fishana:()=>buildElevator('fishana'),directCars:buildCars,directFishana:buildFishana};
window.GameIO3D={startV8,api};
