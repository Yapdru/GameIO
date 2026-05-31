let current=null;
const tracks={
  drive:'Michael Jackson - You Rock My World (Official Video - Shortened Version).mp3',
  elevator:'Kenny G - Songbird (Offiical Video).mp3',
  lobby:'Montagem Miau (Meow Meow Song).mp3'
};
export function playXP(name){
  try{
    if(current&&current.dataset.name===name)return;
    if(current){current.pause();current.currentTime=0;}
    current=new Audio(tracks[name]);
    current.dataset.name=name;
    current.loop=true;
    current.volume=name==='elevator'?0.45:0.6;
    current.play().catch(()=>{});
  }catch(e){}
}
window.playXP=playXP;
