<x-mail::message>

# Hello {{$user->first_name}}!

You have a new payslip for job '{{$payslip->advert->title}}'.

<x-mail::button :url="$url">
View Payslip
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>