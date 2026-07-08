<?php

namespace App\Handlers\Uploads;

use App\Http\Integrations\GoogleMaps\GoogleMapsConnector;
use App\Http\Integrations\GoogleMaps\Requests\FindPlaceRequest;
use App\Http\Integrations\GoogleMaps\Requests\GetPlacePhotoRequest;
use App\Models\Upload;
use Illuminate\Support\Facades\Log;

class CreateUploadFromGoogleHandler
{
    public function __construct(
        protected GoogleMapsConnector $googleMapsConnector,
        protected CreateUploadFromDataHandler $createUploadFromDataHandler,
    ) {}

    public function handle(
        string $name,
        string $postcode,
    ): ?Upload {

        $name = strtolower($name);
        $postcode = strtolower($postcode);

        try {
            $placeRequest = new FindPlaceRequest("$name $postcode");
            $response = $this->googleMapsConnector->send($placeRequest);
        } catch (\Throwable $e) {
            return null;
        }

        if ($response->isCached()) {
            Log::channel('google_maps')->info('Google Maps API place request cached', [
                'name' => $name,
                'postcode' => $postcode,
            ]);
        } else {
            Log::channel('google_maps')->info('Google Maps API place request sent', [
                'name' => $name,
                'postcode' => $postcode,
            ]);
        }

        $photoReference = $response->json('candidates.0.photos.0.photo_reference');
        if (! $photoReference) {
            return null;
        }

        Log::channel('google_maps')->info('Google Maps API photo request sent', [
            'name' => $name,
            'postcode' => $postcode,
            'photo_reference' => $photoReference,
        ]);
        try {
            $photoRequest = new GetPlacePhotoRequest($photoReference);
            $photoResponse = $this->googleMapsConnector->send($photoRequest);
        } catch (\Throwable $th) {
            return null;
        }

        $photoData = $photoResponse->body();
        $mimeType = $photoResponse->header('Content-Type');
        $disposition = $photoResponse->header('Content-Disposition');
        preg_match('/filename=".*\.(\w+)"/', $disposition, $matches);
        $extension = $matches[1] ?? 'jpg';

        $upload = $this->createUploadFromDataHandler->handle(
            $photoData,
            "$name $postcode.$extension",
            $mimeType,
            $extension,
        );

        return $upload;
    }
}
