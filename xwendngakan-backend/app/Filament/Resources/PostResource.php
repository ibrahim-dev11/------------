<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PostResource\Pages;
use App\Models\Post;
use App\Models\Institution;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;

class PostResource extends Resource
{
    protected static ?string $model = Post::class;

    protected static ?string $navigationIcon = 'heroicon-o-newspaper';

    protected static ?string $navigationLabel = 'پۆستەکان';

    protected static ?string $modelLabel = 'پۆست';

    protected static ?string $pluralModelLabel = 'پۆستەکان';

    protected static ?string $navigationGroup = 'بەڕێوەبردن';

    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        $pending = static::getModel()::where('approved', false)->count();
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
                Forms\Components\Section::make('ناوەڕۆکی پۆست')
                    ->description('زانیاری و ناوەڕۆکی پۆستەکە بنووسە')
                    ->icon('heroicon-o-document-text')
                    ->schema([
                        Forms\Components\Select::make('institution_id')
                            ->label('دامەزراوە')
                            ->relationship('institution', 'nku')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->columnSpanFull(),
                        
                        Forms\Components\TextInput::make('title')
                            ->label('ناونیشان')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('ناونیشانی پۆستەکە...'),

                        Forms\Components\Toggle::make('approved')
                            ->label('پەسەندکراو')
                            ->default(true)
                            ->helperText('ئەگەر چالاک بێت، لە ئەپەکەدا پیشان دەدرێت'),

                        Forms\Components\Textarea::make('content')
                            ->label('ناوەڕۆک')
                            ->required()
                            ->rows(5)
                            ->placeholder('چی ڕوویداوە؟ لێرە بینووسە...')
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('image')
                            ->label('وێنە')
                            ->image()
                            ->directory('posts')
                            ->disk('public')
                            ->imagePreviewHeight('250')
                            ->maxSize(2048)
                            ->columnSpanFull(),
                        
                        Forms\Components\Hidden::make('user_id')
                            ->default(auth()->id()),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('وێنە')
                    ->disk('public')
                    ->square()
                    ->size(50),
                
                Tables\Columns\TextColumn::make('title')
                    ->label('ناونیشان')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->institution?->nku),

                Tables\Columns\IconColumn::make('approved')
                    ->label('پەسەند')
                    ->boolean()
                    ->sortable()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('بەروار')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->color('gray'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('institution_id')
                    ->label('دامەزراوە')
                    ->relationship('institution', 'nku')
                    ->searchable(),
                
                Tables\Filters\TernaryFilter::make('approved')
                    ->label('بارودۆخ')
                    ->trueLabel('پەسەندکراو')
                    ->falseLabel('چاوەڕوان'),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\EditAction::make()->label('دەستکاری'),
                    Tables\Actions\Action::make('toggleApproval')
                        ->label(fn (Post $record) => $record->approved ? 'ڕەتکردنەوە' : 'پەسەندکردن')
                        ->icon(fn (Post $record) => $record->approved ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                        ->color(fn (Post $record) => $record->approved ? 'danger' : 'success')
                        ->requiresConfirmation()
                        ->action(function (Post $record) {
                            $record->update(['approved' => !$record->approved]);
                            Notification::make()
                                ->title($record->approved ? 'پەسەندکرا' : 'ڕەتکرایەوە')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\DeleteAction::make()->label('سڕینەوە'),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
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
            'index' => Pages\ListPosts::route('/'),
            'create' => Pages\CreatePost::route('/create'),
            'edit' => Pages\EditPost::route('/{record}/edit'),
        ];
    }
}
