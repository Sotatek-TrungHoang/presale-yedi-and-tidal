<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ ucwords($reference->applicant->user->name) }} Reference</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sora:wght@100..800&display=swap');
    </style>
    {{-- @vite(['resources/css/app.css', 'resources/js/app.js']) --}}
    <style>
        {!! Vite::content('resources/css/app.css') !!}
    </style>
    <style>
        html {
            -webkit-print-color-adjust: exact;
            height: 100%;
            margin: 0px;
        }

        @page {
            margin: 32px 32px 32px 32px;
            position: relative;
        }

        .page-break {
            page-break-before: always;
        }

        .page-break-inside {
            page-break-inside: avoid !important;
        }

        dt {
            font-weight: 600;
            margin-bottom: 0.15rem;
        }

        dd {
            margin-bottom: 1rem;
        }
    </style>
</head>

<body class="text-sm leading-snug font-sora">

    @component('pdfs.components.header')
    @endcomponent


    <h1 class="mb-4 text-2xl font-semibold uppercase">{{ ucwords($reference->applicant->user->name) }} Reference</h1>

    <dl>
        <dt>Candidate Name</dt>
        <dd>{{ $reference->name }}</dd>

        <dt>Job Title</dt>
        <dd>{{ $reference->job_title }}</dd>

        <dt>Employment Start Date</dt>
        <dd>{{ $reference->employment_start_date->format('d/m/Y') }}</dd>

        <dt>Employment End Date</dt>
        <dd>{{ $reference->employment_end_date->format('d/m/Y') }}</dd>

        <dt>Place of Employment</dt>
        <dd>{{ $reference->advertiser_name }}</dd>

        <dt>Referee Name</dt>
        <dd>{{ $reference->referee_name }}</dd>

        <dt>Referee Job Title</dt>
        <dd>{{ $reference->referee_job_title }}</dd>

        <dt>Relationship to Applicant</dt>
        <dd>{{ $reference->relationship_to_applicant }}</dd>

        <dt>How long have you known the candidate</dt>
        <dd>{{ $reference->how_long_has_known_applicant }}</dd>

        <dt>Comments about the candidate</dt>
        <dd>{{ $reference->comments }}</dd>

        @if (config('app.configuration') === 'yedi')
            <dt>Curriculum Knowledge</dt>
            <dd>{{ $reference->curriculum_knowledge?->getLabel() }}</dd>

            <dt>Ability to Support Groups</dt>
            <dd>{{ $reference->ability_to_support_groups?->getLabel() }}</dd>

            <dt>Ability to Support on 1:1 Basis</dt>
            <dd>{{ $reference->ability_to_support_on_1_1_basis?->getLabel() }}</dd>

            <dt>Relationships with Colleagues</dt>
            <dd>{{ $reference->relationships_with_colleagues?->getLabel() }}</dd>

            <dt>Rapport with Students</dt>
            <dd>{{ $reference->rapport_with_students?->getLabel() }}</dd>

            <dt>Pupil Management</dt>
            <dd>{{ $reference->pupil_management?->getLabel() }}</dd>

            <dt>Communication and Attitude</dt>
            <dd>{{ $reference->communication_and_attitude?->getLabel() }}</dd>

            <dt>Reliability and Punctuality</dt>
            <dd>{{ $reference->reliability_and_punctuality?->getLabel() }}</dd>

            <dt>Please add any additional comments on their ability and suitability in a support role; e.g. rapport with students, behaviour management, any SEN experience</dt>
            <dd>{{ $reference->additional_comments }}</dd>
        @endif

        <dt>Do you know of any disciplinary procedures against this candidate or safeguarding concerns?</dt>
        <dd>{{ $reference->any_disciplinary_procedures ? 'Yes' : 'No' }}</dd>

        <dt>Was this candidate dismissed?</dt>
        <dd>{{ $reference->was_dismissed ? 'Yes' : 'No' }}</dd>

        <dt>Would you reemploy this person?</dt>
        <dd>{{ $reference->would_reemploy ? 'Yes' : 'No' }}</dd>

        @if (!$reference->would_reemploy)
            <dt>If no why?</dt>
            <dd>{{ $reference->would_reemploy_reason }}</dd>
        @endif

        <dt>Do you know of any reasons why the candidate is not suitable to work with children under the age of 18?</dt>
        <dd>{{ $reference->not_suitable_to_work_with_under_18s ? 'Yes' : 'No' }}</dd>

        <dt>May we share this reference with potential new employers?</dt>
        <dd>{{ $reference->may_share_with_new_employers ? 'Yes' : 'No' }}</dd>

        <dt>Signature Name</dt>
        <dd>{{ $reference->signature_name }}</dd>

        <dt>Signature Date</dt>
        <dd>{{ $reference->signature_date->format('d/m/Y') }}</dd>

        <dt>Signature</dt>
        <dd><img class="h-auto max-w-full" src="{{ $reference->signature }}" alt=""></dd>
    </dl>

</body>

</html>
