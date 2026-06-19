/* ============================================================
   Famous Fashion – Spiel-Logik
   Ablauf einer Runde:
     1. Lobby (30 Sek. warten, bis 12 Teilnehmerinnen da sind)
     2. Thema wird verkündet
     3. Umkleide: Outfit zum Thema zusammenstellen
     4. Voting: alle bewerten sich gegenseitig mit bis zu 5 Sternen
     5. Siegerehrung: Top 3 + deine Platzierung
   Du spielst gegen 11 vom Computer gesteuerte Mitspielerinnen.
   ============================================================ */

"use strict";

const $ = (id) => document.getElementById(id);

// ---- Einstellungen (hier kannst du Zeiten ändern) ----
const CONFIG = {
  totalPlayers: 12,
  lobbySeconds: 30,
  stylingSeconds: 90,
};

// ---- Mädchen-Namen für die Mitspielerinnen ----
const NAMES = [
  "Mia", "Emma", "Lina", "Hannah", "Lea", "Marie", "Lara", "Sophie",
  "Clara", "Anna", "Nele", "Leonie", "Zoe", "Ella", "Maja", "Frieda",
  "Ida", "Pia", "Romy", "Greta", "Luisa", "Mila",
];

// ---- Themen. "tags" = welche Stile zum Thema passen. ----
const THEMES = [
  { name: "Sommer am Strand", emoji: "🏖️", tags: ["sommer", "casual"] },
  { name: "Elegante Gala",    emoji: "💎", tags: ["elegant", "party"] },
  { name: "Winter-Zauber",    emoji: "❄️", tags: ["winter", "elegant"] },
  { name: "Sport & Action",   emoji: "🏃‍♀️", tags: ["sport", "casual"] },
  { name: "Party-Nacht",      emoji: "🎉", tags: ["party", "elegant"] },
  { name: "Schultag",         emoji: "🎒", tags: ["casual", "sport"] },
];

