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
        Schema::table('applications', function (Blueprint $table) {
            $table->tinyInteger('rating', false, unsigned: true)->nullable()->after('actioned_at');
        });

        Schema::table('applicants', function (Blueprint $table) {
            $table->decimal('rating')->nullable()->after('profile_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('applications', function (Blueprint $table) {
            $table->dropColumn('rating');
        });

        Schema::table('applicants', function (Blueprint $table) {
            $table->dropColumn('rating');
        });
    }
};
