<?php

namespace App\Handlers\Advertisers\Documents;

use App\DTOs\Documents\DocumentData;
use App\Models\Document;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class CreateDocumentHandler
{
    public function handle(DocumentData $data, Model $owner)
    {
        try {
            DB::beginTransaction();

            $document = new Document;
            $document->title = $data->title;
            $document->upload()->associate($data->upload);
            $document->owner()->associate($owner);
            $document->save();

            $data->upload->owner()->associate($document);
            $data->upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $document;
    }
}
