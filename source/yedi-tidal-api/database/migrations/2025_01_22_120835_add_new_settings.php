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
        Schema::table('settings', function (Blueprint $table) {

            $table->after('require_teacher_number', function (Blueprint $table) {
                $table->float('default_applicant_charge_percentage')->default(10);
                $table->float('default_advertiser_charge_percentage')->default(10);
            });

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->dropColumn('default_applicant_charge_percentage');
            $table->dropColumn('default_advertiser_charge_percentage');
        });
    }
};
