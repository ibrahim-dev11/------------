@extends('portal.layout')
@section('title', 'چوونەژوورەوە — EduBook')

@section('styles')
<style>
.auth-page {
    min-height:calc(100vh - 66px);display:flex;align-items:center;justify-content:center;
    padding:2.5rem 1.5rem;background:var(--bg);
    background-image:
        radial-gradient(ellipse 60% 50% at 50% 0%, rgba(183,137,54,.1) 0%, transparent 60%);
}
.auth-card {
    width:100%;max-width:420px;
    background:var(--bg2);border:1px solid var(--border);
    border-radius:20px;padding:2.5rem;
}
.auth-header { text-align:center;margin-bottom:2rem; }
.auth-logo {
    width:56px;height:56px;background:var(--grad);
    border:1px solid var(--border2);border-radius:14px;
    display:flex;align-items:center;justify-content:center;
    font-size:1.6rem;margin:0 auto 1rem;
}
.auth-title { font-size:1.5rem;font-weight:800;color:var(--txt);margin-bottom:.3rem; }
.auth-sub   { color:var(--txt2);font-size:.88rem; }
.form-group { margin-bottom:1rem; }
.form-label { display:block;font-size:.82rem;font-weight:700;color:var(--txt2);margin-bottom:6px; }
.form-input {
    width:100%;padding:11px 14px;
    background:rgba(74,80,88,.25);border:1px solid rgba(183,137,54,.12);
    border-radius:10px;color:var(--txt);
    font-family:inherit;font-size:.92rem;outline:none;
    transition:border-color .15s,background .15s;direction:rtl;
}
.form-input:focus { border-color:var(--gold);background:rgba(74,80,88,.35); }
.form-input::placeholder { color:var(--txt3); }
.form-input.err { border-color:var(--red); }
.remember-row { display:flex;align-items:center;gap:8px;margin-bottom:1.35rem; }
.remember-row input { accent-color:var(--gold);width:15px;height:15px;cursor:pointer; }
.remember-row label { font-size:.85rem;color:var(--txt2);cursor:pointer; }
.btn-full {
    width:100%;justify-content:center;padding:12px;font-size:.95rem;
    border-radius:11px;background:var(--grad);color:#fff;
    font-family:inherit;font-weight:800;border:1px solid var(--border2);
    cursor:pointer;transition:opacity .15s;
}
.btn-full:hover { opacity:.88; }
.divider { display:flex;align-items:center;gap:12px;margin:1.35rem 0;color:var(--txt3);font-size:.8rem; }
.divider::before,.divider::after { content:'';flex:1;height:1px;background:var(--border); }
.auth-link { text-align:center;font-size:.86rem;color:var(--txt2); }
.auth-link a { color:var(--gold);font-weight:700;text-decoration:none; }
.auth-link a:hover { color:var(--gold-lt); }
</style>
@endsection

@section('content')
<div class="auth-page">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-logo">📚</div>
            <h1 class="auth-title">بەخێربێیتەوە</h1>
            <p class="auth-sub">بچووە ژوورەوە بۆ بەڕێوەبردنی دامەزراوەکەت</p>
        </div>

        @if(session('success'))
            <div class="alert alert-success">✅ {{ session('success') }}</div>
        @endif
        @if($errors->any())
            <div class="alert alert-error">⚠ {{ $errors->first() }}</div>
        @endif

        <form method="POST" action="{{ route('portal.login.submit') }}">
            @csrf
            <div class="form-group">
                <label class="form-label" for="email">ئیمەیڵ</label>
                <input id="email" type="email" name="email" class="form-input {{ $errors->has('email') ? 'err' : '' }}"
                    placeholder="example@email.com" value="{{ old('email') }}" required autocomplete="email">
            </div>
            <div class="form-group">
                <label class="form-label" for="password">وشەی نهێنی</label>
                <input id="password" type="password" name="password" class="form-input"
                    placeholder="••••••••" required autocomplete="current-password">
            </div>
            <div class="remember-row">
                <input type="checkbox" id="remember" name="remember">
                <label for="remember">لە بیرم بهێلەرەوە</label>
            </div>
            <button type="submit" class="btn-full">چوونەژوورەوە ←</button>
        </form>

        <div class="divider">یان</div>

        <div class="auth-link">
            هەژمارت نییە؟ <a href="{{ route('portal.register') }}">ئێستا تۆمار بکە</a>
        </div>
    </div>
</div>
@endsection
