<!DOCTYPE html>
<html lang="ku" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>خوێندنگاکانم - پلاتفۆرمی پەروەردەیی</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Kufi+Arabic:wght@100..900&display=swap" rel="stylesheet">

    <!-- Tailwind CSS via CDN for instant preview -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Alpine.js for interactivity -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        arabic: ['"Noto Kufi Arabic"', 'sans-serif'],
                    },
                    colors: {
                        primary: '#0ea5e9',
                        secondary: '#0369a1',
                        accent: '#f59e0b',
                    }
                }
            }
        }
    </script>

    <style>
        body {
            font-family: 'Noto Kufi Arabic', sans-serif;
            scroll-behavior: smooth;
        }
        .glass {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .hero-gradient {
            background: radial-gradient(circle at top right, #e0f2fe 0%, #ffffff 50%, #f0f9ff 100%);
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }
        .float {
            animation: float 3s ease-in-out infinite;
        }
    </style>
</head>
<body class="bg-slate-50 text-slate-900 hero-gradient min-h-screen" 
      x-data="{ 
        showLogin: new URLSearchParams(window.location.search).has('login'), 
        showRegister: false 
      }">

    <!-- Navigation -->
    <nav class="fixed top-0 left-0 right-0 z-50 glass shadow-sm">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg">خ</div>
                <span class="text-xl font-bold tracking-tight text-slate-800">خوێندنگاکانم</span>
            </div>
            
            <div class="hidden md:flex items-center gap-10 text-sm font-bold">
                <div class="flex items-center gap-8 text-slate-600">
                    <a href="#about" class="hover:text-primary transition-colors">دەربارە</a>
                    <a href="#tutorial" class="hover:text-primary transition-colors">فێرکاری</a>
                    @auth
                        @if($institution)
                            <a href="#join" class="text-primary">بەرێوەبردن</a>
                            <a href="#posts" class="hover:text-primary transition-colors">پۆستەکان</a>
                        @else
                            <a href="#join" class="hover:text-primary transition-colors italic">زیادکردنی دامەزراوە</a>
                        @endif
                    @endauth
                </div>

                <div class="h-6 w-px bg-slate-200"></div>
                
                @auth
                    <div class="flex items-center gap-6">
                        <div class="flex items-center gap-2">
                            <div class="w-8 h-8 bg-slate-100 rounded-full flex items-center justify-center text-slate-400 border border-slate-200">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                            </div>
                            <span class="text-slate-800">{{ auth()->user()->name }}</span>
                        </div>
                        <form action="{{ route('logout') }}" method="POST" class="inline">
                            @csrf
                            <button type="submit" class="text-rose-500 hover:text-rose-600 transition-colors">چوونەدەرەوە</button>
                        </form>
                    </div>
                @else
                    <button @click="showLogin = true" class="bg-primary text-white px-10 py-3 rounded-full hover:bg-secondary transition-all shadow-lg shadow-sky-100">چوونەژوورەوە</button>
                @endauth
            </div>
        </div>
    </nav>

    <!-- Modals -->
    <!-- Login Modal -->
    <div x-show="showLogin" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/60 backdrop-blur-md" style="display: none;">
        <div class="bg-white w-full max-w-md rounded-[3rem] p-12 shadow-2xl relative" @click.away="showLogin = false">
            <button @click="showLogin = false" class="absolute top-8 left-8 p-2 hover:bg-slate-100 rounded-full">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
            <h3 class="text-3xl font-black mb-8 text-center">چوونەژوورەوە</h3>
            <form action="{{ route('login.submit') }}" method="POST" class="space-y-6">
                @csrf
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">ئیمەیڵ</label>
                    <input type="email" name="email" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                </div>
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">وشەی نهێنی</label>
                    <input type="password" name="password" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                </div>
                <button type="submit" class="w-full py-4 bg-primary text-white rounded-2xl font-black text-lg shadow-lg hover:bg-secondary">چوونەژوورەوە</button>
                <p class="text-center text-sm text-slate-500">هەژمارت نییە؟ <button type="button" @click="showLogin = false; showRegister = true" class="text-primary font-bold">دروستی بکە</button></p>
            </form>
        </div>
    </div>

    <!-- Register Modal -->
    <div x-show="showRegister" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/60 backdrop-blur-md" style="display: none;">
        <div class="bg-white w-full max-w-md rounded-[3rem] p-12 shadow-2xl relative" @click.away="showRegister = false">
            <button @click="showRegister = false" class="absolute top-8 left-8 p-2 hover:bg-slate-100 rounded-full">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
            <h3 class="text-3xl font-black mb-8 text-center">دروستکردنی هەژمار</h3>
            <form action="{{ route('register.submit') }}" method="POST" class="space-y-6">
                @csrf
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">ناو</label>
                    <input type="text" name="name" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary">
                </div>
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">ئیمەیڵ</label>
                    <input type="email" name="email" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                </div>
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">وشەی نهێنی</label>
                    <input type="password" name="password" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                </div>
                <div class="space-y-2">
                    <label class="text-sm font-bold text-slate-700">دووبارەکردنەوەی وشەی نهێنی</label>
                    <input type="password" name="password_confirmation" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                </div>
                <button type="submit" class="w-full py-4 bg-slate-900 text-white rounded-2xl font-black text-lg shadow-lg hover:bg-black">دروستکردن</button>
                <p class="text-center text-sm text-slate-500">پێشتر هەژمارت دروستکردووە؟ <button type="button" @click="showRegister = false; showLogin = true" class="text-primary font-bold">بچۆ ژوورەوە</button></p>
            </form>
        </div>
    </div>

    @if(!$institution)
    <!-- Hero Section -->
    <section class="pt-40 pb-20 px-6 overflow-hidden">
        <div class="max-w-7xl mx-auto grid md:grid-cols-2 gap-12 items-center">
            <div class="space-y-8 relative z-10 text-right">
                <div class="inline-block px-4 py-1.5 bg-sky-100 text-sky-700 rounded-full text-xs font-bold tracking-widest uppercase">داهاتووی پەروەردە لێرەیە</div>
                <h1 class="text-5xl md:text-6xl font-black leading-tight text-slate-900">
                    هەموو خوێندنگاکان <br>
                    <span class="text-primary">لە یەک شوێندا</span>
                </h1>
                <p class="text-lg text-slate-600 leading-relaxed max-w-xl">
                    پلاتفۆرمی خوێندنگاکانم یارمەتی دایکان و باوکان دەدات باشترین ناوەندی پەروەردەیی بۆ منداڵەکانیان بدۆزنەوە. ئەگەر تۆ خاوەنی دامەزراوەیەکی، ئێستا پەیوەندیمان پێوە بکە.
                </p>
                <div class="flex flex-wrap gap-4 justify-start">
                    <a href="#join" class="px-8 py-4 bg-primary text-white rounded-2xl font-bold shadow-xl shadow-sky-200 hover:bg-secondary hover:-translate-y-1 transition-all">تۆمارکردنی دامەزراوە</a>
                    <a href="#about" class="px-8 py-4 bg-white text-slate-700 rounded-2xl font-bold border border-slate-200 hover:bg-slate-50 transition-all">زیاتر بزانە</a>
                </div>
            </div>
            
            <div class="relative flex justify-center">
                <div class="absolute -top-20 -left-20 w-80 h-80 bg-sky-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse"></div>
                <div class="absolute -bottom-20 -right-20 w-80 h-80 bg-emerald-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse delay-700"></div>
                
                <!-- Mockup Image -->
                <div class="relative w-full max-w-lg float">
                    <img src="/images/app_mockup_preview_1777707434316.png" 
                         alt="Xwendngakan App Mockup" 
                         class="w-full h-auto drop-shadow-2xl">
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="py-24 bg-white">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-16 space-y-4">
                <h2 class="text-4xl font-black text-slate-900">بۆچی خوێندنگاکانم؟</h2>
                <div class="w-20 h-2 bg-primary mx-auto rounded-full"></div>
            </div>
            
            <div class="grid md:grid-cols-3 gap-12">
                <div class="p-10 rounded-[3rem] bg-slate-50 hover:shadow-2xl hover:shadow-sky-100 transition-all group border border-slate-100">
                    <div class="w-16 h-16 bg-white text-primary rounded-2xl flex items-center justify-center mb-8 shadow-sm group-hover:bg-primary group-hover:text-white transition-all">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" /></svg>
                    </div>
                    <h3 class="text-2xl font-black mb-4">نەخشەی زیرەک</h3>
                    <p class="text-slate-500 leading-relaxed">هەموو خوێندنگاکان لەسەر نەخشە ببینە و نزیکترینیان بۆ خۆت هەڵبژێرە بە ئاسانترین شێوە.</p>
                </div>
                
                <div class="p-10 rounded-[3rem] bg-slate-50 hover:shadow-2xl hover:shadow-sky-100 transition-all group border border-slate-100">
                    <div class="w-16 h-16 bg-white text-primary rounded-2xl flex items-center justify-center mb-8 shadow-sm group-hover:bg-primary group-hover:text-white transition-all">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" /></svg>
                    </div>
                    <h3 class="text-2xl font-black mb-4">زانیاری تەواو</h3>
                    <p class="text-slate-500 leading-relaxed">بەرواری وەرگرتن، نرخ، چالاکییەکان و زانیاری پەیوەندی هەموو دامەزراوەکان بە وردی لێرەیە.</p>
                </div>
                
                <div class="p-10 rounded-[3rem] bg-slate-50 hover:shadow-2xl hover:shadow-sky-100 transition-all group border border-slate-100">
                    <div class="w-16 h-16 bg-white text-primary rounded-2xl flex items-center justify-center mb-8 shadow-sm group-hover:bg-primary group-hover:text-white transition-all">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
                    </div>
                    <h3 class="text-2xl font-black mb-4">نوێکارییەکان</h3>
                    <p class="text-slate-500 leading-relaxed">ئاگەداربە لە دواین چالاکی و ڕاگەیەندراوەکانی خوێندنگاکان لە ڕێگەی پۆستەکانەوە بە سادەیی.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- App Showcase Section -->
    <section class="py-24 bg-white relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-20 space-y-4">
                <h2 class="text-4xl font-black text-slate-900 italic">ئەپی خوێندنگاکانم</h2>
                <p class="text-slate-400 font-medium italic">ئەزموونێکی جیاواز و مۆدێرن بۆ گەڕان و دۆزینەوە</p>
                <div class="w-24 h-2 bg-primary mx-auto rounded-full"></div>
            </div>

            <div class="grid md:grid-cols-3 gap-12">
                <!-- Map Showcase -->
                <div class="space-y-8 text-center group">
                    <div class="relative overflow-hidden rounded-[3rem] shadow-2xl transition-transform duration-500 group-hover:-translate-y-4">
                        <img src="/images/app_map_mockup_1777707551587.png" 
                             alt="Map View" class="w-full h-auto">
                    </div>
                    <div class="space-y-2">
                        <h4 class="text-xl font-black">نەخشەی زیرەک</h4>
                        <p class="text-slate-500 text-sm">بە ئاسانی هەموو دامەزراوەکان لەسەر نەخشە ببینە و نزیکترینیان بدۆزەرەوە.</p>
                    </div>
                </div>

                <!-- Feed Showcase -->
                <div class="space-y-8 text-center group">
                    <div class="relative overflow-hidden rounded-[3rem] shadow-2xl transition-transform duration-500 group-hover:-translate-y-4">
                        <img src="/images/app_mockup_preview_1777707434316.png" 
                             alt="Feed View" class="w-full h-auto">
                    </div>
                    <div class="space-y-2">
                        <h4 class="text-xl font-black">دواین پۆستەکان</h4>
                        <p class="text-slate-500 text-sm">ئاگەداربە لە هەموو چالاکی و ڕاگەیەندراوە نوێیەکانی خوێندنگاکەت.</p>
                    </div>
                </div>

                <!-- Profile Showcase -->
                <div class="space-y-8 text-center group">
                    <div class="relative overflow-hidden rounded-[3rem] shadow-2xl transition-transform duration-500 group-hover:-translate-y-4">
                        <img src="/images/app_profile_mockup_1777707573764.png" 
                             alt="Profile View" class="w-full h-auto">
                    </div>
                    <div class="space-y-2">
                        <h4 class="text-xl font-black">پرۆفایلی دامەزراوە</h4>
                        <p class="text-slate-500 text-sm">هەموو زانیارییەکان، نرخ، شوێن، و پەیوەندی لە یەک شوێندا ببینە.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Tutorial Section -->
    <section id="tutorial" class="py-24 bg-slate-50 relative overflow-hidden">
        <div class="absolute top-0 left-0 w-full h-24 bg-gradient-to-b from-white to-transparent"></div>
        <div class="max-w-7xl mx-auto px-6 relative z-10">
            <div class="text-center mb-20 space-y-4">
                <h2 class="text-4xl font-black text-slate-900 italic">چۆن بەکاری بهێنم؟</h2>
                <p class="text-slate-400 font-medium italic">فێرکاری هەنگاو بە هەنگاو بۆ خاوەن دامەزراوەکان</p>
                <div class="w-24 h-2 bg-slate-900 mx-auto rounded-full"></div>
            </div>

            <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mb-24">
                <!-- Step 1 -->
                <div class="relative group">
                    <div class="absolute -top-6 -right-6 w-16 h-16 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-primary z-10 border border-slate-100 group-hover:scale-110 transition-transform">١</div>
                    <div class="bg-white p-10 rounded-[3rem] shadow-xl border border-slate-100 h-full space-y-6">
                        <div class="w-14 h-14 bg-primary/10 text-primary rounded-2xl flex items-center justify-center">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" /></svg>
                        </div>
                        <h4 class="text-xl font-black">دروستکردنی هەژمار</h4>
                        <p class="text-slate-500 text-sm leading-relaxed">سەرەتا لە ڕێگەی دوگمەی "چوونەژوورەوە"وە هەژمارێکی نوێ بۆ خۆت دروست بکە بە ئیمەیڵ و ناوەکەت.</p>
                    </div>
                </div>

                <!-- Step 2 -->
                <div class="relative group">
                    <div class="absolute -top-6 -right-6 w-16 h-16 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-primary z-10 border border-slate-100 group-hover:scale-110 transition-transform">٢</div>
                    <div class="bg-white p-10 rounded-[3rem] shadow-xl border border-slate-100 h-full space-y-6">
                        <div class="w-14 h-14 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" /></svg>
                        </div>
                        <h4 class="text-xl font-black">تۆمارکردنی دامەزراوە</h4>
                        <p class="text-slate-500 text-sm leading-relaxed">دوای چوونەژوورەوە، زانیارییە سەرەکییەکانی وەک (ناو، جۆر، مۆبایل) پڕ بکەرەوە و داواکارییەکە بنێرە.</p>
                    </div>
                </div>

                <!-- Step 3 -->
                <div class="relative group">
                    <div class="absolute -top-6 -right-6 w-16 h-16 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-primary z-10 border border-slate-100 group-hover:scale-110 transition-transform">٣</div>
                    <div class="bg-white p-10 rounded-[3rem] shadow-xl border border-slate-100 h-full space-y-6">
                        <div class="w-14 h-14 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                        </div>
                        <h4 class="text-xl font-black">پەسەندکردنی ئادمین</h4>
                        <p class="text-slate-500 text-sm leading-relaxed">زانیارییەکانت لەلایەن ئادمینەوە دەبینرێت و دوای دڵنیابوونەوە، دامەزراوەکەت پەسەند دەکرێت بۆ پیشاندان.</p>
                    </div>
                </div>

                <!-- Step 4 -->
                <div class="relative group">
                    <div class="absolute -top-6 -right-6 w-16 h-16 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-primary z-10 border border-slate-100 group-hover:scale-110 transition-transform">٤</div>
                    <div class="bg-white p-10 rounded-[3rem] shadow-xl border border-slate-100 h-full space-y-6">
                        <div class="w-14 h-14 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" /></svg>
                        </div>
                        <h4 class="text-xl font-black">بڵاوکردنەوەی پۆست</h4>
                        <p class="text-slate-500 text-sm leading-relaxed">ئێستا لە داشبۆردەکەتەوە، دەتوانیت پۆست بنووسیت و وێنەی بۆ زیاد بکەیت تا لەناو ئەپەکەدا دەربکەوێت.</p>
                    </div>
                </div>
            </div>

            <!-- Detailed Posting Tutorial & App Preview -->
            <div class="grid lg:grid-cols-2 gap-16 items-center">
                <div class="space-y-10">
                    <div class="space-y-4">
                        <h3 class="text-3xl font-black text-slate-900">چۆن پۆستەکانت بڵاو دەکەیتەوە؟</h3>
                        <p class="text-slate-500 text-lg">پڕۆسەی بڵاوکردنەوەی پۆست زۆر سادەیە و تەنها چەند چرکەیەکی دەوێت:</p>
                    </div>
                    
                    <ul class="space-y-8">
                        <li class="flex gap-6 items-start">
                            <div class="w-10 h-10 bg-primary text-white rounded-xl flex items-center justify-center shrink-0 font-bold">١</div>
                            <div>
                                <h5 class="font-bold text-slate-800 mb-1">ناونیشانێکی سەرنجڕاکێش</h5>
                                <p class="text-sm text-slate-500">ناونیشانێک هەڵبژێرە کە کورت بێت و مەبەستی پۆستەکە بە ڕوونی بگەیەنێت.</p>
                            </div>
                        </li>
                        <li class="flex gap-6 items-start">
                            <div class="w-10 h-10 bg-primary text-white rounded-xl flex items-center justify-center shrink-0 font-bold">٢</div>
                            <div>
                                <h5 class="font-bold text-slate-800 mb-1">وەسف و زانیاری</h5>
                                <p class="text-sm text-slate-500">لە بەشی ناوەڕۆک، هەموو ئەو وردەکارییانە بنووسە کە دەتەوێت دایکان و باوکان بیزانن.</p>
                            </div>
                        </li>
                        <li class="flex gap-6 items-start">
                            <div class="w-10 h-10 bg-primary text-white rounded-xl flex items-center justify-center shrink-0 font-bold">٣</div>
                            <div>
                                <h5 class="font-bold text-slate-800 mb-1">وێنەیەک کە گوزارشت بێت</h5>
                                <p class="text-sm text-slate-500">وێنەیەکی با کوالیتی بەرز بۆ پۆستەکە هەڵبژێرە چونکە زیاتر سەرنجی خەڵک ڕادەکێشێت.</p>
                            </div>
                        </li>
                    </ul>
                </div>

                <div class="relative">
                    <div class="absolute inset-0 bg-primary/5 rounded-[4rem] blur-3xl -rotate-6"></div>
                    <div class="relative bg-white p-8 rounded-[4rem] shadow-2xl border border-slate-100 transform hover:scale-[1.02] transition-transform duration-500">
                        <div class="text-center mb-6">
                            <span class="px-4 py-1 bg-emerald-100 text-emerald-700 rounded-full text-xs font-bold uppercase tracking-widest">پیشاندانی ناو ئەپ</span>
                        </div>
                        <img src="/images/app_mockup_preview_1777707434316.png" 
                             alt="Post in App Preview" 
                             class="w-full h-auto rounded-3xl shadow-inner">
                        <div class="mt-8 text-center">
                            <p class="text-sm text-slate-500 font-medium italic">"پۆستەکانت یەکسەر بەم شێوەیە لە ناو ئەپی خوێندنگاکانم دەردەکەون"</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="mt-32 p-10 bg-slate-900 rounded-[3rem] text-white flex flex-col md:flex-row items-center justify-between gap-8 shadow-2xl">
                <div class="space-y-2 text-center md:text-right">
                    <h3 class="text-2xl font-black italic">ئامادەی بۆ دەستپێکردن؟</h3>
                    <p class="text-slate-400">هەژمارەکەت دروست بکە و ببەرە بەشێک لە گەورەترین پلاتفۆرمی پەروەردەیی.</p>
                </div>
                <button @click="showLogin = true" class="px-10 py-4 bg-primary text-white rounded-2xl font-black hover:bg-white hover:text-primary transition-all">دەستپێبکە ئێستا</button>
            </div>
        </div>
    </section>
    @else
    <!-- Owner Dashboard Header -->
    <section class="pt-32 pb-12 px-6">
        <div class="max-w-7xl mx-auto">
            <div class="bg-white p-10 rounded-[3rem] shadow-2xl shadow-sky-100 border border-slate-100 flex flex-col md:flex-row items-center gap-8 relative overflow-hidden">
                <div class="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full -mr-20 -mt-20 blur-3xl"></div>
                
                <div class="w-32 h-32 bg-slate-50 rounded-[2rem] overflow-hidden border-4 border-white shadow-xl relative z-10 shrink-0">
                    @if($institution->img)
                        <img src="{{ $institution->img }}" class="w-full h-full object-cover">
                    @else
                        <div class="w-full h-full flex items-center justify-center text-primary bg-primary/10 font-black text-4xl">
                            {{ mb_substr($institution->nku, 0, 1) }}
                        </div>
                    @endif
                </div>

                <div class="flex-1 text-center md:text-right relative z-10">
                    <h1 class="text-4xl font-black text-slate-900 mb-2">{{ $institution->nku }}</h1>
                    <div class="flex flex-wrap gap-4 justify-center md:justify-start items-center">
                        <span class="px-4 py-1.5 bg-sky-100 text-sky-700 rounded-full text-xs font-bold uppercase">{{ $institution->type }}</span>
                        <div class="flex items-center gap-2 text-slate-400 text-sm">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                            {{ $institution->addr ?? 'ناونیشان دیارینەکراوە' }}
                        </div>
                    </div>
                </div>

                <div class="flex gap-4 relative z-10">
                    <a href="/" target="_blank" class="px-6 py-3 bg-slate-50 text-slate-600 rounded-2xl font-bold border border-slate-200 hover:bg-white hover:shadow-lg transition-all flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                        بینینی پەڕە
                    </a>
                </div>
            </div>
        </div>
    </section>
    @endif


    <!-- Join/Registration Section -->
    <section id="join" class="py-24 bg-slate-50">
        <div class="max-w-6xl mx-auto px-6">
            @if($institution)
                <!-- Premium Management Dashboard -->
                <div class="space-y-12 pb-24">
                    <!-- Header -->
                    <div class="flex flex-col md:flex-row justify-between items-center gap-6 bg-white p-8 rounded-[3rem] shadow-sm border border-slate-100">
                        <div class="flex items-center gap-6">
                            <div class="w-20 h-20 bg-primary/10 rounded-3xl flex items-center justify-center text-primary font-black text-3xl">
                                {{ mb_substr($institution->nku, 0, 1) }}
                            </div>
                            <div>
                                <h2 class="text-3xl font-black text-slate-900 leading-none mb-2">{{ $institution->nku }}</h2>
                                <p class="text-slate-400 font-medium flex items-center gap-2">
                                    <span class="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></span>
                                    بەرێوەبردنی دامەزراوە
                                </p>
                            </div>
                        </div>
                        <div class="flex gap-4">
                            <a href="/" target="_blank" class="px-6 py-3 bg-slate-50 text-slate-600 rounded-2xl font-bold border border-slate-200 hover:bg-white hover:shadow-lg transition-all flex items-center gap-2">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                                بینینی پەڕە
                            </a>
                        </div>
                    </div>

                    @if (session('success'))
                        <div class="p-6 bg-emerald-50 text-emerald-700 rounded-3xl border border-emerald-100 font-bold flex items-center gap-3 animate-bounce">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                            {{ session('success') }}
                        </div>
                    @endif

                    <form action="{{ route('institution.update') }}" method="POST" enctype="multipart/form-data" class="grid lg:grid-cols-3 gap-12">
                        @csrf
                        <!-- Main Content -->
                        <div class="lg:col-span-2 space-y-12">
                            <!-- Section 1: زانیاری سەرەکی -->
                            <div class="bg-white p-10 rounded-[3rem] shadow-xl shadow-slate-200/50 border border-slate-100 space-y-8">
                                <div class="flex items-center gap-4">
                                    <div class="w-1.5 h-8 bg-primary rounded-full"></div>
                                    <div>
                                        <h3 class="text-2xl font-black text-slate-900">زانیاری سەرەکی</h3>
                                        <p class="text-slate-400 text-sm">زانیارییە گرنگەکان دابنێ</p>
                                    </div>
                                </div>

                                <div class="space-y-4">
                                    <label class="text-sm font-bold text-slate-700 mr-2">وێنەی دامەزراوە</label>
                                    <div class="flex items-center gap-8 p-8 bg-slate-50 rounded-[2.5rem] border-2 border-dashed border-slate-200 group hover:border-primary transition-all">
                                        <div class="w-32 h-32 bg-white rounded-3xl overflow-hidden shadow-lg border border-slate-100 shrink-0">
                                            @if($institution->img)
                                                <img src="{{ $institution->img }}" class="w-full h-full object-cover">
                                            @else
                                                <div class="w-full h-full flex items-center justify-center text-slate-200 font-black text-4xl">؟</div>
                                            @endif
                                        </div>
                                        <div class="flex-1">
                                            <input type="file" name="img" class="block w-full text-sm text-slate-500 file:mr-4 file:py-3 file:px-6 file:rounded-2xl file:border-0 file:text-sm file:font-bold file:bg-primary file:text-white hover:file:bg-secondary cursor-pointer transition-all">
                                            <p class="mt-3 text-xs text-slate-400 italic">وێنەیەکی کوالیتی بەرز هەڵبژێرە بۆ لۆگۆ یان وێنەی سەرەکی</p>
                                        </div>
                                    </div>
                                </div>

                                <div class="grid md:grid-cols-2 gap-8">
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">ناوی کوردی*</label>
                                        <input type="text" name="nku" value="{{ $institution->nku }}" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-lg font-bold">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">جۆر*</label>
                                        <select name="type" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-lg font-bold">
                                            @foreach($types as $type)
                                                <option value="{{ $type->key }}" {{ $institution->type == $type->key ? 'selected' : '' }}>{{ $type->emoji }} {{ $type->name }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>

                                <div class="flex items-center gap-6 p-8 bg-emerald-50 rounded-[2.5rem] border border-emerald-100">
                                    <div class="relative inline-flex items-center cursor-pointer">
                                        <input type="checkbox" name="approved" value="1" {{ $institution->approved ? 'checked' : '' }} class="sr-only peer">
                                        <div class="w-14 h-7 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                                    </div>
                                    <div>
                                        <span class="block font-black text-emerald-900 text-lg">پەسەندکراو</span>
                                        <span class="text-sm text-emerald-600">ئەگەر چالاک بکەیت، لە ئەپەکەدا دەردەکەوێت</span>
                                    </div>
                                </div>

                                <div class="grid md:grid-cols-2 gap-8">
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">Latitude</label>
                                        <input type="text" name="lat" value="{{ $institution->lat }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left font-mono">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">Longitude</label>
                                        <input type="text" name="lng" value="{{ $institution->lng }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left font-mono">
                                    </div>
                                </div>

                                <div class="space-y-2">
                                    <label class="text-sm font-bold text-slate-700 mr-2">دەربارە</label>
                                    <textarea name="desc" rows="6" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary leading-relaxed" placeholder="زانیاری دەربارەی دامەزراوەکە">{{ $institution->desc }}</textarea>
                                </div>
                            </div>

                            <!-- Section 2: زمانەکانی تر -->
                            <div class="bg-white p-10 rounded-[3rem] shadow-xl shadow-slate-200/50 border border-slate-100 space-y-8">
                                <div class="flex items-center gap-4">
                                    <div class="w-1.5 h-8 bg-amber-400 rounded-full"></div>
                                    <h3 class="text-2xl font-black text-slate-900">زمانەکانی تر</h3>
                                </div>
                                <div class="grid md:grid-cols-2 gap-8">
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">ناوی ئینگلیزی</label>
                                        <input type="text" name="nen" value="{{ $institution->nen }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left" placeholder="Institution name in English">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700 mr-2">ناوی عەرەبی</label>
                                        <input type="text" name="nar" value="{{ $institution->nar }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-right" placeholder="اسم المؤسسة بالعربية">
                                    </div>
                                </div>
                                <div class="space-y-2">
                                    <label class="text-sm font-bold text-slate-700 mr-2">وەسف</label>
                                    <textarea name="desc_extra" rows="3" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary" placeholder="کورتەیەک لەسەر دامەزراوەکە..."></textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Sidebar Content -->
                        <div class="space-y-12">
                            <!-- Section 3: پەیوەندی -->
                            <div class="bg-white p-10 rounded-[3rem] shadow-xl shadow-slate-200/50 border border-slate-100 space-y-8">
                                <div class="flex items-center gap-4">
                                    <div class="w-1.5 h-8 bg-emerald-400 rounded-full"></div>
                                    <div>
                                        <h3 class="text-2xl font-black text-slate-900">پەیوەندی</h3>
                                        <p class="text-slate-400 text-sm">زانیاری پەیوەندی</p>
                                    </div>
                                </div>
                                <div class="space-y-6">
                                    <div class="space-y-1">
                                        <label class="text-xs font-bold text-slate-400 mr-2">ژمارەی مۆبایل</label>
                                        <input type="tel" name="phone" value="{{ $institution->phone }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left font-bold">
                                    </div>
                                    <div class="space-y-1">
                                        <label class="text-xs font-bold text-slate-400 mr-2">ئیمەیڵ</label>
                                        <input type="email" name="email" value="{{ $institution->email }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left">
                                    </div>
                                    <div class="space-y-1">
                                        <label class="text-xs font-bold text-slate-400 mr-2">وێبسایت</label>
                                        <input type="url" name="web" value="{{ $institution->web }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left" placeholder="https://...">
                                    </div>
                                </div>
                            </div>

                            <!-- Section 4: سۆشیال -->
                            <div class="bg-white p-10 rounded-[3rem] shadow-xl shadow-slate-200/50 border border-slate-100 space-y-8">
                                <div class="flex items-center gap-4">
                                    <div class="w-1.5 h-8 bg-indigo-400 rounded-full"></div>
                                    <div>
                                        <h3 class="text-2xl font-black text-slate-900">سۆشیال</h3>
                                        <p class="text-slate-400 text-sm">هەژمارەکانی تۆڕە کۆمەڵایەتییەکان</p>
                                    </div>
                                </div>
                                <div class="space-y-6">
                                    <div class="space-y-1">
                                        <label class="text-xs font-bold text-slate-400 mr-2">فەیسبووک</label>
                                        <input type="text" name="fb" value="{{ $institution->fb }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left" placeholder="username">
                                    </div>
                                    <div class="space-y-1">
                                        <label class="text-xs font-bold text-slate-400 mr-2">واتسئاپ</label>
                                        <input type="text" name="wa" value="{{ $institution->wa }}" class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left" placeholder="07XX XXX XX XX">
                                    </div>
                                </div>
                            </div>

                            <div class="flex gap-4">
                                <button type="submit" class="flex-1 py-6 bg-primary text-white rounded-[2.5rem] font-black text-lg shadow-2xl shadow-sky-200 hover:bg-secondary hover:-translate-y-1 transition-all">پاشکەوتکردنی گۆڕانکارییەکان</button>
                            </div>
                        </div>
                    </form>

                    <!-- Section 5: پۆستەکان -->
                    <div id="posts" class="space-y-10" x-data="{ search: '', showModal: false }">
                        <div class="bg-white p-12 rounded-[3.5rem] shadow-xl shadow-slate-200/50 border border-slate-100 space-y-12">
                            <div class="flex flex-col md:flex-row justify-between items-center gap-8">
                                <div class="flex items-center gap-4">
                                    <div class="w-1.5 h-10 bg-slate-900 rounded-full"></div>
                                    <h3 class="text-3xl font-black text-slate-900">پۆستەکان</h3>
                                </div>
                                
                                <div class="flex flex-1 max-w-2xl w-full gap-4">
                                    <div class="relative flex-1">
                                        <input type="text" x-model="search" placeholder="Search" class="w-full px-8 py-5 bg-slate-50 border-none rounded-[2rem] focus:ring-2 focus:ring-primary pr-14 text-lg">
                                        <svg class="w-6 h-6 absolute right-5 top-1/2 -translate-y-1/2 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                                    </div>
                                    <button @click="showModal = true" class="px-10 py-5 bg-slate-900 text-white rounded-[2rem] font-black hover:bg-black transition-all flex items-center gap-3 shrink-0 shadow-lg">
                                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                                        پۆستی نوێ
                                    </button>
                                </div>
                            </div>

                            @if($institution->posts->isEmpty())
                                <div class="text-center py-32 bg-slate-50 rounded-[3rem] border-2 border-dashed border-slate-200 space-y-8">
                                    <div class="w-24 h-24 bg-white rounded-full flex items-center justify-center mx-auto text-slate-200 shadow-sm">
                                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" /></svg>
                                    </div>
                                    <div class="space-y-2">
                                        <p class="text-2xl font-bold text-slate-400 italic">No پۆستەکان</p>
                                        <p class="text-slate-400">بۆ ئەوەی پۆستەکانت لێرە دەربکەون، یەکەم پۆست زیاد بکە</p>
                                    </div>
                                </div>
                            @else
                                <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-10">
                                    @foreach($institution->posts as $post)
                                        <div class="bg-white rounded-[2.5rem] border border-slate-100 overflow-hidden group hover:shadow-2xl transition-all duration-500" 
                                             x-show="'{{ strtolower($post->title) }}'.includes(search.toLowerCase()) || '{{ strtolower($post->content) }}'.includes(search.toLowerCase())">
                                            <div class="aspect-video bg-slate-100 relative overflow-hidden">
                                                @if($post->img)
                                                    <img src="{{ $post->img }}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700">
                                                @else
                                                    <div class="w-full h-full flex items-center justify-center text-slate-300">وێنە نییە</div>
                                                @endif
                                            </div>
                                            <div class="p-8 space-y-4">
                                                <h4 class="text-xl font-black text-slate-800 truncate">{{ $post->title }}</h4>
                                                <p class="text-sm text-slate-500 line-clamp-3 leading-relaxed h-12">{{ $post->content }}</p>
                                                <div class="pt-6 border-t border-slate-100 flex justify-between items-center">
                                                    <span class="text-xs text-slate-400 font-bold bg-slate-50 px-3 py-1 rounded-full">{{ $post->created_at->diffForHumans() }}</span>
                                                    <div class="flex gap-4">
                                                        <form action="{{ route('posts.destroy', $post) }}" method="POST" onsubmit="return confirm('ئایا دڵنیای لە سڕینەوەی ئەم پۆستە؟')">
                                                            @csrf
                                                            @method('DELETE')
                                                            <button type="submit" class="text-rose-500 text-sm font-black hover:underline transition-all">سڕینەوە</button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            @endif
                        </div>

                        <!-- Modal: New Post -->
                        <div x-show="showModal" 
                             x-transition:enter="transition ease-out duration-300"
                             x-transition:enter-start="opacity-0 translate-y-12"
                             x-transition:enter-end="opacity-100 translate-y-0"
                             class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/60 backdrop-blur-md" 
                             style="display: none;">
                            <div class="bg-white w-full max-w-2xl rounded-[3rem] p-12 shadow-2xl space-y-10 relative" @click.away="showModal = false">
                                <button @click="showModal = false" class="absolute top-8 left-8 p-3 hover:bg-slate-100 rounded-full transition-colors">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                                </button>
                                <h3 class="text-4xl font-black">پۆستی نوێ</h3>
                                <form action="{{ route('posts.store') }}" method="POST" enctype="multipart/form-data" class="space-y-8">
                                    @csrf
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700">ناونیشانی پۆست</label>
                                        <input type="text" name="title" required placeholder="چی دەنووسیت؟" class="w-full px-8 py-5 bg-slate-50 border-none rounded-2xl text-lg focus:ring-2 focus:ring-primary">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700">ناوەڕۆک</label>
                                        <textarea name="content" rows="6" required placeholder="زانیارییەکان لێرە بنووسە..." class="w-full px-8 py-5 bg-slate-50 border-none rounded-2xl text-lg focus:ring-2 focus:ring-primary leading-relaxed"></textarea>
                                    </div>
                                    <div class="space-y-2">
                                        <label class="text-sm font-bold text-slate-700">وێنەی پۆست</label>
                                        <div class="p-8 bg-slate-50 rounded-2xl border-2 border-dashed border-slate-200 text-center">
                                            <input type="file" name="img" class="text-sm text-slate-500">
                                        </div>
                                    </div>
                                    <div class="flex gap-4 pt-4">
                                        <button type="submit" class="flex-1 py-6 bg-primary text-white rounded-2xl font-black text-xl shadow-xl shadow-sky-200 hover:bg-secondary">بڵاوکردنەوە</button>
                                        <button type="button" @click="showModal = false" class="px-10 py-6 bg-slate-100 text-slate-500 rounded-2xl font-black">پەشیمانبوونەوە</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            @else
                <!-- Original Registration Form -->
                <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 overflow-hidden border border-slate-100 flex flex-col md:flex-row">
                    <div class="bg-primary p-12 text-white md:w-2/5 flex flex-col justify-between">
                        <div class="space-y-6">
                            <h2 class="text-3xl font-black">دامەزراوەکەت زیاد بکە</h2>
                            <p class="text-sky-100 leading-relaxed">
                                ئەگەر خاوەنی خوێندنگا، باخچەی منداڵان، یان پەیمانگای، زانیارییەکانت بنێرە تا پێت بڵێین چۆن دەتوانیت ببیتە بەشێک لە پلاتفۆرمەکەمان.
                            </p>
                        </div>
                        <div class="mt-12 space-y-4 text-sm">
                            <div class="flex items-center gap-3">
                                <svg class="w-5 h-5 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" /></svg>
                                <span>+964 7XX XXX XX XX</span>
                            </div>
                            <div class="flex items-center gap-3">
                                <svg class="w-5 h-5 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>
                                <span>info@xwendngakanm.com</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="p-12 md:w-3/5">
                        @if (session('success'))
                            <div class="bg-emerald-50 text-emerald-700 p-6 rounded-2xl border border-emerald-100 mb-8 flex items-center gap-3">
                                <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                                <p class="font-bold">{{ session('success') }}</p>
                            </div>
                        @endif

                        @auth
                        <form action="{{ route('institution.register') }}" method="POST" class="space-y-6">
                            @csrf
                            <div class="space-y-2">
                                <label class="text-sm font-bold text-slate-700 mr-1">ناوی دامەزراوە</label>
                                <input type="text" name="name" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary transition-all" placeholder="ناوی خوێندنگاکەت بنووسە...">
                            </div>

                            <div class="space-y-2">
                                <label class="text-sm font-bold text-slate-700 mr-1">جۆر</label>
                                <select name="type" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary transition-all">
                                    @foreach($types as $type)
                                        <option value="{{ $type->key }}">{{ $type->emoji }} {{ $type->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            
                            <div class="space-y-2">
                                <label class="text-sm font-bold text-slate-700 mr-1">ژمارەی مۆبایل</label>
                                <input type="tel" name="phone" required class="w-full px-6 py-4 bg-slate-50 border-none rounded-2xl focus:ring-2 focus:ring-primary text-left dir-ltr transition-all" placeholder="07XX XXX XX XX">
                            </div>
                            
                            <button type="submit" class="w-full py-5 bg-primary text-white rounded-2xl font-bold hover:bg-secondary hover:shadow-xl transition-all">تۆمارکردنی دامەزراوە و دەستپێکردن</button>
                        </form>
                        @else
                        <div class="py-12 text-center space-y-8">
                            <div class="w-20 h-20 bg-primary/10 rounded-full flex items-center justify-center mx-auto text-primary">
                                <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                            </div>
                            <div class="space-y-4">
                                <h3 class="text-2xl font-black text-slate-900">بۆ ناردنی داواکاری پێویستە بچیتە ناو هەژمارەکەت</h3>
                                <p class="text-slate-500 max-w-sm mx-auto">بۆ ئەوەی بتوانیت دامەزراوەکەت تۆمار بکەیت و زانیارییەکانت بڵاو بکەیتەوە، تکایە سەرەتا بچۆ ناو هەژمارەکەت یان هەژمارێکی نوێ دروست بکە.</p>
                            </div>
                            <button @click="showLogin = true" class="px-12 py-5 bg-primary text-white rounded-2xl font-black text-lg shadow-xl shadow-sky-100 hover:bg-secondary transition-all">چوونەژوورەوە و دەستپێکردن</button>
                        </div>
                        @endauth
                    </div>
                </div>
            @endif
        </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 border-t border-slate-200">
        <div class="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-8">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-slate-200 rounded-lg flex items-center justify-center font-bold text-slate-600">خ</div>
                <span class="font-bold text-slate-500 italic">خوێندنگاکانم</span>
            </div>
            <p class="text-sm text-slate-400">© {{ date('Y') }} خوێندنگاکانم. هەموو مافەکان پارێزراوە.</p>
            <div class="flex gap-6 text-slate-400">
                <a href="#" class="hover:text-primary transition-colors italic">Facebook</a>
                <a href="#" class="hover:text-primary transition-colors italic">Instagram</a>
                <a href="#" class="hover:text-primary transition-colors italic">Snapchat</a>
            </div>
        </div>
    </footer>

</body>
</html>
