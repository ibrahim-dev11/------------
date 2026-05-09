<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeacherResource\Pages;
use App\Models\Teacher;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;

class TeacherResource extends Resource
{
    protected static ?string $model = Teacher::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';

    protected static ?string $navigationLabel = 'مامۆستاکان';

    protected static ?string $modelLabel = 'ماموستا';

    protected static ?string $pluralModelLabel = 'مامۆستاکان';

    protected static ?string $navigationGroup = 'بەڕێوەبردن';

    protected static ?int $navigationSort = 3;

    protected static ?string $recordTitleAttribute = 'name';

    public static function getNavigationBadge(): ?string
    {
        $pending = static::getModel()::where('is_approved', false)->count();
        return $pending > 0 ? (string) $pending : null;
    }

    public static function getNavigationBadgeColor(): string|array|null
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('زانیاری ماموستا')
                    ->description('زانیاریە سەرەکییەکانی ماموستا')
                    ->icon('heroicon-o-user')
                    ->schema([
                        Forms\Components\FileUpload::make('photo')
                            ->label('وێنەی ماموستا')
                            ->image()
                            ->directory('teachers')
                            ->disk('public')
                            ->imagePreviewHeight('150')
                            ->maxSize(2048),
                        Forms\Components\FileUpload::make('subject_photo')
                            ->label('وێنەی بابەت')
                            ->image()
                            ->directory('teachers')
                            ->disk('public')
                            ->imagePreviewHeight('150')
                            ->maxSize(2048),
                        Forms\Components\TextInput::make('name')
                            ->label('ناوی سیانی')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->label('ژمارەی تەلەفۆن')
                            ->tel()
                            ->required()
                            ->maxLength(20),
                        Forms\Components\TextInput::make('subject')
                            ->label('بابەت / پسپۆڕی')
                            ->maxLength(255),
                        Forms\Components\Select::make('type')
                            ->label('جۆری ماموستا')
                            ->options([
                                'university' => 'ماموستای زانکۆ',
                                'school' => 'ماموستای قوتابخانە',
                            ])
                            ->required()
                            ->native(false),
                        Forms\Components\TextInput::make('city')
                            ->label('شار')
                            ->required()
                            ->maxLength(100),
                        Forms\Components\TextInput::make('experience_years')
                            ->label('ساڵانی ئەزموون')
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(60),
                        Forms\Components\TextInput::make('hourly_rate')
                            ->label('نرخی کاتژمێرێک (دینار)')
                            ->numeric()
                            ->minValue(0),
                    ])->columns(2),

                Forms\Components\Section::make('دەربارە و ڤیدیۆ')
                    ->icon('heroicon-o-document-text')
                    ->schema([
                        Forms\Components\Textarea::make('about')
                            ->label('دەربارەی ماموستا')
                            ->rows(4)
                            ->maxLength(2000),
                        Forms\Components\TextInput::make('video_url')
                            ->label('لینکی ڤیدیۆ (YouTube)')
                            ->url()
                            ->placeholder('https://www.youtube.com/watch?v=...')
                            ->maxLength(255),
                    ]),


                Forms\Components\Section::make('دۆخ')
                    ->schema([
                        Forms\Components\Toggle::make('is_approved')
                            ->label('پەسەندکراو')
                            ->helperText('ئایا ئەم ماموستایە پەسەندکراوە بۆ پیشاندان بە قوتابیان؟'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('وێنە')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=3b82f6&color=fff'),
                Tables\Columns\TextColumn::make('name')
                    ->label('ناوی مامۆستا')
                    ->searchable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('subject')
                    ->label('پسپۆڕی')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('تەلەفۆن')
                    ->searchable()
                    ->copyable()
                    ->icon('heroicon-o-phone'),
                Tables\Columns\TextColumn::make('type')
                    ->label('جۆر')
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'university' => 'ماموستای زانکۆ',
                        'school' => 'ماموستای قوتابخانە',
                        default => '-',
                    })
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'university' => 'info',
                        'school' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('city')
                    ->label('شار')
                    ->searchable()
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('experience_years')
                    ->label('ئەزموون')
                    ->suffix(' ساڵ')
                    ->sortable(),
                Tables\Columns\TextColumn::make('hourly_rate')
                    ->label('نرخ/کاتژمێر')
                    ->suffix(' دینار')
                    ->sortable(),
                Tables\Columns\TextColumn::make('video_url')
                    ->label('ڤیدیۆ')
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->copyable(),
                Tables\Columns\IconColumn::make('is_approved')

                    ->label('پەسەندکراو')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('کاتی تۆمارکردن')
                    ->dateTime('Y/m/d H:i')
                    ->sortable()
                    ->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('is_approved')
                    ->label('دۆخ')
                    ->options([
                        true => 'پەسەندکراو',
                        false => 'چاوەڕوانی پەسەندکردن',
                    ]),
                Tables\Filters\SelectFilter::make('type')
                    ->label('جۆر')
                    ->options([
                        'university' => 'ماموستای زانکۆ',
                        'school' => 'ماموستای قوتابخانە',
                    ]),
                Tables\Filters\SelectFilter::make('city')
                    ->label('شار')
                    ->options(fn () => Teacher::distinct()->pluck('city', 'city')->toArray()),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('toggleApproval')
                        ->label(fn ($record) => $record->is_approved ? 'لابردنی پەسەند' : 'پەسەندکردن')
                        ->icon(fn ($record) => $record->is_approved ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                        ->color(fn ($record) => $record->is_approved ? 'danger' : 'success')
                        ->action(function ($record) {
                            $record->update(['is_approved' => !$record->is_approved]);
                            Notification::make()
                                ->title($record->is_approved ? 'ماموستا پەسەندکرا' : 'پەسەندکردن لابرا')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\DeleteAction::make(),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('approve')
                        ->label('پەسەندکردن')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn (Collection $records) => $records->each->update(['is_approved' => true]))
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\BulkAction::make('unapprove')
                        ->label('لابردنی پەسەند')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn (Collection $records) => $records->each->update(['is_approved' => false]))
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeachers::route('/'),
            'create' => Pages\CreateTeacher::route('/create'),
            'view' => Pages\ViewTeacher::route('/{record}'),
            'edit' => Pages\EditTeacher::route('/{record}/edit'),
        ];
    }
}
