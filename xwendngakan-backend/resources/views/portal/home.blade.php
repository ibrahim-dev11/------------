@extends('portal.layout')
@section('title', 'EduBook — پلاتفۆرمی پەروەردەیی کوردستان')

@section('styles')
<style>
/* ════════════ ANIMATIONS ════════════ */
@keyframes fadeUp { from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:none} }
@keyframes glow   { 0%,100%{opacity:.4}50%{opacity:.8} }
@keyframes ping   { 75%,100%{transform:scale(2);opacity:0} }

.fade-up  { animation:fadeUp .65s cubic-bezier(.22,1,.36,1) both; }
.delay-1  { animation-delay:.08s; } .delay-2 { animation-delay:.16s; }
.delay-3  { animation-delay:.24s; } .delay-4 { animation-delay:.32s; }

.sr { opacity:0;transform:translateY(22px);transition:opacity .55s cubic-bezier(.22,1,.36,1),transform .55s cubic-bezier(.22,1,.36,1); }
.sr.in { opacity:1;transform:none; }
.sr.d1{transition-delay:.07s}.sr.d2{transition-delay:.14s}.sr.d3{transition-delay:.21s}
.sr.d4{transition-delay:.28s}.sr.d5{transition-delay:.35s}.sr.d6{transition-delay:.42s}

