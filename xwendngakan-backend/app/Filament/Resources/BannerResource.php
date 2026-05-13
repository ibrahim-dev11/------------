<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BannerResource\Pages;
use App\Models\Banner;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;

    protected static ?string $navigationIcon = 'heroicon-o-photo';
    protected static ?string $navigationGroup = 'ناوەڕۆک';
    protected static ?string $navigationLabel = 'بانەرەکان';
    protected static ?string $modelLabel = 'بانەر';
    protected static ?string $pluralModelLabel = 'بانەرەکان';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('زانیاری بانەر')
                ->schema([
                    Forms\Components\TextInput::make('title')
                        ->label('ناونیشان')
                        ->required()
                        ->maxLength(120)
                        ->columnSpanFull(),

                    Forms\Components\TextInput::make('subtitle')
                        ->label('ناونیشانی بچووک')
                        ->maxLength(200)
                        ->columnSpanFull(),

                    Forms\Components\TextInput::make('tag')
                        ->label('تاگ')
                        ->maxLength(40),
                ])->columns(1),

            Forms\Components\Section::make('وێنە و ڕەنگ')
                ->schema([
                    Forms\Components\FileUpload::make('image')
                        ->label('وێنەی بانەر')
                        ->image()
                        ->directory('banners')
                        ->imageResizeMode('cover')
                        ->imageCropAspectRatio('3:1')
                        ->helperText('ئەگەر وێنەیەک دانرا، ئەوا بەجێی گرادیان نیشان دەدرێت')
                        ->columnSpanFull(),

                    Forms\Components\ColorPicker::make('color_start')
                        ->label('ڕەنگی سەرەتا')
                        ->default('#C49A3C'),

                    Forms\Components\ColorPicker::make('color_end')
                        ->label('ڕەنگی کۆتا')
                        ->default('#E0B856'),
                ])->columns(2),

            Forms\Components\Section::make('ڕێکخستن')
                ->schema([
                    Forms\Components\TextInput::make('sort_order')
                        ->label('ڕیزبەندی')
                        ->numeric()
                        ->default(0)
                        ->helperText('ژمارەی کەمتر پێشتر نیشان دەدرێت'),

                    Forms\Components\Toggle::make('is_active')
                        ->label('چالاکە')
                        ->default(true),
                ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image_url')
                    ->label('وێنە')
                    ->width(80)
                    ->height(40)
                    ->defaultImageUrl(fn($record) => null),

                Tables\Columns\TextColumn::make('title')
                    ->label('ناونیشان')
                    ->searchable()
                    ->limit(40),

                Tables\Columns\TextColumn::make('tag')
                    ->label('تاگ')
                    ->badge(),

                Tables\Columns\ColorColumn::make('color_start')
                    ->label('ڕەنگ'),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('ڕیز')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('چالاک')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('بەروار')
                    ->dateTime('d/m/Y')
                    ->sortable(),
            ])
            ->defaultSort('sort_order')
            ->reorderable('sort_order')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')->label('چالاک'),
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('دەستکاری'),
                Tables\Actions\DeleteAction::make()->label('سڕینەوە'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()->label('سڕینەوەی هەڵبژێردراوەکان'),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBanners::route('/'),
            'create' => Pages\CreateBanner::route('/create'),
            'edit'   => Pages\EditBanner::route('/{record}/edit'),
        ];
    }
}
