<?php

use App\Models\Applicant;
use App\Models\Upload;
use App\Models\VideoVerification;
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
        Schema::create('video_verifications', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Applicant::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Upload::class)->nullable()->constrained()->cascadeOnDelete();
            $table->string('code');
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::table('applicants', function (Blueprint $table) {
            $table->foreignIdFor(VideoVerification::class, 'video_verification_id')->nullable()->after('evidence_of_id_id')->constrained()->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('applicants', function (Blueprint $table) {
            $table->dropForeign(['video_verification_id']);
            $table->dropColumn('video_verification_id');
        });
        Schema::dropIfExists('video_verifications');
    }
};
