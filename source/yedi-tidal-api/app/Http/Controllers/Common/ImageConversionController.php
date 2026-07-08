<?php

namespace App\Http\Controllers\Common;

use App\Http\Controllers\Controller;
use App\Models\ImageConversion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageConversionController extends Controller
{
    public function serve(Request $request, ImageConversion $imageConversion)
    {
        if (! $request->hasValidSignature()) {
            abort(401);
        }

        return Storage::disk($imageConversion->disk)->response($imageConversion->path, $imageConversion->file_name);
    }
}
