<?php

namespace App\Filament\Resources;

use App\Filament\Resources\InstitutionTypeResource\Pages;
use App\Models\InstitutionType;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class InstitutionTypeResource extends Resource
{
    protected static ?string $model = InstitutionType::class;

    protected static ?string $navigationIcon = 'heroicon-o-squares-plus';

    protected static ?string $navigationLabel = 'جۆرەکانی دامەزراوە';

    protected static ?string $modelLabel = 'جۆر';

    protected static ?string $pluralModelLabel = 'جۆرەکانی دامەزراوە';

    protected static ?string $navigationGroup = 'هەموو بابەتەکان';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('کوردی')
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('name_en')
                    ->label('ئینگلیزی')
                    ->maxLength(255),

                Forms\Components\TextInput::make('name_ar')
                    ->label('عەرەبی')
                    ->maxLength(255),

                Forms\Components\Toggle::make('has_colleges')
                    ->label('کۆلێژ هەیە؟ (زانکۆ)')
                    ->helperText('ئەگەر چالاک بێت، فیلدی ناوی کۆلێژەکان نیشان دەدرێت')
                    ->default(false),

                Forms\Components\Toggle::make('has_departments')
                    ->label('بەش هەیە؟ (پەیمانگا / زانکۆ)')
                    ->helperText('ئەگەر چالاک بێت، فیلدی ناوی بەشەکان نیشان دەدرێت')
                    ->default(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('ناو')
                    ->searchable(),

                Tables\Columns\TextColumn::make('icon')
                    ->label('ئایکۆن')
                    ->badge(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([])
            ->defaultSort('sort_order')
            ->reorderable('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInstitutionTypes::route('/'),
            'create' => Pages\CreateInstitutionType::route('/create'),
            'edit' => Pages\EditInstitutionType::route('/{record}/edit'),
        ];
    }
}
