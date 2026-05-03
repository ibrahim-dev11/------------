<?php

namespace App\Filament\Resources;

use App\Filament\Resources\InstitutionRequestResource\Pages;
use App\Models\InstitutionRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class InstitutionRequestResource extends Resource
{
    protected static ?string $model = InstitutionRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';
    protected static ?string $navigationGroup = 'بەڕێوەبردن';
    protected static ?string $modelLabel = 'داواکاری دامەزراوە';
    protected static ?string $pluralModelLabel = 'داواکارییەکانی دامەزراوە';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('ناوی دامەزراوە')
                    ->required(),
                Forms\Components\TextInput::make('phone')
                    ->label('ژمارەی مۆبایل')
                    ->required(),
                Forms\Components\Textarea::make('message')
                    ->label('پەیام')
                    ->nullable(),
                Forms\Components\Select::make('status')
                    ->label('بارودۆخ')
                    ->options([
                        'pending' => 'چاوەڕوان',
                        'approved' => 'پەسەندکراو',
                        'rejected' => 'ڕەتکراوە',
                    ])
                    ->default('pending')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('ناوی دامەزراوە')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('ژمارەی مۆبایل')
                    ->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('بارودۆخ')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'چاوەڕوان',
                        'approved' => 'پەسەندکراو',
                        'rejected' => 'ڕەتکراوە',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('بەروار')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('پەسەندکردن و دروستکردن')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('پەسەندکردنی داواکاری')
                    ->modalDescription('ئایا دڵنیایت لە پەسەندکردنی ئەم داواکارییە؟ بەمەش خوێندنگایەکی نوێ دروست دەبێت.')
                    ->action(function (InstitutionRequest $record) {
                        // Create the Institution
                        $institution = \App\Models\Institution::create([
                            'nku' => $record->name,
                            'phone' => $record->phone,
                            'user_id' => $record->user_id,
                            'approved' => true,
                            'type' => 'school',
                        ]);

                        // Update Request status
                        $record->update(['status' => 'approved']);

                        \Filament\Notifications\Notification::make()
                            ->title('داواکارییەکە پەسەند کرا')
                            ->success()
                            ->send();

                        // Redirect to the newly created institution's edit page
                        return redirect()->to(\App\Filament\Resources\InstitutionResource::getUrl('edit', ['record' => $institution]));
                    })
                    ->visible(fn (InstitutionRequest $record) => $record->status === 'pending'),
                Tables\Actions\EditAction::make()->label('دەستکاری'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInstitutionRequests::route('/'),
            'create' => Pages\CreateInstitutionRequest::route('/create'),
            'edit' => Pages\EditInstitutionRequest::route('/{record}/edit'),
        ];
    }
}
