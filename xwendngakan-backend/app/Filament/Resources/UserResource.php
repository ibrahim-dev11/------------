<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Hash;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = 'بەکارهێنەران';

    protected static ?string $modelLabel = 'بەکارهێنەر';

    protected static ?string $pluralModelLabel = 'بەکارهێنەران';

    protected static ?string $navigationGroup = 'سیستەم';

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'name';

    public static function getNavigationBadge(): ?string
    {
        return (string) static::getModel()::count();
    }

    public static function getNavigationBadgeColor(): string|array|null
    {
        return 'info';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('زانیاری بەکارهێنەر')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('ناو')
                            ->required()
                            ->markAsRequired(false)
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->label('ئیمەیڵ')
                            ->email()
                            ->required()
                            ->markAsRequired(false)
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\TextInput::make('password')
                            ->label('وشەی نهێنی')
                            ->password()
                            ->revealable()
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $operation): bool => $operation === 'create')
                            ->markAsRequired(false)
                            ->maxLength(255),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('ناو')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->icon('heroicon-o-user'),
                Tables\Columns\TextColumn::make('email')
                    ->label('ئیمەیڵ')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->icon('heroicon-o-envelope'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('بەرواری تۆمارکردن')
                    ->dateTime('Y/m/d H:i')
                    ->sortable()
                    ->icon('heroicon-o-calendar'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([])
            ->actions([
                Tables\Actions\Action::make('sendNotification')
                    ->label('ناردنی نۆتیفیکەیشن')
                    ->icon('heroicon-o-chat-bubble-left-ellipsis')
                    ->color('success')
                    ->form([
                        Forms\Components\TextInput::make('title')
                            ->label('ناونیشان')
                            ->required()
                            ->default('پەیامێک لە لایەن بەڕێوەبەر'),
                        Forms\Components\Textarea::make('message')
                            ->label('پەیام')
                            ->required()
                            ->rows(3),
                    ])
                    ->action(function (User $record, array $data): void {
                        $firebase = app(FirebaseNotificationService::class);
                        
                        // Save to database
                        $record->notify(new \App\Notifications\AdminMessage(
                            $data['title'],
                            $data['message']
                        ));
                        
                        // Send via Firebase if user has FCM token
                        if ($record->fcm_token && $record->notifications_enabled) {
                            $firebase->sendToToken(
                                $record->fcm_token,
                                $data['title'],
                                $data['message']
                            );
                        }
                        
                        \Filament\Notifications\Notification::make()
                            ->title('نۆتیفیکەیشن بە سەرکەوتوویی نێردرا')
                            ->success()
                            ->send();
                    }),
                Tables\Actions\EditAction::make()->label('دەستکاری'),
                Tables\Actions\DeleteAction::make()->label('سڕینەوە'),
            ])
            ->bulkActions([])
            ->striped();
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
