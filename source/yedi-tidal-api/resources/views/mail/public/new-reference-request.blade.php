<x-mail::message>

# Hello,

You are receiving this email because you have been requested to provide a reference for {{$reference->applicant->user->name}}.

<x-mail::button :url="$url">
Please click here to provide the reference
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>