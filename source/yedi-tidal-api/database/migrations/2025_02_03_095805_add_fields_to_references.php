<?php

use App\Enums\ReferenceStatus;
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
        Schema::table('references', function (Blueprint $table) {
            $table->after('email', function (Blueprint $table) {

                $table->string('status')->default(ReferenceStatus::Created->value);
                $table->uuid('reference_id');

                $table->string('job_title')->nullable();
                $table->date('employment_start_date')->nullable();
                $table->date('employment_end_date')->nullable();
                $table->string('advertiser_name')->nullable();
                $table->string('referee_name')->nullable();
                $table->string('referee_job_title')->nullable();
                $table->string('relationship_to_applicant')->nullable();
                $table->string('how_long_has_known_applicant')->nullable();
                $table->text('comments')->nullable();

                $table->string('curriculum_knowledge')->nullable();
                $table->string('ability_to_support_groups')->nullable();
                $table->string('ability_to_support_on_1_1_basis')->nullable();
                $table->string('relationships_with_colleagues')->nullable();
                $table->string('rapport_with_students')->nullable();
                $table->string('pupil_management')->nullable();
                $table->string('communication_and_attitude')->nullable();
                $table->string('reliability_and_punctuality')->nullable();
                $table->text('additional_comments')->nullable();

                $table->boolean('any_disciplinary_procedures')->nullable();
                $table->boolean('was_dismissed')->nullable();
                $table->boolean('would_reemploy')->nullable();
                $table->string('would_reemploy_reason')->nullable();
                $table->boolean('not_suitable_to_work_with_under_18s')->nullable();
                $table->boolean('may_share_with_new_employers')->nullable();

                $table->string('signature_name')->nullable();
                $table->dateTime('signature_date')->nullable();
                $table->mediumText('signature')->nullable();
            });
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('references', function (Blueprint $table) {

            $table->dropColumn([
                'status',
                'reference_id',
                'job_title',
                'employment_start_date',
                'employment_end_date',
                'advertiser_name',
                'referee_name',
                'referee_job_title',
                'relationship_to_applicant',
                'how_long_has_known_applicant',
                'comments',
                'curriculum_knowledge',
                'ability_to_support_groups',
                'ability_to_support_on_1_1_basis',
                'relationships_with_colleagues',
                'rapport_with_students',
                'pupil_management',
                'communication_and_attitude',
                'reliability_and_punctuality',
                'additional_comments',
                'any_disciplinary_procedures',
                'was_dismissed',
                'would_reemploy',
                'would_reemploy_reason',
                'not_suitable_to_work_with_under_18s',
                'may_share_with_new_employers',
                'signature_name',
                'signature_date',
                'signature',
            ]);
        });
    }
};
