<x-mail::message>

# Hello {{$user->first_name}}!

A new {{___("applicant")}} has completed their registration and is pending approval.

Please see details below:

<x-mail::panel>
<dl>

<dt>Name</dt>
<dd>{{ $applicant->user->name }}</dd>

<dt>Date of Birth</dt>
<dd>{{ $applicant->user->date_of_birth?->format("d/m/Y") }}</dd>

<dt>Telephone</dt>
<dd>{{ $applicant->user->telephone }}</dd>

<dt>Email</dt>
<dd>{{ $applicant->user->email }}</dd>

<dt>Address</dt>
<dd>{{ $applicant->address->formatted }}</dd>

<dt>Qualification</dt>
<dd>{{ $applicant->qualification->label() }}</dd>

</dl>
</x-mail::panel>

<x-mail::button :url="$url">
Click here to review the {{___("applicant")}}
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>