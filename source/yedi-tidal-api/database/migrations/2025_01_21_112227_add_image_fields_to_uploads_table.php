<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('uploads', function (Blueprint $table) {
            $table->after('size', function (Blueprint $table) {
                $table->unsignedInteger('image_width')->nullable();
                $table->unsignedInteger('image_height')->nullable();
            });
        });

        Schema::create('image_conversions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('upload_id')->references('id')->on('uploads')->cascadeOnDelete();
            $table->string('conversion_name');
            $table->string('disk');
            $table->string('path');
            $table->string('name');
            $table->string('file_name');
            $table->string('mime_type')->nullable();
            $table->string('extension');
            $table->unsignedBigInteger('size');
            $table->unsignedInteger('width');
            $table->unsignedInteger('height');
            $table->timestamps();
            $table->softDeletes();
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

        Schema::dropIfExists('image_conversions');

        Schema::table('uploads', function (Blueprint $table) {
            $table->dropColumn('image_width');
            $table->dropColumn('image_height');
        });
    }
};
