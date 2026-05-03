<?php

use Illuminate\Http\Request;
use App\Models\InstitutionRequest;
use App\Models\Institution;
use App\Models\InstitutionType;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

Route::get('/', function () {
    $institution = null;
    $types = InstitutionType::active()->ordered()->get();
    
    if (auth()->check()) {
        $institution = auth()->user()->institution;
    }

    return view('welcome', compact('institution', 'types'));
})->name('home');

Route::post('/register', function (Request $request) {
    $data = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:8|confirmed',
    ]);

    $user = User::create([
        'name' => $data['name'],
        'email' => $data['email'],
        'password' => Hash::make($data['password']),
    ]);

    Auth::login($user);

    return redirect('/')->with('success', 'هەژمارەکەت بە سەرکەوتوویی دروستکرا!');
})->name('register.submit');

Route::get('/login', function () {
    return redirect('/?login=1');
})->name('login');

Route::post('/login', function (Request $request) {
    $credentials = $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    if (Auth::attempt($credentials)) {
        $request->session()->regenerate();
        return redirect('/')->with('success', 'بەخێربێیتەوە!');
    }

    return back()->withErrors([
        'email' => 'زانیارییەکان ڕاست نین.',
    ]);
})->name('login.submit');

Route::post('/logout', function (Request $request) {
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();
    return redirect('/');
})->name('logout');

Route::post('/join', function (Request $request) {
    $data = $request->validate([
        'name' => 'required|string|max:255',
        'phone' => 'required|string|max:20',
        'message' => 'nullable|string',
    ]);

    InstitutionRequest::create([
        'name' => $data['name'],
        'phone' => $data['phone'],
        'message' => $data['message'],
        'status' => 'pending',
    ]);

    return back()->with('success', 'سوپاس بۆ داواکارییەکەت! بە زووترین کات پەیوەندیت پێوە دەکەین.');
})->name('join.submit');

Route::post('/institution/register', function (Request $request) {
    if (!auth()->check()) return redirect()->route('login');

    $data = $request->validate([
        'name' => 'required|string|max:255',
        'type' => 'required|string',
        'phone' => 'required|string|max:20',
    ]);

    $institution = Institution::create([
        'user_id' => auth()->id(),
        'nku' => $data['name'],
        'type' => $data['type'],
        'phone' => $data['phone'],
        'approved' => false, // Initially unapproved
    ]);

    return back()->with('success', 'دامەزراوەکەت بە سەرکەوتوویی تۆمارکرا! ئێستا دەتوانیت پۆست و زانیارییەکان زیاد بکەیت.');
})->name('institution.register');

Route::post('/institution/update', function (Request $request) {
    if (!auth()->check() || !auth()->user()->institution) {
        return back()->with('error', 'دەستگەیشتن ڕێگەنەدراوە.');
    }

    $institution = auth()->user()->institution;
    
    $data = $request->validate([
        'nku' => 'required|string|max:255',
        'nen' => 'nullable|string|max:255',
        'nar' => 'nullable|string|max:255',
        'type' => 'required|string',
        'addr' => 'nullable|string',
        'lat' => 'nullable|numeric',
        'lng' => 'nullable|numeric',
        'desc' => 'nullable|string',
        'phone' => 'nullable|string',
        'email' => 'nullable|email',
        'web' => 'nullable|url',
        'wa' => 'nullable|string',
        'fb' => 'nullable|string',
        'img' => 'nullable|image|max:2048',
    ]);

    $data['approved'] = $request->has('approved');

    if ($request->hasFile('img')) {
        $path = $request->file('img')->store('institutions', 'public');
        $data['img'] = '/storage/' . $path;
    }

    $institution->update($data);

    return back()->with('success', 'زانیارییەکان بە سەرکەوتوویی نوێکرانەوە.');
})->name('institution.update');

Route::post('/posts/store', function (Request $request) {
    if (!auth()->check() || !auth()->user()->institution) {
        return back()->with('error', 'دەستگەیشتن ڕێگەنەدراوە.');
    }

    $institution = auth()->user()->institution;

    $data = $request->validate([
        'title' => 'required|string|max:255',
        'content' => 'required|string',
        'img' => 'nullable|image|max:2048',
    ]);

    $post = new \App\Models\Post($data);
    $post->institution_id = $institution->id;

    if ($request->hasFile('img')) {
        $path = $request->file('img')->store('posts', 'public');
        $post->img = '/storage/' . $path;
    }

    $post->save();

    return back()->with('success', 'پۆستەکە بە سەرکەوتوویی بڵاوکرایەوە.');
})->name('posts.store');
