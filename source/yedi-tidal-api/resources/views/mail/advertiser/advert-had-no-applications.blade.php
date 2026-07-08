<x-mail::message>

# Hello {{$user->first_name}}!

The application period of your advert '{{$advert->title}}' has ended without any applications.

Regards,\
{{ config("app.name") }}

</x-mail::message>