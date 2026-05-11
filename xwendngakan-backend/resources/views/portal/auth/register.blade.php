@extends('portal.layout')
@section('title', 'تۆمارکردن — EduBook')
@section('styles')
<style>
.auth-page {
    min-height:calc(100vh - 66px);display:flex;align-items:center;justify-content:center;
    padding:2.5rem 1.5rem;background:var(--bg);
    background-image:
        radial-gradient(ellipse 60% 50% at 50% 0%, rgba(183,137,54,.1) 0%, transparent 60%);
}
.auth-card {
    width:100%;max-width:450px;
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
.form-err { font-size:.78rem;color:var(--red);margin-top:4px; }
.btn-full {
    width:100%;justify-content:center;padding:12px;font-size:.95rem;
    border-radius:11px;background:var(--grad);color:#fff;
    font-family:inherit;font-weight:800;border:1px solid var(--border2);
    cursor:pointer;transition:opacity .15s;
}
.btn-full:hover { opacity:.88; }
.auth-link { text-align:center;font-size:.86rem;color:var(--txt2);margin-top:1.25rem; }
.auth-link a { color:var(--gold);font-weight:700;text-decoration:none; }
.auth-link a:hover { color:var(--gold-lt); }
</style>
@endsection
@section('content')
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-header">
      <div class="auth-logo">🎓</div>
      <h1 class="auth-title">هەژمار دروست بکە</h1>
      <p class="auth-sub">بەخۆڕایی — لە کەمتر لە یەک خولەک</p>
    </div>
    @if($errors->any())
      <div class="alert alert-error">⚠ {{ $errors->first() }}</div>
    @endif
    <form method="POST" action="{{ route('portal.register.submit') }}">
      @csrf
      <div class="form-group">
        <label class="form-label" for="name">ناوی تەواو</label>
        <input id="name" type="text" name="name" class="form-input {{ $errors->has('name') ? 'err' : '' }}" placeholder="ناوی تەواوت داخڵ بکە" value="{{ old('name') }}" required>
        @error('name')<div class="form-err">{{ $message }}</div>@enderror
      </div>
      <div class="form-group">
        <label class="form-label" for="email">ئیمەیڵ</label>
        <input id="email" type="email" name="email" class="form-input {{ $errors->has('email') ? 'err' : '' }}" placeholder="example@email.com" value="{{ old('email') }}" required>
        @error('email')<div class="form-err">{{ $message }}</div>@enderror
      </div>
      <div class="form-group">
        <label class="form-label" for="password">وشەی نهێنی</label>
        <input id="password" type="password" name="password" class="form-input {{ $errors->has('password') ? 'err' : '' }}" placeholder="وشەی نهێنیت داخڵ بکە" required>
        @error('password')<div class="form-err">{{ $message }}</div>@enderror
      </div>
      <div class="form-group">
        <label class="form-label" for="password_confirmation">دووبارەکردنەوەی وشەی نهێنی</label>
        <input id="password_confirmation" type="password" name="password_confirmation" class="form-input" placeholder="وشەی نهێنی دووبارە بنووسە" required>
      </div>
      <button type="submit" class="btn-full">🎓 دروستکردنی هەژمار</button>
    </form>
    <div class="auth-link">پێشتر هەژمارت هەیە؟ <a href="{{ route('portal.login') }}">چوونەژوورەوە</a></div>
  </div>
</div>
@endsection
