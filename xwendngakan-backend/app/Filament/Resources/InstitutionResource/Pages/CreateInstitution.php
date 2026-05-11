<?php

namespace App\Filament\Resources\InstitutionResource\Pages;

use App\Filament\Resources\InstitutionResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateInstitution extends CreateRecord
{
    protected static string $resource = InstitutionResource::class;

    protected static bool $canCreateAnother = false;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Serialize colleges repeater data to JSON
        if (isset($data['colleges_data'])) {
            $data['colleges'] = json_encode(array_values($data['colleges_data']), JSON_UNESCAPED_UNICODE);
            unset($data['colleges_data']);
        }

        return $data;
    }
}
