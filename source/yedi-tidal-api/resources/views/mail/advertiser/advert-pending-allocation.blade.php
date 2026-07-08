<x-mail::message>

# Hello {{$user->first_name}}!

The application period for your advert '{{$advert->title}}' has ended.

Regards,\
{{ config("app.name") }}

</x-mail::message>