// ---- Garderobe. Jedes Teil hat "tags" (zu welchem Stil es passt). ----
const CATALOG = {
  hair: [
    { id: "h1", name: "Lange Locken", color: "#5b3a29", tags: ["elegant", "party"] },
    { id: "h2", name: "Blonder Zopf", color: "#e6c27a", tags: ["casual", "sport"] },
    { id: "h3", name: "Pink Bob",     color: "#ff69b4", tags: ["party"] },
    { id: "h4", name: "Schwarz glatt", color: "#2b2b2b", tags: ["elegant", "winter"] },
    { id: "h5", name: "Braune Wellen", color: "#7a4a2b", tags: ["sommer", "casual"] },
    { id: "h6", name: "Rote Mähne",   color: "#b5482e", tags: ["party", "sommer"] },
  ],
  makeup: [
    { id: "m0", name: "Natürlich", blush: true,  lip: "#d98d8d", tags: ["casual", "sommer", "sport"] },
    { id: "m1", name: "Glamour",   blush: true,  lip: "#c41e5a", tags: ["party", "elegant"] },
    { id: "m2", name: "Rote Lippen", blush: false, lip: "#e2243b", tags: ["elegant", "party"] },
    { id: "m3", name: "Frisch",    blush: true,  lip: "#e98aa0", tags: ["sommer", "casual"] },
    { id: "m4", name: "Ohne",      blush: false, lip: null,      tags: ["sport"] },
  ],
  top: [
    { id: "t1", name: "T-Shirt",   emoji: "👕", color: "#6ec6ff", tags: ["casual", "sommer", "sport"] },
    { id: "t2", name: "Pullover",  emoji: "🧥", color: "#c8a2c8", tags: ["winter", "casual"] },
    { id: "t3", name: "Glitzer-Top", emoji: "✨", color: "#ffd700", tags: ["party", "elegant"] },
    { id: "t4", name: "Bluse",     emoji: "👚", color: "#ffffff", tags: ["elegant", "casual"] },
    { id: "t5", name: "Sport-Top", emoji: "🎽", color: "#ff6b6b", tags: ["sport"] },
    { id: "t6", name: "Bikini-Top", emoji: "👙", color: "#ff9ecd", tags: ["sommer"] },
  ],
  bottom: [
    { id: "b1", name: "Jeans",      type: "pants", color: "#3b5b92", tags: ["casual", "sport"] },
    { id: "b2", name: "Rock",       type: "skirt", color: "#ff8fab", tags: ["casual", "sommer"] },
    { id: "b3", name: "Abendkleid", type: "dress", color: "#7b1fa2", tags: ["elegant", "party"] },
    { id: "b4", name: "Sommerkleid", type: "dress", color: "#ffd166", tags: ["sommer", "casual"] },
    { id: "b5", name: "Leggings",   type: "pants", color: "#2b2b2b", tags: ["sport", "winter"] },
    { id: "b6", name: "Glitzerkleid", type: "dress", color: "#e91e9c", tags: ["party", "elegant"] },
    { id: "b7", name: "Warmer Rock", type: "skirt", color: "#8d6e63", tags: ["winter"] },
  ],
  shoes: [
    { id: "s1", name: "Sneaker",    color: "#ffffff", tags: ["casual", "sport"] },
    { id: "s2", name: "High Heels", color: "#c2185b", tags: ["elegant", "party"] },
    { id: "s3", name: "Sandalen",   color: "#ffcc80", tags: ["sommer", "casual"] },
    { id: "s4", name: "Stiefel",    color: "#4e342e", tags: ["winter", "elegant"] },
    { id: "s5", name: "Ballerinas", color: "#f48fb1", tags: ["casual", "elegant"] },
  ],
  bag: [
    { id: "g1", name: "Handtasche", emoji: "👜", tags: ["elegant", "casual"] },
    { id: "g2", name: "Clutch",     emoji: "👝", tags: ["party", "elegant"] },
    { id: "g3", name: "Rucksack",   emoji: "🎒", tags: ["sport", "casual"] },
    { id: "g4", name: "Strandtasche", emoji: "🧺", tags: ["sommer"] },
    { id: "g5", name: "Keine",      emoji: "🚫", tags: [] },
  ],
};

// Reihenfolge & Anzeige der Kategorien in der Umkleide.
const CATEGORIES = [
  { id: "hair",   name: "Haare",    icon: "💇‍♀️" },
  { id: "makeup", name: "Make-up",  icon: "💄" },
  { id: "top",    name: "Oberteil", icon: "👕" },
  { id: "bottom", name: "Kleid/Hose", icon: "👗" },
  { id: "shoes",  name: "Schuhe",   icon: "👟" },
  { id: "bag",    name: "Tasche",   icon: "👜" },
];

// ============================================================
// Spielzustand
// ============================================================
const state = {
  theme: null,
  contestants: [], // { name, outfit, base, isPlayer }
  activeCategory: "hair",
  playerRatings: {}, // { contestantIndex: sterne }
  timers: { lobby: null, styling: null },
};

const player = () => state.contestants[0];

// ============================================================
// Hilfsfunktionen
// ============================================================
function rand(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function shuffle(arr) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}
function clamp(n, lo, hi) { return Math.max(lo, Math.min(hi, n)); }

function showScreen(id) {
  document.querySelectorAll(".screen").forEach((s) => s.classList.remove("active"));
  $(id).classList.add("active");
}

// Wie gut passt ein Outfit zum Thema? Liefert 0..1.
function themeMatch(outfit) {
  const wanted = state.theme.tags;
  let matched = 0, counted = 0;
  for (const cat of CATEGORIES) {
    const item = outfit[cat.id];
    if (!item || !item.tags || item.tags.length === 0) continue;
    counted++;
    if (item.tags.some((t) => wanted.includes(t))) matched++;
  }
  return counted === 0 ? 0 : matched / counted;
}

