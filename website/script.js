/**
 * Word Search - Classic Puzzle
 * Interactive Website & Mini Playable Puzzle Script
 * Appstick Ltd
 */

document.addEventListener('DOMContentLoaded', () => {
  initThemeToggle();
  initMobileMenu();
  initMiniWordSearchGame();
});

/* ==========================================================================
   Theme Toggle (Dark / Light Mode)
   ========================================================================== */
function initThemeToggle() {
  const themeToggleBtn = document.getElementById('theme-toggle-btn');
  if (!themeToggleBtn) return;

  const savedTheme = localStorage.getItem('ws_theme') || 
    (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');

  document.documentElement.setAttribute('data-theme', savedTheme);
  updateThemeIcon(savedTheme);

  themeToggleBtn.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const nextTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', nextTheme);
    localStorage.setItem('ws_theme', nextTheme);
    updateThemeIcon(nextTheme);
  });
}

function updateThemeIcon(theme) {
  const iconPlaceholder = document.getElementById('theme-icon-container');
  if (!iconPlaceholder) return;
  if (theme === 'dark') {
    // Sun icon for dark mode
    iconPlaceholder.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="5"></circle>
        <line x1="12" y1="1" x2="12" y2="3"></line>
        <line x1="12" y1="21" x2="12" y2="23"></line>
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
        <line x1="1" y1="12" x2="3" y2="12"></line>
        <line x1="21" y1="12" x2="23" y2="12"></line>
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
      </svg>
    `;
  } else {
    // Moon icon for light mode
    iconPlaceholder.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
      </svg>
    `;
  }
}

/* ==========================================================================
   Mobile Menu Toggle
   ========================================================================== */
function initMobileMenu() {
  const menuBtn = document.getElementById('mobile-menu-btn');
  const navLinks = document.getElementById('nav-links');
  if (!menuBtn || !navLinks) return;

  menuBtn.addEventListener('click', () => {
    navLinks.classList.toggle('mobile-active');
  });

  // Close when clicking any nav link
  navLinks.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('mobile-active');
    });
  });
}

/* ==========================================================================
   Audio Synthesizer (Zero External Dependencies)
   ========================================================================== */
let audioCtx = null;
let soundEnabled = true;

