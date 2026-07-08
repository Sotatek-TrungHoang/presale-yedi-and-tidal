<?php

use Illuminate\Support\Str;

function ___($key, $replace = [], $locale = null)
{
    $translationFile = config('app.configuration');

    if (in_array($translationFile, ['yedi', 'tidal'])) {
        $key = "$translationFile.$key";
    }

    $translation = __($key, $replace, $locale);

    if (Str::startsWith($translation, ['yedi.', 'tidal.'])) {
        $translation = Str::replaceStart('yedi.', '', $translation);
        $translation = Str::replaceStart('tidal.', '', $translation);
    }

    return $translation;
}
