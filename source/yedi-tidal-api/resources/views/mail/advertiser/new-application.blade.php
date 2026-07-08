<x-mail::message>

# Hello {{$user->first_name}}!

{{$application->applicant->user->name}} has applied for your advert '{{$application->advert->title}}'.

Regards,\
{{ config("app.name") }}

</x-mail::message>