export const GAME_DATA = {
  hub:{icon:'🏠',name:'GameIO Social Hub',code:['HUB'],mode:'hub',world:'hub',desc:'Chill in the lobby, chat with friends, and prep for games'},
  fishana:{icon:'🎣',name:'Fishana Evolution',code:['FISH','FIN','BUB','WAVE'],mode:'world',world:'ocean'},
  cars:{icon:'🏎️',name:'Cars Horizon Sim',code:['CAR','RACE','DRFT'],mode:'world',world:'road'},
  rally:{icon:'🚙',name:'Rally Mud Run',code:['RALLY','MUD'],mode:'world',world:'rally'},
  gt:{icon:'🏁',name:'GT Track Sprint',code:['GT','TRACK'],mode:'world',world:'gt'},
  kart:{icon:'🏎️',name:'Kart Chaos',code:['KART'],mode:'world',world:'kart'},
  badamsat:{icon:'🃏',name:'Badaam Saat Table',code:['BADM','SAT','ALM'],mode:'cards',table:['6♥','7♥','8♥'],hand:['5♥','9♥','7♣','7♦','8♣','6♦']},
  cardrush:{icon:'♦️',name:'Card Rush',code:['CARD','RUSH'],mode:'cards',table:['7♦','8♦','9♦'],hand:['6♦','10♦','7♠','8♣','9♥']},
  npat:{icon:'📝',name:'Name Place Animal Thing',code:['NPAT','WORD'],mode:'quiz',q:'Letter D — Name, Place, Animal, Thing',a:['Dhruv Delhi Dog Drum','Dino Dubai Deer Door','Duck Delhi Deer Door','Donkey Denmark Dragonfruit']},
  charades:{icon:'🎭',name:'Charades Challenge',code:['CHAR','ACT'],mode:'quiz',q:'Act like a T-Rex stuck in traffic',a:['Roar & rage','Tiny arms','Freeze frame','Wild dance']},
  bluff:{icon:'🃏',name:'Bluff Master',code:['BLUF','CARD'],mode:'quiz',q:'Someone claims three kings in hand',a:['Call bluff!','Believe them','Raise stake','Ask again']},
  funnyai:{icon:'😂',name:'Funny AI Chat',code:['LOL','MEME'],mode:'quiz',q:'AI says: "I am definitely human"',a:['Roast it','Trust blindly','Ask joke','Run away']},
  riddle:{icon:'❓',name:'Riddle Run',code:['RIDL'],mode:'quiz',q:'I have cities but no houses',a:['Map','Cloud','Shoe','Fish']},
  mathdash:{icon:'➕',name:'Math Dash',code:['MATH'],mode:'quiz',q:'5 + 7 = ?',a:['12','10','57','99']},
  character:{icon:'🎪',name:'Character Guessing',code:['CHAR','GUESS'],mode:'quiz',q:'Movie character who says "I am Batman"',a:['Batman','Superman','Spiderman','Iron Man']},
  facetalk:{icon:'🎤',name:'FaceTalk Duel',code:['FACE','TALK'],mode:'quiz',q:'Make the silliest face at camera',a:['Maximum silliness','Balance cuteness','Go full comedy','Stay cool']},
  spacedash:{icon:'🚀',name:'Space Dash',code:['SPACE'],mode:'world',world:'space'},
  dino:{icon:'🦖',name:'Dino Escape',code:['DINO'],mode:'world',world:'dino'},
  dragon:{icon:'🐉',name:'Dragon Dodge',code:['DRGN'],mode:'world',world:'dragon'},
  ice:{icon:'🧊',name:'Ice Drift',code:['ICE'],mode:'world',world:'ice'},
  lava:{icon:'🌋',name:'Lava Floor',code:['LAVA'],mode:'world',world:'lava'},
  obby:{icon:'🧗',name:'Sky Obby Run',code:['OBBY'],mode:'world',world:'obby'},
  arena:{icon:'⚔️',name:'Arena Dash',code:['ARENA'],mode:'world',world:'arena'},
  zombie:{icon:'🧟',name:'Zombie Survival',code:['ZOMBIE'],mode:'world',world:'zombie'},
  cyber:{icon:'🤖',name:'Cyber Speedrun',code:['CYBER'],mode:'world',world:'cyber'},
  volcano:{icon:'🌋',name:'Volcano Run',code:['VOLC'],mode:'world',world:'volcano'}
};

