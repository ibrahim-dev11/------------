<?php

use Illuminate\Http\Request;
use App\Models\InstitutionType;
use App\Models\Institution;
use App\Models\Post;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

// Root: redirect to portal
Route::get('/', function () {
    if (auth()->check()) return redirect()->route('portal.dashboard');
    return redirect()->route('portal.home');
})->name('home');

// =====================
//  INSTITUTION PORTAL
// =====================
Route::prefix('portal')->name('portal.')->group(function () {

    // ---- Public ----
    Route::get('/', function () {
        if (auth()->check()) return redirect()->route('portal.dashboard');
        return view('portal.home');
    })->name('home');

    Route::get('/login', function () {
        if (auth()->check()) {
            if (auth()->user()->is_approved || auth()->user()->is_admin) {
                return redirect()->route('portal.dashboard');
            }
            return redirect()->route('portal.waiting');
        }
        return view('portal.auth.login');
    })->name('login');

    Route::post('/login', function (Request $request) {
        $credentials = $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);
        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();
            return redirect()->route('portal.dashboard');
        }
        return back()->withErrors(['email' => 'ئیمەیڵ یان وشەی نهێنی هەڵەیە.'])->withInput();
    })->name('login.submit');

    Route::get('/register', function () {
        if (auth()->check()) return redirect()->route('portal.dashboard');
        return view('portal.auth.register');
    })->name('register');

    Route::post('/register', function (Request $request) {
        $data = $request->validate([
            'name'                  => 'required|string|max:255',
            'email'                 => 'required|string|email|max:255|unique:users',
            'password'              => 'required|string|min:8|confirmed',
        ]);
        $user = User::create([
            'name'        => $data['name'],
            'email'       => $data['email'],
            'password'    => Hash::make($data['password']),
            'is_approved' => false,
        ]);
        Auth::login($user);
        return redirect()->route('portal.waiting');
    })->name('register.submit');

    Route::get('/waiting-approval', function () {
        if (!auth()->check()) return redirect()->route('portal.login');
        if (auth()->user()->is_approved || auth()->user()->is_admin) return redirect()->route('portal.dashboard');
        return view('portal.auth.waiting');
    })->name('waiting');

    Route::post('/logout', function (Request $request) {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('portal.home');
    })->name('logout');

    // ---- Protected ----
    Route::middleware(['auth', 'approved'])->group(function () {

        Route::get('/dashboard', function () {
            $institution = auth()->user()->institution;
            $posts = $institution
                ? Post::where('institution_id', $institution->id)->latest()->get()
                : collect();
            $types = InstitutionType::active()->ordered()->get();
            // Map of type key → academic flags for JavaScript
            $typeFlags = $types->keyBy('key')->map(fn($t) => [
                'has_colleges'    => (bool) $t->has_colleges,
                'has_departments' => (bool) $t->has_departments,
            ])->toArray();
            return view('portal.dashboard', compact('institution', 'posts', 'types', 'typeFlags'));
        })->name('dashboard');

        Route::post('/institution/save', function (Request $request) {
            $user = auth()->user();
            $data = $request->validate([
                'nku'      => 'required|string|max:255',
                'nar'      => 'nullable|string|max:255',
                'nen'      => 'nullable|string|max:255',
                'type'     => 'required|string',
                'country'  => 'required|string|max:255',
                'city'     => 'required|string|max:255',
                'phone'    => 'nullable|string|max:20',
                'email'    => 'nullable|email|max:255',
                'addr'     => 'nullable|string|max:500',
                'desc'     => 'nullable|string',
                'desc_en'  => 'nullable|string',
                'desc_ar'  => 'nullable|string',
                'web'      => 'nullable|url|max:255',
                'colleges'         => 'nullable|array',
                'colleges.*'       => 'nullable|string|max:255',
                'depts'            => 'nullable|array',
                'depts.*'          => 'nullable|string|max:255',
                'tuition_dept'     => 'nullable|array',
                'tuition_fee'      => 'nullable|array',
                'tuition_discount' => 'nullable|array',
                'fb'               => 'nullable|string|max:255',
                'ig'       => 'nullable|string|max:255',
                'tg'       => 'nullable|string|max:255',
                'wa'       => 'nullable|string|max:50',
                'tk'       => 'nullable|string|max:255',
                'yt'       => 'nullable|string|max:255',
                'img'      => 'nullable|image|max:4096',
                'logo'     => 'nullable|image|max:2048',
            ]);

            if ($request->hasFile('img')) {
                $path = $request->file('img')->store('institutions', 'public');
                $data['img'] = '/storage/' . $path;
            }
            if ($request->hasFile('logo')) {
                $path = $request->file('logo')->store('institutions/logos', 'public');
                $data['logo'] = '/storage/' . $path;
            }

            // Convert colleges[] array → newline string
            $data['colleges'] = implode("\n", array_filter(array_map('trim', $data['colleges'] ?? [])));
            $data['depts']    = implode("\n", array_filter(array_map('trim', $data['depts'] ?? [])));

            // Build tuition_plans JSON from parallel arrays
            $tuitionDepts     = $data['tuition_dept'] ?? [];
            $tuitionFees      = $data['tuition_fee'] ?? [];
            $tuitionDiscounts = $data['tuition_discount'] ?? [];
            unset($data['tuition_dept'], $data['tuition_fee'], $data['tuition_discount']);
            $tuitionPlans = [];
            foreach ($tuitionDepts as $i => $dept) {
                if (!empty(trim((string)$dept))) {
                    $tuitionPlans[] = [
                        'dept'     => trim((string)$dept),
                        'fee'      => trim((string)($tuitionFees[$i] ?? '')),
                        'discount' => trim((string)($tuitionDiscounts[$i] ?? '')),
                    ];
                }
            }
            $data['tuition_plans'] = json_encode($tuitionPlans, JSON_UNESCAPED_UNICODE);

            if ($user->institution) {
                $user->institution->update($data);
            } else {
                $data['user_id']  = $user->id;
                $data['approved'] = false;
                Institution::create($data);
            }
            return back()->with('success', 'زانیارییەکانی دامەزراوەکەت بە سەرکەوتوویی تۆمارکران.');
        })->name('institution.save');

        Route::post('/posts/store', function (Request $request) {
            $institution = auth()->user()->institution;
            if (!$institution) return back()->with('error', 'پێشتر دامەزراوەکەت تۆمار بکە.');
            if (!$institution->approved) return back()->with('error', 'دامەزراوەکەت هێشتا قبوڵ نەکراوە. پاش قبوڵکردنی ئەدمین دەتوانیت پۆست بکەیت.');

            $data = $request->validate([
                'title'   => 'required|string|max:255',
                'content' => 'required|string',
                'image'   => 'nullable|image|max:4096',
            ]);

            $post = new Post();
            $post->institution_id = $institution->id;
            $post->title          = $data['title'];
            $post->content        = $data['content'];
            $post->approved       = false;

            if ($request->hasFile('image')) {
                $path = $request->file('image')->store('posts', 'public');
                $post->image = '/storage/' . $path;
            }
            $post->save();
            return back()->with('success', 'پۆستەکەت بە سەرکەوتوویی نێردرا — چاوەڕوانی پەسەندکردنی ئەدمینە.');
        })->name('posts.store');

        Route::delete('/posts/{id}', function ($id) {
            $institution = auth()->user()->institution;
            if (!$institution) abort(403);
            $post = Post::where('id', $id)->where('institution_id', $institution->id)->firstOrFail();
            $post->delete();
            return back()->with('success', 'پۆستەکە سڕایەوە.');
        })->name('posts.delete');
    });
});
