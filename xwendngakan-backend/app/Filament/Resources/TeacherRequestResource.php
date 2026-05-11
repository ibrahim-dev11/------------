<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeacherRequestResource\Pages;
use App\Filament\Resources\TeacherRequestResource\RelationManagers;
use App\Models\TeacherRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TeacherRequestResource extends Resource
{
    protected static ?string $model = TeacherRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';
    protected static ?string $navigationGroup = 'خزمەتگوزاری';
    protected static ?string $modelLabel = 'داواکاری مامۆستا';
    protected static ?string $pluralModelLabel = 'داواکارییەکانی مامۆستا';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')->label('ناو')->required(),
                Forms\Components\TextInput::make('phone')->label('مۆبایل')->required(),
                Forms\Components\Textarea::make('message')->label('پێغام')->nullable(),
                Forms\Components\Select::make('status')
                    ->label('دۆخ')
                    ->options([
                        'pending' => 'بریتیگ',
                        'approved' => 'پەسەندکراو',
                        'rejected' => 'ڕەتکراو',
                    ])
                    ->default('pending')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('ناو')->searchable(),
                Tables\Columns\TextColumn::make('phone')->label('مۆبایل')->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('دۆخ')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'بریتیگ',
                        'approved' => 'پەسەندکراو',
                        'rejected' => 'ڕەتکراو',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')->label('بەروار')->dateTime()->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('دەستکاری'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()->label('سڕینەوە'),
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
            'index' => Pages\ListTeacherRequests::route('/'),
            'create' => Pages\CreateTeacherRequest::route('/create'),
            'edit' => Pages\EditTeacherRequest::route('/{record}/edit'),
        ];
    }
}