/* ════════════ HERO ════════════ */
.hero {
    position:relative; padding:8rem 1.5rem 6rem;
    text-align:center; overflow:hidden;
    background:var(--bg);
}
/* gold radial glow */
.hero::before {
    content:''; position:absolute; inset:0; pointer-events:none;
    background:
        radial-gradient(ellipse 70% 50% at 50% -10%, rgba(183,137,54,.18) 0%, transparent 65%),
        radial-gradient(ellipse 40% 40% at 10% 95%, rgba(183,137,54,.07) 0%, transparent 60%),
        radial-gradient(ellipse 40% 40% at 90% 90%, rgba(183,137,54,.06) 0%, transparent 60%);
}
/* grid pattern */
.hero::after {
    content:''; position:absolute; inset:0; pointer-events:none;
    background-image:
        linear-gradient(rgba(183,137,54,.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(183,137,54,.04) 1px, transparent 1px);
    background-size:48px 48px;
    mask-image:radial-gradient(ellipse 80% 70% at 50% 50%, black 30%, transparent 100%);
}

.hero-inner { position:relative;z-index:1;max-width:680px;margin:0 auto; }

.hero-badge {
    display:inline-flex;align-items:center;gap:9px;
    background:rgba(183,137,54,.1); color:var(--gold-lt);
    border:1px solid var(--border2); border-radius:50px;
    padding:6px 18px; font-size:.8rem; font-weight:800;
    margin-bottom:1.75rem; letter-spacing:.3px;
}
.badge-dot { position:relative;width:8px;height:8px; }
.badge-dot span { display:block;width:8px;height:8px;border-radius:50%;background:var(--gold); }
.badge-dot::after {
    content:'';position:absolute;inset:0;border-radius:50%;
    background:rgba(183,137,54,.5); animation:ping 2s cubic-bezier(0,0,.2,1) infinite;
}

.hero-title {
    font-size:clamp(2rem,6vw,3.75rem);
    font-weight:800;line-height:1.18;color:var(--txt);
    margin-bottom:1.25rem;letter-spacing:-.5px;
}
.hero-title .hl {
    background:linear-gradient(130deg, var(--gold-lt) 0%, var(--gold) 50%, var(--gold-dk) 100%);
    -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
}

.hero-sub {
    font-size:1.05rem;color:var(--txt2);
    max-width:460px;margin:0 auto 2.5rem;line-height:2;
}

.hero-btns { display:flex;gap:.85rem;justify-content:center;flex-wrap:wrap;margin-bottom:3.5rem; }

.hbtn-primary {
    display:inline-flex;align-items:center;gap:8px;
    padding:13px 30px;border-radius:12px;
    background:var(--grad);color:#fff;
    font-family:inherit;font-size:.95rem;font-weight:800;
    text-decoration:none;border:1px solid var(--border2);
    transition:opacity .2s,transform .2s;
}
.hbtn-primary:hover { opacity:.88;transform:translateY(-2px); }

.hbtn-ghost {
    display:inline-flex;align-items:center;gap:8px;
    padding:13px 30px;border-radius:12px;
    background:rgba(183,137,54,.06);color:var(--txt2);
    font-family:inherit;font-size:.95rem;font-weight:700;
    text-decoration:none;border:1px solid var(--border);
    transition:border-color .2s,color .2s,transform .2s;
}
.hbtn-ghost:hover { border-color:var(--gold);color:var(--gold);transform:translateY(-2px); }

.stats-bar {
    display:flex;max-width:440px;margin:0 auto;
    border:1px solid var(--border);border-radius:16px;overflow:hidden;
    background:var(--bg2);
}
.stat-cell { flex:1;padding:1.25rem .75rem;text-align:center; }
.stat-cell + .stat-cell { border-right:1px solid var(--border); }
.stat-n {
    font-size:1.55rem;font-weight:800;line-height:1;
    color:var(--gold);
}
.stat-l { font-size:.73rem;color:var(--txt3);margin-top:5px;font-weight:600; }

/* ════════════ SECTIONS ════════════ */
.sec     { padding:5.5rem 1.5rem;max-width:1080px;margin:0 auto; }
.sec-alt { border-top:1px solid var(--border);border-bottom:1px solid var(--border);background:var(--bg2); }
.sec-alt-inner { padding:5.5rem 1.5rem;max-width:1080px;margin:0 auto; }

.sec-head { margin-bottom:3rem; }
.sec-tag {
    display:inline-flex;align-items:center;gap:7px;
    font-size:.7rem;font-weight:800;letter-spacing:3px;
    text-transform:uppercase;color:var(--gold);margin-bottom:.65rem;
}
.sec-tag::before { content:'';width:16px;height:2px;border-radius:2px;background:var(--gold); }
.sec-title { font-size:clamp(1.5rem,3.5vw,2.2rem);font-weight:800;color:var(--txt);line-height:1.3; }
.sec-sub   { color:var(--txt2);margin-top:.5rem;font-size:.95rem;line-height:1.85; }

/* ════════════ FEATURE CARDS ════════════ */
.feat-grid { display:grid;grid-template-columns:repeat(3,1fr);gap:1rem; }
.feat-card {
    background:var(--bg2);
    border:1px solid var(--border);border-radius:16px;
    padding:1.75rem 1.5rem;
    transition:border-color .25s,transform .3s cubic-bezier(.22,1,.36,1);
}
.feat-card:hover { border-color:var(--border2);transform:translateY(-4px); }
.feat-icon {
    width:48px;height:48px;border-radius:12px;
    background:rgba(183,137,54,.1);border:1px solid var(--border);
    display:flex;align-items:center;justify-content:center;
    font-size:1.4rem;margin-bottom:1.1rem;
}
.feat-name { font-size:.95rem;font-weight:800;color:var(--txt);margin-bottom:.4rem; }
.feat-desc { font-size:.84rem;color:var(--txt2);line-height:1.9; }

/* ════════════ STEPS ════════════ */
.steps-grid { display:grid;grid-template-columns:repeat(3,1fr);gap:1.25rem;position:relative; }
.steps-grid::before {
    content:'';position:absolute;top:33px;right:calc(16.6% + 14px);left:calc(16.6% + 14px);
    height:1px;background:linear-gradient(90deg,transparent,var(--border2),transparent);
}
.step-card {
    background:var(--bg);border:1px solid var(--border);border-radius:16px;
    padding:2rem 1.5rem;text-align:center;
    transition:border-color .25s,transform .3s cubic-bezier(.22,1,.36,1);
}
.step-card:hover { border-color:var(--border2);transform:translateY(-4px); }
.step-num {
    width:46px;height:46px;border-radius:50%;
    background:var(--grad);color:#fff;
    font-size:1rem;font-weight:800;
    display:flex;align-items:center;justify-content:center;
    margin:0 auto 1.1rem;position:relative;z-index:1;
    border:2px solid rgba(183,137,54,.3);
}
.step-name { font-size:.95rem;font-weight:800;color:var(--txt);margin-bottom:.4rem; }
.step-desc { font-size:.83rem;color:var(--txt2);line-height:1.9; }

/* ════════════ CTA ════════════ */
.cta-section { padding:5.5rem 1.5rem; }
.cta-box {
    max-width:720px;margin:0 auto;
    background:var(--bg2);
    border:1px solid var(--border2);border-radius:24px;
    padding:4.5rem 2.5rem;text-align:center;
    position:relative;overflow:hidden;
}
.cta-box::before {
    content:'';position:absolute;inset:0;pointer-events:none;
    background:
        radial-gradient(ellipse 70% 60% at 50% 0%, rgba(183,137,54,.12), transparent),
        radial-gradient(ellipse 40% 40% at 90% 100%, rgba(183,137,54,.07), transparent);
}
.cta-inner { position:relative;z-index:1; }
.cta-icon  { font-size:2.5rem;display:block;margin-bottom:.9rem; }
.cta-title { font-size:clamp(1.4rem,3.5vw,2rem);font-weight:800;color:var(--txt);margin-bottom:.7rem; }
.cta-sub   { color:var(--txt2);font-size:.95rem;line-height:1.85;margin-bottom:2rem; }
.btn-cta {
    display:inline-flex;align-items:center;gap:8px;
    background:var(--grad);color:#fff;
    padding:13px 32px;border-radius:12px;
    font-family:inherit;font-size:.95rem;font-weight:800;
    text-decoration:none;border:1px solid var(--border2);
    transition:opacity .2s,transform .2s;
}
.btn-cta:hover { opacity:.88;transform:translateY(-2px); }

/* ════════════ FOOTER ════════════ */
.site-footer {
    border-top:1px solid var(--border);
    padding:2rem 1.5rem;text-align:center;
    background:var(--bg2);color:var(--txt3);font-size:.83rem;
}
.site-footer a { color:var(--gold);text-decoration:none;font-weight:700; }
.site-footer a:hover { color:var(--gold-lt); }

/* ════════════ RESPONSIVE ════════════ */
@media (max-width:900px) { .feat-grid{grid-template-columns:repeat(2,1fr);} .steps-grid{grid-template-columns:1fr;} .steps-grid::before{display:none;} }
@media (max-width:580px) { .feat-grid{grid-template-columns:1fr;} .hbtn-primary,.hbtn-ghost{width:100%;justify-content:center;} .hero-btns{flex-direction:column;} .cta-box{padding:3rem 1.25rem;border-radius:16px;} .hero{padding:6rem 1.25rem 4.5rem;} }
</style>
@endsection

@section('content')

{{-- ═══════ HERO ═══════ --}}
<section class="hero">
    <div class="hero-inner">
        <div class="hero-badge fade-up">
            <div class="badge-dot"><span></span></div>
            پلاتفۆرمی ژمارە یەکی پەروەردەیی کوردستان
        </div>

        <h1 class="hero-title fade-up delay-1">
            دامەزراوەکەت<br>
            <span class="hl">دیجیتاڵ بکە</span> لەگەڵ EduBook
        </h1>

        <p class="hero-sub fade-up delay-2">
            پلاتفۆرمی پەروەردەیی بۆ خوێندنگا، کۆلێژ و ناوەندەکان —
            تۆمار بکە، بڵاوبکەرەوە، خوێندکار بکێشەرەوە
        </p>

        <div class="hero-btns fade-up delay-3">
            <a href="{{ route('portal.register') }}" class="hbtn-primary">🎓 تۆمارکردنی بەخۆڕایی</a>
            <a href="{{ route('portal.login') }}"    class="hbtn-ghost">چوونەژوورەوە ←</a>
        </div>

        <div class="stats-bar fade-up delay-4">
            <div class="stat-cell">
                <div class="stat-n">٥٠٠+</div>
                <div class="stat-l">دامەزراوە</div>
            </div>
            <div class="stat-cell">
                <div class="stat-n">١٢٠+</div>
                <div class="stat-l">شار</div>
            </div>
            <div class="stat-cell">
                <div class="stat-n">بەخۆڕایی</div>
                <div class="stat-l">تەواو</div>
            </div>
        </div>
    </div>
</section>

{{-- ═══════ FEATURES ═══════ --}}
<div class="sec">
    <div class="sec-head">
        <div class="sec-tag sr">تایبەتمەندییەکان</div>
        <h2 class="sec-title sr d1">هەموو ئەوەی دامەزراوەکەت پێویستیەتی</h2>
        <p  class="sec-sub  sr d2">ئامرازی کامل بۆ بەڕێوەبردنی ئۆنلاینی دامەزراوەکەت</p>
    </div>
    <div class="feat-grid">
        <div class="feat-card sr d1">
            <div class="feat-icon">🏫</div>
            <div class="feat-name">پرۆفایلی دامەزراوە</div>
            <div class="feat-desc">ناو، جۆر، ناونیشان، پەیوەندی و لینکی کۆمەڵایەتی تۆمار بکە بە شێوەیەکی پیشەیی</div>
        </div>
        <div class="feat-card sr d2">
            <div class="feat-icon">📝</div>
            <div class="feat-name">بەڕێوەبردنی پۆست</div>
            <div class="feat-desc">هەواڵ، ئیلان و بابەتەکانت بڵاوبکەرەوە بۆ خوێندکارانت لە هەر کاتێک</div>
        </div>
        <div class="feat-card sr d3">
            <div class="feat-icon">📱</div>
            <div class="feat-name">ئەپی موبایل</div>
            <div class="feat-desc">دامەزراوەکەت لە ئەپی EduBook دیار دەبێت بۆ ملیۆنان خوێندکاری کوردستان</div>
        </div>
        <div class="feat-card sr d4">
            <div class="feat-icon">✅</div>
            <div class="feat-name">سیستەمی پەسەندکردن</div>
            <div class="feat-desc">تیمی ئەدمین زانیارییەکانت پشتڕاست دەکاتەوە پێش دیارکردن لە ئەپەکەدا</div>
        </div>
        <div class="feat-card sr d5">
            <div class="feat-icon">🔍</div>
            <div class="feat-name">گەڕان و دیتن</div>
            <div class="feat-desc">خوێندکاران بە ئاسانی دامەزراوەکەت دۆزنەوە لە نێو گەڕانی زیرەک</div>
        </div>
        <div class="feat-card sr d6">
            <div class="feat-icon">🆓</div>
            <div class="feat-name">بەخۆڕایی تەواو</div>
            <div class="feat-desc">هیچ کرێیەک نییە — تۆمارکردن و بەکارهێنان بەتەواوی بەخۆڕایی و بەردەوامە</div>
        </div>
    </div>
</div>

{{-- ═══════ HOW IT WORKS ═══════ --}}
<div class="sec-alt">
    <div class="sec-alt-inner">
        <div class="sec-head">
            <div class="sec-tag sr">چۆن کار دەکات</div>
            <h2 class="sec-title sr d1">سێ هەنگاوی سادە</h2>
            <p  class="sec-sub  sr d2">لە کەمتر لە ٥ خولەک دامەزراوەکەت ئۆنلاین بکە</p>
        </div>
        <div class="steps-grid">
            <div class="step-card sr d1">
                <div class="step-num">١</div>
                <div class="step-name">هەژمار دروستبکە</div>
                <div class="step-desc">ناو، ئیمەیڵ و وشەی نهێنیت داخڵ بکە — تەنها ٣٠ چرکە دەکات</div>
            </div>
            <div class="step-card sr d2">
                <div class="step-num">٢</div>
                <div class="step-name">دامەزراوەکەت تۆمار بکە</div>
                <div class="step-desc">زانیارییەکانی دامەزراوەکەت پڕ بکەرەوە و پرۆفایلت ئامادە بکە</div>
            </div>
            <div class="step-card sr d3">
                <div class="step-num">٣</div>
                <div class="step-name">بڵاوکردنەوە دەستبکە</div>
                <div class="step-desc">هەواڵ، ئیلان و پۆستەکانت بڵاوبکەرەوە — خوێندکارانت لە ئەپەکەدا دەتبیننەوە</div>
            </div>
        </div>
    </div>
</div>

{{-- ═══════ CTA ═══════ --}}
<div class="cta-section">
    <div class="cta-box sr">
        <div class="cta-inner">
            <span class="cta-icon">🎓</span>
            <h2 class="cta-title">ئامادەیت؟ ئێستا دەستپێبکە!</h2>
            <p class="cta-sub">بە بەخۆڕایی تۆمار بکە و دامەزراوەکەت لە ئەپی EduBook<br>دیار بکە بۆ ملیۆنان خوێندکاری کوردستان</p>
            <a href="{{ route('portal.register') }}" class="btn-cta">🎓 تۆمارکردنی بەخۆڕایی</a>
        </div>
    </div>
</div>

{{-- ═══════ FOOTER ═══════ --}}
<footer class="site-footer">
    <p>© {{ date('Y') }} <strong style="color:var(--gold)">EduBook</strong> — هەموو مافەکان پارێزراون &nbsp;·&nbsp;
       <a href="{{ route('portal.login') }}">چوونەژوورەوە</a></p>
</footer>

@endsection

@section('scripts')
<script>
(function(){
    const io = new IntersectionObserver(entries=>{
        entries.forEach(e=>{ if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { threshold:0.1 });
    document.querySelectorAll('.sr').forEach(el=>io.observe(el));
})();
</script>
@endsection
