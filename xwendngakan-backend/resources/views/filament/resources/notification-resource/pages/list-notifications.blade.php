<x-filament-panels::page>
    <div class="space-y-6">
        <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
            <h3 class="text-sm font-semibold text-blue-900 dark:text-blue-200">ℹ️ سەبارەت بە نۆتیفیکەیشن</h3>
            <p class="mt-2 text-sm text-blue-800 dark:text-blue-300">
                لێرە دەتوانیت نۆتیفیکەیشن لە طریقی Firebase بنێریت بۆ بەکارهێنەرانی ئەپلیکەیشن. 
                هەموو بەکارهێنەرێک کە ئەپلیکەیشنەکەی لۆقیننەت و FCM تۆکنیان هەیە ئەیانوەی ئاگادارکردنەوەکە.
            </p>
        </div>

        {{ $this->form }}
    </div>
</x-filament-panels::page>
