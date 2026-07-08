<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ ___('brand') }} Contract</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sora:wght@100..800&display=swap');
    </style>
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

        p {
            margin-bottom: 1rem;
        }

        h1,
        h2,
        h3,
        h4,
        h5 {
            margin-bottom: 0.5rem;
        }

        h1 {
            font-size: 2rem;
            font-weight: 500;
        }

        h2 {
            font-size: 1.75rem;
            font-weight: 500;
        }

        h3 {
            font-size: 1.5rem;
            font-weight: 500;
        }

        h4 {
            font-size: 1.25rem;
            font-weight: 500;
        }

        h5 {
            font-size: 1rem;
            font-weight: 500;
        }

        a {
            color: #3490dc;
            text-decoration: none;
        }
    </style>
</head>

<body class="text-sm leading-snug font-sora">

    @component('pdfs.components.header')
    @endcomponent

    {!! $wording !!}
</body>

</html>
