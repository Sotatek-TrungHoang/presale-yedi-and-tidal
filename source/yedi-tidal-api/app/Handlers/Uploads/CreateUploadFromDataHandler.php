<?php

namespace App\Handlers\Uploads;

use App\Exceptions\Uploads\UploadException;
use App\Jobs\CreateImageConversionsJob;
use App\Models\Upload;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CreateUploadFromDataHandler
{
    public function handlePdf(
        string $data,
        string $originalFileName
    ): Upload {
        return $this->handle(
            $data,
            $originalFileName,
            'application/pdf',
            'pdf'
        );
    }

    public function handle(
        string $data,
        string $originalFileName,
        string $mime,
        string $extension,
    ): Upload {

        $id = Str::orderedUuid();
        $disk = config('filesystems.default');

        $name = Str::of(File::name($originalFileName))->replace(' ', '_')->lower()->snake()->toString();

        $fileSize = $this->getfileSize($data);
        $outputDir = "uploads/documents/$id";
        $outputFilename = "$name.$extension";
        $outputFilePath = sprintf('%s%s%s', $outputDir, DIRECTORY_SEPARATOR, $outputFilename);

        $res = Storage::disk($disk)->put($outputFilePath, $data);
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

    private function getFileSize(string &$data)
    {
        if (function_exists('mb_strlen')) {
            return mb_strlen($data, '8bit');
        }

        return strlen($data);
    }
}
