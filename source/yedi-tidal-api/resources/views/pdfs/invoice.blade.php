@php
    $advert = $invoice->advert;
    $advertiser = $advert->advertiser;
    $locale = app()->getLocale();

    $configuration = config('app.configuration');
    $tableBg = $configuration === 'yedi' ? 'bg-yediBg' : 'bg-tidalBg';
    $accent = $configuration === 'yedi' ? 'text-yediAccent' : 'text-tidalAccent';

@endphp
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $invoice->invoice_number }}</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sora:wght@100..800&display=swap');
    </style>
    {{-- @vite(['resources/css/app.css', 'resources/js/app.js']) --}}
    <style>
        {!! Vite::content('resources/css/app.css') !!}
    </style>
    <style>
        html {
            -webkit-print-color-adjust: exact;
            height: 100%;
            margin: 0px;
        }

        @page {
            margin: 32px 32px 32px 32px;
            position: relative;
        }

        .page-break {
            page-break-before: always;
        }

        .page-break-inside {
            page-break-inside: avoid !important;
        }
    </style>
</head>

<body class="text-sm leading-snug font-sora">

    @component('pdfs.components.header')
    @endcomponent

    <h1 class="mb-4 text-2xl font-semibold uppercase">{{ ___('brand') }} Invoice</h1>

    <p class=""><span class="font-semibold">Invoice Number: </span>{{ $invoice->invoice_number }}</p>
    <p class=""><span class="font-semibold">Invoice Date: </span>{{ $invoice->created_at->format('jS F Y') }}</p>
    <p class="mb-4"><span class="font-semibold">Due Date: </span>{{ $invoice->due_date->format('jS F Y') }}</p>

    <div class="mb-4">
        <div class="font-semibold">Bill to:</div>
        {{ $invoice->advert->advertiser->name }}<br />
        @foreach ($invoice->advert->advertiser->address->components as $component)
            {{ $component }}<br />
        @endforeach
    </div>

    <div class="mb-8">
        <div class="mb-4 font-semibold">Description of Services:</div>

        <table class="min-w-full border border-black divide-y">
            <thead class="{{ $tableBg }}">
                <tr>
                    <th scope="col" class="px-4 py-2 text-xs font-semibold tracking-wider text-left text-black uppercase border border-black">Date</th>
                    <th scope="col" class="px-4 py-2 text-xs font-semibold tracking-wider text-left text-black uppercase border border-black">Description</th>
                    <th scope="col" class="px-4 py-2 text-xs font-semibold tracking-wider text-left text-black uppercase border border-black">Rate</th>
                    <th scope="col" class="px-4 py-2 text-xs font-semibold tracking-wider text-left text-black uppercase border border-black">Quantity</th>
                    <th scope="col" class="px-4 py-2 text-xs font-semibold tracking-wider text-left text-black uppercase border border-black">Amount</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @foreach ($invoice->items as $item)
                    <tr>
                        <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $item->date->format('d/m/Y') }}</td>
                        <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $item->description }}</td>
                        <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $item->rate->formatTo($locale) }}</td>
                        <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">
                            @if ($item->rate_type->value === 'hourly')
                                {{ $item->quantity }}@if ($item->quantity == 1)
                                    hour
                                @else
                                    hours
                                @endif
                            @else
                                {{ $item->quantity }}@if ($item->quantity == 1)
                                    day
                                @else
                                    days
                                @endif
                            @endif
                        </td>
                        <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $item->amount->formatTo($locale) }}</td>
                    </tr>
                @endforeach
                <tr>
                    <td colspan="5" class="px-4 py-2 {{ $tableBg }}"></td>
                </tr>
                <tr>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="px-4 py-2 text-xs font-semibold tracking-wider text-black uppercase border border-black">Subtotal:</td>
                    <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $invoice->sub_total->formatTo($locale) }}</td>
                </tr>
                <tr>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="px-4 py-2 text-xs font-semibold tracking-wider text-black uppercase border border-black">+ VAT 20%:</td>
                    <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap">{{ $invoice->vat->formatTo($locale) }}</td>
                </tr>
                <tr class=>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="border border-black"></td>
                    <td class="px-4 py-2 text-xs font-semibold tracking-wider text-black uppercase border border-black {{ $tableBg }}">Total amount due:</td>
                    <td class="px-4 py-2 text-sm text-black border border-black whitespace-nowrap {{ $tableBg }}">{{ $invoice->total->formatTo($locale) }}</td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="mb-4 font-semibold">Payment Terms:</div>

    <div class="mb-8 page-break-inside">
        <div class="font-semibold">1. Payment Due: {{ $invoice->due_date->format('jS F Y') }}</div>
        <p>Payment for this invoice is due within {{ $invoice->invoice_due_date_days }} {{ Str::plural('day', $invoice->invoice_due_date_days) }} from the invoice date. Please ensure payment is received by {{ $invoice->due_date->format('jS F Y') }}</p>
    </div>

    <div class="mb-8 page-break-inside">
        <div class="font-semibold">2. Late Payment Charges:</div>
        <p>If payment is not received within the {{ $invoice->invoice_due_date_days }}-day period, a late payment charge of {{ $invoice->invoice_late_payment_charge_percent }}% of the total amount due will be added to the invoice.</p>
    </div>

    <div class="mb-8 page-break-inside">
        <div class="font-semibold">3. Payment Methods:</div>
        <p>
            Payment should be made via bank transfer to the following account:<br />
            @if($settings->invoice_payment_account_name)<span class="font-semibold">Account Name: </span>{{ $settings->invoice_payment_account_name }}<br />@endif
            @if($settings->invoice_payment_account_number)<span class="font-semibold">Account Number: </span>{{ $settings->invoice_payment_account_number }}<br />@endif
            @if($settings->invoice_payment_account_sort_code)<span class="font-semibold">Sort Code: </span>{{ $settings->invoice_payment_account_sort_code }}<br />@endif
        </p>
    </div>

    <div class="page-break-inside">
        <div class="mb-4 font-semibold">4. Contact Information:</div>
        <div class="font-semibold">Address:</div>
        @if($settings->invoice_contact_address)<p class="mb-4">{!! $settings->invoice_contact_address !!}</p>@endif

        <div class="font-semibold">Contact:</div>
        <p>
            @if($settings->invoice_contact_email)<a class="font-semibold mb-2 {{ $accent }}" href="mailto:{{ $settings->invoice_contact_email }}">{{ $settings->invoice_contact_email }}</a> <br />@endif
            @if($settings->invoice_contact_telephone)<a class="font-semibold {{ $accent }}" href="tel:{{ $settings->invoice_contact_telephone }}">{{ $settings->invoice_contact_telephone }}</a>@endif
        </p>
    </div>

</body>

</html>
