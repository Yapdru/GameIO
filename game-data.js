export const GAME_DATA = {
  hub:{icon:'🏠',name:'GameIO Social Hub',code:['HUB'],mode:'hub',world:'hub'},
  fishana:{icon:'🎣',name:'Fishana Evolution',code:['FISH','FIN','BUB','WAVE'],mode:'world',world:'ocean'},
  cars:{icon:'🏎️',name:'Cars Horizon Sim',code:['CAR','RACE','DRFT'],mode:'world',world:'road'},
  rally:{icon:'🚙',name:'Rally Mud Run',code:['RALLY','MUD'],mode:'world',world:'rally'},
  gt:{icon:'🏁',name:'GT Track Sprint',code:['GT','TRACK'],mode:'world',world:'gt'},
  kart:{icon:'🏎️',name:'Kart Chaos',code:['KART'],mode:'world',world:'kart'},
  badamsat:{icon:'🃏',name:'Badaam Saat Table',code:['BADM','SAT','ALM'],mode:'cards',table:['6♥','7♥','8♥'],hand:['5♥','9♥','7♣','7♦','8♣','6♦']},
  cardrush:{icon:'♦️',name:'Card Rush',code:['CARD','RUSH'],mode:'cards',table:['7♦','8♦','9♦'],hand:['6♦','10♦','7♠','8♣','9♥']},
  npat:{icon:'📝',name:'NPAT Arena',code:['NPAT','WORD'],mode:'quiz',q:'Letter D — Name, Place, Animal, Thing',a:['Dhruv Delhi Dog Drum','Dino Dubai Deer Door','Duck Delhi Deer Door','Fish Answer']},
  charades:{icon:'🎭',name:'Charades',code:['CHAR','ACT'],mode:'quiz',q:'Act like a T-Rex stuck in traffic',a:['Roar','Tiny arms','Freeze','Dance']},
  bluff:{icon:'🃏',name:'Bluff',code:['BLUF','CARD'],mode:'quiz',q:'Someone claims three kings',a:['Call bluff','Believe','Raise','Stare']},
  funnyai:{icon:'😂',name:'Funny AI',code:['LOL','MEME'],mode:'quiz',q:'AI says it is totally normal',a:['Roast it','Trust it','Ask joke','Run']},
  riddle:{icon:'❓',name:'Riddle Run',code:['RIDL'],mode:'quiz',q:'I have cities but no houses',a:['Map','Cloud','Shoe','Fish']},
  mathdash:{icon:'➕',name:'Math Dash',code:['MATH'],mode:'quiz',q:'5 + 7 = ?',a:['12','10','57','Fish']},
  spacedash:{icon:'🚀',name:'Space Dash',code:['SPACE'],mode:'world',world:'space'},
  dino:{icon:'🦖',name:'Dino Escape',code:['DINO'],mode:'world',world:'dino'},
  dragon:{icon:'🐉',name:'Dragon Dodge',code:['DRGN'],mode:'world',world:'dragon'},
  ice:{icon:'🧊',name:'Ice Drift',code:['ICE'],mode:'world',world:'ice'},
  lava:{icon:'🌋',name:'Lava Floor',code:['LAVA'],mode:'world',world:'lava'},
  obby:{icon:'🧗',name:'Sky Obby Run',code:['OBBY'],mode:'world',world:'obby'},
  arena:{icon:'⚔️',name:'Arena Dash',code:['ARENA'],mode:'world',world:'arena'}
};

export const AVATAR_PARTS={
  face:['😎','🐟','🏎️','🚙','🤖','🧑‍🚀','🦖','🦸','🐱','🐼','🐉','🦈','🚀','🧑'],
  body:['🧊','🧥','🦺','🛡️','🎽','🚀','🏁','🧍'],
  acc:['⚡','👑','🎧','💎','🔥','⭐','🏆','🪽']
};

export function defaultOrder(){return ['hub','fishana','cars','badamsat','npat','rally','spacedash','dino'];}
export function megaOrder(){return Object.keys(GAME_DATA);}
export function racingOrder(){return ['hub','cars','rally','gt','kart','ice'];}
export function socialOrder(){return ['hub','fishana','obby','arena','badamsat','charades'];}
