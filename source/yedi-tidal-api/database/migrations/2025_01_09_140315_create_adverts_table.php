<?php

use App\Models\Advertiser;
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
        Schema::create('adverts', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Advertiser::class)->constrained()->cascadeOnDelete();
            $table->string('type')->index();
            $table->string('status')->index();
            $table->string('title');
            $table->text('description');
            $table->dateTime('starts_at');
            $table->dateTime('ends_at');
            $table->string('shift_start_time');
            $table->string('shift_end_time');
            $table->dateTime('apply_by');
            $table->json('advertiser_pay_rate');
            $table->string('advertiser_pay_rate_type');
            $table->float('applicant_charge_percentage');
            $table->float('advertiser_charge_percentage');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('adverts');
    }
};
