<?php

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
        Schema::create('right_to_work_declarations', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Applicant::class)->constrained()->cascadeOnDelete();
            $table->boolean('right_to_work_uk');
            $table->boolean('require_visa_to_work_uk');
            $table->boolean('lived_or_worked_outside_uk_6_months');
            $table->boolean('has_criminal_convictions_or_prosecutions_pending');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('right_to_work_declarations');
    }
};