// Bewertung (Sterne 1..5) einer Outfit-Qualität, mit etwas Zufall.
function judgeStars(base) {
  const jitter = (Math.random() - 0.5) * 2.2;
  return clamp(Math.round(base + jitter), 1, 5);
}

// ============================================================
// Mitspielerinnen (Computer) erstellen
// ============================================================
function autoStyle(skill) {
  // skill 0..1: höher = wählt öfter passende Teile.
  const outfit = {};
  for (const cat of CATEGORIES) {
    const items = CATALOG[cat.id];
    if (Math.random() < skill) {
      // Passendes Teil bevorzugen.
      const good = items.filter((i) => i.tags.some((t) => state.theme.tags.includes(t)));
      outfit[cat.id] = good.length ? rand(good) : rand(items);
    } else {
      outfit[cat.id] = rand(items);
    }
  }
  return outfit;
}

function createContestants() {
  const names = shuffle(NAMES).slice(0, CONFIG.totalPlayers - 1);
  // Index 0 = du (noch ohne Outfit), 1.. = Computer-Mitspielerinnen.
  state.contestants = [{ name: "Du", outfit: {}, isPlayer: true }];
  for (const name of names) {
    const skill = 0.35 + Math.random() * 0.6; // unterschiedlich gut
    const outfit = autoStyle(skill);
    state.contestants.push({ name, outfit, isPlayer: false });
  }
}

// ============================================================
// 1) LOBBY
// ============================================================
function startLobby() {
  showScreen("screen-lobby");
  $("lobby-avatars").innerHTML = "";
  let current = 1;
  let secs = CONFIG.lobbySeconds;
  $("lobby-current").textContent = current;
  $("lobby-timer").textContent = secs;
  addLobbyAvatar("🙋‍♀️"); // du

  const faces = ["👧", "👩", "🧑‍🦰", "👱‍♀️", "👩‍🦱", "👩‍🦳"];
  clearInterval(state.timers.lobby);
  state.timers.lobby = setInterval(() => {
    secs--;
    $("lobby-timer").textContent = Math.max(0, secs);

    // Nach und nach füllen sich die Plätze bis 12.
    if (current < CONFIG.totalPlayers && Math.random() < 0.7) {
      current++;
      $("lobby-current").textContent = current;
      addLobbyAvatar(rand(faces));
    }

    if (secs <= 0) {
      // Falls noch nicht voll: Rest sofort auffüllen.
      while (current < CONFIG.totalPlayers) {
        current++;
        addLobbyAvatar(rand(faces));
      }
      $("lobby-current").textContent = current;
      clearInterval(state.timers.lobby);
      revealTheme();
    }
  }, 1000);
}

function addLobbyAvatar(emoji) {
  const d = document.createElement("div");
  d.className = "pa";
  d.textContent = emoji;
  $("lobby-avatars").appendChild(d);
}

// ============================================================
// 2) THEMA
// ============================================================
function revealTheme() {
  state.theme = rand(THEMES);
  createContestants();

  showScreen("screen-theme");
  $("theme-emoji").textContent = state.theme.emoji;
  $("theme-name").textContent = state.theme.name;
  $("theme-hint").textContent = "Stelle ein Outfit zusammen, das dazu passt!";

  setTimeout(startStyling, 3500);
}

// ============================================================
// 3) UMKLEIDE / STYLING
// ============================================================
function startStyling() {
  showScreen("screen-styling");
  $("styling-theme-emoji").textContent = state.theme.emoji;
  $("styling-theme-name").textContent = state.theme.name;

  // Start-Outfit: erstes Teil jeder Kategorie.
  for (const cat of CATEGORIES) {
    player().outfit[cat.id] = CATALOG[cat.id][0];
  }
  state.activeCategory = "hair";
  renderTabs();
  renderItems();
  renderDoll($("preview-doll"), player().outfit);

  // Timer
  let secs = CONFIG.stylingSeconds;
  updateStylingTimer(secs);
  clearInterval(state.timers.styling);
  state.timers.styling = setInterval(() => {
    secs--;
    updateStylingTimer(secs);
    if (secs <= 0) {
      clearInterval(state.timers.styling);
      startVoting();
    }
  }, 1000);
}

