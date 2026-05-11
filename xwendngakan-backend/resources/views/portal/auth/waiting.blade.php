@extends('portal.layout')
@section('title', 'چاوەڕوانی پەسەندکردن — EduBook')
@section('styles')
<style>
@keyframes pulse {
    0%  { transform:scale(1); box-shadow:0 0 0 0 rgba(183,137,54,.4); }
    70% { transform:scale(1.05); box-shadow:0 0 0 14px rgba(183,137,54,0); }
    100%{ transform:scale(1); box-shadow:0 0 0 0 rgba(183,137,54,0); }
}
.waiting-page {
    min-height:calc(100vh - 66px);display:flex;align-items:center;justify-content:center;
    padding:2.5rem 1.5rem;background:var(--bg);
    background-image:radial-gradient(ellipse 60% 50% at 50% 0%, rgba(183,137,54,.08) 0%, transparent 60%);
}
.waiting-card {
    width:100%;max-width:500px;
    background:var(--bg2);border:1px solid var(--border2);
    border-radius:22px;padding:3rem 2rem;text-align:center;
}
.status-icon {
    width:80px;height:80px;border-radius:50%;
    background:rgba(183,137,54,.12);border:2px solid var(--border2);
    display:flex;align-items:center;justify-content:center;
    font-size:2.4rem;margin:0 auto 1.5rem;
    animation:pulse 2.5s infinite;
}
.waiting-title { font-size:1.6rem;font-weight:800;color:var(--txt);margin-bottom:1rem; }
.waiting-desc  { color:var(--txt2);font-size:.95rem;line-height:1.85;margin-bottom:2rem; }
.waiting-steps {
    text-align:right;background:rgba(183,137,54,.05);
    border:1px solid var(--border);border-radius:14px;
    padding:1.35rem;margin-bottom:2rem;
}
.step-item {
    display:flex;align-items:center;gap:11px;
    margin-bottom:11px;font-size:.9rem;color:var(--txt2);
}
.step-item:last-child { margin-bottom:0; }
.step-dot { width:7px;height:7px;border-radius:50%;background:var(--gold);flex-shrink:0; }
.btn-logout {
    display:inline-flex;align-items:center;gap:8px;
    color:var(--txt3);font-size:.88rem;font-family:inherit;
    background:none;border:none;cursor:pointer;transition:color .2s;
}
.btn-logout:hover { color:var(--red); }
</style>
@endsection
@section('content')
<div class="waiting-page">
    <div class="waiting-card">
        <div class="status-icon">⏳</div>
        <h1 class="waiting-title">هەژمارەکەت لە ژێر چاوخشاندنەوەدایە</h1>
        <p class="waiting-desc">
            سوپاس بۆ ناونووسین! زانیارییەکانی تۆ نێردراوە بۆ بەڕێوەبەر.<br>
            تکایە چاوەڕوان بە تا هەژمارەکەت پەسەند دەکرێت.
        </p>
        <div class="waiting-steps">
            <div class="step-item"><span class="step-dot"></span>زانیارییەکانت وەرگیرا ✅</div>
            <div class="step-item"><span class="step-dot"></span>ئەدمین تێپەڕوی دەکات ⏳</div>
            <div class="step-item"><span class="step-dot"></span>پاش پەسەندکردن دەتوانیت پۆست بکەیت</div>
        </div>
        <form method="POST" action="{{ route('portal.logout') }}">
            @csrf
            <button type="submit" class="btn-logout">🚪 دەرچوون</button>
        </form>
    </div>
</div>
@endsection
