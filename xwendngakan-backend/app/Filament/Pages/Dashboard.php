<?php

namespace App\Filament\Pages;

use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    protected static ?string $navigationLabel = 'داشبۆرد';
    protected static ?string $title = 'داشبۆرد';
    protected static ?string $navigationGroup = 'سەرەکی';
    protected static ?int $navigationSort = -10;

    public function getHeading(): string
    {
        return 'داشبۆرد';
    }
}
