<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CvResource\Pages;
use App\Models\Cv;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;

class CvResource extends Resource
{
    protected static ?string $model = Cv::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-text';

    protected static ?string $navigationLabel = 'CVکان';

    protected static ?string $modelLabel = 'CV';

    protected static ?string $pluralModelLabel = 'CVکان';

    protected static ?string $navigationGroup = 'هەموو بابەتەکان';

    protected static ?int $navigationSort = 2;

    protected static ?string $recordTitleAttribute = 'name';

    public static function getNavigationBadge(): ?string
    {
        $pending = static::getModel()::where('is_reviewed', false)->count();
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
                // ─── زانیاری کەسی ───
                Forms\Components\Section::make('زانیاری کەسی')
                    ->description('زانیاریە سەرەکییەکانی کەسەکە')
                    ->icon('heroicon-o-user')
                    ->schema([
                        Forms\Components\FileUpload::make('photo')
                            ->label('وێنە')
                            ->image()
                            ->directory('cvs')
                            ->disk('public')
                            ->imagePreviewHeight('150')
                            ->maxSize(2048)
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('name')
                            ->label('ناوی سیانی')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->label('ژمارەی تەلەفۆن')
                            ->tel()
                            ->required()
                            ->maxLength(20),
                        Forms\Components\TextInput::make('email')
                            ->label('ئیمەیڵ')
                            ->email()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('city')
                            ->label('شار')
                            ->required()
                            ->maxLength(100),
                        Forms\Components\TextInput::make('age')
                            ->label('تەمەن')
                            ->numeric()
                            ->minValue(15)
                            ->maxValue(100),
                        Forms\Components\Select::make('gender')
                            ->label('ڕەگەز')
                            ->options([
                                'male' => 'نێر',
                                'female' => 'مێ',
                                'other' => 'تر',
                            ])
                            ->native(false),
                    ])->columns(2),

                // ─── زانیاری خوێندن ───
                Forms\Components\Section::make('زانیاری خوێندن')
                    ->description('زانیاری دەربارەی خوێندن و بوار')
                    ->icon('heroicon-o-academic-cap')
                    ->schema([
                        Forms\Components\TextInput::make('field')
                            ->label('بواری خوێندن / پیشە')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('education_level')
                            ->label('ئاستی خوێندن')
                            ->options([
                                'پۆلی یەکەم' => 'پۆلی یەکەم',
                                'پۆلی دووەم' => 'پۆلی دووەم',
                                'پۆلی سێیەم' => 'پۆلی سێیەم',
                                'پۆلی چوارەم' => 'پۆلی چوارەم',
                                'دەرچوو' => 'دەرچوو',
                                'ماستەر' => 'ماستەر',
                                'دکتۆرا' => 'دکتۆرا',
                            ])
                            ->native(false),
                        Forms\Components\TextInput::make('graduation_year')
                            ->label('ساڵی دەرچوون')
                            ->maxLength(10),
                    ])->columns(3),

                // ─── ئەزموون و بەهرەکان ───
                Forms\Components\Section::make('ئەزموون و بەهرەکان')
                    ->description('ئەزموون و تایبەتمەندییەکان')
                    ->icon('heroicon-o-briefcase')
                    ->schema([
                        Forms\Components\Textarea::make('experience')
                            ->label('ئەزموونی کار')
                            ->rows(3)
                            ->maxLength(2000),
                        Forms\Components\Textarea::make('skills')
                            ->label('بەهرەکان / تایبەتمەندییەکان')
                            ->rows(2)
                            ->maxLength(1000),
                        Forms\Components\Textarea::make('notes')
                            ->label('تێبینی')
                            ->rows(2)
                            ->maxLength(1000),
                    ])->columns(1),

                // ─── دۆخ ───
                Forms\Components\Section::make('دۆخ')
                    ->schema([
                        Forms\Components\Toggle::make('is_reviewed')
                            ->label('پشکنینکراو')
                            ->helperText('ئایا ئەم CVیە لەلایەن ئەدمینەوە پشکنینکراوە؟'),
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
                    ->label('ناو')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('phone')
                    ->label('تەلەفۆن')
                    ->searchable()
                    ->copyable()
                    ->icon('heroicon-o-phone'),
                Tables\Columns\TextColumn::make('city')
                    ->label('شار')
                    ->searchable()
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('field')
                    ->label('بوار')
                    ->searchable()
                    ->limit(30)
                    ->wrap(),
                Tables\Columns\TextColumn::make('education_level')
                    ->label('ئاست')
                    ->badge()
                    ->color('success'),
                Tables\Columns\IconColumn::make('is_reviewed')
                    ->label('پشکنینکراو')
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
                Tables\Filters\SelectFilter::make('is_reviewed')
                    ->label('دۆخ')
                    ->options([
                        true => 'پشکنینکراو',
                        false => 'چاوەڕوانی پشکنین',
                    ]),
                Tables\Filters\SelectFilter::make('city')
                    ->label('شار')
                    ->options(fn () => Cv::distinct()->pluck('city', 'city')->toArray()),
                Tables\Filters\SelectFilter::make('education_level')
                    ->label('ئاستی خوێندن')
                    ->options([
                        'پۆلی یەکەم' => 'پۆلی یەکەم',
                        'پۆلی دووەم' => 'پۆلی دووەم',
                        'پۆلی سێیەم' => 'پۆلی سێیەم',
                        'پۆلی چوارەم' => 'پۆلی چوارەم',
                        'دەرچوو' => 'دەرچوو',
                        'ماستەر' => 'ماستەر',
                        'دکتۆرا' => 'دکتۆرا',
                    ]),
            ])
            ->actions([
                Tables\Actions\Action::make('toggleReview')
                    ->label(fn ($record) => $record->is_reviewed ? 'نەپشکنینکراو' : 'پشکنینکراو')
                    ->icon(fn ($record) => $record->is_reviewed ? 'heroicon-m-x-circle' : 'heroicon-m-check-circle')
                    ->color(fn ($record) => $record->is_reviewed ? 'danger' : 'success')
                    ->button()
                    ->action(function ($record) {
                        $record->update(['is_reviewed' => !$record->is_reviewed]);
                        Notification::make()
                            ->title($record->is_reviewed ? 'وەک پشکنینکراو نیشانکرا' : 'وەک نەپشکنینکراو نیشانکرا')
                            ->success()
                            ->send();
                    }),
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\DeleteAction::make(),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('markReviewed')
                        ->label('نیشانکردن وەک پشکنینکراو')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn (Collection $records) => $records->each->update(['is_reviewed' => true]))
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\BulkAction::make('markNotReviewed')
                        ->label('نیشانکردن وەک نەپشکنینکراو')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn (Collection $records) => $records->each->update(['is_reviewed' => false]))
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
            'index' => Pages\ListCvs::route('/'),
            'create' => Pages\CreateCv::route('/create'),
            'view' => Pages\ViewCv::route('/{record}'),
            'edit' => Pages\EditCv::route('/{record}/edit'),
        ];
    }
}
