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
                'clg'                    => 'nullable|array',
                'clg.*.name'             => 'nullable|string|max:255',
                'clg.*.fee'              => 'nullable|string|max:50',
                'clg.*.discount'         => 'nullable|string|max:20',
                'clg.*.depts'            => 'nullable|array',
                'clg.*.depts.*.name'     => 'nullable|string|max:255',
                'clg.*.depts.*.fee'      => 'nullable|string|max:50',
                'clg.*.depts.*.discount' => 'nullable|string|max:20',
                'simple_dept'            => 'nullable|array',
                'simple_dept.*'          => 'nullable|string|max:255',
                'simple_fee'             => 'nullable|array',
                'simple_discount'        => 'nullable|array',
                'fb'               => 'nullable|string|max:255',
                'ig'       => 'nullable|string|max:255',
                'tg'       => 'nullable|string|max:255',
                'wa'       => 'nullable|string|max:50',
                'tk'       => 'nullable|string|max:255',
                'yt'       => 'nullable|string|max:255',
                'img'      => 'nullable|image|max:10240',
                'logo'     => 'nullable|image|max:10240',
            ]);

            if ($request->hasFile('img')) {
                $path = $request->file('img')->store('institutions', 'public');
                $data['img'] = '/storage/' . $path;
            }
            if ($request->hasFile('logo')) {
                $path = $request->file('logo')->store('institutions/logos', 'public');
                $data['logo'] = '/storage/' . $path;
            }

            // Build unified colleges JSON + tuition_plans from new nested form
            $clgInput    = $data['clg'] ?? [];
            $simpleDepts = $data['simple_dept'] ?? [];
            $simpleFees  = $data['simple_fee'] ?? [];
            $simpleDiscs = $data['simple_discount'] ?? [];
            unset($data['clg'], $data['simple_dept'], $data['simple_fee'], $data['simple_discount']);

            $collegesJson = [];
            $tuitionPlans = [];
            $allDeptNames = [];

            if (!empty($clgInput)) {
                // Mode 1: has colleges (universities, institutes)
                foreach (array_values($clgInput) as $col) {
                    $colName = trim((string)($col['name'] ?? ''));
                    if (!$colName) continue;
                    $depts = [];
                    foreach (array_values($col['depts'] ?? []) as $dept) {
                        $dn = trim((string)($dept['name'] ?? ''));
                        if (!$dn) continue;
                        $fee  = trim((string)($dept['fee'] ?? ''));
                        $disc = trim((string)($dept['discount'] ?? ''));
                        $depts[]        = ['name' => $dn, 'fee' => $fee, 'discount' => $disc];
                        $allDeptNames[] = $dn;
                        $tuitionPlans[] = ['dept' => $dn, 'fee' => $fee, 'discount' => $disc];
                    }
                    $collegesJson[] = [
                        'name'     => $colName,
                        'fee'      => trim((string)($col['fee'] ?? '')),
                        'discount' => trim((string)($col['discount'] ?? '')),
                        'depts'    => $depts,
                    ];
                }
                $data['colleges'] = json_encode($collegesJson, JSON_UNESCAPED_UNICODE);
                $data['depts']    = implode("\n", $allDeptNames);
            } else {
                // Mode 2: simple depts (schools etc.)
                foreach ($simpleDepts as $i => $dn) {
                    $dn = trim((string)$dn);
                    if (!$dn) continue;
                    $allDeptNames[] = $dn;
                    $tuitionPlans[] = [
                        'dept'     => $dn,
                        'fee'      => trim((string)($simpleFees[$i] ?? '')),
                        'discount' => trim((string)($simpleDiscs[$i] ?? '')),
                    ];
                }
                $data['colleges'] = '';
                $data['depts']    = implode("\n", $allDeptNames);
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
