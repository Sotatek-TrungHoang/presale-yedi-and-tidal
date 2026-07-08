<x-mail::message>

# Hello {{$user->first_name}}!

A new {{___("advertiser")}} has completed their registration and is pending approval.

Please see details below:

<x-mail::panel>
<dl>

<dt>Name</dt>
<dd>{{ $advertiser->user->name }}</dd>

<dt>Date of Birth</dt>
<dd>{{ $advertiser->user->date_of_birth?->format("d/m/Y") }}</dd>

<dt>Telephone</dt>
<dd>{{ $advertiser->user->telephone }}</dd>

<dt>Email</dt>
<dd>{{ $advertiser->user->email }}</dd>

<dt>{{ucwords(___("advertiser"))}} Name</dt>
<dd>{{ $advertiser->name }}</dd>

<dt>{{ucwords(___("advertiser"))}} Email</dt>
<dd>{{ $advertiser->email }}</dd>

<dt>{{ucwords(___("advertiser"))}} Telephone</dt>
<dd>{{ $advertiser->telephone }}</dd>

<dt>{{ucwords(___("advertiser"))}} Address</dt>
<dd>{{ $advertiser->address->formatted }}</dd>

</dl>
</x-mail::panel>

<x-mail::button :url="$url">
Click here to review the {{___("advertiser")}}
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>