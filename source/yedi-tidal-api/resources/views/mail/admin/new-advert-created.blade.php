<x-mail::message>

# Hello {{$user->first_name}}!

A new job has been created and is pending your approval.

Please see details below:

<x-mail::panel>
<dl>

<dt>Advertiser</dt>
<dd><a href="{{ $advertiser_url }}">{{$advert->advertiser->name}}</a></dd>

<dt>Title</dt>
<dd>{{ $advert->title }}</dd>

<dt>Type</dt>
<dd>{{ $advert->type->getLabel() }}</dd>

<dt>Description</dt>
<dd>{{ $advert->description }}</dd>

<dt>Starts At</dt>
<dd>{{ $advert->starts_at->format("d/m/Y") }}</dd>

<dt>Ends At</dt>
<dd>{{ $advert->ends_at->format("d/m/Y") }}</dd>

<dt>Shift Times</dt>
<dd>{{ $advert->shift_start_time }} - {{ $advert->shift_end_time }}</dd>

@if ($advert->type === \App\Enums\AdvertType::DayToDay)
<dt>Day to Day Application Time (minutes)</dt>
<dd>{{ $advert->day_to_day_active_minutes }}</dd>
@endif

@if ($advert->type === \App\Enums\AdvertType::LongTerm)
<dt>Apply By</dt>
<dd>{{ $advert->apply_by->format("d/m/Y, H:i") }}</dd>
@endif

</dl>
</x-mail::panel>

<x-mail::button :url="$url">
Click here to review the job
</x-mail::button>

Regards,\
{{ config("app.name") }}

</x-mail::message>