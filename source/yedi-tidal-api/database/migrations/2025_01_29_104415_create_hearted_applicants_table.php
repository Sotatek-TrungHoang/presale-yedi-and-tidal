<?php

use App\Models\Advertiser;
use App\Models\Applicant;
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
        Schema::create('hearted_applicants', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Advertiser::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Applicant::class)->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hearted_applicants');
    }
};
