<?php

use App\Models\Applicant;
use App\Models\Declaration;
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
        Schema::create('declaration_agreements', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Declaration::class)->constrained()->cascadeOnDelete();
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
        Schema::dropIfExists('declaration_agreements');
    }
};
