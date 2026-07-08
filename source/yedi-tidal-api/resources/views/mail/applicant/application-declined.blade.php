<x-mail::message>

# Hello {{$user->first_name}}!

Your application for '{{$application->advert->title}}' has been declined

Regards,\
{{ config("app.name") }}

</x-mail::message>