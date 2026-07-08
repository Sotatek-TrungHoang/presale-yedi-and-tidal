<?php

use App\Enums\ProfileStatus;
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
            $table->string('profile_status')->default(ProfileStatus::Pending->value)->after('compliance_status')->index();
        });
        Schema::table('advertisers', function (Blueprint $table) {
            $table->string('profile_status')->default(ProfileStatus::Pending->value)->after('compliance_status')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('applicants', function (Blueprint $table) {
            $table->dropColumn('profile_status');
        });
        Schema::table('advertisers', function (Blueprint $table) {
            $table->dropColumn('profile_status');
        });
    }
};
