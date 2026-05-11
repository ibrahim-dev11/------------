<?php

namespace App\Filament\Widgets;

use App\Models\Institution;
use App\Models\User;
use App\Models\Teacher;
use App\Models\Post;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class GreetingWidget extends BaseWidget
{
    protected static ?int $sort = -1;

    protected function getStats(): array
    {
        return [
            Stat::make('کۆی دامەزراوەکان', Institution::count())
                ->color('success'),
            Stat::make('چاوەڕوانی پەسەندکردن', Institution::where('approved', false)->count())
                ->color('warning'),
            Stat::make('بەکارهێنەران', User::count())
                ->color('info'),
            Stat::make('مامۆستاکان', Teacher::count())
                ->color('primary'),
            Stat::make('پۆستەکان', Post::count())
                ->color('success'),
            Stat::make('داواکاری مامۆستا', \App\Models\TeacherRequest::count())
                ->color('danger'),
        ];
    }
}
