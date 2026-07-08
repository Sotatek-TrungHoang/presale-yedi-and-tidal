<?php

use App\Models\Advert;
use App\Models\Applicant;
use App\Models\Upload;
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
        Schema::create('payslips', function (Blueprint $table) {
            $table->id();
            $table->string('payslip_number');
            $table->string('title');
            $table->foreignIdFor(Advert::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Applicant::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Upload::class)->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payslips');
    }
};
