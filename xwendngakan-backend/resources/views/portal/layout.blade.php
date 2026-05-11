<!DOCTYPE html>
<html lang="ku" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'EduBook — پلاتفۆرمی پەروەردەیی')</title>
    <meta name="description" content="EduBook — تۆمارکردنی دامەزراوەت و بەڕێوەبردنی پۆستەکانت بە ئاسانی">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Naskh+Arabic:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        :root {
            --gold:    #b78936;
            --gold-lt: #d4a84b;
            --gold-dk: #8a6520;
            --bg:      #0d1117;
            --bg2:     #161b22;
            --bg3:     #1c2230;
            --border:  rgba(183,137,54,.18);
            --border2: rgba(183,137,54,.35);
            --txt:     #f0f0f0;
            --txt2:    #a0a8b8;
            --txt3:    #5a6278;
            --red:     #ff4d4d;
            --green:   #2dbe6c;
            --grad:    linear-gradient(135deg, var(--gold-dk), var(--gold));
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Noto Naskh Arabic', sans-serif;
            background: var(--bg);
            color: var(--txt);
            min-height: 100vh;
            direction: rtl;
            line-height: 1.75;
            overflow-x: hidden;
        }

        /* ===== SCROLLBAR ===== */
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: var(--bg2); }
        ::-webkit-scrollbar-thumb { background: rgba(183,137,54,.3); border-radius: 4px; }

        /* ===== NAVBAR ===== */
        .navbar {
            position: fixed; top: 0; right: 0; left: 0; z-index: 1000;
            padding: 0 2.5rem; height: 66px;
            display: flex; align-items: center; justify-content: space-between;
            background: rgba(13,17,23,.88);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border);
        }
        .nav-brand { display:flex; align-items:center; gap:10px; text-decoration:none; }
        .nav-logo {
            width: 36px; height: 36px; border-radius: 10px;
            background: var(--grad);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; border: 1px solid var(--border2);
        }
        .nav-brand-text { font-size: 1.25rem; font-weight: 800; color: var(--txt); }
        .nav-brand-text span { color: var(--gold); }

        .nav-links { display: flex; align-items: center; gap: .75rem; }

        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 20px; border-radius: 10px;
            font-family: inherit; font-size: .9rem; font-weight: 700;
            cursor: pointer; text-decoration: none; border: none;
            transition: all .2s;
        }
        .btn-ghost {
            background: transparent; color: var(--txt2);
            border: 1px solid var(--border);
        }
        .btn-ghost:hover { border-color: var(--gold); color: var(--gold); background: rgba(183,137,54,.08); }
        .btn-primary {
            background: var(--grad); color: #fff;
            border: 1px solid var(--border2);
        }
        .btn-primary:hover { opacity: .88; }
        .btn-sm { padding: 5px 14px; font-size: .82rem; border-radius: 8px; }

        /* ===== ALERTS ===== */
        .alert {
            padding: 11px 15px; border-radius: 10px;
            margin-bottom: 1.1rem; font-size: .88rem;
            border: 1px solid; display: flex; align-items: center; gap: 9px;
        }
        .alert-success { background: rgba(45,190,108,.1);  border-color: rgba(45,190,108,.3); color: #34d399; }
        .alert-error   { background: rgba(255,77,77,.1);   border-color: rgba(255,77,77,.3);  color: #ff8080; }
        .alert-warning { background: rgba(183,137,54,.1);  border-color: var(--border2);      color: var(--gold-lt); }

        /* ===== PAGE WRAPPER ===== */
        .page-wrapper { padding-top: 66px; min-height: 100vh; }

        @media (max-width: 640px) {
            .navbar { padding: 0 1rem; }
        }
    </style>
    @yield('styles')
</head>
<body>
    <nav class="navbar">
        <a href="{{ route('portal.home') }}" class="nav-brand">
            <div class="nav-logo">📚</div>
            <div class="nav-brand-text"><span>Edu</span>Book</div>
        </a>
        <div class="nav-links">
            @auth
                @if(auth()->user()->is_approved)
                <a href="{{ route('portal.dashboard') }}" class="btn btn-ghost">داشبۆرد</a>
                @endif
                <form method="POST" action="{{ route('portal.logout') }}" style="display:inline">
                    @csrf
                    <button type="submit" class="btn btn-ghost">دەرچوون</button>
                </form>
            @else
                <a href="{{ route('portal.login') }}" class="btn btn-ghost">چوونەژوورەوە</a>
                <a href="{{ route('portal.register') }}" class="btn btn-primary">تۆمارکردن</a>
            @endauth
        </div>
    </nav>

    <div class="page-wrapper">
        @yield('content')
    </div>

    @yield('scripts')
</body>
</html>
