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
        Schema::table('adverts', function (Blueprint $table) {
            $table->after('advertiser_charge_percentage', function (Blueprint $table) {
                $table->string('contact_name')->nullable();
                $table->string('contact_position')->nullable();
                $table->string('contact_email')->nullable();
                $table->string('contact_telephone')->nullable();
            });
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('adverts', function (Blueprint $table) {
            $table->dropColumn('contact_name');
            $table->dropColumn('contact_position');
            $table->dropColumn('contact_email');
            $table->dropColumn('contact_telephone');
        });
    }
};
