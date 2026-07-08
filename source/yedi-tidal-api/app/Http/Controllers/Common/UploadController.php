<?php

namespace App\Http\Controllers\Common;

use App\Exceptions\Uploads\UploadException;
use App\Handlers\Uploads\CreateUploadFromGoogleHandler;
use App\Handlers\Uploads\UploadFileHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Common\Uploads\UploadFileRequest;
use App\Http\Requests\Common\Uploads\UploadFromGoogleRequest;
use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Upload;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    public function __construct(
        protected UploadFileHandler $uploadFileHandler,
        protected CreateUploadFromGoogleHandler $createUploadFromGoogleHandler,
    ) {}

    public function store(UploadFileRequest $request)
    {

        $file = $request->file('file');

        try {
            $upload = $this->uploadFileHandler->handle($file);
        } catch (UploadException $e) {
            return $this->stdError($e->getMessage());
        }

        return (new UploadResource($upload))->response()->setStatusCode(201);
    }

    public function storeFromGoogle(UploadFromGoogleRequest $request)
    {
        try {
            $upload = $this->createUploadFromGoogleHandler->handle($request->validated('name'), $request->validated('postcode'));
        } catch (UploadException $e) {
            return $this->stdError($e->getMessage());
        }

        if ($upload === null) {
            return $this->stdError('Failed to upload from Google');
        }

        return (new UploadResource($upload))->response()->setStatusCode(201);
    }

    public function serve(Request $request, Upload $upload)
    {
        if (! $request->hasValidSignature()) {
            abort(401);
        }

        return Storage::disk($upload->disk)->response($upload->file_path, $upload->file_name);
    }
}
