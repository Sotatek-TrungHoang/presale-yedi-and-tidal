<?php

namespace App\Jobs;

use App\Enums\ImageConversionType;
use App\Models\Upload;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Spatie\Image\Image as SpatieImage;

class CreateImageConversionsJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        protected Upload $upload,
    ) {
        $this->onQueue('conversions');
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {

        if (! Str::startsWith($this->upload->mime_type, 'image')) {
            return;
        }

        // Generate a temporary file path
        $originalTempPathRelative = sprintf('%s.%s', Str::orderedUuid()->toString(), $this->upload->extension);
        $originalTempPathAbsolute = Storage::disk('tmp')->path($originalTempPathRelative);

        Storage::disk('tmp')->put($originalTempPathRelative, Storage::disk($this->upload->disk)->read($this->upload->file_path));

        // Do the cropping and save to the temp file path
        $originalSpatieImage = SpatieImage::load($originalTempPathAbsolute);
        $originalSpatieSize = $originalSpatieImage->getSize();
        $originalSpatieWidth = $originalSpatieSize->width;
        $originalSpatieHeight = $originalSpatieSize->height;

        if (! $originalSpatieHeight || ! $originalSpatieWidth) {
            return;
        }

        $this->upload->update([
            'image_width' => $originalSpatieWidth,
            'image_height' => $originalSpatieHeight,
        ]);

        foreach (ImageConversionType::cases() as $conversionType) {

            try {
                $conversionOptions = $conversionType->getOptions($originalSpatieWidth, $originalSpatieHeight);
                if (! $conversionOptions) {
                    continue;
                }

                $extension = 'webp';

                // Generate a temporary file path
                $conversionTempPathRelative = sprintf('%s.%s', Str::orderedUuid()->toString(), $extension);
                $conversionTempPathAbsolute = Storage::disk('tmp')->path($conversionTempPathRelative);

                // Do the cropping and save to the temp file path
                $convertedImage = SpatieImage::load($originalTempPathAbsolute)
                    ->fit($conversionOptions->fit, $conversionOptions->width, $conversionOptions->height)
                    ->optimize()
                    ->save($conversionTempPathAbsolute);

                // Get attributes of the image
                $fileSize = Storage::disk('tmp')->size($conversionTempPathRelative);
                $convertedSize = $convertedImage->getSize();
                $width = $convertedSize->width;
                $height = $convertedSize->height;

                // Build the new file name
                $name = sprintf('%s_%s', File::name($this->upload->file_name), Str::slug($conversionType->value));
                $fileName = "$name.$extension";

                // Calculate the output directory based on the parent image
                // Add conversion name to file name then append the extension
                $outputDir = Str::of($this->upload->file_path)->explode(DIRECTORY_SEPARATOR)->slice(0, -1)->join(DIRECTORY_SEPARATOR, DIRECTORY_SEPARATOR);
                $outputFilePath = sprintf('%s%s%s', $outputDir, DIRECTORY_SEPARATOR, $fileName);

                // Copy the file from tmp to the proper disk
                Storage::disk($this->upload->disk)->put($outputFilePath, Storage::disk('tmp')->read($conversionTempPathRelative));

                // Delete the temporary file
                Storage::disk('tmp')->delete($conversionTempPathRelative);

                $this->upload->conversions()->updateOrCreate([
                    'conversion_name' => $conversionType->value,
                ], [
                    'path' => $outputFilePath,
                    'disk' => $this->upload->disk,
                    'name' => $name,
                    'file_name' => $fileName,
                    'mime_type' => $this->upload->mime_type,
                    'extension' => $extension,
                    'size' => $fileSize,
                    'width' => $width,
                    'height' => $height,
                ]);
            } catch (\Throwable $th) {
                report($th);
            }
        }
    }
}
