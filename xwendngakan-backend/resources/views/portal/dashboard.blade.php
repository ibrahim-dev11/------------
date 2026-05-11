@extends('portal.layout')
@section('title', 'داشبۆرد — EduBook')
@section('styles')
<style>
/* ════════════════════════════════════════════════
   TOKENS
════════════════════════════════════════════════ */
:root {
  --gold:    #c49a3c;
  --gold-lt: #e0b856;
  --gold-dk: #8a6520;
  --bg:      #090d16;
  --bg2:     #0f1624;
  --bg3:     #16203a;
  --bg4:     #1e2d48;
  --border:  rgba(196,154,60,.13);
  --border2: rgba(196,154,60,.30);
  --txt:     #eef1f8;
  --txt2:    #8da4c0;
  --txt3:    #4e6585;
  --red:     #ff4545;
  --green:   #22c55e;
  --grad:    linear-gradient(135deg, #7a5a1a, #c49a3c);
  --radius:  14px;
  --radius-sm: 9px;
}

/* ════════════════════════════════════════════════
   LAYOUT
════════════════════════════════════════════════ */
*, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }

.db {
  display: flex;
  min-height: calc(100vh - 66px);
  background: var(--bg);
  direction: rtl;
}

/* ════════════════════════════════════════════════
   SIDEBAR
════════════════════════════════════════════════ */
.db-side {
  width: 230px;
  flex-shrink: 0;
  background: var(--bg2);
  border-left: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 66px;
  height: calc(100vh - 66px);
  overflow-y: auto;
  padding: 1.25rem .75rem 1rem;
}

.db-avatar {
  display: flex;
  align-items: center;
  gap: .75rem;
  padding: .75rem .5rem 1.25rem;
  border-bottom: 1px solid var(--border);
  margin-bottom: 1.1rem;
}
.db-avatar-circle {
  width: 40px; height: 40px;
  border-radius: 11px;
  background: var(--grad);
  box-shadow: 0 4px 14px rgba(196,154,60,.35);
  display: flex; align-items: center; justify-content: center;
  font-size: .95rem; font-weight: 900; color: #fff;
  flex-shrink: 0;
}
.db-avatar-name  { font-size: .87rem; font-weight: 700; color: var(--txt); line-height: 1.3; }
.db-avatar-email { font-size: .71rem; color: var(--txt3); margin-top: 1px; word-break: break-all; }

.db-nav { display: flex; flex-direction: column; gap: 3px; }
.db-nav-btn {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px;
  border-radius: 10px; border: none;
  background: transparent;
  color: var(--txt2);
  font-family: inherit; font-size: .87rem; font-weight: 700;
  cursor: pointer; width: 100%; text-align: right;
  transition: all .15s;
  position: relative;
}
.db-nav-btn:hover { background: rgba(196,154,60,.07); color: var(--gold-lt); }
.db-nav-btn.is-active {
  background: rgba(196,154,60,.11);
  color: var(--gold);
}
.db-nav-btn.is-active::before {
  content: '';
  position: absolute; right: 0; top: 18%; height: 64%; width: 3px;
  background: var(--grad);
  border-radius: 2px 0 0 2px;
}
.db-nav-icon { font-size: 1rem; flex-shrink: 0; }
.db-nav-badge {
  margin-right: auto;
  background: rgba(183,137,54,.2);
  color: var(--gold);
  font-size: .65rem; padding: 1px 7px;
  border-radius: 20px; font-weight: 800;
}
.db-sep { height: 1px; background: var(--border); margin: .75rem 0; }

