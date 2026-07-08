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
        Schema::table('applicants', function (Blueprint $table) {
            $table->dateTime('sign_up_completed_at')->nullable();
        });
        Schema::table('advertisers', function (Blueprint $table) {
            $table->dateTime('sign_up_completed_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('advertisers', function (Blueprint $table) {
            $table->dropColumn('sign_up_completed_at');
        });
        Schema::table('applicants', function (Blueprint $table) {
            $table->dropColumn('sign_up_completed_at');
        });
    }
};