function updateStylingTimer(secs) {
  secs = Math.max(0, secs);
  const m = Math.floor(secs / 60);
  const s = String(secs % 60).padStart(2, "0");
  $("styling-timer").textContent = `${m}:${s}`;
}

function renderTabs() {
  const box = $("wardrobe-tabs");
  box.innerHTML = "";
  for (const cat of CATEGORIES) {
    const b = document.createElement("button");
    b.className = "tab" + (cat.id === state.activeCategory ? " active" : "");
    b.innerHTML = `${cat.icon} ${cat.name}`;
    b.onclick = () => { state.activeCategory = cat.id; renderTabs(); renderItems(); };
    box.appendChild(b);
  }
}

function renderItems() {
  const box = $("wardrobe-items");
  box.innerHTML = "";
  const cat = state.activeCategory;
  const selected = player().outfit[cat];
  for (const item of CATALOG[cat]) {
    const el = document.createElement("div");
    el.className = "item" + (selected && selected.id === item.id ? " selected" : "");

    // Vorschau: Farbkreis oder Emoji.
    let visual;
    if (item.emoji) {
      visual = `<div class="em">${item.emoji}</div>`;
    } else {
      visual = `<div class="swatch" style="background:${item.color || item.lip || "#ccc"}"></div>`;
    }
    el.innerHTML = `${visual}<div class="nm">${item.name}</div>`;
    el.onclick = () => {
      player().outfit[cat] = item;
      renderItems();
      renderDoll($("preview-doll"), player().outfit);
    };
    box.appendChild(el);
  }
}

// Zeichnet das Mode-Püppchen aus einem Outfit.
function renderDoll(container, outfit) {
  const hair = outfit.hair, makeup = outfit.makeup, top = outfit.top,
        bottom = outfit.bottom, shoes = outfit.shoes, bag = outfit.bag;

  let html = "";
  if (hair) html += `<div class="hair" style="background:${hair.color}"></div>`;
  html += `<div class="head"></div>`;
  html += `<div class="eyes">••</div>`;
  if (makeup && makeup.blush) {
    html += `<div class="blush l"></div><div class="blush r"></div>`;
  }
  if (makeup && makeup.lip) {
    html += `<div class="lips" style="background:${makeup.lip}"></div>`;
  }

  // Kleid überdeckt Oberteil + Unterteil.
  if (bottom && bottom.type === "dress") {
    html += `<div class="dress" style="background:${bottom.color}"></div>`;
  } else {
    if (top) html += `<div class="torso" style="background:${top.color}"></div>`;
    if (bottom && bottom.type === "skirt") {
      html += `<div class="skirt" style="background:${bottom.color}"></div>`;
    } else if (bottom) {
      html += `<div class="legs" style="background:${bottom.color}"></div>`;
    }
  }

  if (shoes) html += `<div class="shoes"><span style="background:${shoes.color}"></span><span style="background:${shoes.color}"></span></div>`;
  if (bag && bag.emoji && bag.emoji !== "🚫") html += `<div class="bag">${bag.emoji}</div>`;

  container.innerHTML = html;
}

$("btn-done").onclick = () => {
  clearInterval(state.timers.styling);
  startVoting();
};

