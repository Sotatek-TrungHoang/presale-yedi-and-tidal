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
            $table->after('invoice_contact_telephone', function (Blueprint $table) {
                $table->mediumText('applicant_contract')->nullable();
                $table->mediumText('advertiser_contract')->nullable();
            });
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->dropColumn('applicant_contract');
            $table->dropColumn('advertiser_contract');
        });
    }
};
