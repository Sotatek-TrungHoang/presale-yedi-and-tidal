<?php

namespace App\Filament\Resources\DeclarationResource\Pages;

use App\Filament\Resources\DeclarationResource;
use App\Models\Declaration;
use App\Models\Upload;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\DB;

class CreateDeclaration extends CreateRecord
{
    protected static string $resource = DeclarationResource::class;

    protected function handleRecordCreation(array $data): Declaration
    {

        try {

            DB::beginTransaction();
            $declaration = Declaration::create([
                'title' => $data['title'],
                'description' => $data['description'],
                'time_to_complete' => $data['time_to_complete'],
                'required' => $data['required'],
            ]);

            $upload = Upload::query()->find($data['upload_id']);

            $upload->owner()->associate($declaration)->save();
            $declaration->upload()->associate($upload)->save();

            // dd($data['upload_id'], $upload, $declaration);
            DB::commit();

            return $declaration;
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

    }
}
