<?php

namespace App\Forms\Components;

use Filament\Forms\Components\RichEditor;

class RichEditorTemplateStrings extends RichEditor
{
    protected string $view = 'forms.components.rich-editor-template-strings';

    protected array $templateItems = [

    ];

    public function templateItems(array $templateItems): static
    {
        $this->templateItems = $templateItems;

        return $this;
    }

    public function getTemplateItems(): array
    {
        return $this->templateItems;
    }
}