// ============================================================
// 4) VOTING
// ============================================================
function startVoting() {
  // Qualität jeder Teilnehmerin berechnen (1..5 Basis).
  for (const c of state.contestants) {
    c.base = 1 + themeMatch(c.outfit) * 4;
  }

  state.playerRatings = {};
  showScreen("screen-voting");

  const grid = $("vote-grid");
  grid.innerHTML = "";
  // Du bewertest alle ausser dich selbst (Index 1..11).
  for (let i = 1; i < state.contestants.length; i++) {
    const c = state.contestants[i];
    state.playerRatings[i] = 3; // Voreinstellung

    const card = document.createElement("div");
    card.className = "vote-card";
    const dollBox = document.createElement("div");
    dollBox.className = "doll scale-half";
    renderDoll(dollBox, c.outfit);

    const name = document.createElement("div");
    name.className = "nm";
    name.textContent = c.name;

    const stars = document.createElement("div");
    stars.className = "stars";
    for (let s = 1; s <= 5; s++) {
      const st = document.createElement("span");
      st.className = "st" + (s <= 3 ? " on" : "");
      st.textContent = "⭐";
      st.onclick = () => {
        state.playerRatings[i] = s;
        [...stars.children].forEach((c2, idx) => c2.classList.toggle("on", idx < s));
      };
      stars.appendChild(st);
    }

    card.appendChild(dollBox);
    card.appendChild(name);
    card.appendChild(stars);
    grid.appendChild(card);
  }
}

$("btn-vote-done").onclick = showResults;

// ============================================================
// 5) ERGEBNIS
// ============================================================
function showResults() {
  // Alle bewerten alle (ausser sich selbst), 11 Bewertungen pro Person.
  const totals = state.contestants.map((c, ci) => {
    let total = 0;
    for (let ji = 0; ji < state.contestants.length; ji++) {
      if (ji === ci) continue;
      if (ji === 0) {
        // Du als Bewerterin.
        total += state.playerRatings[ci] || 3;
      } else {
        // Computer-Mitspielerin bewertet nach Qualität.
        total += judgeStars(c.base);
      }
    }
    return { name: c.name, isPlayer: c.isPlayer, stars: total, index: ci };
  });

  totals.sort((a, b) => b.stars - a.stars);

  // Podium (Top 3)
  const podium = $("podium");
  podium.innerHTML = "";
  const medals = ["🥇", "🥈", "🥉"];
  const classes = ["first", "second", "third"];
  const bases = ["base-first", "base-second", "base-third"];
  for (let i = 0; i < 3 && i < totals.length; i++) {
    const t = totals[i];
    const pod = document.createElement("div");
    pod.className = "pod " + classes[i];
    pod.innerHTML = `
      <div class="medal">${medals[i]}</div>
      <div class="nm">${t.isPlayer ? "⭐ Du ⭐" : t.name}</div>
      <div class="sc">${t.stars} ⭐</div>
      <div class="${bases[i]}"></div>`;
    podium.appendChild(pod);
  }

  // Deine Platzierung
  const yourPlace = totals.findIndex((t) => t.isPlayer) + 1;
  const yr = $("your-rank");
  if (yourPlace === 1) yr.textContent = `🎉 Du hast GEWONNEN! Platz ${yourPlace} von 12!`;
  else if (yourPlace <= 3) yr.textContent = `🎉 Super! Du bist auf Platz ${yourPlace} von 12!`;
  else yr.textContent = `Du bist auf Platz ${yourPlace} von 12. Beim nächsten Mal klappt's! 💪`;

  // Gesamtliste
  const ranking = $("ranking");
  ranking.innerHTML = "";
  totals.forEach((t, i) => {
    const row = document.createElement("div");
    row.className = "row" + (t.isPlayer ? " you" : "");
    row.innerHTML = `<span>${i + 1}. ${t.isPlayer ? "Du" : t.name}</span><span>${t.stars} ⭐</span>`;
    ranking.appendChild(row);
  });

  showScreen("screen-results");
}

// ============================================================
// Buttons zum Starten
// ============================================================
$("btn-start").onclick = startLobby;
$("btn-again").onclick = startLobby;
