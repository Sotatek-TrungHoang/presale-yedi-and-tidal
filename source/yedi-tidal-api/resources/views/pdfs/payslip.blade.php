@php
    $advert = $payslip->advert;
    $applicant = $payslip->applicant;
    $advertiser = $advert->advertiser;
@endphp
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $payslip->payslip_number }}</title>
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
    </style>
</head>

<body class="font-sans">
    <h1>Payslip: {{ $payslip->payslip_number }}</h1>
</body>

</html>