.db-logout-btn {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 10px; border: none;
  background: transparent; color: var(--txt3);
  font-family: inherit; font-size: .84rem; font-weight: 700;
  cursor: pointer; width: 100%; margin-top: auto;
  transition: all .15s;
}
.db-logout-btn:hover { background: rgba(255,69,69,.1); color: #ff8080; }

/* ════════════════════════════════════════════════
   MAIN
════════════════════════════════════════════════ */
.db-main {
  flex: 1;
  padding: 2.25rem 2.75rem 5rem;
  max-width: 980px;
  overflow-y: auto;
}

.db-tab { display: none; animation: dbFade .22s ease; }
.db-tab.is-active { display: block; }
@keyframes dbFade { from { opacity:0; transform:translateY(8px) } to { opacity:1; transform:none } }

/* ── Page header ── */
.pg-head { margin-bottom: 2rem; }
.pg-title {
  font-size: 1.55rem; font-weight: 900;
  color: var(--txt); letter-spacing: -.02em;
  line-height: 1.2;
}
.pg-title span { color: var(--gold); }
.pg-sub { font-size: .84rem; color: var(--txt2); margin-top: .45rem; }

.pg-head-row {
  display: flex; align-items: flex-end;
  justify-content: space-between;
  flex-wrap: wrap; gap: 1rem;
  margin-bottom: 1.75rem;
}

/* ── Notice ── */
.nt {
  display: flex; align-items: flex-start; gap: 12px;
  padding: 1rem 1.25rem; border-radius: 13px;
  margin-bottom: 1.5rem; font-size: .86rem; font-weight: 600;
  line-height: 1.55;
}
.nt-warn { background: rgba(251,191,36,.06); border: 1px solid rgba(251,191,36,.2); color: #fbbf24; }
.nt-ok   { background: rgba(34,197,94,.06); border: 1px solid rgba(34,197,94,.2); color: #4ade80; }
.nt-icon { font-size: 1.05rem; flex-shrink: 0; }
.nt-title { font-weight: 800; font-size: .87rem; }
.nt-sub   { font-size: .78rem; opacity: .75; margin-top: 2px; }

/* ── Cards ── */
.db-card {
  background: var(--bg2);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 1.75rem;
  margin-bottom: 1.125rem;
  transition: border-color .2s, box-shadow .2s;
}
.db-card:hover { border-color: rgba(196,154,60,.22); box-shadow: 0 4px 24px rgba(0,0,0,.2); }

.db-card-head {
  display: flex; align-items: center;
  justify-content: space-between;
  margin-bottom: 1.375rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}
.db-card-title {
  font-size: .78rem; font-weight: 800;
  letter-spacing: .09em; color: var(--txt2);
  text-transform: uppercase;
  display: flex; align-items: center; gap: 9px;
}
.db-card-title::before {
  content: '';
  width: 3px; height: 16px;
  background: var(--grad);
  border-radius: 2px; display: inline-block; flex-shrink: 0;
}

/* ── Form fields ── */
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.f-group { margin-bottom: .9rem; }

.f-label {
  display: block; font-size: .84rem; font-weight: 700;
  color: #94b0cc; margin-bottom: 7px;
}
.f-req { color: var(--red); }

.f-input, .f-select, .f-textarea {
  width: 100%; padding: 11px 15px;
  background: var(--bg3);
  border: 1px solid rgba(255,255,255,.07);
  border-radius: 10px;
  color: var(--txt);
  font-family: inherit; font-size: .91rem;
  outline: none; direction: rtl;
  transition: border-color .15s, background .15s, box-shadow .15s;
}
.f-input:focus, .f-select:focus, .f-textarea:focus {
  border-color: var(--gold);
  background: var(--bg4);
  box-shadow: 0 0 0 3px rgba(196,154,60,.09);
}
.f-input::placeholder, .f-textarea::placeholder { color: var(--txt3); opacity: .7; }
.f-select { appearance: none; cursor: pointer; }
.f-select option { background: var(--bg2); color: var(--txt); }
.f-textarea { resize: vertical; min-height: 90px; line-height: 1.65; }

/* ── Translate btn ── */
.btn-tr {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 5px 13px; border-radius: 8px;
  background: rgba(183,137,54,.1);
  color: var(--gold);
  border: 1px solid var(--border2);
  font-family: inherit; font-size: .75rem; font-weight: 700;
  cursor: pointer; transition: background .15s;
}
.btn-tr:hover { background: rgba(183,137,54,.2); }
.btn-tr.loading svg { animation: spin .9s linear infinite; }
@keyframes spin { to { transform: rotate(360deg) } }

/* ── File pick ── */
.f-file {
  display: flex; flex-direction: column; align-items: center;
  padding: 1.625rem 1rem;
  border: 1.5px dashed rgba(196,154,60,.25);
  border-radius: 12px; cursor: pointer;
  background: rgba(196,154,60,.03);
  text-align: center; transition: all .15s;
}
.f-file:hover { border-color: var(--gold); background: rgba(196,154,60,.08); }
.f-file input { display: none; }
.f-file-icon { font-size: 1.75rem; margin-bottom: .5rem; }
.f-file-text { font-size: .84rem; color: var(--txt2); font-weight: 700; }
.f-file-hint { font-size: .73rem; color: var(--txt3); margin-top: 4px; }
.f-preview {
  width: 100%; max-height: 130px;
  object-fit: cover; border-radius: 9px;
  margin-top: .65rem; display: none;
  border: 1px solid var(--border);
}

/* ── Dynamic item rows ── */
.item-row {
  display: flex; align-items: center; gap: .4rem; margin-bottom: .35rem;
}
.item-row .f-input { flex: 1; margin-bottom: 0; }
.rm-btn {
  flex-shrink: 0; width: 30px; height: 30px; border-radius: 8px;
  background: rgba(255,59,59,.1); color: #ff7070;
  border: 1px solid rgba(255,59,59,.2);
  font-size: 1.1rem; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background .15s; line-height: 1;
}
.rm-btn:hover { background: rgba(255,59,59,.2); }

.add-row-btn {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 6px 16px; border-radius: 8px;
  background: rgba(183,137,54,.07);
  color: var(--gold);
  border: 1px dashed var(--border2);
  font-family: inherit; font-size: .79rem; font-weight: 700;
  cursor: pointer; margin-top: .5rem; transition: background .15s;
}
.add-row-btn:hover { background: rgba(183,137,54,.15); }

/* ── Fee table ── */
.fee-header {
  display: grid; grid-template-columns: 2fr 1.3fr 1fr 30px;
  gap: .4rem; margin-bottom: .4rem; padding: 0 2px;
}
.fee-header span { font-size: .7rem; font-weight: 800; color: var(--txt3); }
.fee-row {
  display: grid; grid-template-columns: 2fr 1.3fr 1fr 30px;
  gap: .4rem; align-items: center; margin-bottom: .35rem;
}
.fee-row .f-input { margin-bottom: 0; }

/* ── College nested cards ── */
.college-wrap { display: flex; flex-direction: column; gap: .75rem; }

.college-card {
  border: 1px solid rgba(196,154,60,.22);
  border-radius: 14px;
  overflow: hidden;
  background: linear-gradient(160deg, rgba(196,154,60,.04) 0%, rgba(15,22,36,.7) 100%);
  transition: border-color .2s, box-shadow .2s;
}
.college-card:hover { border-color: rgba(196,154,60,.38); box-shadow: 0 6px 26px rgba(0,0,0,.28); }

.college-header {
  display: flex; align-items: center; gap: .6rem;
  background: rgba(196,154,60,.06);
  border-bottom: 1px solid rgba(196,154,60,.13);
  padding: .7rem 1rem;
}
.college-badge {
  font-size: .65rem; font-weight: 900;
  letter-spacing: .12em; text-transform: uppercase;
  color: var(--gold); white-space: nowrap; flex-shrink: 0;
  display: flex; align-items: center; gap: 5px;
}
.college-badge::before {
  content: ''; width: 6px; height: 6px;
  background: var(--gold); border-radius: 50%;
  box-shadow: 0 0 7px rgba(196,154,60,.75); flex-shrink: 0;
}
.college-header .clg-name {
  flex: 1; min-width: 0; margin-bottom: 0;
  font-weight: 700; font-size: .92rem;
}
.college-del-btn {
  flex-shrink: 0; width: 30px; height: 30px; border-radius: 8px;
  background: rgba(255,70,70,.09); color: #ff7070;
  border: 1px solid rgba(255,70,70,.2); font-size: .85rem;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  transition: background .15s, transform .12s;
}
.college-del-btn:hover { background: rgba(255,70,70,.22); transform: scale(1.07); }

/* College fee strip */
.college-fee-strip {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: .5rem; padding: .6rem 1rem;
  border-bottom: 1px solid rgba(196,154,60,.09);
  background: rgba(0,0,0,.12);
}
.college-fee-field { display: flex; flex-direction: column; gap: 4px; }
.college-fee-label {
  font-size: .62rem; font-weight: 800;
  color: var(--txt3); letter-spacing: .05em;
  padding-right: 3px;
}
.college-fee-strip .f-input { margin-bottom: 0; font-size: .87rem; }

.college-body { padding: .85rem 1rem 1rem; }

.depts-header-row {
  display: flex; align-items: center; gap: 8px; margin-bottom: .5rem;
}
.depts-header-label {
  font-size: .64rem; font-weight: 900; letter-spacing: .1em;
  text-transform: uppercase; color: var(--txt3); white-space: nowrap;
}
.depts-header-line { flex: 1; height: 1px; background: var(--border); }

.dept-col-labels {
  display: grid; grid-template-columns: 1fr 120px 78px 30px;
  gap: .4rem; padding: 0 1px; margin-bottom: .3rem;
}
.dept-col-labels span {
  font-size: .63rem; font-weight: 800; color: var(--txt3); letter-spacing: .04em;
}

.dept-row {
  display: grid; grid-template-columns: 1fr 120px 78px 30px;
  gap: .4rem; align-items: center; margin-bottom: .35rem;
}
.dept-row .f-input {
  margin-bottom: 0; font-size: .86rem;
  background: rgba(9,13,22,.6); border-color: rgba(255,255,255,.07);
}
.dept-row .f-input:focus { background: var(--bg4); }

.dept-del-btn {
  width: 30px; height: 36px; border-radius: 8px;
  background: rgba(255,70,70,.07); color: #ff7070;
  border: 1px solid rgba(255,70,70,.15); font-size: .85rem;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  transition: background .15s; flex-shrink: 0;
}
.dept-del-btn:hover { background: rgba(255,70,70,.2); }

.add-dept-btn {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 5px 13px; border-radius: 8px;
  background: rgba(100,160,255,.05); color: #84b8ff;
  border: 1px dashed rgba(100,160,255,.22);
  font-family: inherit; font-size: .74rem; font-weight: 700;
  cursor: pointer; margin-top: .2rem;
  transition: background .15s, border-color .15s;
}
.add-dept-btn:hover { background: rgba(100,160,255,.12); border-color: rgba(100,160,255,.4); }

.add-college-btn {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  width: 100%; padding: 12px;
  border-radius: 12px;
  background: rgba(196,154,60,.04);
  border: 1.5px dashed rgba(196,154,60,.25);
  color: var(--gold);
  font-family: inherit; font-size: .83rem; font-weight: 800;
  cursor: pointer;
  transition: background .15s, border-color .15s;
}
.add-college-btn:hover { background: rgba(196,154,60,.1); border-color: rgba(196,154,60,.5); }

/* ── Simple dept/fee rows ── */
.fee-header {
  display: grid; grid-template-columns: 1fr 120px 78px 30px;
  gap: .4rem; margin-bottom: .35rem; padding: 0 1px;
}
.fee-header span { font-size: .63rem; font-weight: 800; color: var(--txt3); }
.fee-row {
  display: grid; grid-template-columns: 1fr 120px 78px 30px;
  gap: .4rem; align-items: center; margin-bottom: .35rem;
}
.fee-row .f-input { margin-bottom: 0; }

@media (max-width: 600px) {
  .college-header-inputs { flex-wrap: wrap; }
  .clg-fee, .clg-disc { width: calc(50% - .2rem); }
  .dept-col-labels, .dept-row,
  .fee-header, .fee-row { grid-template-columns: 1fr 30px; }
  .dept-col-labels span:nth-child(2), .dept-col-labels span:nth-child(3),
  .fee-header span:nth-child(2), .fee-header span:nth-child(3) { display: none; }
  .dept-row .f-input:nth-child(2), .dept-row .f-input:nth-child(3),
  .fee-row .f-input:nth-child(2), .fee-row .f-input:nth-child(3) { display: none; }
}

/* ── Buttons ── */
.btn-primary {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 12px 30px; border-radius: 10px;
  background: var(--grad);
  color: #fff; border: none;
  font-family: inherit; font-size: .92rem; font-weight: 800;
  cursor: pointer; transition: opacity .15s, transform .1s, box-shadow .15s;
  letter-spacing: .025em;
  box-shadow: 0 4px 18px rgba(196,154,60,.3);
}
.btn-primary:hover { opacity: .88; }
.btn-primary:active { transform: scale(.97); }

.btn-outline {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 9px 20px; border-radius: 10px;
  background: transparent; color: var(--gold);
  border: 1px solid var(--border2);
  font-family: inherit; font-size: .84rem; font-weight: 700;
  cursor: pointer; transition: background .15s;
}
.btn-outline:hover { background: rgba(183,137,54,.12); }

/* ── Posts ── */
.posts-grid { display: flex; flex-direction: column; gap: .75rem; }
.p-card {
  background: var(--bg2);
  border: 1px solid var(--border);
  border-radius: 14px;
  display: flex; overflow: hidden;
  transition: border-color .15s, transform .15s, box-shadow .15s;
}
.p-card:hover { border-color: var(--border2); transform: translateY(-2px); box-shadow: 0 6px 24px rgba(0,0,0,.25); }
.p-img { width: 96px; flex-shrink: 0; object-fit: cover; }
.p-body { padding: 1rem 1.25rem; flex: 1; min-width: 0; }
.p-title { font-weight: 800; font-size: .95rem; color: var(--txt); }
.p-text {
  color: var(--txt2); font-size: .82rem; line-height: 1.65;
  display: -webkit-box; -webkit-line-clamp: 2;
  -webkit-box-orient: vertical; overflow: hidden; margin-top: .2rem;
}
.p-foot {
  display: flex; align-items: center; gap: 8px;
  margin-top: .65rem; flex-wrap: wrap;
}
.p-date { font-size: .72rem; color: var(--txt3); }

/* ── Chips ── */
.chip {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 3px 10px; border-radius: 20px;
  font-size: .71rem; font-weight: 700;
}
.chip-ok      { background: rgba(45,190,108,.12); color: #2dbe6c; border: 1px solid rgba(45,190,108,.25); }
.chip-pending { background: rgba(255,170,0,.1);   color: #f59e0b; border: 1px solid rgba(255,170,0,.2); }
.chip-dot     { width: 5px; height: 5px; border-radius: 50%; background: currentColor; }

/* ── Empty / Locked ── */
.empty-state {
  text-align: center; padding: 4rem 1rem; color: var(--txt3);
}
.empty-icon { font-size: 3rem; margin-bottom: 1rem; filter: grayscale(.2); }
.empty-txt  { font-size: 1rem; font-weight: 700; color: var(--txt2); }
.empty-sub  { font-size: .83rem; margin-top: .4rem; }

.locked-state {
  background: var(--bg2);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 2.5rem; text-align: center; color: var(--txt2);
}
.locked-icon { font-size: 2rem; margin-bottom: .65rem; }

/* ════════════════════════════════════════════════
   MOBILE BOTTOM NAV
════════════════════════════════════════════════ */
.db-mobile-nav {
  display: none;
  position: fixed; bottom: 0; left: 0; right: 0;
  background: rgba(15,22,36,.95);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border-top: 1px solid var(--border);
  z-index: 100; padding: .5rem .25rem env(safe-area-inset-bottom, .5rem);
}
.db-mobile-nav-inner {
  display: flex; justify-content: space-around; align-items: center;
}
.db-mob-btn {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  padding: .5rem .75rem; border: none; background: transparent;
  color: var(--txt3);
  font-family: inherit; font-size: .67rem; font-weight: 700;
  cursor: pointer; border-radius: 11px; min-width: 62px;
  transition: color .15s, background .15s;
}
.db-mob-btn .mob-icon { font-size: 1.3rem; line-height: 1; }
.db-mob-btn.is-active { color: var(--gold); background: rgba(196,154,60,.11); }

/* ════════════════════════════════════════════════
   RESPONSIVE
════════════════════════════════════════════════ */
@media (max-width: 960px) {
  .db-main { padding: 1.75rem 2rem 5rem; }
}
@media (max-width: 768px) {
  .db-side { display: none; }
  .db-mobile-nav { display: block; }
  .db-main { padding: 1.375rem 1.125rem 5.5rem; max-width: 100%; }
  .f-row { gap: .75rem; }
}
@media (max-width: 580px) {
  .f-row { grid-template-columns: 1fr; gap: 0; }
  .fee-header, .fee-row { grid-template-columns: 1fr 1fr; }
  .fee-header span:nth-child(3), .fee-header span:nth-child(4) { display: none; }
  .fee-row .f-input:nth-child(3), .fee-row .rm-btn { display: none; }
  .db-card { padding: 1.125rem; border-radius: 13px; }
  .pg-title { font-size: 1.3rem; }
  .db-main { padding: 1.125rem .875rem 5.5rem; }
}
</style>
@endsection

@section('content')
<div class="db">

  {{-- ══ SIDEBAR ══ --}}
  <aside class="db-side">
    <div class="db-avatar">
      <div class="db-avatar-circle">{{ mb_substr(auth()->user()->name, 0, 1) }}</div>
      <div>
        <div class="db-avatar-name">{{ auth()->user()->name }}</div>
        <div class="db-avatar-email">{{ auth()->user()->email }}</div>
      </div>
    </div>

    <nav class="db-nav">
      <button class="db-nav-btn is-active" onclick="showTab('institution',this)">
        <span class="db-nav-icon">🏫</span> دامەزراوەکەم
      </button>
      <button class="db-nav-btn" onclick="showTab('posts',this)">
        <span class="db-nav-icon">📰</span> پۆستەکانم
        @if($posts->count())
          <span class="db-nav-badge">{{ $posts->count() }}</span>
        @endif
      </button>
      <button class="db-nav-btn" onclick="showTab('new-post',this)">
        <span class="db-nav-icon">✏️</span> پۆستی نوێ
      </button>
    </nav>

    <div class="db-sep" style="margin-top:auto"></div>
    <form method="POST" action="{{ route('portal.logout') }}">
      @csrf
      <button type="submit" class="db-logout-btn">
        <span>🚪</span> دەرچوون
      </button>
    </form>
  </aside>

  {{-- ══ MAIN ══ --}}
  <main class="db-main">

    @if(session('success'))
      <div class="nt nt-ok" style="margin-bottom:1.25rem"><span class="nt-icon">✅</span><span>{{ session('success') }}</span></div>
    @endif
    @if(session('error') || $errors->any())
      <div class="nt nt-warn" style="margin-bottom:1.25rem"><span class="nt-icon">⚠</span><span>{{ session('error') ?? $errors->first() }}</span></div>
    @endif

    {{-- ══ TAB: INSTITUTION ══ --}}
    <div class="db-tab is-active" id="tab-institution">
      <div class="pg-head">
        <div class="pg-title">دامەزراوە<span>کەم</span></div>
        <p class="pg-sub">زانیارییەکانت تۆمار بکە تا لە ئەپەکەدا دیار بێت</p>
      </div>

      @if($institution)
        @if(!$institution->approved)
          <div class="nt nt-warn">
            <span class="nt-icon">⏳</span>
            <div>
              <div class="nt-title">چاوەڕوانی پەسەندکردنی ئەدمین</div>
              <div class="nt-sub">پاش پەسەندکردن دەتوانیت پۆست بکەیت</div>
            </div>
          </div>
        @else
          <div class="nt nt-ok">
            <span class="nt-icon">✅</span>
            <span>دامەزراوەکەت پەسەندکراوە — دەتوانیت پۆست بکەیت</span>
          </div>
        @endif
      @endif

      <form method="POST" action="{{ route('portal.institution.save') }}" enctype="multipart/form-data">
        @csrf

        {{-- ناو --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">📋 ناوی دامەزراوە</div>
            <button type="button" class="btn-tr" onclick="autoTranslate('nku', ['nar', 'nen'], this)">
              <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m5 8 6 6"/><path d="m4 14 6-6 2-3"/><path d="M2 5h12"/><path d="M7 2h1"/><path d="m22 22-5-10-5 10"/><path d="M14 18h6"/></svg>
              وەرگێڕان
            </button>
          </div>
          <div class="f-row">
            <div class="f-group">
              <label class="f-label">کوردی <span class="f-req">*</span></label>
              <input type="text" id="nku" name="nku" class="f-input" placeholder="ناوی کوردی..." value="{{ old('nku', $institution?->nku) }}" required>
            </div>
            <div class="f-group">
              <label class="f-label">عەرەبی</label>
              <input type="text" id="nar" name="nar" class="f-input" placeholder="الاسم بالعربي..." value="{{ old('nar', $institution?->nar) }}">
            </div>
            <div class="f-group">
              <label class="f-label">ئینگلیزی</label>
              <input type="text" id="nen" name="nen" class="f-input" placeholder="English name..." value="{{ old('nen', $institution?->nen) }}">
            </div>
          </div>
        </div>

        {{-- شوێن و جۆر --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">📍 شوێن و جۆر</div>
          </div>
          <div class="f-row">
            <div class="f-group">
              <label class="f-label">جۆری دامەزراوە <span class="f-req">*</span></label>
              <select name="type" class="f-select" required onchange="handleTypeChange(this.value)">
                <option value="">— جۆر هەڵبژێرە —</option>
                @foreach($types as $t)
                  <option value="{{ $t->key }}" {{ old('type', $institution?->type) == $t->key ? 'selected' : '' }}>
                    {{ $t->emoji ?? '' }} {{ $t->name }}
                  </option>
                @endforeach
              </select>
            </div>
            <div class="f-group">
              <label class="f-label">وڵات / هەرێم <span class="f-req">*</span></label>
              <select name="country" class="f-input" required>
                <option value="کوردستان" {{ old('country', $institution?->country ?? 'کوردستان') == 'کوردستان' ? 'selected' : '' }}>🏔️ کوردستان</option>
                <option value="عێراق" {{ old('country', $institution?->country) == 'عێراق' ? 'selected' : '' }}>🇮🇶 عێراق</option>
              </select>
            </div>
            <div class="f-group">
              <label class="f-label">شار <span class="f-req">*</span></label>
              <input type="text" name="city" class="f-input" list="cities_list" placeholder="شار هەڵبژێرە یان بنووسە..." value="{{ old('city', $institution?->city) }}" required>
              <datalist id="cities_list">
                @foreach([
                    'هەولێر', 'سلێمانی', 'دهۆک', 'زاخۆ', 'ئامێدی', 'سیمێل', 'شێخان', 'دیانا', 'چۆمان', 'سۆران',
                    'کەرکووک', 'هەڵەبجە', 'رانیە', 'کەلار', 'قلادزێ', 'دوکان', 'دەربەندیخان', 'کفری', 'چەمچەماڵ',
                    'شارەزووری', 'پێنجوێن', 'سەید سادق', 'دوزەخوڕماتو', 'بەغداد', 'مووسڵ', 'بەسرە', 'نەجەف',
                    'کەربەلا', 'حیللە', 'سامەراء', 'تکریت', 'رمادی', 'فەللووجە', 'نەسیریە', 'عەماره', 'کووت',
                    'دیوانیە', 'بعقووبە', 'سینجار', 'تەلاعەفەر'
                ] as $c)
                    <option value="{{ $c }}">
                @endforeach
              </datalist>
            </div>
            <div class="f-group">
              <label class="f-label">ناونیشان</label>
              <input type="text" name="addr" class="f-input" placeholder="ناونیشان..." value="{{ old('addr', $institution?->addr) }}">
            </div>
          </div>
        </div>

        {{-- پەیوەندی --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">📞 پەیوەندی</div>
          </div>
          <div class="f-row">
            <div class="f-group">
              <label class="f-label">تەلەفۆن</label>
              <input type="text" name="phone" class="f-input" placeholder="07XX XXX XXXX" value="{{ old('phone', $institution?->phone) }}">
            </div>
            <div class="f-group">
              <label class="f-label">ئیمەیڵ</label>
              <input type="email" name="email" class="f-input" placeholder="info@example.com" value="{{ old('email', $institution?->email) }}">
            </div>
            <div class="f-group">
              <label class="f-label">وێبسایت</label>
              <input type="url" name="web" class="f-input" placeholder="https://..." value="{{ old('web', $institution?->web) }}">
            </div>
          </div>
        </div>

        {{-- کۆلێژ و بەشەکان --}}
        @php
          $currentType  = old('type', $institution?->type);
          $flags        = $typeFlags[$currentType] ?? ['has_colleges' => false, 'has_departments' => false];
          $showSection  = $flags['has_colleges'] || $flags['has_departments'];
          $showColleges = $flags['has_colleges'];
          $showDepts    = $flags['has_departments'];
          // Parse colleges — handles: new JSON (with depts+fee), Filament JSON, legacy newline text
          $collegesData = [];
          if (!empty($institution?->colleges)) {
              $decoded = json_decode($institution->colleges, true);
              if (is_array($decoded) && count($decoded)) {
                  foreach ($decoded as $col) {
                      if (!isset($col['name'])) continue;
                      $depts = [];
                      foreach (($col['depts'] ?? $col['departments'] ?? []) as $d) {
                          $depts[] = [
                              'name'     => is_string($d) ? $d : ($d['name'] ?? $d['dept_name'] ?? ''),
                              'fee'      => $d['fee'] ?? '',
                              'discount' => $d['discount'] ?? '',
                          ];
                      }
                      $collegesData[] = [
                          'name'     => $col['name'],
                          'fee'      => $col['fee'] ?? '',
                          'discount' => $col['discount'] ?? '',
                          'depts'    => $depts,
                      ];
                  }
              } else {
                  foreach (array_filter(array_map('trim', explode("\n", $institution->colleges))) as $line) {
                      $collegesData[] = ['name' => $line, 'fee' => '', 'discount' => '', 'depts' => []];
                  }
              }
          }
          $nextCiSeed   = count($collegesData);
          // Simple dept rows (for school/non-college types)
          $tuitionList  = is_array($institution?->tuition_plans)
                          ? $institution->tuition_plans
                          : (json_decode($institution?->tuition_plans ?? '[]', true) ?: []);
          $deptsList    = array_filter(array_map('trim', explode("\n", $institution?->depts ?? '')));
          $simpleDeptRows = (count($tuitionList) && !$showColleges)
                          ? $tuitionList
                          : array_map(fn($d) => ['dept' => $d, 'fee' => '', 'discount' => ''], $deptsList);
        @endphp

        <div id="academic-section" class="db-card" style="{{ $showSection ? '' : 'display:none' }}">
          <div class="db-card-head">
            <div class="db-card-title">📚 <span id="academic-title">{{ $showColleges ? 'کۆلێژ و بەشەکان' : 'بەشەکان و پارەدان' }}</span></div>
          </div>

          {{-- Mode 1: Colleges → nested depts + fee/discount per dept --}}
          <div id="group-colleges" style="{{ $showColleges ? '' : 'display:none' }}">
            <div id="colleges-container" class="college-wrap">
              @forelse($collegesData as $col)
                @php $ci = $loop->index; @endphp
                <div class="college-card" data-ci="{{ $ci }}">
                  <div class="college-header">
                    <span class="college-badge">کۆلێژ</span>
                    <input type="text" name="clg[{{ $ci }}][name]" class="f-input clg-name" value="{{ $col['name'] }}" placeholder="بۆ نموونە: کۆلێژی ئەندازیاری">
                    <button type="button" class="college-del-btn" onclick="removeCollege(this)" title="سڕینەوە">✕</button>
                  </div>
                  <div class="college-fee-strip">
                    <div class="college-fee-field">
                      <span class="college-fee-label">پارەی کۆلێژ (دینار)</span>
                      <input type="text" name="clg[{{ $ci }}][fee]" class="f-input" value="{{ $col['fee'] }}" placeholder="بۆ نموونە: 500,000">
                    </div>
                    <div class="college-fee-field">
                      <span class="college-fee-label">داشکاندنی کۆلێژ %</span>
                      <input type="text" name="clg[{{ $ci }}][discount]" class="f-input" value="{{ $col['discount'] }}" placeholder="بۆ نموونە: 10%">
                    </div>
                  </div>
                  <div class="college-body">
                    <div class="depts-header-row">
                      <span class="depts-header-label">بەشەکان</span>
                      <span class="depts-header-line"></span>
                    </div>
                    <div class="dept-col-labels">
                      <span>ناوی بەش</span><span>پارە (دینار)</span><span>داشکان %</span><span></span>
                    </div>
                    <div class="depts-wrap">
                      @forelse($col['depts'] as $dept)
                        @php $di = $loop->index; @endphp
                        <div class="dept-row">
                          <input type="text" name="clg[{{ $ci }}][depts][{{ $di }}][name]" class="f-input" value="{{ $dept['name'] }}" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">
                          <input type="text" name="clg[{{ $ci }}][depts][{{ $di }}][fee]" class="f-input" value="{{ $dept['fee'] }}" placeholder="150,000">
                          <input type="text" name="clg[{{ $ci }}][depts][{{ $di }}][discount]" class="f-input" value="{{ $dept['discount'] }}" placeholder="10%">
                          <button type="button" class="dept-del-btn" onclick="removeDept(this)">✕</button>
                        </div>
                      @empty
                        <div class="dept-row">
                          <input type="text" name="clg[{{ $ci }}][depts][0][name]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">
                          <input type="text" name="clg[{{ $ci }}][depts][0][fee]" class="f-input" placeholder="150,000">
                          <input type="text" name="clg[{{ $ci }}][depts][0][discount]" class="f-input" placeholder="10%">
                          <button type="button" class="dept-del-btn" onclick="removeDept(this)">✕</button>
                        </div>
                      @endforelse
                    </div>
                    <button type="button" class="add-dept-btn" onclick="addDept(this)">＋ بەش زیاد بکە</button>
                  </div>
                </div>
              @empty
                <div class="college-card" data-ci="0">
                  <div class="college-header">
                    <span class="college-badge">کۆلێژ</span>
                    <input type="text" name="clg[0][name]" class="f-input clg-name" placeholder="بۆ نموونە: کۆلێژی ئەندازیاری">
                    <button type="button" class="college-del-btn" onclick="removeCollege(this)">✕</button>
                  </div>
                  <div class="college-fee-strip">
                    <div class="college-fee-field">
                      <span class="college-fee-label">پارەی کۆلێژ (دینار)</span>
                      <input type="text" name="clg[0][fee]" class="f-input" placeholder="بۆ نموونە: 500,000">
                    </div>
                    <div class="college-fee-field">
                      <span class="college-fee-label">داشکاندنی کۆلێژ %</span>
                      <input type="text" name="clg[0][discount]" class="f-input" placeholder="بۆ نموونە: 10%">
                    </div>
                  </div>
                  <div class="college-body">
                    <div class="depts-header-row">
                      <span class="depts-header-label">بەشەکان</span>
                      <span class="depts-header-line"></span>
                    </div>
                    <div class="dept-col-labels">
                      <span>ناوی بەش</span><span>پارە (دینار)</span><span>داشکان %</span><span></span>
                    </div>
                    <div class="depts-wrap">
                      <div class="dept-row">
                        <input type="text" name="clg[0][depts][0][name]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">
                        <input type="text" name="clg[0][depts][0][fee]" class="f-input" placeholder="150,000">
                        <input type="text" name="clg[0][depts][0][discount]" class="f-input" placeholder="10%">
                        <button type="button" class="dept-del-btn" onclick="removeDept(this)">✕</button>
                      </div>
                    </div>
                    <button type="button" class="add-dept-btn" onclick="addDept(this)">＋ بەش زیاد بکە</button>
                  </div>
                </div>
              @endforelse
            </div>
            <button type="button" class="add-college-btn" onclick="addCollege()">🏛️ کۆلێژی نوێ زیاد بکە</button>
          </div>

          {{-- Mode 2: Simple depts + fees (schools etc.) --}}
          <div id="group-depts" style="{{ (!$showColleges && $showDepts) ? '' : 'display:none' }}">
            <div class="fee-header">
              <span>ناوی بەش</span>
              <span>پارە (دینار)</span>
              <span>داشکان %</span>
              <span></span>
            </div>
            <div id="depts-list">
              @forelse($simpleDeptRows as $row)
                <div class="fee-row">
                  <input type="text" name="simple_dept[]" class="f-input" value="{{ $row['dept'] ?? $row['name'] ?? '' }}" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">
                  <input type="text" name="simple_fee[]" class="f-input" value="{{ $row['fee'] ?? '' }}" placeholder="150,000">
                  <input type="text" name="simple_discount[]" class="f-input" value="{{ $row['discount'] ?? '' }}" placeholder="10%">
                  <button type="button" class="dept-del-btn" onclick="removeRow(this)">✕</button>
                </div>
              @empty
                <div class="fee-row">
                  <input type="text" name="simple_dept[]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">
                  <input type="text" name="simple_fee[]" class="f-input" placeholder="150,000">
                  <input type="text" name="simple_discount[]" class="f-input" placeholder="10%">
                  <button type="button" class="dept-del-btn" onclick="removeRow(this)">✕</button>
                </div>
              @endforelse
            </div>
            <button type="button" class="add-row-btn" onclick="addSimpleDeptRow()">＋ بەش زیاد بکە</button>
          </div>
        </div>

        {{-- دەربارە --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">📝 دەربارە</div>
            <button type="button" class="btn-tr" onclick="autoTranslate('desc', ['desc_ar', 'desc_en'], this)">
              <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m5 8 6 6"/><path d="m4 14 6-6 2-3"/><path d="M2 5h12"/><path d="M7 2h1"/><path d="m22 22-5-10-5 10"/><path d="M14 18h6"/></svg>
              وەرگێڕان
            </button>
          </div>
          <div class="f-group">
            <label class="f-label">کوردی</label>
            <textarea id="desc" name="desc" class="f-textarea" placeholder="کورتەیەک دەربارەی دامەزراوەکەت...">{{ old('desc', $institution?->desc) }}</textarea>
          </div>
          <div class="f-group">
            <label class="f-label">عەرەبی</label>
            <textarea id="desc_ar" name="desc_ar" class="f-textarea" placeholder="نبذة عن المؤسسة...">{{ old('desc_ar', $institution?->desc_ar) }}</textarea>
          </div>
          <div class="f-group">
            <label class="f-label">ئینگلیزی</label>
            <textarea id="desc_en" name="desc_en" class="f-textarea" placeholder="About the institution...">{{ old('desc_en', $institution?->desc_en) }}</textarea>
          </div>
        </div>

        {{-- سۆشیال --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">🔗 سۆشیال میدیا</div>
          </div>
          <div class="f-row">
            <div class="f-group">
              <label class="f-label">Facebook</label>
              <input type="url" name="fb" class="f-input" placeholder="https://facebook.com/..." value="{{ old('fb', $institution?->fb) }}">
            </div>
            <div class="f-group">
              <label class="f-label">Instagram</label>
              <input type="url" name="ig" class="f-input" placeholder="https://instagram.com/..." value="{{ old('ig', $institution?->ig) }}">
            </div>
            <div class="f-group">
              <label class="f-label">Telegram</label>
              <input type="url" name="tg" class="f-input" placeholder="https://t.me/..." value="{{ old('tg', $institution?->tg) }}">
            </div>
            <div class="f-group">
              <label class="f-label">WhatsApp</label>
              <input type="text" name="wa" class="f-input" placeholder="https://wa.me/..." value="{{ old('wa', $institution?->wa) }}">
            </div>
            <div class="f-group">
              <label class="f-label">TikTok</label>
              <input type="url" name="tk" class="f-input" placeholder="https://tiktok.com/@..." value="{{ old('tk', $institution?->tk) }}">
            </div>
            <div class="f-group">
              <label class="f-label">YouTube</label>
              <input type="url" name="yt" class="f-input" placeholder="https://youtube.com/..." value="{{ old('yt', $institution?->yt) }}">
            </div>
          </div>
        </div>

        {{-- وێنەکان --}}
        <div class="db-card">
          <div class="db-card-head">
            <div class="db-card-title">🖼 وێنەکان</div>
          </div>
          <div class="f-row">
            <div class="f-group">
              <label class="f-label">لۆگۆ</label>
              <label class="f-file" for="logo-input">
                <input type="file" id="logo-input" name="logo" accept="image/*" onchange="previewImg(this,'logo-prev')">
                <div class="f-file-icon">🏷</div>
                <div class="f-file-text">لۆگۆ هەڵبژێرە</div>
                <div class="f-file-hint">PNG, JPG · max 10MB</div>
              </label>
              @if($institution?->logo)
                <img src="{{ $institution->logo }}" class="f-preview" style="display:block" alt="">
              @else
                <img id="logo-prev" class="f-preview" alt="">
              @endif
            </div>
            <div class="f-group">
              <label class="f-label">وێنەی دامەزراوە</label>
              <label class="f-file" for="img-input">
                <input type="file" id="img-input" name="img" accept="image/*" onchange="previewImg(this,'img-prev')">
                <div class="f-file-icon">📸</div>
                <div class="f-file-text">وێنەی سەرەکی هەڵبژێرە</div>
                <div class="f-file-hint">PNG, JPG · max 10MB</div>
              </label>
              @if($institution?->img)
                <img src="{{ $institution->img }}" class="f-preview" style="display:block" alt="">
              @else
                <img id="img-prev" class="f-preview" alt="">
              @endif
            </div>
          </div>
        </div>

        <button type="submit" class="btn-primary">💾 پاشەکەوتکردن</button>
      </form>
    </div>

    {{-- ══ TAB: POSTS ══ --}}
    <div class="db-tab" id="tab-posts">
      <div class="pg-head-row">
        <div class="pg-head" style="margin-bottom:0">
          <div class="pg-title">پۆستەکا<span>نم</span></div>
          <p class="pg-sub">{{ $posts->count() }} پۆست بڵاوکراوەتەوە</p>
        </div>
        @if($institution?->approved)
          <button class="btn-primary" style="padding:9px 20px;font-size:.83rem" onclick="showTab('new-post',null);syncMobile('new-post')">+ پۆستی نوێ</button>
        @endif
      </div>

      @if($posts->isEmpty())
        <div class="empty-state">
          <div class="empty-icon">📭</div>
          <div class="empty-txt">هیچ پۆستێکت نییە هێشتا</div>
          <div class="empty-sub">پاش قبوڵکردنی دامەزراوەکەت دەتوانیت پۆست بکەیت</div>
        </div>
      @else
        <div class="posts-grid">
          @foreach($posts as $post)
            <div class="p-card">
              @if($post->image)
                <img src="{{ $post->image }}" class="p-img" alt="">
              @endif
              <div class="p-body">
                <div class="p-title">{{ $post->title }}</div>
                <div class="p-text">{{ $post->content }}</div>
                <div class="p-foot">
                  <span class="chip {{ $post->approved ? 'chip-ok' : 'chip-pending' }}">
                    <span class="chip-dot"></span>
                    {{ $post->approved ? 'پەسەندکراو' : 'چاوەڕوانی پەسەند' }}
                  </span>
                  <span class="p-date">{{ $post->created_at->diffForHumans() }}</span>
                  <form method="POST" action="{{ route('portal.posts.delete', $post->id) }}" onsubmit="return confirm('دڵنیایت؟')" style="margin-right:auto">
                    @csrf @method('DELETE')
                    <button type="submit" style="background:none;border:none;cursor:pointer;color:#ff7070;font-size:.78rem;font-family:inherit;font-weight:700">🗑 سڕینەوە</button>
                  </form>
                </div>
              </div>
            </div>
          @endforeach
        </div>
      @endif
    </div>

    {{-- ══ TAB: NEW POST ══ --}}
    <div class="db-tab" id="tab-new-post">
      <div class="pg-head">
        <div class="pg-title">پۆستی <span>نوێ</span></div>
        <p class="pg-sub">هەواڵ، ئیلان یان بابەتێک بڵاوبکەرەوە</p>
      </div>

      @if(!$institution)
        <div class="nt nt-warn"><span class="nt-icon">⚠</span><span>پێشتر دامەزراوەکەت تۆمار بکە.</span></div>
      @elseif(!$institution->approved)
        <div class="locked-state">
          <div class="locked-icon">🔒</div>
          <div style="font-weight:800;color:var(--txt);margin-bottom:.35rem">دامەزراوەکەت هێشتا قبوڵ نەکراوە</div>
          <div style="font-size:.82rem;color:var(--txt3)">پاش قبوڵکردنی ئەدمین دەتوانیت پۆست بکەیت</div>
        </div>
      @else
        <div class="db-card">
          <form method="POST" action="{{ route('portal.posts.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="f-group">
              <label class="f-label">ناونیشانی پۆست <span class="f-req">*</span></label>
              <input type="text" name="title" class="f-input" placeholder="ناونیشانی کورت و ڕوون" value="{{ old('title') }}" required>
            </div>
            <div class="f-group">
              <label class="f-label">ناوەڕۆک <span class="f-req">*</span></label>
              <textarea name="content" class="f-textarea" placeholder="ناوەڕۆکی پۆستەکەت بنووسە..." style="min-height:130px" required>{{ old('content') }}</textarea>
            </div>
            <div class="f-group">
              <label class="f-label">وێنە (ئەختیاری)</label>
              <label class="f-file" for="post-img">
                <input type="file" id="post-img" name="image" accept="image/*" onchange="previewImg(this,'post-prev')">
                <div class="f-file-icon">🖼</div>
                <div class="f-file-text">وێنەی پۆست هەڵبژێرە</div>
                <div class="f-file-hint">PNG, JPG · max 4MB</div>
              </label>
              <img id="post-prev" class="f-preview" alt="">
            </div>
            <div style="display:flex;align-items:center;gap:.75rem;flex-wrap:wrap;margin-top:.5rem">
              <button type="submit" class="btn-primary">🚀 بڵاوکردنەوە</button>
              <span style="font-size:.78rem;color:var(--txt3)">ئەدمین پەسەندی دەکات پاش بڵاوکردنەوە</span>
            </div>
          </form>
        </div>
      @endif
    </div>

  </main>
</div>

{{-- ══ MOBILE BOTTOM NAV ══ --}}
<nav class="db-mobile-nav">
  <div class="db-mobile-nav-inner">
    <button class="db-mob-btn is-active" id="mob-institution" onclick="showTab('institution',null);syncMobile('institution')">
      <span class="mob-icon">🏫</span>دامەزراوەکەم
    </button>
    <button class="db-mob-btn" id="mob-posts" onclick="showTab('posts',null);syncMobile('posts')">
      <span class="mob-icon">📰</span>پۆستەکانم
    </button>
    <button class="db-mob-btn" id="mob-new-post" onclick="showTab('new-post',null);syncMobile('new-post')">
      <span class="mob-icon">✏️</span>پۆستی نوێ
    </button>
    <form method="POST" action="{{ route('portal.logout') }}" style="display:contents">
      @csrf
      <button type="submit" class="db-mob-btn">
        <span class="mob-icon">🚪</span>دەرچوون
      </button>
    </form>
  </div>
</nav>

@endsection

@section('scripts')
<script>
function showTab(name, sideBtn) {
    document.querySelectorAll('.db-tab').forEach(p => p.classList.remove('is-active'));
    document.querySelectorAll('.db-nav-btn').forEach(b => b.classList.remove('is-active'));
    document.getElementById('tab-' + name).classList.add('is-active');
    if (sideBtn) sideBtn.classList.add('is-active');
}
function syncMobile(name) {
    document.querySelectorAll('.db-mob-btn').forEach(b => b.classList.remove('is-active'));
    const mob = document.getElementById('mob-' + name);
    if (mob) mob.classList.add('is-active');
}
function previewImg(input, previewId) {
    const file = input.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = e => {
        const img = document.getElementById(previewId);
        if (img) { img.src = e.target.result; img.style.display = 'block'; }
    };
    reader.readAsDataURL(file);
}
async function autoTranslate(sourceId, targetIds, btn) {
    const text = document.getElementById(sourceId).value;
    if (!text) { alert('تکایە سەرەتا دەقەکە بنووسە.'); return; }
    btn.classList.add('loading'); btn.disabled = true;
    try {
        for (const targetId of targetIds) {
            const lang = targetId.includes('ar') ? 'ar' : 'en';
            const url  = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=ckb&tl=${lang}&dt=t&q=${encodeURIComponent(text)}`;
            const data = await (await fetch(url)).json();
            if (data?.[0]) document.getElementById(targetId).value = data[0].map(p => p[0] ?? '').join('');
        }
    } catch { alert('هەڵەیەک ڕوویدا لە کاتی وەرگێڕان.'); }
    finally { btn.classList.remove('loading'); btn.disabled = false; }
}
const TYPE_FLAGS = @json($typeFlags);
function handleTypeChange(type) {
    const section  = document.getElementById('academic-section');
    const grpCol   = document.getElementById('group-colleges');
    const grpDept  = document.getElementById('group-depts');
    const title    = document.getElementById('academic-title');
    const flags    = TYPE_FLAGS[type] || { has_colleges: false, has_departments: false };
    if (!flags.has_colleges && !flags.has_departments) {
        section.style.display = 'none'; return;
    }
    section.style.display = '';
    title.textContent     = flags.has_colleges ? 'کۆلێژ و بەشەکان' : 'بەشەکان و پارەدان';
    grpCol.style.display  = flags.has_colleges ? '' : 'none';
    grpDept.style.display = (!flags.has_colleges && flags.has_departments) ? '' : 'none';
}
let _nextCi = {{ $nextCiSeed ?? 1 }};
function addCollege() {
    const container = document.getElementById('colleges-container');
    const ci = _nextCi++;
    const card = document.createElement('div');
    card.className = 'college-card';
    card.dataset.ci = ci;
    card.innerHTML =
        `<div class="college-header">` +
          `<span class="college-badge">کۆلێژ</span>` +
          `<input type="text" name="clg[${ci}][name]" class="f-input clg-name" placeholder="بۆ نموونە: کۆلێژی ئەندازیاری">` +
          `<button type="button" class="college-del-btn" onclick="removeCollege(this)">✕</button>` +
        `</div>` +
        `<div class="college-fee-strip">` +
          `<div class="college-fee-field">` +
            `<span class="college-fee-label">پارەی کۆلێژ (دینار)</span>` +
            `<input type="text" name="clg[${ci}][fee]" class="f-input" placeholder="بۆ نموونە: 500,000">` +
          `</div>` +
          `<div class="college-fee-field">` +
            `<span class="college-fee-label">داشکاندنی کۆلێژ %</span>` +
            `<input type="text" name="clg[${ci}][discount]" class="f-input" placeholder="بۆ نموونە: 10%">` +
          `</div>` +
        `</div>` +
        `<div class="college-body">` +
          `<div class="depts-header-row">` +
            `<span class="depts-header-label">بەشەکان</span>` +
            `<span class="depts-header-line"></span>` +
          `</div>` +
          `<div class="dept-col-labels">` +
            `<span>ناوی بەش</span><span>پارە (دینار)</span><span>داشکان %</span><span></span>` +
          `</div>` +
          `<div class="depts-wrap">` +
            `<div class="dept-row">` +
              `<input type="text" name="clg[${ci}][depts][0][name]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">` +
              `<input type="text" name="clg[${ci}][depts][0][fee]" class="f-input" placeholder="150,000">` +
              `<input type="text" name="clg[${ci}][depts][0][discount]" class="f-input" placeholder="10%">` +
              `<button type="button" class="dept-del-btn" onclick="removeDept(this)">✕</button>` +
            `</div>` +
          `</div>` +
          `<button type="button" class="add-dept-btn" onclick="addDept(this)">＋ بەش زیاد بکە</button>` +
        `</div>`;
    container.appendChild(card);
    card.querySelector('input').focus();
}
function removeCollege(btn) {
    const card = btn.closest('.college-card');
    if (card.parentElement.children.length > 1) card.remove();
    else card.querySelectorAll('input').forEach(i => i.value = '');
}
function addDept(btn) {
    const card = btn.closest('.college-card');
    const ci   = card.dataset.ci;
    const wrap = card.querySelector('.depts-wrap');
    const di   = wrap.children.length;
    const row  = document.createElement('div');
    row.className = 'dept-row';
    row.innerHTML =
        `<input type="text" name="clg[${ci}][depts][${di}][name]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">` +
        `<input type="text" name="clg[${ci}][depts][${di}][fee]" class="f-input" placeholder="150,000">` +
        `<input type="text" name="clg[${ci}][depts][${di}][discount]" class="f-input" placeholder="10%">` +
        `<button type="button" class="dept-del-btn" onclick="removeDept(this)">✕</button>`;
    wrap.appendChild(row);
    row.querySelector('input').focus();
}
function removeDept(btn) {
    const row = btn.parentElement;
    if (row.parentElement.children.length > 1) row.remove();
    else row.querySelectorAll('input').forEach(i => i.value = '');
}
function addSimpleDeptRow() {
    const list = document.getElementById('depts-list');
    const row  = document.createElement('div');
    row.className = 'fee-row';
    row.innerHTML =
        `<input type="text" name="simple_dept[]" class="f-input" placeholder="بۆ نموونە: بەشی کۆمپیوتەر">` +
        `<input type="text" name="simple_fee[]" class="f-input" placeholder="150,000">` +
        `<input type="text" name="simple_discount[]" class="f-input" placeholder="10%">` +
        `<button type="button" class="dept-del-btn" onclick="removeRow(this)">✕</button>`;
    list.appendChild(row);
    row.querySelector('input').focus();
}
function removeRow(btn) {
    const row  = btn.parentElement;
    const list = row.parentElement;
    if (list.children.length > 1) row.remove();
    else row.querySelectorAll('input').forEach(i => i.value = '');
}
</script>
@endsection
