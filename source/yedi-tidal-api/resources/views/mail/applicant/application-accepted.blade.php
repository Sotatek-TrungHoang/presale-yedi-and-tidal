<x-mail::message>

# Hello {{$user->first_name}}!

Your application for '{{$application->advert->title}}' has been accepted

Regards,\
{{ config("app.name") }}

</x-mail::message>