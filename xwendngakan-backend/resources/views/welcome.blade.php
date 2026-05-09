<!DOCTYPE html>
<html lang="ku" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>edu book - پلاتفۆرمی پەروەردەیی مۆدێرن</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Kufi+Arabic:wght@100..900&family=Plus+Jakarta+Sans:wght@200..800&display=swap" rel="stylesheet">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        arabic: ['"Noto Kufi Arabic"', 'sans-serif'],
                        sans: ['"Plus Jakarta Sans"', '"Noto Kufi Arabic"', 'sans-serif'],
                    },
                    colors: {
                        brand: {
                            50: '#f0f9ff',
                            100: '#e0f2fe',
                            200: '#bae6fd',
                            300: '#7dd3fc',
                            400: '#38bdf8',
                            500: '#0ea5e9',
                            600: '#0284c7',
                            700: '#0369a1',
                            800: '#075985',
                            900: '#0c4a6e',
                        },
                        accent: {
                            500: '#6366f1',
                            600: '#4f46e5',
                        }
                    },
                    animation: {
                        'float': 'float 6s ease-in-out infinite',
                        'reveal': 'reveal 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards',
                    },
                    keyframes: {
                        float: {
                            '0%, 100%': { transform: 'translateY(0)' },
                            '50%': { transform: 'translateY(-20px)' },
                        },
                        reveal: {
                            '0%': { opacity: '0', transform: 'translateY(20px)' },
                            '100%': { opacity: '1', transform: 'translateY(0)' },
                        }
                    }
                }
            }
        }
    </script>

    <style>
        body {
            font-family: 'Noto Kufi Arabic', 'Plus Jakarta Sans', sans-serif;
            background-color: #fcfcfd;
            overflow-x: hidden;
            scroll-behavior: smooth;
        }

        .glass-nav {
            background: rgba(252, 252, 253, 0.8);
            backdrop-filter: blur(12px) saturate(180%);
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .mesh-gradient {
            background-color: #fcfcfd;
            background-image: 
                radial-gradient(at 0% 0%, rgba(14, 165, 233, 0.05) 0px, transparent 50%),
                radial-gradient(at 100% 0%, rgba(99, 102, 241, 0.05) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(14, 165, 233, 0.05) 0px, transparent 50%),
                radial-gradient(at 0% 100%, rgba(99, 102, 241, 0.05) 0px, transparent 50%);
        }

        .premium-card {
            background: white;
            border: 1px solid rgba(0, 0, 0, 0.04);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02), 0 10px 15px -3px rgba(0, 0, 0, 0.03);
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .premium-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 10px 10px -5px rgba(0, 0, 0, 0.02);
            border-color: rgba(14, 165, 233, 0.2);
        }

        .btn-premium {
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .btn-premium::after {
            content: '';
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: linear-gradient(120deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transform: translateX(-100%);
            transition: 0.6s;
        }

        .btn-premium:hover::after { transform: translateX(100%); }

        [x-cloak] { display: none !important; }

        .reveal-on-scroll {
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .reveal-on-scroll.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .dir-ltr { direction: ltr; }
    </style>
</head>
<body class="mesh-gradient min-h-screen text-slate-900" 
      x-data="{ 
        showLogin: new URLSearchParams(window.location.search).has('login'), 
        showRegister: false,
        scrolled: false
      }"
      @scroll.window="scrolled = (window.pageYOffset > 20)"
      x-init="
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) entry.target.classList.add('is-visible');
            });
        }, { threshold: 0.1 });
        $nextTick(() => {
            document.querySelectorAll('.reveal-on-scroll').forEach(el => observer.observe(el));
        });
      ">

    <!-- Navigation -->
    <nav class="fixed top-0 left-0 right-0 z-[60] transition-all duration-500"
         :class="scrolled ? 'glass-nav py-3 shadow-sm' : 'py-6'">
        <div class="max-w-7xl mx-auto px-6 flex items-center justify-between">
            <div class="flex items-center gap-4 group cursor-pointer" onclick="window.location.href='/'">
                <div class="w-12 h-12 bg-gradient-to-br from-brand-500 to-brand-700 rounded-2xl flex items-center justify-center text-white font-bold text-2xl shadow-lg shadow-brand-200 group-hover:rotate-6 transition-transform">
                    eb
                </div>
                <div class="flex flex-col">
                    <span class="text-xl font-black tracking-tight text-slate-900 leading-none">edu book</span>
                    <span class="text-[10px] uppercase tracking-[0.2em] font-bold text-brand-600 mt-1 opacity-70 italic">پەروەردەیەکی جیاواز</span>
                </div>
            </div>
            
            <div class="hidden md:flex items-center gap-10">
                <div class="flex items-center gap-8 text-sm font-bold text-slate-500">
                    <a href="#about" class="hover:text-brand-600 transition-colors">دەربارە</a>
                    <a href="#features" class="hover:text-brand-600 transition-colors">تایبەتمەندییەکان</a>
                    <a href="#tutorial" class="hover:text-brand-600 transition-colors">چۆنیەتی بەکارهێنان</a>
                    @auth
                        @if($institution)
                            <a href="#join" class="text-brand-600 flex items-center gap-2">
                                <span class="w-2 h-2 bg-brand-500 rounded-full animate-pulse"></span>
                                پانێڵی بەڕێوەبردن
                            </a>
                        @endif
                    @endauth
                </div>

                <div class="h-6 w-px bg-slate-200"></div>
                
                @auth
                    <div class="flex items-center gap-5">
                        <div class="flex items-center gap-3 bg-white/50 border border-slate-100 rounded-full px-4 py-1.5 shadow-sm">
                            <div class="w-7 h-7 bg-brand-100 rounded-full flex items-center justify-center text-brand-600">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                            </div>
                            <span class="text-sm font-bold text-slate-700">{{ auth()->user()->name }}</span>
                        </div>
                        <form action="{{ route('logout') }}" method="POST" class="inline">
                            @csrf
                            <button type="submit" class="text-rose-500 hover:text-rose-600 font-bold text-sm transition-colors">چوونەدەرەوە</button>
                        </form>
                    </div>
                @else
                    <button @click="showLogin = true" class="btn-premium px-8 py-3 bg-brand-600 text-white rounded-2xl font-black text-sm shadow-xl shadow-brand-100 hover:bg-brand-700 hover:scale-[1.02] active:scale-95 transition-all">
                        چوونەژوورەوە
                    </button>
                @endauth
            </div>
        </div>
    </nav>

    <!-- Modals (Login/Register) -->
    <div x-show="showLogin" x-cloak class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/40 backdrop-blur-sm">
        <div class="bg-white w-full max-w-[440px] rounded-[2.5rem] overflow-hidden shadow-2xl relative" @click.away="showLogin = false">
            <div class="bg-brand-600 p-10 text-white text-center relative overflow-hidden">
                <h3 class="text-3xl font-black mb-2 relative z-10">بەخێربێیتەوە</h3>
                <p class="text-brand-100 text-sm font-medium relative z-10">بۆ چوونە ناو edu book هەژمارەکەت بنووسە</p>
                <button @click="showLogin = false" class="absolute top-6 left-6 p-2 text-white/50 hover:text-white transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" /></svg>
                </button>
            </div>
            <div class="p-10">
                <form action="{{ route('login.submit') }}" method="POST" class="space-y-6">
                    @csrf
                    <div class="space-y-2">
                        <label class="text-xs font-black text-slate-400 uppercase tracking-wider mr-1">ئیمەیڵ</label>
                        <input type="email" name="email" required class="w-full px-6 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-brand-500 focus:bg-white outline-none transition-all text-left">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-black text-slate-400 uppercase tracking-wider">وشەی نهێنی</label>
                        <input type="password" name="password" required class="w-full px-6 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-brand-500 focus:bg-white outline-none transition-all text-left">
                    </div>
                    <button type="submit" class="w-full py-4 bg-brand-600 text-white rounded-2xl font-black text-lg shadow-xl shadow-brand-100 hover:bg-brand-700 hover:-translate-y-1 transition-all">چوونەژوورەوە</button>
                    <div class="text-center"><p class="text-sm text-slate-500 font-medium">هەژمارت نییە؟ <button type="button" @click="showLogin = false; showRegister = true" class="text-brand-600 font-black hover:underline">دروستی بکە</button></p></div>
                </form>
            </div>
        </div>
    </div>

    @if(!$institution)
    <!-- Hero Section -->
    <section class="relative pt-48 pb-32 overflow-hidden">
        <div class="max-w-7xl mx-auto px-6 relative z-10">
            <div class="grid lg:grid-cols-2 gap-20 items-center">
                <div class="space-y-10 reveal-on-scroll">
                    <div class="inline-flex items-center gap-3 px-4 py-2 bg-brand-50 border border-brand-100 rounded-full">
                        <span class="flex h-2 w-2 relative"><span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-brand-400 opacity-75"></span><span class="relative inline-flex rounded-full h-2 w-2 bg-brand-500"></span></span>
                        <span class="text-[10px] font-black text-brand-700 uppercase tracking-widest">داهاتووی پەروەردە لێرەیە</span>
                    </div>

                    <div class="space-y-6">
                        <h1 class="text-6xl md:text-7xl font-black leading-[1.1] text-slate-900">
                            هەموو خوێندنگاکان <br>
                            <span class="text-transparent bg-clip-text bg-gradient-to-l from-brand-600 to-brand-400">لە یەک شوێندا</span>
                        </h1>
                        <p class="text-xl text-slate-500 leading-relaxed max-w-xl font-medium">
                            پلاتفۆرمی edu book گەورەترین و پێشکەوتووترین ناوەندی دۆزینەوەی قوتابخانە و ناوەندە پەروەردەییەکانە لە هەرێمی کوردستان.
                        </p>
                    </div>

                    <div class="flex flex-wrap gap-5">
                        <a href="#join" class="btn-premium px-10 py-5 bg-brand-600 text-white rounded-[2rem] font-black text-lg shadow-2xl shadow-brand-200 hover:bg-brand-700 hover:-translate-y-1 transition-all">تۆمارکردنی دامەزراوە</a>
                        <a href="#about" class="px-10 py-5 bg-white text-slate-700 rounded-[2rem] font-black text-lg border border-slate-200 hover:bg-slate-50 hover:border-slate-300 transition-all">زیاتر بزانە</a>
                    </div>

                    <div class="flex items-center gap-8 pt-8">
                        <div class="flex -space-x-3 rtl:space-x-reverse">
                            @for($i=1; $i<=4; $i++)
                                <div class="w-12 h-12 rounded-full border-4 border-white bg-slate-200 overflow-hidden shadow-sm">
                                    <img src="https://i.pravatar.cc/100?img={{ $i+20 }}" alt="User">
                                </div>
                            @endfor
                            <div class="w-12 h-12 rounded-full border-4 border-white bg-brand-600 flex items-center justify-center text-white text-xs font-bold shadow-sm">+5k</div>
                        </div>
                        <div class="text-sm font-bold text-slate-400">زیاتر لە <span class="text-slate-900">٥٠٠٠+</span> بەکارهێنەر متمانەیان پێمانە</div>
                    </div>
                </div>
                
                <div class="relative reveal-on-scroll">
                    <div class="relative z-10 animate-float">
                        <div class="relative max-w-md mx-auto">
                            <div class="absolute inset-0 bg-brand-500/20 rounded-[4rem] blur-[80px] -rotate-6"></div>
                            <img src="/images/app_home.png" alt="edu book App" class="relative w-full h-auto drop-shadow-[0_35px_35px_rgba(0,0,0,0.15)]">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="py-32 bg-white relative">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center max-w-3xl mx-auto mb-24 reveal-on-scroll">
                <h2 class="text-4xl font-black text-slate-900 mb-6">بۆچی edu book؟</h2>
                <div class="w-20 h-2 bg-brand-500 mx-auto rounded-full mb-8"></div>
                <p class="text-lg text-slate-500 font-medium">ئێمە ژینگەیەکی دیجیتاڵی مۆدێرنمان دروستکردووە کە پردی پەیوەندییە لە نێوان ناوەندە پەروەردەییەکان و خێزانەکاندا.</p>
            </div>
            
            <div class="grid md:grid-cols-3 gap-10">
                @php
                    $features = [
                        ['t' => 'نەخشەی زیرەک', 'd' => 'هەموو خوێندنگاکان لەسەر نەخشەیەکی پێشکەوتوو ببینە و نزیکترینیان هەڵبژێرە.', 'icon' => 'M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7'],
                        ['t' => 'زانیاری ورد', 'd' => 'بەرواری وەرگرتن، نرخ، و چالاکییەکان هەموو دامەزراوەکان لێرە بە وردی ببینە.', 'icon' => 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4'],
                        ['t' => 'ئاگەدارکەرەوە', 'd' => 'ئاگەداربە لە دواین چالاکی و ڕاگەیەندراوەکانی خوێندنگاکان لە ڕێگەی پۆستەکانەوە.', 'icon' => 'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9']
                    ];
                @endphp
                @foreach($features as $f)
                <div class="p-12 premium-card rounded-[3.5rem] group reveal-on-scroll">
                    <div class="w-16 h-16 bg-brand-50 text-brand-600 rounded-2xl flex items-center justify-center mb-10 group-hover:bg-brand-600 group-hover:text-white transition-all duration-500">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="{{ $f['icon'] }}" /></svg>
                    </div>
                    <h3 class="text-2xl font-black mb-4">{{ $f['t'] }}</h3>
                    <p class="text-slate-500 leading-relaxed font-medium">{{ $f['d'] }}</p>
                </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- App Showcase Section -->
    <section id="features" class="py-32 bg-slate-50 relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-24 reveal-on-scroll">
                <h2 class="text-4xl font-black text-slate-900 italic">ئەپی edu book</h2>
                <p class="text-slate-400 font-medium italic mt-4">ئەزموونێکی جیاواز و مۆدێرن بۆ گەڕان و دۆزینەوە</p>
                <div class="w-24 h-2 bg-brand-500 mx-auto rounded-full mt-6"></div>
            </div>

            <div class="grid md:grid-cols-3 gap-12">
                @php
                    $showcase = [
                        ['t' => 'نەخشەی زیرەک', 'd' => 'بە ئاسانی هەموو دامەزراوەکان لەسەر نەخشە ببینە.', 'img' => '/images/app_map.png'],
                        ['t' => 'دواین پۆستەکان', 'd' => 'ئاگەداربە لە هەموو چالاکی و ڕاگەیەندراوە نوێیەکان.', 'img' => '/images/app_home.png'],
                        ['t' => 'پرۆفایلی دامەزراوە', 'd' => 'هەموو زانیارییەکان لە یەک شوێندا ببینە.', 'img' => '/images/app_profile.png']
                    ];
                @endphp
                @foreach($showcase as $s)
                <div class="space-y-8 text-center group reveal-on-scroll">
                    <div class="relative overflow-hidden rounded-[3rem] shadow-2xl transition-transform duration-500 group-hover:-translate-y-4">
                        <img src="{{ $s['img'] }}" alt="{{ $s['t'] }}" class="w-full h-auto">
                    </div>
                    <div class="space-y-2">
                        <h4 class="text-xl font-black">{{ $s['t'] }}</h4>
                        <p class="text-slate-500 text-sm italic">{{ $s['d'] }}</p>
                    </div>
                </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- Tutorial Section -->
    <section id="tutorial" class="py-32 bg-white">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center max-w-2xl mx-auto mb-20 reveal-on-scroll">
                <h2 class="text-4xl font-black text-slate-900 mb-4">چۆن بەکاری بهێنم؟</h2>
                <p class="text-slate-500 font-medium italic">فێرکاری هەنگاو بە هەنگاو بۆ خاوەن دامەزراوەکان</p>
            </div>

            <div class="grid md:grid-cols-4 gap-8 mb-24">
                @php
                    $steps = [
                        ['n' => '١', 't' => 'دروستکردنی هەژمار', 'd' => 'بە ئیمەیڵ و ناوەکەت هەژمارێکی نوێ بۆ خۆت دروست بکە.'],
                        ['n' => '٢', 't' => 'تۆمارکردنی دامەزراوە', 'd' => 'دوای چوونەژوورەوە، زانیارییە سەرەکییەکان پڕ بکەرەوە.'],
                        ['n' => '٣', 't' => 'پەسەندکردنی ئادمین', 'd' => 'زانیارییەکانت لەلایەن ئادمینەوە دەبینرێت و پەسەند دەکرێت.'],
                        ['n' => '٤', 't' => 'بڵاوکردنەوەی پۆست', 'd' => 'ئێستا دەتوانیت پۆست بنووسیت و وێنە زیاد بکەیت.']
                    ];
                @endphp
                @foreach($steps as $step)
                <div class="relative group reveal-on-scroll">
                    <div class="absolute -top-6 -right-6 w-14 h-14 bg-white rounded-2xl shadow-xl flex items-center justify-center text-2xl font-black text-brand-600 z-10 border border-slate-50 group-hover:scale-110 transition-transform">{{ $step['n'] }}</div>
                    <div class="bg-slate-50 p-10 rounded-[3rem] h-full space-y-6 group-hover:bg-white group-hover:shadow-2xl transition-all duration-500 border border-transparent group-hover:border-slate-100">
                        <h4 class="text-xl font-black text-slate-900">{{ $step['t'] }}</h4>
                        <p class="text-sm text-slate-400 font-medium leading-relaxed">{{ $step['d'] }}</p>
                    </div>
                </div>
                @endforeach
            </div>

            <div class="p-16 bg-slate-900 rounded-[4rem] text-white flex flex-col md:flex-row items-center justify-between gap-12 shadow-2xl relative overflow-hidden reveal-on-scroll">
                <div class="space-y-4 text-center md:text-right relative z-10">
                    <h3 class="text-4xl font-black italic leading-tight">ئامادەی بۆ ئەزموونێکی نوێ؟</h3>
                    <p class="text-slate-400 text-lg font-medium italic">ببەرە بەشێک لە پلاتفۆرمی edu book و دەستپێبکە.</p>
                </div>
                <button @click="showLogin = true" class="btn-premium px-12 py-5 bg-brand-600 text-white rounded-[2rem] font-black text-xl shadow-2xl hover:scale-[1.05] transition-all">دەستپێبکە ئێستا</button>
            </div>
        </div>
    </section>

    @else
    <!-- Owner Dashboard Header -->
    <section class="pt-40 pb-16 px-6">
        <div class="max-w-7xl mx-auto">
            <div class="bg-white p-12 rounded-[4rem] shadow-2xl shadow-slate-200/50 border border-slate-100 flex flex-col md:flex-row items-center gap-12 relative overflow-hidden reveal-on-scroll">
                <div class="w-40 h-40 bg-slate-50 rounded-[3rem] overflow-hidden border-8 border-white shadow-2xl relative z-10 shrink-0">
                    @if($institution->img) <img src="{{ $institution->img }}" class="w-full h-full object-cover">
                    @else <div class="w-full h-full flex items-center justify-center text-brand-600 bg-brand-50 font-black text-5xl">{{ mb_substr($institution->nku, 0, 1) }}</div> @endif
                </div>

                <div class="flex-1 text-center md:text-right relative z-10">
                    <div class="flex flex-wrap gap-4 justify-center md:justify-start items-center mb-4">
                        <span class="px-4 py-1.5 bg-brand-50 text-brand-600 rounded-full text-[10px] font-black uppercase tracking-widest">{{ $institution->type }}</span>
                        @if($institution->approved)
                            <span class="px-4 py-1.5 bg-emerald-50 text-emerald-600 rounded-full text-[10px] font-black uppercase tracking-widest flex items-center gap-2">
                                <span class="w-2 h-2 bg-emerald-500 rounded-full"></span> چالاک و پەسەندکراو
                            </span>
                        @else
                            <span class="px-4 py-1.5 bg-amber-50 text-amber-600 rounded-full text-[10px] font-black uppercase tracking-widest italic">لەژێر وردبینی</span>
                        @endif
                    </div>
                    <h1 class="text-5xl font-black text-slate-900 mb-4">{{ $institution->nku }}</h1>
                    <div class="flex items-center justify-center md:justify-start gap-3 text-slate-400 font-bold italic">
                        <svg class="w-5 h-5 text-brand-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                        {{ $institution->addr ?? 'ناونیشان دیارینەکراوە' }}
                    </div>
                </div>

                <div class="flex gap-4 relative z-10">
                    <a href="/" target="_blank" class="px-8 py-4 bg-brand-600 text-white rounded-2xl font-black shadow-xl hover:scale-[1.05] transition-all flex items-center gap-3">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                        بینینی پەڕە
                    </a>
                </div>
            </div>
        </div>
    </section>
    @endif

    <!-- Footer -->
    <footer class="py-20 bg-white border-t border-slate-100">
        <div class="max-w-7xl mx-auto px-6">
            <div class="flex flex-col md:flex-row justify-between items-center gap-12">
                <div class="flex items-center gap-4 group">
                    <div class="w-12 h-12 bg-slate-900 rounded-2xl flex items-center justify-center text-white font-black text-xl shadow-xl">eb</div>
                    <div class="flex flex-col">
                        <span class="text-xl font-black text-slate-900 tracking-tight">edu book</span>
                        <span class="text-[10px] uppercase font-bold text-slate-400 tracking-widest mt-0.5 italic">Education Platform</span>
                    </div>
                </div>
                
                <div class="flex flex-wrap justify-center gap-10 text-sm font-black text-slate-400 italic">
                    <a href="#" class="hover:text-brand-600 transition-colors">مەرجەکان</a>
                    <a href="#" class="hover:text-brand-600 transition-colors">پاراستنی زانیاری</a>
                    <a href="#" class="hover:text-brand-600 transition-colors">پەیوەندی</a>
                </div>

                <div class="text-sm font-bold text-slate-400 italic">Made with ❤️ in Kurdistan &copy; 2026</div>
            </div>
        </div>
    </footer>

</body>
</html>
