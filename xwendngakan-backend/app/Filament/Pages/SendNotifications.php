<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Forms;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use App\Models\User;
use App\Notifications\AdminMessage;
use Filament\Notifications\Notification;

class SendNotifications extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string $view = 'filament.pages.send-notifications';

    protected static ?string $navigationIcon = 'heroicon-o-bell-alert';

    protected static ?string $navigationLabel = 'ناردنی ئاگادارکردنەوە';

    protected static ?string $navigationGroup = 'سیستەم';

    protected static ?int $navigationSort = 15;

    public ?array $data = [];

    public function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->statePath('data')
            ->schema([
                Forms\Components\Tabs::make('ناردنی ئاگادارکردنەوە')
                    ->tabs([
                        Forms\Components\Tabs\Tab::make('بۆ هەموو بەکارهێنەر')
                            ->icon('heroicon-o-megaphone')
                            ->schema([
                                Forms\Components\Section::make()
                                    ->schema([
                                        Forms\Components\TextInput::make('broadcast_title')
                                            ->label('ناونیشان')
                                            ->placeholder('بۆ نموونە: بەڕێوەبەری سیستەم')
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('broadcast_body')
                                            ->label('پەیام')
                                            ->placeholder('پەیامی ئاگادارکردنەوەی خۆت بنووسە')
                                            ->rows(4)
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('broadcast_data')
                                            ->label('زانیاری زیاتر (JSON)')
                                            ->placeholder('{"link": "/path", "type": "announcement"}')
                                            ->columnSpanFull()
                                            ->helperText('بۆچوون: ناتێبەی'),

                                        Forms\Components\Actions::make([
                                            Forms\Components\Actions\Action::make('sendBroadcast')
                                                ->label('بلاوکردنەوە')
                                                ->icon('heroicon-o-paper-airplane')
                                                ->color('success')
                                                ->action(function (): void {
                                                    $data = $this->form->getState();

                                                    if (empty($data['broadcast_title']) || empty($data['broadcast_body'])) {
                                                        Notification::make()
                                                            ->title('ناونیشان و پەیام پێویست دەکەن')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $customData = [];
                                                    if (!empty($data['broadcast_data'])) {
                                                        try {
                                                            $customData = json_decode($data['broadcast_data'], true) ?? [];
                                                        } catch (\Exception $e) {
                                                            Notification::make()
                                                                ->title('فۆرمایتی JSON غەلەیە')
                                                                ->danger()
                                                                ->send();
                                                            return;
                                                        }
                                                    }

                                                    $users = User::where('notifications_enabled', true)->get();
                                                    $count = 0;
                                                    foreach ($users as $user) {
                                                        $user->notify(new AdminMessage(
                                                            $data['broadcast_title'],
                                                            $data['broadcast_body'],
                                                            $customData
                                                        ));
                                                        $count++;
                                                    }

                                                    Notification::make()
                                                        ->title("بڵاوکردنەوەی سەرکەوتوو")
                                                        ->body("ناردرا بۆ {$count} بەکارهێنەر")
                                                        ->success()
                                                        ->send();
                                                }),
                                        ])
                                            ->columnSpanFull()
                                            ->alignment('center'),
                                    ]),
                            ]),

                        Forms\Components\Tabs\Tab::make('بۆ یەک بەکارهێنەر')
                            ->icon('heroicon-o-user')
                            ->schema([
                                Forms\Components\Section::make()
                                    ->schema([
                                        Forms\Components\Select::make('single_user_id')
                                            ->label('بەکارهێنەر')
                                            ->options(User::query()->pluck('name', 'id'))
                                            ->searchable()
                                            ->preload()
                                            ->columnSpanFull(),

                                        Forms\Components\TextInput::make('single_title')
                                            ->label('ناونیشان')
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('single_body')
                                            ->label('پەیام')
                                            ->rows(4)
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('single_data')
                                            ->label('زانیاری زیاتر (JSON)')
                                            ->columnSpanFull()
                                            ->helperText('بۆچوون: ناتێبەی'),

                                        Forms\Components\Actions::make([
                                            Forms\Components\Actions\Action::make('sendSingle')
                                                ->label('ناردن')
                                                ->icon('heroicon-o-paper-airplane')
                                                ->color('success')
                                                ->action(function (): void {
                                                    $data = $this->form->getState();

                                                    if (empty($data['single_user_id'])) {
                                                        Notification::make()
                                                            ->title('بەکارهێنەر دیای هەبیت')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    if (empty($data['single_title']) || empty($data['single_body'])) {
                                                        Notification::make()
                                                            ->title('ناونیشان و پەیام پێویست دەکەن')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $user = User::find($data['single_user_id']);
                                                    if (!$user) {
                                                        Notification::make()
                                                            ->title('بەکارهێنەر نەدۆزرایەوە')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $customData = [];
                                                    if (!empty($data['single_data'])) {
                                                        try {
                                                            $customData = json_decode($data['single_data'], true) ?? [];
                                                        } catch (\Exception $e) {
                                                            Notification::make()
                                                                ->title('فۆرمایتی JSON غەلەیە')
                                                                ->danger()
                                                                ->send();
                                                            return;
                                                        }
                                                    }

                                                    $user->notify(new AdminMessage(
                                                        $data['single_title'],
                                                        $data['single_body'],
                                                        $customData
                                                    ));

                                                    Notification::make()
                                                        ->title('نۆتیفیکەیشن بە سەرکەوتوویی نێردرا')
                                                        ->success()
                                                        ->send();
                                                }),
                                        ])
                                            ->columnSpanFull()
                                            ->alignment('center'),
                                    ]),
                            ]),

                        Forms\Components\Tabs\Tab::make('بۆ گرووپی بەکارهێنەر')
                            ->icon('heroicon-o-users')
                            ->schema([
                                Forms\Components\Section::make()
                                    ->schema([
                                        Forms\Components\MultiSelect::make('group_user_ids')
                                            ->label('بەکارهێنەران')
                                            ->options(User::query()->pluck('name', 'id'))
                                            ->searchable()
                                            ->preload()
                                            ->columnSpanFull(),

                                        Forms\Components\TextInput::make('group_title')
                                            ->label('ناونیشان')
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('group_body')
                                            ->label('پەیام')
                                            ->rows(4)
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('group_data')
                                            ->label('زانیاری زیاتر (JSON)')
                                            ->columnSpanFull()
                                            ->helperText('بۆچوون: ناتێبەی'),

                                        Forms\Components\Actions::make([
                                            Forms\Components\Actions\Action::make('sendGroup')
                                                ->label('ناردن')
                                                ->icon('heroicon-o-paper-airplane')
                                                ->color('success')
                                                ->action(function (): void {
                                                    $data = $this->form->getState();

                                                    if (empty($data['group_user_ids'])) {
                                                        Notification::make()
                                                            ->title('بەکارهێنەری دیای هەبیت')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    if (empty($data['group_title']) || empty($data['group_body'])) {
                                                        Notification::make()
                                                            ->title('ناونیشان و پەیام پێویست دەکەن')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $users = User::whereIn('id', $data['group_user_ids'])
                                                        ->where('notifications_enabled', true)
                                                        ->get();

                                                    if ($users->isEmpty()) {
                                                        Notification::make()
                                                            ->title('هیچ بەکارهێنەرێک نەدۆزرایەوە')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $customData = [];
                                                    if (!empty($data['group_data'])) {
                                                        try {
                                                            $customData = json_decode($data['group_data'], true) ?? [];
                                                        } catch (\Exception $e) {
                                                            Notification::make()
                                                                ->title('فۆرمایتی JSON غەلەیە')
                                                                ->danger()
                                                                ->send();
                                                            return;
                                                        }
                                                    }

                                                    $count = 0;
                                                    foreach ($users as $user) {
                                                        $user->notify(new AdminMessage(
                                                            $data['group_title'],
                                                            $data['group_body'],
                                                            $customData
                                                        ));
                                                        $count++;
                                                    }

                                                    Notification::make()
                                                        ->title('ناردنی سەرکەوتوو')
                                                        ->body("ناردرا بۆ {$count} بەکارهێنەر")
                                                        ->success()
                                                        ->send();
                                                }),
                                        ])
                                            ->columnSpanFull()
                                            ->alignment('center'),
                                    ]),
                            ]),

                        Forms\Components\Tabs\Tab::make('بۆ بابەت')
                            ->icon('heroicon-o-tag')
                            ->schema([
                                Forms\Components\Section::make()
                                    ->schema([
                                        Forms\Components\TextInput::make('topic_name')
                                            ->label('ناوی بابەت')
                                            ->placeholder('نموونە: announcements')
                                            ->columnSpanFull(),

                                        Forms\Components\TextInput::make('topic_title')
                                            ->label('ناونیشان')
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('topic_body')
                                            ->label('پەیام')
                                            ->rows(4)
                                            ->columnSpanFull(),

                                        Forms\Components\Textarea::make('topic_data')
                                            ->label('زانیاری زیاتر (JSON)')
                                            ->columnSpanFull()
                                            ->helperText('بۆچوون: ناتێبەی'),

                                        Forms\Components\Actions::make([
                                            Forms\Components\Actions\Action::make('sendTopic')
                                                ->label('ناردن')
                                                ->icon('heroicon-o-paper-airplane')
                                                ->color('success')
                                                ->action(function (): void {
                                                    $data = $this->form->getState();

                                                    if (empty($data['topic_name'])) {
                                                        Notification::make()
                                                            ->title('ناوی بابەت پێویست دەکەت')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    if (empty($data['topic_title']) || empty($data['topic_body'])) {
                                                        Notification::make()
                                                            ->title('ناونیشان و پەیام پێویست دەکەن')
                                                            ->danger()
                                                            ->send();
                                                        return;
                                                    }

                                                    $customData = [];
                                                    if (!empty($data['topic_data'])) {
                                                        try {
                                                            $customData = json_decode($data['topic_data'], true) ?? [];
                                                        } catch (\Exception $e) {
                                                            Notification::make()
                                                                ->title('فۆرمایتی JSON غەلەیە')
                                                                ->danger()
                                                                ->send();
                                                            return;
                                                        }
                                                    }

                                                    // Send to topic via Firebase directly
                                                    $firebase = app(\App\Services\FirebaseNotificationService::class);
                                                    $success = $firebase->sendToTopic(
                                                        $data['topic_name'],
                                                        $data['topic_title'],
                                                        $data['topic_body'],
                                                        $customData
                                                    );

                                                    // Also save to DB for all users with notifications enabled
                                                    $users = User::where('notifications_enabled', true)->get();
                                                    foreach ($users as $user) {
                                                        $user->notify(new AdminMessage(
                                                            $data['topic_title'],
                                                            $data['topic_body'],
                                                            $customData
                                                        ));
                                                    }

                                                    if ($success) {
                                                        Notification::make()
                                                            ->title('نۆتیفیکەیشن بۆ بابەت نێردرا')
                                                            ->success()
                                                            ->send();
                                                    } else {
                                                        Notification::make()
                                                            ->title('هەڵەیەک ڕوویدا')
                                                            ->danger()
                                                            ->send();
                                                    }

                                                }),
                                        ])
                                            ->columnSpanFull()
                                            ->alignment('center'),
                                    ]),
                            ]),
                    ])
                    ->columnSpanFull(),
            ]);
    }
}
