<x-mail::message>

# Hello {{$user->first_name}}!

You have a new invoice for your job '{{$invoice->advert->title}}'.

<x-mail::button :url="$url">
View Invoice
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>