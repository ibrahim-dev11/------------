<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EventResource\Pages;
use App\Models\Event;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class EventResource extends Resource
{
    protected static ?string $model = Event::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar';
    protected static ?string $navigationGroup = 'ناوەڕۆک';
    protected static ?string $navigationLabel = 'ڕووداوەکان';
    protected static ?string $modelLabel = 'ڕووداو';
    protected static ?string $pluralModelLabel = 'ڕووداوەکان';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('ناونیشان')
                    ->required()
                    ->maxLength(255)
                    ->columnSpanFull(),
                Forms\Components\FileUpload::make('image')
                    ->label('وێنە')
                    ->image()
                    ->directory('events')
                    ->columnSpanFull(),
                Forms\Components\Textarea::make('description')
                    ->label('وردەکاری')
                    ->required()
                    ->rows(4)
                    ->columnSpanFull(),
                Forms\Components\DateTimePicker::make('start_date')
                    ->label('کاتی دەستپێکردن')
                    ->required(),
                Forms\Components\DateTimePicker::make('end_date')
                    ->label('کاتی کۆتایهاتن'),
                Forms\Components\TextInput::make('location')
                    ->label('شوێن')
                    ->maxLength(255),
                Forms\Components\TextInput::make('organizer')
                    ->label('ڕێکخەر')
                    ->maxLength(255),
                Forms\Components\Toggle::make('is_active')
                    ->label('چالاکە')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('وێنە'),
                Tables\Columns\TextColumn::make('title')
                    ->label('ناونیشان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('start_date')
                    ->label('دەستپێک')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('چالاکە')
                    ->boolean(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListEvents::route('/'),
            'create' => Pages\CreateEvent::route('/create'),
            'edit' => Pages\EditEvent::route('/{record}/edit'),
        ];
    }
}
