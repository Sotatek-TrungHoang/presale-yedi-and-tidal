<?php

use App\Models\Address;
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
        Schema::create('applicants', function (Blueprint $table) {
            $table->id();
            $table->string('compliance_status')->index();
            $table->string('qualification')->nullable();
            $table->string('teacher_number')->nullable();
            $table->foreignIdFor(Address::class)->nullable()->constrained()->nullOnDelete();
            $table->foreignIdFor(Upload::class, 'photograph_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignIdFor(Upload::class, 'evidence_of_id_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('applicants');
    }
};