export const AVATAR_PARTS={
  face:['😎','🐟','🏎️','🚙','🤖','🧑‍🚀','🦖','🦸','🐱','🐼','🐉','🦈','🚀','🧑','👽','🤠','🧛','🧞','🧌','🤡','👹','🦁','🐯','🐻','🦊','🦝','🐨','🐸','🦗','🦗','🦎','🦖','🦕','🐢','🐍','🦗','🦟','🦗'],
  body:['🧊','🧥','🦺','🛡️','🎽','🚀','🏁','🧍','👔','🥻','👕','🩳','🧦','🧤','🧣','👘','🥼','🥽','⛑️','💼','🎓','👑'],
  acc:['⚡','👑','🎧','💎','🔥','⭐','🏆','🪽','🎖️','🏅','📿','💍','⌚','🕶️','🥿','👟','👞','👠','💄','💋','👄','👃','👂','👁️','🧠','❤️','💙','💚','💛']
};

export const QUIZ_QUESTIONS={
  npat:[
    {q:'Letter A - Name, Place, Animal, Thing',a:['Arjun, America, Ant, Apple','Alex, Africa, Albatross, Armor','Andrew, Australia, Aardvark, Anchor','Arthur, Austria, Antelope, Arrow']},
    {q:'Letter P - Name, Place, Animal, Thing',a:['Priya, Paris, Parrot, Pencil','Peter, Prague, Penguin, Pizza','Paul, Portugal, Pig, Plate','Patrick, Poland, Panda, Pen']},
  ],
  charades:[
    {q:'Act like a zombie at a wedding',a:['Groaning stiff','Confused dancing','Eating cake messily','Slow walk']},
    {q:'Act like you just won the lottery',a:['Jump & scream','Cry happy tears','Do a victory dance','Hug everyone']},
  ],
  character:[
    {q:'Movie character: "May the Force be with you"',a:['Yoda','Darth Vader','Luke Skywalker','Obi-Wan Kenobi']},
    {q:'Movie character: "Here\'s looking at you, kid"',a:['Casablanca','Titanic','Godfather','Pulp Fiction']},
  ],
  facetalk:[
    {q:'Make the silliest expression possible',a:['Max silliness','Cute factor','Comedy gold','Ultra cool']},
    {q:'Mimic a surprised celebrity',a:['Shocked face','Jaw drop','Wide eyes','Eyebrow wiggle']},
  ],
  bluff:[
    {q:'Player claims: "I have all 4 aces"',a:['Call bluff!','Believe totally','Raise bet','Ask questions']},
  ],
  funnyai:[
    {q:'AI says: "I definitely need coffee"',a:['Roast it hard','Believe it','Laugh together','Run away']},
  ],
};

export function getRandomQuestion(gameKey){const questions=QUIZ_QUESTIONS[gameKey]||[];return questions.length>0?questions[Math.floor(Math.random()*questions.length)]:{q:'Ready to play?',a:['Yes!','Absolutely!','Let\'s go!','More!']};};

export function defaultOrder(){return ['hub','fishana','cars','badamsat','npat','charades','character','facetalk','spacedash','dino'];}
export function megaOrder(){const keys=Object.keys(GAME_DATA);return keys.filter(k=>k!=='hub').sort(()=>Math.random()-.5);}
export function racingOrder(){return ['hub','cars','rally','gt','kart','ice','cyber','volcano'];}
export function socialOrder(){return ['hub','fishana','obby','arena','badamsat','charades','character','facetalk','bluff','funnyai'];}
