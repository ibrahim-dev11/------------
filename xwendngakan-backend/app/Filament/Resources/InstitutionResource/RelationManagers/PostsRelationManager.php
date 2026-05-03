<?php

namespace App\Filament\Resources\InstitutionResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PostsRelationManager extends RelationManager
{
    protected static string $relationship = 'posts';

    protected static ?string $title = 'پۆستەکان';
    protected static ?string $modelLabel = 'پۆست';
    protected static ?string $pluralModelLabel = 'پۆستەکان';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('ناونیشان')
                    ->required()
                    ->maxLength(255)
                    ->columnSpanFull(),
                Forms\Components\RichEditor::make('content')
                    ->label('ناوەڕۆک')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\FileUpload::make('image')
                    ->label('وێنە')
                    ->image()
                    ->directory('posts')
                    ->columnSpanFull(),
                Forms\Components\Toggle::make('approved')
                    ->label('پەسەندکراو')
                    ->default(true),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('title')
            ->columns([
                Tables\Columns\ImageColumn::make('image')->label('وێنە'),
                Tables\Columns\TextColumn::make('title')->label('ناونیشان')->searchable(),
                Tables\Columns\IconColumn::make('approved')->label('پەسەند')->boolean(),
                Tables\Columns\TextColumn::make('created_at')->label('بەروار')->dateTime(),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('پۆستی نوێ'),
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('دەستکاری'),
                Tables\Actions\DeleteAction::make()->label('سڕینەوە'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
