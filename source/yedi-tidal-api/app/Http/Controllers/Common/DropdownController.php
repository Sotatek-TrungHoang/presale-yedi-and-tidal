<?php

namespace App\Http\Controllers\Common;

use App\DTOs\Dropdowns\DropdownData;
use App\Http\Controllers\Controller;
use App\Http\Requests\Common\Dropdowns\DropdownRequest;
use App\Http\Resources\Common\Dropdowns\DropdownCollection;
use App\Registries\Dropdowns\DropdownRegistry;

class DropdownController extends Controller
{
    public function __construct(
        protected DropdownRegistry $dropdownRegistry
    ) {}

    public function __invoke(DropdownRequest $request)
    {
        $data = new DropdownData(
            search: $request->validated('search'),
            additional: $request->validated('additional'),
        );
        $option = $this->dropdownRegistry->get($request->validated('code'));

        return new DropdownCollection(
            $option
                ->authCheck()
                ->getResults($data)
        );
    }
}
