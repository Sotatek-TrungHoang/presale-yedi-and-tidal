@php
    $config = config('app.configuration');

    $labelClass = 'block mb-2 text-sm font-semibold text-gray-700';
    $inputClass = 'block w-full px-4 py-3 rounded-lg border border-gray-400 bg-white read-only:bg-gray-100';
    $errorInputClass = 'border-red-700';
    $selectClass = "$inputClass bg-red-500 read-only:bg-white";
    $errorClass = 'block mt-2 text-sm text-red-700';

@endphp

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>{{ config('app.name') }} Reference Request</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sora:wght@100..800&display=swap');
    </style>
    @vite(['resources/css/app.css', 'resources/js/app.js'])

</head>

<body class="py-10 font-sora">

    <div class='max-w-5xl px-10 mx-auto'>

        @if ($config === 'yedi')
            <div class="mx-auto mb-12 max-w-64">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 165 71" class="h-auto">
                    <g clip-path="url(#a)">
                        <mask id="b" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#b)">
                            <path fill="#EF9F1F" d="M45.7 21.2c0-1.2-1-2-2.4-2l-5.6.2-5.4-.2c-1.9 0-2.7.8-2.7 2 0 2.8 3.8 2.3 3.8 5.3 0 1.2-.4 2.5-1.3 4.8l-6 14.8-6.7-14.8c-.9-2-1.3-3.6-1.3-4.7 0-3.4 3.7-2.6 3.7-5.4 0-1.2-1-2-2.9-2l-8 .2-8.5-.2c-1.3 0-2.4.7-2.4 2 0 2.7 3.3 1.9 6.3 8l13.7 28c-1.6 3.6-3.3 6-5.7 6-2.5 0-4.3-1.5-7.2-5.4-.7-1-1.3-1.4-2-1.4-1.3 0-2.2 1.2-2.2 2.8 0 2.8 1.6 8.2 3 10 .9 1 3.3 1.8 6.2 1.8 6.4 0 11.2-4.5 14.7-12.4L39.5 29c2.6-6 6.2-5.2 6.2-7.9Z" />
                        </g>
                        <mask id="c" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#c)">
                            <path fill="#EF9F1F" d="M79.2 42.6c-.6.1-1.2.5-2.3 1.6a15 15 0 0 1-9 5.1c-5.3.8-10-1.8-12.9-5.8l21-10.1c1.3-.6 2-1 1.6-3.2-1-7-8.7-13.4-19.2-11.8C47.5 20 39.1 29.3 41 41.2c1.8 11.6 11.5 17.9 23 16.1 8.9-1.3 15-7 16.9-11 .4-1 .5-1.5.4-2.2-.1-.6-1-1.7-2-1.5Zm-27.6-7c-1-6.3 1.7-10.6 6.1-11.3 4.2-.7 7.8 2.8 8.3 6 .2 1.5-.4 2-1.4 2.6l-12.2 5.9a17 17 0 0 1-.8-3.3Z" />
                        </g>
                        <mask id="d" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#d)">
                            <path fill="#EF9F1F" d="M124.5 44.5v-41c0-1.9-.4-3.5-2.3-3.5-.8 0-2 .1-7 2.2-5.8 2.3-7.7 3.3-7.7 4.9 0 3.5 5.8 1.2 5.8 6v8.8a16.5 16.5 0 0 0-11-3.7 19.6 19.6 0 0 0-19.9 20.4c0 12 7.7 19 17 19 6.4 0 11-3.1 13.8-7.2v3.3c0 1.5.3 3.7 2.4 3.7.7 0 1.8-.3 6.5-1.9 5.7-2 7.6-2.7 7.6-4.6 0-3-5.2-1.7-5.2-6.4Zm-11.2-5c0 6.3-4 10.4-8.7 10.4-5.1 0-10.2-5.6-10.2-14.5 0-7.2 3.4-11.6 8.7-11.6 5.4 0 10.2 5.7 10.2 13.2v2.4Z" />
                        </g>
                        <mask id="e" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#e)">
                            <path fill="#EF9F1F" d="M137.1 13.5c5.1 0 9.5-3.7 9.5-7.4 0-3-2.7-5-5.9-5-5.2 0-9.1 4-9.1 7.8 0 2.8 2.2 4.6 5.5 4.6Z" />
                        </g>
                        <mask id="f" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#f)">
                            <path fill="#EF9F1F" d="M145.4 47.8V22.3c0-2.1-.6-3.6-2.3-3.6-.9 0-1.8.3-6.7 2.4-5.4 2.4-7.2 3.4-7.2 5 0 3.4 5 1.2 5 6v15.7c0 5.5-4.5 3.8-4.5 6.8 0 1 .7 2.1 2.5 2.1l7.5-.2 7.6.2c1.7 0 2.5-1.1 2.5-2 0-3-4.4-1.4-4.4-7Z" />
                        </g>
                        <mask id="g" width="165" height="71" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance">
                            <path fill="#fff" d="M165 0H0v71h165V0Z" />
                        </mask>
                        <g mask="url(#g)">
                            <path fill="#EF9F1F" d="M158.4 45.2c-4.5 0-7.6 3-7.6 6.4 0 3.5 2.6 5.6 6.5 5.6 4.5 0 7.7-2.9 7.7-6.3 0-3.5-2.7-5.7-6.6-5.7Z" />
                        </g>
                    </g>
                    <defs>
                        <clipPath id="a">
                            <path fill="#fff" d="M0 0h165v71H0z" />
                        </clipPath>
                    </defs>
                </svg>
            </div>
        @else
            <div class="mx-auto mb-12 max-w-64">
                <svg class='logo' xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 165 64">
                    <path fill="#000" d="M30.4 53.8c0-.6-.2-.9-.8-.9l-.7.6-.3.6c-1.2 2-2.6 3-4.2 3.2-2.3 0-3.4-2.7-3.4-8.2V26.3h7.4c.4 0 .7-.3.8-.7-.1-.5-.4-.8-.8-.9H21V8.6c0-.4-.3-.7-.6-.9-.4 0-.7.2-.9.6-1 3-3.2 6-7 9.4A26.5 26.5 0 0 1 .9 24.6a1 1 0 0 0-.9.7c0 .3.4.6 1 .9 2.2 0 3.7.2 4.2.5.7.6 1 2.6 1 6.2L6 49.1c0 2.2.2 4.2.5 6 1.1 5.8 4.7 8.8 10.6 8.8a12 12 0 0 0 4.1-.7 16.6 16.6 0 0 0 9-9.4M41 17.2c1.4 0 2.9-.4 4.3-1.1a8.2 8.2 0 0 0 4.3-7.5A8.5 8.5 0 0 0 41 0a9 9 0 0 0-4.4 1.1 8 8 0 0 0-4.3 7.4c0 1.9.6 3.6 1.8 5.2a8.4 8.4 0 0 0 6.9 3.4" />
                    <path fill="#000" d="m55.1 61.7-1.8-.5c-2.5-1-3.7-4-3.7-9V23.3l-.1-.5c-.3-.5-.7-.5-1.2 0-.1 0-.3 0-.5.2a30.8 30.8 0 0 1-18.3 6.8c-.4 0-.7.3-.8.7 0 .4.3.6.8.8l.8.3c3 .9 4.5 4.4 4.5 10.5v10.1a24 24 0 0 1-.5 5c-.5 2.7-2.2 4.1-5 4.5a1 1 0 0 0-1 .7c.1.4.4.7 1 .9h26c.3-.1.5-.4.7-.9 0-.3-.4-.6-.9-.7" />
                    <path fill="#000" d="M102.4 59.9h-1.7c-1.4-.3-2.4-1.4-3-3.4a22 22 0 0 1-.7-6.3V.9l-.1-.4c-.3-.6-.7-.7-1.2-.2l-.5.4a31.3 31.3 0 0 1-18.4 6.6 1 1 0 0 0-.7.8c0 .3.3.6.7.8l.9.2c3 1 4.5 4.4 4.5 10.6v7a17.8 17.8 0 0 0-23.8 1c-4.5 4.5-6.5 10-6 16.7.2 4.3 1.6 8.2 4 11.6a18 18 0 0 0 14.2 8h1.9c3.9-.3 7.5-1.8 10.7-4.5 2 3.1 5.4 4.6 10.4 4.4 3 0 6-.8 9.1-2.5.3-.2.5-.4.5-.7 0-.5-.2-.8-.8-.8m-23.7.7c-.3.2-.6.2-.8.2-.7 0-1.4-.2-2.1-.6-3.4-2-6.2-7.3-8.7-16.1a67 67 0 0 1-1.6-7.7c-.9-7.4.2-11.5 3.2-12.3l.8-.1c.7 0 1.4.2 2.1.6 3.4 2 6.2 7.3 8.7 16.1.7 2.5 1.2 4.8 1.4 7 1.2 7.8.2 12-3 13" />
                    <path fill="#000" d="M147.4 59.9h-1.8c-2.4-.5-4.1-3.5-5-9l-1.7-13.6c-1.7-10.3-9-15.3-21.8-14.8a20 20 0 0 0-10.3 3c-3.5 2.5-4.7 5.7-3.7 9.7a7 7 0 0 0 1 2.3c1.7 2 4 2.6 6.7 2 2.6-.5 4.1-1.9 4.5-4 .3-1.7-.4-3.1-2-4.5-1.4-1.2-2-2.2-2-3.1v-.2c.2-2.4 1.7-3.6 4.6-3.6.7 0 1.4.1 2.1.4 3.1 1.1 5 4.3 5.6 9.5v1c.3 2.4-.7 4-2.8 5-1 .5-2.5.9-4.5 1.2l-9.1 1.6C101.7 44.4 99 48 99 53.4c0 1.6.3 3 1 4.5 2 4 6.5 6 13.5 6 4.4 0 8.1-1 11.3-3.3 1.4-1 2-1.6 2-1.9 2 3.5 5.5 5.2 10.8 5.3 3.6 0 7-.9 10-2.6.3-.2.4-.4.5-.7 0-.5-.2-.8-.7-.8m-22.9-1c-1.7 1.5-4 1.8-6.6.8-3.2-1.3-4.9-3.9-4.9-7.8a9 9 0 0 1 3.2-6.9l5.3-3.3c1-.6 2-1.4 2.7-2.3l1.8 15.5a4 4 0 0 1-1.5 4" />
                    <path fill="#000" d="m164.1 61.7-1.8-.5c-2.5-1-3.7-4-3.7-9V.9a1 1 0 0 0-.3-.7 1 1 0 0 0-1 0l-.5.4a30.8 30.8 0 0 1-18.2 6.7c-.5.1-.9.3-1 .8 0 .3.4.6 1 .8l.7.2c3 1 4.5 4.4 4.5 10.6v32.5a24 24 0 0 1-.4 5c-.6 2.7-2.3 4.1-5.2 4.5a1 1 0 0 0-.8.7c0 .4.3.7.8.9h26c.4-.1.7-.4.8-.9 0-.3-.4-.6-.9-.7" />
                </svg>
            </div>
        @endif

        <h1 class="mb-12 text-xl font-normal text-center">Reference Request</h1>

        <div class="mb-8">
            <p class="text-sm text-center">Thank you for providing a reference for {{ $reference->applicant->user->name }}.</p>
        </div>

</body>

</html>