function getAudioContext() {
  if (!audioCtx) {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (AudioContextClass) {
      audioCtx = new AudioContextClass();
    }
  }
  if (audioCtx && audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

function playTone(freq, type = 'sine', duration = 0.12, gainVal = 0.15) {
  if (!soundEnabled) return;
  try {
    const ctx = getAudioContext();
    if (!ctx) return;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, ctx.currentTime);
    gain.gain.setValueAtTime(gainVal, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + duration);
  } catch (e) {
    // Audio context may be restricted before interaction
  }
}

function playSelectSound() {
  playTone(520, 'sine', 0.08, 0.1);
}

function playFoundWordSound() {
  if (!soundEnabled) return;
  try {
    const ctx = getAudioContext();
    if (!ctx) return;
    const notes = [440, 554.37, 659.25, 880];
    notes.forEach((freq, idx) => {
      setTimeout(() => {
        playTone(freq, 'triangle', 0.18, 0.2);
      }, idx * 70);
    });
  } catch (e) {}
}

function playWinSound() {
  if (!soundEnabled) return;
  try {
    const notes = [523.25, 659.25, 783.99, 1046.5];
    notes.forEach((freq, idx) => {
      setTimeout(() => {
        playTone(freq, 'square', 0.25, 0.15);
      }, idx * 100);
    });
  } catch (e) {}
}

/* ==========================================================================
   Playable Mini Word Search Engine
   ========================================================================== */
function initMiniWordSearchGame() {
  const gridEl = document.getElementById('word-search-grid');
  if (!gridEl) return;

  const targetWords = ['FIND', 'WORDS', 'PUZZLE', 'PLAY'];
  
  // 7x7 grid pre-built matrix containing the words
  // F  I  N  D  S  P  L
  // W  O  R  D  S  U  A
  // X  A  P  L  A  Y  Y
  // Q  P  U  Z  Z  L  E
  // B  A  S  M  I  N  D
  // C  L  E  V  E  R  T
  // G  A  M  E  F  U  N
  const initialGrid = [
    ['F', 'I', 'N', 'D', 'S', 'P', 'L'],
    ['W', 'O', 'R', 'D', 'S', 'U', 'A'],
    ['X', 'A', 'P', 'L', 'A', 'Y', 'Y'],
    ['Q', 'P', 'U', 'Z', 'Z', 'L', 'E'],
    ['B', 'A', 'S', 'M', 'I', 'N', 'D'],
    ['C', 'L', 'E', 'V', 'E', 'R', 'T'],
    ['G', 'A', 'M', 'E', 'F', 'U', 'N']
  ];

  // Specific word placement locations for the words
  const wordCoordinates = {
    'FIND': [[0, 0], [0, 1], [0, 2], [0, 3]],
    'WORDS': [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4]],
    'PUZZLE': [[3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6]],
    'PLAY': [[2, 2], [2, 3], [2, 4], [2, 5]]
  };

  const foundWords = new Set();
  let isSelecting = false;
  let selectedCells = [];
  let timerInterval = null;
  let secondsElapsed = 0;

  // Sound toggle button
  const soundBtn = document.getElementById('sound-toggle-btn');
  if (soundBtn) {
    soundBtn.addEventListener('click', () => {
      soundEnabled = !soundEnabled;
      soundBtn.style.opacity = soundEnabled ? '1' : '0.5';
    });
  }

  // Timer
  const timerDisplay = document.getElementById('game-timer-display');
  function startTimer() {
    clearInterval(timerInterval);
    secondsElapsed = 0;
    if (timerDisplay) timerDisplay.textContent = '00:00';
    timerInterval = setInterval(() => {
      secondsElapsed++;
      const mins = String(Math.floor(secondsElapsed / 60)).padStart(2, '0');
      const secs = String(secondsElapsed % 60).padStart(2, '0');
      if (timerDisplay) timerDisplay.textContent = `${mins}:${secs}`;
    }, 1000);
  }

  // Render Grid
  function renderGrid() {
    gridEl.innerHTML = '';
    for (let r = 0; r < 7; r++) {
      for (let c = 0; c < 7; c++) {
        const cell = document.createElement('div');
        cell.className = 'grid-cell';
        cell.dataset.row = r;
        cell.dataset.col = c;
        cell.dataset.letter = initialGrid[r][c];
        cell.textContent = initialGrid[r][c];
        gridEl.appendChild(cell);
      }
    }
  }

  function getCellAt(r, c) {
    return gridEl.querySelector(`.grid-cell[data-row="${r}"][data-col="${c}"]`);
  }

  // Touch & Mouse handlers
  function handleCellDown(cell) {
    isSelecting = true;
    selectedCells = [cell];
    updateCellHighlights();
    playSelectSound();
  }

  function handleCellEnter(cell) {
    if (!isSelecting) return;
    if (!selectedCells.includes(cell)) {
      selectedCells.push(cell);
      updateCellHighlights();
      playSelectSound();
    }
  }

  function handleSelectionEnd() {
    if (!isSelecting) return;
    isSelecting = false;

    // Check formed word
    const formedWord = selectedCells.map(c => c.dataset.letter).join('');
    const reversedWord = formedWord.split('').reverse().join('');

    let matchedWord = null;
    if (targetWords.includes(formedWord) && !foundWords.has(formedWord)) {
      matchedWord = formedWord;
    } else if (targetWords.includes(reversedWord) && !foundWords.has(reversedWord)) {
      matchedWord = reversedWord;
    }

    if (matchedWord) {
      foundWords.add(matchedWord);
      selectedCells.forEach(cell => {
        cell.classList.remove('selecting');
        cell.classList.add('found-word');
      });
      playFoundWordSound();
      updateWordListUI(matchedWord);
      checkWinCondition();
    } else {
      // Clear selection
      selectedCells.forEach(cell => {
        cell.classList.remove('selecting');
      });
    }

    selectedCells = [];
  }

  function updateCellHighlights() {
    gridEl.querySelectorAll('.grid-cell').forEach(c => {
      if (!c.classList.contains('found-word')) {
        c.classList.remove('selecting');
      }
    });
    selectedCells.forEach(c => {
      if (!c.classList.contains('found-word')) {
        c.classList.add('selecting');
      }
    });
  }

  function updateWordListUI(word) {
    const wordItem = document.querySelector(`.word-target-item[data-word="${word}"]`);
    if (wordItem) {
      wordItem.classList.add('found');
    }
    const foundCountEl = document.getElementById('words-found-count');
    if (foundCountEl) {
      foundCountEl.textContent = `${foundWords.size}/${targetWords.length}`;
    }
  }

  function checkWinCondition() {
    if (foundWords.size === targetWords.length) {
      clearInterval(timerInterval);
      playWinSound();
      const winModal = document.getElementById('win-modal');
      const winTimeText = document.getElementById('win-time-text');
      if (winTimeText) {
        winTimeText.textContent = `Completed in ${secondsElapsed} seconds!`;
      }
      if (winModal) {
        setTimeout(() => {
          winModal.classList.add('active');
        }, 300);
      }
    }
  }

  // Pointer & Touch Listeners
  gridEl.addEventListener('mousedown', (e) => {
    const cell = e.target.closest('.grid-cell');
    if (cell) handleCellDown(cell);
  });

  gridEl.addEventListener('mouseover', (e) => {
    const cell = e.target.closest('.grid-cell');
    if (cell) handleCellEnter(cell);
  });

  window.addEventListener('mouseup', handleSelectionEnd);

  // Touch Support
  gridEl.addEventListener('touchstart', (e) => {
    const touch = e.touches[0];
    const target = document.elementFromPoint(touch.clientX, touch.clientY);
    const cell = target ? target.closest('.grid-cell') : null;
    if (cell) {
      e.preventDefault();
      handleCellDown(cell);
    }
  }, { passive: false });

  gridEl.addEventListener('touchmove', (e) => {
    const touch = e.touches[0];
    const target = document.elementFromPoint(touch.clientX, touch.clientY);
    const cell = target ? target.closest('.grid-cell') : null;
    if (cell) {
      e.preventDefault();
      handleCellEnter(cell);
    }
  }, { passive: false });

  window.addEventListener('touchend', handleSelectionEnd);

  // Hint Button
  const hintBtn = document.getElementById('game-hint-btn');
  if (hintBtn) {
    hintBtn.addEventListener('click', () => {
      // Find first unfound word
      const unfound = targetWords.find(w => !foundWords.has(w));
      if (!unfound) return;

      const coords = wordCoordinates[unfound];
      if (coords && coords.length > 0) {
        const [r, c] = coords[0];
        const cell = getCellAt(r, c);
        if (cell) {
          cell.classList.add('hinted');
          playTone(660, 'sine', 0.15);
          setTimeout(() => {
            cell.classList.remove('hinted');
          }, 2000);
        }
      }
    });
  }

  // Restart Buttons
  function restartGame() {
    foundWords.clear();
    selectedCells = [];
    renderGrid();
    document.querySelectorAll('.word-target-item').forEach(item => {
      item.classList.remove('found');
    });
    const foundCountEl = document.getElementById('words-found-count');
    if (foundCountEl) {
      foundCountEl.textContent = `0/${targetWords.length}`;
    }
    const winModal = document.getElementById('win-modal');
    if (winModal) {
      winModal.classList.remove('active');
    }
    startTimer();
  }

  const restartBtn = document.getElementById('game-restart-btn');
  if (restartBtn) restartBtn.addEventListener('click', restartGame);

  const winRestartBtn = document.getElementById('win-play-again-btn');
  if (winRestartBtn) winRestartBtn.addEventListener('click', restartGame);

  // Initial setup
  renderGrid();
  startTimer();
}
