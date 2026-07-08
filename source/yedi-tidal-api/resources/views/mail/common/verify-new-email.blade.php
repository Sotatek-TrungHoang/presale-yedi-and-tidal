<x-mail::message>

# Hello {{$user->first_name}}!

We received a request to change the email address associated with your account. Please use the following code to verify your new email address:

**{{ $code }}**

If you did not request this change, please ignore this email.

Regards,\
{{ config("app.name") }}

</x-mail::message>