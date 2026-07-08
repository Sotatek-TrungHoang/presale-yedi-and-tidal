<?php

namespace App\Handlers\Uploads;

use App\Exceptions\Uploads\UploadException;
use App\Jobs\CreateImageConversionsJob;
use App\Models\Upload;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class UploadFileHandler
{
    public function handle(UploadedFile $file): Upload
    {

        $id = Str::orderedUuid();
        $disk = config('filesystems.default');

        $originalFileName = $file->getClientOriginalName();
        $name = Str::of(File::name($originalFileName))->replace(' ', '_')->lower()->snake()->toString();

        $mime = $file->getMimeType();
        $fileSize = $file->getSize();
        $extension = $file->guessExtension() ?? $file->getExtension();

        $outputDir = "uploads/documents/$id";
        $outputFilename = "$name.$extension";
        $outputFilePath = sprintf('%s%s%s', $outputDir, DIRECTORY_SEPARATOR, $outputFilename);

        $res = Storage::disk($disk)->putFileAs($outputDir, $file, $outputFilename);
        if ($res === false) {
            try {
                Storage::disk($disk)->deleteDirectory($outputDir);
            } catch (\Throwable $th) {
                // let it fail
                report($th);
            }
            throw new UploadException('Failed to upload document');
        }

        try {
            DB::beginTransaction();
            $upload = new Upload;
            $upload->fill([
                'id' => $id,
                'disk' => $disk,
                'file_path' => $outputFilePath,
                'file_name' => $outputFilename,
                'mime_type' => $mime,
                'extension' => $extension,
                'size' => $fileSize,
            ]);
            $upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            Storage::disk($disk)->delete($outputFilePath);
            throw $th;
        }

        if (Str::startsWith($mime, 'image')) {
            CreateImageConversionsJob::dispatch($upload);
        }

        return $upload->fresh();
    }
}
