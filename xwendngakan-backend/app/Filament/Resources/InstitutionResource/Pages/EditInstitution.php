<?php

namespace App\Filament\Resources\InstitutionResource\Pages;

use App\Filament\Resources\InstitutionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditInstitution extends EditRecord
{
    protected static string $resource = InstitutionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Hydrate colleges_data repeater from JSON
        if (!empty($data['colleges'])) {
            $decoded = json_decode($data['colleges'], true);
            if (is_array($decoded)) {
                $data['colleges_data'] = $decoded;
            }
        }

        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Serialize colleges repeater data to JSON
        if (isset($data['colleges_data'])) {
            $data['colleges'] = json_encode(array_values($data['colleges_data']), JSON_UNESCAPED_UNICODE);
            unset($data['colleges_data']);
        }

        return $data;
    }
}
