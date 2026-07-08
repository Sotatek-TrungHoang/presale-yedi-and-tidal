<x-mail::message>

# Hello {{$user->first_name}}!

A new reference has been provided for {{$reference->applicant->user->name}} by {{$reference->referee_name}} ({{$reference->email}}).

<x-mail::button :url="$url">
Click here to review the reference
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>